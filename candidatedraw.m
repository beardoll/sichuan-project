function [] = candidatedraw(cluster, Lx, Ly, Bx, By, linehaulnum)
    for i = 1:length(cluster)
        if cluster(i) <= linehaulnum
            plot(Lx(cluster(i)), Ly(cluster(i)), 'ro');
            hold on;
        else
            plot(Bx(cluster(i)-linehaulnum), By(cluster(i)-linehaulnum), 'g+');
            hold on;
        end
    end
    axis([0 24000 0 32000])
    hold off;
end