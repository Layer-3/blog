+++
title = "高级计算机网络学习笔记"
author = ["tang"]
date = 2020-03-18
lastmod = 2020-03-24T12:55:17+08:00
tags = ["Network"]
categories = ["Learn"]
draft = false
+++

_This is for Adcanced Computer Networks learn note_

---


## Part I Datacnter Networks {#part-i-datacnter-networks}


### 1. FartTree {#1-dot-farttree}


### 2. DCN-Portland {#2-dot-dcn-portland}


#### 2.1 Abstract {#2-dot-1-abstract}


#### 2.2 Design {#2-dot-2-design}


#### 2.3 Implementation {#2-dot-3-implementation}


#### 2.4 Tips {#2-dot-4-tips}

-   与 FartTree 的连接方式不同，由于 FartTree 的连接方式是固定的，而 Portland 是没有固定的连接哪个交换机的哪个端口的要求的，同样的对编号也没有要求。
-   为什么要让 edge 投票选 id，因为冉 Aggre switch 来分配的会可能会冲突；
-   每个 switch 都会连接到 fabric manager，其作为 control plane 运行；
-   为什么需要 PMAC，因为 FatTree 中的 ip 地址是分配给虚拟机的，如果虚拟机迁移了，就要重新分配 ip，而是 PMAC 就不用进行手动来管理；


### 3. Helios：混合的电光交换机 Arch for Modular Data Centers {#3-dot-helios-混合的电光交换机-arch-for-modular-data-centers}


#### 3.1 介绍 {#3-dot-1-介绍}

什么是 Modular，指的就是数据中心的一个部分，里面是个完整的包含服务器、网络散热器等均已配置的很完善的一个模块数据中心。其实就是将数据中心模块化，将各个小的模块组织在一起就是一个大的数据中心。研究的重点就是怎么为 modular 之间实现好的通信。想法就是将带宽变成资源池，按需进行分配，节省成本。


#### 3.2 Ciuruit Switch {#3-dot-2-ciuruit-switch}

ppt 里的 circuit switch 和 optical switch 是一个意思。

作为第 0 层交换：物理层的交换，把 a 端口进来的光通过镜子反射到 b 端口出去。

波分复用：把多个光信号(比如红,黄,蓝色光)调制在一起传输，再通过解调器输出为多个光信号


#### 3.3 Simulation {#3-dot-3-simulation}

p：有 p 个端口连到交换机，c：有 c 个端口连接到光交换机；

M：所有的 pods 加一起共有 M 个端口连光交换机。


#### 3.4 Prototype: {#3-dot-4-prototype}

把一些物理交换机利用 vlan 虚拟出来多个虚拟交换机用于 pods。一台物理交换机用作核心交换机，每个 pods 有一个端口连接到以太网交换机

每个光交换机连接到 pod 中的一个端口。

LAG:为指向某一个 pod 的物理**光路**端口指定一个为集合形成逻辑端口。如果 LAG 里的端口为 0 的话，就说明指向这个 pod 的数据应该走 packet switch。

通过现有的 traffic Matrix 估计出 Demand Matrix。

在 Demand Matrix 中，因为光交换的特点，每一行、每一列只能满足一个。

<span class="underline">当 w=4 时，即使有个 demand 是 7，但是仍然只能传 4，所以在点亮格子的计算时需要注意。</span>


#### 3.5 总结 {#3-dot-5-总结}

Blocking Switch:打通一条路的代价是堵塞所有其他路，光交换机就是，而包交换机不是。

从 FatTree 开始，其只是一个拓扑结构，没有迁移、容错等问题，到了 Portland 其在资源增多时，需要大量的交换机。通过引入光交换机，Portland 中的大量交换机是为了应对最坏情况，这里通过观察的传输情况，对传输进行按需分配。


### Project I {#project-i}

beacon:ap 往外面发送的关于自身的 ssid 等信息的包；


## Part II Protocols {#part-ii-protocols}


### 1. MPTCP {#1-dot-mptcp}


#### 1.1 背景 {#1-dot-1-背景}

现在是一个路径上连接，希望能建立多条路径，能够和 TCP 公平竞争，应用程序兼容性。

在 TCP Option 字段定义 MP……指定使用 MPTCP。

huawei: Turbo Link


#### 1.2 Congestion Control {#1-dot-2-congestion-control}

`有拥塞就退让，有空闲就争取`。

TCP 使用的 AMID，慢启动，快撤退；

对 MPTCP，算法的公示比较复杂，建议查看 ppt。收到 ACK 后，把`一些子流` 的窗口增大，但是如果丢包，则只把`该子流`的窗口减半。

对于 Coupled，不能把其他路径减到 0.至少要留一个 probe，就涨是全局的，但是跌只和自己相关。考虑 RTT 进行泛化之后得到了现在用的算法。
