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
     xorigin = range(1);   % 横向起点
     yorigin = range(3);   % 纵向起点
     rowLen = range(2) - range(1);  % 横向长度
     colLen = range(4) - range(3);  % 纵向长度
     intervalX = rowLen/rowDiv;     % 横向每个分块的跨度
     intervalY = colLen/colDiv;     % 纵向每个分块的跨度
     blockNum = rowDiv * colDiv;    % 总的分块数
     blockMemL = zeros(blockNum, 1); % 每个分块的linehaul成员数
     blockMemB = zeros(blockNum, 1); % 每个分块的backhaul成员数
     
     % 计算出每个分块内的成员数
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
     
     % 把簇首定在成员数最多的区域
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
     
     
     