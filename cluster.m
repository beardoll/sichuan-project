function [u_final, center] = cluster(center_ini, demand, samplex, sampley, cluster_num, capacity, option)
    % center_ini: ���׵ĳ�ʼλ��
    % demand:�������ݵ�Ļ�������
    % samplex, sampley: ���ݵ��x��y����
    % option: �ִ�ģʽ��1��ʾ�����滮��2��ʾ�޸���Լ��FCM��3��ʾ�и���Լ��FCM
    % ������������u

    datanum = length(samplex);    % ���ݵ������
    K = cluster_num;              % �ִص�����
    epsilon = 10^(-4);
    gap = 1;
    center = center_ini;   
    
    while gap > epsilon 
        dist = zeros(datanum*K,1);   % �����ݵ㵽���ĵľ���
        for i = 1:length(dist)
            clusterindex = floor(i/datanum)+1;  % ��ǰ���ױ��
            if i - (clusterindex-1)*datanum == 0
                clusterindex = clusterindex - 1;
            end
            num = i - (clusterindex-1)*datanum;   % ���ݵ��λ��
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
