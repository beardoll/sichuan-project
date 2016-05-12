function [assignment] = AP(costMat)
    n = size(costMat, 1);   % 矩阵的阶数
    p = costMat;            % 规约矩阵
    unique_zero = 0;
    while unique_zero < n   % 当找到n个独立的零元素时，算法阶数
        % 求解指派问题
        % 匈牙利算法
        row = zeros(1,n);       % 每一行的0元素个数
        col = zeros(1,n);       % 每一列的0元素个数
        q = zeros(n,n);         % 每个元素的划线情况，0表示未被划过，1表示划过1次，2表示划过2次（交点）
        r = zeros(n,n);         % 0:非零元素，1:非独立零元素，2:独立零元素
        x = zeros(1,n);         % 划线时是否被打勾，1是0不是
        y = zeros(1,n);         % 划线时是否被打勾，1是0不是
        unique_zero = 0;        % 独立零元素的个数

        % 行规约
        for i = 1:n
            p(i,:) = p(i,:) - min(p(i,:));
        end
        % 列规约
        for i = 1:n
            p(i,:) = p(i,:) - min(p(i,:));
        end
        
       %% 试指派
        % 找出未被划线的含0元素最少的行/列
        % 找出该行/列中未被划线的0元素，这就是一个独立0元素
        % 对该0元素所在行和列划线
        % 首先数一下每一行每一列的0元素
        for i = 1:n
            row(i) = length(find(p(i,:)==0));
            col(i) = length(find(p(:,i)==0));
        end
        while 1  % 当还有元素没有被划时，继续划线
            if min(row) <= min(col)    % 最少0元素在行
                index = find(row == min(row));  % 找出该行
                index = index(1);
                if row(index) == 0    % 如果该行没有0元素，标记为无穷大
                    row(index) = inf;
                else
                    selection = find(p(index,:)==0);  % 找出未被划线的一个0元素
                    index2 = 0;    % 列标号
                    stop = 1;
                    for i = 1:length(selection)
                        if q(index, selection(i)) == 0  % 没被划线
                            index2 = selection(i);   % 找到一个就行，可结束for循环
                            r(index,selection(i)) = r(index,selection(i)) + 1; %后面会+1使之成为独立0元素
                            stop = 0;    % 如果找到独立零元素，则继续执行while循环
                            unique_zero = unique_zero + 1;
                            break;
                        end
                    end
                    if stop == 1
                        break;
                    end
                    % 对该0元素所在的行和列划线
                    q(index,:) = q(index,:) + 1;
                    q(:,index2) = q(:,index2) + 1;
                    row(index) = inf;   % 已划线
                    col(index2) = inf;
                    % 记得更新row和col
                    zero_of_col = find(p(index,:) == 0); % 在划线的行中零元素所在的列
                    col(zero_of_col) = col(zero_of_col) - 1;
                    zero_of_row = find(p(:,index2) == 0)  % 在划线的列中零元素所在的列
                    row(zero_of_row) = row(zero_of_row) - 1;
                end
            else     % 最少0元素在列
                index2 = find(col == min(col));  % 找出该列
                index2 = index2(1);
                if col(index2) == 0    % 如果该列没有0元素，标记为无穷大
                    col(index2) = inf;
                else
                    selection = find(p(:,index2)==0);  % 找出未被划线的一个0元素
                    index = 0;    % 行标号
                    stop = 1;
                    for i = 1:length(selection)
                        if q(selection(i), index2) == 0   % 没被划线
                            index = selection(i);   % 找到一个就行，可结束for循环
                            r(selection(i),index2) = r(selection(i),index2) + 1; %后面会+1使之成为独立0元素
                            stop = 0;   % 如果找到独立零元素，则继续执行while循环
                            unique_zero = unique_zero + 1;
                            break;
                        end
                    end
                    if stop == 1
                        break;
                    end
                    % 对该0元素所在的行和列划线
                    q(index,:) = q(index,:) + 1;
                    q(:,index2) = q(:,index2) + 1;
                    row(index) = inf;   % 已划线
                    col(index2) = inf;
                    % 记得更新row和col
                    zero_of_col = find(p(index,:) == 0); % 在划线的行中零元素所在的列
                    col(zero_of_col) = col(zero_of_col) - 1;
                    zero_of_row = find(p(:,index2) == 0)  % 在划线的列中零元素所在的列
                    row(zero_of_row) = row(zero_of_row) - 1;
                end
            end
        end
        % 区分非0元素(=0)，非独立0元素(=1)，独立0元素(=2)
        zeropos = find(p == 0);   % 找出规约矩阵的0元素的位置
        temp = r;
        temp = temp(:);           % 按行展开
        temp(zeropos) = temp(zeropos) + 1;
        temp = reshape(temp,n,n);
        r = temp;

        %% 画最小盖0线
        % 对没有独立0元素的行打勾
        for i = 1:n
            if isempty(find(r(i,:)==2)) == 1  %该行没有独立零元素
                x(i) = 1;
            end
        end
        % 对打勾的行所含0元素的列打勾
        stop = 0;
        while stop == 0
            row_mark = find(x == 1);   % 标记要打勾的行
            for i = 1:length(row_mark)
                zeropos = find(p(row_mark(i),:) == 0);
                if(length(find(y(zeropos) == 1)) == length(zeropos))  % 没有可以打勾的列
                    stop = 1;
                else
                    y(zeropos) = 1;
                end
            end
            col_mark = find(y==1);     % 标记要打勾的列
            % 对所有打勾的列中所含独立0元素的行打勾
            for i = 1:length(col_mark)
                uniquepos = find(r(:,col_mark(i)) == 2);
                if length(find(x(uniquepos)==1)) == length(uniquepos)  % 没有可以打勾的行
                    stop = 1;
                else
                    x(uniquepos) = 1;
                end
            end
        end
        % 对打勾的列和没有打勾的行划线，那就是最小盖0线

        %% 更新矩阵
        row_not_draw = find(x==0);   % 没被划线的行
        col_not_draw = find(y==0);   % 没被划线的列
        element_not_draw = p(row_not_draw, col_not_draw);  % 没有被划线的数
        min_value = min(element_not_draw);  % 没有被划线的数中最小的数
        p(row_not_draw, col_not_draw) = p(row_not_draw, col_not_draw) - min_value;
        row_draw = find(x==1);  % 被划线的行
        col_draw = find(y==1);  % 被划线的列
        p(row_draw, col_draw) = p(row_draw, col_draw) + min_value; % 对被两条线划到的数中，加上最小的数     
    end
    assignment = p;
end


