% 定义子问题约束，并每次调用时更新
% value of theta is the parameter
Constraints_sub = [];
Constraints_sub = [Constraints_sub, - lambda - 1 <= 0];
Constraints_sub = [Constraints_sub, lambda - 1 <= 0];
Constraints_sub = [Constraints_sub, mu <= 0];
Constraints_sub = [Constraints_sub, C' * lambda + D' * mu == 0];
Constraints_sub = [Constraints_sub, H' * zeta + C0' * lambda == 0];
Constraints_sub = [Constraints_sub,  (H * (x - x0) - G * theta_j) <= 0];
Constraints_sub = [Constraints_sub, -1e3 * zeta <= 0];
Constraints_sub = [Constraints_sub,  (- H * (x - x0) + G * theta_j -  M * t) <= 0];
Constraints_sub = [Constraints_sub,  1e3 * zeta - M * (1 - t) <= 0];
% Constraints_sub = [Constraints_sub, -x <= 0, x <= 288];

% % 目标函数
obj1 = c' * lambda + d' * mu + (G * theta_j + H * x0)' * zeta; 
obj1 = obj1 * 1;% R(theta)