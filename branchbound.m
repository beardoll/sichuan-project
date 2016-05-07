% �÷�֧���編�������·��
function [path] = branchbound(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
    m = N - n;    % backhaul�ĸ���
    best_c = inf;  % ��ǰ��С���ۣ���Ϊ�����
    min_out = count_minout(N, dist_spot, dist_repo);
    repo.remaincost = sum(min_out); % ���Ҫ�߻زֿ�
    repo.currentcost = min_out(1);
    repo.impose = 1:n;
    repo.size = 0;
    repo.num = 0;
    pq = repo;   % priority queue, �ȰѲֿ���ӽ�ȥ
    for i = 1:length(repo.impose)   % һ���Բ������еĻ�ڵ�
        node.remaincost = repo.remaincost - dist_spot(i);
        node.currentcost = repo.currentcost + dist_spot(i);
        node.impose = setdiff(repo.impose,i);
        node.size = repo.size+1;
        node.num = i;
        pq = [pq, node];
    end
    pq = rank(pq);  % �����������
    hn = pq(1);   
    pq(1) = [];   % ��ջ����
    while hn.size < N-1
        if hn.size == n  % linehaul�����һ�㣬��������Ҫ��backhaul��ѡ����
            new_impose = n+1:N;
            for j = 1:lenght(hn.impose)
                node.remaincost = hn.remaincost - min_cost(hn.impose(j));
                node.currentcost = hn.currentcost + dist_spot(hn.num, new_impose(j));
                node.size = hn.size + 1;
                node.impose = setdiff(new_impose,new_impose(j));
                node.num = new_impose(j);
                pq = [pq, node];
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        elseif hn.size == N-2  % backhaul�ĵ����ڶ���
            if(hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose) < best_c)
                best_c = hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose);
                hn.current_cost = best_c;
                hn.lower_cost = best_c;
                hn.size = hn.size + 1;
                pq = [pq, hn];
                pq = rank(pq);
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        else
            % ������ǰ��չ�ڵ�Ķ��ӽڵ�
            for k = 1:length(hn.impose)
                cc = hn.current_cost + dist_spot(hn.impose(k));
                rcost = hn.remaincost - min_out(hn.impose(k));
                b = cc + rcost;   % ���ȼ�lcost = ��ǰ���� + ʣ�������С���ú� - ��ǰ�ڵ����С����;
                if(b < best_c)
                    node.remaincost = rcost;
                    node.currentcost = cc;
                    node.size = hn.size + 1;
                    node.impose = setdiff(hn.impose, hn.impose(k));
                    node.num = hn.impose(k);
                    pq = [pq, node];
                end
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        end
    end
end

%%%%%%%%%%%%%%%% �����������Ͷ��� %%%%%%%%%%%%%%%%%%
% hn.remaincost:δ�߹��Ľڵ����С����֮��
% hn.currentcost: ���߹���·������֮��
% hn.size: ��ǰ·���ܳ���
% hn.impose: ��ѡ�ڵ�
% hn.num: ��ǰ������ĩ�ڵ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [order_pq] = rank(pq)
    % �Ե�ǰ��pq���н�������
    % �ٶ���ǰ�������Ľڵ�����Ϊs����s<N-2ʱ�����ȼ�lcost = ��ǰ����+ ʣ�������С���ú�- ��ǰ�ڵ����С����
    % ��s = N-2,N-1ʱ��lcost = ��ǰ��·�ĳ���
    pq_len = length(pq);
    cost_vec = zeros(1:pq_len);
    for i = 1:pq_len
        cost_vec(i) = pq.currentcost;
    end
    [sort_vec, sort_num] = sort(cost_vec);  % �����з��ý�������
    order_pq = pq(sort_num);
end

function [min_out] = count_minout(N, dist_spot, dist_repo)
    % ������С����
    min_out = zeros(1,N+1);    %��һ���ǲֿ����С����
    min_out(1) = min(dist_repo);
    for i = 2:N+1
        min_out(i) = min(dist_spot(i-1,:));
    end
end
    
    
    
    
        
    
    
    
    
    