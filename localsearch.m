function [route, reducecost, routedemandL, routedemandB] = localsearch(dist_repo, dist_spot, demandL, demandB, capacity, route)
    % ����ŷʽ����ִصľֲ������㷨
    % ��route�е�·�����нڵ��Ľ���/·����Ľ���
    M = size(dist_spot,1);
    D = zeros(M+1, M+1);
    D(1,2:end) = dist_repo;  % ���Ϊ1�ı�ʾ�ֿ�
    D(2:end,1) = dist_repo;
    D(1,1) = inf;
    D(2:M+1,2:M+1) = dist_spot; % �˿ͽڵ��2��ʼ

    linehaulnum = length(demandL);

    K = length(route);

    routedemandL = zeros(1,K);   % ��·����Linehaul�ڵ㸺��
    routedemandB = zeros(1,K);   % ��·����backhaul�ڵ㸺��
    reducecost = 0;

    for i = 1:K
        r = route{i};
        routelen = length(r);
        temp1 = 0;
        temp2 = 0;
        if routelen > 2   % ��·�����ȴ���2ʱ����2�����ǲֿ�ڵ㣩��������
            for j = 2:routelen-1
                cpos = r(j);
                if cpos <= linehaulnum
                    temp1 = temp1 + demandL(cpos);
                else
                    temp2 = temp2 + demandB(cpos-linehaulnum);
                end
            end
        end
        routedemandL(i) = temp1;
        routedemandB(i) = temp2;
    end

    maxsc = -1;
    alpha = 100000;  % �ͷ����ӣ��ͷ�����
    while abs(maxsc) > 10^(-6)
        maxsc = inf;
        for i = 1:K
            croute = route{i};  % ·������β���ǲֿ�ڵ㣬ע��ֿ�ڵ���Ϊ0
            remainindex = setdiff(1:K,i);  % ������·��
            len = length(croute); % ·�����ȣ�������β�Ĳֿ�ڵ�
            ordemandL = routedemandL(i);
            ordemandB = routedemandB(i);
            restdemandL = sum(ordemandL);   % Ϊ��·��������׼��
            restdemandB = sum(ordemandB);
            for j = 2:len-1   % �������еĹ˿ͽڵ�
                ppos = croute(j-1);  % ǰ�ڵ�
                cpos = croute(j);    % ��ǰ�ڵ�
                npos = croute(j+1);  % ��̽ڵ�
                if cpos <= linehaulnum  % cpos��linehaul�ڵ�
                    cdemand = demandL(cpos);  % ��ǰҪ�����Ĺ˿ͽڵ�Ĵ���
                    restdemandL = restdemandL - cdemand;
                else
                    cdemand = demandB(cpos-linehaulnum);
                    restdemandB = restdemandB - cdemand;
                end
                for k = 1:length(remainindex)
                    frroute = route{remainindex(k)};  % Ҫ���н���������·��
                    frlen = length(frroute);
                    frdemandL = routedemandL(remainindex(k));   % Ҫ���н�������·����linehaul����
                    frdemandB = routedemandB(remainindex(k));   % Ҫ���н�������·����backhaul����
                    frrestdemandL = sum(frdemandL);
                    frrestdemandB = sum(frdemandB);
                    for m = 2:frlen - 1
                        frppos = frroute(m-1);        % ǰ�ڵ�
                        frcpos = frroute(m);          % ��ǰ�ڵ�
                        frnpos = frroute(m+1);        % ��̽ڵ�
