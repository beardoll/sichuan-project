function [CH] = Candidate2(Lx, Ly, Bx, By, demandL, demandB, K, dc, repox, repoy)
    % ���÷��Ǿ�������ʼ������λ��
    alpha1 = sum(demandL)/K;   % ÿ��Linehaul�ص�ƽ��������
    alpha2 = sum(demandB)/K;   % ÿ��backhaul�ص�ƽ��������
    linehaulnum = length(Lx);
    backhaulnum = length(Bx);
    line_angle = computeAngle(Lx, Ly, repox, repoy);   % linehaul�ڵ�ķ���
    back_angle = computeAngle(Bx, By, repox, repoy);   % backhaul�ڵ�ķ���
    cus_angle = [line_angle, back_angle];               % ���й˿ͽڵ�ķ���
    angledist = zeros(linehaulnum+backhaulnum, linehaulnum+backhaulnum); % �˿ͽڵ�֮��ķ��Ǿ���
    cluster = cell(K);   % һ��K����
    for i = 1:K
        cluster{i} = [];
    end
    for i = 1:linehaulnum + backhaulnum
        angledist(i,i) = inf;
        for j = i+1:linehaulnum + backhaulnum
            angledist(i,j) = cus_angle(i) - cus_angle(j);  % ���Ƕȱ�ʾj�ķ��Ǳ�i�ķ���С
            angledist(j,i) = -angledist(i,j);
        end
    end
    m = find(cus_angle == min(cus_angle));
    n = find(cus_angle == max(cus_angle));
    angledist(m,n) = 2*pi - max(cus_angle) + min(cus_angle);
    angledist(n,m) = -angledist(m,n);
    
    
    option = 1:linehaulnum + backhaulnum;
    choice = option(randi(length(option)));
    bigcluster = cell(K);
    k = 1;
    cluster = [choice];   % ��ǰ�س�Ա
    border = [choice, choice];  % �ص������߽��Ա
    if choice <= linehaulnum
        dL = demandL(choice);  % ����linehaul��������
        dB = 0;  % ����backhaul��������
    else
        dL = 0;
        dB = demandB(choice - linehaulnum);
    end
    stop1 = 0;
    stop2 = 0;
    stop = 0;
    while stop == 0
%         candidatedraw(cluster, Lx, Ly, Bx, By, linehaulnum);
        cdist1 = angledist(border(1),:);
        cdist2 = angledist(border(2),:);
        temp1 = find(cdist1 > 0);
        cdist1(temp1) = -inf;
        temp2 = find(cdist2 < 0);
        cdist2(temp2) = inf;
        min1 = max(cdist1);  
        min2 = min(cdist2);  
        if min1 == -inf
            stop1 = 1;
        elseif min1 ~= -inf
            neighbor1 = find(angledist(border(1),:) == min1);  % ��߽������С��
            neighbor1 = neighbor1(1);
        end 
        if min2 == inf
            stop2 = 1;
        elseif min2 ~= inf
        	neighbor2 = find(angledist(border(2),:) == min2);  % �ұ߽������С��
            neighbor2 = neighbor2(1);
        end
        if stop1 == 0
            angledist(border(1),neighbor1) = inf;
            angledist(neighbor1,border(1)) = -inf;
            if neighbor1 <= linehaulnum
                if dL + demandL(neighbor1) <= alpha1
                    cluster = [cluster, neighbor1];
                    border(1) = neighbor1;
                    dL = dL + demandL(neighbor1);
                else
                    stop1 = 1;
                end
            else
                if dB + demandB(neighbor1-linehaulnum) <= alpha2
                    cluster = [cluster, neighbor1];
                    border(1) = neighbor1;
                    dB = dB + demandB(neighbor1-linehaulnum);
                else
                    stop1 = 1;
                end
            end
        end
        
        if stop2 == 0 
            angledist(border(2),neighbor2) = -inf;
            angledist(neighbor2,border(2)) = inf;
            if neighbor2 <= linehaulnum
                if dL + demandL(neighbor2) <= alpha1
                    cluster = [cluster, neighbor2];
                    border(2) = neighbor2;
                    dL = dL + demandL(neighbor2);
                else
                    stop2 = 1;
                end
            else
                if dB + demandB(neighbor2-linehaulnum) <= alpha2
                    cluster = [cluster, neighbor2];
                    border(2) = neighbor2;
                    dB = dB + demandB(neighbor2-linehaulnum);
                else
                    stop2 = 1;
                end
            end
        end
            
        
        if stop1 == 1 && stop2 == 1
            stop1 = 0;
            stop2 = 0;
            bigcluster{k} = cluster;
            k = k+1;
            option = setdiff(option, cluster);
            angledist(cluster,:) = inf;  % ������ĳ�Ա�����ٱ��ֵ���Ĵ�ȥ
            angledist(:,cluster) = inf;
            choice = option(randi(length(option)));
            cluster = [choice];
            if choice <= linehaulnum
                dL = demandL(choice);
                dB = 0;
            else
                dL = 0;
                dB = demandB(choice - linehaulnum);
            end
            border = [choice, choice];
        end
        
        if k > K
            stop = 1;
        end
        
    end
    
    CH = zeros(K,2);
    for i = 1:K
        cc = bigcluster{i};
%         candidatedraw(cc, Lx, Ly, Bx, By, linehaulnum);
        temp1 = 0;
        temp2 = 0;
        for j = 1:length(cc)
            temp1 = temp1 + cos(cus_angle(cc(j)));
            temp2 = temp2 + sin(cus_angle(cc(j)));
        end
        temp1 = temp1/length(cc);
        temp2 = temp2/length(cc);
        CH(i,1) = dc*temp1+repox;
        CH(i,2) = dc*temp2+repoy;
    end       
end
        