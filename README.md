# OVB (Optimal Virtual Battery) 模型实现

本项目复现了最优虚拟电池（OVB）模型，用于测试其计算性能和优化效果。

## 参考文献

本实现基于以下论文：
Z. Tan, A. Yu, H. Zhong, X. Zhang, Q. Xia and C. Kang, "Optimal Virtual Battery Model for Aggregating Storage-Like Resources with Network Constraints," in CSEE Journal of Power and Energy Systems, vol. 10, no. 4, pp. 1843-1847, July 2024, doi: 10.17775/CSEEJPES.2022.04090.

## 数学模型

### 主要变量
- θ = (PB_C, PB_D, E_C, E_D): 虚拟电池参数
- x(t): t时刻的用电负荷
- λ, μ, ζ: 对偶变量

### 目标函数
最大化虚拟电池容量：
```
max η'θ
```

其中 η 为电池配置参数向量。

### 关键约束
1. 虚拟电池参数约束：
```
0 ≤ θ ≤ θ_max
```

2. 负荷可行性约束：
```
Cx ≤ c   (运行约束)
Dx = d   (平衡约束)
Gx ≤ g   (网络约束)
```

### Benders 分解算法

1. 主问题：
```
max η'θ
s.t. θ ∈ Θ
    R(θ) ≤ 0
```

2. 子问题：
```
R(θ) = max{λ'(c-Cx) + μ'(d-Dx) + ζ'(g-Gx)}
s.t. λ ≥ 0, ζ ≥ 0
```

## 项目结构

主要文件说明：
- `main.m`: 主程序入口，用于调用不同模型进行对比测试
- `VB_benders.m`: 使用 Benders 分解方法实现的 OVB 模型求解器
- `Constraints_master_problem_VB.m`: OVB 模型主问题约束定义
- `Constraints_sub_problem_VB.m`: OVB 模型子问题约束定义

## 算法流程

1. 初始化：
   - 设定初始 θ = θ_max
   - 初始化对偶变量 λ, μ, ζ

2. 迭代求解：
   - 求解子问题，获取对偶变量
   - 求解主问题，更新 θ
   - 检查收敛条件 R(θ) ≤ ε

3. 输出结果：
   - 最优虚拟电池参数 θ_vb
   - 计算时间统计
   - 迭代收敛过程

## 使用方法

1. 运行 `main.m` 进行模型测试
2. 可通过修改参数进行不同场景的测试：
   - 调整时间周期 T
   - 修改电池配置参数 η
   - 更改收敛阈值 ε

## 计算结果

程序会输出：
- 最优虚拟电池参数 θ_vb
- 主问题计算时间统计
- 子问题计算时间统计
- 总体求解时间
- 迭代收敛过程记录
```