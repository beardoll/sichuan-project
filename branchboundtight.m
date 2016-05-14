function [path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n是linehaul的个数
    % N是节点总的个数
    % dist_spot是节点之间的相互距离（不包括仓库）
    % dist_repo是各节点到仓库的距离
end

function [cost] = get_lb(node, dist_spot, dist_repo, n, N)
    % 找到node节点的下界
    % 分成3大部分
    % 第一部分是已走过路径长度的2倍
    % 第二部分是已走过路径的端点到未走过节点的最小距离和
    % 第三部分是未走过节点中，linehaul和backhaul节点分别的最小内联代价
    %         也就是说，假定有n个linehaul节点，那么每个点会有两个出度，共2n条边
    %         那么最小内联代价为(n-2)*2条最短边之和
    % 第四部分是linehaul和backhaul节点的最小互连代价
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
            % 计算剩余remain_linehaulnum - 2个节点的内联代价
            costL = zeros(length(remain_linehaul), 1);  % linehaul节点间的连接代价
            for i = 1:remain_linehaulnum
                sort_cost = sort(dist_spot(remain_linehaul(i), remain_linehaul), 'ascend');
                costL(i) = sum(sort_cost(1:2));   % 最短路径相加
            end
            costL = sort(costL, 'ascend');  % 升序排序
            cost = cost + costL(1:end-2);   % 加上n-2个内联边的最短距离
        elseif remain_linehaulnum == 2  
            % 剩余linehaul节点等于2个       
            cost = cost + 2*dist_spot(remain_linehaul(1), remain_linehaul(2));            
        end
        % 求linehaul和backhaul的最小互连代价
        back_spot = n+1:N;  % backhaul节点标号
        mindist_tobackhaul = min(min(dist_spot(remain_linehaul, back_spot)));
        cost = cost + mindist_tobackhaul;
        % 计算backhaul节点的最小内联代价
        costB = zeros(N-n,1);
        for i = 1:N-n
            sort_cost = sort(dist_spot(back_spot(i),:),'ascend');
            costB(i) = sum(sort_cost(1:2));
        end
        
        %%%%%%%%%%%%%% 然后计算已走过路径到未走过端点的最小距离和  %%%%%%%%%%%%%%%%%
        mindist_start = min(dist_repo(back_spot));  % backhaul节点连接仓库的最小距离
        mindist_end = min(dist_spot(pathend,remain_linehaul));  % 剩余linehaul节点距离路径最后节点的最短距离
        cost = cost + costB(1:end-2) + mindist_start + mindist_tobackhaul + mindist_end;
        
    else       % 剩余节点中已经没有backhaul节点
        %%%%%%%%%%%%%%%%%%%%%% 首先加上最小内联代价  %%%%%%%%%%%%%%%%%%%%%%%%%%
        back_spot = n+1:N;  % backhaul节点标号
        remain_backhaul = setdiff(back_spot, path);   % 剩余节点中的backhaul节点
        remain_backhaulnum = length(remain_backhaul);
        if remain_backhaulnum >= 3
            % 剩余backhaul节点数量大于等于3
            costB = zeros(remain_backhaulnum, 1);
            for i = 1:remain_backhaulnum
                sort_cost = sort(dist_spot(back_spot(i),:),'ascend');
                costB(i) = sum(sort_cost(1:2));
            end
            cost = cost + costB(1:end-2);  % 加上n-2条边的最小内联代价
        elseif remain_backhaulnum == 2
            % 剩余backhaul节点数量等于2
            cost = cost + dist_spot(remain_backhaul(1), remain_backhaul(2));
        end
        %%%%%%%%%%%%%% 然后计算已走过路径到未走过端点的最小距离和  %%%%%%%%%%%%%%%%%
        mindist_end = min(dist_spot(remain_backhaul, pathend));  % 到路径末端点的最短距离
        mindist_start = min(dist_repo(remain_backhaul));
        cost = cost + mindist_end + mindist_start;
    end    
end
                
