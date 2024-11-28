%% 计算x0和theta_max
load("CD_Para.mat");
T = size(C0, 2);
% 机器在各运行状态的运行时间
y = sdpvar(size(C, 2), 1, 'full');%共T*K*I个变量，前K个，机器1在时段1的三个时间；
% K+1 ~ 2K个，机器2时段1；以此类推。

% 整个工厂的用能
x = sdpvar(T, 1,  'full');
%% 构造约束 参考tan.（6）
B3 = B1;
B3(1, T) = -1;% 保证x0的子元素相等

Constraintsx0 = [C0 * x+C * y == c, D * y <= d, B3 * x == 0];

Price = ones(T);

%% 求x0

% 配置求解器
ops=sdpsettings('solver','GUROBI','verbose',0);

objmin = Price(:, 1)' * x;  
objmax = Price(:, 1)' * x;

% 求解
% 求成本最小时的用电，此时x最小
result_min = optimize(Constraintsx0, objmin, ops);
x_min = value(x);

% 求成本最大时的用电，此时x最大
result_max = optimize(Constraintsx0, -objmax, ops);
x_max = value(x);

x0 = x_min;
% x0 = (x_min + x_max) / 2; % x0在最大值与最小值的中间


%% 求theta_max
Constraints = [C0 * x + C * y == c, D * y <= d];

% 最小功率
p_min = x_min(1, 1);
for m = 1 : T
    power_min = optimize(Constraints, x(m, 1), ops);
    p_min = min(value(x(m, 1)), p_min);
end

% 最大功率
p_max = x_max(1, 1);
for m = 1 : T
    power_max = optimize(Constraints, - x(m, 1), ops);
    p_max = max(value(x(m, 1)), p_max);
end

% 此时总能量下限最大
energy_min = optimize(Constraints, objmin, ops);
e_min = value(x);

% 此时总能量上限最大
energy_max = optimize(Constraints, -objmax, ops);
e_max = value(x);

theta_max = [p_max - x0(1); x0(1) - p_min; T * (p_max - x0(1));...
    T * (x0(1) - p_min)];

% 展示
disp([' x0 =   ',num2str(x0')]);
disp([' theta_max =   ',num2str((theta_max)')]);

% 保存x0和theta_max
save("x0andtheta_max.mat", "theta_max", "x0");

