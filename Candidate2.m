function [] = Candidate2(Lx, Ly, Bx, By, demandL, demandB, K)
    % 利用幅角距离来初始化簇首位置
    alpha1 = demandL/K;   % 每个Linehaul簇的平均载重量
    alpha2 = demandB/K;   % 每个backhaul簇的平均载重量
    linehaulnum = length(Lx);
    backhaulnum = length(Bx);
    line_angle = computeAngle(Lx, Ly, repox, repoy);   % linehaul节点的幅角
    back_angle = computeAngle(Bx, By, repox, repoy);   % backhaul节点的幅角
    cus_angle = [line_angle, back_angle];               % 所有顾客节点的幅角
    angledist = zeros(linehaulnum+backhaulnum, linehaulnum+backhaulnum); % 顾客节点之间的幅角距离
    cluster = cell(K);   % 一共K个簇
    for i = 1:K
        cluster{i} = [];
    end
    clusterdL = zeros(1,K);  % 每个簇的linehaul代价
    clusterdB = zeros(1,K);  % 每个簇的backhaul代价
    borderspot = zeros(K,2);  % 边界点
    curcluster = 1;  % 当前要装载节点的簇
    for i = 1:linehaulnum + backhaulnum
        angledist(i,i) = inf;
        for j = i+1:linehaulnum + backhaulnum
            angledist(i,j) = abs(cus_angle(i) - cus_angle(j));
        end
        angledist(j,i) = angledist(i,j);
    end
    stop = 0
    while stop == 0
        mindist = min(min(angledist));
        minindex = find(angledist == mindist);
        temp1 = floor(minindex/(linehaulnum+backhaulnum));  % 幅角最小者所在行
        temp2 = minindex - (temp1-1)*(linehaulnum+backhaulnum); % 幅角最小者所在列
        if temp2 == 0
            temp2 = linehaulnum + backhaulnum;
        end
        if temp1 <= linehaulnum;
            d1L = demandL(temp1); % temp1带来的Linehaul负担
            d1B = 0;              % temp1带来的backhaul负担
        else
            d1L = 0;
            d1B = demandB(temp1-linehaulnum);
        end
        if temp2 <= linehaulnum
            d2L = demandL(temp2);  % temp2带来的Linehaul负担
            d2B = 0;               % temp2带来的backhaul负担
        else
            d2L = 0;
            d2B = demandB(temp2-linehaulnum);
        end 
        % 下面的计算是为了衡量加入当前节点的货物量后是否超出当前簇的货物量
        if length(cluster{curcluster}) == 0  % 当前簇还没有成员
            cluster{curcluster} = [cluster{curcluster}, temp1, temp2];
            clusterdL(curcluster) = clusterdL(curcluster) + d1L + d2L;
            clusterdB(curcluster) = clusterdB(curcluster) + d1B + d2B;
        else
            cdL = clusterdL(curcluster);
            cdB = clusterdB(curcluster);
            if cdL + d1L + d2L > alpha1 || cdB + d1B + d2B > alpha2  % 不合法
                if temp1 == borderspot(curcluster,1) || temp1 == borderspot(curcluster,2) ...
                        || temp2 == borderspot(curcluster,1) || temp2 == borderspot(curcluster,2) 
                    % 这对不合法组合中有一个成员是当前簇的边界成员
                    angledist(temp1,temp2) = inf;
                    angledist(temp1,temp1) = inf;
                else
                    curcluster = curcluster + 1;
                    if curcluster > K
                        curcluster = 1;
                    end
                    cluster{curcluster} = [cluster{curcluster}, temp1, temp2];
                    clusterdL(curcluster) = clusterdL(curcluster) + d1L + d2L;
                    clusterdB(curcluster) = clusterdB(curcluster) + d1B + d2B;
                    borderspot(curcluster,1) = temp1;
                    borderspot(curcluster,2) = temp2;
                end 
            else  % 合法
                cluster{curcluster} = [cluster{curcluster}, temp1, temp2];
                clusterdL(curcluster) = clusterdL(curcluster) + d1L + d2L;
                clusterdB(curcluster) = clusterdB(curcluster) + d1B + d2B;
                if temp1 ~= borderspot(curcluster,1) && temp2 ~= borderspot(curcluster,2)
                    if temp2 == borderspot(curcluster,1)
                        borderspot(curcluster,2) = temp1;
                    elseif temp2 == borderspot(curcluster,2)
                        
                    
            end
        end                                                    
        if min(min(angledist)) == inf  % 如果已经查找过所有的节点组合，则算法结束
            stop = 1;
        end
    end
end