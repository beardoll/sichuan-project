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
    % option: BPPl: =1, ����BPP�㷨������������(linehaul)
    %         BPPb: =1. ����BPP�㷨������������(backhaul)
    %         cluster4b: =1�����÷ִ��㷨��backhaul�ڵ���зִ�
    %         cluster4l: =1�����÷ִ��㷨��linehaul�ڵ���зִ�
    %         AP: =1. ʹ��assignment problem�㷨
    %         draworigincluster: =1, ����ʼ�طֲ�
    %         drawbigcluster: =1����backhaul��linehaul�ϲ���ķִؽ��
    %         drawfinalrouting: =1�� ������·��ͼ
    
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

    %% ����ȷ��Ӧ���ü�����ȥ����Linehaul��Backhaul
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

    %% ��Linehaul��Backhaul���зִ�
    % ��ʼ������
    [CHL] = detectOriginalValue(regionrange, rowDiv, colDiv, Lx, Ly, KL, repox, repoy);
    [CHB] = detectOriginalValue(regionrange, rowDiv, colDiv, Bx, By, KB, repox, repoy);


    % �ֱ�ִ�
    if option.cluster4l
        [uL, centerL] = cluster(CHL, demandL, Lx, Ly, KL, capacity, 1);
        uL = int8(uL);
        clusterL = cell(KL);   % ÿ���صĳ�Ա,1-linehaulnum   
        for i = 1:KL
            mem = find(uL((i-1)*linehaulnum+1:i*linehaulnum)==1);
            clusterL{i} = mem;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%% cluster������ض��� %%%%%%%%%%%%%%%%%%%%%%%%%%
    % cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
    % center_ini: ���׵ĳ�ʼλ��
    % demand:�������ݵ�Ļ�������
    % samplex, sampley: ���ݵ��x��y����
    % option: �ִ�ģʽ��1��ʾ�����滮��2��ʾ�޸���Լ��FCM��3��ʾ�и���Լ��FCM
    % ������������u
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if option.cluster4b
        [uB, centerB] = cluster(CHB, demandB, Bx, By, KB, capacity, 1);
        uB = int8(uB);
        clusterB = cell(KB);   % ÿ���صĳ�Ա, linehaulnum+1 - linehaulnum + backhaulnum
        for i = 1:KB
            mem = find(uB((i-1)*backhaulnum+1:i*backhaulnum)==1);
            clusterB{i} = mem+linehaulnum;
        end
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
    if option.AP
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
                
    %% �Ը����ڽ�������·��
    % load big_cluster;
    totalcost = 0;
    path = cell(KL);
    for k = 1:KL
        mem = big_cluster{k};  % ���ڳ�Ա
        memlen = length(mem);  % ���ڳ�Ա��Ŀ
        linemem = mem(find(mem<=linehaulnum)); % linehaul�ڵ㣬���Զ�λ
        dist_spot = zeros(memlen, memlen);
        for i = 1:memlen
            dist_spot(i,i) = inf;
            for j = i+1:memlen
                if i <= length(linemem)    % ���i��linehaul�ڵ�
                    if j <= length(linemem) % ���j��linehaul�ڵ�
                        dist_spot(i,j) = sqrt((Lx(mem(i)) - Lx(mem(j)))^2 +...
                            (Ly(mem(i)) - Ly(mem(j)))^2);
                    else   % ���j��backhaul�ڵ�
                        dist_spot(i,j) = sqrt((Lx(mem(i)) - Bx(mem(j)-linehaulnum))^2 +...
                            (Ly(mem(i)) - By(mem(j)-linehaulnum))^2);
                    end
                    dist_spot(j,i) = dist_spot(i,j);  % �Գ���
                else  % ���w��backhaul�ڵ㣬��ôvҲ��Ȼ��backhaul�ڵ�
                    dist_spot(i,j) = sqrt((Bx(mem(i)-linehaulnum) - Bx(mem(j)-linehaulnum))^2+...
                        (By(mem(i)-linehaulnum) - By(mem(j)-linehaulnum))^2);
                    dist_spot(j,i) = dist_spot(i,j);  % �Գ���
                end
            end        
        end
        dist_repo = zeros(1,memlen);  % �ֿ⵽���ڵ�ľ���
        for i = 1:memlen
            if i <= length(linemem) % ��i������linehaul�ڵ�
                dist_repo(i) = sqrt((Lx(mem(i)) - repox)^2 + (Ly(mem(i)) - repoy)^2);
            else
                dist_repo(i) = sqrt((Bx(mem(i)-linehaulnum) - repox)^2 + (By(mem(i)-linehaulnum) - repoy)^2);
            end
        end
        % [best_path] = branchbound(N, n, dist_spot, dist_repo)
        % n��linehaul�ĸ���
        % N�ǽڵ��ܵĸ���
        % dist_spot�ǽڵ�֮����໥���루�������ֿ⣩
        % dist_repo�Ǹ��ڵ㵽�ֿ�ľ���
        fprintf('The path for %d cluster\n',k);
%         [best_path, best_cost] = branchboundtight(memlen, length(linemem), dist_spot, dist_repo);
        [best_path, best_cost] = TSPB_intprog(memlen, length(linemem), dist_spot, dist_repo);
        totalcost = totalcost + best_cost;
        relative_pos = best_path(2:end-1);  % ��һ�������һ���ڵ��ǲֿ�
        best_path(2:end-1) = mem(relative_pos);  % ��·���еı�Ż��ɾ��Զ�λ
        path{k} = best_path;
    end
%     filename = 'best_path.mat';
%     save(filename, 'path');


    %% ��·�������������
%     load big_cluster;
%     load('best_path.mat');
    if option.drawfinalrouting
        for i = 1:KL
            temp = path{i};
            path{i} = temp(2:end-1);  % ��ͼ��path��ȥ���ֿ�ڵ�0��
        end
        drawpicture(path, Lx, Ly, Bx, By, repox, repoy, regionrange);
    end
end


