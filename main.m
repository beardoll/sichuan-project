clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ������� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �����ı�����ֵ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% �������:
% description for variable
% wareHouseNum: �ֿ�����
% recSpotNum: �ջ�������
% carCompanyPos: ������˾��λ��
% DcarTospot:������˾��������֮��ľ���
% D: �Գƾ��󣬸�����֮�����̾���
% productNeed: �����ջ���Ը����ֿ������ÿ�д�����ջ���Ը����������
% store: ���ֿ�洢��
% parameter: ������������b1,b2�Լ�����alpha  
% carinformation: maxLoad --- ����ػ���
%                   num   --- ���ӵ�������Ԥ���Ľ����     
% �������result:
% result.route:ϸ�����飬��������·��
% result.flow:ϸ�����飬��route��Ӧ���������ڸ����ڵ��ϵ��ջ�/�ͻ���
%             ������һ������