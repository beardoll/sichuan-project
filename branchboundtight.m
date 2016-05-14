function [path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
    path = 0;
    node.pathcost = 8;
    node.path = [0 4];
    cost = get_lb(node, dist_spot, dist_repo, n,N);
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
            cost = cost + mindist_tobackhaul
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
    elseif pathlen - 1 == n && n == N   % ����·�������꣨û��backhaul�ڵ㣩
        cost = cost / 2;
    else       % ʣ��ڵ����Ѿ�û��linehaul�ڵ�
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
            cost = cost + sum(temp(1:end-2));  % ����n-2���ߵ���С��������
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
                
