function [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, K, repox, repoy, capacity)
    linehaulnum = length(Lx);        % linehaul�ڵ����
    totalnum = length([Lx, Bx]);     % �ܵĽڵ����
    line_angle = computeAngle(Lx, Ly, repox, repoy);   % linehaul�ڵ�ķ���
    back_angle = computeAngle(Bx, By, repox, repoy);   % backhaul�ڵ�ķ���
    cus_angle = [line_angle, back_angle];               % ���й˿ͽڵ�ķ���
    angledist = zeros(totalnum, totalnum);  % �ڵ�֮��ķ��Ǿ���
    
    for i = 1:totalnum
        angledist(i,i) = inf;
        for j = i+1:totalnum
            minus = cus_angle(i) - cus_angle(j);
            angledist(i,j) = min(abs(minus), abs(2*pi-abs(minus)));  % ѡ���Ǹ�С�ߣ����ܳ���180�ȣ�
            angledist(j,i) = angledist(i,j); % �Գ���
        end
    end
    
    
    
    cluster = [];  % �Ѿ��۳ɴصĽڵ㼯��
    clusterlen = 0;  % �س���
    clustermem = [];  % �س�Ա
    spotid = -1*ones(1,totalnum);   % ÿ���˿ͽڵ����ڵĴر��
    
    %% �����ִ�
    while length(clustermem) < totalnum || clusterlen > 2*K
        minangledist = min(min(angledist));  % ��ǰ���Ǿ�����С��
        minindex = find(angledist == minangledist);
        minindex = minindex(1);
        
        temp1 = floor(minindex/totalnum)+1;     % ������
        temp2 = minindex - (temp1-1)*totalnum;  % ������
        if temp2 == 0
            temp2 = totalnum;
            temp1 = temp1 - 1;
        end
        
        incluster = length(intersect(clustermem, [temp1, temp2]));  % ��һ��temp1, temp2�Ƿ��Ѿ��ڴ���
        
        angledist(temp1, temp2) = inf;
        angledist(temp2, temp1) = inf;
        
        if incluster == 0  % ��û�б����䵽�κ�һ�����У��򿪱�һ���µĴ�
            clustermem = [clustermem, temp1, temp2];
            cl.mem = [temp1, temp2];
            cl.dL = 0;  % �ص�linehaul����
            cl.dB = 0;  % �ص�backhaul����
            if temp1 <= linehaulnum
                cl.dL = cl.dL + demandL(temp1);
            else
                cl.dB = cl.dB + demandB(temp1-linehaulnum);
            end
            if temp2 <= linehaulnum
                cl.dL = cl.dL + demandL(temp2);
            else
                cl.dB = cl.dB + demandB(temp2-linehaulnum);
            end
            cluster = [cluster, cl];
            clusterlen = clusterlen + 1;
            spotid(temp1) = clusterlen;
            spotid(temp2) = clusterlen;
        elseif incluster == 1  % ������һ���ڵ��ڴ���
            if ismember(temp1, clustermem)  % ���temp1��clustermem�е�Ԫ��
                clid = spotid(temp1);  % ��temp1��id�ҳ���
                cc = cluster(clid);  % clid��ָ��Ĵ�
                if temp2 <= linehaulnum
                    if cc.dL + demandL(temp2) <= capacity
                        clustermem = [clustermem, temp2];
                        cc.dL = cc.dL + demandL(temp2);
                        cc.mem = [cc.mem, temp2];
                        spotid(temp2) = clid;
                        cluster(clid) = cc;
                    end
                else
                    if cc.dB + demandB(temp2-linehaulnum) <= capacity
                        clustermem = [clustermem, temp2];
                        cc.dB = cc.dB + demandB(temp2-linehaulnum);
                        cc.mem = [cc.mem, temp2];
                        spotid(temp2) = clid;
                        cluster(clid) = cc;
                    end
                end
            elseif ismember(temp2, clustermem)  % temp2��clustermem�е�Ԫ��
                clid = spotid(temp2);  % ��temp1��id�ҳ���
                cc = cluster(clid);  % clid��ָ��Ĵ�
                if temp1 <= linehaulnum
                    if cc.dL + demandL(temp1) <= capacity
                        clustermem = [clustermem, temp1];
                        cc.dL = cc.dL + demandL(temp1);
                        cc.mem = [cc.mem, temp1];
                        spotid(temp1) = clid;
                        cluster(clid) = cc;
                    end
                else
                    if cc.dB + demandB(temp1-linehaulnum) <= capacity
                        clustermem = [clustermem, temp1];
                        cc.dB = cc.dB + demandB(temp1-linehaulnum);
                        cc.mem = [cc.mem, temp1];
                        spotid(temp1) = clid;
                        cluster(clid) = cc;
                    end
                end
            end
        elseif incluster == 2  % �������ڴ���
            if spotid(temp1) ~= spotid(temp2)  % �������λ�ڲ�ͬ�Ĵأ����԰��������ظ��������
                clid1 = spotid(temp1);
                clid2 = spotid(temp2);
                cc1 = cluster(clid1);
                cc2 = cluster(clid2);
                if cc1.dL + cc2.dL <= capacity && cc1.dB + cc2.dB <= capacity  % ���غϲ��󲻻ᳬ��������
                    mem2 = cc2.mem;
                    for v = 1:length(mem2)
                        cspot = mem2(v);
                        spotid(cspot) = clid1;  % ȫ������
                    end
                    cc1.mem = [cc1.mem, cc2.mem];  %�ϲ�
                    cc1.dL = cc1.dL + cc2.dL;
                    cc1.dB = cc1.dB + cc2.dB;
                    cluster(clid1) = cc1;
                    cluster(clid2) = [];
                    clusterlen = clusterlen - 1;
                    for k = clid2 : clusterlen  % clid2��ɾ���������Ҫ����������Ĵ�id������
                        cmem = cluster(k).mem;
                        for m = 1:length(cmem)
                            spotid(cmem(m)) = spotid(cmem(m)) - 1;
                        end
                    end
                end
            end
        end               
    end
    
    
    %% adjustment����clusterlen���ر�ɺϷ���K����
    newcluster = [];   % ��ԭ����cluster����λ������              
    anglelist = [];
    border = zeros(clusterlen, 2);  % ԭ������cluster�ı߽�
    epsilon = 10^(-4);
    for i = 1:clusterlen   % ���ÿ���صĽ�ƽ����  
        cmem = cluster(i).mem;
        maxangle = max(cus_angle(cmem));
        minangle = min(cus_angle(cmem));
        anglerange = (maxangle + minangle)/2;
        if maxangle - minangle > pi  % �����еĴ��У��صļнǶ����ᳬ��180�ȣ������ǿ�һ��������
            temp1 = cus_angle(cmem);
            temp2 = temp1(find(temp1 >= 0 & temp1 < pi));
            temp3 = temp1(find(temp1 >=pi & temp1 < 2*pi));
            minangle = max(temp2);
            maxangle = min(temp3);
            anglerange = (-2*pi + maxangle + minangle)/2;
        end
        b1 = find(cus_angle(cmem) >= minangle-epsilon & cus_angle(cmem) <= minangle+epsilon);
        b1 = b1(1);
        b1 = cmem(b1);
        b2 = find(cus_angle(cmem) >= maxangle-epsilon & cus_angle(cmem) <= maxangle+epsilon);
        b2 = b2(1);
        b2 = cmem(b2);
        border(i,:) = [b1, b2];
        midangle = anglerange/2; % �м�ֵ�������Դؽ�������
        anglelist = [anglelist, midangle];
    end
    
    rankborder = zeros(clusterlen,2);  % K���صı߽�ڵ�
    rankanglelist = sort(anglelist, 'ascend');  % �Է���С�����������
    for i = 1:clusterlen  % �γ��µĴ�cluster
        index = find(anglelist == rankanglelist(i));
        rankborder(i,:) = border(index,:);
