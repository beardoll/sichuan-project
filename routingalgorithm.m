% clc;clear;
% ���Զ�λ�� ���磬1 -- n��ʾlinehaul, n+1 -- m��ʾbackhaul
% load dataset;
function [totalcost] = routingalgorithm(dataset, option)
    % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
    %          regionrange, colDiv, rowDiv, K
    %          Lx, Ly: linehaul�ڵ�ĺᡢ�����꣬Bx,ByΪbackhaul
    %          demandL: linehaul�ڵ�Ļ�������demandBΪbackhaul
    %          capacity: ������
    %          repox, repoy: �ֿ�ĺᡢ������
    %          regionrange: �۲������Χ
    %          colDiv,rowDiv: ���򻮷֣��ֱ��������ֿ����ͺ���ֿ���
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
    colDiv = dataset.colDiv;
    rowDiv = dataset.rowDiv;
    linehaulnum = length(Lx);
    backhaulnum = length(Bx);
    K = dataset.K;
    
    if option.cluster == 1  % ��һ�ִַط���
       %% ����ȷ��Ӧ���ü�����ȥ����Linehaul��Backhaul
        % �����ԣ�����backhaul����ѷ�������Ӳ�ִض����������
        KL = K;
        KB = BPP(demandB, capacity);

       %% ��Linehaul��Backhaul���зִ�
        % ��ʼ������
        [CHL] = detectOriginalValue(regionrange, rowDiv, colDiv, Lx, Ly, KL, repox, repoy);
        [CHB] = detectOriginalValue(regionrange, rowDiv, colDiv, Bx, By, KB, repox, repoy);

        % �ֱ�ִ�
        [uL, centerL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
        uL = int8(uL);
        clusterL = cell(KL);   % ÿ���صĳ�Ա,1-linehaulnum   
        for i = 1:KL
            mem = find(uL((i-1)*linehaulnum+1:i*linehaulnum)==1);
            clusterL{i} = mem;
        end

        %%%%%%%%%%%%%%%%%%%%%%%% cluster������ض��� %%%%%%%%%%%%%%%%%%%%%%%%%%
        % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
        % center_ini: ���׵ĳ�ʼλ��
        % demand:�������ݵ�Ļ�������
        % samplex, sampley: ���ݵ��x��y����
        % option: �ִ�ģʽ��1��ʾ�����滮��2��ʾ�޸���Լ��FCM��3��ʾ�и���Լ��FCM
        % ������������u
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [uB, centerB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);
        uB = int8(uB);
        clusterB = cell(KB);   % ÿ���صĳ�Ա, linehaulnum+1 - linehaulnum + backhaulnum
        for i = 1:KB
            mem = find(uB((i-1)*backhaulnum+1:i*backhaulnum)==1);
            clusterB{i} = mem+linehaulnum;
        end
    %     save('origincluster.mat', 'clusterL', 'clusterB');

        %%%%%%%%%%%%%%%%%%% ������ʼ�ִ���� %%%%%%%%%%%%%%%%%
        if option.draworigincluster
            figure(1);
            drawcluster(clusterL, Lx, Ly, Bx, By, linehaulnum, regionrange);
            figure(2);
            drawcluster(clusterB, Lx, Ly, Bx, By, linehaulnum, regionrange);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %% ���Linehaul��Backhaul������ԣ��γɴ�
        % ���ȼ���Linehaul��Backhaul����/�ֿ�֮��ľ���
        % load origincluster;
        center_dist = zeros(KL, KL);
        for i = 1:KL
            for j = 1:KL
                if j <= KB    % linehaul����backhaul
                    center_dist(i,j) = sqrt((centerL(i,1)-centerB(j,1))^2+(centerL(i,2)-centerB(j,2))^2);
                else          % linehaulֱ�����Ӳֿ�
                    center_dist(i,j) = sqrt((centerL(i,1) - repox)^2 + (centerL(i,2) - repoy)^2);
                end
            end
        end

        % Ȼ��������
        [assignment] = AP(center_dist);
        big_cluster = cell(linehaulnum);
        for i = 1:KL
            match = find(assignment(i,:)==1);  % �ҳ�linehaul�Ĵظ�˭���
            if match <= KB  % ��backhaul���
                big_cluster{i} = [clusterL{i};clusterB{match}];
            else            % ��repository���
                big_cluster{i} = clusterL{i};
            end
        end
       
        
    elseif option.cluster == 2  % ���õڶ��ִַط���
        clusterL = autocluster(demandL, Lx, Ly, capacity, K, repox, repoy);
        clusterB = autocluster(demandB, Bx, By, capacity, K, repox, repoy);
        big_cluster = cell(K);
        for i = 1:K
            big_cluster{i} = [clusterL{i}, clusterB{i}+linehaulnum];
        end                 
    end
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
                dist_spot(i,j) == inf;
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
        linemem = mem(find(mem<=linehaulnum)); % linehaul�ڵ㣬���Զ�λ
        cdist_spot = dist_spot(mem, mem);
        cdist_repo = dist_repo(mem);
        % [best_path] = branchbound(N, n, dist_spot, dist_repo)
        % n��linehaul�ĸ���
        % N�ǽڵ��ܵĸ���
        % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
        % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
        fprintf('The path for %d cluster\n',k);
%         [best_path, best_cost] = branchboundtight(memlen, length(linemem), dist_spot, dist_repo);
        [best_path, best_cost] = TSPB_intprog(memlen, length(linemem), cdist_spot, cdist_repo);
        totalcost = totalcost + best_cost;
        relative_pos = best_path(2:end-1);  % ��һ�������һ���ڵ��ǲֿ�
        best_path(2:end-1) = mem(relative_pos);  % ��·���еı�Ż��ɾ��Զ�λ
        path{k} = best_path;
    end
%     filename = 'best_path.mat';
%     save(filename, 'path','dist_spot','dist_repo', 'demandL','demandB', 'capacity');
%     load best_path
    %% local search
    % path1, path2, path3Ӧ���������ֿ�
    if option.localsearch
        % step1: insertion
        for i = 1:K
            path2 = path{i};
            path2 = path2(2:end-1);
            if i == 1
                path1 = path{K};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{K} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;
            elseif i == K
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{1};
                path3 = path3(2:end-1);
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{1} = newpath3;
            else
                path1 = path{i-1};
                path1 = path1(2:end-1);
                path3 = path{i+1};
                path3 = path3(2:end-1);
                [newpath1, newpath2, newpath3, reducecost] = insertion(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
                newpath1 = [0 newpath1 0];
                newpath2 = [0 newpath2 0];
                newpath3 = [0 newpath3 0];
                path{i-1} = newpath1;
                path{i} = newpath2;
                path{i+1} = newpath3;
            end
            totalcost = totalcost + reducecost;
            reducecost
        end
    end
    
    % step2: interchange
    for i = 1:K
        path2 = path{i};
        path2 = path2(2:end-1);
        if i == 1
            path1 = path{K};
            path1 = path1(2:end-1);
            path3 = path{i+1};
            path3 = path3(2:end-1);
            [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
            newpath1 = [0 newpath1 0];
            newpath2 = [0 newpath2 0];
            newpath3 = [0 newpath3 0];
            path{K} = newpath1;
            path{i} = newpath2;
            path{i+1} = newpath3;
        elseif i == K
            path1 = path{i-1};
            path1 = path1(2:end-1);
            path3 = path{1};
            path3 = path3(2:end-1);
            [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
            newpath1 = [0 newpath1 0];
            newpath2 = [0 newpath2 0];
            newpath3 = [0 newpath3 0];
            path{i-1} = newpath1;
            path{i} = newpath2;
            path{1} = newpath3;
        else
            path1 = path{i-1};
            path1 = path1(2:end-1);
            path3 = path{i+1};
            path3 = path3(2:end-1);
            [newpath1, newpath2, newpath3, reducecost] = interchange(path1, path2, path3, dist_spot, dist_repo, demandL, demandB, capacity);
            newpath1 = [0 newpath1 0];
            newpath2 = [0 newpath2 0];
            newpath3 = [0 newpath3 0];
            path{i-1} = newpath1;
            path{i} = newpath2;
            path{i+1} = newpath3;
        end
        totalcost = totalcost + reducecost;
        reducecost
    end

    %% ��·�������������
%     load big_cluster;
%     load('best_path.mat');
    if option.drawfinalrouting
        for i = 1:K
            temp = path{i};
            path{i} = temp(2:end-1);  % ��ͼ��path��ȥ���ֿ�ڵ�0��
        end
        drawpicture(path, Lx, Ly, Bx, By, repox, repoy, regionrange);
    end
end


