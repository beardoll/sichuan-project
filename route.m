function [cost] = route(N, n, dist_spot, dist_repo)
    U = 1:n;   % δ��ӵ�·���еĽڵ�
    delta = dist_repo;  % ������ȫͼ���ҶԳ�
    route = [0];
    cost = 0;
    while isempty(U) == 0
        i = find(delta == max(delta));   % �ҳ�delta���ĵ�
        delta(i) = -1;   % δ��������ѡ�����   
        M = inf;
        if length(route) == 1   % �ոմӲֿ����
            route = [route i];
            M = dist_repo(i)*2;
        else   % Ѱ�������˲����
            bound = find(route > n);
            if i>n  % ���i��backhaul�ڵ�
                if isempty(bound) == 0   % ·������backhaul�ڵ�
                    bound = bound(1) - 1;   % ���һ��linehaul�ڵ�(����±�����)
                    for k = bound :length(route)
                        if k == length(route)  % ����·�������
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
                else  % ���·����û�к���ڵ㣬�����ǵ�һ������ڵ㣬��ôֱ�Ӳ��뵽���
                    insert_point = route(end);   % ����㣨ǰ��
                end
            else   % ���i��linehaul�ڵ�
                if isempty(bound)==0  % ���·������backhaul�ڵ�
                    bound = bound(1) - 1; % ���һ��linehaul�ڵ㣨����±�������
                else
                    bound = length(route);   % ·����û��backhaul�ڵ�
                end
                for k = 1:bound
                    if cpos == 0  % �����ǰ������ǰ�ڵ��ǲֿ�
                        cpos = route(k);   
                        npos = route(k+1);
                        diff = dist_repo(i) + dist_spot(i, npos) - dist_repo(npos);
                        if diff < M
                            M = diff;
                            insert_point = k;   % ����㣨ǰ��
                        end
                    else  % �����ǰ������ǰ�ڵ㲻�ǲֿ�
                        if k == length(route)   % ���k��·�������λ��
                            cpos = route(k);
                            diff = dist_repo(i) + dist_spot(cpos, i) - dist_repo(cpos);
                            if diff < M
                                M = diff;
                                insert_point = k;
                            end
                        else  % ���k����·���е����λ��
                            cpos = route(k);   
                            npos = route(k+1);
                            diff = dist_spot(cpos, i)+dist_spot(i, npos) - dist_spot(cpos, npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % ����㣨ǰ��
                            end
                        end
                    end
                end
            end
            cost = cost + M;
            % ����route��U
            U = setdiff(U, i);
            newroute = zeros(length(route)+1, 1);
            if insert_point == length(route)   % ���뵽·�����
                newroute(1:length(route)) = route;
                newroute(end) = i;
            else
                newroute(1:insert_point) = route(1:insert_point);
                newroute(insert_point+1) = i;
                newroute(insert_point+1:end) = route(insert_point:end);
            end
            route = newroute;
            % ����delta
            for j = 1:length(U)
                if dist_spot(i,j) < delta(j)
                    delta(j) = dist_spot(i,j);
                end
            end
        end
    end
    % �������ص��ֿ�Ļ�·
    endspot = route(end);
    cost = cost + dist_repo(endspot);
end
    