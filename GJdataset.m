% Goetschlcks and Jacobs-blecha�����ݼ�
clc;clear;
xrange = [0 24000];   % �����귶Χ
yrange = [0 32000];   % �����귶Χ
repox = 12000;        % �ֿ�x����
repoy = 16000;        % �ֿ�y����
linehaulnum = 45;     % ǰ��ڵ����
backhaulnum = 45;      % ����ڵ����
carnum = 5;           % ����������
capacity = 5700;      % ������
Lx = zeros(linehaulnum, 1);   % ǰ��ڵ������
Ly = zeros(linehaulnum, 1);   % ǰ��ڵ�������
demandL = zeros(linehaulnum, 1);
Bx = zeros(backhaulnum, 1);   % ����ڵ������
By = zeros(backhaulnum, 1);   % ����ڵ�������
demandB = zeros(backhaulnum, 1);

% ǰ��ڵ����ꡢ��������
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

% ������ֵ
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
option.BPPl = 0;
option.BPPb = 0;
option.cluster4b = 1;
option.cluster4l = 1;
option.AP = 1;
option.drawbigcluster = 0;
option.draworigincluster = 0;
option.drawfinalrouting = 1;

% ִ�к���
[totalcost] = routingalgorithm(dataset, option)
    % dataset: Lx, Ly, demandL, Bx, By, demandB, capacity, repox, repoy,
    %          regionrange, colDiv, rowDiv, K
    %          Lx, Ly: linehaul�ڵ�ĺᡢ�����꣬Bx,ByΪbackhaul
    %          demandL: linehaul�ڵ�Ļ�������demandBΪbackhaul
    %          capacity: ������
    %          repox, repoy: �ֿ�ĺᡢ������
    %          regionrange: �۲������Χ
    %          colDiv,rowDiv: ���򻮷֣��ֱ��������ֿ����ͺ���ֿ���
    %          K: ��������
    % option: BPPl: =1, ����BPP�㷨������������(linehaul)
    %         BPPb: =1. ����BPP�㷨������������(backhaul)
    %         cluster4b: =1�����÷ִ��㷨��backhaul�ڵ���зִ�
    %         cluster4l: =1�����÷ִ��㷨��linehaul�ڵ���зִ�
    %         AP: =1. ʹ��assignment problem�㷨
    %         draworigincluster: =1, ����ʼ�طֲ�
    %         drawbigcluster: =1����backhaul��linehaul�ϲ���ķִؽ��
    %         drawfinalrouting: =1�� ������·��ͼ
