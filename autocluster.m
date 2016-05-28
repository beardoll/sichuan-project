function [cluster] = autocluster(demand, samplex, sampley, capacity, K, repox, repoy)
    % 拍脑袋想出来的分簇算法
    % demand: 要分簇的顾客的货物需求
    % samplex, sampley:顾客的x、y坐标
    % capacity:车载量
    % K:车辆数，即分簇的数目
    % repox, repoy:仓库的x、y坐标
    
    largenum = 100000;
    %% first step: 初步分簇
    num = length(samplex);
    tanvalue = zeros(1,num);
    % 首先计算各个点的正切值
    for i = 1:num
        tanvalue(i) = (sampley(i) - repoy)/(samplex(i) - repox);
    end
    angle = 0:2*pi/K:2*pi*(K-1)/K;
    bound = zeros(1,length(angle));% 分界线的正切值
    for i = 1:length(angle)
        if angle(i) == pi/2
            bound(i) = largenum;
        elseif angle(i) == 3*pi/2
            bound(i) = largenum;
        else
            bound(i) = tan(angle(i));
        end
    end 
    cluster = cell(K);   % 共分成K个簇
    burden = zeros(1,K); % 各簇的货物量总和  
    for i = 1:K
        cluster{i} = [];
    end
    for i = 1:num
        temptan = tanvalue(i);
        index = -1;
        for j = 1:K
            if j == K  % 如果这是最后一个簇，那么前边界应该是bound(end)，后边界是bound(1)
                frontbound = bound(end);
                backbound = bound(1);
                frontangle = angle(end);
                backangle = angle(1);
                if frontbound == largenum
                    frontbound = -largenum;
                elseif backbound == largenum
                    backbound = largenum;
                end
            else     % 如果这不是最后一个簇，那么前就是前，后就是后
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
                % 分界线跨区(tan函数的无穷间断点)
                if temptan > frontbound  % 这是正切值为正数区域，应该大于前边界
                    if (cos(frontangle) * (samplex(i) - repox) >= 0)  && (sin(frontangle) * (sampley(i) - repoy) >= 0)
                        index = j;
                        break;
                    end
                elseif temptan <= backbound  % 这是正切值为负数区域，应该小于后边界，统一后边界取等号
                    if (cos(backangle) * (samplex(i) - repox) >= 0) && (sin(backangle) * (sampley(i) - repoy) >= 0)
                        index = j;
                        break;
                    end
                end                    
            else  % 分界线不跨区，只需要当前点与某一分界线同象限即可
                if temptan > frontbound && temptan <= backbound
                    if ((cos(frontangle) * (samplex(i) - repox) >= 0)  && (sin(frontangle) * (sampley(i) - repoy) >= 0))||...
                        ((cos(backangle) * (samplex(i) - repox) >= 0) && (sin(backangle) * (sampley(i) - repoy) >= 0)) % 同一象限
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
    
    %% second step: 调整各簇成员
    % 对于当前负担最大的簇，检查其两边簇的负担，把其成员分配给负担较小的簇
    % 对于簇负担最大的簇，挖出其离边线最近的点，转移到旁边的簇
    maxburden = max(burden);
    while maxburden > capacity
        clusterindex = find(burden == maxburden);
        clusterindex = clusterindex(1);
        % leftcluster和rightcluster是该簇左右两边的簇编号
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
        if clusterindex == K  % 如果这是最后一个簇，那么前边界应该是bound(end)，后边界是bound(1)
            frontangle = angle(end);
            backangle = angle(1);
        else     % 如果这不是最后一个簇，那么前就是前，后就是后
            frontangle = angle(clusterindex);
            backangle = angle(clusterindex+1);
        end   
        clustermem = cluster{clusterindex};   % 簇成员
        memtanvalue = tanvalue(clustermem);
        
        if rand <= 0.5    % 为了防止出现zigzag，随机选择交换到哪一边
%         if burden(leftcluster) <= burden(rightcluster)  % 左边簇负担更小 
            if frontangle < pi/2 && backangle > pi/2  || frontangle < 3/2*pi && backangle > 3/2*pi  % 跨区，选择正切值正数最小者转移
                positiveindex = find(memtanvalue >= 0);
                positivevalue = memtanvalue(positiveindex);
                minindex = find(positivevalue == min(positivevalue));
                if isempty(minindex) == 1  % 如果没有正数正切值，找负数正切值的最小者
                    minindex = find(memtanvalue == min(memtanvalue));
                    minindex = minindex(1);
                    realminindex = clustermem(minindex);
                else
                    minindex = minindex(1);  % 在positiveindex中的定位
                    realminindex = clustermem(positiveindex(minindex));  % 在clustermem中的绝对定位
                end
            else % 不跨区，选择正切值最小者转移
                realminindex = find(memtanvalue == min(memtanvalue));
                realminindex = realminindex(1);
                realminindex = clustermem(realminindex);  % 在clustermem中的绝对定位
            end
            realindex = realminindex;   
            neighborindex = leftcluster;
        else % 右边簇负担更小
            if frontangle < pi/2 && backangle > pi/2  || frontangle < 3/2*pi && backangle > 3/2*pi  % 跨区
                negativeindex = find(memtanvalue < 0);
                negativevalue = memtanvalue(negativeindex);
                maxindex = find(negativevalue == max(negativevalue));
                if isempty(maxindex) == 1  % 没有负数的节点，找正数正切值的最大者
                    maxindex = find(memtanvalue == max(memtanvalue));
                    maxindex = maxindex(1);
                    realmaxindex = clustermem(maxindex);
                else
                    maxindex = maxindex(1);   % 在negativeindex中的定位
                    realmaxindex = clustermem(negativeindex(maxindex));   % 在clustermem中的绝对定位
                end
            else
                realmaxindex = find(memtanvalue == max(memtanvalue));
                realmaxindex = realmaxindex(1);
                realmaxindex = clustermem(realmaxindex);  % 在clustermem中的绝对定位
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
    