function [results] = BPP(demand, capacity)
    % װ������
    % ���û���̰��˼���FFD�㷨
    % step1: ����Ʒ�ɴ�С��������
    % step2: �������е���Ʒ���ȳ��Խ�����Ʒװ��һ���Ѿ������������У����װ���£������µ�����
    
    n = length(demand);   % Ҫװ�ص���Ʒ����
    box = zeros(1,n);     % ���ӳ�ʼ��Ϊ�գ������Ҫn������
    mark = 0;             % �ѿ�������������
    %% ����Ʒ��С��������
    sort_demand = sort(demand, 'descend');
        
    
    %% װ�����
    mark = 1;   % һ��ʼ��ʱ���ȿ�����һ������
    for i=1:n
        success = 0;  % =1��ʾ�ɹ������ѿ�����������װ����Ʒ 
        for j = 1:mark
            if capacity - box(j) > sort_demand(i)
                box(j) = box(j) + sort_demand(i);
                success = 1;
                break;
            end
        end
        if success == 0
            mark = mark + 1;
            box(mark) = sort_demand(i);
        end
    end
    results = mark;
end
