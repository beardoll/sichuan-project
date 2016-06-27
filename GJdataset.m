% Goetschlcks and Jacobs-blecha的数据集
clc;clear;
close all;
xrange = [0 24000];   % 横坐标范围
yrange = [0 32000];   % 纵坐标范围
repox = 12000;        % 仓库x坐标
repoy = 16000;        % 仓库y坐标

O;
load OPro;
PROID = 5;

% plot([Lx, Bx], [Ly,By],'o');
% axis([0 24000 0 32000]);
% grid on;
% set(gca,'xtick', 0:3000:24000, 'ytick',0:4000:32000); 

% 函数赋值
dataset.Lx = Lx;
dataset.Ly = Ly;
dataset.Bx = Bx;
dataset.By = By;
dataset.demandL = demandL;
dataset.demandB = demandB;
dataset.capacity = capacity(PROID);
dataset.regionrange = [xrange, yrange];
dataset.repox = repox;
dataset.repoy = repoy;
dataset.K = carnum(PROID);

option.cluster = 1;
option.drawbigcluster = 0;
option.draworigincluster = 0;
option.drawfinalrouting = 0;
option.localsearch = 1;


% [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, carnum(PROID), repox, repoy, capacity(PROID));
% plot(Lx, Ly, 'go');
% hold on;
% plot(Bx, By, 'r+');
% hold on;
% plot(CH(:,1), CH(:,2), 'b*');
% hold off;

[totalcost, final_path, routedemandL, routedemandB, alpha] = VRPB(dataset, option);
format short;
totalcost, alpha
                
% dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
%          regionrange, K
%          Lx, Ly: linehaul节点的横、纵坐标，Bx,By为backhaul
%          demandL: linehaul节点的货物绣球，demandB为backhaul
%          capacity: 车容量
%          repox, repoy: 仓库的横、纵坐标
%          regionrange: 观测的区域范围
%          K: 货车数量
% option: cluster: =1,使用分簇算法1.0，=2,使用分簇算法2.0
%         draworigincluster: =1, 画初始簇分布
%         drawbigcluster: =1，画backhaul和linehaul合并后的分簇结果
%         drawfinalrouting: =1， 画最终路径图
%         localsearch: =1, 使用localsearch
