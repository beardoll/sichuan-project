function [results]=smallLogisticsNetwork(wareHouseNum, recSpotNum, carCompanyPos, DcarToSpot, D, productNeed, store, parameter, carInformation)
% 输入参数:
% description for variable
% wareHouseNum: 仓库数量
% recSpotNum: 收货点数量
% carCompanyPos: 货车公司的位置
% DcarTospot:汽车公司到各个点之间的距离
% D: 对称矩阵，各个点之间的最短距离
% productNeed: 各个收货点对各个仓库的需求，每行代表该收货点对各货物的需求
% store: 各仓库存储量
% parameter: 包含两条界限b1,b2以及参数alpha  
% carinformation: maxLoad --- 最大载货量
%                   num   --- 车子的数量（预估的结果）     
% 输出参数result:
% result.route:细胞数组，各辆车的路径
% result.flow:细胞数组，与route对应，各辆车在各个节点上的收货/送货量
%             该量是一个矩阵
    %% Initialization
    %% 编号：从1到m为仓库，从m+1到m+n为收货点
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 基本参数赋值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m = wareHouseNum;  
    n = recSpotNum; 
    b1 = parameter.b1;
    b2 = parameter.b2; %两条界线
    alpha = parameter.alpha;  %距离比较参数

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% car的相关定义 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    car.index = 1;
    car.positionIndex = 0; %货车位置编号，0-(n+m)，0表示在货车公司，一般表示车子下一站取出
    car.route = ones(1,m+n);  %当前货车（第一辆）未走过的路径,1代表未走过，0代表已走过
    car.W = zeros(1,m);  %货车上各类货物的数量
    car.maxLoad = carInformation.maxLoad; %最大载货量
    car.state = 0;  %汽车的状态变量，0表示寻路，1表示去仓库收货，2表示去收货点送货，3表示任务完成，换车
    car.nowChoiceWH = 1;   
    car.nowChoiceRS = 1;   
    % 以上两个参数表示在选择收货/送货路径时，根据路径最短原则可能找不到合适的点
    % 则需要选择2nd,3rd,..最短路径的点，而该参数的值就是路径长度由小到大的排名
    car.relax = 0;  %已经路过所有节点，现在只需要把货物卸载即可完成任务
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% results初始化 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    results = cell(carInformation.num);
    for i = 1:carInformation.num
        results{i}.route = [];
        results{i}.flow = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 回溯相关 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     car.backwardRoute = []; %车子回溯路径中的可选节点                    %
    %     car.backward = 0;  %为1表示触发回溯机制，为0表示不触发               %
    % 当载货率介于b1和b2之间时，要进行收货or送货选择                            %
    % 假定根据alpha参数的判定得到的策略是收货，地址为s1                         %
    % 但是s1仓库已经没货了，因此需要寻找稍远一点的s2                            %
    % 此时alpha约束可能不满足，即选择仓库s2时，有可能策略是要进行送货            %
    % 那么假定送货点是p1，可能该点所需的货物车上没有，那么有需要选择更远一点的p2  %
    % 此时s2和p2根据alpha约束的判定所得出来的选择又是未知的。。。                %
    % 那么下面两个变量就是用于当前选择不可达时，下一个次优的选择                 %
    %     car.nextChoiceForWH = -1;  %下一个仓库的选择                        %
    %     car.nextChoiceForRS = -1;  %下一个收货点的选择                      %
    % 车子当前在可选送货点上的选择，1表示路径最短，                             %
    % 但不一定满足送货需求（即收货点不需要车上货物）                            %
    % 这时可能会选择次短，甚至更次短                                           %
    % 如果搜完所有的可选路径都没找到可以送货的点，则启动回溯机制                 %
    % 然后从已经去过的收货点中再根据路径最短原则选择                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while sum(sum(productNeed)) > 0   %当收货点的需求未被全部满足时，货车继续执行收货送货操作
        switch car.state
            case 0,
                if sum(car.W)/car.maxLoad <b1  && car.relax == 0 %无条件收货
                    [car_update] = collect(car, D, store, DcarToSpot, m, n);
                    car = car_update;
                elseif sum(car.W)/car.maxLoad < b2 && car.relax == 0  %根据与仓库距离和与送货点距离远近来做决策(不可能刚出发)
                    option = 1;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, store, option);
                    car = car_update;
                elseif sum(car.W)/car.maxLoad > b2 || car.relax == 1    %无条件送货
                    option = 0;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, store, option);
                    car = car_update;
                end
            case 1,  %收货
                % 会不会出现这样的情况：在最后一个点收完货之后发现已经没有未走过的节点
                % 还有一个问题，如果该收货点的货物已经全部送出去，应该要做一个判断
                
                %%%%%%%%%%%%%%%%%%% 载货量和仓库存量的更新 %%%%%%%%%%%%%%%%%%
                restLoadAmount = car.maxLoad - sum(car.W);   %可装载的最大货量
                optionS1 = car.positionIndex;  %当前车子到达的地方
                temp = min(restLoadAmount, store(optionS1));
                allocationAmount = temp - car.W(optionS1);
                store(optionS1) = store(optionS1) - allocationAmount;
                car.W(optionS1) = temp;
                car.state = 0;  %继续进行选路
                car.route(optionS1) = 0;  %标记此节点已走过
                
                %%%%%%%%%%%%%%%%%%%%% route record %%%%%%%%%%%%%%%%%%%%%%%%
                flow = zeros(1,m);
                flow(optionS1) = allocationAmount;
                results{car.index}.route = [results{car.index}.route, optionS1];
                results{car.index}.flow = [results{car.index}.flow; flow];
                
                %%%%%%%%%%%%%%%%%%%%% 货车其他状态的更新 %%%%%%%%%%%%%%%%%%%
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                if isempty(find(car.route == 1))==1 %已经“无路可走”
                    car.route = zeros(1,m+n);
                    car.route(m+1:m+n) = 1;
                    car.route(optionS1) = 0;  %当前节点不可选，节省搜索时间
                    car.relax = 1;
                end
                
            case 2,  %送货
                
                %%%%%%%%%%%%%%%%%%%%%%% 回溯相关，暂时取消 %%%%%%%%%%%%%%%%%
                % car.backward = 0;      %暂时取消回溯机制                 %
                % car.backwardRoute = []; %清空回溯路径                    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%%%% 车载量与收货点货物量的更新 %%%%%%%%%%%%%%%%%%%
                optionS2 = car.positionIndex;
                relativeToRecSpot = optionS2 - m;  %在收货点中的相对位置
                temp = max(car.W-productNeed(relativeToRecSpot,:), zeros(1,m));  %执行卸货操作
                deliverAmount = temp - car.W;
                productNeed(relativeToRecSpot,:) = productNeed(relativeToRecSpot,:)+deliverAmount;
                
                %%%%%%%%%%%%%%%%%%%%% route record %%%%%%%%%%%%%%%%%%%%%%%%
                flow = deliverAmount;
                results{car.index}.route = [results{car.index}.route, optionS2];
                results{car.index}.flow = [results{car.index}.flow;flow];
                
                %%%%%%%%%%%%%%%%%%% 货车其他状态的更新 %%%%%%%%%%%%%%%%%%%%%%
                car.W = temp;
                car.route(optionS2) = 0;    %注意当前的下标optionS2是在收货点中的相对位置
                car.state = 0;
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                if isempty(find(car.route == 1))==1 %已经“无路可走”
                    if sum(car.W) == 0  %如果已经送完货，则换车
                        car.state = 3;
                    else  %否则，启动无条件送货,进入选路操作
                        car.route = zeros(1,m+n);
                        car.route(m+1:m+n) = 1;
                        car.route(optionS2) = 0;  %当前节点不可选
                        car.relax = 1;
                    end
                end
                
            case 3,  %换车
                car.index = car.index + 1;
                car.W = zeros(1,m);
                car.maxLoad = carInformation.maxLoad; %最大载货量
                car.state = 0;  %汽车的状态变量，0表示寻路，1表示去仓库收货，2表示去收货点送货，3表示任务完成，换车
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                car.relax = 0;  %已经路过所有节点，现在只需要把货物卸载即可完成任务
                
                %%%%%%%%%%%%%%%%%%%%%%%% 回溯相关，暂时取消 %%%%%%%%%%%%%%%%%%%%
                % car.backwardRoute = []; %车子回溯路径中的可选节点            %
                % car.backward = 0;  %为1表示触发回溯机制，为0表示不触发        %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end


