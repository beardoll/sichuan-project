function [CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB)
     % 决定分簇时的簇首初始值
     % range: [xleft, xright, ybottom, ytop]
     % rowDiv: 横向分块数
     % colDiv: 纵向分块数
     % Lx, Ly: 所有Linehaul的横坐标和纵坐标
     % Bx, By: 所有Linehaul的横坐标和纵坐标
     % KL: linehaul的分簇数目
     % KB： backhaul的分簇数目
     % CHL, CHB: 二维数组，linhaul的簇首和backhaul的簇首
     rowLen = range(2) - range(1);  % 横向长度
     colLen = range(4) - range(3);  % 纵向长度
     intervalX = rowLen/rowDiv;     % 横向每个分块的跨度
     intervalY = colLen/colDiv;     % 纵向每个分块的跨度
     blockNum = rowDiv * colDiv;    % 总的分块数
     blockMemL = zeros(blockNum, 1); % 每个分块的linehaul成员数
     blockMemB = zeros(blockNum, 1); % 每个分块的backhaul成员数
     
     % 计算出每个分块内的成员数
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
     
     % 把簇首定在成员数最多的区域
     sortMemL = sort(blockMemL,'descend');
     sortMemB = sort(blockMemB,'descend');
     selectL = find(blockMemL == sortMemL(1:KL));
     selectB = find(blockMemB == sortMemB(1:KB));
     
     
     
     
end
     
     
     