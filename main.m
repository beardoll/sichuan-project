clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 计算距离 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wareHouseNum = 4;
recSpotNum = 2;
position = cell(6);
position{1}.x = 0;
position{1}.y = 5;
position{2}.x = 6;
position{2}.y = 0;
position{3}.x = 10;
position{3}.y = 3;
position{4}.x = 7;
position{4}.y = 9;
position{5}.x = 5;
position{5}.y = 8;
position{6}.x = 3;
position{6}.y = 15;
D = zeros(wareHouseNum+recSpotNum, wareHouseNum+recSpotNum);
for i = 1:wareHouseNum + recSpotNum
    for j = i:wareHouseNum + recSpotNum
        if i == j
            D(i,j) = inf;
        else
            D(i,j) = sqrt((position{i}.x - position{j}.x)^2 + (position{i}.y - position{j}.y)^2);
            D(j,i) = D(i,j);
        end
    end
end
DcarToSpot = zeros(1, wareHouseNum + recSpotNum);
for i = 1:wareHouseNum+recSpotNum
    DcarToSpot(i) = sqrt(position{i}.x^2 + position{i}.y^2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 其他的变量赋值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
carCompanyPos.x = 0;
carCompanyPos.y = 0;
productNeed = zeros(recSpotNum, wareHouseNum);
productNeed(1,:) = [3, 2, 3, 0];
productNeed(2,:) = [2, 2, 0, 2];
% store = zeros(1, wareHouseNum);
store = [5, 4, 3, 2];
parameter.b1 = 0.4;
parameter.b2 = 0.9;
parameter.alpha = 1.2;
carInformation.maxLoad = 4;
carInformation.num = 4;


[results]=smallLogisticsNetwork(wareHouseNum, recSpotNum, carCompanyPos, DcarToSpot, D, productNeed, store, parameter, carInformation)
% 输入参数:
% description for variable
% wareHouseNum: 仓库数量
% recSpotNum: 收货点数量
% carCompanyPos: 货车公司的位置
% DcarTospot:汽车公司到各个点之间的距离
% D: 对称矩阵，各个点之间的最短距离
% productNeed: 各个收货点对各个仓库的需求，每行代表该收货点对各货物的需求
% store: 各仓库存储量
% parameter: 包含两条界限b1,b2以及参数alpha  
% carinformation: maxLoad --- 最大载货量
%                   num   --- 车子的数量（预估的结果）     
% 输出参数result:
% result.route:细胞数组，各辆车的路径
% result.flow:细胞数组，与route对应，各辆车在各个节点上的收货/送货量
%             该量是一个矩阵