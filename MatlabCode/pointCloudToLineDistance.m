function distances = pointCloudToLineDistance(P, line_point, line_direction)
% P: 点云坐标，N×3矩阵
% line_point: 直线上一点，1×3向量
% line_direction: 直线方向向量，1×3向量（需要归一化）

% 归一化方向向量
line_direction = line_direction / norm(line_direction);

% 计算点到直线上参考点的向量
vectors = P - line_point;

% 计算投影长度（标量投影）
projection_length = dot(vectors, repmat(line_direction, size(P,1), 1), 2);

% 计算投影点坐标
projection_points = line_point + projection_length .* line_direction;

% 计算点到直线的距离
distances = sqrt(sum((P - projection_points).^2, 2));
end