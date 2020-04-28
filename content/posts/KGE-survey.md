+++
title = "知识图谱Embedding综述"
author = ["tang"]
date = 2020-04-22
lastmod = 2020-04-27T19:37:04+08:00
tags = ["KnowledgeGraph", "NLP"]
categories = ["Study"]
draft = false
+++

_学习[Knowledge Graph Embedding: A Survey of Approaches and Applications](http://ieeexplore.ieee.org/abstract/document/8047276/)_


## 1. 预备知识 {#1-dot-预备知识}

_这部分是我自己在阅读过过程中遇到不懂的地方，自行查阅记录，以供理解_

-   Embedding:是一个将离散变量转为连续向量表示的一个方式，不光可以减少离散变量的空间维数，同时还可以有意义的表示该变量。上面这句话的意思就是说，把词语拆成指定数量的特征维度，每一个词都可以用这些维度组合成的向量来表示（word embedding 的含义[^fn:1]）。相对于稀疏的 one-hot 编码而言，这样的编码可以表示出不同的词语之间的临近关系。
-   tensor: 张量，在物理学中张量被定义为是一种无关于坐标系的物理量，不需要进行线性（坐标）变换，以统一的方式表达定理的物理量，但是在机器学习中，显然不是这个意思。张量在这里指的是一个多维的数据存储形式，维度被称之为张量的阶(mode)，可以看成向量和矩阵在多维空间的推广，即把向量看作一维张量，矩阵看作二维张量。上述信息和张量的一些运算法则可以参考这篇[文章](http://www.xiongfuli.com/%E6%9C%BA%E5%99%A8%E5%AD%A6%E4%B9%A0/2016-06/tensor-decomposition-part1.html)
-   Circular Correlation: 循环相关，对应的是线性相关。相关反应的是同步性、相似性、同相性等，具体的计算方法就是给定位移量 m，计算 x 和 y+m 的对应的点的乘积的和，线性相关的计算公式为： \\(r\_{xy}(m) = \sum\_{n=-\infty}^{+\infty} x(n) y(n+m)\\) 。循环相关稍微复杂一点，首先要将上面的有限序列通过向左循环移位得到周期序列（周期就是序列的原长度），然后套用公示进行计算： \\(r\_{xy}(m) = \sum\_{n=0}^{N-1} x(n) y((n+m))\_N R\_N(n)\\) ，计算过程就是循环移位(偏移 m 是多少就移位多少)相乘的乘积和，具体计算过程和理论参考[文章](http://read.pudn.com/downloads70/ebook/254107/ch4.pdf)，发现论文中的公式更简单： \\([a \star b]\_i = \sum\_{k=0}^{n-1}[a]\_k [b]\_{(k+i)~mod~n}\\) .
    -   _计算示例_

{{< figure src="https://gitee.com/layer3/pic/raw/master/uPic/20200423213305-screen-shoot.png" >}}

-   超平面(HyperPlanes)，指的是用来切分当前高维空间的切分平面，比如三维空间中的一个分割平面，二维空间中的一条分割线。n维空间中的n-1维的空间。


## 2. 介绍 {#2-dot-介绍}


### 2.1. 知识图谱 {#2-dot-1-dot-知识图谱}

知识图谱就是一个多关系图，由实体和关系组成，每个边都是一个三元组：(head, relation, tail)，这个三元组又被成为`fact`。


### 2.2. 知识图谱嵌入 {#2-dot-2-dot-知识图谱嵌入}

知识图谱（KG）Embedding 是将包含实体和关系的 KG 组件嵌入到连续的向量空间中，以便简化操作，同时保留 KG 的固有结构。


### 2.3. 知识图谱嵌入的通常做法 {#2-dot-3-dot-知识图谱嵌入的通常做法}

给定一个 KG，嵌入技术首先使用连续向量空间表示实体和关系，并为每个 fact 定义一个评分函数以衡量其合理性。通过最大化已有的 fact 的得分来获得实体和关系的 Embed。

> 但是上述过程学习到的 Embedding 只在针对单个 fact 具有**compatible**，因此不具有**可预测性**。

因此现在会考虑使用更多信息诸如：**实体类型、关系路径、文本描述、逻辑规则**来让 Embedding 更具有预测性。

**具体来说就是只使用 fact 的方法不具有可预测性，因此需要结合其他信息。**


## 3. 方法 {#3-dot-方法}


### 3.1. Trans系列 {#3-dot-1-dot-trans系列}

-   TransE在上篇博文以详细描述，它的score函数为 \\(f\_r(h,t) = -||h+r-t||\_{1/2}\\)
    -   但是TransE在处理1-N, N-1和 N-N时就会出现问题，比如当同一个实体的某一关系有多个对应时，尽管t的意义可能完全不同，但是TransE也会让他们尽量相似，比如我喜欢狗狗和冰淇淋就会把狗狗和冰淇淋表现的很相似。
-   为了避免这个问题，一种解决方法是允许实体在不同的关系下有不同的representation，
    1.  TransH使用**超平面**的方法，relation用r上的法向量为 \\(w\_r\\) 的超平面来表示。给定一个fact (h,r,t)，首先要把h和t投射到超平面上，
        -   \\(h\_{\perp} = h- w\_r^{\top}hw\_r\\) , \\(t\_{\perp} = t - w\_r^{\top}hw\_r\\)
        -   score函数为：\\(f\_r(h,t) = - ||h\_{\perp} + r - t\_{\perp}||\_2^2\\)
    2.  TransR与TransH类似，其为relation定义特定的空间（维度），即定义Entity为d维，但定义relation为k维，对于fact (h,r,t)，先使用投射矩阵 \\(M\_r\\) 把h和t投射到k维上:
        -   \\(h\_{\perp} = M\_rh\\), \\(h\_{\perp} = M\_rt\\)
        -   score函数与TransH相同。
        -   TransR的表达能力很强，但是TransR有个很严重的问题，因为投射矩阵的存在其需要的参数复杂度达到了O(dk)
    3.  TransD通过将投射矩阵分解为两个vector $w\_r, w\_t$，然后根据这两个向量获得投射矩阵 \\(M\_r^1, M\_r^2\\)
        -   \\(M\_r^1 = w\_rw\_h^{\top} + I, M\_r^2 = w\_rw\_t^{\top} + I\\)
        -   \\(h\_{\perp} = M\_r^1h, t\_{\perp} = M\_r^2t\\)
    4.  TranSparse通过稀疏投射矩阵来减少参数，使用 &theta; 表示稀疏程度，其有两个版本，分别是用同一个 \\(M\_r(\theta\_r)\\) 和用不同的 \\(M\_r^1(\theta\_r^1)h, M\_r^2(\theta\_r^2)\\)
        -   \\(h\_{\perp} = M\_r(\theta\_r)h\\) 或 $h<sub>&perp;</sub> = M\_r^1(&theta;\_r^1)h$，后面略
-   另一种解决思路是放宽TransE中 \\(h+r \approx t\\) 这个条件。
    1.  TransM给每个fact添加了一个权重&theta;，为1-N,N-1,N-N分配更小的权重，是的t可以在这些relation中离h+r更远。score函数为：
        -   \\(f\_r(h,t) = -\theta\_r ||h+r-t||\_{1/2}\\)
    2.  MoanifoldE放宽条件到 $||h+4-t||\_2^2 &asymp; &theta;\_r^2$，从而使得t可以在h+r附近的一个圆内，而不是一个点：
        -   \\(f\_r(h,t) = -(||h+r-t||\_2^2 - \theta\_r^2)^2\\)
    3.  TransF通过尽让t和h+r在一个方向，同时h和t-r在同一个方向来放松条件：
        -   \\(f\_r(h,t) = (h+r)^{\top}t + (t-r)^{\top}h\\)
    4.  TransA使用了马氏空间，相比较 TransE 模型，引入了 \\(W\_r\\) 矩阵为不同维度的向量进行加权，并利用 LDL 方法对 \\(W\_r\\) 进行分解:
        -   \\(f\_r(h,t) = -(|h+r-t|)^{\top} M\_r (|h+r-t|)\\)

[^fn:1]: 参考自<https://www.zhihu.com/question/38002635>
