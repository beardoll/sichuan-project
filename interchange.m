function [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB)
    % 把path2中的节点与path1/path3进行交换
    % path1, path2, path3应当不包括仓库
    reducecost = 0;  % 通过insertion减少的代价（取负号）
    % 在进行interchange的时候必须满足容量约束
    for i = 1:length(path2)
        [M1, changep1] = caladdcost(i, path2, path1, dist_spot, dist_repo, capacity, demandL, demandB);
        [M3, changep3] = caladdcost(i, path2, path3, dist_spot, dist_repo, capacity, demandL, demandB);
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
                if i == 1  % 从仓库出来的第一个节点
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
                elseif i == length(path)  %  path路径中最后一个节点（无后向节点）
                    cpos = path(i);
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
                else   % i是path路径中间的一个节点
                    ppos = path(i-1);  % ppos是path路径当前节点的前一个节点
                    npos = path(i+1);  % npos是path路径当前节点的下一个节点
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
                    elseif nodeindex == length(path)   % cpos2是路径的最后一个节点，连接仓库
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
        
        
    else   % cpos2是backhaul节点
        if linebound == length(path)  % path中没有后向节点
            M = inf;
            interchange_point = -1;  % 没有可插入点
        else
            backindex = find(path > linehaulnum);  % path中backhaul节点标号
            backindex2 = find(path2 > linehaulnum);  % path2中backhaul节点标号
            demand1B = sum(demandB(path(backindex)-linehaulnum));            
            demand2B = sum(demandB(path2(backindex2)-linehaulnum));
            for i =linebound+1:length(path)
                cpos = path(i);
                diff = demandB(cpos2-linehaulnum) - demandL(cpos-linehaulnum); % 交换给双方带来的负担差值，
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
                        if nodeindex == length(path)  
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
    reducecost = M;
end
                    
                
    
    
            