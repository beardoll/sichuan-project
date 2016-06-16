function [CH] = Candidate(Lx, Ly, Bx, By, xmax, ymax, K)
% 根据顾客节点初始分布定义初始簇首（网格法）
    minblocknum = 9 * K;
    rowdiv = ceil(sqrt(minblocknum))+1;
    coldiv = rowdiv;
    xdivrange = xmax/rowdiv;
    ydivrange = ymax/coldiv;
    dc = sqrt(xdivrange^2 + ydivrange^2)*0.5;
    candidatex = zeros(rowdiv, coldiv);
    candidatey = zeros(rowdiv, coldiv);
    countnum = zeros(rowdiv, coldiv);

    for i = 1:coldiv      % i扫过每一行，是矩阵的x编号
        for j = 1:rowdiv  % j扫过每一列，是矩阵的y编号
            candidatex(i,j) = (j-1)*xdivrange + xdivrange/2;
            candidatey(i,j) = (i-1)*ydivrange + ydivrange/2;
            clusterx = candidatex(i,j);
            clustery = candidatey(i,j);
            optionrangex1 = max(clusterx - dc, 0);     % x坐标左边界
            optionrangex2 = min(clusterx + dc, xmax);  % x坐标右边界
            optionrangey1 = max(clustery - dc, 0);     % y坐标下边界
            optionrangey2 = min(clustery + dc, ymax);  % y坐标上边界

            temp1 = intersect(find(Lx >= optionrangex1),find(Lx <= optionrangex2));
            temp2 = intersect(find(Ly >= optionrangey1),find(Ly <= optionrangey2));
            optionL = intersect(temp1, temp2);
            len1 = length(optionL);
            if isempty(optionL) == 0
                for k = 1:len1
                    cspot = optionL(k);
                    if sqrt((Lx(cspot) - clusterx)^2 + (Ly(cspot) - clustery)^2) < dc
                        countnum(i,j) = countnum(i,j) + 1;
                    end
                end
            end

            temp3 = intersect(find(Bx >= optionrangex1),find(Bx <= optionrangex2));
            temp4 = intersect(find(By >= optionrangey1),find(By <= optionrangey2));
            optionB = intersect(temp3, temp4);
            len2 = length(optionB);
            if isempty(optionB) == 0
                for k = 1:len2
                    cspot = optionB(k);
                    if sqrt((Bx(cspot) - clusterx)^2 + (By(cspot) - clustery)^2) < dc
                        countnum(i,j) = countnum(i,j) + 1;
                    end
                end
            end
        end
    end

    diff = zeros(rowdiv, coldiv);
    for i = 1:coldiv  % 扫过每一行，矩阵的x编号
        for j = 1:rowdiv  % 扫过每一列，矩阵的y编号
            colbottom = max(i-1, 1);    % x最小者
            coltop = min(i+1, coldiv);  % x最大者
            rowleft = max(j-1,1);       % y最小者
            rowright = min(j+1, rowdiv); % y最大者
%             diff(i,j) = countnum(colbottom,rowleft) + countnum(colbottom,j) + countnum(colbottom,rowright) + ...
%                    countnum(i,rowleft) + countnum(i,rowright) + countnum(coltop,rowleft) + ...
%                    countnum(coltop, j) + countnum(coltop, rowright) - 8*countnum(i,j);
            xr = [colbottom i coltop];
            yr = [rowleft j rowright];
            plus = 0;    % 当前簇首比周围8个簇首多的簇成员数量
            pluscount = 0; % 一共比pluscount个簇首多
            minus = 0;   % 当前簇首比周围8个簇首少的簇成员数量
            minuscount = 0; % 一共比minuscount个簇首少
            for m = 1:length(xr)
                for n = 1:length(yr)
                    temp = countnum(i,j) - countnum(xr(m),yr(n));
                    if temp > 0
                        plus = plus + temp;
                        pluscount = pluscount + 1;
                    elseif temp < 0
                        minus = minus + abs(temp);
                        minuscount = minuscount + 1;
                    end
                end
            end
            if pluscount
                plus = plus/pluscount;
            end
            if minuscount
                minus = minus/minuscount;
            end
            diff(i,j) = max(plus, minus);
%             diff(i, j) = abs(diff(i, j));
        end
    end

    % 禁止在仓库周围产生簇首
    % 禁止区域为围绕仓库的那些区域
    forbidymin = floor(xmax/2/xdivrange);  % 列号
    forbidxmin = floor(ymax/2/ydivrange);  % 行号
    if forbidxmin == ymax/2/ydivrange  % 正好在区域的纵轴边界上
        forbidx = [forbidxmin forbidxmin+1];
    else
        forbidx = [forbidxmin forbidxmin+1 forbidxmin+2];
    end
    
    if forbidymin == xmax/2/xdivrange  % 正好在区域的横轴边界上
        forbidy = [forbidymin forbidymin+1];
    else
        forbidy = [forbidymin forbidymin+1 forbidymin+2];
    end
    
    for i = 1:length(forbidx)
        for j = 1:length(forbidy)
            diff(forbidx(i),forbidy(j)) = 0;
        end
    end
    
    CH = zeros(K,2);
    for i = 1:K
        maxdiff = max(max(diff));
        maxindex = find(diff' == maxdiff);
        maxindex = maxindex(randi([1 length(maxindex)], 1));
        temp1 = floor(maxindex/rowdiv) + 1;      % 对应x
        temp2 = maxindex - (temp1-1) * rowdiv;   % 对应y
        if temp2 == 0
            temp1 = temp1 - 1;
            temp2 = coldiv;
        end
        CH(i,1) = candidatex(temp1, temp2);
        CH(i,2) = candidatey(temp1, temp2);
        colbottom = max(temp1-1, 1);   % x最小者
        coltop = min(temp1+1, coldiv); % x最大者
        rowleft = max(temp2-1, 1);     % y最小者
        rowright = min(temp2+1, rowdiv); % y最大者
        
        % 每当选中一个簇首后，将其周围的8个候选簇首从候选人中除名
        diff(colbottom, rowleft) = 0;
        diff(colbottom, temp2) = 0;
        diff(colbottom, rowright) = 0;
        diff(temp1, rowleft) = 0;
        diff(temp1, temp2) = 0;
        diff(temp1, rowright) = 0;
        diff(coltop, rowleft) = 0;
        diff(coltop, temp2) = 0;
        diff(coltop, rowright) = 0;
    end
end
        



        