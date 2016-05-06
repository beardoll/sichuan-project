function []=smallLogisticsNetwork(wareHouseNum, recSpotNum, carCompanyPos, DcarToSpot, D, productNeed, store, parameter, carinformation)
% description for variable
% wareHouseNum: �ֿ�����
% recSpotNum: �ջ�������
% carCompanyPos: ������˾��λ��
% DcarTospot:������˾��������֮��ľ���
% D: �Գƾ��󣬸�����֮�����̾���
% productNeed: �����ջ���Ը����ֿ������ÿ�д�����ջ���Ը����������
% store: ���ֿ�洢��
% parameter: ������������b1,b2�Լ�����alpha  
    %% Initialization
    %% ��ţ���1��mΪ�ֿ⣬��m+1��m+nΪ�ջ���
    m = wareHouseNum;  
    n = recSpotNum; 
    b1 = parameter.b1;
    b2 = parameter.b2; %��������
    alpha = parameter.b3;  %����Ƚϲ���

    % car����ض���
    car.index = 1;
    car.positionIndex = 0; %����λ�ñ�ţ�0-(n+m)��0��ʾ�ڻ�����˾��һ���ʾ������һվȡ��
    car.route = ones(1,m+n);  %��ǰ��������һ����δ�߹���·��,1����δ�߹���0�������߹�
    car.W = zeros(1,m);  %�����ϸ�����������
    car.maxLoad = carinformation.maxLoad; %����ػ���
    car.state = 0;  %������״̬������0��ʾѰ·��1��ʾȥ�ֿ��ջ���2��ʾȥ�ջ����ͻ���3��ʾ������ɣ�����
    car.backwardRoute = []; %���ӻ���·���еĿ�ѡ�ڵ�
    car.backward = 0;  %Ϊ1��ʾ�������ݻ��ƣ�Ϊ0��ʾ������
    car.nowChoice = 1;     
    car.relax = 0;  %�Ѿ�·�����нڵ㣬����ֻ��Ҫ�ѻ���ж�ؼ����������
    % ���ӵ�ǰ�ڿ�ѡ�ͻ����ϵ�ѡ��1��ʾ·����̣�����һ�������ͻ����󣨼��ջ��㲻��Ҫ���ϻ��
    % ��ʱ���ܻ�ѡ��ζ̣��������ζ�
    % ����������еĿ�ѡ·����û�ҵ������ͻ��ĵ㣬���������ݻ���
    % Ȼ����Ѿ�ȥ�����ջ������ٸ���·�����ԭ��ѡ��

    while sum(productNeed) > 0   %���ջ��������δ��ȫ������ʱ����������ִ���ջ��ͻ�����
        switch car.state
            case 0,
                if sum(W)/M <b1  && car.relax == 0 %�������ջ�
                    [car_update] = collect(car, D, store, DcarToSpot, m, n);
                    car = car_update;
                elseif sum(W)/M < b2 && car.relax == 0  %������ֿ��������ͻ������Զ����������(�����ܸճ���)
                    option = 1;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, option);
                    car = car_update;
                elseif sum(W)/M <= b2 || car.relax == 1    %�������ͻ�
                    option = 0;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, option);
                    car = car_update;
                end
            case 1,  %�ջ�
                % �᲻���������������������һ���������֮�����Ѿ�û��δ�߹��Ľڵ�
                % ����һ�����⣬������ջ���Ļ����Ѿ�ȫ���ͳ�ȥ��Ӧ��Ҫ��һ���ж�
                optionS1 = car.positionIndex;  %��ǰ���ӵ���ĵط�
                temp = min(car.W(optionS1)+store(optionS1), M);
                store(optionS1) = store(optionS1) - (temp - car.W(optionS1));
                car.W(optionS1) = temp;
                car.state = 0;  %��������ѡ·
                car.route(optionS1) = 0;  %��Ǵ˽ڵ����߹�
                car.nowChoice = 1;
                if length(find(car.route==1))==0 %�Ѿ�����·���ߡ���
                    car.route = zeros(1,m+n);
                    car.route(m+1:m+n) = 1;
                    car.route(optionS2+n) = 0;  %��ǰ�ڵ㲻��ѡ
                    car.relax = 1;
                end
            case 2,  %�ͻ�
                car.backward = 0;      %��ʱȡ�����ݻ���
                car.backwardRoute = []; %��ջ���·��
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % �����п��ܻ�ǣ�����ظ�ѡ������⣬�Ժ��ٿ��� %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                optionS2 = car.positionIndex;
                relativeToRecSpot = optionS2 - m;  %���ջ����е����λ��
                temp = max(car.W-productNeed(relativeToRecSpot,:), zeros(1,m));  %ִ��ж������
                productNeed(optionS2,:) = productNeed(relativeToRecSpo,:)-(car.W-temp);
                car.W = temp;
                car.route(optionS2) = 0;    %ע�⵱ǰ���±�optionS2�����ջ����е����λ��
                car.state = 0;
                car.nowChoice = 1;
                if length(find(car.route==1))==0 %�Ѿ�����·���ߡ�
                    if sum(car.W) == 0  %����Ѿ���������򻻳�
                        car.state = 3;
                    else  %���������������ͻ�,����ѡ·����
                        car.route = zeros(1,m+n);
                        car.route(m+1:m+n) = 1;
                        car.route(optionS2+n) = 0;  %��ǰ�ڵ㲻��ѡ
                        car.relax = 1;
                    end
                end
            case 3,  %����
                car.index = car.index + 1;
                car.W = 0;
                car.maxLoad = ; %����ػ���
                car.state = 0;  %������״̬������0��ʾѰ·��1��ʾȥ�ֿ��ջ���2��ʾȥ�ջ����ͻ���3��ʾ������ɣ�����
                car.backwardRoute = []; %���ӻ���·���еĿ�ѡ�ڵ�
                car.backward = 0;  %Ϊ1��ʾ�������ݻ��ƣ�Ϊ0��ʾ������
                car.nowChoice = 1; 
                car.relax = 0;  %�Ѿ�·�����нڵ㣬����ֻ��Ҫ�ѻ���ж�ؼ����������
        end
    end
