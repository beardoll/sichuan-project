% 用分支定界法求解最优路径
function [path] = branchbound(N, n, dist_spot, dist_repo)
    % n是linehaul的个数
    % N是节点总的个数
    % dist_spot是节点之间的相互距离（不包括仓库）
    % dist_repo是各节点到仓库的距离
    m = N - n;    % backhaul的个数
    pq = [];   % priority queue
    treeroot = 0;   % 初始化，从仓库开始
    impose = 1:m; %初始化可行子节点为所有的Linehaul
    pq = mincost(impose);  % 从可行的子节点中寻找代价最小者
end

function [min_spot] = mincost(impose)
    % 从impose中找出代价最小的子节点
    
    
    