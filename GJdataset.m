% Goetschlcks and Jacobs-blecha�����ݼ�
clc;clear;
close all;
xrange = [0 24000];   % �����귶Χ
yrange = [0 32000];   % �����귶Χ
repox = 12000;        % �ֿ�x����
repoy = 16000;        % �ֿ�y����

O;
load OPro;
PROID = 5;

% plot([Lx, Bx], [Ly,By],'o');
% axis([0 24000 0 32000]);
% grid on;
% set(gca,'xtick', 0:3000:24000, 'ytick',0:4000:32000); 

% ������ֵ
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
%          Lx, Ly: linehaul�ڵ�ĺᡢ�����꣬Bx,ByΪbackhaul
%          demandL: linehaul�ڵ�Ļ�������demandBΪbackhaul
%          capacity: ������
%          repox, repoy: �ֿ�ĺᡢ������
%          regionrange: �۲������Χ
%          K: ��������
% option: cluster: =1,ʹ�÷ִ��㷨1.0��=2,ʹ�÷ִ��㷨2.0
%         draworigincluster: =1, ����ʼ�طֲ�
%         drawbigcluster: =1����backhaul��linehaul�ϲ���ķִؽ��
%         drawfinalrouting: =1�� ������·��ͼ
%         localsearch: =1, ʹ��localsearch
