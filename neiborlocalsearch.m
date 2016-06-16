function [newpath, totalreducecost] = neiborlocalsearch(path, dist_spot, dist_repo, demandL, demandB, capacity, K)
% ��·���Ƿ��������ڵ�����¿���
    totalreducecost = 0;
    % step1:���ȶ�ÿ��·��ʹ��insertion
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
                path3 = path3(2:end-1);   % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{K} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % ���յ�path�����ֿ�ڵ�
            elseif i == K
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{1};
                path3 = path3(2:end-1);   % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{1} = newpath3;   % ���յ�path�����ֿ�ڵ�
            else
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);   % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % ���յ�path�����ֿ�ڵ�
            end
            totalreducecost = totalreducecost + reducecost;
        end
    end

    % step2: ��ÿ��·��ʹ��interchange
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
                path3 = path3(2:end-1);  % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{K} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;  % ���յ�path�����ֿ�ڵ�
            elseif i == K
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{1};
                path3 = path3(2:end-1);  % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{1} = newpath3;  % ���յ�path�����ֿ�ڵ�
            else 
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);  % path1, path2, path3�������ֿ�ڵ�
                [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;   % ���յ�path�����ֿ�ڵ�
            end
            totalreducecost = totalreducecost + reducecost;
        end
    end
    newpath = path;
end
    

%% insertion ��interchange����
function [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity)
    % ��path2�еĽڵ���path1/path3���н���
    % path1, path2, path3Ӧ���������ֿ�
    % ���ڰ����Ƿִصľֲ������㷨
    reducecost = 0;  % ͨ��insertion���ٵĴ��ۣ�ȡ���ţ�
    % �ڽ���interchange��ʱ�������������Լ��
    for i = 1:length(path2)
        if length(path1) == 0  % path1û��·������������
            M1 = inf;
        else
            [M1, changep1] = caladdcost(i, path2, path1, dist_spot, dist_repo, capacity, demandL, demandB);
        end
        if length(path3) == 0
            M3 = inf;
        else
            [M3, changep3] = caladdcost(i, path2, path3, dist_spot, dist_repo, capacity, demandL, demandB);
        end
        if M1 == inf && M3 == inf  % ���ɽ���
            continue;
        else
            if M1 <= M3
                if M1 >=0  % û�иĽ�
                    continue;
                else   % ����ִ����ν���
                    temp = path1(changep1);
                    path1(changep1) = path2(i);
                    path2(i) = temp;
                    reducecost = reducecost + M1;
                end
            else
                if M3 >= 0 % û�иĽ�
                    continue;
                else   % ����ִ����ν���
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
    % ����path2�е�nodeindex���ڵ���path��ĳ���ڵ�Ľ�������
    % ������ʱ�涨linehaulֻ�ܺ�linehaul������backhaulֻ�ܺ�backhaul����
    % ������Ҫ��������Լ��
    linehaulnum = length(demandL);
    cpos2 = path2(nodeindex);        
    M = inf;   % �������·�����Ȳ�
    interchange_point = -1;
    linebound = find(path > linehaulnum); % linehaul��backhaul�ķֽ���(lineһ��)
    if isempty(linebound) == 1  % path��û��backhaul�ڵ�
        linebound = length(path);
    else
        linebound = linebound(1)-1;
    end
    lineindex = find(path <= linehaulnum);  % path��linehaul�ڵ���
    lineindex2 = find(path2 <= linehaulnum);  % path2��linehaul�ڵ���
    if cpos2 <= linehaulnum   % cpos2��ǰ��ڵ�
        demand1L = sum(demandL(path(lineindex)));  % path��linehaul�ܸ���
        demand2L = sum(demandL(path2(lineindex2)));  % path2��linehaul�ܸ���
        for i = 1:linebound
            cpos = path(i);   % cpos��path�еĵ�i���ڵ㣬��cpos2����
            diff = demandL(cpos2) - demandL(cpos); % ������˫�������ĸ�����ֵ��
            if demand1L + diff > capacity || demand2L - diff > capacity  %  ������������һ�����������򲻿ɽ���
                continue;
            else
                if i == 1 && length(path) == 1
                    if nodeindex == 1 && length(path2) == 1   % ����·����ֻ��һ���ڵ�
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
                    if i == 1  % �Ӳֿ�����ĵ�һ���ڵ�
                        if nodeindex == 1 && length(path2) == 1  % Ψһ�ڵ�
                            npos = path(i+1);   % path��ǰѡ�нڵ����һ���ڵ�
                            temp = -dist_repo(cpos2) + dist_repo(cpos) - dist_spot(cpos,npos) + dist_spot(cpos2,npos);
                            if temp < M
                                M = temp;
                                interchange_point = i;  % path�е�interchange�ڵ�
                            end
                        else
                            if nodeindex == 1  % cpos2�ǴӲֿ�����ĵ�һ���ڵ�
                                npos2 = path2(nodeindex+1);   % path2��ǰѡ�нڵ����һ���ڵ�
                                npos = path(i+1);   % path��ǰѡ�нڵ����һ���ڵ�
                                temp = - dist_spot(cpos2, npos2) + dist_spot(cpos,npos2) - dist_spot(cpos, npos) + dist_spot(cpos2, npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;  % path�е�interchange�ڵ�
                                end
                            elseif nodeindex == length(path2)  % path2·�������һ���ڵ㣨�޺���ڵ㣩
                                ppos2 = path2(nodeindex-1);  % path2��ǰѡ�нڵ��ǰһ���ڵ�
                                npos = path(i+1);  % path��ǰѡ�нڵ����һ���ڵ�
                                temp = -dist_spot(ppos2, cpos2)+dist_spot(ppos2, cpos)-dist_spot(cpos, npos)+dist_spot(cpos2, npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else   % cpos2������·���м�Ľڵ�
                                npos = path(i+1);   % path��ǰ�ڵ����һ���ڵ�
                                ppos2 = path2(nodeindex-1);  % path2��ǰ�ڵ��ǰһ���ڵ�
                                npos2 = path2(nodeindex+1);  % path2��ǰ�ڵ��ǰһ���ڵ�
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
                    elseif i == length(path)  %  path·�������һ���ڵ㣨�޺���ڵ㣩
                        cpos = path(i);
                        if nodeindex == 1 && length(path2) == 1  % Ψһ�ڵ�
                            ppos = path(i-1);    % path��ǰ�ڵ��ǰһ��
                            temp = -dist_repo(cpos2) + dist_repo(cpos) - dist_spot(ppos,cpos) + dist_spot(ppos, cpos2);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        else    
                            if nodeindex == 1   % cpos2�ǴӲֿ�����ĵ�һ���ڵ�
                                npos2 = path2(nodeindex+1);   % path2��ǰ�ڵ��ǰһ���ڵ�
                                ppos = path(i-1);    % path��ǰ�ڵ��ǰһ��
                                temp = - dist_spot(cpos2,npos2) + dist_spot(cpos, npos2) - dist_spot(cpos, ppos) + dist_spot(ppos, cpos2);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            elseif nodeindex == length(path2)  % path2·�������һ���ڵ㣨�޺���ڵ㣩
                                ppos2 = path2(nodeindex-1);  % path2��ǰ�ڵ��ǰһ���ڵ�
                                ppos = path(i-1);     % path��ǰ�ڵ��ǰһ���ڵ�
                                temp = -dist_spot(ppos,cpos)+dist_spot(ppos, cpos2)-dist_spot(ppos2, cpos2)+dist_spot(ppos2,cpos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else    % cpos2������·���м�Ľڵ�
                                ppos = path(i-1);   % path·����ǰ�ڵ��ǰһ���ڵ�
                                ppos2 = path2(nodeindex-1);  % path2·����ǰ�ڵ��ǰһ���ڵ�
                                npos2 = path2(nodeindex+1);  % path2·����ǰ�ڵ����һ���ڵ�
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
                   else   % i��path·���м��һ���ڵ�
                        ppos = path(i-1);  % ppos��path·����ǰ�ڵ��ǰһ���ڵ�
                        npos = path(i+1);  % npos��path·����ǰ�ڵ����һ���ڵ�
                        if nodeindex == 1 && length(path2) == 1   % Ψһ�ڵ�
                            temp = -dist_repo(cpos2)+dist_repo(cpos)...
                                -dist_spot(ppos, cpos)-dist_spot(cpos, npos)...
                                +dist_spot(ppos, cpos2)+dist_spot(cpos2, npos);
                            if temp < M
                                M = temp;
                                interchange_point = i;
                            end
                        else
                            if nodeindex == 1    % cpos2�ǴӲֿ�����ĵ�һ���ڵ�
                                npos2 = path2(nodeindex+1);
                                temp = -dist_repo(cpos2)-dist_spot(cpos2, npos2)...
                                    +dist_spot(cpos, npos2)+dist_repo(cpos)...
                                    -dist_spot(ppos, cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            elseif nodeindex == length(path2)   % cpos2��·�������һ���ڵ㣬���Ӳֿ�
                                ppos2 = path2(nodeindex-1);  % ppos2��path2·����ǰ�ڵ��ǰһ���ڵ�
                                temp = -dist_repo(cpos2)-dist_spot(ppos2,cpos2)...
                                    +dist_spot(ppos2, cpos)+dist_repo(cpos)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else    % cpos2������·���м�Ľڵ�
                                ppos2 = path2(nodeindex-1);  % ppos2��path2·����ǰ�ڵ��ǰһ���ڵ�
                                npos2 = path2(nodeindex+1);  % npos2��path2·����ǰ�ڵ����һ���ڵ�
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
        
        
    else   % cpos2��backhaul�ڵ�
        if linebound == length(path)  % path��û�к���ڵ�
            M = inf;
            interchange_point = -1;  % û�пɲ����
        else
            backindex = find(path > linehaulnum);  % path��backhaul�ڵ���
            backindex2 = find(path2 > linehaulnum);  % path2��backhaul�ڵ���
            if isempty(backindex) == 1 % path��û��backhaul��û�ý���
                M = inf;
                interchange_point = -1;
            else
                demand1B = sum(demandB(path(backindex)-linehaulnum));            
                demand2B = sum(demandB(path2(backindex2)-linehaulnum));
                for i =linebound+1:length(path)
                    cpos = path(i);
                    diff = demandB(cpos2-linehaulnum) - demandB(cpos-linehaulnum); % ������˫�������ĸ�����ֵ��
                    if demand1B + diff > capacity || demand2B - diff > capacity
                        continue;
                    else
                        if i == length(path)   % i��path�е����һ���ڵ�
                            if nodeindex == length(path2)  % cpos2��path2·�������һ���ڵ㣨�޺���ڵ㣩
                                ppos2 = path2(nodeindex-1);  % ppos2��path2��ǰ�ڵ��ǰһ���ڵ�
                                ppos = path(i-1);   % ppos��path��ǰ�ڵ��ǰһ���ڵ�
                                temp = -dist_spot(ppos,cpos)+dist_spot(ppos, cpos2)-dist_spot(ppos2, cpos2)+dist_spot(ppos2,cpos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else   % cpos2������·���м�Ľڵ�
                                ppos = path(i-1);   % ppos��path��ǰ�ڵ��ǰһ���ڵ�
                                ppos2 = path2(nodeindex-1);  % ppos2��path2��ǰ�ڵ��ǰһ���ڵ�
                                npos2 = path2(nodeindex+1);  % npos2��path2��ǰ�ڵ����һ���ڵ�
                                temp = -dist_spot(ppos2, cpos2)-dist_spot(cpos2, npos2)...
                                    +dist_spot(ppos2, cpos)+dist_spot(cpos,npos2)...
                                    -dist_spot(ppos, cpos)-dist_repo(cpos)...
                                    +dist_spot(ppos, cpos2)+dist_repo(cpos2);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            end
                        else  % i��path������·���м�ڵ�
                            ppos = path(i-1);  % ppos��path��ǰ�ڵ��ǰһ���ڵ�
                            npos = path(i+1);  % npos��path��ǰ�ڵ����һ���ڵ�
                            if nodeindex == length(path2)  
                                ppos2 = path2(nodeindex-1); % ppos2��path2��ǰ�ڵ��ǰһ���ڵ�
                                temp = -dist_repo(cpos2)-dist_spot(ppos2,cpos2)...
                                    +dist_spot(ppos2, cpos)+dist_repo(cpos)...
                                    -dist_spot(ppos,cpos)-dist_spot(cpos,npos)...
                                    +dist_spot(ppos, cpos2)+dist_spot(cpos2,npos);
                                if temp < M
                                    M = temp;
                                    interchange_point = i;
                                end
                            else  % cpos2������·���м�Ľڵ�
                                ppos2 = path2(nodeindex-1);  % ppos2��path2��ǰ�ڵ��ǰһ���ڵ�
                                npos2 = path2(nodeindex+1); % npos2��path2��ǰ�ڵ����һ���ڵ�
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
    % ���ڰ����Ƿִص�·���ľֲ������㷨
    % ��path2�Ľڵ����path1/path3
    % path1, path2, path3Ӧ���������ֿ�
    reducecost = 0;  % ͨ��insertion���ٵĴ��ۣ�ȡ���ţ�
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
        if isempty(backindex1) == 1  % û��backhaul�ڵ�
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
        if isempty(backindex3) == 1  % û��backhaul�ڵ�
            demand3B = 0;
        else
            demand3B = sum(demandB(path3(backindex3)-linehaulnum));
        end
    end
    
    while stop == 0
        cpos = path2(cindex);
        if cindex == 1 
            if cindex == length(path2)  % �Ǵ�·���е�Ψһ�ڵ� 
                savecost = -2*dist_repo(cpos);
            elseif path2(2) > linehaulnum % ֻʣ��Ψһ��linehual�ڵ���
                savecost = 0;
                cindex = cindex + 1;
                continue;
            else
                npos = path2(cindex+1); % cpos����һ���ڵ�
                savecost = dist_repo(npos) - dist_repo(cpos) - dist_spot(cpos,npos);
            end
        else  % ���Ǵ�·���е�Ψһ�ڵ� 
            if cindex == length(path2) 
                ppos = path2(cindex-1);  % cpos��ǰһ���ڵ�
                savecost = dist_repo(ppos) - dist_repo(cpos) - dist_spot(ppos, cpos);
            else
                ppos = path2(cindex-1);
                npos = path2(cindex+1);
                savecost = dist_spot(ppos, npos) - dist_spot(ppos, cpos) - dist_spot(cpos, npos);
            end
        end
        
        % �����cpos���뵽path1��path3����С����
        % ���ж��Ƿ���������Լ��
        if cpos <= linehaulnum % cpos��ǰ��ڵ�
            if demandL(cpos) + demand1L <= capacity
                [insert_point1, M1] = caladdingcost(cpos, path1, linehaulnum, dist_spot, dist_repo);
            else
                M1 = inf;   % �������㣬����ʧ��
            end
            if demandL(cpos) + demand3L <= capacity                
                [insert_point3, M3] = caladdingcost(cpos, path3, linehaulnum, dist_spot, dist_repo);
            else
                M3 = inf;  % �������㣬����ʧ��
            end
        else  % cpos�Ǻ���ڵ�
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
                if cpos > linehaulnum && length(path3) == 0  % ������ֱ�Ӱ�backhaul���뵽��·����
                    M3 = inf;
                else
                    [insert_point3, M3] = caladdingcost(cpos, path3, linehaulnum, dist_spot, dist_repo);
                end
            else 
                M3 = inf;
            end
        end
        
        % �Ҳ��������С��·��������ĵط�����
        if M3 == inf && M1 == inf   % ��������߶�����ʧ�ܣ���cpos���䣬��������һ����
            cindex = cindex + 1;
        else
            if M1 <= M3
                if savecost + M1 < 0  % ȷʵ��ʡ��·������
                    reducecost = reducecost + savecost + M1;
                    newpath1 = zeros(1,length(path1)+1);
                    if insert_point1 == 0  % �������path�Ŀ�ͷ
                        newpath1(1) = cpos;
                        newpath1(2:end) = path1;
                    elseif insert_point1 == length(path1)  % ���뵽·�����
                        newpath1(1:end-1) = path1;
                        newpath1(end) = cpos;
                    else
                        newpath1(1:insert_point1) = path1(1:insert_point1);
                        newpath1(insert_point1+1) = cpos;
                        newpath1(insert_point1+2:end) = path1(insert_point1+1:end);
                    end
                    path1 = newpath1;
                    path2(cindex) = [];  % ��path2��ȥ��cpos
                else  % cpos���ʺ���insertion����ôѡ��path2�е���һ���ڵ�
                    cindex = cindex + 1;
                end
            else
                if savecost + M3 < 0  % ȷʵ��ʡ��·������
                    reducecost = reducecost + savecost + M3;
                    newpath3 = zeros(1,length(path3)+1);
                    if insert_point3 == 0  % �������path�Ŀ�ͷ
                        newpath3(1) = cpos;
                        newpath3(2:end) = path3;
                    elseif insert_point3 == length(path3)  % ���뵽·�����
                        newpath3(1:end-1) = path3;
                        newpath3(end) = cpos;
                    else
                        newpath3(1:insert_point3) = path3(1:insert_point3);
                        newpath3(insert_point3+1) = cpos;
                        newpath3(insert_point3+2:end) = path3(insert_point3+1:end);
                    end
                    path3 = newpath3;
                    path2(cindex) = [];  % ��path2��ȥ��cpos
                else
                    cindex = cindex + 1;
                end
            end
        end
        if cindex > length(path2)  % �Ѿ���������еļ�����ֹͣwhile-loop
            stop = 1;
        end
    end
    newpath1 = path1;
    newpath2 = path2;
    newpath3 = path3;
end

function [insert_point, M] = caladdingcost(cpos, path, linehaulnum, dist_spot, dist_repo)
    % �����cpos���뵽path�е���С���Ӵ���
    if length(path) == 0   % path�ǿյ�
        insert_point = 0;
        M = dist_repo(cpos)*2;
    else
        linehaulbound = find(path > linehaulnum);
        if isempty(linehaulbound) == 1  % ���linehaulboundΪ��
            linehaulbound = length(path);
        else
            linehaulbound = linehaulbound(1)-1;     % path��ǰ��ڵ�ֽ���
        end
        M = inf;   % ���뵽path����С���Ӵ���
        insert_point = 0;
        if cpos <= linehaulnum  % cpos��ǰ��ڵ�
            for j = 1:linehaulbound+1  % һ������ô������в����
                if j == 1
                    npos = path(j);   % �����󷽽ڵ㣬ǰ���ǲֿ�
                    temp = dist_repo(cpos) + dist_spot(cpos, npos) - dist_repo(npos);
                    if temp < M
                        M = temp;
                        insert_point = 0;  % ���뵽�ֿ����
                    end
                elseif j > length(path)  % û��backhaul�ڵ�
                    ppos = path(end);   % �����ǰ���ڵ㣬���ǲֿ�
                    temp = dist_repo(cpos) + dist_spot(cpos, ppos) - dist_repo(ppos);
                    if temp < M
                        M = temp;
                        insert_point = length(path);  % ���뵽path1��ĩ�ڵ����
                    end
                else
                    ppos = path(j-1);  % �����ǰ���ڵ�
                    npos = path(j);    % �����󷽽ڵ�
                    temp = dist_spot(ppos,cpos)+dist_spot(cpos,npos)-dist_spot(ppos,npos);
                    if temp < M
                        M = temp;
                        insert_point = j-1;  % �����ǰ���ڵ�
                    end
                end
            end
        else   % ������Ǻ󷽽ڵ�
            for j = linehaulbound : length(path)
                if j == length(path)   % �����󷽽ڵ��ǲֿ�
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
                        insert_point = j;  % �����ǰ���ڵ�
                    end
                end           
            end
        end
    end
end

                
                            
    
    
            
