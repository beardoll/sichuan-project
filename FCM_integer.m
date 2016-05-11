function [u_new] =FCM_integer(datanum, dist,K,capacity,demand)
    % �����滮��ʵ�ʷ�FCM����һ��Ӳ����
    ux = intvar(datanum*K,1);
    f = dist'*ux;
    F = [ux>=0];
    temp = diag(ones(1,datanum));
    A = [temp temp temp];
    b = ones(datanum,1);
    F = F+[A*ux==b];
    for j = 1:K
        F=F+[ux((j-1)*datanum+1:j*datanum)'*demand <= capacity];
    end
    solvesdp(F,f);
    u_new = double(ux);
end