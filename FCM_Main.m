% clc;clear;
K = 3;
center = zeros(K,2);
xrange = 100;
yrange = 100;
capacity = 32;

load dataset;
linehaulnum = length(datasetLx);
backhaulnum = length(datasetBx);

% for i = 1:K
%     center(i,1) = rand * 33+33*(i-1);
%     center(i,2) = rand * yrange;
% end
center(1,1) = 16;center(1,2) = 49;
center(2,1) = 49;center(2,2) = 79;
center(3,1) = 79;center(3,2) = 49;

% center(1,1) = rand * 33;center(1,2) = rand * 33 + 33;
% center(2,1) = rand * 33 + 33;center(2,2) = rand * 33 + 66;
% center(3,1) = rand * 33 + 66;center(3,2) = rand * 33 + 33;

epsilon = 10^(-4);
gap = 1;
u_ini = 1/K*ones(datanum*K,1);
u = u_ini;
nn = 1;

while gap > epsilon 
    nn = nn+1;
    dist = zeros(datanum*K,1);
    for i = 1:length(dist)
        clusterindex = floor(i/datanum)+1;
        if i - (clusterindex-1)*datanum == 0
            clusterindex = clusterindex - 1;
        end
        num = i - (clusterindex-1)*datanum;
        datax = dataset(num,1);
        datay = dataset(num,2);
        dist(i) = (datax-center(clusterindex,1))^2+(datay-center(clusterindex,2))^2;
    end
    dist;

%%%%%%%%%%%  fuzzy clustering method with non-integer inequalityconstraint %%%%%%%%%%    
%     results = FCM(dist,K,capacity,demand);
%     u_new = results;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% fuzzy clustering method without inequality constraint %%%%%%%%
%     u_new = zeros(datanum*K,1);
%     distmat = reshape(1./dist,datanum,K);
%     for i = 1:datanum*K
%         cl = floor(i/datanum)+1;
%         if mod(i,datanum) == 0
%             cl = cl - 1;
%         end
%         num = i - datanum*(cl-1);
%         u_new(i) = 1/(dist(i,:)*sum(distmat(num,:)));
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% fuzzy clustering method with integer-inequality constraint  %%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    u = u_new;
    newcenter = zeros(K,2);
    for i = 1:K
        newcenter(i,1) = sum(u((i-1)*datanum+1:i*datanum).^2.*dataset(:,1))/sum(u((i-1)*datanum+1:i*datanum).^2);
        newcenter(i,2) = sum(u((i-1)*datanum+1:i*datanum).^2.*dataset(:,2))/sum(u((i-1)*datanum+1:i*datanum).^2);
    end
    gap = sum(sum((center-newcenter).^2));
    center = newcenter;
end

k_demand = zeros(K,1);
Umatrix = reshape(u,datanum,K);

% allocation
% for k = 1:datanum
%     spot = find(u==max(u));
%     

for i = 1:datanum
    type = find(Umatrix(i,:) == max(Umatrix(i,:)));
    k_demand(type) = k_demand(type)+demand(i);
    switch type
        case 1  
            plot(dataset(i,1),dataset(i,2),'ro');
            axis([0 100 0 100]);
            hold on;            
        case 2 
            plot(dataset(i,1),dataset(i,2),'go');
            hold on;
        case 3 
            plot(dataset(i,1),dataset(i,2),'bo');
            hold on;
    end
end

plot(center(1,1),center(1,2),'r*');
plot(center(2,1),center(2,2),'g*');
plot(center(3,1),center(3,2),'b*');
k_demand

