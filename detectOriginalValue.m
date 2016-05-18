function [CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB)
     % �����ִ�ʱ�Ĵ��׳�ʼֵ
     % range: [xleft, xright, ybottom, ytop]
     % rowDiv: ����ֿ���
     % colDiv: ����ֿ���
     % Lx, Ly: ����Linehaul�ĺ������������
     % Bx, By: ����Linehaul�ĺ������������
     % KL: linehaul�ķִ���Ŀ
     % KB�� backhaul�ķִ���Ŀ
     % CHL, CHB: ��ά���飬linhaul�Ĵ��׺�backhaul�Ĵ���
     xorigin = range(1);   % �������
     yorigin = range(3);   % �������
     rowLen = range(2) - range(1);  % ���򳤶�
     colLen = range(4) - range(3);  % ���򳤶�
     intervalX = rowLen/rowDiv;     % ����ÿ���ֿ�Ŀ��
     intervalY = colLen/colDiv;     % ����ÿ���ֿ�Ŀ��
     blockNum = rowDiv * colDiv;    % �ܵķֿ���
     blockMemL = zeros(blockNum, 1); % ÿ���ֿ��linehaul��Ա��
     blockMemB = zeros(blockNum, 1); % ÿ���ֿ��backhaul��Ա��
     
     % �����ÿ���ֿ��ڵĳ�Ա��
     for i = 1:blockNum
         yindex = floor(i/rowDiv)+1;
         if floor(i/rowDiv) == i/rowDiv 
             yindex = yindex - 1;
         end
         xindex = i - (yindex-1) * rowDiv;
         rowMemL = intersect(find(Lx > (xindex-1)*intervalX+xorigin), find(Lx < xindex * intervalX+xorigin));
         colMemL = intersect(find(Ly > (yindex-1)*intervalY+yorigin), find(Ly < yindex * intervalY+yorigin));
         blockMemL(i) = length(intersect(rowMemL, colMemL));
         rowMemB = intersect(find(Bx > (xindex-1)*intervalX+xorigin), find(Bx < xindex * intervalX+xorigin));
         colMemB = intersect(find(By > (yindex-1)*intervalY+yorigin), find(By < yindex * intervalY+yorigin));
         blockMemB(i) = length(intersect(rowMemB, colMemB));
     end
     
     % �Ѵ��׶��ڳ�Ա����������
     [sortMemL, selectL] = sort(blockMemL,'descend');
     [sortMemB, selectB] = sort(blockMemB,'descend');
     CHL = zeros(KL, 2);
     CHB = zeros(KB, 2);
     for i = 1:KL
         y_axis = floor(selectL(i)/rowDiv)+1;
         if floor(selectL(i)/rowDiv) == selectL(i)/rowDiv
             y_axis = y_axis - 1;
         end
         x_axis = selectL(i) - (y_axis-1) * rowDiv;
         CHL(i,1) = (x_axis-1)*intervalX + intervalX/2+xorigin;
         CHL(i,2) = (y_axis-1)*intervalY + intervalY/2+yorigin;
     end
     for i = 1:KB
         y_axis = floor(selectB(i)/rowDiv)+1;
         if floor(selectB(i)/rowDiv) == selectB(i)/rowDiv
             y_axis = y_axis - 1;
         end
         x_axis = selectB(i) - (y_axis-1) * rowDiv;
         CHB(i,1) = (x_axis-1)*intervalX + intervalX/2+xorigin;
         CHB(i,2) = (y_axis-1)*intervalY + intervalY/2+yorigin;
     end     
end
     
     
     