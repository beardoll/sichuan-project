function [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity)
    % 将path2的节点插入path1/path3
    % path1, path2, path3应当不包括仓库
    reducecost = 0;  % 通过insertion减少的代价（取负号）
    linehaulnum = length(demandL);
    stop = 0;
    cindex = 1;
    lineindex1 = find(path1 <= linehaulnum);
    backindex1 = find(path1 > linehaulnum);
    lineindex3 = find(path3 <= linehaulnum);
    backindex3 = find(path3 > linehaulnum);
    demand1L = sum(demandL(path1(lineindex1)));
    if isempty(backindex1) == 1  % 没有backhaul节点
        demand1B = 0;
    else
        demand1B = sum(demandB(path1(backindex1)-linehaulnum));
    end
    demand3L = sum(demandL(path3(lineindex3)));
    if isempty(backindex3) == 1  % 没有backhaul节点
        demand3B = 0;
    else
        demand3B = sum(demandB(path3(backindex3)-linehaulnum));
    end
    while stop == 0
        cpos = path2(cindex);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%% 有可能会出现单点路径
        
        if cindex == 1   
            npos = path2(cindex+1);  % cpos的下一个节点
            savecost = dist_repo(npos) - dist_repo(cpos) - dist_spot(cpos,npos);
        elseif cindex == length(path2)
            ppos = path2(cindex-1);  % cpos的前一个节点
            savecost = dist_repo(ppos) - dist_repo(cpos) - dist_spot(ppos, cpos);
        else
            ppos = path2(cindex-1);
            npos = path2(cindex+1);
            savecost = dist_spot(ppos, npos) - dist_spot(ppos, cpos) - dist_spot(cpos, npos);
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
                [insert_point1, M1] = caladdingcost(cpos, path1, linehaulnum, dist_spot, dist_repo);
            else
                M1 = inf;
            end
            if demandB(cpos-linehaulnum) + demand3B <= capacity
                [insert_point3, M3] = caladdingcost(cpos, path3, linehaulnum, dist_spot, dist_repo);
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

                
            