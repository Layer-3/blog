+++
title = "OpenFlow"
author = ["tang"]
date = 2020-03-19
lastmod = 2020-03-22T11:32:53+08:00
tags = ["SDN", "Network"]
categories = ["Study"]
draft = false
+++

## 1. 介绍 {#1-dot-介绍}

这是 SDN 开山之作“OpenFlow: Enabling Innovation in Campus Networks”的阅读笔记，想要学习 SDN 到底是什么，能做什么，为什么，怎么做，还可以怎么做，研读开山之作显然是必不可少的。

文章的开篇主要阐述了作者实现 openflow 的主要目的，就是为了让研究人员能够在实际网络中测试他们提出的新方法，所以希望商用交换机和路由器可以提供一种通用的可编程的交换机，可以对流表执行一定的动作（action），并且为了不干扰生产生活中的网络，能够保证生产网络和研究网络的独立性。为此作者提出了这样的协议，文章有这样一句话：“hence
the commonly held belief that the network infrastructure has "ossified" ”，作者就是想要打破这种"ossified"，这样的胸怀也就不奇怪 OpenFlow 和 SDN 能够在学界引起如此庞大的影响了。


## 2. OpenFlow 交换机 {#2-dot-openflow-交换机}


### 2.1 总览 {#2-dot-1-总览}

现在的交换机和路由器大多都提供了一个流表(`Flow Table`)，可以以线性速度实现防火墙、NAT、QoS 和数据统计信息等功能。 OpenFlow 为各种不同的交换机和路由器提供一种开放的协议来对流表进行编程。


#### 2.1.1 基本组成 {#2-dot-1-dot-1-基本组成}

OpenFlow 交换机至少需要包括三个部分：

-   `流表(FlowTable)`，流表上的每个项(entry)关联的一个**动作(action)**，告诉交换机如何处理这个流[^fn:1]；
-   `安全信道(Secure Channel)`，将交换机和远程控制进程(_controller_)链接，允许指令和包在交换机和控制器 controller 之间传送；
-   `OpenFlow 协议`，为 Controller 和交换机之间通信提供一种标准方法。通过指定标准接口（OpenFlow 协议），可以从外部定义流表中的条目，而不用直接对交换机进行编程。

{{< figure src="/ox-hugo/2020-03-21_17-18-41_screen-shoot.png" class="foo" width="500" >}}


#### 2.1.2 Flow Table {#2-dot-1-dot-2-flow-table}

OpenFlow 将交换机分为两种，一种是**Dedicated OpenFlow switches**，这种 OpenFlow 交换机不支持常规的 Layer 2 和 Layer 3 的处理，它在端口间按照远程 Controller[^fn:2] 定义的要求转发 packets。另一种则是在现有的商业路由器或交换机上添加 OpenFlow 的三要素的**OpenFlow-enabled swithes**，增加 OpenFlow 的支持。

每个 Flow-Table 中的 entry 由三个部分组成：

-   定义 flow 的包头(header[^fn:3])，其中 header 的初步设计如下表所示；
-   定义怎么处理 packets 的动作(action)；
-   统计 Flow 中的 packets 数目和字节数的统计量。

{{< figure src="/ox-hugo/2020-03-21_18-12-39_screen-shoot.png" class="foo" width="500" >}}

针对每个 Flow Table 中的 Flow 关联的基础 Action 有：(`Type 0 要求`)

-   转发 flow 中的 packets 到指定的端口（们），这提供了网络中的路由功能；
-   封装并转发 flow 中的 packets 到 controller，_通常情况下是把新的 flow 中的第一个 packet 过去，从而考虑是不是需要添加到 Flow Table 中去_；
-   drop packet，处于安全、防治 dos 攻击等考虑。
-   把 Flow 中的 packets 通过交换机传统的传统方式转发出去（_这是针对 OpenFlow 支持的商业交换机，可以分离[^fn:4]实验与生产数据_）


### 3. 使用 {#3-dot-使用}

根据论文提供的案例，可以总结出如下大致步骤。首先定义一个流，将具有特定属性的数据包发送到控制器，然后在控制器中执行逻辑，然后将针对流的动作下放到个交换机，从而在一整个网络中完成对 Flow 的控制。

[^fn:1]: 流指的是网络中，具有相同属性的一类报文等，因此流的定义可能是广义的，具有相同的属性（可以指的是相同源 IP 地址，MAC 地址，端口等）的 pakcets 都可以被称之为是流。
[^fn:2]: 一个交换机可以被多个远程控制器控制。
[^fn:3]: Header 中的表项均可以通过通配符来进行匹配，从而聚集想要的流，实施策略。
[^fn:4]: 除了添加这个动作来分离实验与生产数据之外，还可以通过开议分离虚拟子网(VLANs)集合来分离这两种流量。
