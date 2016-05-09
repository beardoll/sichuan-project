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
     rowLen = range(2) - range(1);  % ���򳤶�
     colLen = range(4) - range(3);  % ���򳤶�
     intervalX = rowLen/rowDiv;     % ����ÿ���ֿ�Ŀ��
     intervalY = colLen/colDiv;     % ����ÿ���ֿ�Ŀ��
     blockNum = rowDiv * colDiv;    % �ܵķֿ���
     blockMemL = zeros(blockNum, 1); % ÿ���ֿ��linehaul��Ա��
     blockMemB = zeros(blockNum, 1); % ÿ���ֿ��backhaul��Ա��
     
     % �����ÿ���ֿ��ڵĳ�Ա��
     for i = 1:blockNum
         yindex = floor(i/rowDiv);
         xindex = i - yindex * rowDiv;
         rowMemL = find(Lx > (xindex-1)*intervalX && Lx < xindex * intervalX);
         colMemL = find(Ly > (yindex-1)*intervalY && Ly < yindex * intervalY);
         blockMemL(i) = length(intersect(rowMemL, colMemL));
         rowMemB = find(Bx > (xindex-1)*intervalX && Bx < xindex * intervalX);
         colMemB = find(By > (yindex-1)*intervalY && By < yindex * intervalY);
         blockMemB(i) = length(intersect(rowMemB, colMemB));
     end
     
     % �Ѵ��׶��ڳ�Ա����������
     sortMemL = sort(blockMemL,'descend');
     sortMemB = sort(blockMemB,'descend');
     selectL = find(blockMemL == sortMemL(1:KL));
     selectB = find(blockMemB == sortMemB(1:KB));
     
     
     
     
end
     
     
     