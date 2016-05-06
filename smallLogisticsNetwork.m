function [results]=smallLogisticsNetwork(wareHouseNum, recSpotNum, carCompanyPos, DcarToSpot, D, productNeed, store, parameter, carInformation)
% �������:
% description for variable
% wareHouseNum: �ֿ�����
% recSpotNum: �ջ�������
% carCompanyPos: ������˾��λ��
% DcarTospot:������˾��������֮��ľ���
% D: �Գƾ��󣬸�����֮�����̾���
% productNeed: �����ջ���Ը����ֿ������ÿ�д�����ջ���Ը����������
% store: ���ֿ�洢��
% parameter: ������������b1,b2�Լ�����alpha  
% carinformation: maxLoad --- ����ػ���
%                   num   --- ���ӵ�������Ԥ���Ľ����     
% �������result:
% result.route:ϸ�����飬��������·��
% result.flow:ϸ�����飬��route��Ӧ���������ڸ����ڵ��ϵ��ջ�/�ͻ���
%             ������һ������
    %% Initialization
    %% ��ţ���1��mΪ�ֿ⣬��m+1��m+nΪ�ջ���
    %%%%%%%%%%%%%%%%%%%%%%%%%%% ����������ֵ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m = wareHouseNum;  
    n = recSpotNum; 
    b1 = parameter.b1;
    b2 = parameter.b2; %��������
    alpha = parameter.alpha;  %����Ƚϲ���

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% car����ض��� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    car.index = 1;
    car.positionIndex = 0; %����λ�ñ�ţ�0-(n+m)��0��ʾ�ڻ�����˾��һ���ʾ������һվȡ��
    car.route = ones(1,m+n);  %��ǰ��������һ����δ�߹���·��,1����δ�߹���0�������߹�
    car.W = zeros(1,m);  %�����ϸ�����������
    car.maxLoad = carInformation.maxLoad; %����ػ���
    car.state = 0;  %������״̬������0��ʾѰ·��1��ʾȥ�ֿ��ջ���2��ʾȥ�ջ����ͻ���3��ʾ������ɣ�����
    car.nowChoiceWH = 1;   
    car.nowChoiceRS = 1;   
    % ��������������ʾ��ѡ���ջ�/�ͻ�·��ʱ������·�����ԭ������Ҳ������ʵĵ�
    % ����Ҫѡ��2nd,3rd,..���·���ĵ㣬���ò�����ֵ����·��������С���������
    car.relax = 0;  %�Ѿ�·�����нڵ㣬����ֻ��Ҫ�ѻ���ж�ؼ����������
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% results��ʼ�� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    results = cell(carInformation.num);
    for i = 1:carInformation.num
        results{i}.route = [];
        results{i}.flow = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ������� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     car.backwardRoute = []; %���ӻ���·���еĿ�ѡ�ڵ�                    %
    %     car.backward = 0;  %Ϊ1��ʾ�������ݻ��ƣ�Ϊ0��ʾ������               %
    % ���ػ��ʽ���b1��b2֮��ʱ��Ҫ�����ջ�or�ͻ�ѡ��                            %
    % �ٶ�����alpha�������ж��õ��Ĳ������ջ�����ַΪs1                         %
    % ����s1�ֿ��Ѿ�û���ˣ������ҪѰ����Զһ���s2                            %
    % ��ʱalphaԼ�����ܲ����㣬��ѡ��ֿ�s2ʱ���п��ܲ�����Ҫ�����ͻ�            %
    % ��ô�ٶ��ͻ�����p1�����ܸõ�����Ļ��ﳵ��û�У���ô����Ҫѡ���Զһ���p2  %
    % ��ʱs2��p2����alphaԼ�����ж����ó�����ѡ������δ֪�ġ�����                %
    % ��ô�������������������ڵ�ǰѡ�񲻿ɴ�ʱ����һ�����ŵ�ѡ��                 %
    %     car.nextChoiceForWH = -1;  %��һ���ֿ��ѡ��                        %
    %     car.nextChoiceForRS = -1;  %��һ���ջ����ѡ��                      %
    % ���ӵ�ǰ�ڿ�ѡ�ͻ����ϵ�ѡ��1��ʾ·����̣�                             %
    % ����һ�������ͻ����󣨼��ջ��㲻��Ҫ���ϻ��                            %
    % ��ʱ���ܻ�ѡ��ζ̣��������ζ�                                           %
    % ����������еĿ�ѡ·����û�ҵ������ͻ��ĵ㣬���������ݻ���                 %
    % Ȼ����Ѿ�ȥ�����ջ������ٸ���·�����ԭ��ѡ��                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while sum(sum(productNeed)) > 0   %���ջ��������δ��ȫ������ʱ����������ִ���ջ��ͻ�����
        switch car.state
            case 0,
                if sum(car.W)/car.maxLoad <b1  && car.relax == 0 %�������ջ�
                    [car_update] = collect(car, D, store, DcarToSpot, m, n);
                    car = car_update;
                elseif sum(car.W)/car.maxLoad < b2 && car.relax == 0  %������ֿ��������ͻ������Զ����������(�����ܸճ���)
                    option = 1;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, store, option);
                    car = car_update;
                elseif sum(car.W)/car.maxLoad > b2 || car.relax == 1    %�������ͻ�
                    option = 0;
                    [car_update]=allocation(car, D, alpha, m, n, productNeed, store, option);
                    car = car_update;
                end
            case 1,  %�ջ�
                % �᲻���������������������һ���������֮�����Ѿ�û��δ�߹��Ľڵ�
                % ����һ�����⣬������ջ���Ļ����Ѿ�ȫ���ͳ�ȥ��Ӧ��Ҫ��һ���ж�
                
                %%%%%%%%%%%%%%%%%%% �ػ����Ͳֿ�����ĸ��� %%%%%%%%%%%%%%%%%%
                restLoadAmount = car.maxLoad - sum(car.W);   %��װ�ص�������
                optionS1 = car.positionIndex;  %��ǰ���ӵ���ĵط�
                temp = min(restLoadAmount, store(optionS1));
                allocationAmount = temp - car.W(optionS1);
                store(optionS1) = store(optionS1) - allocationAmount;
                car.W(optionS1) = temp;
                car.state = 0;  %��������ѡ·
                car.route(optionS1) = 0;  %��Ǵ˽ڵ����߹�
                
                %%%%%%%%%%%%%%%%%%%%% route record %%%%%%%%%%%%%%%%%%%%%%%%
                flow = zeros(1,m);
                flow(optionS1) = allocationAmount;
                results{car.index}.route = [results{car.index}.route, optionS1];
                results{car.index}.flow = [results{car.index}.flow; flow];
                
                %%%%%%%%%%%%%%%%%%%%% ��������״̬�ĸ��� %%%%%%%%%%%%%%%%%%%
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                if isempty(find(car.route == 1))==1 %�Ѿ�����·���ߡ�
                    car.route = zeros(1,m+n);
                    car.route(m+1:m+n) = 1;
                    car.route(optionS1) = 0;  %��ǰ�ڵ㲻��ѡ����ʡ����ʱ��
                    car.relax = 1;
                end
                
            case 2,  %�ͻ�
                
                %%%%%%%%%%%%%%%%%%%%%%% ������أ���ʱȡ�� %%%%%%%%%%%%%%%%%
                % car.backward = 0;      %��ʱȡ�����ݻ���                 %
                % car.backwardRoute = []; %��ջ���·��                    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%%%% ���������ջ���������ĸ��� %%%%%%%%%%%%%%%%%%%
                optionS2 = car.positionIndex;
                relativeToRecSpot = optionS2 - m;  %���ջ����е����λ��
                temp = max(car.W-productNeed(relativeToRecSpot,:), zeros(1,m));  %ִ��ж������
                deliverAmount = temp - car.W;
                productNeed(relativeToRecSpot,:) = productNeed(relativeToRecSpot,:)+deliverAmount;
                
                %%%%%%%%%%%%%%%%%%%%% route record %%%%%%%%%%%%%%%%%%%%%%%%
                flow = deliverAmount;
                results{car.index}.route = [results{car.index}.route, optionS2];
                results{car.index}.flow = [results{car.index}.flow;flow];
                
                %%%%%%%%%%%%%%%%%%% ��������״̬�ĸ��� %%%%%%%%%%%%%%%%%%%%%%
                car.W = temp;
                car.route(optionS2) = 0;    %ע�⵱ǰ���±�optionS2�����ջ����е����λ��
                car.state = 0;
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                if isempty(find(car.route == 1))==1 %�Ѿ�����·���ߡ�
                    if sum(car.W) == 0  %����Ѿ���������򻻳�
                        car.state = 3;
                    else  %���������������ͻ�,����ѡ·����
                        car.route = zeros(1,m+n);
                        car.route(m+1:m+n) = 1;
                        car.route(optionS2) = 0;  %��ǰ�ڵ㲻��ѡ
                        car.relax = 1;
                    end
                end
                
            case 3,  %����
                car.index = car.index + 1;
                car.W = zeros(1,m);
                car.maxLoad = carInformation.maxLoad; %����ػ���
                car.state = 0;  %������״̬������0��ʾѰ·��1��ʾȥ�ֿ��ջ���2��ʾȥ�ջ����ͻ���3��ʾ������ɣ�����
                car.nowChoiceRS = 1;
                car.nowChoiceWH = 1;
                car.relax = 0;  %�Ѿ�·�����нڵ㣬����ֻ��Ҫ�ѻ���ж�ؼ����������
                
                %%%%%%%%%%%%%%%%%%%%%%%% ������أ���ʱȡ�� %%%%%%%%%%%%%%%%%%%%
                % car.backwardRoute = []; %���ӻ���·���еĿ�ѡ�ڵ�            %
                % car.backward = 0;  %Ϊ1��ʾ�������ݻ��ƣ�Ϊ0��ʾ������        %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end


