# AI驱动的卡牌游戏---使用ai模型计算 序列插入匹配得分最大化问题

## 概述
这是一款我独立设计并实现的 Unity 引擎开发的自定义规则回合制PVE卡牌游戏，电脑的策略基于一个部署了训练好的ai模型的本地服务器。该游戏的框架基于 [Unity 社区的卡牌框架](https://assetstore.unity.com/packages/tools/game-toolkits/cardhouse-264045) 。

- 在最开始,我想设计一个有些创新的,并且规则简单,比较依赖运气但是也需要策略的卡牌游戏  所以我设计了这个游戏,将游戏规则抽象为算法问题,然后编程实现它   游戏规则与“连连看”或者"消消乐"类似，玩家需要通过配对卡牌来消除它们获得得分，但玩法上进行了创新。具体的游戏规则详见第一部分中的游戏规则,篇文章的重点会放在算法,AI模型和软件架构上


## 技术亮点
- **算法分析**：将游戏的最大得分问题抽象为算法问题,并进行了详细的分析 ,以此说明代理模型的重要性

- **AI驱动**：电脑的出牌策略由基于我编写和训练的 transformer 模型和 基于遗传算法的启发式方法 模型 数据的特征和启发方法均结合问题经过精心设计,训练的模型经过严谨的优化和测试,最后获得比较准确而且快速的预测模型。

- **比较复杂的游戏框架**：游戏的实现基于 Unity 引擎，使用c#语言开发,该游戏的基础框架是基于 Unity 社区的卡牌框架其中的 空当接龙 示例，经过大规模自定义和扩展。

- **广泛的技术栈**：除了以上提到的算法设计和分析,C#,python语言编程,软件架构设计,AI方面的机器学习/深度学习(Transformer架构),数据处理与特征工程,模型部署与优化外,还有涉及到服务器编程,网络编程(游戏通过 HTTP 协议与本地 Python 服务器进行实时通讯，进行策略计算) 以及少许前端(游戏ui),


## 文章结构

本文分为4个主要部分:


### 1.游戏规则以及算法分析
本部分将详细介绍游戏规则以及编程实现，包括：
- **游戏规则**：介绍游戏规则
- **编程实现**：介绍游戏逻辑的实现方式，包括卡牌的生成、匹配规则、得分计算的编程细节。
- **算法分析**：

### 2. AI 技术细节
本部分将详细介绍游戏中 AI 系统的工作原理,，包括：

- **AI模型的选择**：
-**模型编程实现以及优化**：python语言实现
- **模型训练**：

- **模型评测**：



### 3. 游戏架构
本部分将探讨游戏在 Unity 引擎中的开发与实现，重点将放在整个软件的架构上,并展开说明了一些我认为重要的技术实现,包括：
- **游戏框架**：

- **卡牌功能的实现**：描述如何将卡牌框架拓展,以达成自定义的卡牌游戏机制 C#语言实现

- **服务器和unity的交互**：描述游戏与本地 Python 服务器的通信流程，如何通过 HTTP 协议传递数据和接收策略建议。解释如何从封装好的python服务器获取策略,并阐述电脑如何自动将这些策略实施到游戏里

### 4.我认为的项目可能的改进方向和前景,以及结语
失败的缓存
假如它够快,使用gpu加速,可能代替传统的递归算法(基于cpu)吗 

在预测时使用cuda进行批量特征处理  比递归快的多

这个游戏设计可能有用  它足够简单,并且包含策略和运气,比如可以整合到大型游戏里作为小游戏

这个算法的代理模型可能有用,因为算法是针对这个游戏设计的,通用的算法处理方式可能效果并不好


# 第一部分 游戏规则以及算法分析

## 游戏规则以及玩法示例

**开局**

1.  系统创建一个包含52个数字的列表 $P$，每个数字从1到13，每个数字严格重复4次（共 $13 \times 4 = 52$ 个元素）。
2.  从列表 $P$ 中**随机抽取 6 个不同的元素**，得到列表 $A$。
    * **示例：** 假设我们得到 $A = \{1, 2, 3, 7, 4, 6\}$。
    * **(补充说明)** 这里的 $A$ 的元素个数固定是6。
3.  再从剩余列表 $P$ 中**随机抽取 3 个允许重复的元素**，得到列表 $B$。
    * **示例：** 假设我们得到 $B = \{4, 3, 9\}$。
    * **(补充说明)** 这里的 $B$ 的元素个数固定是3。

**可插入位置**

* 列表 $A$ 中的元素之间及其两端是允许插入的位置。
* 对于示例 $A = \{1, 2, 3, 7, 4, 6\}$，可插入位置用序号表示是：
    ① 1 ② 2 ③ 3 ④ 7 ⑤ 4 ⑥ 6 ⑦
* 总共有 $6 + 1 = 7$ 个位置。

**回合开始**

* 玩家允许在 $B$ 中选取一张牌插入 $A$ 中的一个可插入位置。
* 牌被选取并插入后，会从 $B$ 中移除，并添加到 $A$ 中。

**示例回合流程**

**第一次出牌**

1.  玩家选择将牌 `3` 从 $B$ 中取出，插入到 $A$ 中的位置 ① (即 $A[0]$ 之前的位置)。
2.  $A, B$ 被更新：
    * $A$ 变为 $\{3, 1, 2, 3, 7, 4, 6\}$
    * $B$ 变为 $\{4, 9\}$

**匹配规则**

* 观察新插入的牌 (`3`)。在更新后的 $A$ 中，查找数值上与新插入的牌相同的元素。
* **示例：** 新插入的牌是 `3`。在 $\{3, 1, 2, 3, 7, 4, 6\}$ 中，`A[3]` 的值也是 `3`，与新加入的 `3` 相匹配。
* **(补充说明)** 在 $A$ 中最多只会有一个元素与新加入的牌匹配，不会出现两个匹配。这是因为初始化时，$A$ 中的元素都是独一无二的。

**得分与移除 (第一次出牌)**

1.  找到匹配后，形成一个序列：从新插入的牌开始，到匹配到的元素结束（包含这两个元素）。
    * **示例：** 新插入的 `3` 在 $A[0]$，匹配到的 `3` 在 $A[3]$。序列是 $A[0]$ 到 $A[3]$，即 $\{3, 1, 2, 3\}$。
2.  这个匹配的序列将从 $A$ 中被移除。
3.  记录得分：得分为序列中所有元素的数值之和。
    * **示例：** 得分1 $= 3 + 1 + 2 + 3 = 10$。
4.  $A$ 会动态更新：
    * $A$ 移除 $\{3, 1, 2, 3\}$ 后，变为 $\{7, 4, 6\}$。
    * $B$ 没有改变，仍为 $\{4, 9\}$。
5.  可插入位置随之改变：对于 $A = \{7, 4, 6\}$，可插入位置变成 ① 7 ② 4 ③ 6 ④。

**第二次出牌**

1.  玩家选择将牌 `9` 从 $B$ 中取出，插入到 $A$ 中的位置 ④。
2.  $A, B$ 被更新：
    * $A$ 变为 $\{7, 4, 6, 9\}$。
    * $B$ 变为 $\{4\}$。
3.  检查匹配：新插入的牌是 `9`。在 $\{7, 4, 6, 9\}$ 中，没有其他元素数值为 `9`。
4.  没有匹配发生，所以得分2为 0。
5.  $A$ 和 $B$ 保持当前状态。
6.  可插入位置变成 ① 7 ② 4 ③ 6 ④ 9 ⑤。

**第三次出牌**

1.  玩家选择将最后一张牌 `4` 从 $B$ 中取出，插入到 $A$ 中的位置 ⑤。
2.  $A, B$ 被更新：
    * $A$ 变为 $\{7, 4, 6, 9, 4\}$。
    * $B$ 变为 `{}` (空)。
3.  检查匹配：新插入的牌是 `4`。在 $\{7, 4, 6, 9, 4\}$ 中，`A[1]` 的数值也是 `4`，与 `A[4]` 相匹配。
4.  匹配到的序列是 $A[1]$ 到 $A[4]$，即 $\{4, 6, 9, 4\}$。
5.  记录得分：得分3 $= 4 + 6 + 9 + 4 = 23$。
6.  $A$ 移除 $\{4, 6, 9, 4\}$ 后，变为 $\{7\}$。
7.  $B$ 已经是空列表 `{}`。

**回合结束**

* 所有玩家（在此示例中是玩家自己）已经出了3次牌，$B$ 中的所有元素都被插入到 $A$ 中。
* 回合结束。

**总得分**

* 总得分为该回合所有得分之和。
* **示例：** 总得分 $= \text{得分1} + \text{得分2} + \text{得分3} = 10 + 0 + 23 = 33$。



#### 算法分析


我们要计算的是给定A,B后的最佳策略

给定的A,B:  A是一个长度为6,元素间不可重复的整数列表, 范围是1~13  B是一个长度为3,元素间可重复的整数列表, 范围是1~13 

策略: 这里的这个一个 策略 指的是  B中的元素以什么样的顺序插入到A中的哪些位置(也就是说，策略包括两个部分：B 的插入顺序，以及插入到 A 中的位置。)。   

匹配：当你从列表 B 中选择一张牌，并将其插入到列表 A 的某个指定位置之后，立即检查：

① 新插入的这张牌的数值，是否与当前列表 A 中已经存在的某一张牌的数值完全相同。
② 如果存在这样一张数值相同的、原本就在 A 中的牌，那么就称之为发生了一次“匹配”。

匹配序列 与 移除： ：

发生匹配时，会确定一个“匹配序列”。这个序列包含
①新插入的那张牌。
②原本就在 A 中且数值相同的那张牌。
③位于这两张牌在列表 A 中位置之间的所有牌。 这个完整的序列将从列表 A 中被移除。

得分： 这次操作的得分，等于被移除的“匹配序列”中所有牌的数值之和。


没有发生匹配和得分为0： 如果新插入的牌的数值，在当前列表 A 中找不到任何一张数值相同的、原本就存在的牌，那么没有发生“匹配",此时列表 A 的匹配序列为空,不会移除任何元素，这次操作的得分为 0。


总得分: A,B使用此策略后会将B中的元素依次插入到A中  每次插入会产生一个 匹配 的判断 ,产生相应的得分,然后计算3次匹配对应的得分的和,也就是总得分

最佳策略: 指的是 能使得总得分最大的策略


首先我们解决能处理匹配过程并计分的函数 insertion (),  由于A会随着插入以及匹配而改变  所以在调用这个函数时,这里的输入的A的长度不再是初始化的6  而是0~8(因为当A是0~8时才有可能去调用insertion,A不可能小于0且A等于9时 B=[],B不能再选取元素插入),在插入之后,由于匹配,A的长度会变为0~9



def insertion(A, b, pos):

    """
    将元素b插入到列表A的指定位置pos，并处理可能发生的匹配情况。
    
    参数:
        A: list - 当前的牌列表(动态变化)
        b: int - 要插入的元素(来自B列表)
        pos: int - b要插入到A中的位置索引
        
    返回值:
        tuple - 包含5个元素:
            1. int: 本次操作产生的得分
            2. int: 被移除的匹配序列长度
            3. int: 操作后A的长度
            4. int: 是否产生匹配(1代表True，0代表False)
            5. list: 操作后的A列表
    """
    # 创建A的副本避免修改原始列表
    copy_A = A.copy()
     
    # 当A为空时,直接往A中插入b,这时候不产生匹配
    if len(copy_A) == 0:
        copy_A.append(b)

        return 0, 0, 1, 0, copy_A
    
    try:
        # 使用列表的insert函数插入b到A的pos位置
        copy_A.insert(pos, b)
        
        # 向左右分别寻找b是否与当前列表A中已经存在的数值相同
        
        left_idx, right_idx = None, None
        
        # 从插入位置pos的左侧向左遍历列表copy_A，寻找与插入值b相等的最近的元素的索引
        for i in range(pos - 1, -1, -1):
            if copy_A[i] == b:
                left_idx = i
                break
         
        # 从插入位置pos的右侧向右遍历列表copy_A，寻找与插入值b相等的最近的元素的索引
        for j in range(pos + 1, len(copy_A)):
            if copy_A[j] == b:
                right_idx = j
                break
        
        # 无论向左还是向右都找不到匹配
        if left_idx is None and right_idx is None:

            return 0, 0, len(copy_A), 0, copy_A
        
        # 计算插入位置pos与匹配元素的索引(left_idx, right_idx)之间的距离
        # 如果没有匹配的元素，则将距离设置为正无穷大
        left_distance = pos - left_idx if left_idx is not None else float('inf')
        right_distance = right_idx - pos if right_idx is not None else float('inf')
        
        # 确定匹配发生在哪一侧（左侧或右侧）获取匹配序列的起始和结束索引
        if left_distance < right_distance:
           
            start, end = left_idx, pos
        elif right_distance < left_distance:
            
            start, end = pos, right_idx
        else:
            # 两侧距离相等但都不是无穷大（即两侧都有匹配），这种情况不会出现,这是由A在初始化时元素不可重复保证的
            # 如果左右距离都是无穷大，说明没有匹配 根据 IEEE 754 浮点数标准，所有正无穷大 (float('inf')) 被视为相等
            return 0, 0, len(copy_A), 0, copy_A
        
        # 通过索引获取匹配序列
        removal_interval = copy_A[start:end + 1]
        # 计分
        score = sum(removal_interval)
        # 将A中的匹配序列进行移除
        new_A = copy_A[:start] + copy_A[end + 1:]
        

        return score, len(removal_interval), len(new_A), 1, new_A
    

    #异常处理 尤其是 IndexError 
    except Exception as e:
        print(f"当将 {b} 插入到当前A：{A}的位置 {pos} 时发生错误。")
        print(f"Error message: {str(e)}")
        raise



这个问题的关键问题之一在于如何设计数据结构来表示插入策略。

我使用的策略结构是一个形如 3×2 的二维矩阵（或列表），我们称它为 move。这个矩阵的每一行都代表一个插入操作，共两列：

    第一列表示元素在数组 B 中的索引；

    第二列表示将该元素插入到当前数组 A 中的哪个位置。

需要注意的是，这里的“插入位置”是相对于最新的 A 状态而言的，而不是初始的 A

举个例子：

B = [1, 2, 3]
move = [[1, 6], [0, 3], [2, 0]]

这个策略表示：

    第一步：将 B[1]（即元素 2）插入到当前 A 的索引位置 6；

    第二步：将 B[0]（即元素 1）插入到更新后的 A 的索引位置 3；

    第三步：将 B[2]（即元素 3）插入到再次更新后的 A 的索引位置 0。

每一步都在当前版本的 A 上进行操作，每次B[i]的插入都会导致A会由于插入本身和插入后的匹配而更新




所以可以设计递归算法:


def Recursive_StrategyAndScore(A, B, original_indices=None, move_sequence=None, used_indices=None):

"""
A: 目标列表，B 中的元素将被插入到这里。

B: 包含待插入元素的列表。

original_indices : 字典: 使用 B中的元素值做字典的键, 元素的值对应的索引做字典的值

move_sequence : 用于构建move序列的列表。每次移动记录为一个列表 [原始B中的索引, 在A中的插入位置]。它在递归过程中构建。

used_indices : 这是一个字典 ，用于跟踪 original_indices 中每个值的索引被使用了多少次。用来保证B中的元素的每个元素都使用过一次,且只使用过一次

"""
    if move_sequence is None:
        move_sequence = []

    if original_indices is None:

    # 初始化original_indices字典，默认值是 list
        original_indices = defaultdict(list)

        #将B中的元素值和对应的索引添加到 original_indices 中
        for idx, value in enumerate(B):
            original_indices[value].append(idx)
            
    if used_indices is None:
    # 初始化used_indices字典，默认值是 int
        used_indices = defaultdict(int) 

#递归的终止条件 
    if not B:
        return 0, move_sequence 

    max_score = 0
    best_moves = []

#开始逐个操作B中的元素
    for i, b in enumerate(B):
        # 拷贝used_indices
        current_used = copy(used_indices)


   #original_indices中[b]记录的是b在B中的的全部索引  len(original_indices[b])是b的重复次数
        if current_used[b] < len(original_indices[b]):
            index_b = original_indices[b][current_used[b]]
            current_used[b] += 1  # 递增当前元素的计数
#遍历A中的所有元素,返回被改变的A和得分
            for a in range(0, len(A) + 1):
                insertscore, _, _, _, AA = simulate_insertion_tool(A, b, a)
                
                #使用切片排除被考察过的B中的元素
                B_new = B[:i] + B[i+1:]

                # 递归调用，传递新的A,新的B,使用过的B中的元素
                score, moves = Recursive_StrategyAndScore(
                    AA, B_new, original_indices,
                    move_sequence ,
                    current_used  # 使用拷贝后的used_indices
                )

            #更新最高分和对应的移动序列
                new_score = score + insertscore
                if new_score > max_score:
                    max_score = new_score
                    # 确保返回正确的操作顺序,新的插入操作 (index_b, a) 是在 moves 的前面，而不是后面
                    best_moves =   [[index_b, a]]+moves

    return max_score, best_moves



首先进行一些数学估计:



时间复杂度分析:

对于 B 中的每一个元素，它尝试在当前的 A 的所有可能位置插入，然后递归处理剩余的元素。假设 |B| = n，|A| = m，那么在第一步有 n 种元素选择，每种元素有 m+1 个插入位置，总共有 n * (m+1) 种可能。第二步B有 n-1 个元素，插入位置变为 m+2 个，依此类推得到n!*(m+1)*(m+2)*...*(m+n)=n!⋅(m+n)!/m!。所以得到大致的复杂度是 O(n!⋅(m+n)!/m!) 量级，非常高。(但由于每次插入后A的长度的改变并不确定, 可能没有匹配导致的长度加一  也可能产生了匹配,移除了2~len(A)个元素   所以这个估计并不是精确的)






结合具体的输入数据分析穷举的数据量:

计算穷举当A,B没有给定且不发生任何匹配消除时,所有的将B插入A后的所有可能性(注意这里仅仅是"最终静态组合数")

如果仅考虑将B(长度为3的数组)中的牌插入A(长度为6的数组)里,不考虑A,B上有点数,求解有多少中插入的可能,那么这可以看作是一个多重集排列问题:从{A,A, A,A, A,A, B,B,B}构成的集合中不放回的拿出元素,全部放到一个一维数组里,能构成多少种长度为9的不同的数组?   
所以是C(9,6)*C(3,3)=C(9,6)


*注: 我在思考这个问题时发现了这个树结构 我觉得值得记录 即使它和问题并不强相关

一棵所有叶子节点都在同一深度k的树。树根保存值0 其他的每个节点保存一个小于等于n的正整数 沿着任意一条树根到叶子的路径上的节点数字都是递增的 问这棵树有多少个叶子节点 结果其实就是C(n k)  (ps:而且因为这个树的根有n-k+1个子节点,还可以使用这个树的结构推导出曲棍球棒恒等式)

可以用它很好的表达组合问题

但由于如果直接对应到原问题  树高是动态变化的(由于匹配)  而这个结构的树高是固定的 所以不适合直接带入此树  因为这棵树直观的连接了组合问题与数据结构,或许它的变体能够用于直观的处理原问题 但是由于篇幅限制,这里不做过多讨论




然后由于现在的数组的牌只有A,B的区别,位置已经定下来,但是 还没有点数 现在给他们加上点数


每个A的值是1~13,且不能重复 所以给A加上点数的所有可能方式:P(13,6)  
每个B的值也是1~13,但是可以重复 给B加上点数的所有可能方式:13^3  


所以这是所有的可能插入得到的最终可能  C(9,3)*P(13,6)*13^3=228,012,744,960 

 假设每个样本占10B  数据超过2000GB  这是一个非常大的数据量   (这是一个估计,就如前面所说,每次插入可能导致A数组变动,从而导致之后的决策发生改变,而且不同顺序的插入是不一样的  

匹配会导致B的插入顺序是需要考虑的 
比如 b1插入1号位,b2 插入2号位,这样的顺序反过来 ,b2 插入2号位,b1插入1号位,由于匹配规则,会产生不同的结果 所以是两种情况 

这里只考虑了不发生匹配的情况,这也同时导致了有些插入可能是不合法的  而且匹配会同时导致A的长度改变, 我们无法直接判断匹配带来的是更多还是更少的情况)



为了估计真实的匹配造成的影响,这里使用了基于概率的统计数据分析(蒙特卡洛模拟) 来研究一个特例 :  对于当len(A)=6  len(B)=3 时 

随机生成A,B  len(A)=6  len(B)=3   随机不放回的抽取B中的一张牌,随机插入到A中,重复2次调用simulate_insertion_tool直到B中没有元素,第二次调用是基于上一次改变后的A,B, 

{
        A, B = get_A_and_B_random()

        card = random.choice(B)

        pos=random.randint(0,6)
        
        _, _, new_length1, _, newA = simulate_insertion_tool(A, card, pos)

        all_lengths1.append(new_length1)

第一次改变后的A的长度期望 expected_value = sum(all_lengths1) /total_times

        B.remove(card)
        card = random.choice(B)
        pos = random.randint(0, len(newA))

        _, _, new_length2, _, newA = simulate_insertion_tool(newA, card, pos)

        all_lengths2.append(new_length2)

第二次改变后的A的长度期望 expected_value = sum(all_lengths2) / total_times

}


获取函数的第三个返回值 以上过程重复20M次(total_times=20M) 进行统计, 编写代码运行 以下是我的结果:


总共执行了 20M 次 simulate_insertion_tool 调用。

 len(A1) 分布情况:
   len(A1)( 0: 559058  次, 占比: 2.80%
   len(A1)( 1: 1112357 次, 占比: 5.56%
   len(A1)( 2: 1669068 次, 占比: 8.35%
   len(A1)( 3: 2216588 次, 占比: 11.08%
   len(A1)( 4: 2775405 次, 占比: 13.88%
   len(A1)( 5: 3333920 次, 占比: 16.67%
   len(A1)( 7: 8333604 次, 占比: 41.67%

len(A1) 的期望值: 4.8603≈5

 len(A2)分布情况:
   len(A2) 0: 689171  次, 占比: 3.45%
   len(A2) 1: 1746955 次, 占比: 8.73%
   len(A2) 2: 2511990 次, 占比: 12.56%
   len(A2) 3: 3001901 次, 占比: 15.01%
   len(A2) 4: 3202618 次, 占比: 16.01%
   len(A2) 5: 3129061 次, 占比: 15.65%
   len(A2) 6: 3434722 次, 占比: 17.17%
   len(A2) 8: 2283582 次, 占比: 11.42%

 len(A2) 的期望值: 4.1555≈4

simulate_insertion_tool在每个循环中只调用两次是因为第一次插入可能固定为len(A)+1=7   并且不用考虑第三次插入后的A的变化,因为此时len(B)等于0,在这之后算法已经停止了

第一次插入有 len(A)+1 个位置，第二次插入有 E[len(A1)]+1 个位置，第三次插入则应基于第二次插入后A的期望长度 E[len(A2)]+1 个位置

基于这些期望 得到估计 决策路径数量为   ( (len(A)+1) * (E[len(A1)]+1) * (E[len(A2)]+1)  ) *P(13,6)*13^3 

(7×6×5)/ C(9,3)=2.5  这个结果变成不考虑匹配规则的2.5倍  需要再次强调的是  这里估计的而非A与B的“最终静态组合数”,而是决策的数量   因为这个模拟估计的并不仅仅是单纯的卡牌组合的数据量,而且考虑了匹配规则,也就是考虑了B的插入顺序,因此产生了更大的数据规模 


时间复杂度的通过这个思想也能得到更精确的估计,但由于改变的是数据的规模  所以依然是阶乘的时间复杂度



这导致了可能的决策空间非常大,所以在编程时很难使用缓存技术来加速,因为缓存难以命中


优化尝试:

动态规划:

A 的状态在每次插入后都会改变，并且列表内容本身复杂，而且导致了难以找到重叠子问题,难以作为 DP 状态的键进行存储和查找, A 的动态的状态是问题所在。因此，动态规划 在这个问题的通用形式下很难实现。



剪枝/启发式方法:

基于对于simulate_insertion_tool的匹配规则的理解,的确可以做出启发式方法优化,来跳过一些递归分支, 我使用future_score 这个特征来实现   具体内容在遗传算法的实现中展开


代理模型（surrogate modeling）:
在这个过程中，这个Recursive_StrategyAndScore算法生成结果数据，然后将这些数据用作训练集来训练AI模型。训练完成后，AI模型学习到了原始算法的行为模式，可以在允许一定的误差的情况下预测该算法在新输入上的输出结果，而无需实际运行原始算法。 这就是本文着重要讨论的内容





# 第二部分  AI 技术细节

python版本 3.12.9

使用Anaconda配置了cuda环境

CPU: AMD Ryzen 9 5900HS(8 processing cores, 16 threads)
GPU: NVIDIA GeForce RTX 3050 laptop  (Vram: 4G)




我选择了transformer和遗传算法作为ai模型 

使用遗传算法的原因其一是这个决策序列空间是巨大的，并且每一步的决策都依赖于上一步的结果。遗传算法是擅长在复杂、高维、非连续或目标函数难以微分的搜索空间中寻找最优解。  其二是它相对容易实现,而且它的计算成本低,可以快速得到结果。

选择使用transformer也同样是决策会相互影响的原因,这个问题的3次出牌策略中,每一次出牌都会产生动态的A,所以导致影响了之后的出牌策略,Transformer 使用自注意力机制（self-attention），能够捕捉序列中任意两个元素之间的关系(比如第一次插入是怎么影响第二次和第三次策略的)。这对于取得最佳得分的出牌策略非常重要 

我使用遗传算法来优化transformer模型



### 1.训练集的获取以及预处理
我测试了多种大小的数据集,最终决定用大约10k条数据集训练遗传算法,并使用大约5M条数据训练transformer模型,因为对于遗传算法而言,数据集并没有全部参与训练 ,遗传算法只会从数据集抽样进行遗传和评估,所以这里的数据集只需要够均匀即可,对于transformer而言,数据集的大小的确能提升模型性能,但是考虑到训练的时长和硬件限制,经过测试,我觉得5M条数据集应该足够了,再大的数据集难以操作而且对模型的提升并不明显

数据集生成代码:



def generate_training_data(num_samples=10000):
    dataset = []

    for i in range(num_samples):


#deal_cards_tool()是在外部定义的函数  随机初始化了A,B ,并确保了A,B有交集 这里将A,B没有交集(怎么出牌都无法得分的情况)视为噪声排除,不需要参与训练

        A, B = deal_cards_tool()  # 初始A, B   A, B 都是 list<int>

#递归生成最优的策略和得分
        max_score, best_moves = recursive_StrategyAndScore(A, B)
       
#这里由于策略move=[[i,a],[j,b],[k,c]]的格式,且i,j,k是严格属于[0,1,2]且互不重复的,因为B中的索引只有0,1,2,如果违反这个约束,策略将没有意义
        whole = [0, 1, 2]
        current_rows = set(move[0] for move in best_moves)

        remaining = [i for i in whole if i not in current_rows]

        for i in remaining:
            if len(best_moves) < 3:
                best_moves.append([i, 0])


        dataset.append({"A": A, "B": B, "max_score": max_score, "best_moves": best_moves})

#保存至json文件
   ...


generate_training_data(num_samples=10000)


这里有额外需要注意的一点 

bestmoves的长度未必都是3  因为当B中就算再出牌也不能得分时(比如将B中的3张牌出了两张后,剩下的一张与A无法产生匹配) recursive_StrategyAndScore不会将移动加入到策略中,检查输出的best_moves的长度后,发现这样的情况大概占比num_samples的10%


所以现在有一个需要抉择的地方  对于这些长度不是严格为3的best_move 是应该跳过它们,还是填充它们到3? 跳过的话会丢失重要的内在关系吗?如果填充会反而引入噪声吗?  这需要结合训练出的模型的预测结果来判断究竟哪个好  我经过测试得出,填充更优,  这一部分的细节放在ai模型的评测中再详细讨论


由于A,B是使用deal_cards_tool随机生成的,需要对数据集去重,可以使用python的set完成,接着需要详细检查数据的格式,异常处理 等 代码详见dedpu.py

最后得出给遗传算法使用的数据集data_GA.json  样本数为10k 这是一个样本示例:
{
        "A": [
            10,
            3,
            4,
            2,
            12,
            9
        ],
        "B": [
            3,
            8,
            4
        ],
        "max_score": 55,
        "best_moves": [
            [
                0,
                0
            ],
            [
                1,
                1
            ],
            [
                2,
                5
            ]
        ]
    }


给transformer使用的数据集data_TR.json的处理也是一样的,只是由于数据过大,使用了多进程加速获取数据集,以及后续将json格式转换jsonl以支持流式加载 (详见 Get_trainingset_huge.py)   样本数为4989523




### 2.遗传算法的实现



# 遗传算法框架概述


## 基因的组成
6维权重向量，对应6个游戏特征：当前得分、移除长度、新长度、未来得分、A元素总和、交集数量。

## 适应度评估
- `evaluate_genome()`: 用个体权重执行多轮游戏，返回平均得分
- `GA_Strategy()`: 基于权重计算最优插牌策略，使用特征向量与权重的点积评估每个可能位置

## 种群初始化
- 种群规模500个个体
- 70%按启发式范围初始化，30%完全随机
- 引入多样性防止早期收敛

## 选择与繁殖
- 精英保留：10%最优个体直接传承
- 锦标赛选择：竞争性选择父代
- 交叉：父代权重加权平均
- 变异：添加高斯噪声，变异率自适应调整

## 高级进化策略
- `island_model_evolution()`: 岛屿模型，将种群分割为独立岛屿，定期迁移优秀个体
- `differential_evolution()`: 差分进化备选方案
- 动态方法切换：根据改进效果选择进化策略

## 优化机制
- GPU加速：PyTorch张量运算
- 并行评估：多进程处理不同个体
- 批量处理：减少GPU调用开销
- 早停机制：连续无改善时提前终止

## 训练配置
- 种群大小：500
- 进化代数：20  
- 评估轮数：200轮/个体
- 总计算量：200万局游戏

## 输出结果
最优个体的6个权重参数，构成AI的决策策略模型。








特征设计  根据卡牌的记分方法来决定需要使用的特征


                features = [
                    score,  # 当前策略的子集得分
                    removal_length,  # 匹配的移除长度
                    new_length,  # A由于插入操作得到的新长度
                    future_score,  # 未来得分
                    sum_A,  # A的元素总和
                    intersection_count,  # B与A的交集数量
                ]


遗传算法的genome 是一个包含6个浮点数的列表。这6个数字代表了评估游戏决策时所用到的6个特征的权重





这里有新意的是future_score
由于B中的牌数量较少(0~3) 所以可以根据这个特点进行启发式算法,  这里的future_score意思是  由于每次要从B中选一张插入A,而且每次的选取,插入都可能造成A的变化,然后导致后续的选取,插入步骤的最优得分策略变化  future_score指每次选取插入这个操作之后,剩余牌可能的得分  这是一个很重要的特征  它动态的评估了未来的卡牌状态  就好像国际象棋玩家会考虑某一步对以后的棋子策略带来的影响一样


其他的特征选取于simulate_insertion_tool的返回值  match_found和removal_length有重合,考虑到模型复杂度,它没有被作为特征


这个计算future_score的启发式函数的思路是这样的,从B中的牌抽取一张插入A时,同时考虑在这次选取插入操作实现之后:

1 当如果 A 和 B 没有任何重复元素,那么future_score是0

2 如果没有剩余的B玩家的牌,那么future_score是0

3 如果B中只剩下一张牌,检查这张牌和A是否有交集 如果有  则调用get_best_insertion_score计算得分作为future_score,如果没有那么future_score是0




def calculate_future_score(A, remaining_B):
  
    future_score = 0  # 初始化未来得分
    if len(remaining_B) == 0:
        return future_score  # 如果没有剩余的B玩家的牌，返回0
    if not set(A) & set(remaining_B):  # 如果 A 和 B 没有任何重复元素
        return future_score
    # 复制A玩家的牌以便模拟
    simulated_B = remaining_B.copy()

    if len(simulated_B) == 1:
        card_of_B = simulated_B[0]  # 获取最后一张B玩家的牌
        matched = card_of_B  in A  # 判断是否能匹配
        if not matched:
            return future_score  # 如果不能匹配，返回0
        else:
            _, score = get_best_insertion_score(A, card_of_B)
            return score





遗传算法核心函数  

使用了 传统的遗传算法 和岛屿模型算法 这两种进化策略 根据历史表现自适应选择进化方法




岛屿模型(Multi-Population Genetic Algorithm)  

def island_model_evolution(population, fitnesses, pop_size, tournament_size, mutation_strength,
                           num_rounds, islands=4, migration_rate=0.1,
                           generation=0, max_generations=60):
    """
    实现岛屿模型进化，将总人口分成几个独立'岛屿'，定期交换个体

    参数：
    - population: 当前种群
    - fitnesses: 当前种群的适应度值
    - pop_size: 总人口规模
    - tournament_size: 锦标赛选择规模
    - mutation_strength: 变异强度
    - islands: 岛屿数量

    - migration_rate: 每次迁移的个体比例
    - generation: 当前代数
    - max_generations: 最大代数

    返回：
    - new_population: 进化后的新种群
    - new_fitnesses: 新种群的适应度
    """


    #计算运行进度
    # progress_ratio需要＞0
    progress_ratio = generation / max_generations   if max_generations > 0 else 0.5
    # 动态增加迁移率
    adaptive_migration_rate = migration_rate * (1.0 + progress_ratio)  # 迁移率逐渐增加到原来的2倍

    # 计算每个岛屿的容纳的种群数量和迁移数量
    island_size = pop_size // islands # 向下取整
    #迁移数量 向0取整
    migration_size = int(island_size * adaptive_migration_rate)

    # 将总种群分割成岛屿
    island_populations = []
    island_fitnesses = []

    # 将总种群按岛屿进行分割
    # island_populations 在整个算法中仅作为输入数据源 初始化后不做修改
    for i in range(islands):
        # 计算第i个岛屿在总种群中的起始,结束索引
        start_idx = i * island_size
        # 将剩下的人口放入最后一个岛
        end_idx = start_idx + island_size if i < islands - 1 else pop_size
        island_populations.append(population[start_idx:end_idx])
        island_fitnesses.append(fitnesses[start_idx:end_idx])

    # 每个岛屿独立进化
    #二维列表 每个岛屿进化后产生的新子种群
    new_island_populations = []

    # 二维列表 在某个岛上的某个个体的适应度 [岛索引][个体索引]
    new_island_fitnesses = []


    # 岛内进化
    for i in range(islands):

        # 选择精英

        # 按照该岛的子种群在island_fitnesses[i]列表中对应的适应度值从（降序）排列
        sorted_indices = sorted(range(len(island_fitnesses[i])),
                              key=lambda k: island_fitnesses[i][k], reverse=True)
#前10%作为精英
        elitism_count = int(0.1 * len(island_populations[i]))
#从降序排列的子种群切片生成精英列表
        elites = [island_populations[i][idx] for idx in sorted_indices[:elitism_count]]

        # 锦标赛选择  从排除精英的种群中选取父代  这一定程度上缓解了足够优秀的个体在精英选择中被遗漏的情况
        selected = []
        for _ in range(len(island_populations[i]) - elitism_count):
            #在非精英中随机选择tournament_size个 个体
            candidates = random.sample(range(len(island_populations[i])), tournament_size)
            #选出具有最大的适应度的个体,它胜出了
            winner_idx = max(candidates, key=lambda idx: island_fitnesses[i][idx])
            #加入筛选出的种群,作为父代
            selected.append(island_populations[i][winner_idx])


        #精英个体被直接复制到下一代
        next_population = elites.copy()

        while len(next_population) < len(island_populations[i]):
            # 随机两个作为父代
            parent1, parent2 = random.sample(selected, 2)
            # 交叉
            #     以 70% 的概率，取 (p1 + p2) / 2（即两个父代的平均值）
            #     以 30% 的概率，直接取 p1。
            #     将上述逻辑应用于每一对 (p1, p2)，并生成一个新的列表 child
            child = [(p1 + p2) / 2 if random.random() < 0.7 else p1
                    for p1, p2 in zip(parent1, parent2)]

            # 变异
            # mutation_strength = 0.7
            # 对子代的每个基因，都加上高斯分布中采样的随机数。这会引入小的随机扰动。(变异)
            child = [gene + random.gauss(0, mutation_strength) for gene in child]
            next_population.append(child)

        new_island_populations.append(next_population)

    # 评估新岛屿种群适应度
    new_island_fitnesses = [evaluate_genomes_return_fitness(pop, num_rounds)
                            for pop in new_island_populations]

    # 迁移过程 (每代都迁移)

    for i in range(islands):
        # 按适应度降序排列当前岛屿中的个体。
        sorted_indices = sorted(range(len(new_island_fitnesses[i])),
                              key=lambda k: new_island_fitnesses[i][k], reverse=True)
        # 选择适应度最高的 'migration_size' 个 个体
        migrants_indices = sorted_indices[:migration_size]
        migrants = [new_island_populations[i][idx] for idx in migrants_indices]

        # 用模运算实现环形拓扑,将个体迁移到下一个岛屿
        target_island = (i + 1) % islands

        # 在目标岛屿中，替换最差的个体
        # 适应度升序排序
        target_sorted_indices = sorted(range(len(new_island_fitnesses[target_island])),
                                     key=lambda k: new_island_fitnesses[target_island][k])
        #  # 遍历从源岛屿选出的优秀迁移个体 'migrants' 列表。
        for j, migrant in enumerate(migrants):
            if j < len(target_sorted_indices):
                replace_idx = target_sorted_indices[j]
                # 替换掉目标岛屿中的较差个体
                new_island_populations[target_island][replace_idx] = migrant

    # 重新评估迁移后的适应度
    new_island_fitnesses = [evaluate_genomes_return_fitness(pop, num_rounds)
                            for pop in new_island_populations]

    # 合并所有岛屿种群
    new_population = []
    new_fitnesses = []
    # 配对迭代
    for pop, fit in zip(new_island_populations, new_island_fitnesses):
        # 将当前岛屿所有个体添加到 'new_population' 总列表中。
        new_population.extend(pop)
        new_fitnesses.extend(fit)

    # 如果合并后的种群大小超过了原始种群大小，截断到原始大小
    if len(new_population) > pop_size:
        combined = list(zip(new_population, new_fitnesses))
        sorted_combined = sorted(combined, key=lambda x: x[1], reverse=True)
        new_population = [x[0] for x in sorted_combined[:pop_size]]
        new_fitnesses = [x[1] for x in sorted_combined[:pop_size]]

    return new_population, new_fitnesses


#遗传算法训练主函数

def genetic_algorithm(pop_size, generations, num_rounds, elitism_ratio, tournament_size,
                      evolution_methods,
                      early_stop_generations, early_stop_threshold):
    """
    参数：
    - pop_size: 种群大小
    - generations: 最大进化代数
    - num_rounds: 评估每个基因组的回合数
    - elitism_ratio: 精英比例
    - tournament_size: 锦标赛选择规模

    - evolution_methods: 可用的进化方法列表
    - method_probs: 各进化方法的使用概率
    - early_stop_generations: 早停的连续代数
    - early_stop_threshold: 早停的改善阈值

    返回：
    - best_genome: 最佳基因组
    """
    
    population = []
    for _ in range(pop_size):
        genome = []
        # 引入更多随机性  
        """
        基于先验知识的种群初始化策略


        这里使用了一个优化手段,回顾基因的features = [
            score,  # 当前策略的子集得分
            removal_length,  # 匹配的移除长度
            new_length,  # A由于插入操作得到的新长度
            future_score,  # 未来得分
            sum_A,  # A的元素总和
            intersection_count,  # B与A的交集数量
        ]
        经过足够多的测试后 ，可以得出以下结论：
        score,future_score,sum_A与结果正相关  且score和future_score对于策略一般大于1.5,影响较大  其余特征均负相关
        """
        
        if random.random() < 0.7:  # 70%的个体按原方式初始化
            for i in range(6):
                if i == 0 or i == 3 :
                    genome.append(random.uniform(1.5, 2.5))
                elif i == 4 :
                    genome.append(random.uniform(0, 1))
                else:
                    genome.append(random.uniform(-1, 0))
        else:  # 30%的个体完全随机初始化
            for i in range(6):
                # 用[-2,2]随机浮点数
                genome.append(random.uniform(-2, 2))
        population.append(genome)

    best_fitness_history, avg_fitness_history = [], []  # 初始化历史最佳适应度和平均适应度列表
    best_genome, best_fitness = None, -float('inf')  # 初始化最佳基因组和最佳适应度
    elitism_count = int(elitism_ratio * pop_size)  # 计算精英数量
    method_history = []  # 记录每代使用的进化方法

    # 早停相关变量
    early_stop_counter = 0
    last_best_fitness = -float('inf')

    for gen in range(generations):  # 迭代每个世代
        fitnesses = evaluate_genomes_return_fitness(population, num_rounds)  # 评估种群适应度
        gen_best, gen_avg = max(fitnesses), np.mean(fitnesses)  # 获取当前世代的最佳适应度和平均适应度
        best_fitness_history.append(gen_best)  # 记录最佳适应度
        avg_fitness_history.append(gen_avg)  # 记录平均适应度

        # 早停检查
        improvement = gen_best - last_best_fitness

        # 修复除法错误 确保 last_best_fitness 不是无效值
        if last_best_fitness != -float('inf') and abs(last_best_fitness) > 1e-10:
            relative_improvement = improvement / abs(last_best_fitness)
        else:
            # 第一代或last_best_fitness接近0或无穷时，使用绝对改善判断
            relative_improvement = 1.0 if improvement > early_stop_threshold else 0.0

        if relative_improvement <= early_stop_threshold:
            early_stop_counter += 1

            #早停触发
            if early_stop_counter >= early_stop_generations:
                
                break
        else:
            early_stop_counter = 0  # 重置计数器

        last_best_fitness = gen_best

        if gen_best > best_fitness:  # 更新最佳基因组和适应度
            best_fitness, best_genome = gen_best, population[fitnesses.index(gen_best)]

      
        sorted_population = [x for _, x in
                             sorted(zip(fitnesses, population), key=lambda pair: pair[0], reverse=True)]  # 按适应度排序种群
        elites = sorted_population[:elitism_count]  # 选择精英

        selected = [population[max(random.sample(range(pop_size), tournament_size), key=lambda i: fitnesses[i])] 
        
        for _ in range(pop_size - elitism_count)]  # 通过锦标赛选择剩余的基因组

        next_population = elites.copy()  # 初始化下一代种群
        while len(next_population) < pop_size:  # 生成下一代
            parent1, parent2 = random.sample(selected, 2)  # 选择两个父本
            child = [(p1 + p2) / 2 if random.random() < 0.7 else p1 for p1, p2 in zip(parent1, parent2)]  # 交叉产生子代
            mutation_rate = max(0.1, 0.3 - (gen / generations) * 0.2)  # 计算变异率
            if early_stop_counter > 0:
                mutation_rate += 0.1 * early_stop_counter  # 每停滞一代增加10%的变异率
            mutation_rate = min(mutation_rate, 0.8)  # 但变异率不超过80%
            child = [gene + random.gauss(0, 0.5) if random.random() < mutation_rate else gene for gene in child]  # 变异
            next_population.append(child)  # 添加子代到下一代种群

        # 自适应进化方法选择 
       
        #根据历史表现选择进化方法
        if len(best_fitness_history) > 1:
         
            improvement = best_fitness_history[-1] - best_fitness_history[-2]
           
            # 如果有改进，继续使用上一代的方法 
            if improvement > 0:
                method = method_history[-1]
               
             # 如果无改进，随机选择下一个方法    
            else:
                method = np.random.choice(evolution_methods)
               
        else:
        #无历史改进数据(第一代随机方法选择)，随机选择
            method = np.random.choice(evolution_methods)
            
        method_history.append(method)

        #使用标准遗传算法
        if method == 'standard':
            pass  

        # 将种群分成多个子群体，独立进化后进行迁移的岛屿模型进化算法
        elif method == 'island':
            next_population, _ = island_model_evolution(next_population, fitnesses, pop_size, tournament_size, 0.7, num_rounds, generation=gen, max_generations=generations)
      
        population = next_population  # 更新种群

    return best_genome  # 返回最佳基因组






#根据A,B和给定的基因生成策略 (给调用遗传算法提供接口)

def GA_Strategy(genome, A, B):
    """
    计算每一个插入位置的特征张量,并与它和基因张量做点积计算 得到这个位置的"评估值",并按照评估值从大到小排序

    参数：
    - genome: 基因组权重 (NumPy数组或PyTorch张量)
    - A: A玩家的牌
    - B: B玩家的牌

    返回：
    - strategy: 最佳策略
    """

    # 检查CUDA可用性并设置设备
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # 检查genome类型并转换为torch张量
    if isinstance(genome, torch.Tensor):
        genome_tensor = genome.to(device)
    else:
        genome_tensor = torch.tensor(genome, dtype=torch.float32, device=device)



    # 根据给定的基因 批量计算所有B牌的所有可能插入位置的 特征
    def compute_card_values_batch(A_copy, B, genome_tensor):
        card_values = []

        #特征计算
        sum_A = sum(A_copy)
        A_set = set(A_copy)

        #使用嵌套循环进行插入模拟  每一个插入位置都会计算6个特征
        for i, card in enumerate(B):
            remaining_B = [B[j] for j in range(len(B)) if j != i]
            remaining_B_set = set([card] + remaining_B)
            #特征计算
            intersection_count = len(remaining_B_set & A_set)

            # 插入位置以及特征集合
            all_features = []
            all_positions = []

            for pos in range(len(A_copy) + 1):
                #特征计算
                score, removal_length, new_length, _, new_A = simulate_insertion_tool(A_copy, card, pos)
                future_score = calculate_future_score(new_A, remaining_B)

                features = [
                    score,  # 当前得分
                    removal_length,  # 移除长度
                    new_length,  # 新长度
                    future_score,  # 未来得分
                    sum_A,  # A的元素总和
                    intersection_count,  # B与A的交集数量
                ]

                all_features.append(features)

                all_positions.append(pos)
                # all_scores.append(score)
                # all_new_As.append(new_A)

            # 将所有特征转换为张量并一次性在GPU上计算
            if all_features:
                features_tensor = torch.tensor(all_features, dtype=torch.float32, device=device)


                # 特征张量和目前的基因张量计算点积。对于每一个可能的插入位置，
                # 其对应的特征向量会与genome_tensor 进行点积运算 也就是给每个特征加权：
                # 评估值 = (feature1 * genome_tensor的第一个元素) + (feature2 * genome_tensor的第二个元素) + ... + (feature6 * genome_tensor的第六个元素)
                values = torch.matmul(features_tensor, genome_tensor)

                # 用于返回输入张量中最大元素的索引
                best_idx = torch.argmax(values).item()
                #该索引对应的值(最大的评估值)
                best_value = values[best_idx].item()
                #最大评估值的对应插入位置(最优插入)
                best_pos = all_positions[best_idx]


                card_values.append((i, best_value, best_pos))

        return card_values

    # 计算卡值
    card_values = compute_card_values_batch(A.copy(), B, genome_tensor)

    # 根据评估值对卡进行排序 x[1] 就是 best_value ，即每张牌的最佳评估值
    card_values.sort(key=lambda x: x[1], reverse=True)

    # 根据排序后的顺序生成策略   注意这一步  因为它是依据评估值进行排序的,所以是贪心算法
    strategy = [(card_idx, pos) for card_idx, _, pos in card_values]

    return strategy




#用一批种子生成的A,B来评估基因是否够好 返回计算fitness的平均值  (类似于通过计算损失函数来评估ai模型)

#这个函数在实际调用时使用了多进程加速

#种子是为了使用相同的A,B进行评估 避免引入其他变量 seed_base是第一个种子  它会递增
def evaluate_genome(genome, num_rounds=1000, seed_base=111):


    import calculate_score_by_strategy

    # 检查并设置 GPU 可用性
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


    # 将基因组转换为 GPU 张量
    # genome_tensor = torch.tensor(genome, dtype=torch.float32, device=device)

    # GPU批处理大小
    batch_size = 128

    # 预分配结果数组
    #torch.zeros 创建一个所有元素都初始化为 0 的张量(这里是一维张量,也就是向量)  长度是num_rounds,数据类型是float32,张量将被分配在计算设备 device 上
    total_scores = torch.zeros(num_rounds, dtype=torch.float32, device=device)

    # 分批处理评估任务 步长为 batch_size
    for batch_start in range(0, num_rounds, batch_size):

#计算实际的batch_size
        batch_end = min(batch_start + batch_size, num_rounds)
        batch_size_actual = batch_end - batch_start


        # 为当前批次生成所有A和B
        batch_A = []
        batch_B = []
        for _ in range(batch_size_actual):

        #使用种子生成A和B,填充进batch 注意每个基因受过num_rounds次评估 这一批种子会随着批次的索引增加  每个基因对应的用于评估的种子集合都是相同的
            A, B = deal_cards(seed=seed_base + batch_start + _)
            batch_A.append(A)
            batch_B.append(B)

        # 并行评估批次使用GPU
        batch_scores = torch.zeros(batch_size_actual, dtype=torch.float32, device=device)

        for j in range(batch_size_actual):

#GA_Strategy 当前基因转换为对应的策略
            strategy = GA_Strategy(genome, batch_A[j], batch_B[j])

            #计算策略对应的得分
            batch_scores[j] = calculate_score_by_strategy(batch_A[j], batch_B[j], strategy)

        # 复制批次得分到总得分
        total_scores[batch_start:batch_end] = batch_scores

    # 计算最终平均分(平均)
    mean_score = torch.mean(total_scores).item()

    print(f"基因组平均得分: {mean_score}")

    return mean_score  # 返回平均得分










遗传算法的实际参数 经过测试,此模型收敛的比较快,这些参数已经能足够好的结果了:

    pop_size=400
    generations=20
    num_rounds=200
    elitism_ratio=0.1
    tournament_size=3
    evolution_methods=['standard', 'island']

    early_stop_generations=3
    early_stop_threshold=0.01

    genome = genetic_algorithm(pop_size,generations, num_rounds, elitism_ratio, tournament_size, evolution_methods, early_stop_generations, early_stop_threshold)  



 




   这是一个训练后得到的基因 
    Genome model :  [1.5939234785836462, -0.5025118249479125, -0.5296184457165617, 1.4105017073059225, 0.7851904853961442, -0.3300074485121268]

基因组特征权重:
当前得分: 1.5939
移除长度: -0.5025
新长度: -0.5296
未来得分: 1.4105
A元素总和: 0.7852
B与A交集数量: -0.3300
### 特征1: 当前得分 (1.5939)
这个权重非常高且为正值，表明算法非常重视当前移动能够直接带来的得分

### 特征2: 移除长度 (-0.5025)
这个权重为负值，表明算法倾向于避免移除过多的元素。这可能是因为保留更多元素可以为未来的移动提供更多可能性。

### 特征3: 新长度 (-0.5296)
同样为负值，表明算法倾向于保持序列较短。这可能是因为较短的序列更容易管理，也更容易在未来找到匹配。

### 特征4: 未来得分 (1.4105)
这个权重也很高且为正值，仅次于当前得分。这表明算法非常重视移动对未来可能得分的影响，具有很强的前瞻性。

### 特征5: A的元素总和 (0.7852)
中等正值，表明算法认为保持A中元素总和较高是有利的。这可能是因为更高的总和提供了更多的组合可能性。

### 特征6: B与A的交集数量 (-0.3300)
小负值，表明算法略微倾向于避免B与A有太多交集。这可能是为了保持多样性，避免重复元素。



各进化方法性能分析:
standard方法: 平均适应度=48.65, 最大适应度=48.69, 改进率=0.17%, 使用次数=2
island方法: 平均适应度=48.65, 最大适应度=48.65, 改进率=0.00%, 使用次数=1

Genome model :  [2.0195332597953675, -0.25463285223957144, -0.2931028178243443, 1.7412285628631057, 0.5661556620443767, -0.31580113743065963]
Best genome saved to trained/best_genome.pkl

基因组特征权重:
当前得分: 2.0195
移除长度: -0.2546
新长度: -0.2931
未来得分: 1.7412
A元素总和: 0.5662
B与A交集数量: -0.3158



各进化方法性能分析:
standard方法: 平均适应度=48.70, 最大适应度=48.70, 改进率=0.00%, 使用次数=2
island方法: 平均适应度=48.70, 最大适应度=48.70, 改进率=0.00%, 使用次数=1

Genome model :  [2.3743590686956035, -0.48376345338990934, -0.6264156095823054, 2.0077230845881813, 0.7371065038346376, -0.17165442336290104]
Best genome saved to trained/best_genome.pkl

基因组特征权重:
当前得分: 2.3744
移除长度: -0.4838
新长度: -0.6264
未来得分: 2.0077
A元素总和: 0.7371
B与A交集数量: -0.1717
