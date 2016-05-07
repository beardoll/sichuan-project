K = 3;
center = zeros(K,2);
xrange = 100;
yrange = 100;
capacity = 32;

load dataset;
load demand;
datanum = size(dataset, 1);

for i = 1:K
    center(i,1) = rand * 33+33*(i-1);
    center(i,2) = rand * yrange;
end

epsilon = 0.01;
gap = 2;
type = zeros(datanum,1);
iter = 1;

while gap >= epsilon
    for i = 1:datanum
        datax = dataset(i,1);
        datay = dataset(i,2);
        mindist = inf;
        for j = 1:K
            currentdist = sqrt((datax - center(j,1))^2+(datay - center(j,2))^2);
            if currentdist < mindist
                mindist = currentdist;
                type(i) = j;
            end
        end
    end
    newcenter = zeros(K,2);
    sumation = zeros(K,2);
    count = zeros(K,1);
    k_demand = zeros(K,1);
    for i = 1:datanum
        tt = type(i);
        k_demand(tt) = k_demand(tt)+demand(i);
        sumation(tt,1) = sumation(tt,1) + dataset(i,1);
        sumation(tt,2) = sumation(tt,2) + dataset(i,2);
        count(tt) = count(tt)+1;
    end
    gap = 0;
    for i = 1:K
        newcenter(i,1) = sumation(i,1)/count(i);
        newcenter(i,2) = sumation(i,2)/count(i);
        gap = gap + sqrt((newcenter(i,1)-center(i,1))^2+(newcenter(i,1)-center(i,1))^2);
        center(i,1) = newcenter(i,1);
        center(i,2) = newcenter(i,2);
    end
end
for i = 1:datanum
    switch type(i)
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
for i = 1:K
    plot(center(i,1),center(i,2),'k*');
end
hold off;
k_demand

% dist = zeros(datanum*K,1);
% for i = 1:length(dist)
%     clusterindex = floor(i/datanum)+1;
%     if i - (clusterindex-1)*datanum == 0
%         clusterindex = clusterindex - 1;
%     end
%     num = i - (clusterindex-1)*datanum;
%     datax = dataset(num,1);
%     datay = dataset(num,2);
%     dist(i) = sqrt((datax-center(clusterindex,1))^2+(datay-center(clusterindex,2))^2);
% end
% dist;
% results = FCM(dist,K,capacity,demand);



 
        