%% �ջ������йصĺ���
% �������������δ�߹��Ĳֿⶼ�޻����գ���ó�������������״̬3
function [car_update] = collect(car, D, store, DcarToSpot, m, n)
    %%%%%%%%%%%%%%%%%%% �����ж��Ƿ�����δ�߹��Ľڵ㶼����ѡ�����ǣ�������ó����� %%%%%%%%%%%%%%%%
    effectiveIndex = find(car.route == 1); %�ҳ�û�߹��ĵ�(forward)
    indexForWareHouse = effectiveIndex(find(effectiveIndex<=m));  %��ֿ��й�
    if car.nowChoiceWH > length(indexForWareHouse)
        if sum(car.W) == 0
            car.state = 3;
        else
            car.relax = 1;
            car.state = 0;
            car.route = zeros(1,m+n);
            car.route(m+1:m+n) = 1;
        end    
    
    %%%%%%%%%%%%%%%%%%%%%% ��������ջ���������Ҫ�жϸòֿ��Ƿ��п�� %%%%%%%%%%%%%%%%%%%%%%%%
    else
        if car.positionIndex == 0   %��������ڹ�˾
            distToWareHouse = sort(DcarToSpot(indexForWareHouse)); %���ֿ�ľ����С��������(δ�߹���·��)           
            optionS1 = find(DcarToSpot == distToWareHouse(car.nowChoiceWH));  %�ҳ�·����̵ĵ�
        else
            distanceArray = D(car.positionIndex,:);  %�õ���������֮��ľ�������
            distToWareHouse = sort(distanceArray(indexForWareHouse));
            optionS1 = find(distanceArray == distToWareHouse(car.nowChoiceWH));
        end
        if store(optionS1) == 0 %����ֿ���Ļ����Ѿ�����
            car.state = 0;            %����ѡ·
            car.nowChoiceWH = car.nowChoiceWH + 1;
        else   %���򣬿��Խ����ͻ�
            car.state = 1;   %�ͻ�
            car.positionIndex = optionS1;   %����ͻ���ַ
        end
    end
    car_update = car;
