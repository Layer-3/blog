+++
title = "TransE，连接多关系实体"
author = ["tang"]
date = 2020-04-19
lastmod = 2020-04-19T23:29:31+08:00
tags = ["Knowledge_Graph"]
categories = ["Study"]
draft = false
+++

## Point {#point}

本次学习的是知识表示、知识工程、知识图谱之类的中一篇很重要的论文，[TransE: Translating Embeddings for Modeling Multi-relational Data](http://papers.nips.cc/paper/5071-translating-embeddings-for-modeling-multi-relational-data.pdf)，讲述的是如何对多关系的实体进行连接。直接来讲就是要使得 `h+l=t`。


## 需要知道的东西 {#需要知道的东西}

什么是知识图谱，一种定义是“知识图谱是语义网络上的知识库”，也就是个多关系图。他的目的就是要表示出实体与实体之间的关系，实体指的是现实世界中的事物比如人、地名、概念、药物、公司等，关系则用来表达不同实体之间的某种联系，比如人-“居住在”-北京、张三和李四是“朋友”、逻辑回归是深度学习的“先导知识”等等。又比如人和人之间的关系可以是“朋友”，也可以是“同事”关系。构建这样的一个知识图谱就获得了一个结构化的知识库，当我们执行搜索的时候，就可以通过关键词提取（"张三", "李四", "朋友"）以及知识库上的匹配可以直接获得最终的答案[^fn:1]。

多关系数据的有向图里面的节点就是**实体Entities**，而边则象征着这样一个**三元组(h, l, t)**，(head, label, tail)，每个边表示的就是在实体head和tail之间有着名为label的关系。我们要做的是要学习出实体与关系之间的**表示**。


## 方法 {#方法}

文章强调使用了embedding 空间的translation来表示关系，从而得到了很好的效果，那么为什么“翻译”能够表示关系呢？实际上我觉得这里的translation表达的应该是**转移**。也就是说从一个向量转移到另一个向量，而转移的过程就是两个向量的关系，使用null转移向量就可以表示实体之间的等价关系了，所以看起来，用转移是可以表示的。

那么怎么表示转移呢？数轴中，a+b可以表示a向右移动了b个单位，那么h+l也可表示h移动了l个单位，因此答案呼之欲出，要使得**h+l=t**。


## 实现 {#实现}

给定训练集S，S包含一系列三元组(h,l,t)，其中h,t &isin; E(实体集)，l &isin; L(关系集)，要把实体和关系embed到k维，其中k是一个超参数。本质想法就是要使得(h,l,t)这条关系存在时，尽量使得h+l &asymp; t，而反之则尽量远离。采用基于energy的方法表示这个目标（这个基于energy的方法没有搞懂他的描述目的，但从公式和代码来看，这里的判断标准就是计算距离。）即使用d(h,l,t)，其中d可以是 \\(L\_1, L\_2\\) 范数。

损失函数如下：

\\[
\mathcal L = \sum\_{(h,l,t) \in S} ~ \sum\_{(h',l,t') \in S'\_{(h,l,t)}} [\lambda + d(h+l, t) - d(h'+l,t')]\_+
\\]

其中$[x]\_+$表示$x$中的正数部分。并且：

\\[
S'\_{(h,l,t)} = \\{ (h',l,t)|h' \in E \\} \cup \\{ (h,t,l') | t' \in E \\}
\\]

上式构造不正确的三元组，头部或尾部被随机实体代替（但肯定有一个是属于训练项中的实体）。

这样通过随机梯度下降进行训练，就能实现有关系的距离近，没关系的距离远。如下：

{{< figure src="https://gitee.com/layer3/pic/raw/master/uPic/20200419230343-screen-shoot.png" >}}

先根据前人[^fn:2]提出的随机过程初始化实体和关系的所有Embed。在算法的每个主要迭代中，实体的嵌入向量首先进行归一化。然后，从训练集中采样一小部分三元组，并将其作为一个batch的训练三元组。然后，对于每个这样的三元组，我们产生一个不正确的三元组。然后通过采用具有恒定学习率的梯度步骤来更新参数。根据算法在验证集中的性能停止更新。


## 我的问题 {#我的问题}

那么训练出来的结果是什么呢？

训练出来的结果就是对关系和实体的Embed vector，也就是实体和关系的低维向量，并且满足，如果有(h,l,t)的话，就会有h+l=t[^fn:3]。

[^fn:1]: 参考自机器之心 <https://www.jiqizhixin.com/articles/2018-06-20-4>;
[^fn:2]: X. Glorot and Y. Bengio. Understanding the difﬁculty of training deep feedforward neural networks. In Proceedings of the International Conference on Artiﬁcial Intelligence and Statistics (AISTATS)., 2010.
[^fn:3]: 感谢ZJU的陈少帮助我解疑答惑。
