function []=smallLogisticsNetwork(wareHouseNum, recSpotNum, carCompanyPos, DcarToSpot, D, productNeed, store, parameter, carinformation)
% description for variable
% wareHouseNum: 仓库数量
% recSpotNum: 收货点数量
% carCompanyPos: 货车公司的位置
% DcarTospot:汽车公司到各个点之间的距离
% D: 对称矩阵，各个点之间的最短距离
% productNeed: 各个收货点对各个仓库的需求，每行代表该收货点对各货物的需求
% store: 各仓库存储量
% parameter: 包含两条界限b1,b2以及参数alpha  
    %% Initialization
    %% 编号：从1到m为仓库，从m+1到m+n为收货点
    m = wareHouseNum;  
    n = recSpotNum; 
    b1 = parameter.b1;
    b2 = parameter.b2; %两条界线
    alpha = parameter.b3;  %距离比较参数

    % car的相关定义
    car.index = 1;
    car.positionIndex = 0; %货车位置编号，0-(n+m)，0表示在货车公司，一般表示车子下一站取出
    car.route = ones(1,m+n);  %当前货车（第一辆）未走过的路径,1代表未走过，0代表已走过
    car.W = zeros(1,m);  %货车上各类货物的数量
    car.maxLoad = carinformation.maxLoad; %最大载货量
    car.state = 0;  %汽车的状态变量，0表示寻路，1表示去仓库收货，2表示去收货点送货，3表示任务完成，换车
    car.backwardRoute = []; %车子回溯路径中的可选节点
    car.backward = 0;  %为1表示触发回溯机制，为0表示不触发
    car.nowChoice = 1;     
    car.relax = 0;  %已经路过所有节点，现在只需要把货物卸载即可完成任务
    % 车子当前在可选送货点上的选择，1表示路径最短，但不一定满足送货需求（即收货点不需要车上货物）
    % 这时可能会选择次短，甚至更次短
    % 如果搜完所有的可选路径都没找到可以送货的点，则启动回溯机制
    % 然后从已经去过的收货点中再根据路径最短原则选择

    while sum(productNeed) > 0   %当收货点的需求未被全部满足时，货车继续执行收货送货操作
        switch car.state
            case 0,
                if sum(W)/M <b1  && car.relax == 0 %无条件收货
                    [car_update] = collect(car, D, store, DcarToSpot, m, n);
                    car = car_update;
                elseif sum(W)/M < b2 && car.relax == 0  %根据与仓库距离和与送货点距离远近来做决策(不可能刚出发)
                    option = 1;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, option);
                    car = car_update;
                elseif sum(W)/M <= b2 || car.relax == 1    %无条件送货
                    option = 0;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, option);
                    car = car_update;
                end
            case 1,  %收货
                % 会不会出现这样的情况：在最后一个点收完货之后发现已经没有未走过的节点
                % 还有一个问题，如果该收货点的货物已经全部送出去，应该要做一个判断
                optionS1 = car.positionIndex;  %当前车子到达的地方
                temp = min(car.W(optionS1)+store(optionS1), M);
                store(optionS1) = store(optionS1) - (temp - car.W(optionS1));
                car.W(optionS1) = temp;
                car.state = 0;  %继续进行选路
                car.route(optionS1) = 0;  %标记此节点已走过
                car.nowChoice = 1;
                if length(find(car.route==1))==0 %已经“无路可走”作
                    car.route = zeros(1,m+n);
                    car.route(m+1:m+n) = 1;
                    car.route(optionS2+n) = 0;  %当前节点不可选
                    car.relax = 1;
                end
            case 2,  %送货
                car.backward = 0;      %暂时取消回溯机制
                car.backwardRoute = []; %清空回溯路径
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 这里有可能会牵扯到重复选择的问题，以后再考虑 %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                optionS2 = car.positionIndex;
                relativeToRecSpot = optionS2 - m;  %在收货点中的相对位置
                temp = max(car.W-productNeed(relativeToRecSpot,:), zeros(1,m));  %执行卸货操作
                productNeed(optionS2,:) = productNeed(relativeToRecSpo,:)-(car.W-temp);
                car.W = temp;
                car.route(optionS2) = 0;    %注意当前的下标optionS2是在收货点中的相对位置
                car.state = 0;
                car.nowChoice = 1;
                if length(find(car.route==1))==0 %已经“无路可走”
                    if sum(car.W) == 0  %如果已经送完货，则换车
                        car.state = 3;
                    else  %否则，启动无条件送货,进入选路操作
                        car.route = zeros(1,m+n);
                        car.route(m+1:m+n) = 1;
                        car.route(optionS2+n) = 0;  %当前节点不可选
                        car.relax = 1;
                    end
                end
            case 3,  %换车
                car.index = car.index + 1;
                car.W = 0;
                car.maxLoad = ; %最大载货量
                car.state = 0;  %汽车的状态变量，0表示寻路，1表示去仓库收货，2表示去收货点送货，3表示任务完成，换车
                car.backwardRoute = []; %车子回溯路径中的可选节点
                car.backward = 0;  %为1表示触发回溯机制，为0表示不触发
                car.nowChoice = 1; 
                car.relax = 0;  %已经路过所有节点，现在只需要把货物卸载即可完成任务
        end
    end