end


%% �ͻ�/�ջ����� and �������ͻ� �����йصĺ���,��option��Ϊ����ѡ��
% �������������δ�߹����ջ��㶼����Ҫ���ϵĻ����ó�������������״̬3
% �������������δ�߹��Ĳֿⶼ�޻����գ���ó�ͬ��������������״̬3
function [car_update] = allocation(car, D, alpha, m, n, productNeed, store, option)
    % option=1:��Ҫ�ж��ǲ�ȡ�ͻ����Ի����ջ�����
    % option=0:��������ȡ�ͻ�����
    
    %%%%%%%%%%%%%%%%%%% �����ж��Ƿ�����δ�߹��Ľڵ㶼����ѡ�����ǣ�������ó����� %%%%%%%%%%%%%%%%
    effectiveIndex = find(car.route==1);  %�ҳ�û�߹��ĵ�(forward)
    indexForRecSpot = effectiveIndex(find(effectiveIndex>m));
    indexForWareHouse = effectiveIndex(find(effectiveIndex<=m));
    if car.nowChoiceWH > length(indexForWareHouse) || car.nowChoiceRS > length(indexForRecSpot)
        %����δ�߹��Ĳֿⶼ������Ҫ�����������
        car.nowChoiceWH = 1;
        car.nowChoiceRS = 1;
        if sum(car.W) == 0
            car.state = 3;
        else
            car.relax = 1;
            car.state = 0;
            car.route = ones(1,m+n);
            car.route(car.positionIndex) = 0;  %��ǰ�ڵ㲻�����ظ���
        end   
    else

