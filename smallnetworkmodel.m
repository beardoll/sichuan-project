m = wareHouseNum;  %仓库数量
n = recPointNum;   %收货点数量
%% Initialization
%% 编号：从1到m为仓库，从m+1到m+n为收货点
carCompanyPos.x = ;
carCompanyPos.y = ;  %货车公司的位置
spot = cell(1,n+m);
for i = 1:n+m
    spot{i}.x = ;
    spot{i}.y = ;  %各个点的x和y坐标，但实际距离不简单地以几何距离来测算
end
DcarToSpot = zeros(1,n+m);  %汽车公司到各个点之间的距离
D = zeros(m+n, m+n); %对称矩阵，各个点之间的最短距离
store = zeros(1,m);  %各仓库存储量;
productNeed = cell(1,n); %各个点对各个仓库的需求，每个元胞包含一个m维数组
Route = ones(1,m+n); %当前货车（第一辆）未走过的路径,1代表未走过，0代表已走过
W = zeros(1,m);  %货车上各类货物的数量
maxLoad = ;   %最大载货量
b1 = ;
b2 = ; %两条界线
alpha = ;  %距离比较参数
carStack = 1; %纪录当前在运作的货车编号
carPositionIndex = 0;%货车位置编号，0-(n+m)，0表示在货车公司

%% applying the statechart
while sum(store) > 0  %算法执行至所有的货物都运出去为止
    effectiveIndex = find(route == 1); %找出没走过的点
    if sum(W)/M <b1  %无条件送货
        if carPositionIndex == 0
            minDist = min(DcarToSpot(effectiveIndex));
            arrSpot = find(DcarToSpot == minDist);  %找出路径最短的点
        else
            distanceArray = D(carPositionIndex,:);  %该点与其他点之间的距离数组
            minDist = min(distanceArray(effectiveIndex));
            arrSpot = find(distanceArray == minDist); %找出路径最短的点
        end
        temp = min(W(arrSpot)+store(arrSpot), M);
        store(arrSpot) = store(arrSpot) - (temp - W(arrSpot));
        W(arrSpot) = temp;
        route(arrSpot) = 0;
        carPositionIndex = arrSpot;
    else
        if sum(W)/M < b2 %根据与仓库距离和与送货点距离远近来做决策(不可能刚出发)
            distArr = D(carPositionIndex,:);
            distToWareHouse = distArr(1:m);
            distToRecSpot = distArr(m+1:m+n);
            index1 = find(effectiveIndex<=m);  %仓库与送货点之间的分界线
            index2 = find(effectiveIndex>m);
            minDist1 = min(distToWareHouse(index1));
            optionS1 = find(distToWareHouse == minDist1);  %当前最近的送货点
            nowChoice = 1;   %先选择最近的收货点
            DistOpt = sort(distToRecSpot(index2));     %对与没有经过的收货点的距离进行排序
            optionS2 = find(distToRecSpot == DistOpt(nowChoice));  %当前最近的收货点
            success = 0;
            while success == 0 %还没有确定下一站，则继续寻找
                if minDist1 <= alpha * minDist2  %优先前往收货点送货
                    %先判断车上的货物是否为该送货点所需
                    productNeedCur = productNeed{OptionS1}.array;
                    productToSend = find(W~=0);
                    productForRec = find(productNeedCur~=0);
                    if length(difference(productToSend, productForRec)) == 0 %货车上的货物不是该收货点所需
                        success = 0;
                        nowChoice = nowChoice + 1;
                        minDist2 = DistOpt(newChoice);  
                        optionS2 = find(distToRecSpot == DistOpt(newChoice));  %当前的收货点
                    else  %可往该点送货
                       needArray = productNeed{optionS2}
                        for k = 1:length(needArray)
                            temp = max(W(k)-needArray(k),0);
                            needArray(k) = needArray(k) - (W(k)-temp);    %第k类货物所需量
                            W(k) = temp;
                        end
                        Route(n+optionS2) = 0;    %注意当前的下标optionS2是在收货点中的相对位置
                        success = 1;
                        carPositionIndex = n + optionS2; %原理同上
                        notArriveNum = length(find(route == 1));  %看一下还有多少节点没有经过
                        if notArriveNum == 0 %如果全部节点已遍历 
                            %因为车上货物未必已经全部送出，所以这里必须把当前车上的货物送出
                            distanceArray = D(carPositionIndex,:); %从当前节点看其余收货点到这里的距离
                            distanceArray2 = distanceArray(m+1:m+n); %只寻找收货点
                            candidateNode = []; %候选的收货点
                            distanceRank = sort(distanceArray2);
                            carStack = carStack + 1; %换一辆车
                            route = ones(1,m+n);
                            W = zeros(1,m);
                            carPositionIndex = 0;
                        end
                    end
                else % 优先选择收货
                    temp = min(W(optionS1)+S(optionS), M);
                    S(optionS1) = S(optionS1) - (temp - W(optionS1));
                    W(optionS1) = temp;
                    Route(optionS1) = 0;   %这里是因为全局数组排列是从仓库开始的，所以不用如收货点那样区分相对定位
                    carPositionIndex = optionS1;
                end
            end
        else  %无条件送货
            needArray = productNeed{optionS2}
            for k = 1:length(needArray)
                temp = max(W(k)-needArray(k),0);
                needArray(k) = needArray(k) - (W(k)-temp);    %第k类货物所需量
                W(k) = temp;
            end
            Route(n+optionS2) = 0;    %注意当前的下标optionS2是在收货点中的相对位置
            success = 1;
            carPositionIndex = n + optionS2; %原理同上
            notArriveNum = length(find(route == 1));  %看一下还有多少节点没有经过
            if notArriveNum == 0 %如果全部节点已遍历
                carStack = carStack + 1; %换一辆车
                route = ones(1,m+n);
                W = zeros(1,m);
                carPositionIndex = 0;
            end
        end
    end
end
            
                    
                    
                
                
                
                