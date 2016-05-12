% clc;clear;
load dataset;
linehaulnum = length(datasetLx);
backhaulnum = length(datasetBx);
capacity = 32;

%% 首先确定应该用几辆车去运送Linehaul和Backhaul
KL = 5;
KB = 3;

%% 对Linehaul和Backhaul进行分簇
Lx = datasetLx;
Ly = datasetLy;
Bx = datasetBx;
By = datasetBy;

% 初始化簇首
range = [0 100 30 100];
rowDiv = 4;
colDiv = 2;
[CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB);

% 分别分簇
[uL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
% cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
% center_ini: 簇首的初始位置
% demand:各个数据点的货物需求
% samplex, sampley: 数据点的x，y坐标
% option: 分簇模式，1表示整数规划，2表示无负载约束FCM，3表示有负载约束FCM
% 返回隶属矩阵u
% [uB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);

%% 针对Linehaul和Backhaul进行配对，形成簇

%% 对各簇内结点求最佳路径





% allocation
% for k = 1:datanum
%     spot = find(u==max(u));
%     

% for i = 1:datanum
%     type = find(Umatrix(i,:) == max(Umatrix(i,:)));
%     k_demand(type) = k_demand(type)+demand(i);
%     switch type
%         case 1  
%             plot(dataset(i,1),dataset(i,2),'ro');
%             axis([0 100 0 100]);
%             hold on;            
%         case 2 
%             plot(dataset(i,1),dataset(i,2),'go');
%             hold on;
%         case 3 
%             plot(dataset(i,1),dataset(i,2),'bo');
%             hold on;
%     end
% end
% 
% plot(center(1,1),center(1,2),'r*');
% plot(center(2,1),center(2,2),'g*');
% plot(center(3,1),center(3,2),'b*');
% k_demand


%%%%%%%%%%%%%%%%%%%%%%% 画簇首初始分布 %%%%%%%%%%%%%%%%%%%
% for i=1:linehaulnum
%     plot(datasetLx(i),datasetLy(i),'ro');
%     axis([0 100 0 100]);
%     hold on;
% end
% 
% for i=1:backhaulnum
%     plot(datasetBx(i),datasetBy(i),'go');
%     axis([0 100 0 100]);
%     hold on;
% end
% 
% for i = 1:KL
%     plot(CHL(i,1),CHL(i,2),'r*');
%     axis([0 100 0 100]);
%     hold on;
% end
% 
% for i = 1:KB
%     plot(CHB(i,1),CHB(i,2),'g*');
%     axis([0 100 0 100]);
%     hold on;
% end
% hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

