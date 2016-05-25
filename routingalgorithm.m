% clc;clear;
% 绝对定位： 比如，1 -- n表示linehaul, n+1 -- m表示backhaul
% load dataset;
function [totalcost] = routingalgorithm(dataset, option)
    % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
    %          regionrange, colDiv, rowDiv, K
    %          Lx, Ly: linehaul节点的横、纵坐标，Bx,By为backhaul
    %          demandL: linehaul节点的货物绣球，demandB为backhaul
    %          capacity: 车容量
    %          repox, repoy: 仓库的横、纵坐标
    %          regionrange: 观测的区域范围
    %          colDiv,rowDiv: 区域划分，分别代表纵向分块数和横向分块数
    %          K: 货车数量
    % option: BPPl: =1, 利用BPP算法决定汽车数量(linehaul)
    %         BPPb: =1. 利用BPP算法决定汽车数量(backhaul)
    %         cluster4b: =1，利用分簇算法对backhaul节点进行分簇
    %         cluster4l: =1，利用分簇算法对linehaul节点进行分簇
    %         AP: =1. 使用assignment problem算法
    %         draworigincluster: =1, 画初始簇分布
    %         drawbigcluster: =1，画backhaul和linehaul合并后的分簇结果
    %         drawfinalrouting: =1， 画最终路径图
    
    %%  赋值
    Lx = dataset.Lx;
    Ly = dataset.Ly;
    demandL = dataset.demandL;
    Bx = dataset.Bx;
    By = dataset.By;
    demandB = dataset.demandB;
    capacity = dataset.capacity;
    repox = dataset.repox;
    repoy = dataset.repoy;
    regionrange = dataset.regionrange;
    colDiv = dataset.colDiv;
    rowDiv = dataset.rowDiv;
    linehaulnum = length(Lx);
    backhaulnum = length(Bx);
    K = dataset.K;

    %% 首先确定应该用几辆车去运送Linehaul和Backhaul
    if option.BPPl
        KL = BPP(demandL, capacity);
    else 
        KL = K;
    end
    if option.BPPb
        KB = BPP(demandB, capacity);
    else
        KB = K;
    end

    %% 对Linehaul和Backhaul进行分簇
    % 初始化簇首
    [CHL] = detectOriginalValue(regionrange, rowDiv, colDiv, Lx, Ly, KL, repox, repoy);
    [CHB] = detectOriginalValue(regionrange, rowDiv, colDiv, Bx, By, KB, repox, repoy);


    % 分别分簇
    if option.cluster4l
        [uL, centerL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
        uL = int8(uL);
        clusterL = cell(KL);   % 每个簇的成员,1-linehaulnum   
        for i = 1:KL
            mem = find(uL((i-1)*linehaulnum+1:i*linehaulnum)==1);
            clusterL{i} = mem;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%% cluster函数相关定义 %%%%%%%%%%%%%%%%%%%%%%%%%%
    % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
    % center_ini: 簇首的初始位置
    % demand:各个数据点的货物需求
    % samplex, sampley: 数据点的x，y坐标
    % option: 分簇模式，1表示整数规划，2表示无负载约束FCM，3表示有负载约束FCM
    % 返回隶属矩阵u
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if option.cluster4b
        [uB, centerB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);
        uB = int8(uB);
        clusterB = cell(KB);   % 每个簇的成员, linehaulnum+1 - linehaulnum + backhaulnum
        for i = 1:KB
            mem = find(uB((i-1)*backhaulnum+1:i*backhaulnum)==1);
            clusterB{i} = mem+linehaulnum;
        end
    end
%     save('origincluster.mat', 'clusterL', 'clusterB');
    
    %%%%%%%%%%%%%%%%%%% 画出初始分簇情况 %%%%%%%%%%%%%%%%%
    if option.draworigincluster
        figure(1);
        drawcluster(clusterL, Lx, Ly, Bx, By, linehaulnum, regionrange);
        figure(2);
        drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% 针对Linehaul和Backhaul进行配对，形成簇
    % 首先计算Linehaul和Backhaul簇心/仓库之间的距离
    % load origincluster;
    if option.AP
        center_dist = zeros(KL, KL);
        for i = 1:KL
            for j = 1:KL
                if j <= KB    % linehaul连接backhaul
                    center_dist(i,j) = sqrt((centerL(i,1)-centerB(j,1))^2+(centerL(i,2)-centerB(j,2))^2);
                else          % linehaul直接连接仓库
                    center_dist(i,j) = sqrt((centerL(i,1) - repox)^2 + (centerL(i,2) - repoy)^2);
                end
            end
        end

        % 然后进行配对
        [assignment] = AP(center_dist);
        big_cluster = cell(linehaulnum);
        for i = 1:KL
            match = find(assignment(i,:)==1);  % 找出linehaul的簇跟谁配对
            if match <= KB  % 和backhaul配对
                big_cluster{i} = [clusterL{i};clusterB{match}];
            else            % 和repository配对
                big_cluster{i} = clusterL{i};
            end
        end
    end
%     filename = 'big_cluster.mat';
%     save(filename, 'big_cluster');
    
    %%%%%%%%%%%%%%%% 画出合并后分簇情况 %%%%%%%%%%%%%%%%%%%
    % load big_cluster;
    if option.drawbigcluster
        figure(3);
        drawcluster(big_cluster, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    %% 对各簇内结点求最佳路径
    % load big_cluster;
    totalcost = 0;
    path = cell(KL);
    for k = 1:KL
        mem = big_cluster{k};  % 簇内成员
        memlen = length(mem);  % 簇内成员数目
        linemem = mem(find(mem<=linehaulnum)); % linehaul节点，绝对定位
        dist_spot = zeros(memlen, memlen);
        for i = 1:memlen
            dist_spot(i,i) = inf;
            for j = i+1:memlen
                if i <= length(linemem)    % 如果i是linehaul节点
                    if j <= length(linemem) % 如果j是linehaul节点
                        dist_spot(i,j) = sqrt((Lx(mem(i)) - Lx(mem(j)))^2 +...
                            (Ly(mem(i)) - Ly(mem(j)))^2);
                    else   % 如果j是backhaul节点
                        dist_spot(i,j) = sqrt((Lx(mem(i)) - Bx(mem(j)-linehaulnum))^2 +...
                            (Ly(mem(i)) - By(mem(j)-linehaulnum))^2);
                    end
                    dist_spot(j,i) = dist_spot(i,j);  % 对称性
                else  % 如果w是backhaul节点，那么v也必然是backhaul节点
                    dist_spot(i,j) = sqrt((Bx(mem(i)-linehaulnum) - Bx(mem(j)-linehaulnum))^2+...
                        (By(mem(i)-linehaulnum) - By(mem(j)-linehaulnum))^2);
                    dist_spot(j,i) = dist_spot(i,j);  % 对称性
                end
            end        
        end
        dist_repo = zeros(1,memlen);  % 仓库到各节点的距离
        for i = 1:memlen
            if i <= length(linemem) % 第i个点是linehaul节点
                dist_repo(i) = sqrt((Lx(mem(i)) - repox)^2 + (Ly(mem(i)) - repoy)^2);
            else
                dist_repo(i) = sqrt((Bx(mem(i)-linehaulnum) - repox)^2 + (By(mem(i)-linehaulnum) - repoy)^2);
            end
        end
        % [best_path] = branchbound(N, n, dist_spot, dist_repo)
        % n是linehaul的个数
        % N是节点总的个数
        % dist_spot是节点之间的相互距离（不包括仓库）
        % dist_repo是各节点到仓库的距离
        fprintf('The path for %d cluster\n',k);
%         [best_path, best_cost] = branchboundtight(memlen, length(linemem), dist_spot, dist_repo);
        [best_path, best_cost] = TSPB_intprog(memlen, length(linemem), dist_spot, dist_repo);
        totalcost = totalcost + best_cost;
        relative_pos = best_path(2:end-1);  % 第一个和最后一个节点是仓库
        best_path(2:end-1) = mem(relative_pos);  % 将路径中的标号换成绝对定位
        path{k} = best_path;
    end
%     filename = 'best_path.mat';
%     save(filename, 'path');


    %% 把路径结果给画出来
%     load big_cluster;
%     load('best_path.mat');
    if option.drawfinalrouting
        for i = 1:KL
            temp = path{i};
            path{i} = temp(2:end-1);  % 画图的path是去掉仓库节点0的
        end
        drawpicture(path, Lx, Ly, Bx, By, repox, repoy, regionrange);
    end
end


