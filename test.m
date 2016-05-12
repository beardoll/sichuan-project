x=intvar(1,2);
f = [1 4]*x';
F = [x>=0];
F = F + [x<=2];
F = F+[[-2 3]*x'<=3];
F = F+[[1 2]*x'<=8];
solvesdp(F,-f)
double(f)





% f=[1 1 3 4 2]*(x'.^2)-[8 2 3 1 2]*x';F=[x>=0,x<=99];
% F=F+set([1 1 1 1 1]*x'<=400)+set([1 2 2 1 6]*x'<=800)+set(2*x(1)+x(2)+6*x(3)<=800);
% F=F+set(x(3)+x(4)+5*x(5)<=200);solvesdp(F,-f);
% double(f) 

% F = [x >= 0, x <= 32];
% F = [F, x^2 <= 1];
% F = F + [y <= 10, [x y;y 1] >= 0];
% F = F + [1 <= z <= 5]
% F = [F, [x z;z x+y] >= 0, norm([x;y]) <= z]
% C = [];
% for i = 1:5
%  C = [C, x+y(i)+z(6-i) == i];
% end
% D = [F,C]
% ...
% 
% f = -1*[2 1];
% A = [0 5;6 2;1 1];
% b = [15 24 5];
% [x,fval] = linprog(f,A,b)
