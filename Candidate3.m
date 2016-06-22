function [CH] = Candidate3(Lx, Ly, Bx, By, demandL, demandB, K, dc, repox, repoy, capacity)
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
            angledist(i,j) = min(abs(minus), abs(2*pi-abs(minus)));  % ѡ���Ǹ�С��
            angledist(j,i) = angledist(i,j); % �Գ���
        end
    end
    
    
    
    cluster = [];  % �Ѿ��۳ɴصĽڵ㼯��
    clusterlen = 0;  % �س���
    clustermem = [];  % �س�Ա
    spotid = -1*ones(1,totalnum);   % ÿ���˿ͽڵ����ڵĴر��
    
    while length(clustermem) < totalnum
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
    
    memlen = zeros(1,clusterlen);
    for i = 1:clusterlen
        mem = cluster(i).mem;
        memlen(i) = length(mem);
    end
    
    memlensort = sort(memlen, 'descend');
    CH = zeros(K,2);
    for i = 1:K
        clindex = find(memlen == memlensort(i));
        clindex = clindex(1);
        memlen(clindex) = inf;
        cc = cluster(clindex).mem;
%         candidatedraw(cc, Lx, Ly, Bx, By, linehaulnum);
        temp1 = 0;
        temp2 = 0;
        for j = 1:length(cc)
            temp1 = temp1 + cos(cus_angle(cc(j)));
            temp2 = temp2 + sin(cus_angle(cc(j)));
        end
        temp1 = temp1/length(cc);
        temp2 = temp2/length(cc);
        CH(i,1) = dc*temp1+repox;
        CH(i,2) = dc*temp2+repoy;
    end      
end