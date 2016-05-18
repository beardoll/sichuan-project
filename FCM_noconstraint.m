function [u_new] = FCM_noconstraint(datanum, K, dist)
    % 无负载约束的FCM
    u_new = zeros(datanum*K,1);
    distmat = reshape(1./dist,datanum,K);
    for i = 1:datanum*K
        cl = floor(i/datanum)+1;
        if mod(i,datanum) == 0
            cl = cl - 1;
        end
        num = i - datanum*(cl-1);
        u_new(i) = 1/(dist(i,:)*sum(distmat(num,:)));
    end
end