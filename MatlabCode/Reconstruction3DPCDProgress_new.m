function [ExtractedBiofFeature, A] = Reconstruction3DPCDProgress_new(P_baseline, P_biof, Baseline_radius, angle_res, height_res)
AxisVector = [0, 0, 1];% 轴线方向向量
AxisCenter = mean(P_baseline(:, 1:3), 1);

dis_P_biof = pointCloudToLineDistance(P_biof(:, 1:3), AxisCenter, AxisVector);%点云与基准模型轴线的距离
dis_sorted = sort(dis_P_biof, 'descend');

downsampDis = downsample(dis_sorted, 3000);
R = 1:1:length(downsampDis);
Rd = horzcat(R', downsampDis);

[inflection, p1, p2] = fit_three_segment_line(Rd);%寻找拐点
P_biof_seg = P_biof(dis_P_biof < inflection(1, 2), :);%分割出距离小于inflection的点

points = P_biof_seg(:, 1:3);    % xyz坐标
colors = P_biof_seg(:, 4:6);    % RGB颜色值
% 3. 统计RGB值的均值和标准差
meanColor = mean(colors);  % 计算RGB均值
stdColor = std(colors);    % 计算RGB标准差

% 4. 基于统计特性自适应阈值
% 使用均值 ± 2标准差来定义阈值范围
R_min = meanColor(1) - 1 * stdColor(1);
R_max = meanColor(1) + 1 * stdColor(1);
G_min = meanColor(2) - 2 * stdColor(2);
G_max = meanColor(2) + 2 * stdColor(2);
B_min = meanColor(3) - 1 * stdColor(3);
B_max = meanColor(3) + 1 * stdColor(3);

% 5. 根据自适应的颜色阈值筛选绿色点
greenIdx = (colors(:,1) >= R_min) & (colors(:,1) <= R_max) & ...
           (colors(:,2) >= G_min) & (colors(:,2) <= G_max) & ...
           (colors(:,3) >= B_min) & (colors(:,3) <= B_max);

% 提取绿色点的坐标
greenPoints = points(greenIdx, :);%固着物点云
greenColors = colors(greenIdx, :);

figure;
scatter3(greenPoints(:,1), greenPoints(:,2), greenPoints(:,3), 3, greenColors/255, 'filled');
axis equal;
hold on;
scatter3(P_baseline(:,1), P_baseline(:,2), P_baseline(:,3), 1, P_baseline(:, 4:6)/255, 'filled');
title('P-biof');

% 圆柱下采样
data1 = P_baseline;
data2 = greenPoints;

% 圆柱体侧表面点云 ptCloud
ptCloud = pointCloud(data2(:, 1:3));
baselineCloud = pointCloud(data1(:, 1:3));

% 获取圆柱参数
center1 = mean(baselineCloud.Location(:, 1:3), 1);
axisDirection = [0, 0,1]; % 轴线方向向量
    
% 将点云平移到圆柱轴线原点
rotatedPoints2 = ptCloud.Location - center1;  
rotatedPoints2 = pointCloud(rotatedPoints2(:, 1:3));
rotatedPoints1 = baselineCloud .Location - center1;  
rotatedPoints1 = pointCloud(rotatedPoints1(:, 1:3));

%基准点云、固着物点云下采样
[downsampledRP, downsampledBP, Biof_thickness] = cylindricalTwoPCDownsample_new(rotatedPoints2, rotatedPoints1, angle_res, height_res);
% 使用 scatter3 进行更灵活的绘制
figure;
scatter3(downsampledRP(:,1), downsampledRP(:,2), downsampledRP(:,3), ...
    10, 'g', 'filled', 'DisplayName', 'Biofouling PCD');
hold on;
scatter3(downsampledBP(:,1), downsampledBP(:,2), downsampledBP(:,3), ...
    5, 'b', 'filled', 'DisplayName', 'baseline PCD');
title('Downsampled PCD');
axis equal;

%固着物特征分析
%计算固着物点云厚度Biof_thickness
Biof_thickness_average = mean(Biof_thickness);
Biof_thickness_max = max(Biof_thickness);

%计算固着物点云面积Biof_area 投影至侧表面的面积，采用网格法
Biof_area = 2*pi*Baseline_radius*0.4*length(Biof_thickness(:, 1)) / length(downsampledBP(:, 1));

%计算固着物点云面积Biof_volume 投影至侧表面的体积
Biof_volume = sum(Biof_thickness(:, 1)) * (angle_res * Baseline_radius * height_res);

ExtractedBiofFeature = horzcat(Biof_thickness_average, Biof_thickness_max, Biof_area, Biof_volume);
A = horzcat(Biof_thickness, downsampledRP(:, 3));
end

