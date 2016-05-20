function [best_path, best_cost] = dynamicprog(N, n, dist_spot, dist_repo)

    % 算法描述：动态规划算法
    % 1.nodearr存放的是这一阶段到达各路径端点的最优解，内含
    %        impose -- 即从该node已走路径上可延伸的路径节点
    %        path   -- 即该node上已走过的路径
    % 2. cost存放的是下一阶段到达各个点的最优代价,i为下一阶段节点的索引
    % 3. nodeid与cost相对应，即要达到此最优代价，下一阶段该点应该连接到哪一个node
    
    nodeid = zeros(1,n);
    nodearr = [];
    node.impose = 1:n;
    node.path = 0;
    nodearr = [nodearr, node];
    cost = dist_repo(1:n);  % 初始化到下一阶段的最优解为从仓库出发的距离
    nodeid(1:end) = 1;   % 当前从一个点（仓库）展开
    for phase = 1:N   % 阶段计数
        if phase <= n   % 还没走到backhaul节点
            update_nodearr = [];
            if phase == n  && N-n ~=0 % 下一步要去走backhaul节点了
                cnodeid = zeros(1,N-n)-1;
                tempcost = inf(1,N-n);
                for i = 1:n
                    choice = nodeid(i);    % 选择代价最小的k-1阶段的解接入
                    if choice == -1   % 没有到此节点的路径
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = n+1:N;
                        cnode.path = [cnode.path, i];
                        update_nodearr = [update_nodearr cnode];
                        for j = 1:length(cnode.impose)
                            % 下面-n是因为数组cost是从1开始而不是从n开始
                            if cost(i) + dist_spot(i,cnode.impose(j)) < tempcost(cnode.impose(j)-n)
                                tempcost(cnode.impose(j)-n) = cost(i) + dist_spot(i,cnode.impose(j));
                                cnodeid(cnode.impose(j)-n) = length(update_nodearr);  % 新的节点插入到最后
                            end
                        end    
                    end
                end
                nodeid = cnodeid;
                cost = tempcost;
                nodearr = update_nodearr;
            elseif phase ==n  && N-n == 0  % 没有backhaul节点，直接返程
                cnodeid = -1;
                tempcost = inf;
                for i = 1:n
                    choice = nodeid(i);
                    if choice == -1   % 没有到此节点的路径
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = 0;
                        cnode.path = [cnode.path i];
                        update_nodearr = [update_nodearr cnode];
                        if cost(i) + dist_repo(i) < tempcost
                            tempcost = cost(i) + dist_repo(i);
                            cnodeid = length(update_nodearr);
                        end    
                    end
                end
                nodeid = cnodeid;
                cost = tempcost;
                nodearr = update_nodearr;
            else  % 往linehaul节点搜寻
                cnodeid = zeros(1,n)-1;
                tempcost = inf(1,n);   % 第k阶段的最小代价，初始化为无穷大
                for i = 1:n
                    choice = nodeid(i);    % 选择代价最小的k-1阶段的解接入
                    if choice == -1   % 没有到此节点的路径
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = setdiff(cnode.impose, i);  % 去掉当前可行点
                        cnode.path = [cnode.path, i];
                        update_nodearr = [update_nodearr cnode];
                        for j = 1:length(cnode.impose)
                            if cost(i) + dist_spot(i,cnode.impose(j)) < tempcost(cnode.impose(j))
                                tempcost(cnode.impose(j)) = cost(i) + dist_spot(i,cnode.impose(j));
                                cnodeid(cnode.impose(j)) = length(update_nodearr);  % 新的节点插入到最后
                            end
                        end
                    end
                end
                nodearr = update_nodearr;
                cost = tempcost;
                nodeid = cnodeid;
            end
        elseif phase < N  % 在backhaul节点上搜寻，但是还没到终点
            update_nodearr = [];
            tempcost = inf(1,N-n);   % 第k阶段的最小代价，初始化为无穷大
            cnodeid = zeros(1,N-n)-1;
            for i = 1:N-n
                choice = nodeid(i);
                if choice == -1   % 没有到此节点的路径
                    continue;
                else
                    cnode = nodearr(choice);
                    cnode.impose = setdiff(cnode.impose, i+n);
                    cnode.path = [cnode.path, i+n];
                    update_nodearr = [update_nodearr cnode];
                    for j = 1:length(cnode.impose)
                        if cost(i)+dist_spot(i+n, cnode.impose(j)) < tempcost(cnode.impose(j)-n)
                            tempcost(cnode.impose(j)-n) = cost(i) + dist_spot(i+n, cnode.impose(j));
                            cnodeid(cnode.impose(j)-n) = length(update_nodearr);
                        end
                    end
                end
            end
            nodearr = update_nodearr;
            nodeid = cnodeid;
            cost = tempcost;
        else   % 回程
            update_nodearr = [];
            tempcost = inf;
            cnodeid = -1;
            for i = 1:N-n
                choice = nodeid(i);
                if choice == -1   % 没有到此节点的路径
                    continue;
                else
                    cnode = nodearr(choice);
                    cnode.impose = 0;
                    cnode.path = [cnode.path, i+n];
                    update_nodearr = [update_nodearr cnode];
                    if cost(i)+dist_repo(i+n) < tempcost
                        tempcost = cost(i) + dist_repo(i+n);
                        cnodeid = length(update_nodearr);
                    end    
                end
            end
            nodearr = update_nodearr;
            cost = tempcost;
            nodeid = cnodeid;
        end
    end
    best_cost = cost;
    best_path = [nodearr(nodeid).path, 0];  % 加上回程的仓库节点
end