%% 初始参数调整函数，使得问题可行
% 生成物料参数S_0,S_tar,S_max
S_max_0 = [1000; user(:, 6)];
S_max_0 = S_max_0(~isnan(S_max_0));

S_0_i = 0.9 * S_max_0;
S_0_i(end) = 0;

S_tar = [-800; 0 * S_max_0(2 : end, 1)];
S_tar = S_tar(~isnan(S_tar));

S_max = zeros((I + 1) * T, 1);
S_0 = zeros((I + 1) * T, 1);

for m = 1 : I+1
    S_0((m - 1) * T + 1, 1) = S_0_i(m, 1);
    for n = 1 : T
    S_max((m - 1) * T + n, :) = S_max_0(m, 1);
    end
end

% 生成生产系数矩阵G_matrix，消耗系数矩阵C_matrix,功率矩阵P_np
G_matrix = reshape(user(:, 3), K, I)';
C_matrix = reshape(user(:, 4), K, I)';
P_np = user(:, 2);

%
S_tar(I + 1, 1) =   0.5 * T * 15;
