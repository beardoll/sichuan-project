% clc;clear;
K = 3;
center = zeros(K,2);
capacity = 32;

load dataset;
linehaulnum = length(datasetLx);
backhaulnum = length(datasetBx);

range = [0 100 30 100];
rowDiv = 4;
colDiv = 2;
Lx = datasetLx;
Ly = datasetLy;
Bx = datasetBx;
By = datasetBy;
KL = 3;
KB = 3;
[CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB);
[u_final] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1)
% cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)


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

