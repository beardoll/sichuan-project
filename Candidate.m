function [CH] = Candidate(Lx, Ly, Bx, By, xmax, ymax, K)
% ���ݹ˿ͽڵ��ʼ�ֲ������ʼ���ף����񷨣�
    minblocknum = 9 * K;
    rowdiv = ceil(sqrt(minblocknum))+1;
    coldiv = rowdiv;
    xdivrange = xmax/rowdiv;
    ydivrange = ymax/coldiv;
    dc = sqrt(xdivrange^2 + ydivrange^2)*0.5;
    candidatex = zeros(rowdiv, coldiv);
    candidatey = zeros(rowdiv, coldiv);
    countnum = zeros(rowdiv, coldiv);

    for i = 1:coldiv      % iɨ��ÿһ�У��Ǿ����x���
        for j = 1:rowdiv  % jɨ��ÿһ�У��Ǿ����y���
            candidatex(i,j) = (j-1)*xdivrange + xdivrange/2;
            candidatey(i,j) = (i-1)*ydivrange + ydivrange/2;
            clusterx = candidatex(i,j);
            clustery = candidatey(i,j);
            optionrangex1 = max(clusterx - dc, 0);     % x������߽�
            optionrangex2 = min(clusterx + dc, xmax);  % x�����ұ߽�
            optionrangey1 = max(clustery - dc, 0);     % y�����±߽�
            optionrangey2 = min(clustery + dc, ymax);  % y�����ϱ߽�

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
    for i = 1:coldiv  % ɨ��ÿһ�У������x���
        for j = 1:rowdiv  % ɨ��ÿһ�У������y���
            colbottom = max(i-1, 1);    % x��С��
            coltop = min(i+1, coldiv);  % x�����
            rowleft = max(j-1,1);       % y��С��
            rowright = min(j+1, rowdiv); % y�����
%             diff(i,j) = countnum(colbottom,rowleft) + countnum(colbottom,j) + countnum(colbottom,rowright) + ...
%                    countnum(i,rowleft) + countnum(i,rowright) + countnum(coltop,rowleft) + ...
%                    countnum(coltop, j) + countnum(coltop, rowright) - 8*countnum(i,j);
            xr = [colbottom i coltop];
            yr = [rowleft j rowright];
            plus = 0;    % ��ǰ���ױ���Χ8�����׶�Ĵس�Ա����
            pluscount = 0; % һ����pluscount�����׶�
            minus = 0;   % ��ǰ���ױ���Χ8�������ٵĴس�Ա����
            minuscount = 0; % һ����minuscount��������
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

    % ��ֹ�ڲֿ���Χ��������
    % ��ֹ����ΪΧ�Ʋֿ����Щ����
    forbidymin = floor(xmax/2/xdivrange);  % �к�
    forbidxmin = floor(ymax/2/ydivrange);  % �к�
    if forbidxmin == ymax/2/ydivrange  % ���������������߽���
        forbidx = [forbidxmin forbidxmin+1];
    else
        forbidx = [forbidxmin forbidxmin+1 forbidxmin+2];
    end
    
    if forbidymin == xmax/2/xdivrange  % ����������ĺ���߽���
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
        temp1 = floor(maxindex/rowdiv) + 1;      % ��Ӧx
        temp2 = maxindex - (temp1-1) * rowdiv;   % ��Ӧy
        if temp2 == 0
            temp1 = temp1 - 1;
            temp2 = coldiv;
        end
        CH(i,1) = candidatex(temp1, temp2);
        CH(i,2) = candidatey(temp1, temp2);
        colbottom = max(temp1-1, 1);   % x��С��
        coltop = min(temp1+1, coldiv); % x�����
        rowleft = max(temp2-1, 1);     % y��С��
        rowright = min(temp2+1, rowdiv); % y�����
        
        % ÿ��ѡ��һ�����׺󣬽�����Χ��8����ѡ���״Ӻ�ѡ���г���
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
        



        