end


%% �ջ������йصĺ���
% �������������δ�߹��Ĳֿⶼ�޻����գ���ó��������
function [car_update] = collect(car, D, store, DcarToSpot, m, n)
    effectiveIndex = find(car.route == 1); %�ҳ�û�߹��ĵ�(forward)
    indexForWareHouse = find(effectiveIndex<=m);  %��ֿ��й�
    if car.nowChoice > length(indexForWareHouse)
        car.state = 3;
    else
        if car.positionIndex == 0   %��������ڹ�˾
            distToWareHouse = sort(DcarToSpot(1:m)); %���ֿ�ľ����С��������           
            optionS1 = find(DcarToSpot == distToWareHouse(car.nowChoice));  %�ҳ�·����̵ĵ�
        else
            distanceArray = D(car.positionIndex,:);  %�õ���������֮��ľ�������
            distToWareHouse = sort(distanceArray(1:m));
            optionS1 = find(D(car.positionIndex) == distToWareHouse(car.nowChoice));
        end
        if store(optionS1) == 0 %����ֿ���Ļ����Ѿ�����
            car.state = 0;  %����ѡ·
            car.nowChoice = car.nowChoice + 1;
        else
            car.state = 1;
            car.positionIndex = optionS1;
        end
        car_update = car;
    end
end
%% �ͻ������йصĺ���

function [car_update] = allocation(car, D, alpha, m, n, productNeed, option)
    % option=1:��Ҫ�ж��ǲ�ȡ�ͻ����Ի����ջ�����
    % option=0:��������ȡ�ͻ�����
    effectiveIndex = find(car.route==1);  %�ҳ�û�߹��ĵ�(forward)
    indexForRecSpot = find(effectiveIndex>m);
    if car.nowChoice > length(indexForRecSpot) && car.backward == 0 %����δ�߹��Ľڵ㶼������Ҫ�������
        car.backward = 1;
        car.backwardRoute = ones(1,m+n);
        car.backwardRoute(1:m) = car.route(1:m);   %�ֿ�������޹�
        car.backwardRoute(indexForRecSpot)=0;     %����·���еĲ���ѡ�ڵ㣨��δ�߹��Ľڵ㣩
        car.nowChoice = 1;
    end
    if car.backward == 0  %��ǰû�н��л���
        route = car.route;
    else  %��ǰ���л��ݣ�������߹���·���н���ѡ��
        route = car.backwardRoute;
    end
    curPos = car.positionIndex
    effectiveIndex = find(route == 1); %�ҳ�û�߹��ĵ�
    distanceArray = D(curPos,:);    %�õ���������֮��ľ�������
    distToWareHouse = distanceArray(1:m);      %���ֿ�ľ���
    distToRecSpot = distanceArray(m+1:m+n);    %���ջ���ľ���
    index1 = find(effectiveIndex<=m);  %ָʾδȥ���Ĳֿ��λ��
    index2 = find(effectiveIndex>m);   %ָʾδȥ�����ջ����λ��
    minDist1 = min(distToWareHouse(index1));
    optionS1 = find(distToWareHouse == minDist1);  %��ǰ������ͻ���
    DistOpt = sort(distToRecSpot(index2));     %����û�о������ջ���ľ����������
    optionS2 = find(distToRecSpot == DistOpt(car.nowChoice));  %��ǰ��nowChoice�����ջ���
    minDist2 = DistOpt(car.nowChoice);        
    if minDist1 <= alpha * minDist2 || option == 0 %����ǰ���ջ����ͻ�
        productNeedCur = productNeed(optionS2,:);
        productToSend = find(W~=0);
        productForRec = find(productNeedCur~=0);
        if isempty(difference(productToSend, productForRec)) == 1 %�����ϵĻ��ﲻ�Ǹ��ջ�������
            car.state = 0; %����ѡ·
            car.nowChoice = car.nowChoice + 1;
        else
            car.state = 2; %ȥ�ջ����ͻ�
            car.positionIndex = m+optionS2;
        end
    else %ȥ�ջ�
        car.state = 1;
        car.positionIndex = optionS1;
    end
    car_update = car;
end
                    
                    
                
                