%% 收货操作有关的函数
% 如果搜索到所有未走过的仓库都无货可收，则该车进入结束任务的状态3
function [car_update] = collect(car, D, store, DcarToSpot, m, n)
    %%%%%%%%%%%%%%%%%%% 首先判断是否所有未走过的节点都不可选，若是，则结束该车任务 %%%%%%%%%%%%%%%%
    effectiveIndex = find(car.route == 1); %找出没走过的点(forward)
    indexForWareHouse = effectiveIndex(find(effectiveIndex<=m));  %与仓库有关
    if car.nowChoiceWH > length(indexForWareHouse)
        if sum(car.W) == 0
            car.state = 3;
        else
            car.relax = 1;
            car.state = 0;
            car.route = zeros(1,m+n);
            car.route(m+1:m+n) = 1;
        end    
    
    %%%%%%%%%%%%%%%%%%%%%% 否则进行收货，但是需要判断该仓库是否还有库存 %%%%%%%%%%%%%%%%%%%%%%%%
    else
        if car.positionIndex == 0   %如果货车在公司
            distToWareHouse = sort(DcarToSpot(indexForWareHouse)); %到仓库的距离从小到大排列(未走过的路径)           
            optionS1 = find(DcarToSpot == distToWareHouse(car.nowChoiceWH));  %找出路径最短的点
        else
            distanceArray = D(car.positionIndex,:);  %该点与其他点之间的距离数组
            distToWareHouse = sort(distanceArray(indexForWareHouse));
            optionS1 = find(distanceArray == distToWareHouse(car.nowChoiceWH));
        end
        if store(optionS1) == 0 %如果仓库里的货物已经送完
            car.state = 0;            %继续选路
            car.nowChoiceWH = car.nowChoiceWH + 1;
        else   %否则，可以进行送货
            car.state = 1;   %送货
            car.positionIndex = optionS1;   %标记送货地址
        end
    end
    car_update = car;
