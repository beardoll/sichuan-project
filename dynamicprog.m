function [best_path, best_cost] = dynamicprog(N, n, dist_spot, dist_repo)

    % �㷨��������̬�滮�㷨
    % 1.nodearr��ŵ�����һ�׶ε����·���˵�����Ž⣬�ں�
    %        impose -- ���Ӹ�node����·���Ͽ������·���ڵ�
    %        path   -- ����node�����߹���·��
    % 2. cost��ŵ�����һ�׶ε������������Ŵ���,iΪ��һ�׶νڵ������
    % 3. nodeid��cost���Ӧ����Ҫ�ﵽ�����Ŵ��ۣ���һ�׶θõ�Ӧ�����ӵ���һ��node
    
    nodeid = zeros(1,n);
    nodearr = [];
    node.impose = 1:n;
    node.path = 0;
    nodearr = [nodearr, node];
    cost = dist_repo(1:n);  % ��ʼ������һ�׶ε����Ž�Ϊ�Ӳֿ�����ľ���
    nodeid(1:end) = 1;   % ��ǰ��һ���㣨�ֿ⣩չ��
    for phase = 1:N   % �׶μ���
        if phase <= n   % ��û�ߵ�backhaul�ڵ�
            update_nodearr = [];
            if phase == n  && N-n ~=0 % ��һ��Ҫȥ��backhaul�ڵ���
                cnodeid = zeros(1,N-n)-1;
                tempcost = inf(1,N-n);
                for i = 1:n
                    choice = nodeid(i);    % ѡ�������С��k-1�׶εĽ����
                    if choice == -1   % û�е��˽ڵ��·��
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = n+1:N;
                        cnode.path = [cnode.path, i];
                        update_nodearr = [update_nodearr cnode];
                        for j = 1:length(cnode.impose)
                            % ����-n����Ϊ����cost�Ǵ�1��ʼ�����Ǵ�n��ʼ
                            if cost(i) + dist_spot(i,cnode.impose(j)) < tempcost(cnode.impose(j)-n)
                                tempcost(cnode.impose(j)-n) = cost(i) + dist_spot(i,cnode.impose(j));
                                cnodeid(cnode.impose(j)-n) = length(update_nodearr);  % �µĽڵ���뵽���
                            end
                        end    
                    end
                end
                nodeid = cnodeid;
                cost = tempcost;
                nodearr = update_nodearr;
            elseif phase ==n  && N-n == 0  % û��backhaul�ڵ㣬ֱ�ӷ���
                cnodeid = -1;
                tempcost = inf;
                for i = 1:n
                    choice = nodeid(i);
                    if choice == -1   % û�е��˽ڵ��·��
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = 0;
                        cnode.path = [cnode.path i];
                        update_nodearr = [update_nodearr cnode];
                        if cost(i) + dist_repo(i) < tempcost
                            tempcost = cost(i) + dist_repo(i);
                            cnodeid = length(update_nodearr);
                        end    
                    end
                end
                nodeid = cnodeid;
                cost = tempcost;
                nodearr = update_nodearr;
            else  % ��linehaul�ڵ���Ѱ
                cnodeid = zeros(1,n)-1;
                tempcost = inf(1,n);   % ��k�׶ε���С���ۣ���ʼ��Ϊ�����
                for i = 1:n
                    choice = nodeid(i);    % ѡ�������С��k-1�׶εĽ����
                    if choice == -1   % û�е��˽ڵ��·��
                        continue;
                    else
                        cnode = nodearr(choice);
                        cnode.impose = setdiff(cnode.impose, i);  % ȥ����ǰ���е�
                        cnode.path = [cnode.path, i];
                        update_nodearr = [update_nodearr cnode];
                        for j = 1:length(cnode.impose)
                            if cost(i) + dist_spot(i,cnode.impose(j)) < tempcost(cnode.impose(j))
                                tempcost(cnode.impose(j)) = cost(i) + dist_spot(i,cnode.impose(j));
                                cnodeid(cnode.impose(j)) = length(update_nodearr);  % �µĽڵ���뵽���
                            end
                        end
                    end
                end
                nodearr = update_nodearr;
                cost = tempcost;
                nodeid = cnodeid;
            end
        elseif phase < N  % ��backhaul�ڵ�����Ѱ�����ǻ�û���յ�
            update_nodearr = [];
            tempcost = inf(1,N-n);   % ��k�׶ε���С���ۣ���ʼ��Ϊ�����
            cnodeid = zeros(1,N-n)-1;
            for i = 1:N-n
                choice = nodeid(i);
                if choice == -1   % û�е��˽ڵ��·��
                    continue;
                else
                    cnode = nodearr(choice);
                    cnode.impose = setdiff(cnode.impose, i+n);
                    cnode.path = [cnode.path, i+n];
                    update_nodearr = [update_nodearr cnode];
                    for j = 1:length(cnode.impose)
                        if cost(i)+dist_spot(i+n, cnode.impose(j)) < tempcost(cnode.impose(j)-n)
                            tempcost(cnode.impose(j)-n) = cost(i) + dist_spot(i+n, cnode.impose(j));
                            cnodeid(cnode.impose(j)-n) = length(update_nodearr);
                        end
                    end
                end
            end
            nodearr = update_nodearr;
            nodeid = cnodeid;
            cost = tempcost;
        else   % �س�
            update_nodearr = [];
            tempcost = inf;
            cnodeid = -1;
            for i = 1:N-n
                choice = nodeid(i);
                if choice == -1   % û�е��˽ڵ��·��
                    continue;
                else
                    cnode = nodearr(choice);
                    cnode.impose = 0;
                    cnode.path = [cnode.path, i+n];
                    update_nodearr = [update_nodearr cnode];
                    if cost(i)+dist_repo(i+n) < tempcost
                        tempcost = cost(i) + dist_repo(i+n);
                        cnodeid = length(update_nodearr);
                    end    
                end
            end
            nodearr = update_nodearr;
            cost = tempcost;
            nodeid = cnodeid;
        end
    end
    best_cost = cost;
    best_path = [nodearr(nodeid).path, 0];  % ���ϻس̵Ĳֿ�ڵ�
end