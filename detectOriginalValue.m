function [CH] = detectOriginalValue(range, rowDiv, colDiv, samplex, sampley, K, repox, repoy)
     % �����ִ�ʱ�Ĵ��׳�ʼֵ
     % range: [xleft, xright, ybottom, ytop]
     % rowDiv: ����ֿ���
     % colDiv: ����ֿ���
     % samplex: ������ĺ�����
     % sampley: �������������
     % K: ������
     % CH: ��ά���飬�������� 
     % repox, repoy: �ֿ��������
     xorigin = range(1);   % �������
     yorigin = range(3);   % �������
     rowLen = range(2) - range(1);  % ���򳤶�
     colLen = range(4) - range(3);  % ���򳤶�
     intervalX = rowLen/rowDiv;     % ����ÿ���ֿ�Ŀ��
     intervalY = colLen/colDiv;     % ����ÿ���ֿ�Ŀ��
     blockNum = rowDiv * colDiv;    % �ܵķֿ���
     blockMem = zeros(blockNum, 1); % ÿ���ֿ�ĳ�Ա��
     
     % �����ÿ���ֿ��ڵĳ�Ա��
     for i = 1:blockNum
         yindex = floor(i/rowDiv)+1;
         if floor(i/rowDiv) == i/rowDiv 
             yindex = yindex - 1;
         end
         xindex = i - (yindex-1) * rowDiv;
         rowMem = intersect(find(samplex > (xindex-1)*intervalX+xorigin), find(samplex < xindex * intervalX+xorigin));
         colMem = intersect(find(sampley > (yindex-1)*intervalY+yorigin), find(sampley < yindex * intervalY+yorigin));
         blockMem(i) = length(intersect(rowMem, colMem));
     end
     
     % �Ѵ��׶��ڳ�Ա����������
     [sortMem, select] = sort(blockMem,'descend');
     CH = zeros(K, 2);
     count = 0;
     i = 1;
     while count < K
         y_axis = floor(select(i)/rowDiv)+1;
         if floor(select(i)/rowDiv) == select(i)/rowDiv
             y_axis = y_axis - 1;
         end
         x_axis = select(i) - (y_axis-1) * rowDiv;
         if x_axis <= repox && x_axis+intervalX >=repox &&...   % ����Ѵ��׶��ڲֿ⸽��
                 y_axis <= repoy && y_axis+intervalY >= repoy
             i = i+1;
             continue;
         else
             CH(i,1) = (x_axis-1)*intervalX + intervalX/2+xorigin;
             CH(i,2) = (y_axis-1)*intervalY + intervalY/2+yorigin;
             i = i+1;
             count = count + 1;
         end
     end
end
     
     
     