end


%% 送货/收货抉择 and 无条件送货 操作有关的函数,以option作为类型选额
% 如果搜索到所有未走过的收货点都不需要车上的货物，则该车进入结束任务的状态3
% 如果搜索到所有未走过的仓库都无货可收，则该车同样进入结束任务的状态3
function [car_update] = allocation(car, D, alpha, m, n, productNeed, store, option)
    % option=1:需要判断是采取送货策略还是收货策略
    % option=0:无条件采取送货策略
    
    %%%%%%%%%%%%%%%%%%% 首先判断是否所有未走过的节点都不可选，若是，则结束该车任务 %%%%%%%%%%%%%%%%
    effectiveIndex = find(car.route==1);  %找出没走过的点(forward)
    indexForRecSpot = effectiveIndex(find(effectiveIndex>m));
    indexForWareHouse = effectiveIndex(find(effectiveIndex<=m));
    if car.nowChoiceWH > length(indexForWareHouse) || car.nowChoiceRS > length(indexForRecSpot)
        %所有未走过的仓库都不符合要求，则任务结束
        car.nowChoiceWH = 1;
        car.nowChoiceRS = 1;
        if sum(car.W) == 0
            car.state = 3;
        else
            car.relax = 1;
            car.state = 0;
            car.route = ones(1,m+n);
            car.route(car.positionIndex) = 0;  %当前节点不可以重复走
        end   
    else

