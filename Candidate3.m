function [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, K, repox, repoy, capacity)
    linehaulnum = length(Lx);        % linehaul节点个数
    totalnum = length([Lx, Bx]);     % 总的节点个数
    line_angle = computeAngle(Lx, Ly, repox, repoy);   % linehaul节点的幅角
    back_angle = computeAngle(Bx, By, repox, repoy);   % backhaul节点的幅角
    cus_angle = [line_angle, back_angle];               % 所有顾客节点的幅角
    angledist = zeros(totalnum, totalnum);  % 节点之间的幅角距离
    
    for i = 1:totalnum
        angledist(i,i) = inf;
        for j = i+1:totalnum
            minus = cus_angle(i) - cus_angle(j);
            angledist(i,j) = min(abs(minus), abs(2*pi-abs(minus)));  % 选幅角更小者（不能超过180度）
            angledist(j,i) = angledist(i,j); % 对称性
        end
    end
    
    
    
    cluster = [];  % 已经聚成簇的节点集合
    clusterlen = 0;  % 簇长度
    clustermem = [];  % 簇成员
    spotid = -1*ones(1,totalnum);   % 每个顾客节点所在的簇标号
    
    %% 初步分簇
    while length(clustermem) < totalnum || clusterlen > 2*K
        minangledist = min(min(angledist));  % 当前幅角距离最小者
        minindex = find(angledist == minangledist);
        minindex = minindex(1);
        
        temp1 = floor(minindex/totalnum)+1;     % 行坐标
        temp2 = minindex - (temp1-1)*totalnum;  % 列坐标
        if temp2 == 0
            temp2 = totalnum;
            temp1 = temp1 - 1;
        end
        
        incluster = length(intersect(clustermem, [temp1, temp2]));  % 看一下temp1, temp2是否都已经在簇中
        
        angledist(temp1, temp2) = inf;
        angledist(temp2, temp1) = inf;
        
        if incluster == 0  % 都没有被分配到任何一个簇中，则开辟一个新的簇
            clustermem = [clustermem, temp1, temp2];
            cl.mem = [temp1, temp2];
            cl.dL = 0;  % 簇的linehaul负担
            cl.dB = 0;  % 簇的backhaul负担
            if temp1 <= linehaulnum
                cl.dL = cl.dL + demandL(temp1);
            else
                cl.dB = cl.dB + demandB(temp1-linehaulnum);
            end
            if temp2 <= linehaulnum
                cl.dL = cl.dL + demandL(temp2);
            else
                cl.dB = cl.dB + demandB(temp2-linehaulnum);
            end
            cluster = [cluster, cl];
            clusterlen = clusterlen + 1;
            spotid(temp1) = clusterlen;
            spotid(temp2) = clusterlen;
        elseif incluster == 1  % 有其中一个节点在簇中
            if ismember(temp1, clustermem)  % 如果temp1是clustermem中的元素
                clid = spotid(temp1);  % 把temp1的id找出来
                cc = cluster(clid);  % clid所指向的簇
                if temp2 <= linehaulnum
                    if cc.dL + demandL(temp2) <= capacity
                        clustermem = [clustermem, temp2];
                        cc.dL = cc.dL + demandL(temp2);
                        cc.mem = [cc.mem, temp2];
                        spotid(temp2) = clid;
                        cluster(clid) = cc;
                    end
                else
                    if cc.dB + demandB(temp2-linehaulnum) <= capacity
                        clustermem = [clustermem, temp2];
                        cc.dB = cc.dB + demandB(temp2-linehaulnum);
                        cc.mem = [cc.mem, temp2];
                        spotid(temp2) = clid;
                        cluster(clid) = cc;
                    end
                end
            elseif ismember(temp2, clustermem)  % temp2是clustermem中的元素
                clid = spotid(temp2);  % 把temp1的id找出来
                cc = cluster(clid);  % clid所指向的簇
                if temp1 <= linehaulnum
                    if cc.dL + demandL(temp1) <= capacity
                        clustermem = [clustermem, temp1];
                        cc.dL = cc.dL + demandL(temp1);
                        cc.mem = [cc.mem, temp1];
                        spotid(temp1) = clid;
                        cluster(clid) = cc;
                    end
                else
                    if cc.dB + demandB(temp1-linehaulnum) <= capacity
                        clustermem = [clustermem, temp1];
                        cc.dB = cc.dB + demandB(temp1-linehaulnum);
                        cc.mem = [cc.mem, temp1];
                        spotid(temp1) = clid;
                        cluster(clid) = cc;
                    end
                end
            end
        elseif incluster == 2  % 两个都在簇中
            if spotid(temp1) ~= spotid(temp2)  % 如果二者位于不同的簇，则尝试把这两个簇给结合起来
                clid1 = spotid(temp1);
                clid2 = spotid(temp2);
                cc1 = cluster(clid1);
                cc2 = cluster(clid2);
                if cc1.dL + cc2.dL <= capacity && cc1.dB + cc2.dB <= capacity  % 两簇合并后不会超出车容量
                    mem2 = cc2.mem;
                    for v = 1:length(mem2)
                        cspot = mem2(v);
                        spotid(cspot) = clid1;  % 全部易主
                    end
                    cc1.mem = [cc1.mem, cc2.mem];  %合并
                    cc1.dL = cc1.dL + cc2.dL;
                    cc1.dB = cc1.dB + cc2.dB;
                    cluster(clid1) = cc1;
                    cluster(clid2) = [];
                    clusterlen = clusterlen - 1;
                    for k = clid2 : clusterlen  % clid2被删除，因此需要把其他后面的簇id做调整
                        cmem = cluster(k).mem;
                        for m = 1:length(cmem)
                            spotid(cmem(m)) = spotid(cmem(m)) - 1;
                        end
                    end
                end
            end
        end               
    end
    
    
    %% adjustment，将clusterlen个簇变成合法的K个簇
    newcluster = [];   % 对原来的cluster进行位置排序              
    anglelist = [];
    border = zeros(clusterlen, 2);  % 原来各个cluster的边界
    epsilon = 10^(-4);
    for i = 1:clusterlen   % 求出每个簇的角平分线  
        cmem = cluster(i).mem;
        maxangle = max(cus_angle(cmem));
        minangle = min(cus_angle(cmem));
        anglerange = (maxangle + minangle)/2;
        if maxangle - minangle > pi  % 在所有的簇中，簇的夹角都不会超过180度，除非是跨一、四象限
            temp1 = cus_angle(cmem);
            temp2 = temp1(find(temp1 >= 0 & temp1 < pi));
            temp3 = temp1(find(temp1 >=pi & temp1 < 2*pi));
            minangle = max(temp2);
            maxangle = min(temp3);
            anglerange = (-2*pi + maxangle + minangle)/2;
        end
        b1 = find(cus_angle(cmem) >= minangle-epsilon & cus_angle(cmem) <= minangle+epsilon);
        b1 = b1(1);
        b1 = cmem(b1);
        b2 = find(cus_angle(cmem) >= maxangle-epsilon & cus_angle(cmem) <= maxangle+epsilon);
        b2 = b2(1);
        b2 = cmem(b2);
        border(i,:) = [b1, b2];
        midangle = anglerange/2; % 中间值，用来对簇进行排序
        anglelist = [anglelist, midangle];
    end
    
    rankborder = zeros(clusterlen,2);  % K个簇的边界节点
    rankanglelist = sort(anglelist, 'ascend');  % 对幅角小到大进行排序
    for i = 1:clusterlen  % 形成新的簇cluster
        index = find(anglelist == rankanglelist(i));
        rankborder(i,:) = border(index,:);
