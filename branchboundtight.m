function [path, cost] = branchboundtight(N, n, dist_spot, dist_repo)
    % n��linehaul�ĸ���
    % N�ǽڵ��ܵĸ���
    % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
    % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
end

function [cost] = get_lb(node, dist_spot, dist_repo, n, N)
    % �ҵ�node�ڵ���½�
    % �ֳ�3�󲿷�
    % ��һ���������߹�·�����ȵ�2��
    % �ڶ����������߹�·���Ķ˵㵽δ�߹��ڵ����С�����
    % ����������δ�߹��ڵ��У�linehaul��backhaul�ڵ�ֱ����С��������
    %         Ҳ����˵���ٶ���n��linehaul�ڵ㣬��ôÿ��������������ȣ���2n����
    %         ��ô��С��������Ϊ(n-2)*2����̱�֮��
    % ���Ĳ�����linehaul��backhaul�ڵ����С��������
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
            % ����ʣ��remain_linehaulnum - 2���ڵ����������
            costL = zeros(length(remain_linehaul), 1);  % linehaul�ڵ������Ӵ���
            for i = 1:remain_linehaulnum
                sort_cost = sort(dist_spot(remain_linehaul(i), remain_linehaul), 'ascend');
                costL(i) = sum(sort_cost(1:2));   % ���·�����
            end
            costL = sort(costL, 'ascend');  % ��������
            cost = cost + costL(1:end-2);   % ����n-2�������ߵ���̾���
        elseif remain_linehaulnum == 2  
            % ʣ��linehaul�ڵ����2��       
            cost = cost + 2*dist_spot(remain_linehaul(1), remain_linehaul(2));            
        end
        % ��linehaul��backhaul����С��������
        back_spot = n+1:N;  % backhaul�ڵ���
        mindist_tobackhaul = min(min(dist_spot(remain_linehaul, back_spot)));
        cost = cost + mindist_tobackhaul;
        % ����backhaul�ڵ����С��������
        costB = zeros(N-n,1);
        for i = 1:N-n
            sort_cost = sort(dist_spot(back_spot(i),:),'ascend');
            costB(i) = sum(sort_cost(1:2));
        end
        
        %%%%%%%%%%%%%% Ȼ��������߹�·����δ�߹��˵����С�����  %%%%%%%%%%%%%%%%%
        mindist_start = min(dist_repo(back_spot));  % backhaul�ڵ����Ӳֿ����С����
        mindist_end = min(dist_spot(pathend,remain_linehaul));  % ʣ��linehaul�ڵ����·�����ڵ����̾���
        cost = cost + costB(1:end-2) + mindist_start + mindist_tobackhaul + mindist_end;
        
    else       % ʣ��ڵ����Ѿ�û��backhaul�ڵ�
        %%%%%%%%%%%%%%%%%%%%%% ���ȼ�����С��������  %%%%%%%%%%%%%%%%%%%%%%%%%%
        back_spot = n+1:N;  % backhaul�ڵ���
        remain_backhaul = setdiff(back_spot, path);   % ʣ��ڵ��е�backhaul�ڵ�
        remain_backhaulnum = length(remain_backhaul);
        if remain_backhaulnum >= 3
            % ʣ��backhaul�ڵ��������ڵ���3
            costB = zeros(remain_backhaulnum, 1);
            for i = 1:remain_backhaulnum
                sort_cost = sort(dist_spot(back_spot(i),:),'ascend');
                costB(i) = sum(sort_cost(1:2));
            end
            cost = cost + costB(1:end-2);  % ����n-2���ߵ���С��������
        elseif remain_backhaulnum == 2
            % ʣ��backhaul�ڵ���������2
            cost = cost + dist_spot(remain_backhaul(1), remain_backhaul(2));
        end
        %%%%%%%%%%%%%% Ȼ��������߹�·����δ�߹��˵����С�����  %%%%%%%%%%%%%%%%%
        mindist_end = min(dist_spot(remain_backhaul, pathend));  % ��·��ĩ�˵����̾���
        mindist_start = min(dist_repo(remain_backhaul));
        cost = cost + mindist_end + mindist_start;
    end    
end
                
