
%% VB model
% 求解θ=（PB_C.PB_D, E_C, E_D)
% 双层规划问题 主问题max η' * θ，s.t. B(θ)包含于P

%% 子问题变量
% 对偶变量lambda, mu, zeta
lambda = sdpvar(size(C, 1), 1, 'full'); % 子问题tan.式（1）对应的决策变量
mu = sdpvar(size(D, 1), 1, 'full'); % 子问题tan.式（2）对应的决策变量
zeta = sdpvar(size(G, 1), 1, 'full'); % 子问题式（3）对应的决策变量

% 整个工厂的用能
x = sdpvar(T, 1, 'full');

% 定义0-1变量
t = binvar(size(G, 1), 1); % 子问题中的决策变量

%% 初始化
M = 1 * 1e5; % 非常大常数
theta_j = theta_max; % 初始值等于theta_max，可以减少迭代次数，向上取整可以减少计算时间
eta = [1; 1; 0.1; 0.1]; % 电池配置参数

result_mu = [];
result_lambda = [];
result_theta = [];
result_R = [];
result_time = []; % 新增：用于存储每次迭代的计算时间
result_time_sub = []; % 新增：存储子问题求解时间
result_time_master = []; % 新增：存储主问题求解时间


%% 主问题变量
% 迭代变量
iter=1;   maxIter=100; % maxIter是最大迭代次数
ex = sdpvar(T, maxIter, 'full');   % ex是主问题的x
xi = sdpvar(size(G, 1), maxIter, 'full');  % 主问题中tan.式（3）对应的dual 变量
z = binvar(size(G, 1), maxIter);  % 主问题中的01变量
ops=sdpsettings('solver', 'GUROBI', 'verbose', 0);

% 打印初始信息
disp('==================== OVB Benders 分解求解开始 ====================');
disp(['最大迭代次数: ', num2str(maxIter)]);
disp(['收敛阈值: 1e-5']);
disp('============================================================');

%% 构造子问题的约束及目标函数-first iter
Constraints_sub = [];
Constraints_sub_problem_VB;

% 第一次迭代——子问题
disp(['迭代 1:']);
tic; % 计时开始：第一次子问题求解
result1 = optimize(Constraints_sub, -obj1, ops);
sub_time = toc; % 计时结束：第一次子问题求解
result_time_sub = [result_time_sub, sub_time];

% 打印第一次迭代结果
disp(['  子问题求解时间: ', num2str(sub_time), ' 秒']);
disp(['  目标函数值 R(θ): ', num2str(value(obj1))]);
disp('------------------------------------------------------------');

% update mu and lambda
mu_j = value(mu);
lambda_j = value(lambda);
R_j = value(obj1);
result_mu = [result_mu, mu_j];
result_lambda = [result_lambda, lambda_j];
result_R = [result_R, R_j];


%% Benders deconposition

% 虚拟电池参数(优化目标)
theta = sdpvar(4, 1, 'full');
obj2 = eta' * theta;
% Constraints_m——主问题的约束
Constraints_m = [];
Constraints_m = [Constraints_m, theta <= theta_max];

% 开始迭代，直至R（θ）<=0或足够接近0
while value(obj1) >= 1e-5

    % add new feasible cuts to the master problem
    Constraints_master_problem_VB;
    Constraints_m = [ Constraints_m, Constraints_fsb_cut];

    % solve the master problem
    ops=sdpsettings('solver', 'GUROBI', 'verbose', 0);
    disp(['迭代 ', num2str(iter+1), ':']);
    tic; % 计时开始：主问题求解
    result2 = optimize(Constraints_m, - obj2, ops);
    master_time = toc; % 计时结束：主问题求解
    result_time_master = [result_time_master, master_time];
    
    % add constraints of the masterproblem, 
    Constraints_m = [ Constraints_m, eta' * theta <= 1 * value(obj2)];
   
    % update theta
    theta_j = value(theta) ; 
    result_theta = [result_theta, theta_j];
    ax = value(ex);
    % 打印主问题结果
    disp(['  主问题求解时间: ', num2str(master_time), ' 秒']);
    disp(['  当前 theta 值: [', num2str(theta_j'), ']']);
    
    iter = iter + 1;

    % add constraints of the subproblem
    Constraints_sub = [];
    Constraints_sub_problem_VB;

    % solve subproblem
    ops=sdpsettings('solver', 'GUROBI', 'verbose', 0);
    tic; % 计时开始：子问题求解
    result1 = optimize(Constraints_sub, - obj1, ops);
    sub_time = toc; % 计时结束：子问题求解
    result_time_sub = [result_time_sub, sub_time];

    % update mu and lambda
    mu_j = value(mu);
    lambda_j = value(lambda);
    R_j = value(obj1);
    result_mu = [result_mu, mu_j];
    result_lambda = [result_lambda, lambda_j];
    result_R = [result_R, R_j];
    
    % 打印子问题结果
    disp(['  子问题求解时间: ', num2str(sub_time), ' 秒']);
    disp(['  目标函数值 R(θ): ', num2str(R_j)]);
    disp('------------------------------------------------------------');
    
    if iter >= maxIter
        disp('警告：达到最大迭代次数，算法终止');
        break
    end
end

% 打印最终结果
disp('==================== 计算完成 ====================');
disp(['总迭代次数: ', num2str(iter)]);
disp(['最优 theta_vb = [', num2str(theta_j'), ']']);
disp(['子问题总计算时间 = ', num2str(sum(result_time_sub)), ' 秒']);
disp(['主问题总计算时间 = ', num2str(sum(result_time_master)), ' 秒']);
disp(['总计算时间 = ', num2str(sum(result_time_sub) + sum(result_time_master)), ' 秒']);
disp('================================================');

