% Goetschlcks and Jacobs-blecha的数据集
clc;clear;
xrange = [0 24000];   % 横坐标范围
yrange = [0 32000];   % 纵坐标范围
repox = 12000;        % 仓库x坐标
repoy = 16000;        % 仓库y坐标

testdata = [
            20 20 2600 5;
            30 8 1700 12;
            30 15 2650 7;
            30 30 3000 6;
            45 12 2700 10;
            45 23 5100 5;
            45 45 4000 7;
            75 19 5600 8;
            75 38 5200 9;
            75 75 5000 9;
            100 25 6200 9;
            100 50 8500 8];

for kk = 1: size(testdata,1)
    cdata = testdata(kk,:);
    linehaulnum = cdata(1);     % 前向节点个数
    backhaulnum = cdata(2);      % 后向节点个数
    carnum = cdata(4);           % 货车车辆数
    capacity = cdata(3);      % 车容量
    Lx = zeros(linehaulnum, 1);   % 前向节点横坐标
    Ly = zeros(linehaulnum, 1);   % 前向节点纵坐标
    demandL = zeros(linehaulnum, 1);
    Bx = zeros(backhaulnum, 1);   % 后向节点横坐标
    By = zeros(backhaulnum, 1);   % 后向节点纵坐标
    demandB = zeros(backhaulnum, 1);
    totalcost = inf;
    
    for testcount = 1:100
    % 前向节点坐标、货物需求
        for i = 1:linehaulnum
            Lx(i) = rand*(xrange(2)-xrange(1))+xrange(1);
            Ly(i) = rand*(yrange(2)-yrange(1))+yrange(1);
            demandL(i) = normrnd(500,200);
        end

        for i = 1:backhaulnum
            Bx(i) = rand*(xrange(2)-xrange(1))+xrange(1);
            By(i) = rand*(yrange(2)-yrange(1))+yrange(1);
            demandB(i) = normrnd(500,200);
        end

        % 函数赋值
        dataset.Lx = Lx;
        dataset.Ly = Ly;
        dataset.Bx = Bx;
        dataset.By = By;
        dataset.demandL = demandL;
        dataset.demandB = demandB;
        dataset.capacity = capacity;
        dataset.regionrange = [xrange, yrange];
        dataset.colDiv = 4;
        dataset.rowDiv = 4;
        dataset.repox = repox;
        dataset.repoy = repoy;
        dataset.K = carnum;

        option.cluster = 2;
        option.drawbigcluster = 0;
        option.draworigincluster = 0;
        option.drawfinalrouting = 0;
        option.localsearch = 1;


        % 执行函数
        [totalcost1, final_path] = routingalgorithm(dataset, option);
        if totalcost1 < totalcost
            totalcost = totalcost1;
            pathx = final_path;
        end
    end
    filename = ['data', num2str(kk)];
    save(filename, 'totalcost', 'pathx');
end
        
        
        
        
        % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
        %          regionrange, colDiv, rowDiv, K
        %          Lx, Ly: linehaul节点的横、纵坐标，Bx,By为backhaul
        %          demandL: linehaul节点的货物绣球，demandB为backhaul
        %          capacity: 车容量
        %          repox, repoy: 仓库的横、纵坐标
        %          regionrange: 观测的区域范围
        %          colDiv,rowDiv: 区域划分，分别代表纵向分块数和横向分块数
        %          K: 货车数量
        % option: cluster: =1,使用分簇算法1.0，=2,使用分簇算法2.0
        %         draworigincluster: =1, 画初始簇分布
        %         drawbigcluster: =1，画backhaul和linehaul合并后的分簇结果
        %         drawfinalrouting: =1， 画最终路径图
        %         localsearch: =1, 使用localsearch
