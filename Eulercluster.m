function [u_final, center] = Eulercluster(center_ini, n, demand, samplex, sampley, cluster_num, capacity, repox, repoy)
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
        
        CH_angle = computeAngle(center(:,1),center(:,2),repox,repoy);
        cus_angle = computeAngle(samplex, sampley, repox, repoy);
        
        
        dist = zeros(datanum*K,1);   % �����ݵ㵽���ĵľ���
        for i = 1:length(dist)
            clusterindex = floor(i/datanum)+1;  % ��ǰ���ױ��
            if i - (clusterindex-1)*datanum == 0
                clusterindex = clusterindex - 1;
            end
            num = i - (clusterindex-1)*datanum;   % ���ݵ��λ��
            dist(i) = (samplex(num)-center(clusterindex,1))^2+(sampley(num)-center(clusterindex,2))^2 + ...
                (samplex(num) - repox)^2 + (sampley(num) - repoy)^2 + (center(clusterindex,1) - repox)^2 + ...
                (center(clusterindex,2) - repoy)^2+100000*abs(cus_angle(num)-CH_angle(clusterindex));
        end   
        K;
        u_new = FCM_integer(n, datanum, dist,K, capacity, demand);
        u = u_new;
        newcenter = zeros(K,2);
        for i = 1:K
            newcenter(i,1) = sum(u((i-1)*datanum+1:i*datanum).*(samplex+repox)/2)/sum(u((i-1)*datanum+1:i*datanum));   % ���´���
            newcenter(i,2) = sum(u((i-1)*datanum+1:i*datanum).*(sampley+repoy)/2)/sum(u((i-1)*datanum+1:i*datanum));
        end
        gap = sum(sum((center-newcenter).^2));
        center = newcenter;
    end
    u_final = u;
end