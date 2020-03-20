+++
title = "OpenFlow"
author = ["tang"]
lastmod = 2020-03-19T11:34:57+08:00
tags = ["SDN", "Network"]
categories = ["Study"]
draft = false
+++

## 介绍 {#介绍}

这是 SDN 开山之作“OpenFlow: Enabling Innovation in Campus Networks”的阅读笔记，想要学习 SDN 到底是什么，能做什么，为什么，怎么做，还可以怎么做，研读开山之作显然是必不可少的。

文章的开篇主要阐述了作者实现 openflow 的主要目的，就是为了让研究人员能够在实际网络中测试他们提出的新方法，所以希望商用交换机和路由器可以提供一种通用的可编程的交换机，可以对流表执行一定的动作（action），并且为了不干扰生产生活中的网络，能够保证生产网络和研究网络的独立性。为此作者提出了这样的协议，文章有这样一句话：“hence the commonly held belief that the network infrastructure has "ossified" ”，作者就是想要打破这种"ossified"，这样的胸怀也就不奇怪 OpenFlow 和 SDN 能够在学界引起如此庞大的影响了。


## OpenFlow 交换机 {#openflow-交换机}

现在的交换机和路由器大多都提供了一个流表(`Flow Table`) OpenFlow 为各种不同的
