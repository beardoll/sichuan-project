% clc;clear;
% 绝对定位： 比如，1 -- n表示linehaul, n+1 -- m表示backhaul
% load dataset;
function [totalcost, final_path, routedemandL, routedemandB] = VRPB(dataset, option)
    % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
    %          regionrange, colDiv, rowDiv, K
    %          Lx, Ly: linehaul节点的横、纵坐标，Bx,By为backhaul
    %          demandL: linehaul节点的货物绣球，demandB为backhaul
    %          capacity: 车容量
    %          repox, repoy: 仓库的横、纵坐标
    %          regionrange: 观测的区域范围
    %          K: 货车数量
    % option: cluster: =1,使用分簇算法1.0，=2,使用分簇算法2.0
    %         draworigincluster: =1, 画初始簇分布
    %         drawbigcluster: =1，画backhaul和linehaul合并后的分簇结果
    %         drawfinalrouting: =1， 画最终路径图
    %         localsearch: =1, 使用localsearch
    
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
    linehaulnum = length(Lx);
    backhaulnum = length(Bx);
    K = dataset.K;
    totalnum = linehaulnum + backhaulnum;
    
    if option.cluster == 1  % 第一种分簇方法
       %% 首先确定应该用几辆车去运送Linehaul和Backhaul
        % 经测试，对于backhaul，最佳方案还是硬分簇而不是随意分
%         KB = BPP(demandB, capacity);

       %% 对Linehaul和Backhaul进行分簇
        % 初始化簇首
        xmax = regionrange(2);
        ymax = regionrange(4);
%         CH = Candidate(Lx, Ly, Bx, By, xmax, ymax, K);
%         save('ha','CH');
        
%         CH = zeros(K,2);
%         dp = sqrt(xmax^2+ymax^2)/2;
%         angle = 0:2*pi/K:2*(K-1)*pi/K;
%         for kk = 1:K
%             xdev = dp*cos(angle(kk));
%             ydev = dp*sin(angle(kk));
%             CH(kk,1) = repox + xdev;
%             CH(kk,2) = repoy + ydev;
%         end
        dc = sqrt((xmax/2)^2+(ymax/2)^2)/2;
        [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, K, dc, repox, repoy, capacity);

