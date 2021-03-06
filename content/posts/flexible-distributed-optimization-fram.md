+++
title = "与主机上其他任务共享资源的分布式优化框架"
author = ["tang"]
date = 2020-03-18
lastmod = 2020-03-21T08:49:14+08:00
tags = ["Infocom2019", "Computer_Network"]
categories = ["Study"]
draft = false
+++

<div class="ox-hugo-toc toc">
<div></div>

<div class="heading">Table of Contents</div>

- [1. 介绍](#1-dot-介绍)
    - [1.1 分布式优化](#1-dot-1-分布式优化)
    - [1.2 什么是次梯度 **subgrdient**](#1-dot-2-什么是次梯度-subgrdient)
    - [1.3 符号规定：](#1-dot-3-符号规定)
- [2. 模型与算法](#2-dot-模型与算法)
    - [2.1 问题模型](#2-dot-1-问题模型)
    - [2.2 算法](#2-dot-2-算法)
- [3. 收敛结果](#3-dot-收敛结果)
    - [](#)

</div>
<!--endtoc-->


## 1. 介绍 {#1-dot-介绍}

题目名为：A Flexible Distributed Optimization Framework for Service of Concurrent Tasks in
Processing Networks


### 1.1 分布式优化 {#1-dot-1-分布式优化}

让一群没有服务器指挥的节点，在仅和邻居通讯（类似于 P2P）的情况下达到整体最优解。需要分布式优化的原因自然是因为 CS 架构的优化模型存在缺点，比如单点故障等原因，参考知乎[刘家耿的回答](https://www.zhihu.com/question/59260302)，给出一个简单的形式化的表达式：
\\[
  \min\_{x\_i,\cdots,x\_n} \sum\_{i=1}^n f\_i(x\_i)
\\]

上面的公示与常规的优化公示相对应，CS 架构的的优化公示中的 x 是全局统一的，存储在中心 server 上，而分布式优化的 x 则存储在每一个 client 上，这里再借用下上面的回答中的一个流程进一步的阐述分布式优化：

```english
for each node i, simultaneously
*repeat*
    do gradient updates with own data;
    regularly exchange some information with neighbors;
    combine information according to some policy;
*until* reach consensus and optimaticaly
```

文章里描述的是，可以为机器学习和信号处理提供使用内部网络连接的处理通过间歇性通信来完成全局最优目标的方法。目前的很多分布式化算法假设所有的处理器都存储了相关数据，但实际上是很多全局最优任务是运行在共享资源的主机上的，所以需要提出一种能够灵活的和其他任务共享**资源**的分布式优化算法。

Here is a summary of classic and novel **Distributed Optimization**

> One of the pioneering works on distributed optimization was Tsitsiklis et al.’s
> work [22]. Since then, several types of methods have been proposed in this area,
> such as distributed subgradient descent (DSD) [8], [14], distributed dual
> averaging [4], [21], Alternating Direction Method of Multipliers (ADMM) [9],
> [18], Nesterov’s method [15], [17] and second-order algorithm [10], [23], with
> different performances and restrictions. Among these types, DSD is the most
> important algorithm because it is easily implemented in a distributed way (ADMM
> needs sequential variable updates and second order methods need costly
> distributed Hessian calculation), and the basis of many further developed
> algorithms. For example, by adding history gradient information to DSD, the
> methods in [13] and [16] can achieve a linear convergence rate for the sum of
> strongly convex and smooth functions with a constant stepsize. Nesterov’s method
> can also be considered as a variant of the gradient method. So in this paper, we
> will focus on gradient-based algorithms.

文章提出一套灵活的分布式次梯度(subgradient)算法，允许处理器通过基于概率地在多个正在进行的任务之间切换，从而同时处理多个正在进行的任务。


### 1.2 什么是次梯度 **subgrdient** {#1-dot-2-什么是次梯度-subgrdient}

> 当函数不可导时，无法通过常规的方法求梯度，也就无法使用梯度下降发来进行实现优化算法，因此针对存在不可导（不光滑）的函数提出其次梯度的概念，其标准定义为：
>
> g 是函数 f 在 x 点的次梯度，当
> \\[
>     f(y) \geq f(x) + g^T(y-x), \forall y
> \\]
>
> 上面的 g 是一个可能的次梯度，函数在某一点的次梯度是一个集合被记为&part; f(x)，对于一个凸函数而言，其 &part; f(x) 非空。所以可以使用类似于经典梯度下降的方法使用次梯度对不可导函数进行优化。


### 1.3 符号规定： {#1-dot-3-符号规定}

| 符号                       | 作用                                                                     |
|--------------------------|------------------------------------------------------------------------|
| \\(n\\)                    | **number** of processors                                                 |
| \\(x\_i^k, y\_i^k\\)       | **value** of Processor i in iteration k                                  |
| \\(a\_{ij}^k\\)            | **weight** of processor i put on value sent from j                       |
| \\(\partial f(x)\\)        | **set** of **subgradient** of function at x                              |
| \\(\nabla f(x)\\)          | **gradient** of f at x                                                   |
| \\(\Vert \cdot \Vert\_p\\) | \\(l\_p - norm\\) for vectors                                            |
| \\(\pi \\{x\\}\\)          | \\(\pi \\{x\\} = \arg \min \limits\_{y \in \chi} \Vert y-x \Vert\_2^2\\) |


## 2. 模型与算法 {#2-dot-模型与算法}


### 2.1 问题模型 {#2-dot-1-问题模型}

考虑优化的问题与上面提到的分布式优化问题相似，这里再抄写一遍：

\\[
    \min\_\limits{m \in \chi} f(x) = \frac{1}{n} \sum\_{i=1}^n f\_i(x)
\\]

其中 \\(f\_i(x)\\) 对在 \\(\chi\\) 上的所以 i 都是凸的。网络是一个静态的无向图 \\(G = (V,
\xi)\\) ，每个处理器 \\(process\_i\\) 仅能访问自己本地函数 \\(f\_i\\) 并计算起次梯度，同时
\\(Process\_i\\) 可以与邻居通信自己的值，邻居被记为 \\(N(i)\\) 。

计算次梯度需要的花费记为 1，在 1 条链路上两个处理器的产生的通信开销记为 \\(\tau\\)


### 2.2 算法 {#2-dot-2-算法}

对于一个有监督的分布式学习可以将每个处理器上的优化问题刻画为这个函数：
\\(f\_i(\theta) = l (h(x\_i; \theta), y\_i)\\) ，其中 h 是预测函数，l 是损失函数， \\(x\_i,
y\_i\\) 是处理器 i 本地存储的数据集中的数据， &theta; 是希望全局优化的参数，下面给出三个假设：

-   \\(f\_i(x)\\) 的次梯度是有界的；字面意思；
-   \\(f\_i(x)\\) 是 l 光滑的，(_Lipschitz smooth 利普希茨连续用来描述函数的平滑程度的，强调的是函数的梯度不会太突兀 L 是光滑程度，具体来说就是 x,y 两点的梯度差<= L|x-y|._)
-   \\(f\_i(x)\\) 是 &mu; -strongly convex。

分布式优化的目标是用做少的通信开销使得每个处理器上的 \\(x\_i^k\\) 收敛到(1)式的最优解。这里的一个重要想法就是能否一次今更新所有处理器的一个子集上的值，该子集外的处理器做其他任务并保持子集的值不变，能否也可以达到全局优化的目标。文章介绍了一个基于概率的部分更新的次梯度算法(PUSD)的算法如下：

{{< figure src="/ox-hugo/2020-03-18_11-42-07_screen-shoot.png" class="foo" width="500" >}}

其第 6-7 行是与其他主机交换信息的过程，第 8-14 行是根据概率选择是否计算次梯度以实现全局优化。

上面算法使用了概率划分的方法，实际上也有一些其他的硬划分模式，比如为不同的任务分配部分处理器数，但是对于有些时候数据因为隐私或者技术的原因不方便与其他处理器共享。上面的算法能够很好的估计出全局最优情况，但是在网络处理器上使用硬划分就很难做到（_这里留个问题，不是很理解为什么不能硬划分很难做到全局优化_）。


## 3. 收敛结果 {#3-dot-收敛结果}


###  {#}
