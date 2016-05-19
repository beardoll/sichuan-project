function [cost] = route(N, n, dist_spot, dist_repo)
    U = 1:n;   % 未添加到路径中的节点
    delta = dist_repo;  % 考虑完全图，且对称
    route = [0];
    cost = 0;
    while isempty(U) == 0
        i = find(delta == max(delta));   % 找出delta最大的点
        delta(i) = -1;   % 未来不会再选这个点   
        M = inf;
        if length(route) == 1   % 刚刚从仓库出发
            route = [route i];
            M = dist_repo(i)*2;
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
                                insert_point = k;
                            end
                        else
                            cpos = route(k);
                            npos = route(k+1);
                            diff = dist_spot(cpos, i)+dist_spot(i, npos) - dist_spot(cpos, npos);
                            if diff < M
                                M = diff;
                                insert_point = k;
                            end
                        end
                    end
                else  % 如果路径中没有后向节点，即这是第一个后向节点，那么直接插入到最后
                    insert_point = route(end);   % 插入点（前）
                end
            else   % 如果i是linehaul节点
                if isempty(bound)==0  % 如果路径中有backhaul节点
                    bound = bound(1) - 1; % 最后一个linehaul节点（相对下标索引）
                else
                    bound = length(route);   % 路径中没有backhaul节点
                end
                for k = 1:bound
                    if cpos == 0  % 如果当前插入点的前节点是仓库
                        cpos = route(k);   
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
            cost = cost + M;
            % 更新route和U
            U = setdiff(U, i);
            newroute = zeros(length(route)+1, 1);
            if insert_point == length(route)   % 插入到路径最后
                newroute(1:length(route)) = route;
                newroute(end) = i;
            else
                newroute(1:insert_point) = route(1:insert_point);
                newroute(insert_point+1) = i;
                newroute(insert_point+1:end) = route(insert_point:end);
            end
            route = newroute;
            % 更新delta
            for j = 1:length(U)
                if dist_spot(i,j) < delta(j)
                    delta(j) = dist_spot(i,j);
                end
            end
        end
    end
    % 加上最后回到仓库的回路
    endspot = route(end);
    cost = cost + dist_repo(endspot);
end
    