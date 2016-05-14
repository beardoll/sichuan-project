function [path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n是linehaul的个数
    % N是节点总的个数
    % dist_spot是节点之间的相互距离（不包括仓库）
    % dist_repo是各节点到仓库的距离
    path = 0;
    node.pathcost = 8;
    node.path = [0 4];
    cost = get_lb(node, dist_spot, dist_repo, n,N);
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
            cost = cost + mindist_tobackhaul
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
    elseif pathlen - 1 == n && n == N   % 所有路径已走完（没有backhaul节点）
        cost = cost / 2;
    else       % 剩余节点中已经没有linehaul节点
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
            cost = cost + sum(temp(1:end-2));  % 加上n-2条边的最小内联代价
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
                