%         figure(i);
%         candidatedraw(cluster(index).mem, Lx, Ly, Bx, By, linehaulnum, 12000,16000);
        newcluster = [newcluster, cluster(index)];
    end
    
    jumpnum = clusterlen - K;  
    % 跳跃的范围（clusterlen > K）
    % 在newcluster中，每偶数编号的簇会被合并到相邻的基数编号的簇中(有jumpnum个簇会执行这样的操作)
    retaincluster = zeros(1,K);    % 保留下来的簇编号
    for j = 1:jumpnum
        retaincluster(j) = (j-1)*2+1;
    end
    % 空出了jumpnum个簇后。剩下的紧密排列
    retaincluster(jumpnum+1:end) = (jumpnum*2+1):(K-jumpnum+jumpnum*2);
    
    % 接下来需要对jumpnum个簇进行“瓜分”
    for i = 1:jumpnum
        index = (i-1)*2+2;
        cmem = newcluster(index).mem;
        if index == 1
            index1 = clusterlen;  % 左邻簇
        else
            index1 = index-1;
        end
        if index == clusterlen
            index2 = 1;           % 右邻簇
        else
            index2 = index + 1;
        end
        candidate1 = rankborder(index1,:);  % 归入相邻编号的簇
        candidate2 = rankborder(index2,:);
        for m = 1:length(cmem)
            min1 = min(angledist(candidate1, cmem(m)));  % min1,min2为当前节点距离相邻簇边界的最短距离
            min2 = min(angledist(candidate2, cmem(m)));
            if min1 <= min2  % 左邻簇更近
                newcluster(index1).mem = [newcluster(index1).mem, cmem(m)];
                if cmem(m) <= linehaulnum
                    newcluster(index1).dL = newcluster(index1).dL + demandL(cmem(m));
                else
                    newcluster(index1).dB = newcluster(index1).dB + demandB(cmem(m)-linehaulnum);
                end
            else  % 右邻簇更近
                newcluster(index2).mem = [newcluster(index2).mem, cmem(m)];
                if cmem(m) <= linehaulnum
                    newcluster(index2).dL = newcluster(index2).dL + demandL(cmem(m));
                else
                    newcluster(index2).dB = newcluster(index2).dB + demandB(cmem(m)-linehaulnum);
                end
            end
        end
    end
    
    origincluster = newcluster(retaincluster);  
    % 原来的clusterlen个簇变成了K个簇，但是每个簇不一定都满足车容量约束
    origindL = zeros(1,K);
    origindB = zeros(1,K);
    % 先把各个簇的容量给统计出来
    for i = 1:K
        origindL(i) = origincluster(i).dL;
        origindB(i) = origincluster(i).dB;
    end
    
    % 接下来针对origincluster进行调整，使每个簇的货物量不超过车载量
    while max(origindL) > 1.05*capacity || max(origindB) > 1.05*capacity   % 1.05是一个松弛量，避免出现死循环
        for i = 1:K   % 往编号大的方向转移(把幅角较大的给转移走)
            if origindL(i) > capacity || origindB(i) > capacity  % 有其中一个容量超了                           
                if i == K
                    neibor = 1;
                else
                    neibor = i+1;
                end
                if origindL(i) > capacity    % 将当前簇的linehaul节点转移走，直到总货物需求低于车载量
                    while origindL(i) > capacity
                        cmem = origincluster(i).mem;
                        cmemL = cmem(find(cmem<=linehaulnum));  % linehaul成员
                        minangle = min(cus_angle(cmemL));  % 当前簇i的linehaul成员的边界
                        maxangle = max(cus_angle(cmemL));
                        if maxangle - minangle > pi  % 簇是跨区的（选幅角大者，因为往簇编号更大的簇转移）
                            plusmem = cmemL(find(cus_angle(cmemL) >= 0 & cus_angle(cmemL) < pi));
                            cchoice = cmemL(find(cus_angle(cmemL) == max(cus_angle(plusmem))));
                            cchoice = cchoice(1);
                        else
                            cchoice = cmemL(find(cus_angle(cmemL) == max(cus_angle(cmemL))));
                            cchoice = cchoice(1);
                        end
                        cdL = demandL(cchoice);                          
                        origincluster(i).mem = setdiff(origincluster(i).mem, cchoice);
                        origincluster(neibor).mem = [origincluster(neibor).mem, cchoice];
                        origincluster(neibor).dL = origincluster(neibor).dL + cdL;
                        origincluster(i).dL = origincluster(i).dL - cdL;
                        origindL(i) = origindL(i) - cdL;
                        origindL(neibor) = origindL(neibor) + cdL;
                    end
                end
                if origindB(i) > capacity % 将当前簇的backhaul节点转移走，直到总货物需求低于车载量
                    while origindB(i) > capacity
                        cmem = origincluster(i).mem;
                        cmemB = cmem(find(cmem>linehaulnum));   % backhaul成员 
                        minangle = min(cus_angle(cmemB));  % 当前簇i的backhaul成员的边界
                        maxangle = max(cus_angle(cmemB));
                        if maxangle - minangle > pi  % 簇是跨区的（选幅角大者，因为往簇编号更大的簇转移）
                            plusmem = cmemB(find(cus_angle(cmemB) >= 0 & cus_angle(cmemB) < pi));
                            cchoice = cmemB(find(cus_angle(cmemB) == max(cus_angle(plusmem))));
                            cchoice = cchoice(1);
                        else
                            cchoice = cmemB(find(cus_angle(cmemB) == max(cus_angle(cmemB))));
                            cchoice = cchoice(1);
                        end
                        cdB = demandB(cchoice-linehaulnum);
                        origincluster(i).mem = setdiff(origincluster(i).mem, cchoice);
                        origincluster(i).dB = origincluster(i).dB - cdB; 
                        origincluster(neibor).mem = [origincluster(neibor).mem, cchoice];
                        origincluster(neibor).dB = origincluster(neibor).dB + cdB;
                        origindB(i) = origindB(i) - cdB;
                        origindB(neibor) = origindB(neibor) + cdB;
                    end
                end                        
            end
        end
    end
    
    % 以origincluster的分簇结果为初始分簇，求解簇心，作为簇首初始值
    CH = zeros(K,2);
    for i = 1:K
        cc = origincluster(i).mem;
        temp2 = 0;
        temp1 = 0;
        for j = 1:length(cc)
            cspot = cc(j);
            if cspot <= linehaulnum
%                 temp1 = temp1 + Lx(cspot);
%                 temp2 = temp2 + Ly(cspot);
                temp1 = temp1 + (Lx(cspot)+repox)/2;
                temp2 = temp2 + (Ly(cspot)+repoy)/2;
            else
%                 temp1 = temp1 + Bx(cspot-linehaulnum);
%                 temp2 = temp2 + By(cspot-linehaulnum);
                temp1 = temp1 + (Bx(cspot-linehaulnum)+repox)/2;
                temp2 = temp2 + (By(cspot-linehaulnum)+repoy)/2;
            end
        end
        temp1 = temp1/length(cc);
        temp2 = temp2/length(cc);
        CH(i,1) = temp1;
        CH(i,2) = temp2;
%         figure(i);
%         candidatedraw(cc, Lx, Ly, Bx, By, linehaulnum, CH(i,1), CH(i,2));
    end  
end