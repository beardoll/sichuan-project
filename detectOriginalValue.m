function [CH] = detectOriginalValue(range, rowDiv, colDiv, samplex, sampley, K, repox, repoy)
     % 决定分簇时的簇首初始值
     % range: [xleft, xright, ybottom, ytop]
     % rowDiv: 横向分块数
     % colDiv: 纵向分块数
     % samplex: 样本点的横坐标
     % sampley: 样本点的纵坐标
     % K: 车辆数
     % CH: 二维数组，簇首坐标 
     % repox, repoy: 仓库横纵坐标
     xorigin = range(1);   % 横向起点
     yorigin = range(3);   % 纵向起点
     rowLen = range(2) - range(1);  % 横向长度
     colLen = range(4) - range(3);  % 纵向长度
     intervalX = rowLen/rowDiv;     % 横向每个分块的跨度
     intervalY = colLen/colDiv;     % 纵向每个分块的跨度
     blockNum = rowDiv * colDiv;    % 总的分块数
     blockMem = zeros(blockNum, 1); % 每个分块的成员数
     
     % 计算出每个分块内的成员数
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
     
     % 把簇首定在成员数最多的区域
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
         if x_axis <= repox && x_axis+intervalX >=repox &&...   % 避免把簇首定在仓库附近
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
     
     
     