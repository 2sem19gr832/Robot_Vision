function plotBrick(Test, bounds, centroid, class)



imshow(Test)
title('Classification of Lego Bricks')
hold on

for k = 1:length(class(1,1,:))
    A = cat(1, bounds{k});
    for x = 1:length(bounds{k})
        boundary = cell2mat(A(x));
        centroidd = cell2mat(centroid{k});
        for u = 1:length(centroidd) 
            centroids = struct2array(centroidd(u));
            if k == 1
                plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'RED', 'FontSize', 14, 'color', 'w')
            end
            if k == 2
                plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on
                text(centroids(:,1),centroids(:,2), 'GREEN', 'FontSize', 14, 'color', 'w')
            end
            if k == 3
                plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLUE', 'FontSize', 14, 'color', 'w')
            end
            if k == 4
                plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'YELLOW', 'FontSize', 14, 'color', 'w')
            end
            if k == 5
                plot(boundary(:,2), boundary(:,1), 'color', [1 0.5 0], 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'ORANGE', 'FontSize', 14, 'color', 'w')
            end
            if k == 6
                plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
                hold on
                plot(centroids(:,1),centroids(:,2), 'bo')
                hold on 
                text(centroids(:,1),centroids(:,2), 'BLACK', 'FontSize', 14, 'color', 'w')
            end
        end
    end
end