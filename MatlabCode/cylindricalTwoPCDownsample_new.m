function [downsampledRP, downsampledBP, Biof_thickness] = cylindricalTwoPCDownsample_new(rotatedPoints, baselinePoints, angle_resolution, height_resolution)
    % 圆柱体侧表面点云柱面坐标系下采样
    % 输入：
    %   ptCloud - 输入点云对象
    %   angle_resolution - 角度分辨率（弧度制）
    %   height_resolution - 高度分辨率
    % 输出：
    %   downsampledPtCloud - 下采样后的点云
    % 旋转点云使轴线与Z轴对齐 rotatedPoints 
    % 步骤3：转换为柱面坐标 (ρ, θ, z)
    points = vertcat(rotatedPoints.Location, baselinePoints.Location);
    z = points(:, 3);
    % 计算BP柱面坐标
    x_BP = baselinePoints.Location(:, 1);
    y_BP = baselinePoints.Location(:, 2);
    z_BP = baselinePoints.Location(:, 3);
    rho_BP = sqrt(x_BP.^2 + y_BP.^2);      % 径向距离
    theta_BP = atan2(y_BP, x_BP);          % 方位角（弧度）-pi~pi
    theta_BP = theta_BP + pi; 
    % 计算RP柱面坐标
    x_RP = rotatedPoints.Location(:, 1);
    y_RP = rotatedPoints.Location(:, 2);
    z_RP = rotatedPoints.Location(:, 3);
    rho_RP = sqrt(x_RP.^2 + y_RP.^2);      % 径向距离
    theta_RP = atan2(y_RP, x_RP);          % 方位角（弧度）-pi~pi
    theta_RP = theta_RP + pi; 
    
    % 步骤4：创建柱面网格并下采样
    % 确定高度范围
    min_z = min(z);
    max_z = max(z);
    
    % 创建网格
    angle_bins = 0:angle_resolution:2*pi;
    height_bins = min_z:height_resolution:max_z;

    % 初始化存储下采样点的数组
    sampled_points_BP = [];
    sampled_points_RP = [];
    
    % 对每个网格单元进行下采样
    for i = 1:(length(angle_bins)-1)
        for j = 1:(length(height_bins)-1)
            % 找到当前网格内baselinePoint(BP)的点
            angle_mask = (theta_BP >= angle_bins(i)) & (theta_BP < angle_bins(i+1));
            height_mask = (z_BP >= height_bins(j)) & (z_BP < height_bins(j+1));
            cell_mask_BP = angle_mask & height_mask;
            cell_indices_BP = find(cell_mask_BP);
            
            if ~isempty(cell_indices_BP)
                % 计算网格内点的平均位置（在柱面坐标系中）
                avg_rho_BP = mean(rho_BP(cell_mask_BP));
                avg_theta = angle_bins(i) + 0.5*angle_resolution;
                avg_z = height_bins(j) + 0.5*height_resolution;
                
                % 转换回笛卡尔坐标系
                avg_x_BP = avg_rho_BP * cos(avg_theta);
                avg_y_BP = avg_rho_BP * sin(avg_theta);
                avg_point_BP = [avg_x_BP, avg_y_BP, avg_z];                
                sampled_points_BP = [sampled_points_BP; avg_point_BP, avg_rho_BP, avg_theta];
            end

              % 找到当前网格内RP的点
            angle_mask_RP = (theta_RP >= angle_bins(i)) & (theta_RP < angle_bins(i+1));
            height_mask_RP = (z_RP >= height_bins(j)) & (z_RP < height_bins(j+1));
            cell_mask_RP = angle_mask_RP & height_mask_RP;
            cell_indices_RP = find(cell_mask_RP);
            
            if ~isempty(cell_indices_RP)
                % 计算网格内点的平均位置（在柱面坐标系中）
                avg_rho_RP = mean(rho_RP(cell_mask_RP));
                avg_theta = angle_bins(i) + 0.5*angle_resolution;
                avg_z = height_bins(j) + 0.5*height_resolution;
                
                % 转换回笛卡尔坐标系
                avg_x_RP = avg_rho_RP * cos(avg_theta);
                avg_y_RP = avg_rho_RP * sin(avg_theta);
                avg_point_RP = [avg_x_RP, avg_y_RP, avg_z];                
                sampled_points_RP = [sampled_points_RP; avg_point_RP, avg_rho_RP, avg_theta];
            end

        end
    end
    downsampledRP = sampled_points_RP;
    downsampledBP = sampled_points_BP;

    bottom = min(downsampledBP(:, 3));
    top = max(downsampledBP(:, 3));
    downsampledRP = downsampledRP(downsampledRP(:, 3) >= bottom & downsampledRP(:, 3) <= top, :);

    %索引出Biofouling投影面的点云
    [lia, locb] = ismember(downsampledBP(:, [3, 5]), downsampledRP(:, [3, 5]), 'rows');
    downsampledBP_idx = find(lia);          % A中匹配的行索引
    downsampledRP_idx = locb(lia);          % B中对应的行索引
    
    % 去除零值（不匹配的情况）
    valid_mask = downsampledRP_idx > 0;
    downsampledRP = [downsampledRP(downsampledRP_idx(valid_mask), :), downsampledBP(downsampledBP_idx(valid_mask), :)];%x y z rou theta x y z rou theta

    Biof_thickness = downsampledRP(:, 4) - downsampledRP(:, 9);

    downsampledRP = downsampledRP(Biof_thickness>= 0, :);
    Biof_thickness = Biof_thickness(Biof_thickness(:, 1) >= 0);
 
end