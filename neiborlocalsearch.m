function [newpath, totalreducecost] = neiborlocalsearch(path, dist_spot, dist_repo, demandL, demandB, capacity, K)
% 仅路径是幅角上相邻的情况下可用
    totalreducecost = 0;
    % step1:首先对每条路径使用insertion
    for i = 1:K    
        path2 = path{i};
        if length(path2) == 2
            continue;
        else
            path2 = path2(2:end-1);
            if i == 1
                path1 = path{K};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);   % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{K} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % 最终的path包含仓库节点
            elseif i == K
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{1};
                path3 = path3(2:end-1);   % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{1} = newpath3;   % 最终的path包含仓库节点
            else
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);   % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % 最终的path包含仓库节点
            end
            totalreducecost = totalreducecost + reducecost;
        end
    end

    % step2: 对每条路径使用interchange
    for i = 1:K
        path2 = path{i};
        if length(path2) == 2
            continue;
        else
            path2 = path2(2:end-1);
            if i == 1
                path1 = path{K};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);  % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{K} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % 最终的path包含仓库节点
            elseif i == K
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{1};
                path3 = path3(2:end-1);  % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{1} = newpath3;  % 最终的path包含仓库节点
            else 
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);  % path1, path2, path3不包含仓库节点
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;   % 最终的path包含仓库节点
            end
            totalreducecost = totalreducecost + reducecost;
        end
    end
    newpath = path;
end
    

%% insertion 和interchange函数
function [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity)
    % 把path2中的节点与path1/path3进行交换
    % path1, path2, path3应当不包括仓库
    % 用于按幅角分簇的局部搜索算法
    reducecost = 0;  % 通过insertion减少的代价（取负号）
    % 在进行interchange的时候必须满足容量约束
    for i = 1:length(path2)
        if length(path1) == 0  % path1没有路径，不允许交换
            M1 = inf;
        else
            [M1, changep1] = caladdcost(i, path2, path1, dist_spot, dist_repo, capacity, demandL, demandB);
        end
        if length(path3) == 0
            M3 = inf;
        else
            [M3, changep3] = caladdcost(i, path2, path3, dist_spot, dist_repo, capacity, demandL, demandB);
        end
        if M1 == inf && M3 == inf  % 不可交换
            continue;
        else
            if M1 <= M3
                if M1 >=0  % 没有改进
                    continue;
                else   % 否则执行这次交换
                    temp = path1(changep1);
                    path1(changep1) = path2(i);
                    path2(i) = temp;
                    reducecost = reducecost + M1;
                end
            else
                if M3 >= 0 % 没有改进
                    continue;
                else   % 否则执行这次交换
                    temp = path3(changep3);
                    path3(changep3) = path2(i);
                    path2(i) = temp;
                    reducecost = reducecost + M3;
                end
            end
        end
    end
    newpath1 = path1;
    newpath2 = path2;
    newpath3 = path3;
end


