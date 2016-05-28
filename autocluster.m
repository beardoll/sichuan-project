function [cluster] = autocluster(demand, samplex, sampley, capacity, K, repox, repoy)
    % ���Դ�������ķִ��㷨
    % demand: Ҫ�ִصĹ˿͵Ļ�������
    % samplex, sampley:�˿͵�x��y����
    % capacity:������
    % K:�����������ִص���Ŀ
    % repox, repoy:�ֿ��x��y����
    
    largenum = 100000;
    %% first step: �����ִ�
    num = length(samplex);
    tanvalue = zeros(1,num);
    % ���ȼ�������������ֵ
    for i = 1:num
        tanvalue(i) = (sampley(i) - repoy)/(samplex(i) - repox);
    end
    angle = 0:2*pi/K:2*pi*(K-1)/K;
    bound = zeros(1,length(angle));% �ֽ��ߵ�����ֵ
    for i = 1:length(angle)
        if angle(i) == pi/2
            bound(i) = largenum;
        elseif angle(i) == 3*pi/2
            bound(i) = largenum;
        else
            bound(i) = tan(angle(i));
        end
    end 
    cluster = cell(K);   % ���ֳ�K����
    burden = zeros(1,K); % ���صĻ������ܺ�  
    for i = 1:K
        cluster{i} = [];
    end
    for i = 1:num
        temptan = tanvalue(i);
        index = -1;
        for j = 1:K
            if j == K  % ����������һ���أ���ôǰ�߽�Ӧ����bound(end)����߽���bound(1)
                frontbound = bound(end);
                backbound = bound(1);
                frontangle = angle(end);
                backangle = angle(1);
                if frontbound == largenum
                    frontbound = -largenum;
                elseif backbound == largenum
                    backbound = largenum;
                end
            else     % ����ⲻ�����һ���أ���ôǰ����ǰ������Ǻ�
                frontbound = bound(j);
                backbound = bound(j+1);
                frontangle = angle(j);
                backangle = angle(j+1);
                if frontbound == largenum
                    frontbound = -largenum;
                elseif backbound == largenum
                    backbound = largenum;
                end
            end
            if frontangle < pi/2 && backangle > pi/2  || frontangle < 3/2*pi && backangle > 3/2*pi   
                % �ֽ��߿���(tan�����������ϵ�)
                if temptan > frontbound  % ��������ֵΪ��������Ӧ�ô���ǰ�߽�
                    if (cos(frontangle) * (samplex(i) - repox) >= 0)  && (sin(frontangle) * (sampley(i) - repoy) >= 0)
                        index = j;
                        break;
                    end
                elseif temptan <= backbound  % ��������ֵΪ��������Ӧ��С�ں�߽磬ͳһ��߽�ȡ�Ⱥ�
                    if (cos(backangle) * (samplex(i) - repox) >= 0) && (sin(backangle) * (sampley(i) - repoy) >= 0)
                        index = j;
                        break;
                    end
                end                    
            else  % �ֽ��߲�������ֻ��Ҫ��ǰ����ĳһ�ֽ���ͬ���޼���
                if temptan > frontbound && temptan <= backbound
                    if ((cos(frontangle) * (samplex(i) - repox) >= 0)  && (sin(frontangle) * (sampley(i) - repoy) >= 0))||...
                        ((cos(backangle) * (samplex(i) - repox) >= 0) && (sin(backangle) * (sampley(i) - repoy) >= 0)) % ͬһ����
                        index = j;
                    end
                end
            end
        end
        if index == -1;
            continue;
        else
            cluster{index} = [cluster{index}, i];
            burden(index) = burden(index) + demand(i);
        end
    end
    
    %% second step: �������س�Ա
    % ���ڵ�ǰ�������Ĵأ���������ߴصĸ����������Ա�����������С�Ĵ�
    % ���ڴظ������Ĵأ��ڳ������������ĵ㣬ת�Ƶ��ԱߵĴ�
    maxburden = max(burden);
    while maxburden > capacity
        clusterindex = find(burden == maxburden);
        clusterindex = clusterindex(1);
        % leftcluster��rightcluster�Ǹô��������ߵĴر��
        if clusterindex == 1
            leftcluster = K;
            rightcluster = 2;
        elseif clusterindex == K
            leftcluster = 1;
            rightcluster = K-1;
        else
            leftcluster = clusterindex - 1;
            rightcluster = clusterindex + 1;
        end
        if clusterindex == K  % ����������һ���أ���ôǰ�߽�Ӧ����bound(end)����߽���bound(1)
            frontangle = angle(end);
            backangle = angle(1);
        else     % ����ⲻ�����һ���أ���ôǰ����ǰ������Ǻ�
            frontangle = angle(clusterindex);
            backangle = angle(clusterindex+1);
        end   
        clustermem = cluster{clusterindex};   % �س�Ա
        memtanvalue = tanvalue(clustermem);
        
        if rand <= 0.5    % Ϊ�˷�ֹ����zigzag�����ѡ�񽻻�����һ��
%         if burden(leftcluster) <= burden(rightcluster)  % ��ߴظ�����С 
            if frontangle < pi/2 && backangle > pi/2  || frontangle < 3/2*pi && backangle > 3/2*pi  % ������ѡ������ֵ������С��ת��
                positiveindex = find(memtanvalue >= 0);
                positivevalue = memtanvalue(positiveindex);
                minindex = find(positivevalue == min(positivevalue));
                if isempty(minindex) == 1  % ���û����������ֵ���Ҹ�������ֵ����С��
                    minindex = find(memtanvalue == min(memtanvalue));
                    minindex = minindex(1);
                    realminindex = clustermem(minindex);
                else
                    minindex = minindex(1);  % ��positiveindex�еĶ�λ
                    realminindex = clustermem(positiveindex(minindex));  % ��clustermem�еľ��Զ�λ
                end
            else % ��������ѡ������ֵ��С��ת��
                realminindex = find(memtanvalue == min(memtanvalue));
                realminindex = realminindex(1);
                realminindex = clustermem(realminindex);  % ��clustermem�еľ��Զ�λ
            end
            realindex = realminindex;   
            neighborindex = leftcluster;
        else % �ұߴظ�����С
            if frontangle < pi/2 && backangle > pi/2  || frontangle < 3/2*pi && backangle > 3/2*pi  % ����
                negativeindex = find(memtanvalue < 0);
                negativevalue = memtanvalue(negativeindex);
                maxindex = find(negativevalue == max(negativevalue));
                if isempty(maxindex) == 1  % û�и����Ľڵ㣬����������ֵ�������
                    maxindex = find(memtanvalue == max(memtanvalue));
                    maxindex = maxindex(1);
                    realmaxindex = clustermem(maxindex);
                else
                    maxindex = maxindex(1);   % ��negativeindex�еĶ�λ
                    realmaxindex = clustermem(negativeindex(maxindex));   % ��clustermem�еľ��Զ�λ
                end
            else
                realmaxindex = find(memtanvalue == max(memtanvalue));
                realmaxindex = realmaxindex(1);
                realmaxindex = clustermem(realmaxindex);  % ��clustermem�еľ��Զ�λ
            end
            realindex = realmaxindex;
            neighborindex = rightcluster;
        end
        clustermem = setdiff(clustermem, realindex);
        burden(clusterindex) = burden(clusterindex) - demand(realindex);
        cluster{clusterindex} = clustermem;
        cluster{neighborindex} = [cluster{neighborindex}, realindex];
        burden(neighborindex) = burden(neighborindex) + demand(realindex);
        maxburden = max(burden);
    end
end
    