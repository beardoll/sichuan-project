% % clc;clear;
load dataset;
linehaulnum = length(datasetLx);
backhaulnum = length(datasetBx);
capacity = 32;
% �ֿ������
repox = 50;
repoy = 0;

%% ����ȷ��Ӧ���ü�����ȥ����Linehaul��Backhaul
KL = BPP(demandL, capacity);
KB = BPP(demandB, capacity);

%% ��Linehaul��Backhaul���зִ�
Lx = datasetLx;
Ly = datasetLy;
Bx = datasetBx;
By = datasetBy;

% % ��ʼ������
% range = [0 100 30 100];
% rowDiv = 4;
% colDiv = 2;
% [CHL, CHB] = detectOriginalValue(range, rowDiv, colDiv, Lx, Ly, Bx, By, KL, KB);
% 
% % �ֱ�ִ�
% [uL, centerL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
% clusterL = cell(KL);   % ÿ���صĳ�Ա,1-linehaulnum
% for i = 1:KL
%     mem = find(uL((i-1)*linehaulnum+1:i*linehaulnum)==1);
%     clusterL{i} = mem;
% end
% % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
% % center_ini: ���׵ĳ�ʼλ��
% % demand:�������ݵ�Ļ�������
% % samplex, sampley: ���ݵ��x��y����
% % option: �ִ�ģʽ��1��ʾ�����滮��2��ʾ�޸���Լ��FCM��3��ʾ�и���Լ��FCM
% % ������������u
% [uB, centerB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);
% clusterB = cell(KB);   % ÿ���صĳ�Ա, linehaulnum+1 - linehaulnum + backhaulnum
% for i = 1:KB
%     mem = find(uB((i-1)*backhaulnum+1:i*backhaulnum)==1);
%     clusterB{i} = mem+linehaulnum;
% end
% save('origincluster.mat', 'clusterL', 'clusterB');

%%%%%%%%%%%%%%%%%%% �����ִ���� %%%%%%%%%%%%%%%%%
% load origincluster;
% drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ���Linehaul��Backhaul������ԣ��γɴ�
% % ���ȼ���Linehaul��Backhaul����/�ֿ�֮��ľ���
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
% % Ȼ��������
% [assignment] = AP(center_dist);
% big_cluster = cell(linehaulnum);
% for i = 1:KL
%     match = find(assignment(i,:)==1);  % �ҳ�linehaul�Ĵظ�˭���
%     if match <= KB  % ��backhaul���
%         big_cluster{i} = [clusterL{i};clusterB{match}];
%     else            % ��repository���
%         big_cluster{i} = clusterL{i};
%     end
% end
% filename = 'big_cluster.mat';
% save(filename, 'big_cluster');

%%%%%%%%%%%%%%%% �����ִ���� %%%%%%%%%%%%%%%%%%%
% load big_cluster;
% drawcluster(big_cluster, Lx, Ly, Bx, By, linehaulnum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load big_cluster;            
% %% �Ը����ڽ�������·��
% path = cell(KL);
% for k = 1:KL
%     mem = big_cluster{k};  % ���ڳ�Ա
%     memlen = length(mem);  % ���ڳ�Ա��Ŀ
%     linemem = mem(find(mem<=linehaulnum)); % linehaul�ڵ㣬���Զ�λ
%     backmem = setdiff(mem, linemem);  % backhaul�ڵ㣬���Զ�λ
%     dist_spot = zeros(memlen, memlen);
%     for i = 1:memlen
%         dist_spot(i,i) = inf;
%         for j = i+1:memlen
%             if i <= length(linemem)    % ���i��linehaul�ڵ�
%                 if j <= length(linemem) % ���j��linehaul�ڵ�
%                     dist_spot(i,j) = (Lx(mem(i)) - Lx(mem(j)))^2 +...
%                         (Ly(mem(i)) - Ly(mem(j)))^2;
%                 else   % ���j��backhaul�ڵ�
%                     dist_spot(i,j) = (Lx(mem(i)) - Bx(mem(j)-linehaulnum))^2 +...
%                         (Ly(mem(i)) - By(mem(j)-linehaulnum))^2;
%                 end
%                 dist_spot(j,i) = dist_spot(i,j);  % �Գ���
%             else  % ���w��backhaul�ڵ㣬��ôvҲ��Ȼ��backhaul�ڵ�
%                 dist_spot(i,j) = (Bx(mem(i)-linehaulnum) - Bx(mem(j)-linehaulnum))^2+...
%                     (By(mem(i)-linehaulnum) - By(mem(j)-linehaulnum))^2;
%                 dist_spot(j,i) = dist_spot(i,j);  % �Գ���
%             end
%         end        
%     end
%     dist_repo = zeros(1,memlen);  % �ֿ⵽���ڵ�ľ���
%     for i = 1:memlen
%         if i <= length(linemem) % ��i������linehaul�ڵ�
%             dist_repo(i) = (Lx(mem(i)) - repox)^2 + (Ly(mem(i)) - repoy)^2;
%         else
%             dist_repo(i) = (Bx(mem(i)-linehaulnum) - repox)^2 + (By(mem(i)-linehaulnum) - repoy)^2;
%         end
%     end
%     % [best_path] = branchbound(N, n, dist_spot, dist_repo)
%     % n��linehaul�ĸ���
%     % N�ǽڵ��ܵĸ���
%     % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
%     % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
%     fprintf('The %d iteration\n',k);
%     dist_repo
%     dist_spot
%     [best_path, best_cost] = branchboundtight(memlen, length(linemem), dist_spot, dist_repo);
%     relative_pos = best_path(2:1+memlen);  % ��һ�������һ���ڵ��ǲֿ�
%     bestpath(2:1+memlen) = mem(relative_pos);
%     path{k} = best_path;
% end
% filename = 'best_path.mat';
% save(filename, 'path');


%% ��·�������������
load('best_path.mat');
for i = 1:KL
    temp = path{i};
    mem = big_cluster{i};  % ���ڳ�Ա
    path{i} = mem(temp(2:end-1));
end
drawpicture(path, Lx, Ly, Bx, By, repox, repoy);