%         figure(i);
%         candidatedraw(cluster(index).mem, Lx, Ly, Bx, By, linehaulnum, 12000,16000);
        newcluster = [newcluster, cluster(index)];
    end
    
    jumpnum = clusterlen - K;  
    % ��Ծ�ķ�Χ��clusterlen > K��
    % ��newcluster�У�ÿż����ŵĴػᱻ�ϲ������ڵĻ�����ŵĴ���(��jumpnum���ػ�ִ�������Ĳ���)
    retaincluster = zeros(1,K);    % ���������Ĵر��
    for j = 1:jumpnum
        retaincluster(j) = (j-1)*2+1;
    end
    % �ճ���jumpnum���غ�ʣ�µĽ�������
    retaincluster(jumpnum+1:end) = (jumpnum*2+1):(K-jumpnum+jumpnum*2);
    
    % ��������Ҫ��jumpnum���ؽ��С��Ϸ֡�
    for i = 1:jumpnum
        index = (i-1)*2+2;
        cmem = newcluster(index).mem;
        if index == 1
            index1 = clusterlen;  % ���ڴ�
        else
            index1 = index-1;
        end
        if index == clusterlen
            index2 = 1;           % ���ڴ�
        else
            index2 = index + 1;
        end
        candidate1 = rankborder(index1,:);  % �������ڱ�ŵĴ�
        candidate2 = rankborder(index2,:);
        for m = 1:length(cmem)
            min1 = min(angledist(candidate1, cmem(m)));  % min1,min2Ϊ��ǰ�ڵ�������ڴر߽����̾���
            min2 = min(angledist(candidate2, cmem(m)));
            if min1 <= min2  % ���ڴظ���
                newcluster(index1).mem = [newcluster(index1).mem, cmem(m)];
                if cmem(m) <= linehaulnum
                    newcluster(index1).dL = newcluster(index1).dL + demandL(cmem(m));
                else
                    newcluster(index1).dB = newcluster(index1).dB + demandB(cmem(m)-linehaulnum);
                end
            else  % ���ڴظ���
                newcluster(index2).mem = [newcluster(index2).mem, cmem(m)];
                if cmem(m) <= linehaulnum
                    newcluster(index2).dL = newcluster(index2).dL + demandL(cmem(m));
                else
                    newcluster(index2).dB = newcluster(index2).dB + demandB(cmem(m)-linehaulnum);
                end
            end
        end
    end
    
    origincluster = newcluster(retaincluster);  
    % ԭ����clusterlen���ر����K���أ�����ÿ���ز�һ�������㳵����Լ��
    origindL = zeros(1,K);
    origindB = zeros(1,K);
    % �ȰѸ����ص�������ͳ�Ƴ���
    for i = 1:K
        origindL(i) = origincluster(i).dL;
        origindB(i) = origincluster(i).dB;
    end
    
    % ���������origincluster���е�����ʹÿ���صĻ�����������������
    while max(origindL) > 1.05*capacity || max(origindB) > 1.05*capacity   % 1.05��һ���ɳ��������������ѭ��
        for i = 1:K   % ����Ŵ�ķ���ת��(�ѷ��ǽϴ�ĸ�ת����)
            if origindL(i) > capacity || origindB(i) > capacity  % ������һ����������                           
                if i == K
                    neibor = 1;
                else
                    neibor = i+1;
                end
                if origindL(i) > capacity    % ����ǰ�ص�linehaul�ڵ�ת���ߣ�ֱ���ܻ���������ڳ�����
                    while origindL(i) > capacity
                        cmem = origincluster(i).mem;
                        cmemL = cmem(find(cmem<=linehaulnum));  % linehaul��Ա
                        minangle = min(cus_angle(cmemL));  % ��ǰ��i��linehaul��Ա�ı߽�
                        maxangle = max(cus_angle(cmemL));
                        if maxangle - minangle > pi  % ���ǿ����ģ�ѡ���Ǵ��ߣ���Ϊ���ر�Ÿ���Ĵ�ת�ƣ�
                            plusmem = cmemL(find(cus_angle(cmemL) >= 0 & cus_angle(cmemL) < pi));
                            cchoice = cmemL(find(cus_angle(cmemL) == max(cus_angle(plusmem))));
                            cchoice = cchoice(1);
                        else
                            cchoice = cmemL(find(cus_angle(cmemL) == max(cus_angle(cmemL))));
                            cchoice = cchoice(1);
                        end
                        cdL = demandL(cchoice);                          
                        origincluster(i).mem = setdiff(origincluster(i).mem, cchoice);
                        origincluster(neibor).mem = [origincluster(neibor).mem, cchoice];
                        origincluster(neibor).dL = origincluster(neibor).dL + cdL;
                        origincluster(i).dL = origincluster(i).dL - cdL;
                        origindL(i) = origindL(i) - cdL;
                        origindL(neibor) = origindL(neibor) + cdL;
                    end
                end
                if origindB(i) > capacity % ����ǰ�ص�backhaul�ڵ�ת���ߣ�ֱ���ܻ���������ڳ�����
                    while origindB(i) > capacity
                        cmem = origincluster(i).mem;
                        cmemB = cmem(find(cmem>linehaulnum));   % backhaul��Ա 
                        minangle = min(cus_angle(cmemB));  % ��ǰ��i��backhaul��Ա�ı߽�
                        maxangle = max(cus_angle(cmemB));
                        if maxangle - minangle > pi  % ���ǿ����ģ�ѡ���Ǵ��ߣ���Ϊ���ر�Ÿ���Ĵ�ת�ƣ�
                            plusmem = cmemB(find(cus_angle(cmemB) >= 0 & cus_angle(cmemB) < pi));
                            cchoice = cmemB(find(cus_angle(cmemB) == max(cus_angle(plusmem))));
                            cchoice = cchoice(1);
                        else
                            cchoice = cmemB(find(cus_angle(cmemB) == max(cus_angle(cmemB))));
                            cchoice = cchoice(1);
                        end
                        cdB = demandB(cchoice-linehaulnum);
                        origincluster(i).mem = setdiff(origincluster(i).mem, cchoice);
                        origincluster(i).dB = origincluster(i).dB - cdB; 
                        origincluster(neibor).mem = [origincluster(neibor).mem, cchoice];
                        origincluster(neibor).dB = origincluster(neibor).dB + cdB;
                        origindB(i) = origindB(i) - cdB;
                        origindB(neibor) = origindB(neibor) + cdB;
                    end
                end                        
            end
        end
    end
    
    % ��origincluster�ķִؽ��Ϊ��ʼ�ִأ������ģ���Ϊ���׳�ʼֵ
    CH = zeros(K,2);
    for i = 1:K
        cc = origincluster(i).mem;
        temp2 = 0;
        temp1 = 0;
        for j = 1:length(cc)
            cspot = cc(j);
            if cspot <= linehaulnum
%                 temp1 = temp1 + Lx(cspot);
%                 temp2 = temp2 + Ly(cspot);
                temp1 = temp1 + (Lx(cspot)+repox)/2;
                temp2 = temp2 + (Ly(cspot)+repoy)/2;
            else
%                 temp1 = temp1 + Bx(cspot-linehaulnum);
%                 temp2 = temp2 + By(cspot-linehaulnum);
                temp1 = temp1 + (Bx(cspot-linehaulnum)+repox)/2;
                temp2 = temp2 + (By(cspot-linehaulnum)+repoy)/2;
            end
        end
        temp1 = temp1/length(cc);
        temp2 = temp2/length(cc);
        CH(i,1) = temp1;
        CH(i,2) = temp2;
%         figure(i);
%         candidatedraw(cc, Lx, Ly, Bx, By, linehaulnum, CH(i,1), CH(i,2));
    end  
end