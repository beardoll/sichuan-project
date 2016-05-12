function [assignment] = AP(costMat)
    n = size(costMat, 1);   % ����Ľ���
    p = costMat;            % ��Լ����
    unique_zero = 0;
    while unique_zero < n   % ���ҵ�n����������Ԫ��ʱ���㷨����
        % ���ָ������
        % �������㷨
        row = zeros(1,n);       % ÿһ�е�0Ԫ�ظ���
        col = zeros(1,n);       % ÿһ�е�0Ԫ�ظ���
        q = zeros(n,n);         % ÿ��Ԫ�صĻ��������0��ʾδ��������1��ʾ����1�Σ�2��ʾ����2�Σ����㣩
        r = zeros(n,n);         % 0:����Ԫ�أ�1:�Ƕ�����Ԫ�أ�2:������Ԫ��
        x = zeros(1,n);         % ����ʱ�Ƿ񱻴򹴣�1��0����
        y = zeros(1,n);         % ����ʱ�Ƿ񱻴򹴣�1��0����
        unique_zero = 0;        % ������Ԫ�صĸ���

        % �й�Լ
        for i = 1:n
            p(i,:) = p(i,:) - min(p(i,:));
        end
        % �й�Լ
        for i = 1:n
            p(i,:) = p(i,:) - min(p(i,:));
        end
        
       %% ��ָ��
        % �ҳ�δ�����ߵĺ�0Ԫ�����ٵ���/��
        % �ҳ�����/����δ�����ߵ�0Ԫ�أ������һ������0Ԫ��
        % �Ը�0Ԫ�������к��л���
        % ������һ��ÿһ��ÿһ�е�0Ԫ��
        for i = 1:n
            row(i) = length(find(p(i,:)==0));
            col(i) = length(find(p(:,i)==0));
        end
        while 1  % ������Ԫ��û�б���ʱ����������
            if min(row) <= min(col)    % ����0Ԫ������
                index = find(row == min(row));  % �ҳ�����
                index = index(1);
                if row(index) == 0    % �������û��0Ԫ�أ����Ϊ�����
                    row(index) = inf;
                else
                    selection = find(p(index,:)==0);  % �ҳ�δ�����ߵ�һ��0Ԫ��
                    index2 = 0;    % �б��
                    stop = 1;
                    for i = 1:length(selection)
                        if q(index, selection(i)) == 0  % û������
                            index2 = selection(i);   % �ҵ�һ�����У��ɽ���forѭ��
                            r(index,selection(i)) = r(index,selection(i)) + 1; %�����+1ʹ֮��Ϊ����0Ԫ��
                            stop = 0;    % ����ҵ�������Ԫ�أ������ִ��whileѭ��
                            unique_zero = unique_zero + 1;
                            break;
                        end
                    end
                    if stop == 1
                        break;
                    end
                    % �Ը�0Ԫ�����ڵ��к��л���
                    q(index,:) = q(index,:) + 1;
                    q(:,index2) = q(:,index2) + 1;
                    row(index) = inf;   % �ѻ���
                    col(index2) = inf;
                    % �ǵø���row��col
                    zero_of_col = find(p(index,:) == 0); % �ڻ��ߵ�������Ԫ�����ڵ���
                    col(zero_of_col) = col(zero_of_col) - 1;
                    zero_of_row = find(p(:,index2) == 0)  % �ڻ��ߵ�������Ԫ�����ڵ���
                    row(zero_of_row) = row(zero_of_row) - 1;
                end
            else     % ����0Ԫ������
                index2 = find(col == min(col));  % �ҳ�����
                index2 = index2(1);
                if col(index2) == 0    % �������û��0Ԫ�أ����Ϊ�����
                    col(index2) = inf;
                else
                    selection = find(p(:,index2)==0);  % �ҳ�δ�����ߵ�һ��0Ԫ��
                    index = 0;    % �б��
                    stop = 1;
                    for i = 1:length(selection)
                        if q(selection(i), index2) == 0   % û������
                            index = selection(i);   % �ҵ�һ�����У��ɽ���forѭ��
                            r(selection(i),index2) = r(selection(i),index2) + 1; %�����+1ʹ֮��Ϊ����0Ԫ��
                            stop = 0;   % ����ҵ�������Ԫ�أ������ִ��whileѭ��
                            unique_zero = unique_zero + 1;
                            break;
                        end
                    end
                    if stop == 1
                        break;
                    end
                    % �Ը�0Ԫ�����ڵ��к��л���
                    q(index,:) = q(index,:) + 1;
                    q(:,index2) = q(:,index2) + 1;
                    row(index) = inf;   % �ѻ���
                    col(index2) = inf;
                    % �ǵø���row��col
                    zero_of_col = find(p(index,:) == 0); % �ڻ��ߵ�������Ԫ�����ڵ���
                    col(zero_of_col) = col(zero_of_col) - 1;
                    zero_of_row = find(p(:,index2) == 0)  % �ڻ��ߵ�������Ԫ�����ڵ���
                    row(zero_of_row) = row(zero_of_row) - 1;
                end
            end
        end
        % ���ַ�0Ԫ��(=0)���Ƕ���0Ԫ��(=1)������0Ԫ��(=2)
        zeropos = find(p == 0);   % �ҳ���Լ�����0Ԫ�ص�λ��
        temp = r;
        temp = temp(:);           % ����չ��
        temp(zeropos) = temp(zeropos) + 1;
        temp = reshape(temp,n,n);
        r = temp;

        %% ����С��0��
        % ��û�ж���0Ԫ�ص��д�
        for i = 1:n
            if isempty(find(r(i,:)==2)) == 1  %����û�ж�����Ԫ��
                x(i) = 1;
            end
        end
        % �Դ򹴵�������0Ԫ�ص��д�
        stop = 0;
        while stop == 0
            row_mark = find(x == 1);   % ���Ҫ�򹴵���
            for i = 1:length(row_mark)
                zeropos = find(p(row_mark(i),:) == 0);
                if(length(find(y(zeropos) == 1)) == length(zeropos))  % û�п��Դ򹴵���
                    stop = 1;
                else
                    y(zeropos) = 1;
                end
            end
            col_mark = find(y==1);     % ���Ҫ�򹴵���
            % �����д򹴵�������������0Ԫ�ص��д�
            for i = 1:length(col_mark)
                uniquepos = find(r(:,col_mark(i)) == 2);
                if length(find(x(uniquepos)==1)) == length(uniquepos)  % û�п��Դ򹴵���
                    stop = 1;
                else
                    x(uniquepos) = 1;
                end
            end
        end
        % �Դ򹴵��к�û�д򹴵��л��ߣ��Ǿ�����С��0��

        %% ���¾���
        row_not_draw = find(x==0);   % û�����ߵ���
        col_not_draw = find(y==0);   % û�����ߵ���
        element_not_draw = p(row_not_draw, col_not_draw);  % û�б����ߵ���
        min_value = min(element_not_draw);  % û�б����ߵ�������С����
        p(row_not_draw, col_not_draw) = p(row_not_draw, col_not_draw) - min_value;
        row_draw = find(x==1);  % �����ߵ���
        col_draw = find(y==1);  % �����ߵ���
        p(row_draw, col_draw) = p(row_draw, col_draw) + min_value; % �Ա������߻��������У�������С����     
    end
    assignment = p;
end