function [reducecost, interchange_point] = caladdcost(nodeindex, path2, path, dist_spot, dist_repo, capacity, demandL, demandB)
    % 计算path2中第nodeindex个节点与path中某个节点的交换代价
    % 我们暂时规定linehaul只能和linehaul交换，backhaul只能和backhaul交换
    % 交换需要满足容量约束
    linehaulnum = length(demandL);
    cpos2 = path2(nodeindex);        
    M = inf;   % 交换后的路径长度差
    interchange_point = -1;
    linebound = find(path > linehaulnum); % linehaul和backhaul的分界线(line一侧)
    if isempty(linebound) == 1  % path中没有backhaul节点
        linebound = length(path);
    else
        linebound = linebound(1)-1;
    end
    lineindex = find(path <= linehaulnum);  % path的linehaul节点编号
    lineindex2 = find(path2 <= linehaulnum);  % path2的linehaul节点编号
    if cpos2 <= linehaulnum   % cpos2是前向节点
        demand1L = sum(demandL(path(lineindex)));  % path的linehaul总负担
        demand2L = sum(demandL(path2(lineindex2)));  % path2的linehaul总负担
        for i = 1:linebound
            cpos = path(i);   % cpos是path中的第i个节点，与cpos2交换
            diff = demandL(cpos2) - demandL(cpos); % 交换给双方带来的负担差值，
            if demand1L + diff > capacity || demand2L - diff > capacity  %  交换后至少有一方超容量，则不可交换
                continue;
            else
                if i == 1 && length(path) == 1
                    if nodeindex == 1 && length(path2) == 1   % 两条路径都只有一个节点
                        M = inf;
                        interchange_point = 1;
                    else
                        if nodeindex == 1
                            npos2 = path2(nodeindex+1);
                            temp = -dist_repo(cpos)+dist_repo(cpos2)-dist_spot(cpos2,npos2)+dist_spot(cpos,npos2);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        elseif nodeindex == length(path2)
                            ppos2 = path2(nodeindex-1);
                            temp = -dist_repo(cpos)+dist_repo(cpos2)-dist_spot(cpos2,ppos2)+dist_spot(ppos2,cpos);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        else
                            ppos2 = path2(nodeindex-1);
                            npos2 = path2(nodeindex+1);
                            temp = -dist_repo(cpos)+dist_repo(cpos2)...
                                -dist_spot(ppos2,cpos2)-dist_spot(cpos2,npos2)...
                                +dist_spot(ppos2,cpos)+dist_spot(cpos,npos2);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        end
                    end
                else
                    if i == 1  % 从仓库出来的第一个节点
                        if nodeindex == 1 && length(path2) == 1  % 唯一节点
                            npos = path(i+1);   % path当前选中节点的下一个节点
                            temp = -dist_repo(cpos2) + dist_repo(cpos) - dist_spot(cpos,npos) + dist_spot(cpos2,npos);
                            if temp < M
                                M = temp;
                                interchange_point = i;  % path中的interchange节点
                            end
                        else
                            if nodeindex == 1  % cpos2是从仓库出来的第一个节点
                                npos2 = path2(nodeindex+1);   % path2当前选中节点的下一个节点
                                npos = path(i+1);   % path当前选中节点的下一个节点
                                temp = - dist_spot(cpos2, npos2) + dist_spot(cpos,npos2) - dist_spot(cpos, npos) + dist_spot(cpos2, npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;  % path中的interchange节点
                                end
                            elseif nodeindex == length(path2)  % path2路径中最后一个节点（无后向节点）
                                ppos2 = path2(nodeindex-1);  % path2当前选中节点的前一个节点
                                npos = path(i+1);  % path当前选中节点的下一个节点
                                temp = -dist_spot(ppos2, cpos2)+dist_spot(ppos2, cpos)-dist_spot(cpos, npos)+dist_spot(cpos2, npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else   % cpos2是其他路径中间的节点
                                npos = path(i+1);   % path当前节点的下一个节点
                                ppos2 = path2(nodeindex-1);  % path2当前节点的前一个节点
                                npos2 = path2(nodeindex+1);  % path2当前节点的前一个节点
                                temp = -dist_spot(ppos2, cpos2) - dist_spot(cpos2, npos2)...
                                    +dist_spot(ppos2, cpos) + dist_spot(cpos, npos2)...
                                    -dist_repo(cpos) - dist_spot(cpos, npos)...
                                    +dist_repo(cpos2) + dist_spot(cpos2, npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        end
                    elseif i == length(path)  %  path路径中最后一个节点（无后向节点）
                        cpos = path(i);
                        if nodeindex == 1 && length(path2) == 1  % 唯一节点
                            ppos = path(i-1);    % path当前节点的前一个
                            temp = -dist_repo(cpos2) + dist_repo(cpos) - dist_spot(ppos,cpos) + dist_spot(ppos, cpos2);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        else    
                            if nodeindex == 1   % cpos2是从仓库出来的第一个节点
                                npos2 = path2(nodeindex+1);   % path2当前节点的前一个节点
                                ppos = path(i-1);    % path当前节点的前一个
                                temp = - dist_spot(cpos2,npos2) + dist_spot(cpos, npos2) - dist_spot(cpos, ppos) + dist_spot(ppos, cpos2);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            elseif nodeindex == length(path2)  % path2路径中最后一个节点（无后向节点）
                                ppos2 = path2(nodeindex-1);  % path2当前节点的前一个节点
                                ppos = path(i-1);     % path当前节点的前一个节点
                                temp = -dist_spot(ppos,cpos)+dist_spot(ppos, cpos2)-dist_spot(ppos2, cpos2)+dist_spot(ppos2,cpos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else    % cpos2是其他路径中间的节点
                                ppos = path(i-1);   % path路径当前节点的前一个节点
                                ppos2 = path2(nodeindex-1);  % path2路径当前节点的前一个节点
                                npos2 = path2(nodeindex+1);  % path2路径当前节点的下一个节点
                                temp = -dist_spot(ppos2, cpos2)-dist_spot(cpos2, npos2)...
                                    +dist_spot(ppos2, cpos)+dist_spot(cpos,npos2)...
                                    -dist_spot(ppos, cpos)-dist_repo(cpos)...
                                    +dist_spot(ppos, cpos2)+dist_repo(cpos2);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        end
                   else   % i是path路径中间的一个节点
                        ppos = path(i-1);  % ppos是path路径当前节点的前一个节点
                        npos = path(i+1);  % npos是path路径当前节点的下一个节点
                        if nodeindex == 1 && length(path2) == 1   % 唯一节点
                            temp = -dist_repo(cpos2)+dist_repo(cpos)...
                                -dist_spot(ppos, cpos)-dist_spot(cpos, npos)...
                                +dist_spot(ppos, cpos2)+dist_spot(cpos2, npos);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        else
                            if nodeindex == 1    % cpos2是从仓库出来的第一个节点
                                npos2 = path2(nodeindex+1);
                                temp = -dist_repo(cpos2)-dist_spot(cpos2, npos2)...
                                    +dist_spot(cpos, npos2)+dist_repo(cpos)...
                                    -dist_spot(ppos, cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            elseif nodeindex == length(path2)   % cpos2是路径的最后一个节点，连接仓库
                                ppos2 = path2(nodeindex-1);  % ppos2是path2路径当前节点的前一个节点
                                temp = -dist_repo(cpos2)-dist_spot(ppos2,cpos2)...
                                    +dist_spot(ppos2, cpos)+dist_repo(cpos)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else    % cpos2是其他路径中间的节点
                                ppos2 = path2(nodeindex-1);  % ppos2是path2路径当前节点的前一个节点
                                npos2 = path2(nodeindex+1);  % npos2是path2路径当前节点的下一个节点
                                temp = - dist_spot(ppos2,cpos2)-dist_spot(cpos2,npos2)...
                                    +dist_spot(ppos2,cpos)+dist_spot(cpos,npos2)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos,cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        end
                    end
                end
            end
        end
        
        
    else   % cpos2是backhaul节点
        if linebound == length(path)  % path中没有后向节点
            M = inf;
            interchange_point = -1;  % 没有可插入点
        else
            backindex = find(path > linehaulnum);  % path中backhaul节点标号
            backindex2 = find(path2 > linehaulnum);  % path2中backhaul节点标号
            if isempty(backindex) == 1 % path中没有backhaul，没得交换
                M = inf;
                interchange_point = -1;
            else
                demand1B = sum(demandB(path(backindex)-linehaulnum));            
                demand2B = sum(demandB(path2(backindex2)-linehaulnum));
                for i =linebound+1:length(path)
                    cpos = path(i);
                    diff = demandB(cpos2-linehaulnum) - demandB(cpos-linehaulnum); % 交换给双方带来的负担差值，
                    if demand1B + diff > capacity || demand2B - diff > capacity
                        continue;
                    else
                        if i == length(path)   % i是path中的最后一个节点
                            if nodeindex == length(path2)  % cpos2是path2路径中最后一个节点（无后向节点）
                                ppos2 = path2(nodeindex-1);  % ppos2是path2当前节点的前一个节点
                                ppos = path(i-1);   % ppos是path当前节点的前一个节点
                                temp = -dist_spot(ppos,cpos)+dist_spot(ppos, cpos2)-dist_spot(ppos2, cpos2)+dist_spot(ppos2,cpos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else   % cpos2是其他路径中间的节点
                                ppos = path(i-1);   % ppos是path当前节点的前一个节点
                                ppos2 = path2(nodeindex-1);  % ppos2是path2当前节点的前一个节点
                                npos2 = path2(nodeindex+1);  % npos2是path2当前节点的下一个节点
                                temp = -dist_spot(ppos2, cpos2)-dist_spot(cpos2, npos2)...
                                    +dist_spot(ppos2, cpos)+dist_spot(cpos,npos2)...
                                    -dist_spot(ppos, cpos)-dist_repo(cpos)...
                                    +dist_spot(ppos, cpos2)+dist_repo(cpos2);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        else  % i是path中其他路径中间节点
                            ppos = path(i-1);  % ppos是path当前节点的前一个节点
                            npos = path(i+1);  % npos是path当前节点的下一个节点
                            if nodeindex == length(path2)  
                                ppos2 = path2(nodeindex-1); % ppos2是path2当前节点的前一个节点
                                temp = -dist_repo(cpos2)-dist_spot(ppos2,cpos2)...
                                    +dist_spot(ppos2, cpos)+dist_repo(cpos)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else  % cpos2是其他路径中间的节点
                                ppos2 = path2(nodeindex-1);  % ppos2是path2当前节点的前一个节点
                                npos2 = path2(nodeindex+1); % npos2是path2当前节点的下一个节点
                                temp = - dist_spot(ppos2,cpos2)-dist_spot(cpos2,npos2)...
                                    +dist_spot(ppos2,cpos)+dist_spot(cpos,npos2)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos,cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        end
                    end
                end
            end
        end 
    end
    reducecost = M;
end
                    
function [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity)
    % 用于按幅角分簇的路径的局部搜索算法
    % 将path2的节点插入path1/path3
    % path1, path2, path3应当不包括仓库
    reducecost = 0;  % 通过insertion减少的代价（取负号）
    linehaulnum = length(demandL);
    stop = 0;
    cindex = 1;
    if length(path1) == 0
        demand1L = 0;
        demand1B = 0;
    else
        lineindex1 = find(path1 <= linehaulnum);
        backindex1 = find(path1 > linehaulnum);
        demand1L = sum(demandL(path1(lineindex1)));        
        if isempty(backindex1) == 1  % 没有backhaul节点
            demand1B = 0;
        else
            demand1B = sum(demandB(path1(backindex1)-linehaulnum));
        end
    end    
    if length(path3) == 0
        demand3L = 0;
        demand3B = 0;
    else
        lineindex3 = find(path3 <= linehaulnum);
        backindex3 = find(path3 > linehaulnum);
        demand3L = sum(demandL(path3(lineindex3)));
        if isempty(backindex3) == 1  % 没有backhaul节点
            demand3B = 0;
        else
            demand3B = sum(demandB(path3(backindex3)-linehaulnum));
        end
    end
    
    while stop == 0
        cpos = path2(cindex);
        if cindex == 1 
            if cindex == length(path2)  % 是此路径中的唯一节点 
                savecost = -2*dist_repo(cpos);
            elseif path2(2) > linehaulnum % 只剩下唯一个linehual节点了
                savecost = 0;
                cindex = cindex + 1;
                continue;
            else
                npos = path2(cindex+1); % cpos的下一个节点
                savecost = dist_repo(npos) - dist_repo(cpos) - dist_spot(cpos,npos);
            end
        else  % 不是此路径中的唯一节点 
            if cindex == length(path2) 
                ppos = path2(cindex-1);  % cpos的前一个节点
                savecost = dist_repo(ppos) - dist_repo(cpos) - dist_spot(ppos, cpos);
            else
                ppos = path2(cindex-1);
                npos = path2(cindex+1);
                savecost = dist_spot(ppos, npos) - dist_spot(ppos, cpos) - dist_spot(cpos, npos);
            end
        end
        
        % 计算把cpos插入到path1和path3的最小代价
        % 先判断是否满足容量约束
        if cpos <= linehaulnum % cpos是前向节点
            if demandL(cpos) + demand1L <= capacity
                [insert_point1, M1] = caladdingcost(cpos, path1, linehaulnum, dist_spot, dist_repo);
            else
                M1 = inf;   % 容量不足，插入失败
            end
            if demandL(cpos) + demand3L <= capacity                
                [insert_point3, M3] = caladdingcost(cpos, path3, linehaulnum, dist_spot, dist_repo);
            else
                M3 = inf;  % 容量不足，插入失败
            end
        else  % cpos是后向节点
            if demandB(cpos-linehaulnum) + demand1B <= capacity
                if cpos > linehaulnum && length(path1) == 0
                    M1 = inf;
                else    
                    [insert_point1, M1] = caladdingcost(cpos, path1, linehaulnum, dist_spot, dist_repo);
                end
            else
                M1 = inf;
            end
            if demandB(cpos-linehaulnum) + demand3B <= capacity
                if cpos > linehaulnum && length(path3) == 0  % 不允许直接把backhaul插入到空路径中
                    M3 = inf;
                else
                    [insert_point3, M3] = caladdingcost(cpos, path3, linehaulnum, dist_spot, dist_repo);
                end
            else 
                M3 = inf;
            end
        end
        
        % 找插入代价最小的路径及具体的地方插入
        if M3 == inf && M1 == inf   % 如果往两边都插入失败，则cpos不变，继续找下一个点
            cindex = cindex + 1;
        else
            if M1 <= M3
                if savecost + M1 < 0  % 确实节省了路径代价
                    reducecost = reducecost + savecost + M1;
                    newpath1 = zeros(1,length(path1)+1);
                    if insert_point1 == 0  % 如果插入path的开头
                        newpath1(1) = cpos;
                        newpath1(2:end) = path1;
                    elseif insert_point1 == length(path1)  % 插入到路径最后
                        newpath1(1:end-1) = path1;
                        newpath1(end) = cpos;
                    else
                        newpath1(1:insert_point1) = path1(1:insert_point1);
                        newpath1(insert_point1+1) = cpos;
                        newpath1(insert_point1+2:end) = path1(insert_point1+1:end);
                    end
                    path1 = newpath1;
                    path2(cindex) = [];  % 在path2中去掉cpos
                else  % cpos不适合做insertion，那么选择path2中的下一个节点
                    cindex = cindex + 1;
                end
            else
                if savecost + M3 < 0  % 确实节省了路径代价
                    reducecost = reducecost + savecost + M3;
                    newpath3 = zeros(1,length(path3)+1);
                    if insert_point3 == 0  % 如果插入path的开头
                        newpath3(1) = cpos;
                        newpath3(2:end) = path3;
                    elseif insert_point3 == length(path3)  % 插入到路径最后
                        newpath3(1:end-1) = path3;
                        newpath3(end) = cpos;
                    else
                        newpath3(1:insert_point3) = path3(1:insert_point3);
                        newpath3(insert_point3+1) = cpos;
                        newpath3(insert_point3+2:end) = path3(insert_point3+1:end);
                    end
                    path3 = newpath3;
                    path2(cindex) = [];  % 在path2中去掉cpos
                else
                    cindex = cindex + 1;
                end
            end
        end
        if cindex > length(path2)  % 已经完成了所有的检索，停止while-loop
            stop = 1;
        end
    end
    newpath1 = path1;
    newpath2 = path2;
    newpath3 = path3;
end

function [insert_point, M] = caladdingcost(cpos, path, linehaulnum, dist_spot, dist_repo)
    % 计算把cpos插入到path中的最小增加代价
    if length(path) == 0   % path是空的
        insert_point = 0;
        M = dist_repo(cpos)*2;
    else
        linehaulbound = find(path > linehaulnum);
        if isempty(linehaulbound) == 1  % 如果linehaulbound为空
            linehaulbound = length(path);
        else
            linehaulbound = linehaulbound(1)-1;     % path的前向节点分界线
        end
        M = inf;   % 插入到path的最小增加代价
        insert_point = 0;
        if cpos <= linehaulnum  % cpos是前向节点
            for j = 1:linehaulbound+1  % 一共有这么多个可行插入点
                if j == 1
                    npos = path(j);   % 插入点后方节点，前方是仓库
                    temp = dist_repo(cpos) + dist_spot(cpos, npos) - dist_repo(npos);
                    if temp < M
                        M = temp;
                        insert_point = 0;  % 插入到仓库后面
                    end
                elseif j > length(path)  % 没有backhaul节点
                    ppos = path(end);   % 插入点前方节点，后方是仓库
                    temp = dist_repo(cpos) + dist_spot(cpos, ppos) - dist_repo(ppos);
                    if temp < M
                        M = temp;
                        insert_point = length(path);  % 插入到path1的末节点后面
                    end
                else
                    ppos = path(j-1);  % 插入点前方节点
                    npos = path(j);    % 插入点后方节点
                    temp = dist_spot(ppos,cpos)+dist_spot(cpos,npos)-dist_spot(ppos,npos);
                    if temp < M
                        M = temp;
                        insert_point = j-1;  % 插入点前方节点
                    end
                end
            end
        else   % 插入点是后方节点
            for j = linehaulbound : length(path)
                if j == length(path)   % 插入点后方节点是仓库
                    ppos = path(end);
                    temp = dist_repo(cpos) + dist_spot(cpos,ppos) - dist_repo(ppos);
                    if temp < M
                        M = temp;
                        insert_point = length(path);
                    end
                else
                    save('hehe.mat', 'path','linehaulnum');
                    ppos = path(j);
                    npos = path(j+1);
                    temp = dist_spot(ppos,cpos)+dist_spot(cpos,npos)-dist_spot(ppos,npos);
                    if temp < M
                        M = temp;
                        insert_point = j;  % 插入点前方节点
                    end
                end           
            end
        end
    end
end

                
                            
    
    
            
