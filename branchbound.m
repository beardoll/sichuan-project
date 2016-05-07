% 用分支定界法求解最优路径
function [path] = branchbound(N, n, dist_spot, dist_repo)
    % n是linehaul的个数
    % N是节点总的个数
    % dist_spot是节点之间的相互距离（不包括仓库）
    % dist_repo是各节点到仓库的距离
    m = N - n;    % backhaul的个数
    best_c = inf;  % 当前最小代价，设为无穷大
    min_out = count_minout(N, dist_spot, dist_repo);
    repo.remaincost = sum(min_out); % 最后还要走回仓库
    repo.currentcost = min_out(1);
    repo.impose = 1:n;
    repo.size = 0;
    repo.num = 0;
    pq = repo;   % priority queue, 先把仓库添加进去
    for i = 1:length(repo.impose)   % 一次性产生所有的活节点
        node.remaincost = repo.remaincost - dist_spot(i);
        node.currentcost = repo.currentcost + dist_spot(i);
        node.impose = setdiff(repo.impose,i);
        node.size = repo.size+1;
        node.num = i;
        pq = [pq, node];
    end
    pq = rank(pq);  % 对其进行排序
    hn = pq(1);   
    pq(1) = [];   % 出栈操作
    while hn.size < N-1
        if hn.size == n  % linehaul的最后一层，接下来就要在backhaul上选择了
            new_impose = n+1:N;
            for j = 1:lenght(hn.impose)
                node.remaincost = hn.remaincost - min_cost(hn.impose(j));
                node.currentcost = hn.currentcost + dist_spot(hn.num, new_impose(j));
                node.size = hn.size + 1;
                node.impose = setdiff(new_impose,new_impose(j));
                node.num = new_impose(j);
                pq = [pq, node];
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % 出栈操作
        elseif hn.size == N-2  % backhaul的倒数第二层
            if(hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose) < best_c)
                best_c = hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose);
                hn.current_cost = best_c;
                hn.lower_cost = best_c;
                hn.size = hn.size + 1;
                pq = [pq, hn];
                pq = rank(pq);
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % 出栈操作
        else
            % 产生当前扩展节点的儿子节点
            for k = 1:length(hn.impose)
                cc = hn.current_cost + dist_spot(hn.impose(k));
                rcost = hn.remaincost - min_out(hn.impose(k));
                b = cc + rcost;   % 优先级lcost = 当前费用 + 剩余结点的最小费用和 - 当前节点的最小费用;
                if(b < best_c)
                    node.remaincost = rcost;
                    node.currentcost = cc;
                    node.size = hn.size + 1;
                    node.impose = setdiff(hn.impose, hn.impose(k));
                    node.num = hn.impose(k);
                    pq = [pq, node];
                end
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % 出栈操作
        end
    end
end

%%%%%%%%%%%%%%%% 子树数据类型定义 %%%%%%%%%%%%%%%%%%
% hn.remaincost:未走过的节点的最小出边之和
% hn.currentcost: 已走过的路径费用之和
% hn.size: 当前路径总长度
% hn.impose: 可选节点
% hn.num: 当前子树的末节点
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [order_pq] = rank(pq)
    % 对当前的pq队列进行排序
    % 假定当前搜索到的节点数量为s，当s<N-2时，优先级lcost = 当前费用+ 剩余结点的最小费用和- 当前节点的最小费用
    % 当s = N-2,N-1时，lcost = 当前回路的长度
    pq_len = length(pq);
    cost_vec = zeros(1:pq_len);
    for i = 1:pq_len
        cost_vec(i) = pq.currentcost;
    end
    [sort_vec, sort_num] = sort(cost_vec);  % 对已有费用进行排序
    order_pq = pq(sort_num);
end

function [min_out] = count_minout(N, dist_spot, dist_repo)
    % 计算最小出边
    min_out = zeros(1,N+1);    %第一个是仓库的最小出边
    min_out(1) = min(dist_repo);
    for i = 2:N+1
        min_out(i) = min(dist_spot(i-1,:));
    end
end
    
    
    
    
        
    
    
    
    
    