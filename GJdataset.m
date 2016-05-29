% Goetschlcks and Jacobs-blecha�����ݼ�
clc;clear;
xrange = [0 24000];   % �����귶Χ
yrange = [0 32000];   % �����귶Χ
repox = 12000;        % �ֿ�x����
repoy = 16000;        % �ֿ�y����

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
    linehaulnum = cdata(1);     % ǰ��ڵ����
    backhaulnum = cdata(2);      % ����ڵ����
    carnum = cdata(4);           % ����������
    capacity = cdata(3);      % ������
    Lx = zeros(linehaulnum, 1);   % ǰ��ڵ������
    Ly = zeros(linehaulnum, 1);   % ǰ��ڵ�������
    demandL = zeros(linehaulnum, 1);
    Bx = zeros(backhaulnum, 1);   % ����ڵ������
    By = zeros(backhaulnum, 1);   % ����ڵ�������
    demandB = zeros(backhaulnum, 1);
    totalcost = inf;
    
    for testcount = 1:100
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

        option.cluster = 2;
        option.drawbigcluster = 0;
        option.draworigincluster = 0;
        option.drawfinalrouting = 0;
        option.localsearch = 1;


        % ִ�к���
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
