% fuzzy clustering method
% dist: xiµ½vcµÄ¾àÀë£¬i=1:N
lambda  = zeros(N*C+C,1);
v = zeros(N,1);
uic = zeros(N*C,1)
A = zeros(N,N*C);
for i = 1:N
    temp = zeros(1,N);
    temp(i) = 1;
    A(i,:) = repmat(temp,1,C);
end
D2f0 = 2*diag(dist);
Df = zeros(N*C+C,N*C);
Df(1:N*C,:) = diag(-ones(N*C,1));
Df(N*C+1:N*C+C,:) = diag(repmat(di,1,C));
fx = zeros(N*C+C,N*C);
fx(1:N*C,:) = diag(-uic);
ss = uic.*repmat(di,1,C);
for i = 1:C
    fx(N*C+i,:) = sum(ss(N*(i-1)+1:N*i));
end
Dr = uic(N*(c-1)+1:N*c)'*dx1
Df0 = 2*uic.*d(xi,vc);   %NC*1 