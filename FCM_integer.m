function [u_new] =FCM_integer(n, datanum, dist,K,capacity,demand)
    % 整数规划，实际非FCM，是一种硬分类
    ux = intvar(datanum*K,1);
    f = dist'*ux;
    F = [ux>=0];
    temp = diag(ones(1,datanum));
    A = repmat(temp,1,K);
    b = ones(datanum,1);
    F = F+[A*ux==b];
    for j = 1:K
        F=F+[ux((j-1)*datanum+1:(j-1)*datanum+n)'*demand(1:n) <= capacity];
        F=F+[ux((j-1)*datanum+n+1:j*datanum)'*demand(n+1:end) <= capacity];
        F=F+[sum(ux((j-1)*datanum+1:(j-1)*datanum+n)) >= 1];
    end
    solvesdp(F,f);
    u_new = double(ux);
end