%%%%%%%%%%%%%%%%%%%% ����Ĵ��������˼·��أ���ʱcancel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     if car.nowChoiceRS > length(indexForRecSpot) && car.backward ==                      % 
%     %����δ�߹����ջ��㶼������Ҫ�����������                                             %
%         car.backward = 1;                                                                %
%         car.backwardRoute = ones(1,m+n);                                                 % 
%         car.backwardRoute(1:m) = car.route(1:m);   %�ֿ�������޹�                        %  
%         car.backwardRoute(indexForRecSpot)=0;     %����·���еĲ���ѡ�ڵ㣨��δ�߹��Ľڵ㣩 %
%         car.nowChoiceRS = 1;                                                             % 
%     end                                                                                  %
%     if car.backward == 0  %��ǰû�н��л���                                               %
%         route = car.route;                                                               %
%     else  %��ǰ���л��ݣ�������߹���·���н���ѡ��                                         %
%         route = car.backwardRoute;                                                       %
%     end                                                                                  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
        %%%%%%%%%%%%%%%%%%%%%%%%% find "relative" minDist1 and minDist2 %%%%%%%%%%%%%%%%%%% 
        % �ҳ���ǰ��ѡ·���е�car.nowChoiceWH���Ĳֿ�
        % �Լ�car.nowChoiceRS�����ջ���
        % relativeToWH��relativeToRS������ڲֿ���ջ����еĶ�λ
        % ���вֿ����Զ�λ�ھ��Զ�λһ�����ջ������Զ�λ+m=���Զ�λ
        curPos = car.positionIndex;
%         effectiveIndex = find(car.route == 1); %�ҳ�û�߹��ĵ�
        distanceArray = D(curPos,:);    %�õ���������֮��ľ�������
        distToWareHouse = distanceArray(1:m);      %���ֿ�ľ���
        distToRecSpot = distanceArray(m+1:m+n);    %���ջ���ľ���
        index1 = effectiveIndex(find(effectiveIndex<=m));  %ָʾδȥ���Ĳֿ��λ��
        index2 = effectiveIndex(find(effectiveIndex>m));   %ָʾδȥ�����ջ����λ��
        if isempty(index2) == 1   %��������ǻ��вֿ�ûȥ�����������е��ͻ��㶼ȥ����
            minDist2 = inf;
            DistOpt1 = sort(distToWareHouse(index1));
            relativeToWH = find(distToWareHouse == DistOpt1(car.nowChoiceWH));  %��ǰ����Ĳֿ�
            minDist1 = DistOpt1(car.nowChoiceWH);
        else
            if isempty(index1) == 1 %��������ǻ����ͻ���ûȥ�����������еĲֿⶼȥ����
                minDist1 = inf;
                DistOpt2 = sort(distToRecSpot(index2-m));     %����û�о������ջ���ľ����������
                relativeToRS = find(distToRecSpot == DistOpt2(car.nowChoiceRS));  %��ǰ��nowChoice�����ջ���
                minDist2 = DistOpt2(car.nowChoiceRS);  
            else
                DistOpt1 = sort(distToWareHouse(index1));
                relativeToWH = find(distToWareHouse == DistOpt1(car.nowChoiceWH));  %��ǰ����Ĳֿ�
                minDist1 = DistOpt1(car.nowChoiceWH);  
                DistOpt2 = sort(distToRecSpot(index2-m));     %����û�о������ջ���ľ����������
                relativeToRS = find(distToRecSpot == DistOpt2(car.nowChoiceRS));  %��ǰ��nowChoice�����ջ���
                minDist2 = DistOpt2(car.nowChoiceRS);  
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%% �����ͻ���������Ҫ�жϸýڵ��Ƿ����%%%%%%%%%%%%%%%%%%%%%%%%%%
        if minDist2 <= alpha * minDist1 || option == 0 %����ǰ���ջ����ͻ�
            productNeedCur = productNeed(relativeToRS,:);
            productToSend = find(car.W~=0);
            productForRec = find(productNeedCur~=0);
            if isempty(intersect(productToSend, productForRec)) == 1 %�����ϵĻ��ﲻ�Ǹ��ջ�������
                car.state = 0; %����ѡ·
                car.nowChoiceRS = car.nowChoiceRS + 1;
    %             car.nextChoiceForRS =  find(distToRecSpot == DistOpt2(car.nowChoice)); %��һ���ֿ��ѡ��
            else
                car.state = 2; %ȥ�ջ����ͻ�
                car.positionIndex = m+relativeToRS;   %����ͻ���ַ
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%% �����ջ���������Ҫ�жϸòֿ��Ƿ��п�� %%%%%%%%%%%%%%%%%%%%%%%
        else %ȥ�ջ�
            if store(relativeToWH) == 0 %����ֿ���Ļ����Ѿ�����
                car.state = 0;  %����ѡ·
                car.nowChoiceWH = car.nowChoiceWH + 1;
            else
                car.state = 1;
                car.positionIndex = relativeToWH;     %����ջ���ַ
            end
        end
    end
    car_update = car;
end
                    
                    
                
                