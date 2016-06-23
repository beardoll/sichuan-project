% clc;clear;
% ���Զ�λ�� ���磬1 -- n��ʾlinehaul, n+1 -- m��ʾbackhaul
% load dataset;
function [totalcost, final_path, routedemandL, routedemandB] = VRPB(dataset, option)
    % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
    %          regionrange, colDiv, rowDiv, K
    %          Lx, Ly: linehaul�ڵ�ĺᡢ�����꣬Bx,ByΪbackhaul
    %          demandL: linehaul�ڵ�Ļ�������demandBΪbackhaul
    %          capacity: ������
    %          repox, repoy: �ֿ�ĺᡢ������
    %          regionrange: �۲������Χ
    %          K: ��������
    % option: cluster: =1,ʹ�÷ִ��㷨1.0��=2,ʹ�÷ִ��㷨2.0
    %         draworigincluster: =1, ����ʼ�طֲ�
    %         drawbigcluster: =1����backhaul��linehaul�ϲ���ķִؽ��
    %         drawfinalrouting: =1�� ������·��ͼ
    %         localsearch: =1, ʹ��localsearch
    
    %%  ��ֵ
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
    
    if option.cluster == 1  % ��һ�ִַط���
       %% ����ȷ��Ӧ���ü�����ȥ����Linehaul��Backhaul
        % �����ԣ�����backhaul����ѷ�������Ӳ�ִض����������
%         KB = BPP(demandB, capacity);

       %% ��Linehaul��Backhaul���зִ�
        % ��ʼ������
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
        
        % �ִ�
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

        %%%%%%%%%%%%%%%%%%%%%%%% cluster������ض��� %%%%%%%%%%%%%%%%%%%%%%%%%%
        % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity)
        % center_ini: ���׵ĳ�ʼλ��
        % demand:�������ݵ�Ļ�������
        % samplex, sampley: ���ݵ��x��y����
        % ������������u
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        
    elseif option.cluster == 2  % ���õڶ��ִַط���(���ڷ���)
        % �ֱ��linehaul��backhaul���зִ�
        clusterL = Anglecluster(demandL, Lx, Ly, capacity, K, repox, repoy);  
        clusterB = Anglecluster(demandB, Bx, By, capacity, K, repox, repoy);
        big_cluster = cell(K);
        % �Դر����ͬ��linehaul��backhaul�ؽ������
        for i = 1:K
            if isempty(clusterL{i}) == 1 && isempty(clusterB{i}) == 0  
                % ĳ��������ֻ��backhaulû��linehaul
                % ���ڸ�����һ��linehaul������Ϊ����
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
                            searchrange = searchrange + 1;  % ������ʧ��������������Χ
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
            big_cluster{i} = [clusterL{i}, clusterB{i}+linehaulnum];  % linehaul��backhaul�ϲ���Ĵ��
        end
    end
    
    %%%%%%%%%%%%%%%%%%% ������ʼ�ִ���� %%%%%%%%%%%%%%%%%
    if option.draworigincluster
        figure(1);
        drawcluster(clusterL, Lx, Ly, Bx, By, linehaulnum, regionrange);
        figure(2);
        drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     filename = 'big_cluster.mat';
    %     save(filename, 'big_cluster');
    
    %%%%%%%%%%%%%%%% �����ϲ���ִ���� %%%%%%%%%%%%%%%%%%%
    % load big_cluster;
    if option.drawbigcluster
        figure(3);
        drawcluster(big_cluster, Lx, Ly, Bx, By, linehaulnum, regionrange);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% ����ڵ�֮��ľ���
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
    
    %% �Ը����ڽ�������·��
    % load big_cluster;
    totalcost = 0;
    path = cell(K);
    for k = 1:K
        mem = big_cluster{k};  % ���ڳ�Ա
        memlen = length(mem);  % ���ڳ�Ա��Ŀ
        if memlen == 0   % ��·��
            path{k} = [0 0];
        else
            save('haha.mat', 'mem','linehaulnum', 'big_cluster','k');
            linemem = mem(find(mem<=linehaulnum)); % linehaul�ڵ㣬���Զ�λ
            cdist_spot = dist_spot(mem, mem);  % ��ǰ�˿ͽڵ��ľ���
            cdist_repo = dist_repo(mem);       % ��ǰ�˿ͽڵ���ֿ�֮��ľ���
            fprintf('The path for %d cluster\n',k);
            [best_path, best_cost] = TSPB_intprog(memlen, length(linemem), cdist_spot, cdist_repo);
            totalcost = totalcost + best_cost;
            relative_pos = best_path(2:end-1);  % ��һ�������һ���ڵ��ǲֿ�
            best_path(2:end-1) = mem(relative_pos);  % ��·���еı�Ż��ɾ��Զ�λ
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
    if option.localsearch==1 && option.cluster == 2   % �����Ƿִؿ��õ�local search
            % path1, path2, path3Ӧ���������ֿ�
            % step1: insertion
         [newpath, totalreducecost] = neiborlocalsearch(path, dist_spot, dist_repo, demandL, demandB, capacity, K);
         path = newpath;
         totalcost = totalcost + totalreducecost;
    end
    
    if option.localsearch == 1 && option.cluster == 1    % �κηִ��㷨������ʹ�õ�local sesearch
        [route, reducecost, routedemandL, routedemandB] = localsearch(dist_repo, dist_spot, demandL, demandB, capacity, path);   
        path = route;
        totalcost = totalcost + reducecost;
    end

    final_path = path;
    %% ��·�������������
%     load big_cluster;
%     load('best_path.mat');
    if option.drawfinalrouting
        for i = 1:K
            temp = path{i};
            if length(temp) == 2
                path{i} = [];
            else
                path{i} = temp(2:end-1);  % ��ͼ��path��ȥ���ֿ�ڵ�0��
            end
        end
        drawfinalroute(path, Lx, Ly, Bx, By, repox, repoy, regionrange);
    end
end


