% Goetschlcks and Jacobs-blecha的数据集
clc;clear;
xrange = [0 24000];   % 横坐标范围
yrange = [0 32000];   % 纵坐标范围
repox = 12000;        % 仓库x坐标
repoy = 16000;        % 仓库y坐标

K;
load KPro;
PROID = 2;

% 函数赋值
dataset.Lx = Lx;
dataset.Ly = Ly;
dataset.Bx = Bx;
dataset.By = By;
dataset.demandL = demandL;
dataset.demandB = demandB;
dataset.capacity = capacity(PROID);
dataset.regionrange = [xrange, yrange];
dataset.colDiv = 4;
dataset.rowDiv = 4;
dataset.repox = repox;
dataset.repoy = repoy;
dataset.K = carnum(PROID);

option.cluster = 1;
option.drawbigcluster = 0;
option.draworigincluster = 1;
option.drawfinalrouting = 1;
option.localsearch = 0;

[totalcost, final_path] = routingalgorithm(dataset, option)
                
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
