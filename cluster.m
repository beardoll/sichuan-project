function [u_final, center] = cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
    % center_ini: 簇首的初始位置
    % demand:各个数据点的货物需求
    % samplex, sampley: 数据点的x，y坐标
    % option: 分簇模式，1表示整数规划，2表示无负载约束FCM，3表示有负载约束FCM
    % 返回隶属矩阵u

    datanum = length(samplex);    % 数据点的数量
    K = cluster_num;              % 分簇的数量
    epsilon = 10^(-4);
    gap = 1;
    center = center_ini;   
    
    while gap > epsilon 
        dist = zeros(datanum*K,1);   % 各数据点到簇心的距离
        for i = 1:length(dist)
            clusterindex = floor(i/datanum)+1;  % 当前簇首编号
            if i - (clusterindex-1)*datanum == 0
                clusterindex = clusterindex - 1;
            end
            num = i - (clusterindex-1)*datanum;   % 数据点的位置
            dist(i) = (samplex(num)-center(clusterindex,1))^2+(sampley(num)-center(clusterindex,2))^2;
        end   
        K;
        switch option
            case 1
                u_new = FCM_integer(datanum, dist,K, capacity, demand);
            case 2
                u_new = FCM_noconstraint(datanum, K, dist);
            case 3             
                u_new = FCM_inner(dist,C,capacity,demand);
        end
        u = u_new;
        newcenter = zeros(K,2);
        for i = 1:K
            newcenter(i,1) = sum(u((i-1)*datanum+1:i*datanum).^2.*samplex)/sum(u((i-1)*datanum+1:i*datanum).^2);
            newcenter(i,2) = sum(u((i-1)*datanum+1:i*datanum).^2.*sampley)/sum(u((i-1)*datanum+1:i*datanum).^2);
        end
        gap = sum(sum((center-newcenter).^2));
        center = newcenter;
    end
    u_final = u;
end
