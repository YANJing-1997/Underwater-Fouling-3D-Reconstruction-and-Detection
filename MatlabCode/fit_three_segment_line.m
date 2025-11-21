function [inflection, p1, p2] = fit_three_segment_line(A)
    x = A(:,1);
    y = A(:,2);
    N = length(x);

    min_error = inf;
    best_i = 0;
    best_j = 0;

    % 搜索两个折点位置（i < j）
    for i = 2:N-3
        for j = i+2:N-1
            % 第一段
            x1 = x(1:i);
            y1 = y(1:i);
            p1_fit = polyfit(x1, y1, 1);
            y1_fit = polyval(p1_fit, x1);
            err1 = sum((y1 - y1_fit).^2);

            % 第二段
            x2 = x(i+1:j);
            y2 = y(i+1:j);
            p2_fit = polyfit(x2, y2, 1);
            y2_fit = polyval(p2_fit, x2);
            err2 = sum((y2 - y2_fit).^2);

            % 第三段
            x3 = x(j+1:end);
            y3 = y(j+1:end);
            p3_fit = polyfit(x3, y3, 1);
            y3_fit = polyval(p3_fit, x3);
            err3 = sum((y3 - y3_fit).^2);

            total_err = err1 + err2 + err3;

            % 更新最小误差和对应折点
            if total_err < min_error
                min_error = total_err;
                best_i = i;
                best_j = j;
            end
        end
    end

    % 输出两个折点坐标
    p1 = [x(best_i), y(best_i)];
    p2 = [x(best_j), y(best_j)];

    if p1(1, 2) < 0.3 && p2(1, 2) < 0.3
        inflection = p1;
    else
        inflection = p2;
    end
    
    if inflection(1, 2) < 0.2
        inflection(1, 2) = 0.2
    end

    % 可选：绘图显示拟合结果
    figure;
    hold on;
    plot(x, y, 'ko', 'DisplayName', 'Original Data');
    plot([x(1:best_i)], polyval(polyfit(x(1:best_i), y(1:best_i),1), x(1:best_i)), 'r', 'LineWidth', 2);
    plot([x(best_i+1:best_j)], polyval(polyfit(x(best_i+1:best_j), y(best_i+1:best_j),1), x(best_i+1:best_j)), 'g', 'LineWidth', 2);
    plot([x(best_j+1:end)], polyval(polyfit(x(best_j+1:end), y(best_j+1:end),1), x(best_j+1:end)), 'b', 'LineWidth', 2);
    plot(p1(1), p1(2), 'ro', 'MarkerSize', 15, 'DisplayName', 'Inflection 1');
    plot(p2(1), p2(2), 'bo', 'MarkerSize', 15, 'DisplayName', 'Inflection 2');
    plot(inflection(1), inflection(2), 'go', 'MarkerSize', 20, 'DisplayName', 'AdoptedInflection');
    legend;
    title('Three segment linear fitting');
    hold off;
end
