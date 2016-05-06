m = wareHouseNum;  %�ֿ�����
n = recPointNum;   %�ջ�������
%% Initialization
%% ��ţ���1��mΪ�ֿ⣬��m+1��m+nΪ�ջ���
carCompanyPos.x = ;
carCompanyPos.y = ;  %������˾��λ��
spot = cell(1,n+m);
for i = 1:n+m
    spot{i}.x = ;
    spot{i}.y = ;  %�������x��y���꣬��ʵ�ʾ��벻�򵥵��Լ��ξ���������
end
DcarToSpot = zeros(1,n+m);  %������˾��������֮��ľ���
D = zeros(m+n, m+n); %�Գƾ��󣬸�����֮�����̾���
store = zeros(1,m);  %���ֿ�洢��;
productNeed = cell(1,n); %������Ը����ֿ������ÿ��Ԫ������һ��mά����
Route = ones(1,m+n); %��ǰ��������һ����δ�߹���·��,1����δ�߹���0�������߹�
W = zeros(1,m);  %�����ϸ�����������
maxLoad = ;   %����ػ���
b1 = ;
b2 = ; %��������
alpha = ;  %����Ƚϲ���
carStack = 1; %��¼��ǰ�������Ļ������
carPositionIndex = 0;%����λ�ñ�ţ�0-(n+m)��0��ʾ�ڻ�����˾

%% applying the statechart
while sum(store) > 0  %�㷨ִ�������еĻ��ﶼ�˳�ȥΪֹ
    effectiveIndex = find(route == 1); %�ҳ�û�߹��ĵ�
    if sum(W)/M <b1  %�������ͻ�
        if carPositionIndex == 0
            minDist = min(DcarToSpot(effectiveIndex));
            arrSpot = find(DcarToSpot == minDist);  %�ҳ�·����̵ĵ�
        else
            distanceArray = D(carPositionIndex,:);  %�õ���������֮��ľ�������
            minDist = min(distanceArray(effectiveIndex));
            arrSpot = find(distanceArray == minDist); %�ҳ�·����̵ĵ�
        end
        temp = min(W(arrSpot)+store(arrSpot), M);
        store(arrSpot) = store(arrSpot) - (temp - W(arrSpot));
        W(arrSpot) = temp;
        route(arrSpot) = 0;
        carPositionIndex = arrSpot;
    else
        if sum(W)/M < b2 %������ֿ��������ͻ������Զ����������(�����ܸճ���)
            distArr = D(carPositionIndex,:);
            distToWareHouse = distArr(1:m);
            distToRecSpot = distArr(m+1:m+n);
            index1 = find(effectiveIndex<=m);  %�ֿ����ͻ���֮��ķֽ���
            index2 = find(effectiveIndex>m);
            minDist1 = min(distToWareHouse(index1));
            optionS1 = find(distToWareHouse == minDist1);  %��ǰ������ͻ���
            nowChoice = 1;   %��ѡ��������ջ���
            DistOpt = sort(distToRecSpot(index2));     %����û�о������ջ���ľ����������
            optionS2 = find(distToRecSpot == DistOpt(nowChoice));  %��ǰ������ջ���
            success = 0;
            while success == 0 %��û��ȷ����һվ�������Ѱ��
                if minDist1 <= alpha * minDist2  %����ǰ���ջ����ͻ�
                    %���жϳ��ϵĻ����Ƿ�Ϊ���ͻ�������
                    productNeedCur = productNeed{OptionS1}.array;
                    productToSend = find(W~=0);
                    productForRec = find(productNeedCur~=0);
                    if length(difference(productToSend, productForRec)) == 0 %�����ϵĻ��ﲻ�Ǹ��ջ�������
                        success = 0;
                        nowChoice = nowChoice + 1;
                        minDist2 = DistOpt(newChoice);  
                        optionS2 = find(distToRecSpot == DistOpt(newChoice));  %��ǰ���ջ���
                    else  %�����õ��ͻ�
                       needArray = productNeed{optionS2}
                        for k = 1:length(needArray)
                            temp = max(W(k)-needArray(k),0);
                            needArray(k) = needArray(k) - (W(k)-temp);    %��k�����������
                            W(k) = temp;
                        end
                        Route(n+optionS2) = 0;    %ע�⵱ǰ���±�optionS2�����ջ����е����λ��
                        success = 1;
                        carPositionIndex = n + optionS2; %ԭ��ͬ��
                        notArriveNum = length(find(route == 1));  %��һ�»��ж��ٽڵ�û�о���
                        if notArriveNum == 0 %���ȫ���ڵ��ѱ��� 
                            %��Ϊ���ϻ���δ���Ѿ�ȫ���ͳ��������������ѵ�ǰ���ϵĻ����ͳ�
                            distanceArray = D(carPositionIndex,:); %�ӵ�ǰ�ڵ㿴�����ջ��㵽����ľ���
                            distanceArray2 = distanceArray(m+1:m+n); %ֻѰ���ջ���
                            candidateNode = []; %��ѡ���ջ���
                            distanceRank = sort(distanceArray2);
                            carStack = carStack + 1; %��һ����
                            route = ones(1,m+n);
                            W = zeros(1,m);
                            carPositionIndex = 0;
                        end
                    end
                else % ����ѡ���ջ�
                    temp = min(W(optionS1)+S(optionS), M);
                    S(optionS1) = S(optionS1) - (temp - W(optionS1));
                    W(optionS1) = temp;
                    Route(optionS1) = 0;   %��������Ϊȫ�����������ǴӲֿ⿪ʼ�ģ����Բ������ջ�������������Զ�λ
                    carPositionIndex = optionS1;
                end
            end
        else  %�������ͻ�
            needArray = productNeed{optionS2}
            for k = 1:length(needArray)
                temp = max(W(k)-needArray(k),0);
                needArray(k) = needArray(k) - (W(k)-temp);    %��k�����������
                W(k) = temp;
            end
            Route(n+optionS2) = 0;    %ע�⵱ǰ���±�optionS2�����ջ����е����λ��
            success = 1;
            carPositionIndex = n + optionS2; %ԭ��ͬ��
            notArriveNum = length(find(route == 1));  %��һ�»��ж��ٽڵ�û�о���
            if notArriveNum == 0 %���ȫ���ڵ��ѱ���
                carStack = carStack + 1; %��һ����
                route = ones(1,m+n);
                W = zeros(1,m);
                carPositionIndex = 0;
            end
        end
    end
end
            
                    
                    
                
                
                
                