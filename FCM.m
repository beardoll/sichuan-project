function [results] = FCM(dist,C,capacity,demand)
    % fuzzy clustering method
    % dist: xi到vc的距离，i=1:N
    % u:N*C维列向量，其中第1组N个u代表样本对簇1的隶属度，以此类推
    % C:簇的数量
    % capacity:货车容量
    % demand:N维列向量，表示每一个样本的需求
    N = length(dist)/C;
    A = zeros(N,N*C);
    temp = diag(ones(1,N));
    A = [temp temp temp];
    b = ones(N,1);
    % initialize 
    % 产生u的初始可行分布（满足不等式约束）
    u_ini = 1/C*ones(N*C,1);
    y = zeros(N*C+N*C+C+N,1);
    y(1:N*C) = u_ini;
    y(N*C+1:end) = rand(N*C+C+N,1);
    ryt = ones(length(y),1);
    epsilon = 10^(-4);
    m = N*C+C;
    miu = 5;
    d2f0 = 2*diag(dist);
    while sum(abs(ryt)) > epsilon
        u = y(1:N*C);
        lambda = y(N*C+1:N*C+N*C+C);
        v = y(N*C+N*C+C+1:end);
        eta = -lambda'*fi(u,demand,capacity);
        t = miu*m/eta;
        fi_value = fi(u,demand,capacity);
        hessian = [d2f0 Dfi(u,demand)' A';
                   -diag(lambda)*Dfi(u,demand) -diag(fi_value) zeros(N*C+C,N);
                   A zeros(N,N*C+C) zeros(N,N)]+10^(-9);
        rt_cur = rti(demand,dist,y,t,A,b,N,C,capacity);
        deltay = -inv(hessian)*rt_cur;
        s = 1;
        alpha = 0.8;
        y1 = y+s*deltay;
        
        g0 = sum(abs(rt_cur));
        while length(find(fi(y1(1:N*C),demand,capacity)>0)==1)~=0 || length(find(y1(N*C+1:N*C+N*C+C)<0))~=0||...
            sum(abs(rti(demand,dist,y1,t,A,b,N,C,capacity))) > (1-alpha*s)* g0               
            s = alpha*s;
            y1 = y+s*deltay;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         del = 0.01:0.03:0.5;
%         yla = zeros(length(del),1);
%         line = yla;
%         for i=1:length(del)
%             yla(i) = sum(abs(rti(demand,dist,y+del(i)*deltay,t,A,b,N,C,capacity)));
%             line(i) = sum(abs(rti(demand,dist,y,t,A,b,N,C,capacity)+hessian*(del(i)*deltay)));
%         end
%         plot(del,yla,'r',del,line,'b');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        y = y+s*deltay;   
        ryt = rti(demand,dist,y,t,A,b,N,C,capacity);
    end
    results = y(1:N*C);
end

function [results] = fi(u,demand,capacity)
% 计算fi(x)
    N = length(demand);
    C = length(u)/length(demand);
    results = zeros(N*C+C,1);
    results(1:N*C) = -u;
    ss = u.*repmat(demand,C,1);
    for i = 1:C
        results(N*C+i) = sum(ss(N*(i-1)+1:N*i))-capacity;
    end
end

function [results] = Dfi(u,demand)
% 计算Dfi(x)
    N = length(demand);
    C = length(u)/N;
    results = zeros(N*C+C,N*C);
    results(1:N*C,:) = diag(-ones(N*C,1));
    for i = 1:C        
        results(N*C+i,(i-1)*N+1:i*N) = demand;
    end
end


function [results] = rti(demand,dist,y,t,A,b,N,C,capacity)
% 计算余量rt
   u_len = N*C;
   lambda_len = N*C+C;
   v_len = N;
   u = y(1:u_len);
   lambda = y(u_len+1:u_len+lambda_len);
   v = y(u_len+lambda_len+1:u_len+lambda_len+v_len);
   Df0 = 2*u.*dist;   %NC*1 
   Df = Dfi(u,demand);  
   results = zeros(u_len+lambda_len+v_len,1);
   results(1:u_len) = Df0 + Df'*lambda + A'*v;
   results(u_len+1:u_len+lambda_len) = -diag(lambda)*fi(u,demand,capacity)-1/t*ones(lambda_len,1);
   results(u_len+lambda_len+1:u_len+lambda_len+v_len) = A*u-b;
end