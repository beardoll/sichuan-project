function [] = drawpicture(path, Lx, Ly, Bx, By, repox, repoy)
    pathnum = length(path);   % 路径数量
    linehaulnum = length(Lx);
    for i = 1:pathnum
        figure(i);
        part_path = path{i}
        plot([repox Lx(part_path(1))], [repoy Ly(part_path(1))], 'r-');
        axis([0 100 0 100]);
        hold on;
        plot(repox, repoy, 'b*');
        plot(Lx(part_path(1)), Ly(part_path(1)), 'go');
        pathlen = length(part_path);
        for j = 2:pathlen+1
            frontnum = part_path(j-1);
            if frontnum <= linehaulnum
                x1 = Lx(frontnum);
                y1 = Ly(frontnum);
            else
                x1 = Bx(frontnum - linehaulnum);
                y1 = By(frontnum - linehaulnum);
            end
            if j <= pathlen
                backnum = part_path(j);
                if backnum <= linehaulnum
                    x2 = Lx(backnum);
                    y2 = Ly(backnum);
                    color = 'go';
                else
                    x2 = Bx(backnum - linehaulnum);
                    y2 = By(backnum - linehaulnum);
                    color = 'bd';
                end
                plot([x1 x2], [y1 y2], 'r-');
                plot(x2, y2, color);
            else
                plot([x1 repox], [y1 repoy], 'r-');
            end
        end
%         legend('连接边','仓库','linehaul', 'backhaul');
        hold off;
    end        
end