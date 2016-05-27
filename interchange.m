function [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB)
    % ��path2�еĽڵ���path1/path3���н���
    % path1, path2, path3Ӧ���������ֿ�
    reducecost = 0;  % ͨ��insertion���ٵĴ��ۣ�ȡ���ţ�
    % �ڽ���interchange��ʱ�������������Լ��
    for i = 1:length(path2)
        [M1, changep1] = caladdcost(i, path2, path1, dist_spot, dist_repo, capacity, demandL, demandB);
        [M3, changep3] = caladdcost(i, path2, path3, dist_spot, dist_repo, capacity, demandL, demandB);
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
                if i == 1  % �Ӳֿ�����ĵ�һ���ڵ�
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
                elseif i == length(path)  %  path·�������һ���ڵ㣨�޺���ڵ㣩
                    cpos = path(i);
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
                else   % i��path·���м��һ���ڵ�
                    ppos = path(i-1);  % ppos��path·����ǰ�ڵ��ǰһ���ڵ�
                    npos = path(i+1);  % npos��path·����ǰ�ڵ����һ���ڵ�
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
                    elseif nodeindex == length(path)   % cpos2��·�������һ���ڵ㣬���Ӳֿ�
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
        
        
    else   % cpos2��backhaul�ڵ�
        if linebound == length(path)  % path��û�к���ڵ�
            M = inf;
            interchange_point = -1;  % û�пɲ����
        else
            backindex = find(path > linehaulnum);  % path��backhaul�ڵ���
            backindex2 = find(path2 > linehaulnum);  % path2��backhaul�ڵ���
            demand1B = sum(demandB(path(backindex)-linehaulnum));            
            demand2B = sum(demandB(path2(backindex2)-linehaulnum));
            for i =linebound+1:length(path)
                cpos = path(i);
                diff = demandB(cpos2-linehaulnum) - demandL(cpos-linehaulnum); % ������˫�������ĸ�����ֵ��
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
                        if nodeindex == length(path)  
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
    reducecost = M;
end
                    
                
    
    
            