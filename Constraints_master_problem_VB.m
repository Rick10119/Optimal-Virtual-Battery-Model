% 定义主问题约束，并每次调用时添加新约束，即添加新的可行性割集
% lambda, mu are the parameters
% ex, xi, theta, z are the variables
Constraints_fsb_cut = [];

Constraints_fsb_cut = [Constraints_fsb_cut, (c - C0 * ex(:, iter))' * result_lambda(:, iter) + d' * result_mu(:, iter) <= 0];

Constraints_fsb_cut = [Constraints_fsb_cut, H' * xi(:, iter) + C0' * result_lambda(:, iter) == 0];

Constraints_fsb_cut = [Constraints_fsb_cut, H * (ex(:, iter) - x0) - G * theta <= 0];

Constraints_fsb_cut = [Constraints_fsb_cut, - H * (ex(:, iter) - x0) + G * theta <= M * z(:, iter)];

Constraints_fsb_cut = [Constraints_fsb_cut, - xi(:, iter) * 1e3 <= 0];

Constraints_fsb_cut = [Constraints_fsb_cut, 1e3 * xi(:, iter) <= M * (1 - z(:, iter))];


