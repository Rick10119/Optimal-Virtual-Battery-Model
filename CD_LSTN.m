%% 生成LSTN的常数矩阵，C、D、C0、c、d

% 2024.04.26
%% C0x + Cy = c--tan.(1)
% 初始化   根据LSTN约束计算C0, C, D, c, d，根据tan.的第（3）式，计算出H、G

P_NP = zeros(T); % x = P_NP * y
for n = 1 : T
    P_NP(n, (n - 1) * KI + 1 : n * KI) = P_np'; 
end

A1 = zeros(T * I); % Σttif = deltat对应的矩阵，可以写成A1 * y=ones
ones_matrix = ones(1,  K); 
for n = 1 : T * I
    A1(n, (n - 1) * K + 1 : n * K) = ones_matrix; 
end
C = [ - P_NP; A1]; % y的系数矩阵

% C0
C0 = [eye(T); zeros(T * I, T)]; % x的系数矩阵

% c
c = [zeros(T, 1); ones(T * I, 1)]; % c


%% Dy <= d--tan.(2)
%
% 对应LSTN中的不等式约束，包括S >= 0; S >= S_0_i + S_tar; S <= S_max; 三个式子
% 其中S由S_0和各个机器的运行时间y所决定，
% 写成等式为temp1 * S = S_0 + temp2 * y; temp1、temp2分别为S和y的系数矩阵
B1 = eye(T); % 临时矩阵，方便计算
for n = 2 : T
    B1(n, n - 1) =  - 1; %  - 1是S(t) - S(t - 1) = G(n) * t - G(n + 1) * t
end

temp1  =  zeros(I + 1); % 计算S的系数矩阵
for n  =  1 : I + 1% temp1由11个B1在对角线确定，B1是11 * 11的可逆矩阵
    temp1((n - 1) * T + 1 : n * T, (n - 1) * T + 1 : n * T) = B1; 
end

temp2 = zeros(T * (I + 1), I * T * K); % 计算y的系数矩阵
% temp2由物料的生产参数和消耗参数决定
for n = 1 : I
    for m = 1 : T
    temp2((n - 1) * T + m, (m - 1) * KI + (n - 1) * K  +  1 :...
        (m - 1) * KI + n * K) =  - C_matrix(n, :); 
    temp2((n) * T + m, (m - 1) * KI + (n - 1) * K  +  1 : ...
        (m - 1) * KI + n * K) = G_matrix(n, :); 
    end
end

A2 = temp1 \ temp2; % 简化表达形式 S = A2 * y + temp1 \ S_0
% S >= S_0_i + S_tar, 其中S指的是在t_end时，物料需要达到生产要求，而不是每个S都要达到
% 所以需要在S前面添加一个系数矩阵，提取出生产结束时的物料状态
% 原约束：A3 * S >= S_0_i + S_tar
A3 = zeros(I + 1, T * (I + 1)); 
for n = 1 : I + 1
    A3(n, T * n) = 1; 
end

% A2为将temp1 \ temp2; 
% 原不等式变成 - A2 * y <= temp1 \ S_0; 
% A2 * y <= S_max - temp1 \ S_0; 
% A2 * y <= temp1 \ S_0 - (S_0_i + S_tar_i); 
% D
D = [-A2; A2; -A3 * A2; -eye(K * I * T)]; 

% d
d =  [temp1 \ S_0; S_max - temp1 \ S_0; A3 * (temp1 \ S_0) - (S_0_i + S_tar); ...
    zeros(K * I * T, 1)]; 

save("CD_Para.mat","C0","c","C", "D", "d","B1");