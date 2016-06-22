function [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, K, dc, repox, repoy, capacity)
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
            angledist(i,j) = min(abs(minus), abs(2*pi-abs(minus)));  % 选幅角更小者
            angledist(j,i) = angledist(i,j); % 对称性
        end
    end
    
    
    
    cluster = [];  % 已经聚成簇的节点集合
    clusterlen = 0;  % 簇长度
    clustermem = [];  % 簇成员
    spotid = -1*ones(1,totalnum);   % 每个顾客节点所在的簇标号
    
    while length(clustermem) < totalnum
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
    
    memlen = zeros(1,clusterlen);
    for i = 1:clusterlen
        mem = cluster(i).mem;
        memlen(i) = length(mem);
    end
    
    memlensort = sort(memlen, 'descend');
    CH = zeros(K,2);
    for i = 1:K
        clindex = find(memlen == memlensort(i));
        clindex = clindex(1);
        memlen(clindex) = inf;
        cc = cluster(clindex).mem;
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