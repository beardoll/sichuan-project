function [best_path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
    
    %%%%%%%%%%%%%%%%%%%%%%%%% �����ô��� %%%%%%%%%%%%%%%%%%%%%%%%%%
%     best_path = 0;
%     node.pathcost = 5;
%     node.path = [0 3];
%     cost = get_lb(node, dist_spot, dist_repo, n,N);
%     path = 0;
%     [cost] = greedy_algorithm(N, n, dist_spot, dist_repo);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ��ʼ��
    pq = [];
    hn.num = 0;
    hn.pathcost = 0;
    hn.path = [0];
    [best_path1, best_c1] = route(N, n, dist_spot, dist_repo);  % ����̰���㷨����������Ͻ�
    [best_path2, best_c2] = greedy_algorithm(N, n, dist_spot, dist_repo);  % ����̰���㷨����������Ͻ�
    if best_c1 <= best_c2
        best_path = best_path1;
        best_c = best_c1;
    else
        best_path = best_path2;
        best_c = best_c2;
    end
    for i = 1:n
        node.pathcost = hn.pathcost + dist_repo(i);
        node.path = [hn.path, i];
        node.lb = get_lb(node, dist_spot, dist_repo, n, N);
        if node.lb < best_c
            node.num = i;
            pq = [pq, node];
        end
    end
    while isempty(pq) ~= 1  % ��pq��Ϊ��ʱ
        pq = rank(pq);
        hn = pq(1);
        pq(1) = [];
        if length(hn.path) - 1 < n   % ��ǰ����linehaul�ڵ���Ѱ��·��
            line_spot = 1:n;
            impose = setdiff(line_spot, hn.path); % û�߹���linehaul�ڵ�
            for i = 1:length(impose)
                node.path = [hn.path, impose(i)];
                node.pathcost = hn.pathcost + dist_spot(hn.num, impose(i));
                node.lb = get_lb(node, dist_spot, dist_repo, n, N);
                if node.lb < best_c
                    node.num = impose(i);
                    pq = [pq, node];
                end
            end
        elseif length(hn.path) - 1 == n && n == N || length(hn.path)-1 == N % û��backhaul�ڵ�
            cc = hn.pathcost + dist_repo(hn.num);
            if cc < best_c
                best_c = cc;
                best_path = [hn.path 0];
            end
        else  % ��û�����һ��
            back_spot = n+1:N;
            impose = setdiff(back_spot, hn.path);  % û�߹���backhaul�ڵ�
            for i = 1:length(impose)
                node.path = [hn.path, impose(i)];
                node.pathcost = hn.pathcost + dist_spot(hn.num, impose(i));
                node.lb = get_lb(node, dist_spot, dist_repo, n, N);
                if node.lb < best_c
                    node.num = impose(i);
                    pq = [pq, node];
                end
            end
        end
    end
    cost = best_c;
end

function [cost] = get_lb(node, dist_spot, dist_repo, n, N)
    % �ҵ�node�ڵ���½�
    % �ֳ�4�󲿷�
    % ��һ���������߹�·�����ȵ�2��
    % �ڶ����������߹�·���Ķ˵㵽δ�߹��ڵ����С�����
    %         Ҳ����˵���ٶ���n��linehaul�ڵ㣬��ôÿ��������������ȣ���2n����
    %         ��ô��С��������Ϊ(n-1)*2����̱�֮��
    % ����������δ�߹��ڵ��У�linehaul��backhaul�ڵ�ֱ����С��������
    % ���Ĳ�����linehaul��backhaul�ڵ����С��������(���û��backhaul�ڵ㣬����Ҫ)
    path = node.path;   % ���߹���·��
    pathlen = length(path);  % ·������
    cost = 0;
    cost = cost + node.pathcost*2;  % �������߹���·�����ȵ�2��
    

    pathend = path(end);  % ·�������һ���ڵ�
    if pathlen - 1 < n   % ʣ��ڵ��к���linehaul�ڵ�
        %%%%%%%%%%%%%%%%%%%%%% ���ȼ�����С��������  %%%%%%%%%%%%%%%%%%%%%%%%%%
        line_spot = 1:n;  % linehaul�ڵ���
        remain_linehaul = setdiff(line_spot, path);  % ʣ��ڵ��е�linehaul�ڵ�
        remain_linehaulnum = length(remain_linehaul);
        if remain_linehaulnum >= 3  
            % ʣ��linehaul�ڵ���ڵ���3��
            % ����ʣ��(remain_linehaulnum - 1)*2���ڵ����������
            costL = zeros(length(remain_linehaul), 2);  % linehaul�ڵ������Ӵ���
            for i = 1:remain_linehaulnum
                sort_cost = sort(dist_spot(remain_linehaul(i), remain_linehaul), 'ascend');
                costL(i,:) = sort_cost(1:2);   % ���·�����
            end
            temp = costL(:);
            temp = sort(temp, 'ascend');
            cost = cost + sum(temp(1:end-2));  % ����2*(n-1)�������ߵ���̾���

        elseif remain_linehaulnum == 2  
            % ʣ��linehaul�ڵ����2��       
            cost = cost + 2*dist_spot(remain_linehaul(1), remain_linehaul(2));            
        end
        if n == N   % û��backhaul�ڵ�
            mindist_start = min(dist_repo(remain_linehaul));
        else   % ��linehaul�ڵ�
            % ��linehaul��backhaul����С��������
            back_spot = n+1:N;  % backhaul�ڵ���
            mindist_tobackhaul = min(min(dist_spot(remain_linehaul, back_spot)));
            cost = cost + mindist_tobackhaul*2;
            % ����backhaul�ڵ����С��������
            costB = zeros(N-n,2);
            if  length(back_spot) == 2  % ʣ������backhaul�ڵ�
                cost = cost + dist_spot(back_spot(1), back_spot(2))*2;
            elseif length(back_spot) >= 3
                for i = 1:N-n
                    sort_cost = sort(dist_spot(back_spot(i),back_spot),'ascend');
                    costB(i,:) = sort_cost(1:2);
                end
                costB = sort(costB, 'ascend');
                temp = costB(:);
                temp = sort(temp, 'ascend');
                cost = cost + sum(temp(1:end-2));
            end
            %%%%%%%%%%%%%% Ȼ��������߹�·����δ�߹��˵����С�����  %%%%%%%%%%%%%%%%%
            mindist_start = min(dist_repo(back_spot));  % backhaul�ڵ����Ӳֿ����С����
        end
        if pathend == 0
            mindist_end = min(dist_repo(remain_linehaul));
        else
            mindist_end = min(dist_spot(pathend,remain_linehaul));  % ʣ��linehaul�ڵ����·�����ڵ����̾���
        end
        cost = cost + 2*mindist_start + 2*mindist_end;
        cost = cost / 2;
    elseif pathlen - 1 == n && n == N  || pathlen - 1 == N % ����·�������꣨û��backhaul�ڵ㣩
        cost = cost / 2;
    elseif pathlen - 1 < N       % ʣ��ڵ����Ѿ�û��linehaul�ڵ�
        %%%%%%%%%%%%%%%%%%%%%% ���ȼ�����С��������  %%%%%%%%%%%%%%%%%%%%%%%%%%
        back_spot = n+1:N;  % backhaul�ڵ���
        remain_backhaul = setdiff(back_spot, path);   % ʣ��ڵ��е�backhaul�ڵ�
        remain_backhaulnum = length(remain_backhaul);
        if remain_backhaulnum >= 3
            % ʣ��backhaul�ڵ��������ڵ���3
            costB = zeros(remain_backhaulnum, 2);
            for i = 1:remain_backhaulnum
                sort_cost = sort(dist_spot(back_spot(i),back_spot),'ascend');
                costB(i,:) = sort_cost(1:2);
            end
            temp = costB(:);
            temp = sort(temp);
            cost = cost + sum(temp(1:end-2));  % ����(n-1)*2���ߵ���С��������
        elseif remain_backhaulnum == 2
            % ʣ��backhaul�ڵ���������2
            cost = cost + 2*dist_spot(remain_backhaul(1), remain_backhaul(2));
        end
        %%%%%%%%%%%%%% Ȼ��������߹�·����δ�߹��˵����С�����  %%%%%%%%%%%%%%%%%
        mindist_end = min(dist_spot(remain_backhaul, pathend));  % ��·��ĩ�˵����̾���
        mindist_start = min(dist_repo(remain_backhaul));
        cost = cost + 2*mindist_end + 2*mindist_start;
        cost = cost / 2;
    end    
end

function [order_pq] = rank(pq)
    % �����½�Ե�ǰ��pq���н�������
    pq_len = length(pq);
    cost_vec = zeros(1,pq_len);
    for i = 1:pq_len
        cost_vec(i) = pq(i).lb;  % �õ�ÿ���ڵ���½�
    end
    [sort_vec, sort_num] = sort(cost_vec);  % �����з��ý�������
    order_pq = pq(sort_num);
end

function [cpath, cost] = greedy_algorithm(N, n, dist_spot, dist_repo)
% ����̰���㷨��ó�ʼ�Ͻ�
    csp = 0;
    cost = 0;
    nsp = find(dist_repo(1:n) == min(dist_repo(1:n))); % �ҵ������linehaul�ڵ�
    nsp = nsp(1);
    path = [nsp];         % ���߹���·���������������ص�
    cost = cost + dist_repo(nsp);
    csp = nsp;
    for i = 1:n-1        
        temp = dist_spot(csp,1:n);
        temp(path) = inf;
        nsp = find(temp == min(temp));
        cost = cost + dist_spot(csp, nsp);
        path = [path, nsp];
        csp = nsp;
    end
    cpath = [0 path];
    if n == N   % û��backhaul�ڵ�
        cost = cost + dist_repo(csp);
        cpath = [cpath 0];
    else  % ��backhaul�ڵ�
        temp = dist_spot(csp, n+1:N);
        nsp = find(temp == min(temp)) + n;
        cost = cost + dist_spot(csp, nsp);
        path = nsp;    % ��linehaul�ڵ�ȥ��
        csp = nsp;
        for j = n+1:N-1
            temp = dist_spot(csp,n+1:N);
            temp(path-n) = inf;
            nsp = find(temp == min(temp)) + n;  % ǰ����n��linehaul�ڵ�
            cost = cost + dist_spot(csp, nsp);
            path = [path, nsp];
            csp = nsp;
        end
        cost = cost + dist_repo(csp);
        cpath = [cpath, path, 0];
    end        
end

function [path, cost] = route(N, n, dist_spot, dist_repo)
    U = 1:N;   % δ��ӵ�·���еĽڵ�
    delta = dist_repo;  % ������ȫͼ���ҶԳ�
    route = [];  % ȥ���ֿ�ڵ�ĵ�ǰ·���ڵ�
    cost = 0;
    while isempty(U) == 0
        % ���ҳ�delta���ĵ�
        temp = delta;
        sortdelta = sort(temp, 'descend');
        index = 1;
        i = find(temp == sortdelta(index));
        i = i(1);
        while ismember(i,U) == 0  % i����U�����Ԫ�أ�˵��i�Ѿ��߹� 
            temp(i) = -1;
            index = index + 1;
            i = find(temp == sortdelta(index));
            i = i(1);
        end
            
        M = inf;
        if length(route) == 0   % �ոմӲֿ����
            M = dist_repo(i)*2;
            insert_point = 0;
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
                                insert_point = k;   % ����㣨ǰ��
                            end
                        elseif k == 0  % ·���н���backhaul�ڵ�
                            npos = route(k+1);
                            diff = dist_repo(i)+dist_spot(i,npos)-dist_repo(npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % ����㣨ǰ��
                            end
                        else
                            cpos = route(k);
                            npos = route(k+1);
                            diff = dist_spot(cpos, i)+dist_spot(i, npos) - dist_spot(cpos, npos);
                            if diff < M
                                M = diff;
                                insert_point = k;   % ����㣨ǰ��
                            end
                        end
                    end
                else  % ���·����û�к���ڵ㣬�����ǵ�һ������ڵ㣬��ôֱ�Ӳ��뵽���
                    insert_point = length(route);   % ����㣨ǰ��
                    M = dist_repo(i)+dist_spot(i, insert_point) - dist_repo(insert_point);
                end
            else   % ���i��linehaul�ڵ�
                if isempty(bound)==0  % ���·������backhaul�ڵ�
                    bound = bound(1) - 1; % ���һ��linehaul�ڵ㣨����±�������
                else
                    bound = length(route);   % ·����û��backhaul�ڵ�
                end
                for k = 0:bound
                    if k == 0  % �����ǰ������ǰ�ڵ��ǲֿ�   
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
        end
        cost = cost + M;
        % ����route��U
        U = setdiff(U, i);
        newroute = zeros(length(route)+1, 1);
        if insert_point == length(route)   % ���뵽·�����
            newroute(1:length(route)) = route;
            newroute(end) = i;
        elseif insert_point == 0  % ���뵽��ͷ
            newroute(2:end) = route;
            newroute(1) = i;
        else
            newroute(1:insert_point) = route(1:insert_point);
            newroute(insert_point+1) = i;
            newroute(insert_point+2:end) = route(insert_point+1:end);
        end
        route = newroute;
        % ����delta
        for j = 1:length(U)
            if dist_spot(i,j) < delta(j)
                delta(j) = dist_spot(i,j);
            end
        end
    end
    % �������ص��ֿ�Ļ�·
    path = [0; route ;0]';
end
    
                