end


%% 收货操作有关的函数
% 如果搜索到所有未走过的仓库都无货可收，则该车完成任务
function [car_update] = collect(car, D, store, DcarToSpot, m, n)
    effectiveIndex = find(car.route == 1); %找出没走过的点(forward)
    indexForWareHouse = find(effectiveIndex<=m);  %与仓库有关
    if car.nowChoice > length(indexForWareHouse)
        car.state = 3;
    else
        if car.positionIndex == 0   %如果货车在公司
            distToWareHouse = sort(DcarToSpot(1:m)); %到仓库的距离从小到大排列           
            optionS1 = find(DcarToSpot == distToWareHouse(car.nowChoice));  %找出路径最短的点
        else
            distanceArray = D(car.positionIndex,:);  %该点与其他点之间的距离数组
            distToWareHouse = sort(distanceArray(1:m));
            optionS1 = find(D(car.positionIndex) == distToWareHouse(car.nowChoice));
        end
        if store(optionS1) == 0 %如果仓库里的货物已经送完
            car.state = 0;  %继续选路
            car.nowChoice = car.nowChoice + 1;
        else
            car.state = 1;
            car.positionIndex = optionS1;
        end
        car_update = car;
    end
end
%% 送货操作有关的函数

function [car_update] = allocation(car, D, alpha, m, n, productNeed, option)
    % option=1:需要判断是采取送货策略还是收货策略
    % option=0:无条件采取送货策略
    effectiveIndex = find(car.route==1);  %找出没走过的点(forward)
    indexForRecSpot = find(effectiveIndex>m);
    if car.nowChoice > length(indexForRecSpot) && car.backward == 0 %所有未走过的节点都不符合要求，则回溯
        car.backward = 1;
        car.backwardRoute = ones(1,m+n);
        car.backwardRoute(1:m) = car.route(1:m);   %仓库与回溯无关
        car.backwardRoute(indexForRecSpot)=0;     %回溯路径中的不可选节点（即未走过的节点）
        car.nowChoice = 1;
    end
    if car.backward == 0  %当前没有进行回溯
        route = car.route;
    else  %当前进行回溯，则从已走过的路径中进行选择
        route = car.backwardRoute;
    end
    curPos = car.positionIndex
    effectiveIndex = find(route == 1); %找出没走过的点
    distanceArray = D(curPos,:);    %该点与其他点之间的距离数组
    distToWareHouse = distanceArray(1:m);      %到仓库的距离
    distToRecSpot = distanceArray(m+1:m+n);    %到收货点的距离
    index1 = find(effectiveIndex<=m);  %指示未去过的仓库的位置
    index2 = find(effectiveIndex>m);   %指示未去过的收货点的位置
    minDist1 = min(distToWareHouse(index1));
    optionS1 = find(distToWareHouse == minDist1);  %当前最近的送货点
    DistOpt = sort(distToRecSpot(index2));     %对与没有经过的收货点的距离进行排序
    optionS2 = find(distToRecSpot == DistOpt(car.nowChoice));  %当前第nowChoice近的收货点
    minDist2 = DistOpt(car.nowChoice);        
    if minDist1 <= alpha * minDist2 || option == 0 %优先前往收货点送货
        productNeedCur = productNeed(optionS2,:);
        productToSend = find(W~=0);
        productForRec = find(productNeedCur~=0);
        if isempty(difference(productToSend, productForRec)) == 1 %货车上的货物不是该收货点所需
            car.state = 0; %继续选路
            car.nowChoice = car.nowChoice + 1;
        else
            car.state = 2; %去收货点送货
            car.positionIndex = m+optionS2;
        end
    else %去收货
        car.state = 1;
        car.positionIndex = optionS1;
    end
    car_update = car;
end
                    
                    
                
                