%                         save('hehe','frroute');
% %                         frroute
                        if frcpos <= linehaulnum  % frcpos��linehaul�ڵ�
                            frcdemand = demandL(frcpos);
                            frrestdemandL = frrestdemandL - frcdemand;
                        else
                            frcdemand = demandB(frcpos-linehaulnum);
                            frrestdemandB = frrestdemandB - frcdemand;
                        end
                        if cpos <= linehaulnum && npos <= linehaulnum  % Ҫ���ߵı���linehaul��
                            if frcpos <= linehaulnum  % Ҫ����뵽linehaul�߻��߽ӿڱ�
                                penalty1 = max(frdemandL + cdemand - capacity, 0) * alpha;  % ���سͷ�
                                csc1 = -D(ppos+1,cpos+1) - D(cpos+1,npos+1) + D(ppos+1,npos+1) + ...
                                      D(frcpos+1, cpos+1) + D(cpos+1,frnpos+1) - D(frcpos+1,frnpos+1) + penalty1;
                                if csc1 < maxsc
                                    best.operation = 1;  % insert;
                                    best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                    best.pos = [cpos, frcpos];  % ���н����ľ���λ�ã���һ���Ǳ�����
                                    best.demand = [ordemandL-cdemand, ordemandB, frdemandL+cdemand, frdemandB];  % �������·������
                                    maxsc = csc1;
                                end
                                penalty2 = (max(ordemandL - restdemandL + frrestdemandL - capacity, 0) + ...
                                           max(ordemandB - restdemandB + frrestdemandB - capacity, 0) + ...
                                           max(frdemandL - frrestdemandL + restdemandL - capacity, 0) + ...
                                           max(frdemandB - frrestdemandB + restdemandB - capacity, 0)) * alpha;
                                csc2 = -D(cpos+1, npos+1) - D(frcpos+1, frnpos+1) + ...
                                       +D(cpos+1, frnpos+1) + D(frcpos+1, npos+1)+penalty2;
                                if csc2 < maxsc
                                    best.operation = 2;  % interchange
                                    best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                    best.pos = [cpos, frcpos];      % ���н����ľ���λ�ã���һ���Ǳ�����
                                    best.demand = [ordemandL - restdemandL + frrestdemandL,ordemandB - restdemandB + frrestdemandB ...
                                                   frdemandL - frrestdemandL + restdemandL, frdemandB - frrestdemandB + restdemandB];
                                    maxsc = csc2; 
                                end
                            end
                        elseif cpos > linehaulnum % Ҫ���ߵı���backhaul��
                            if frcpos <= linehaulnum && frnpos <= linehaulnum  % Ҫ�����ԭ���ӱ���linehaul�ߣ�������
                                continue;
                            else
                                penalty1 = max(frdemandB + cdemand - capacity, 0) * alpha;  % ���سͷ�
                                csc1 = -D(ppos+1,cpos+1) - D(cpos+1,npos+1) + D(ppos+1,npos+1) + ...
                                      D(frcpos+1, cpos+1) + D(cpos+1,frnpos+1) - D(frcpos+1,frnpos+1) + penalty1;
                                if csc1 < maxsc
                                    best.operation = 1;  % insert;
                                    best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                    best.pos = [cpos, frcpos];  % ���н����ľ���λ�ã���һ���Ǳ�����
                                    best.demand = [ordemandL, ordemandB-cdemand, frdemandL, frdemandB+cdemand];  % �������·������
                                    maxsc = csc1;
                                end
                                penalty2 = (max(ordemandL - restdemandL + frrestdemandL - capacity, 0) + ...
                                           max(ordemandB - restdemandB + frrestdemandB - capacity, 0) + ...
                                           max(frdemandL - frrestdemandL + restdemandL - capacity, 0) + ...
                                           max(frdemandB - frrestdemandB + restdemandB - capacity, 0)) * alpha;
                                csc2 = -D(cpos+1, npos+1) - D(frcpos+1, frnpos+1) + ...
                                       +D(cpos+1, frnpos+1) + D(frcpos+1, npos+1)+penalty2;
                                if csc2 < maxsc
                                    best.operation = 2;  % interchange
                                    best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                    best.pos = [cpos, frcpos];      % ���н����ľ���λ�ã���һ���Ǳ�����
                                    best.demand = [ordemandL - restdemandL + frrestdemandL,ordemandB - restdemandB + frrestdemandB ...
                                                   frdemandL - frrestdemandL + restdemandL, frdemandB - frrestdemandB + restdemandB];
                                    maxsc = csc2; 
                                end
                            end
                        elseif  cpos <= linehaulnum && npos > linehaulnum % Ҫ���ߵı��ǽӿڱ�
                            if frcpos <= linehaulnum && j>2 
                                % Ҫ�����ԭ���ӱ�ֻ����linehaul�߻��߽ӿڱ�
                                % ��������·�������һ��linehaul�ڵ������
                                penalty1 = max(frdemandL + cdemand - capacity, 0) * alpha;  % ���سͷ�
                                csc1 = -D(ppos+1,cpos+1) - D(cpos+1,npos+1) + D(ppos+1,npos+1) + ...
                                        D(frcpos+1, cpos+1) + D(cpos+1,frnpos+1) - D(frcpos+1,frnpos+1) + penalty1;
                                if csc1 < maxsc
                                    best.operation = 1;  % insert;
                                    best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                    best.pos = [cpos, frcpos];  % ���н����ľ���λ�ã���һ���Ǳ�����
                                    best.demand = [ordemandL-cdemand, ordemandB, frdemandL+cdemand, frdemandB];  % �������·������
                                    maxsc = csc1;
                                end
                            end
                            penalty2 = (max(ordemandL - restdemandL + frrestdemandL - capacity, 0) + ...
                            max(ordemandB - restdemandB + frrestdemandB - capacity, 0) + ...
                            max(frdemandL - frrestdemandL + restdemandL - capacity, 0) + ...
                            max(frdemandB - frrestdemandB + restdemandB - capacity, 0)) * alpha;
                            csc2 = -D(cpos+1, npos+1) - D(frcpos+1, frnpos+1) + ...
                                   +D(cpos+1, frnpos+1) + D(frcpos+1, npos+1)+penalty2;
                            if csc2 < maxsc
                                best.operation = 2;  % interchange
                                best.interchangeroute = [i,remainindex(k)];  % ���н���������·��
                                best.pos = [cpos, frcpos];      % ���н����ľ���λ�ã���һ���Ǳ�����
                                best.demand = [ordemandL - restdemandL + frrestdemandL,ordemandB - restdemandB + frrestdemandB ...
                                               frdemandL - frrestdemandL + restdemandL, frdemandB - frrestdemandB + restdemandB];
                                maxsc = csc2; 
                            end
                        end
                    end
                end
            end
        end

        if maxsc < 0
            reducecost = reducecost + maxsc;
            r1 = route{best.interchangeroute(1)};
            r2 = route{best.interchangeroute(2)};
            pos1 = best.pos(1);
            pos2 = best.pos(2);
            index1 = find(r1 == pos1);
            index2 = find(r2 == pos2);  % ����������λ��
            if best.operation == 1  % insertion
                newroute1 = r1;
                newroute1(index1) = [];
                newroute2 = zeros(1,length(r2)+1);
                newroute2(1:index2) = r2(1:index2);
                newroute2(index2+1) = pos1;
                newroute2(index2+2:end) = r2(index2+1:end);
            elseif best.operation == 2 % interchange
                newroute1 = [];
                newroute2 = [];
                newroute1 = [newroute1 r1(1:index1)];
                newroute1 = [newroute1 r2(index2+1:end)];
                newroute2 = [newroute2 r2(1:index2)];
                newroute2 = [newroute2 r1(index1+1:end)];     
            end
            route{best.interchangeroute(1)} = newroute1;
            route{best.interchangeroute(2)} = newroute2;
            routedemandL(best.interchangeroute(1)) = best.demand(1);
            routedemandB(best.interchangeroute(1)) = best.demand(2);
            routedemandL(best.interchangeroute(2)) = best.demand(3);
            routedemandB(best.interchangeroute(2)) = best.demand(4);
        end        
    end
end
                        
                        
                        
                               
                            
                        
            