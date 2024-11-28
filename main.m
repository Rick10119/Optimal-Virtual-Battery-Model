%% OVB模型测试程序
% 本程序用于测试OVB（最优虚拟电池）模型的性能和效果
% 作者：[您的名字]
% 日期：[日期]

%% 初始化环境
clc
clear
disp('==================== OVB模型测试开始 ====================');

%% 参数设置
% 基础参数
fac_id = 1;         % 用户编号
T = 24;             % 时间周期（小时）
pt = 4;             % 参数调整系数

% 显示参数设置
disp('参数设置:');
disp(['- 用户编号: ', num2str(fac_id)]);
disp(['- 时间周期: ', num2str(T), ' 小时']);

%% 数据导入
disp('正在导入数据...');
% 读取工业用户数据
filename = '工业用户.xlsx';
sheet_name = ['Sheet', num2str(fac_id)];
data = readtable(filename, 'Sheet', sheet_name);
user = table2array(data);

% 计算基本参数
I = max(user(:, 1));    % 环节数
KI = size(user, 1);     % 环节数*状态数
K = KI / I;             % 状态数

disp(['- 成功导入用户 ', num2str(fac_id), ' 的数据']);
disp(['- 环节数: ', num2str(I)]);
disp(['- 状态数: ', num2str(K)]);

%% 参数计算
disp('正在进行参数计算...');

% 调整物料参数
para_change;
disp('- 完成物料参数调整');

% 生成LSTN的常数矩阵
CD_LSTN;
disp('- 完成LSTN常数矩阵生成');

% 计算基线和参数最大值
x0andtheta_max;
disp('- 完成基线和参数最大值计算');

%% VB模型求解
disp('开始求解VB模型...');

% 初始化参数存储
LSTN_DR_capility(:, 0.5 * T) = theta_max;

% 生成VB模型矩阵
VB_HG;
disp('- 完成VB模型矩阵生成');

% 使用Benders分解求解
disp('- 开始Benders分解求解...');
VB_benders;

%% 结果展示
disp('==================== 测试完成 ====================');




