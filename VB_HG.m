%% 生成VB模型的H、G
%  H * (x - x0) <= G * theta  tan.(3)
% H
B2 = eye(T); 
for i = 1 : T
    B2(i, 1 : i - 1) = 1; % 代表前i个（x - x0）之和小于能量上下界
end
H = [eye(T);  - eye(T); B2;  - B2]; 

% G
G = zeros(4); 
G(1, 1 : T) = ones(1, T); 
G(2, T + 1 : 2 * T) = ones(1, T); 
G(3, 2 * T + 1 : 3 * T) = ones(1, T); 
G(4, 3 * T + 1 : 4 * T) = ones(1, T); 
G = G'; 

% 虚拟电池的模型的每个参数需要保证有意义，因此必须添加下面约束
% -P_max*T+E_max<=0;-P_min*T+E_min<=0 电池能量的上/下限不能超过所有时段的最大充/放电功率之和
G = [G; T, 0, -1, 0; 0, T, 0, -1];
H = [H; zeros(2, T)];

% if theta_max(3) >= theta_max(1) || theta_max(4) >= theta_max(2)
%     G = [G; -1, 0, 1, 0; 0, -1, 0, 1];  
%     H = [H; zeros(2, T)];
% end
save("VB_HG_Para.mat", "H", "G");