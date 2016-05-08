% �÷�֧���編�������·��
function [best_path] = branchbound(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
    m = N - n;    % backhaul�ĸ���
    best_c = inf;  % ��ǰ��С���ۣ���Ϊ�����
    best_path = [];
    pq = [];      % priority queue
    min_out = count_minout(N, dist_spot, dist_repo);
    repo.remaincost = sum(min_out); % ���Ҫ�߻زֿ�
    repo.currentcost = 0;   % ��û�г�������˵�ǰ·������Ϊ0
    repo.impose = 1:n;
    repo.size = 0;
    repo.num = 0;
    repo.path = 0;
    for i = 1:length(repo.impose)   % һ���Բ������еĻ�ڵ�
        node.remaincost = repo.remaincost - min_out(N+1);   % ��ȥ�ֿ����С���߷���
        node.currentcost = repo.currentcost + dist_repo(repo.impose(i)); % ����ʵ�ʵĳ��߷���
        node.lcost = node.remaincost + node.currentcost;
        node.impose = setdiff(repo.impose,repo.impose(i));
        node.size = repo.size+1;
        node.num = i;
        node.path = [repo.path, repo.impose(i)];
        pq = [pq, node];
    end
    option = 0;  % ����ԭʼTSP����
    pq = rank(pq);  % �����������
    hn = pq(1);   
    pq(1) = [];   % ��ջ����
    while isempty(pq)~=1
        if hn.size == n  && option ~= 0   % linehaul�����һ�㣬��������Ҫ��backhaul��ѡ����
            new_impose = n+1:N;
            for j = 1:lenght(hn.impose)
                node.remaincost = hn.remaincost - min_cost(hn.impose(j));
                node.currentcost = hn.currentcost + dist_spot(hn.num, new_impose(j));
                node.lcost = node.remaincost + node.currentcost;
                node.size = hn.size + 1;
                node.impose = setdiff(new_impose,new_impose(j));
                node.num = new_impose(j);
                pq = [pq, node];
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        elseif hn.size == N-1  % backhaul�ĵ����ڶ���
            if(hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose) < best_c)
                best_c = hn.currentcost + dist_spot(hn.num, hn.impose) + dist_repo(hn.impose);
                hn.remaincost = 0;
                hn.currentcost = best_c;
                hn.lcost = best_c;
                hn.size = hn.size + 1;
                hn.path = [hn.path, hn.impose];
                best_path = [hn.path, 0]
                pq = [pq, hn];
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        else
            % ������ǰ��չ�ڵ�Ķ��ӽڵ�
            for k = 1:length(hn.impose)
                cc = hn.currentcost + dist_spot(hn.num, hn.impose(k));
                rcost = hn.remaincost - min_out(hn.num);
                b = cc + rcost;   % ���ȼ�lcost = ��ǰ���� + ʣ�������С���ú� - ��ǰ�ڵ����С����;
                if(b < best_c)
                    node.remaincost = rcost;
                    node.currentcost = cc;
                    node.lcost = node.remaincost + node.currentcost;
                    node.size = hn.size + 1;
                    node.impose = setdiff(hn.impose, hn.impose(k));
                    node.num = hn.impose(k);
                    node.path = [hn.path, hn.impose(k)];
                    pq = [pq, node];
                end
            end
            pq = rank(pq);
            hn = pq(1);
            pq(1) = [];  % ��ջ����
        end
        hn;
    end
            best_c
end

%%%%%%%%%%%%%%%% �����������Ͷ��� %%%%%%%%%%%%%%%%%%
% hn.remaincost:δ�߹��Ľڵ����С����֮��
% hn.currentcost: ���߹���·������֮��
% hn.size: ��ǰ·���ܳ���
% hn.impose: ��ѡ�ڵ�
% hn.num: ��ǰ������ĩ�ڵ�
% hn.lcost: ���ȼ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [order_pq] = rank(pq)
    % �Ե�ǰ��pq���н�������
    % �ٶ���ǰ�������Ľڵ�����Ϊs����s<N-2ʱ�����ȼ�lcost = ��ǰ����+ ʣ�������С���ú�- ��ǰ�ڵ����С����
    % ��s = N-2,N-1ʱ��lcost = ��ǰ��·�ĳ���
    pq_len = length(pq);
    cost_vec = zeros(1,pq_len);
    for i = 1:pq_len
        cost_vec(i) = pq(i).lcost;
    end
    [sort_vec, sort_num] = sort(cost_vec);  % �����з��ý�������
    order_pq = pq(sort_num);
end

function [min_out] = count_minout(N, dist_spot, dist_repo)
    % ������С����
    min_out = zeros(1,N+1);    %��N+1���ǲֿ����С����
    min_out(N+1) = min(dist_repo);
    for i = 1:N
        min_out(i) = min(dist_spot(i,:));
    end
end
    
    
    
    
        
    
    
    
    
    