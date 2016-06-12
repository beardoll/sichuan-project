% Goetschlcks and Jacobs-blecha�����ݼ�
clc;clear;
xrange = [0 24000];   % �����귶Χ
yrange = [0 32000];   % �����귶Χ
repox = 12000;        % �ֿ�x����
repoy = 16000;        % �ֿ�y����

K;
load KPro;
PROID = 2;

% ������ֵ
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
%          Lx, Ly: linehaul�ڵ�ĺᡢ�����꣬Bx,ByΪbackhaul
%          demandL: linehaul�ڵ�Ļ�������demandBΪbackhaul
%          capacity: ������
%          repox, repoy: �ֿ�ĺᡢ������
%          regionrange: �۲������Χ
%          colDiv,rowDiv: ���򻮷֣��ֱ��������ֿ����ͺ���ֿ���
%          K: ��������
% option: cluster: =1,ʹ�÷ִ��㷨1.0��=2,ʹ�÷ִ��㷨2.0
%         draworigincluster: =1, ����ʼ�طֲ�
%         drawbigcluster: =1����backhaul��linehaul�ϲ���ķִؽ��
%         drawfinalrouting: =1�� ������·��ͼ
%         localsearch: =1, ʹ��localsearch
