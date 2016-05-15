% % clc;clear;
load dataset;
linehaulnum = length(datasetLx);
backhaulnum = length(datasetBx);
capacity = 32;
% 仓库的坐标
repox = 50;
repoy = 0;

%% 首先确定应该用几辆车去运送Linehaul和Backhaul
KL = BPP(demandL, capacity);
KB = BPP(demandB, capacity);

%% 对Linehaul和Backhaul进行分簇
Lx = datasetLx;
Ly = datasetLy;
Bx = datasetBx;
By = datasetBy;

% % 初始化簇首
% range = [0 100 30 100];
% rowDiv = 4;
% colDiv = 2;
% [CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB);
% 
% % 分别分簇
% [uL, centerL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
% clusterL = cell(KL);   % 每个簇的成员,1-linehaulnum
% for i = 1:KL
%     mem = find(uL((i-1)*linehaulnum+1:i*linehaulnum)==1);
%     clusterL{i} = mem;
% end
% % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
% % center_ini: 簇首的初始位置
% % demand:各个数据点的货物需求
% % samplex, sampley: 数据点的x，y坐标
% % option: 分簇模式，1表示整数规划，2表示无负载约束FCM，3表示有负载约束FCM
% % 返回隶属矩阵u
% [uB, centerB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);
% clusterB = cell(KB);   % 每个簇的成员, linehaulnum+1 - linehaulnum + backhaulnum
% for i = 1:KB
%     mem = find(uB((i-1)*backhaulnum+1:i*backhaulnum)==1);
%     clusterB{i} = mem+linehaulnum;
% end
% save('origincluster.mat', 'clusterL', 'clusterB');

%%%%%%%%%%%%%%%%%%% 画出分簇情况 %%%%%%%%%%%%%%%%%
% load origincluster;
% drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 针对Linehaul和Backhaul进行配对，形成簇
% % 首先计算Linehaul和Backhaul簇心/仓库之间的距离
% load origincluster;
% straight_connect = KL-KB;
% center_dist = zeros(KL, KL);
% for i = 1:KL
%     for j = 1:KL
%         if j <= KB
%             center_dist(i,j) = (centerL(i,1)-centerB(j,1))^2+(centerL(i,2)-centerB(j,2))^2;
%         else
%             center_dist(i,j) = (centerL(i,1) - repox)^2 + (centerL(i,2) - repoy)^2;
%         end
%     end
% end
% 
% % 然后进行配对
% [assignment] = AP(center_dist);
% big_cluster = cell(linehaulnum);
% for i = 1:KL
%     match = find(assignment(i,:)==1);  % 找出linehaul的簇跟谁配对
%     if match <= KB  % 和backhaul配对
%         big_cluster{i} = [clusterL{i};clusterB{match}];
%     else            % 和repository配对
%         big_cluster{i} = clusterL{i};
%     end
% end
% filename = 'big_cluster.mat';
% save(filename, 'big_cluster');

%%%%%%%%%%%%%%%% 画出分簇情况 %%%%%%%%%%%%%%%%%%%
% load big_cluster;
% drawcluster(big_cluster, Lx, Ly, Bx, By, linehaulnum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load big_cluster;            
% %% 对各簇内结点求最佳路径
% path = cell(KL);
% for k = 1:KL
%     mem = big_cluster{k};  % 簇内成员
%     memlen = length(mem);  % 簇内成员数目
%     linemem = mem(find(mem<=linehaulnum)); % linehaul节点，绝对定位
%     backmem = setdiff(mem, linemem);  % backhaul节点，绝对定位
%     dist_spot = zeros(memlen, memlen);
%     for i = 1:memlen
%         dist_spot(i,i) = inf;
%         for j = i+1:memlen
%             if i <= length(linemem)    % 如果i是linehaul节点
%                 if j <= length(linemem) % 如果j是linehaul节点
%                     dist_spot(i,j) = (Lx(mem(i)) - Lx(mem(j)))^2 +...
%                         (Ly(mem(i)) - Ly(mem(j)))^2;
%                 else   % 如果j是backhaul节点
%                     dist_spot(i,j) = (Lx(mem(i)) - Bx(mem(j)-linehaulnum))^2 +...
%                         (Ly(mem(i)) - By(mem(j)-linehaulnum))^2;
%                 end
%                 dist_spot(j,i) = dist_spot(i,j);  % 对称性
%             else  % 如果w是backhaul节点，那么v也必然是backhaul节点
%                 dist_spot(i,j) = (Bx(mem(i)-linehaulnum) - Bx(mem(j)-linehaulnum))^2+...
%                     (By(mem(i)-linehaulnum) - By(mem(j)-linehaulnum))^2;
%                 dist_spot(j,i) = dist_spot(i,j);  % 对称性
%             end
%         end        
%     end
%     dist_repo = zeros(1,memlen);  % 仓库到各节点的距离
%     for i = 1:memlen
%         if i <= length(linemem) % 第i个点是linehaul节点
%             dist_repo(i) = (Lx(mem(i)) - repox)^2 + (Ly(mem(i)) - repoy)^2;
%         else
%             dist_repo(i) = (Bx(mem(i)-linehaulnum) - repox)^2 + (By(mem(i)-linehaulnum) - repoy)^2;
%         end
%     end
%     % [best_path] = branchbound(N, n, dist_spot, dist_repo)
%     % n是linehaul的个数
%     % N是节点总的个数
%     % dist_spot是节点之间的相互距离（不包括仓库）
%     % dist_repo是各节点到仓库的距离
%     fprintf('The %d iteration\n',k);
%     dist_repo
%     dist_spot
%     [best_path, best_cost] = branchboundtight(memlen, length(linemem), dist_spot, dist_repo);
%     relative_pos = best_path(2:1+memlen);  % 第一个和最后一个节点是仓库
%     bestpath(2:1+memlen) = mem(relative_pos);
%     path{k} = best_path;
% end
% filename = 'best_path.mat';
% save(filename, 'path');


%% 把路径结果给画出来
load('best_path.mat');
for i = 1:KL
    temp = path{i};
    mem = big_cluster{i};  % 簇内成员
    path{i} = mem(temp(2:end-1));
end
drawpicture(path, Lx, Ly, Bx, By, repox, repoy);


