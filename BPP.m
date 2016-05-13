function [results] = BPP(demand, capacity)
    % 装箱问题
    % 采用基于贪婪思想的FFD算法
    % step1: 对物品由大到小进行排序
    % step2: 对于所有的物品：先尝试将该物品装入一个已经开启的箱子中，如果装不下，则开启新的箱子
    
    n = length(demand);   % 要装载的物品数量
    box = zeros(1,n);     % 箱子初始化为空，最多需要n个箱子
    mark = 0;             % 已开启的箱子数量
    %% 对物品大小进行排序
    sort_demand = sort(demand, 'descend');
        
    
    %% 装箱操作
    mark = 1;   % 一开始的时候先开启第一个箱子
    for i=1:n
        success = 0;  % =1表示成功地在已开启的箱子中装入物品 
        for j = 1:mark
            if capacity - box(j) > sort_demand(i)
                box(j) = box(j) + sort_demand(i);
                success = 1;
                break;
            end
        end
        if success == 0
            mark = mark + 1;
            box(mark) = sort_demand(i);
        end
    end
    results = mark;
end
