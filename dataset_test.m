linehaulnum = 30;
backhaulnum = 30;


xrange = 100;
yrange = 100;

weight = 3:0.5:6;
demandL = zeros(linehaulnum, 1);
demandB = zeros(backhaulnum, 1);

datasetLx = zeros(linehaulnum, 1);
datasetLy = zeros(linehaulnum, 1);
datasetBx = zeros(backhaulnum, 1);
datasetBy = zeros(backhaulnum, 1);

for i=1:linehaulnum
    demandL(i) = weight(randi([1 length(weight)]));
    datasetLx(i) = rand * xrange;
    datasetLy(i) = rand * yrange;
    while datasetLy(i) < 30
        datasetLy(i) = rand * yrange;
    end
end

for i=1:backhaulnum
    demandB(i) = weight(randi([1 length(weight)]));
    datasetBx(i) = rand * xrange;
    datasetBy(i) = rand * yrange;
    while datasetBy(i) < 30
        datasetBy(i) = rand * yrange;
    end
end

for i=1:linehaulnum
    plot(datasetLx(i),datasetLy(i),'ro');
    axis([0 100 0 100]);
    hold on;
end

for i=1:backhaulnum
    plot(datasetBx(i),datasetBy(i),'go');
    axis([0 100 0 100]);
    hold on;
end


hold off;

filename = 'dataset.mat';
save(filename, 'datasetLx', 'datasetLy', 'demandL', 'datasetBx', 'datasetBy', 'demandB');
