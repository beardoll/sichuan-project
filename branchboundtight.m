function [best_path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n是linehaul的个数
    % N是节点总的个数
    % dist_spot是节点之间的相互距离（不包括仓库）
    % dist_repo是各节点到仓库的距离
    
    %%%%%%%%%%%%%%%%%%%%%%%%% 测试用代码 %%%%%%%%%%%%%%%%%%%%%%%%%%
%     best_path = 0;
%     node.pathcost = 5;
%     node.path = [0 3];
%     cost = get_lb(node, dist_spot, dist_repo, n,N);
%     path = 0;
%     [cost] = greedy_algorithm(N, n, dist_spot, dist_repo);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % 初始化
    pq = [];
    hn.num = 0;
    hn.pathcost = 0;
    hn.path = [0];
    [best_path1, best_c1] = route(N, n, dist_spot, dist_repo);  % 利用贪婪算法计算出来的上界
    [best_path2, best_c2] = greedy_algorithm(N, n, dist_spot, dist_repo);  % 利用贪婪算法计算出来的上界
    if best_c1 <= best_c2
        best_path = best_path1;
        best_c = best_c1;
    else
        best_path = best_path2;
        best_c = best_c2;
    end
    for i = 1:n
        node.pathcost = hn.pathcost + dist_repo(i);
        node.path = [hn.path, i];
        node.lb = get_lb(node, dist_spot, dist_repo, n, N);
        if node.lb < best_c
            node.num = i;
            pq = [pq, node];
        end
    end
    while isempty(pq) ~= 1  % 当pq不为空时
        pq = rank(pq);
        hn = pq(1);
        pq(1) = [];
        if length(hn.path) - 1 < n   % 当前还在linehaul节点上寻找路径
            line_spot = 1:n;
            impose = setdiff(line_spot, hn.path); % 没走过的linehaul节点
            for i = 1:length(impose)
                node.path = [hn.path, impose(i)];
                node.pathcost = hn.pathcost + dist_spot(hn.num, impose(i));
                node.lb = get_lb(node, dist_spot, dist_repo, n, N);
                if node.lb < best_c
                    node.num = impose(i);
                    pq = [pq, node];
                end
            end
        elseif length(hn.path) - 1 == n && n == N || length(hn.path)-1 == N % 没有backhaul节点
            cc = hn.pathcost + dist_repo(hn.num);
            if cc < best_c
                best_c = cc;
                best_path = [hn.path 0];
            end
        else  % 还没到最后一层
            back_spot = n+1:N;
            impose = setdiff(back_spot, hn.path);  % 没走过的backhaul节点
            for i = 1:length(impose)
                node.path = [hn.path, impose(i)];
                node.pathcost = hn.pathcost + dist_spot(hn.num, impose(i));
                node.lb = get_lb(node, dist_spot, dist_repo, n, N);
                if node.lb < best_c
                    node.num = impose(i);
                    pq = [pq, node];
                end
            end
        end
    end
    cost = best_c;
end

function [cost] = get_lb(node, dist_spot, dist_repo, n, N)
    % 找到node节点的下界
    % 分成4大部分
    % 第一部分是已走过路径长度的2倍
    % 第二部分是已走过路径的端点到未走过节点的最小距离和
    %         也就是说，假定有n个linehaul节点，那么每个点会有两个出度，共2n条边
    %         那么最小内联代价为(n-1)*2条最短边之和
    % 第三部分是未走过节点中，linehaul和backhaul节点分别的最小内联代价
    % 第四部分是linehaul和backhaul节点的最小互连代价(如果没有backhaul节点，则不需要)
    path = node.path;   % 已走过的路径
    pathlen = length(path);  % 路径长度
    cost = 0;
    cost = cost + node.pathcost*2;  % 加上已走过的路径长度的2倍
    

    pathend = path(end);  % 路径中最后一个节点
    if pathlen - 1 < n   % 剩余节点中含有linehaul节点
        %%%%%%%%%%%%%%%%%%%%%% 首先加上最小内联代价  %%%%%%%%%%%%%%%%%%%%%%%%%%
        line_spot = 1:n;  % linehaul节点标号
        remain_linehaul = setdiff(line_spot, path);  % 剩余节点中的linehaul节点
        remain_linehaulnum = length(remain_linehaul);
        if remain_linehaulnum >= 3  
            % 剩余linehaul节点大于等于3个
            % 计算剩余(remain_linehaulnum - 1)*2个节点的内联代价
            costL = zeros(length(remain_linehaul), 2);  % linehaul节点间的连接代价
            for i = 1:remain_linehaulnum
                sort_cost = sort(dist_spot(remain_linehaul(i), remain_linehaul), 'ascend');
                costL(i,:) = sort_cost(1:2);   % 最短路径相加
            end
            temp = costL(:);
            temp = sort(temp, 'ascend');
            cost = cost + sum(temp(1:end-2));  % 加上2*(n-1)个内联边的最短距离

        elseif remain_linehaulnum == 2  
            % 剩余linehaul节点等于2个       
            cost = cost + 2*dist_spot(remain_linehaul(1), remain_linehaul(2));            
        end
        if n == N   % 没有backhaul节点
            mindist_start = min(dist_repo(remain_linehaul));
        else   % 有linehaul节点
            % 求linehaul和backhaul的最小互连代价
            back_spot = n+1:N;  % backhaul节点标号
            mindist_tobackhaul = min(min(dist_spot(remain_linehaul, back_spot)));
            cost = cost + mindist_tobackhaul*2;
            % 计算backhaul节点的最小内联代价
            costB = zeros(N-n,2);
            if  length(back_spot) == 2  % 剩余两个backhaul节点
                cost = cost + dist_spot(back_spot(1), back_spot(2))*2;
            elseif length(back_spot) >= 3
                for i = 1:N-n
                    sort_cost = sort(dist_spot(back_spot(i),back_spot),'ascend');
                    costB(i,:) = sort_cost(1:2);
                end
                costB = sort(costB, 'ascend');
                temp = costB(:);
                temp = sort(temp, 'ascend');
                cost = cost + sum(temp(1:end-2));
            end
            %%%%%%%%%%%%%% 然后计算已走过路径到未走过端点的最小距离和  %%%%%%%%%%%%%%%%%
            mindist_start = min(dist_repo(back_spot));  % backhaul节点连接仓库的最小距离
        end
        if pathend == 0
            mindist_end = min(dist_repo(remain_linehaul));
        else
            mindist_end = min(dist_spot(pathend,remain_linehaul));  % 剩余linehaul节点距离路径最后节点的最短距离
        end
        cost = cost + 2*mindist_start + 2*mindist_end;
        cost = cost / 2;
    elseif pathlen - 1 == n && n == N  || pathlen - 1 == N % 所有路径已走完（没有backhaul节点）
        cost = cost / 2;
    elseif pathlen - 1 < N       % 剩余节点中已经没有linehaul节点
        %%%%%%%%%%%%%%%%%%%%%% 首先加上最小内联代价  %%%%%%%%%%%%%%%%%%%%%%%%%%
        back_spot = n+1:N;  % backhaul节点标号
        remain_backhaul = setdiff(back_spot, path);   % 剩余节点中的backhaul节点
        remain_backhaulnum = length(remain_backhaul);
        if remain_backhaulnum >= 3
            % 剩余backhaul节点数量大于等于3
            costB = zeros(remain_backhaulnum, 2);
            for i = 1:remain_backhaulnum
                sort_cost = sort(dist_spot(back_spot(i),back_spot),'ascend');
                costB(i,:) = sort_cost(1:2);
            end
            temp = costB(:);
            temp = sort(temp);
            cost = cost + sum(temp(1:end-2));  % 加上(n-1)*2条边的最小内联代价
        elseif remain_backhaulnum == 2
            % 剩余backhaul节点数量等于2
            cost = cost + 2*dist_spot(remain_backhaul(1), remain_backhaul(2));
        end
        %%%%%%%%%%%%%% 然后计算已走过路径到未走过端点的最小距离和  %%%%%%%%%%%%%%%%%
        mindist_end = min(dist_spot(remain_backhaul, pathend));  % 到路径末端点的最短距离
        mindist_start = min(dist_repo(remain_backhaul));
        cost = cost + 2*mindist_end + 2*mindist_start;
        cost = cost / 2;
    end    
end

function [order_pq] = rank(pq)
    % 根据下界对当前的pq队列进行排序
    pq_len = length(pq);
    cost_vec = zeros(1,pq_len);
    for i = 1:pq_len
        cost_vec(i) = pq(i).lb;  % 得到每个节点的下界
    end
    [sort_vec, sort_num] = sort(cost_vec);  % 对已有费用进行排序
    order_pq = pq(sort_num);
end

function [cpath, cost] = greedy_algorithm(N, n, dist_spot, dist_repo)
% 利用贪婪算法求得初始上界
    csp = 0;
    cost = 0;
    nsp = find(dist_repo(1:n) == min(dist_repo(1:n))); % 找到最近的linehaul节点
    nsp = nsp(1);
    path = [nsp];         % 已走过的路径，不包括起点和重点
    cost = cost + dist_repo(nsp);
    csp = nsp;
    for i = 1:n-1        
        temp = dist_spot(csp,1:n);
        temp(path) = inf;
        nsp = find(temp == min(temp));
        cost = cost + dist_spot(csp, nsp);
        path = [path, nsp];
        csp = nsp;
    end
    cpath = [0 path];
    if n == N   % 没有backhaul节点
        cost = cost + dist_repo(csp);
        cpath = [cpath 0];
    else  % 有backhaul节点
        temp = dist_spot(csp, n+1:N);
        nsp = find(temp == min(temp)) + n;
        cost = cost + dist_spot(csp, nsp);
        path = nsp;    % 把linehaul节点去掉
        csp = nsp;
        for j = n+1:N-1
            temp = dist_spot(csp,n+1:N);
            temp(path-n) = inf;
            nsp = find(temp == min(temp)) + n;  % 前面有n个linehaul节点
            cost = cost + dist_spot(csp, nsp);
            path = [path, nsp];
            csp = nsp;
        end
        cost = cost + dist_repo(csp);
        cpath = [cpath, path, 0];
    end        
end

function [path, cost] = route(N, n, dist_spot, dist_repo)
    U = 1:N;   % 未添加到路径中的节点
    delta = dist_repo;  % 考虑完全图，且对称
    route = [];  % 去掉仓库节点的当前路径节点
    cost = 0;
    while isempty(U) == 0
        % 线找出delta最大的点
        temp = delta;
        sortdelta = sort(temp, 'descend');
        index = 1;
        i = find(temp == sortdelta(index));
        i = i(1);
        while ismember(i,U) == 0  % i不是U里面的元素，说明i已经走过 
            temp(i) = -1;
            index = index + 1;
            i = find(temp == sortdelta(index));
            i = i(1);
        end
            
        M = inf;
        if length(route) == 0   % 刚刚从仓库出发
            M = dist_repo(i)*2;
            insert_point = 0;
        else   % 寻找最适宜插入点
            bound = find(route > n);
            if i>n  % 如果i是backhaul节点
                if isempty(bound) == 0   % 路径中有backhaul节点
                    bound = bound(1) - 1;   % 最后一个linehaul节点(相对下标索引)
                    for k = bound :length(route)
                        if k == length(route)  % 到达路径的最后
                            cpos = route(k);
                            diff = dist_repo(i) + dist_spot(cpos, i) - dist_repo(cpos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % 插入点（前）
                            end
                        elseif k == 0  % 路径中仅有backhaul节点
                            npos = route(k+1);
                            diff = dist_repo(i)+dist_spot(i,npos)-dist_repo(npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % 插入点（前）
                            end
                        else
                            cpos = route(k);
                            npos = route(k+1);
                            diff = dist_spot(cpos, i)+dist_spot(i, npos) - dist_spot(cpos, npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % 插入点（前）
                            end
                        end
                    end
                else  % 如果路径中没有后向节点，即这是第一个后向节点，那么直接插入到最后
                    insert_point = length(route);   % 插入点（前）
                    M = dist_repo(i)+dist_spot(i, insert_point) - dist_repo(insert_point);
                end
            else   % 如果i是linehaul节点
                if isempty(bound)==0  % 如果路径中有backhaul节点
                    bound = bound(1) - 1; % 最后一个linehaul节点（相对下标索引）
                else
                    bound = length(route);   % 路径中没有backhaul节点
                end
                for k = 0:bound
                    if k == 0  % 如果当前插入点的前节点是仓库   
                        npos = route(k+1);
                        diff = dist_repo(i) + dist_spot(i, npos) - dist_repo(npos);
                        if diff < M
                            M = diff;
                            insert_point = k;   % 插入点（前）
                        end
                    else  % 如果当前插入点的前节点不是仓库
                        if k == length(route)   % 如果k是路径中最后位置
                            cpos = route(k);
                            diff = dist_repo(i) + dist_spot(cpos, i) - dist_repo(cpos);
                            if diff < M
                                M = diff;
                                insert_point = k;
                            end
                        else  % 如果k不是路径中的最后位置
                            cpos = route(k);   
                            npos = route(k+1);
                            diff = dist_spot(cpos, i)+dist_spot(i, npos) - dist_spot(cpos, npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % 插入点（前）
                            end
                        end
                    end
                end
            end
        end
        cost = cost + M;
        % 更新route和U
        U = setdiff(U, i);
        newroute = zeros(length(route)+1, 1);
        if insert_point == length(route)   % 插入到路径最后
            newroute(1:length(route)) = route;
            newroute(end) = i;
        elseif insert_point == 0  % 插入到开头
            newroute(2:end) = route;
            newroute(1) = i;
        else
            newroute(1:insert_point) = route(1:insert_point);
            newroute(insert_point+1) = i;
            newroute(insert_point+2:end) = route(insert_point+1:end);
        end
        route = newroute;
        % 更新delta
        for j = 1:length(U)
            if dist_spot(i,j) < delta(j)
                delta(j) = dist_spot(i,j);
            end
        end
    end
    % 加上最后回到仓库的回路
    path = [0; route ;0]';
end
    
                