%         
%         plot([Lx, Bx], [Ly,By],'o');
%         axis([0 24000 0 32000]);
%         grid on;
%         set(gca,'xtick', 0:3000:24000, 'ytick',0:4000:32000); 
%         hold on;
%         plot(CH(:,1),CH(:,2), '*');
%         hold off;
        
        % 分簇
        clusterL = cell(K);
        clusterB = cell(K);
        [u, center] = Eulercluster(CH, linehaulnum, [demandL demandB]', [Lx Bx]', [Ly By]', K, capacity, repox, repoy);
         for i = 1:K
            memL = find(u((i-1)*totalnum+1:(i-1)*totalnum + linehaulnum)==1);
            clusterL{i} = memL;
            memB = find(u((i-1)*totalnum+linehaulnum+1:i*totalnum)==1);
            clusterB{i} = memB + linehaulnum;            
         end
         big_cluster = cell(K);
         for i = 1:K
             big_cluster{i} = [clusterL{i};clusterB{i}];
         end

        %%%%%%%%%%%%%%%%%%%%%%%% cluster函数相关定义 %%%%%%%%%%%%%%%%%%%%%%%%%%
        % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity)
        % center_ini: 簇首的初始位置
        % demand:各个数据点的货物需求
        % samplex, sampley: 数据点的x，y坐标
        % 返回隶属矩阵u
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        
    elseif option.cluster == 2  % 采用第二种分簇方法(基于幅角)
        % 分别对linehaul和backhaul进行分簇
        clusterL = Anglecluster(demandL, Lx, Ly, capacity, K, repox, repoy);  
        clusterB = Anglecluster(demandB, Bx, By, capacity, K, repox, repoy);
        big_cluster = cell(K);
        % 对簇编号相同的linehaul和backhaul簇进行组合
        for i = 1:K
            if isempty(clusterL{i}) == 1 && isempty(clusterB{i}) == 0  
                % 某个区域内只有backhaul没有linehaul
                % 则在附近拉一个linehaul过来作为簇首
                stop = 0;
                searchrange = 1;
                while stop == 0
                    if i + searchrange > K
                        rightcluster = i + searchrange - K;
                        leftcluster = i - searchrange;
                    elseif i - searchrange <= 0
                        leftcluster = i - searchrange + K;
                        rightcluster = K-1;
                    else
                        leftcluster = i - searchrange;
                        rightcluster = i + searchrange;
                    end
                    if length(clusterL{leftcluster}) == 1 && length(clusterB{leftcluster}) ~= 0 ||...
                            length(clusterL{leftcluster}) == 0
                        if  length(clusterL{rightcluster}) == 1 && length(clusterB{rightcluster}) ~= 0 ||...
                            length(clusterL{rightcluster}) == 0
                            searchrange = searchrange + 1;  % 若搜索失败则增大搜索范围
                        else
                            clustermem = clusterL{rightcluster};
                            index = randi([1 length(clustermem)]);
                            memchoice = clustermem(index);
                            clustermem(index) = [];
                            clusterL{rightcluster} = clustermem;
                            clusterL{i} = memchoice;
                            stop = 1;
                        end
                    else
                        clustermem = clusterL{leftcluster};
                        index = randi([1 length(clustermem)]);
                        memchoice = clustermem(index);
                        clustermem(index) = [];
                        clusterL{leftcluster} = clustermem;
                        clusterL{i} = memchoice;   
                        stop = 1;
                    end
                end
            end
        end
        for i = 1:K
            big_cluster{i} = [clusterL{i}, clusterB{i}+linehaulnum];  % linehaul和backhaul合并后的大簇
        end
    end
    
    %%%%%%%%%%%%%%%%%%% 画出初始分簇情况 %%%%%%%%%%%%%%%%%
    if option.draworigincluster
        figure(1);
        drawcluster(clusterL, Lx, Ly, Bx, By, linehaulnum, regionrange);
        figure(2);
        drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     filename = 'big_cluster.mat';
    %     save(filename, 'big_cluster');
    
    %%%%%%%%%%%%%%%% 画出合并后分簇情况 %%%%%%%%%%%%%%%%%%%
    % load big_cluster;
    if option.drawbigcluster
        figure(3);
        drawcluster(big_cluster, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% 计算节点之间的距离
    dist_spot = zeros(linehaulnum+backhaulnum, linehaulnum+backhaulnum);
    dist_repo = zeros(1, linehaulnum+backhaulnum);
    for i = 1:length(dist_repo)
        if i <= linehaulnum
            dist_repo(i) = sqrt((Lx(i) - repox)^2 + (Ly(i) - repoy)^2);
        else
            dist_repo(i) = sqrt((Bx(i-linehaulnum) - repox)^2 + (By(i-linehaulnum) -repoy)^2);
        end
    end
    
    for i = 1:length(dist_repo)
        for j = i:length(dist_repo)
            if i == j
                dist_spot(i,j) = inf;
            else
                if i<=linehaulnum
                    if j <= linehaulnum
                        dist_spot(i,j) = sqrt((Lx(i) - Lx(j))^2 + (Ly(i) - Ly(j))^2);
                    else
                        dist_spot(i,j) = sqrt((Lx(i) - Bx(j-linehaulnum))^2 + (Ly(i) - By(j-linehaulnum))^2);
                    end
                else
                    dist_spot(i,j) = sqrt((Bx(i-linehaulnum) - Bx(j-linehaulnum))^2 + (By(i-linehaulnum) - By(j-linehaulnum))^2);
                end
            end
            dist_spot(j,i) = dist_spot(i,j);
        end
    end
    
    %% 对各簇内结点求最佳路径
    % load big_cluster;
    totalcost = 0;
    path = cell(K);
    for k = 1:K
        mem = big_cluster{k};  % 簇内成员
        memlen = length(mem);  % 簇内成员数目
        if memlen == 0   % 空路径
            path{k} = [0 0];
        else
            save('haha.mat', 'mem','linehaulnum', 'big_cluster','k');
            linemem = mem(find(mem<=linehaulnum)); % linehaul节点，绝对定位
            cdist_spot = dist_spot(mem, mem);  % 当前顾客节点间的距离
            cdist_repo = dist_repo(mem);       % 当前顾客节点与仓库之间的距离
            fprintf('The path for %d cluster\n',k);
            [best_path, best_cost] = TSPB_intprog(memlen, length(linemem), cdist_spot, cdist_repo);
            totalcost = totalcost + best_cost;
            relative_pos = best_path(2:end-1);  % 第一个和最后一个节点是仓库
            best_path(2:end-1) = mem(relative_pos);  % 将路径中的标号换成绝对定位
            path{k} = best_path;
        end
    end
    
%     filename = 'best_path.mat';
%     save(filename, 'path','dist_spot','dist_repo', 'demandL','demandB', 'capacity');
%     load best_path
%     save('pp','path', 'dist_spot','dist_repo', 'demandL', 'demandB', 'capacity');
    
    %% local search
    routedemandL = 0;
    routedemandB = 0;
    if option.localsearch==1 && option.cluster == 2   % 仅幅角分簇可用的local search
            % path1, path2, path3应当不包括仓库
            % step1: insertion
         [newpath, totalreducecost] = neiborlocalsearch(path, dist_spot, dist_repo, demandL, demandB, capacity, K);
         path = newpath;
         totalcost = totalcost + totalreducecost;
    end
    
    if option.localsearch == 1 && option.cluster == 1    % 任何分簇算法都可以使用的local sesearch
        [route, reducecost, routedemandL, routedemandB] = localsearch(dist_repo, dist_spot, demandL, demandB, capacity, path);   
        path = route;
        totalcost = totalcost + reducecost;
    end

    final_path = path;
    %% 把路径结果给画出来
%     load big_cluster;
%     load('best_path.mat');
    if option.drawfinalrouting
        for i = 1:K
            temp = path{i};
            if length(temp) == 2
                path{i} = [];
            else
                path{i} = temp(2:end-1);  % 画图的path是去掉仓库节点0的
            end
        end
        drawfinalroute(path, Lx, Ly, Bx, By, repox, repoy, regionrange);
    end
end


