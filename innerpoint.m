x = rand(5,1);
lambda = rand(5,1);
v = rand(3,1);
A = [0 5 1 0 0;6 2 0 1 0;1 1 0 0 1];
b = [15 24 5]';
miu = 5;
epsilon = 10^(-6);
ry = ones(5,1);
dl = diag(lambda);
dfx = diag([-1 -1 -1 -1 -1]);
dx0 = [-2 -1 0 0 0]';
y = [x;lambda;v];

while sum(abs(ry))>epsilon
    x = y(1:5);
    v = y(11:13);
    lambda = y(6:10);
    eta = lambda'*x;
    t = miu * 5/eta;
    dl = diag(lambda);
    dx = diag(x);
    hessian = [zeros(5,5) dfx  A';
               dl dx zeros(5,3);
               A zeros(3,5) zeros(3,3)]+10^(-9);
    ry = [dx0+dfx'*y(6:10)+A'*y(11:13);
          y(6:10).*y(1:5)-1/t*ones(5,1);
         A*y(1:5)-b];
    deltay = -inv(hessian)*ry;
    s = 1;
    alpha = 0.8;
    g0 = sum(abs(ry));
    y1 = y+s*deltay;
    ry = [dx0+dfx'*y1(6:10)+A'*y1(11:13);
      y1(6:10).*y1(1:5)-1/t*ones(5,1);
     A*y1(1:5)-b];
    g1 = sum(abs(ry));
    while   length(find(y1(1:10)<0))~=0    
        %g1 > (1-alpha*s)*g0  ||
        s = s*alpha;
        y1 = y+s*deltay;
        ry = [dx0+dfx'*y1(6:10)+A'*y1(11:13);
        y1(6:10).*y1(1:5)-1/t*ones(5,1);
        A*y1(1:5)-b];
        g1 = sum(abs(ry));
    end
    y = y+s*deltay;
end
y(1:5)
    