%%%%%%%%%%%%%%%%%%%% 下面的代码与回溯思路相关，暂时cancel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     if car.nowChoiceRS > length(indexForRecSpot) && car.backward ==                      % 
%     %所有未走过的收货点都不符合要求，则任务结束                                             %
%         car.backward = 1;                                                                %
%         car.backwardRoute = ones(1,m+n);                                                 % 
%         car.backwardRoute(1:m) = car.route(1:m);   %仓库与回溯无关                        %  
%         car.backwardRoute(indexForRecSpot)=0;     %回溯路径中的不可选节点（即未走过的节点） %
%         car.nowChoiceRS = 1;                                                             % 
%     end                                                                                  %
%     if car.backward == 0  %当前没有进行回溯                                               %
%         route = car.route;                                                               %
%     else  %当前进行回溯，则从已走过的路径中进行选择                                         %
%         route = car.backwardRoute;                                                       %
%     end                                                                                  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
        %%%%%%%%%%%%%%%%%%%%%%%%% find "relative" minDist1 and minDist2 %%%%%%%%%%%%%%%%%%% 
        % 找出当前可选路径中第car.nowChoiceWH近的仓库
        % 以及car.nowChoiceRS近的收货点
        % relativeToWH和relativeToRS是相对于仓库和收货点中的定位
        % 其中仓库的相对定位于绝对定位一样，收货点的相对定位+m=绝对定位
        curPos = car.positionIndex;
%         effectiveIndex = find(car.route == 1); %找出没走过的点
        distanceArray = D(curPos,:);    %该点与其他点之间的距离数组
        distToWareHouse = distanceArray(1:m);      %到仓库的距离
        distToRecSpot = distanceArray(m+1:m+n);    %到收货点的距离
        index1 = effectiveIndex(find(effectiveIndex<=m));  %指示未去过的仓库的位置
        index2 = effectiveIndex(find(effectiveIndex>m));   %指示未去过的收货点的位置
        if isempty(index2) == 1   %这种情况是还有仓库没去过，但是所有的送货点都去过了
            minDist2 = inf;
            DistOpt1 = sort(distToWareHouse(index1));
            relativeToWH = find(distToWareHouse == DistOpt1(car.nowChoiceWH));  %当前最近的仓库
            minDist1 = DistOpt1(car.nowChoiceWH);
        else
            if isempty(index1) == 1 %这种情况是还有送货点没去过，但是所有的仓库都去过了
                minDist1 = inf;
                DistOpt2 = sort(distToRecSpot(index2-m));     %对与没有经过的收货点的距离进行排序
                relativeToRS = find(distToRecSpot == DistOpt2(car.nowChoiceRS));  %当前第nowChoice近的收货点
                minDist2 = DistOpt2(car.nowChoiceRS);  
            else
                DistOpt1 = sort(distToWareHouse(index1));
                relativeToWH = find(distToWareHouse == DistOpt1(car.nowChoiceWH));  %当前最近的仓库
                minDist1 = DistOpt1(car.nowChoiceWH);  
                DistOpt2 = sort(distToRecSpot(index2-m));     %对与没有经过的收货点的距离进行排序
                relativeToRS = find(distToRecSpot == DistOpt2(car.nowChoiceRS));  %当前第nowChoice近的收货点
                minDist2 = DistOpt2(car.nowChoiceRS);  
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%% 优先送货，但是需要判断该节点是否可送%%%%%%%%%%%%%%%%%%%%%%%%%%
        if minDist2 <= alpha * minDist1 || option == 0 %优先前往收货点送货
            productNeedCur = productNeed(relativeToRS,:);
            productToSend = find(car.W~=0);
            productForRec = find(productNeedCur~=0);
            if isempty(intersect(productToSend, productForRec)) == 1 %货车上的货物不是该收货点所需
                car.state = 0; %继续选路
                car.nowChoiceRS = car.nowChoiceRS + 1;
    %             car.nextChoiceForRS =  find(distToRecSpot == DistOpt2(car.nowChoice)); %下一个仓库的选择
            else
                car.state = 2; %去收货点送货
                car.positionIndex = m+relativeToRS;   %标记送货地址
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%% 优先收货，但是需要判断该仓库是否还有库存 %%%%%%%%%%%%%%%%%%%%%%%
        else %去收货
            if store(relativeToWH) == 0 %如果仓库里的货物已经送完
                car.state = 0;  %继续选路
                car.nowChoiceWH = car.nowChoiceWH + 1;
            else
                car.state = 1;
                car.positionIndex = relativeToWH;     %标记收货地址
            end
        end
    end
    car_update = car;
end
                    
                    
                
                