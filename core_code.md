




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
            # 两侧距离相等但都不是无穷大（即两侧都有匹配) 的情况不会出现,这是由A在初始化时元素不可重复保证的
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
       ...




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

#检查CUDA可用性并设置设备
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

#检查genome类型并转换为torch张量
if isinstance(genome, torch.Tensor):
    genome_tensor = genome.to(device)
else:
    genome_tensor = torch.tensor(genome, dtype=torch.float32, device=device)



#根据给定的基因 批量计算所有B牌的所有可能插入位置的 特征
def compute_card_values_batch(A_copy, B, genome_tensor):
    card_values = []

    #特征计算

    A_set = set(A_copy)

    #使用嵌套循环进行插入模拟  每一个插入位置都会计算6个特征
    for i, card in enumerate(B):
        remaining_B = [B[j] for j in range(len(B)) if j != i]
        
    
        B_card_proportion  = card/sum(remaining_B)

        # 插入位置以及特征集合
        all_features = []
        all_positions = []

        for pos in range(len(A_copy) + 1):
            #特征计算
            score, removal_length, new_length, _, new_A = simulate_insertion_tool(A_copy, card, pos)
            future_score = calculate_future_score(new_A, remaining_B)

            sum_new_A=sum(new_A),  # 匹配后新A的元素总和
            features = [
                score,  # 当前得分
                removal_length,  # 移除长度
                new_length,  # 新长度
                future_score,  # 未来得分
                sum_new_A,  # 匹配后新A的元素总和
                B_card_proportion,  # B的出牌占B剩余牌的价值比例
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







def evaluate_genome(genome, num_rounds=1000, seed_base=111):
"""

用一批种子生成的A,B来评估基因是否够好 返回计算fitness的平均值  (类似于通过计算损失函数来评估ai模型)

这个函数在实际调用时使用了多进程加速

种子是为了使用相同的A,B进行评估 避免引入其他变量 seed_base是第一个种子  它会递增



"""

    import calculate_score_by_strategy

    # 检查并设置 GPU 可用性
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


    # 将基因组转换为 GPU 张量
    # genome_tensor = torch.tensor(genome, dtype=torch.float32, device=device)

    # GPU批处理大小
    batch_size = 1024

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

   

    return mean_score  # 返回平均得分






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
       

        """
        基于先验知识的种群初始化策略("温启动")


        这里使用了一个优化手段,回顾基因的features = [
            score,  # 当前策略的子集得分
            removal_length,  # 匹配的移除长度
            new_length,  # A由于插入操作得到的新长度
            future_score,  # 未来得分
            sum_new_A,  # 匹配后新A的元素总和
            B_card_proportion,  # B的出牌占B剩余牌的价值比例
        ]
        经过足够多的测试后 ，可以得出以下结论：
        score,future_score  且score和future_score权重一般>1.5,影响较大
        """
        
        if random.random() < 0.7:  # 70%的个体按原方式初始化
            for i in range(6):
                if i == 0 or i == 3 :
                    genome.append(random.uniform(1.5, 2.5))
               
                else:
                    genome.append(random.uniform(-0.5, 0.5))
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
       #如果改进率＞0则沿用方法 否则选择另一个方法  最初的进化方法使用的是岛屿模型 

        if len(best_fitness_history) > 1:
            improvement = best_fitness_history[-1] - best_fitness_history[-2]
            if improvement > 0:
                method = method_history[-1]
                
            else:
                method = method_history[-1]
                # 找到 现在方法 的索引
                index_of_method_now = evolution_methods.index(method)

                # 如果改进率 <= 0，使用另一个方法(这里针对只使用两种进化方法,如果需要使用多种进化方法,
                #可以在某一种进化方法进化率不佳时,改为基于概率来随机选择下一代的另一个进化方法)

                method = evolution_methods[1 - index_of_method_now]
                #method = np.random.choice(evolution_methods)
              
        else:
            method = evolution_methods[0]
      
            
        method_history.append(method)

        #使用标准遗传算法
        if method == 'standard':
            pass  

        # 将种群分成多个子群体，独立进化后进行迁移的岛屿模型进化算法
        elif method == 'island':
            next_population, _ = island_model_evolution(next_population, fitnesses, pop_size, tournament_size, 0.7, num_rounds, generation=gen, max_generations=generations)
      
        population = next_population  # 更新种群

    return best_genome  # 返回最佳基因组





    class PositionalEncoding(nn.Module):
    # 确保 max_len >= num_a + num_b (6 + 3 = 9)

"""
    __init__ 方法初始化了位置编码模块。

    d_model: 表示模型的维度（即嵌入向量的维度）。
    dropout: Dropout 的概率，默认为 0.1。Dropout 是一种正则化技术，用于防止过拟合。
    max_len: 最大序列长度，表示可以支持的最大位置数

"""

    def __init__(self, d_model, dropout=0.1, max_len=20):  # 增加 max_len 以确保安全
        super(PositionalEncoding, self).__init__()
        self.dropout = nn.Dropout(p=dropout)
        #张量初始化
        pe = torch.zeros(max_len, d_model)

        #创建一个包含位置索引的一维张量,并调整为形状是(max_len * 1)的二维张量
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1)
        
       

 """       
        PE(pos,2i)​=   sin(​pos/ 10000^(2i/d_model​) )
        PE(pos,2i+1)​= cos(​pos/ 10000^(2i/d_model​) )
        正弦位置编码（Sinusoidal Positional Encoding）在尽可能确保PE(pos)是唯一的同时,也实现了从 pos 到 pos+k 的变换是线性的(可以通过和变换矩阵做乘法完成)
"""
        div_term = torch.exp(torch.arange(0, d_model, 2).float() * (-math.log(10000.0) / d_model))
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        pe = pe.unsqueeze(0)

        #将计算好的位置编码 pe 注册为模型的缓冲区 作为模型的一部分 但不会被视为模型参数进行梯度更新和优化
        self.register_buffer('pe', pe)

#将输入的词嵌入向量与从缓冲区中取出的、长度匹配的位置编码向量相加，再返回dropout层的处理结果,而为模型注入关键的序列顺序信息 
    def forward(self, x):
        x = x + self.pe[:, :x.size(1)]
        return self.dropout(x)




class TransformerMovePredictor(nn.Module):
   

    def __init__(self, input_dim=6, d_model=128, nhead=8, num_encoder_layers=3,
                 dim_feedforward=512, dropout=0.1, num_a=6, num_b=3):  # 修改input_dim为6
        super(TransformerMovePredictor, self).__init__()
        

        self.num_a = num_a
        self.num_b = num_b

        # 序列长度计算(6+3=9)
        self.seq_len = num_a + num_b 
        self.d_model = d_model

        #输入嵌入层：将6维的A的维度通过线性变换层投影到128维
        self.input_embed = nn.Linear(input_dim, d_model)

        # 类型嵌入：区分A类型(0)和B类型(1)  0 for A, 1 for B
        self.type_embed = nn.Embedding(2, d_model) 

        # 调用位置编码
        self.pos_encoder = PositionalEncoding(d_model, dropout, max_len=self.seq_len + 5)
        
        #Transformer编码器
        encoder_layer = nn.TransformerEncoderLayer(d_model=d_model, nhead=nhead,
                                                   dim_feedforward=dim_feedforward, dropout=dropout,
                                                   batch_first=True)
        self.transformer_encoder = nn.TransformerEncoder(encoder_layer, num_layers=num_encoder_layers)

      #预测顺序和位置预测头
        self.order_head = nn.Linear(num_b * d_model, num_b * num_b)
        self.pos_head = nn.Linear(num_b * d_model, num_b)

        self.init_weights()

#均匀分布初始化权重
    def init_weights(self):
        initrange = 0.1
        self.input_embed.weight.data.uniform_(-initrange, initrange)
        self.input_embed.bias.data.zero_()
        self.type_embed.weight.data.uniform_(-initrange, initrange)
        self.order_head.weight.data.uniform_(-initrange, initrange)
        self.order_head.bias.data.zero_()
        self.pos_head.weight.data.uniform_(-initrange, initrange)
        self.pos_head.bias.data.zero_()

    def forward(self, src, src_mask=None, src_key_padding_mask=None):

    #期望输入至少是三维的
        if src.dim() == 2:
            src = src.unsqueeze(-1)  # (batch, seq_len, 1)

        input_embedded = self.input_embed(src) * math.sqrt(self.d_model)

        #类型嵌入
        type_ids = torch.cat([torch.zeros(self.num_a, dtype=torch.long),
                              torch.ones(self.num_b, dtype=torch.long)], dim=0).to(src.device)
        type_ids = type_ids.unsqueeze(0).expand(src.size(0), -1)  # (batch_size, seq_len)
        type_embedded = self.type_embed(type_ids)


        #合并嵌入与位置编码
        embedded = input_embedded + type_embedded
        embedded = self.pos_encoder(embedded)

        #调用编码器
        memory = self.transformer_encoder(embedded, mask=src_mask, src_key_padding_mask=src_key_padding_mask)
        # memory shape: (batch_size, seq_len=9, d_model)


 #特征提取与处理
        # 提取 B 对应的输出特征 (最后 num_b=3 个)
        # 使用 self.num_a (现在是6) 作为索引起点
        b_features = memory[:, self.num_a:]  # (batch_size, num_b=3, d_model)

#将提取出的 B 类特征 b_features 展平（flatten）
       
        b_features_flat = b_features.reshape(b_features.size(0), -1)  # (batch_size, num_b * d_model)

#self.order_head: 这是一个线性层，其输出维度是 num_b * num_b。它负责预测B中元素的操作顺序。
        order_logits_flat = self.order_head(b_features_flat)

        #将排序头的扁平化输出 order_logits_flat 重新塑形为一个矩阵
        order_logits = order_logits_flat.view(-1, self.num_b, self.num_b) 


#self.pos_head: 这是另一个独立的线性层，输出维度为 num_b。它负责为每个 B 元素预测要插入的A的哪个位置
        pos_preds = self.pos_head(b_features_flat)  

        return order_logits, pos_preds



def prepare_data_transformer(sample: dict, num_a=6, num_b=3):
    """
    数据预处理：构建输入序列和目标输出，添加修改后的特征工程。
    """


    A = sample["A"]
    B = sample["B"]
    best_moves = sample["best_moves"]

    if len(A) != num_a or len(B) != num_b:
        
        return None, None, None

    # 新增特征计算
    A_sum = sum(A)  # A序列的和


    # 计算B序列中重复的元素数
    B_counter = {}
    for val in B:
        B_counter[val] = B_counter.get(val, 0) + 1
    B_duplicates = sum(count - 1 for count in B_counter.values())  # 重复的元素数

    # 交集特征
    intersection = set(A) & set(B)
    intersection_size = len(intersection)

    # 位置特征
    positions_in_A = {}
    for i, a_val in enumerate(A):
        positions_in_A[a_val] = i

    # 创建增强的输入序列
    enhanced_sequence = []

    # 处理A序列
    for i, val in enumerate(A):
        is_in_intersection = 1.0 if val in intersection else 0.0
        relative_position = i / num_a
        relative_size = val / A_sum if A_sum != 0 else 0  # 使用与总和的比例代替相对大小
        intersection_ratio = intersection_size / num_b

        enhanced_sequence.append([
            val,  # 原始值
            val / A_sum if A_sum != 0 else 0,  # 值占A总和的比例
            is_in_intersection,  # 是否在交集中
            relative_position,  # 相对位置
            relative_size,  # 相对大小（占总和的比例）
            intersection_ratio  # 交集大小比例
        ])

    # 处理B序列
    for i, val in enumerate(B):
        is_in_A = 1.0 if val in A else 0.0
        position_in_A = positions_in_A.get(val, -1)
        relative_position_in_A = position_in_A / num_a if position_in_A >= 0 else -0.1
        # relative_size = val / B_sum if B_sum != 0 else 0  # 使用与总和的比例

        # 计算未来得分特征
        # 计算剩余B的未来得分
        remaining_B = B[i + 1:] if i < len(B) - 1 else []
        future_score = calculate_future_score(A, remaining_B)
        future_score_ratio = future_score / (sum(A) + sum(B)) if (sum(A) + sum(B)) > 0 else 0

        enhanced_sequence.append([
            val,  # 原始值
            # val / B_sum if B_sum != 0 else 0,  # 值占B总和的比例
            future_score_ratio,  #未来得分比例

            is_in_A,  # 是否在A中
            relative_position_in_A,  # 在A中的相对位置（如果存在）
            B_duplicates / num_b,  # B中重复元素的比例

            intersection_ratio  # 交集大小比例
        ])

    # 将序列转换为numpy数组
    input_sequence = np.array(enhanced_sequence, dtype=np.float32)

    order_target = np.array([move[0] for move in best_moves], dtype=np.int64)
    pos_target = np.array([move[1] for move in best_moves], dtype=np.float32)

    if len(set(order_target)) != num_b:
            return None, None, None


    result = (input_sequence, order_target, pos_target)


    return result


    def Transformer_predict(A, B, model, num_a=6, num_b=3):
    """
    使用训练好的 Transformer 模型进行预测 (针对 A=6, B=3)。
    
    参数说明:
    A: 长度为6的序列 - 目标序列，代表游戏中的目标位置或状态
    B: 长度为3的序列 - 待插入序列，代表需要放置的元素
    model: 训练好的TransformerMovePredictor模型实例
    num_a: A序列的预期长度，默认为6
    num_b: B序列的预期长度，默认为3
    
    返回值:
    tuple: (最佳策略列表, 预测得分)
    """
    try:
        # ==================== 特殊情况快速处理 ====================
        # 如果A和B没有交集，且B中没有重复元素，使用默认策略
        # Special case: if A and B have no intersection and B has no duplicates, use default strategy
        if not set(A) & set(B) and len(B) == len(set(B)):
           
            # 返回简单的顺序插入策略：[[索引0,位置0], [索引1,位置0], [索引2,位置0]]
            return [[0, 0], [1, 0], [2, 0]], 0

        # ==================== 模型类型验证 ====================
        # 确保传入的模型是正确的类型
        # Ensure the passed model is of correct type
        if not isinstance(model, TransformerMovePredictor):
            raise ValueError(f"需要 TransformerMovePredictor 实例, 但得到 {type(model)}")

        # 设置模型为评估模式，关闭dropout等训练时的随机性
        # Set model to evaluation mode, disable dropout and other training randomness
        model.eval()

        # ==================== 输入长度验证 ====================
        # 验证输入序列长度是否符合预期
        # Validate input sequence lengths
        if len(A) != num_a or len(B) != num_b:
            raise ValueError(f"DNNpredict 期望输入 A 长度为 {num_a}, B 长度为 {num_b}, 但收到 A:{len(A)}, B:{len(B)}")

        # ==================== 特征工程 - 基础统计特征 ====================
        # 1. 计算A序列的总和，用于后续的归一化
        # Calculate sum of sequence A for normalization
        A_sum = sum(A)
        # B_sum = sum(B)  # B序列总和暂时未使用

        # 2. 统计B序列中重复元素的数量
        # Count duplicate elements in sequence B
        B_counter = {}  # 用字典统计每个元素出现的次数
        for val in B:
            B_counter[val] = B_counter.get(val, 0) + 1
        # 计算重复元素总数：每个元素的重复次数-1之和
        # Calculate total duplicates: sum of (count-1) for each element
        B_duplicates = sum(count - 1 for count in B_counter.values())

        # 3. 计算A和B的交集特征
        # Calculate intersection features between A and B
        intersection = set(A) & set(B)  # 求交集
        intersection_size = len(intersection)  # 交集大小

        # 4. 建立A序列中每个值对应位置的映射
        # Create position mapping for values in sequence A
        positions_in_A = {}
        for i, a_val in enumerate(A):
            positions_in_A[a_val] = i  # 记录每个值在A中的位置索引

        # ==================== 特征工程 - 构建增强输入序列 ====================
        enhanced_sequence = []  # 用于存储增强后的特征序列

        # -------------------- 处理A序列的特征 --------------------
        # Process features for sequence A
        for i, val in enumerate(A):
            # 判断当前值是否在交集中
            # Check if current value is in intersection
            is_in_intersection = 1.0 if val in intersection else 0.0
            
            # 计算相对位置：当前位置/总长度
            # Calculate relative position: current_index / total_length
            relative_position = i / num_a
            
            # 计算相对大小：当前值/总和
            # Calculate relative size: current_value / total_sum
            relative_size = val / A_sum if A_sum != 0 else 0
            
            # 交集比例：交集大小/B序列长度
            # Intersection ratio: intersection_size / B_sequence_length
            intersection_ratio = intersection_size / num_b

            # 为A序列的每个元素构建6维特征向量
            # Build 6-dimensional feature vector for each element in A
            enhanced_sequence.append([
                val,                    # 特征1：原始值 (original value)
                val / A_sum if A_sum != 0 else 0,  # 特征2：值占A总和的比例 (value ratio in A)
                is_in_intersection,     # 特征3：是否在交集中 (whether in intersection)
                relative_position,      # 特征4：相对位置 (relative position)
                relative_size,          # 特征5：相对大小 (relative size)
                intersection_ratio      # 特征6：交集大小比例 (intersection ratio)
            ])

        # -------------------- 处理B序列的特征 --------------------
        # Process features for sequence B
        for i, val in enumerate(B):
            # 判断B中的值是否存在于A中
            # Check if value in B exists in A
            is_in_A = 1.0 if val in A else 0.0
            
            # 获取该值在A中的位置（如果存在）
            # Get position of this value in A (if exists)
            position_in_A = positions_in_A.get(val, -1)  # 不存在则返回-1
            
            # 计算在A中的相对位置
            # Calculate relative position in A
            relative_position_in_A = position_in_A / num_a if position_in_A >= 0 else -0.1
            
            # 计算未来得分特征：基于当前位置之后剩余的B序列
            # Calculate future score feature based on remaining B sequence
            remaining_B = B[i + 1:] if i < len(B) - 1 else []  # 获取当前位置后的剩余序列
            future_score = calculate_future_score(A, remaining_B)  # 计算未来可能得分
            
            # 归一化未来得分
            # Normalize future score
            future_score_ratio = future_score / (sum(A) + sum(B)) if (sum(A) + sum(B)) > 0 else 0
            
            # 为B序列的每个元素构建6维特征向量
            # Build 6-dimensional feature vector for each element in B
            enhanced_sequence.append([
                val,                        # 特征1：原始值 (original value)
                future_score_ratio,         # 特征2：未来得分比例 (future score ratio)
                is_in_A,                   # 特征3：是否在A中 (whether in A)
                relative_position_in_A,     # 特征4：在A中的相对位置 (relative position in A)
                B_duplicates / num_b,       # 特征5：B中重复元素的比例 (duplicate ratio in B)
                intersection_ratio          # 特征6：交集大小比例 (intersection ratio)
            ])

        # ==================== 模型推理 ====================
        # 将增强特征序列转换为numpy数组，然后转为PyTorch张量
        # Convert enhanced feature sequence to numpy array, then to PyTorch tensor
        input_sequence = np.array(enhanced_sequence, dtype=np.float32)
        input_tensor = torch.FloatTensor(input_sequence).unsqueeze(0).to(device)  # 添加batch维度并移至GPU

        # 使用torch.no_grad()关闭梯度计算，提高推理效率
        # Use torch.no_grad() to disable gradient computation for efficiency
        with torch.no_grad():
            # 模型前向传播，获取顺序逻辑值和位置预测
            # Forward pass: get order logits and position predictions
            order_logits, pos_preds = model(input_tensor)

        # ==================== 结果处理 ====================
        # 从顺序逻辑值中采样得到预测的插入顺序

        #sample_order为softmax采样
        pred_order_indices = sample_order(order_logits).squeeze(0).cpu().numpy()
        
        # 获取位置预测结果
       
        pred_moves_raw = pos_preds.squeeze(0).cpu().numpy()

        # 限制位置预测在有效范围内
  
        pos_range_base = len(A)  # 基础位置范围
        # 对每个位置预测进行裁剪：范围从0到(基础范围+当前步骤)
        # Clip each position prediction: range from 0 to (base_range + current_step)
        pred_moves_clipped = [int(np.clip(p, 0, pos_range_base + k)) for k, p in enumerate(pred_moves_raw)]

        # 组合最终的移动策略：[顺序索引, 插入位置]
        
        best_moves = [[int(pred_order_indices[k]), pred_moves_clipped[k]] for k in range(num_b)]

        # ==================== 策略验证和得分计算 ====================
        # 提取最终的插入顺序和位置
        # Extract final insertion order and positions
        final_order = [move[0] for move in best_moves]      # 插入顺序
        final_moves = [move[1] for move in best_moves]      # 插入位置

      
        result = (best_moves, pred_score)
        return result
        
    except Exception as e:
        # ==================== 异常处理(略) ====================
       ...

        # 构建默认策略：按顺序插入，每个都插入到位置1
       
        default_strategy = [[i, 1] for i in range(len(B))]
       
        # 计算默认策略的得分
               
      
        return default_strategy




def train_model(train_data, epochs, batch_size, model_path="transformer.pth",
                num_a=6, num_b=3, warmup_epochs, lr_max, lr_min,
                patience, min_delta=:
    """
    训练Transformer模型的主函数
    
    参数说明:
    - train_data: 训练数据集
    - epochs: 训练轮数，默认300轮
    - batch_size: 批次大小，默认64
    - model_path: 模型保存路径
    - num_a, num_b: 模型特定参数
    - warmup_epochs: 学习率预热轮数，默认10轮
    - lr_max: 最大学习率，默认0.0001
    - lr_min: 最小学习率，默认0.0000005
    - patience: 早停耐心值，默认10轮
    - min_delta: 早停的最小改善阈值，默认0.01
    """
    
    # ==================== GPU硬件信息检查 ====================
    ...

    # 全局停止训练标志
    global stop_training

    # ==================== Transformer模型超参数配置 ====================
    d_model = 256           # 模型维度 (model dimension)
    nhead = 4              # 多头注意力头数 (number of attention heads)
    num_encoder_layers = 3  # 编码器层数 (number of encoder layers)
    dim_feedforward = 512   # 前馈网络维度 (feedforward network dimension)
    dropout = 0.1          # Dropout比率，用于防止过拟合

    # ==================== 模型初始化 ====================
    # 创建TransformerMovePredictor模型实例
    # input_dim=6: 输入特征维度为6
    model = TransformerMovePredictor(input_dim=6, d_model=d_model, nhead=nhead,
                                     num_encoder_layers=num_encoder_layers,
                                     dim_feedforward=dim_feedforward, dropout=dropout,
                                     num_a=num_a, num_b=num_b).to(device)

    # ==================== 优化器和损失函数配置 ====================
    # 使用AdamW优化器，包含权重衰减正则化
    optimizer = optim.AdamW(model.parameters(), lr=lr_max, weight_decay=0.01)

    # 定义损失函数
    order_criterion = nn.CrossEntropyLoss().to(device)  # 用于分类任务的交叉熵损失
    pos_criterion = nn.MSELoss().to(device)             # 用于回归任务的均方误差损失

    # 设置模型为训练模式
    model.train()

    # ==================== 学习率调度器配置 ====================
    # 余弦退火学习率调度器 (Cosine Annealing)
    # T_max: 余弦退火的周期长度（总轮数减去预热轮数）
    # eta_min: 学习率的最小值
    scheduler_cosine = CosineAnnealingLR(optimizer, T_max=epochs - warmup_epochs, eta_min=lr_min)

    # ==================== 早停机制变量初始化 ====================
    best_loss = float('inf')  # 记录最佳损失值，初始化为无穷大
    patience_counter = 0      # 耐心计数器，记录连续无改善的轮数
    best_model_state = None   # 保存最佳模型的状态字典

    try:
        # ==================== 主训练循环 ====================
        for epoch in range(epochs):
            # 检查是否需要停止训练
            if stop_training:
                break

            # 初始化当前轮次的统计变量
            total_loss = 0.0  # 累计损失
            batch_count = 0   # 批次计数
            
            # 随机打乱训练数据，增加训练的随机性
            np.random.shuffle(train_data)

            # ==================== 批次训练循环 ====================
            for i in range(0, len(train_data), batch_size):
                # 检查是否需要停止训练
                if stop_training:
                    break

                # 获取当前批次的数据
                batch = train_data[i:i + batch_size]
                inputs, order_targets, pos_targets = [], [], []

                # ==================== 数据预处理 ====================
                # 遍历批次中的每个样本
                for sample in batch:
                    # 准备Transformer输入数据
                    input_seq, order_tgt, pos_tgt = prepare_data_transformer(sample, num_a=num_a, num_b=num_b)
                    if input_seq is None:
                        continue  # 跳过无效样本
                    inputs.append(input_seq)
                    order_targets.append(order_tgt)
                    pos_targets.append(pos_tgt)

                # 如果当前批次没有有效数据，跳过
                if not inputs:
                    continue

                # ==================== 数据转换为张量 ====================
                # 转换为PyTorch张量并移动到GPU
                inputs = torch.FloatTensor(np.array(inputs)).to(device)
                order_targets = torch.LongTensor(np.array(order_targets)).to(device)
                pos_targets = torch.FloatTensor(np.array(pos_targets)).to(device)

                # ==================== 学习率调度 ====================
                # 学习率预热阶段 (Warmup Phase)
                if epoch < warmup_epochs:
                    # 使用线性预热策略
                    new_lr = lr_warmup(epoch, lr_max, warmup_epochs)
                else:
                    # 预热结束后使用余弦退火调度
                    new_lr = scheduler_cosine.get_lr()[0]

                # 更新优化器中所有参数组的学习率
                for param_group in optimizer.param_groups:
                    param_group['lr'] = new_lr

                # ==================== 前向传播 ====================
                optimizer.zero_grad()  # 清零梯度
                order_logits, pos_preds = model(inputs)  # 模型前向传播

                # ==================== 损失计算 ====================
                # 计算分类任务损失（顺序预测）
                order_loss = order_criterion(order_logits, order_targets)
                # 计算回归任务损失（位置预测）
                pos_loss = pos_criterion(pos_preds, pos_targets)
                # 总损失为两个任务损失之和
                loss = order_loss + pos_loss

                # ==================== 反向传播和参数更新 ====================
                loss.backward()  # 反向传播计算梯度
                # 梯度裁剪，防止梯度爆炸
                torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                optimizer.step()  # 更新模型参数

                # 累计损失和批次计数
                total_loss += loss.item()
                batch_count += 1

                # ==================== 训练进度日志 ====================
                # 每10个批次打印一次训练状态
               ...

            # ==================== 轮次结束后的学习率更新 ====================
            # 如果已过预热阶段，执行余弦退火调度
            if epoch >= warmup_epochs:
                scheduler_cosine.step()

            # ==================== 轮次统计和日志 ====================
            # 计算当前轮次的平均损失
            avg_loss = total_loss / batch_count if batch_count > 0 else total_loss
       

            # ==================== 早停检查机制 ====================
            # 检查是否有显著改善（损失下降超过最小阈值）
            if avg_loss < best_loss - min_delta:
                # 发现新的最佳模型
                best_loss = avg_loss
                patience_counter = 0  # 重置耐心计数器
                # 深拷贝保存当前最佳模型状态
                best_model_state = model.state_dict().copy()
         
            else:
                # 没有显著改善
                patience_counter += 1
              
                # 检查是否触发早停条件
                if patience_counter >= patience:
                  
                    # 恢复到训练过程中的最佳模型状态
                    if best_model_state is not None:
                        model.load_state_dict(best_model_state)
                    break  # 结束训练循环

    # ==================== 异常处理 ====================
    except KeyboardInterrupt:
        # 捕获键盘中断（Ctrl+C）
        ...

    except Exception as e:
        # 捕获其他所有异常
        ...

    finally:
        # ==================== 模型保存 ====================
        # 无论训练如何结束，都确保模型被保存
        try:
            # 如果触发了早停并且有最佳模型状态，使用最佳模型
            if patience_counter >= patience and best_model_state is not None:
                model.load_state_dict(best_model_state)
             

            # 保存模型状态字典到指定路径
            torch.save(model.state_dict(), model_path)
         
            
        except Exception as save_error:
           ...

    # 返回训练完成的模型
    return model




def Compare_TwoModel(model, other_model, rounds=1000, plot=False):
    print("开始Compare_TwoModel测试...")  # 确保函数被调用

    test_scores_1 = []
    test_scores_2 = []
    true_score_list = []
    times_list1 = []
    times_list2 = []

    # 保存每一轮的得分
    all_scores_1 = []
    all_scores_2 = []
    all_true_scores = []

    for i in range(rounds):
        print(f"第 {i + 1} 轮测试")  # 观察是否卡在某一轮

        # 测试集生成不应该有限制

        A, B = deal_cards_tool()



        print(A)
        print(B)


        score_1, time_1,move_1 = TestModel_with_given_A_B(model, A, B)


        times_list1.append(time_1)


        score_2, time_2 ,move_2= TestModel_with_given_A_B(other_model, A, B)

        times_list2.append(time_2)

        true_score, true_move = recursive(A,B)
        print('-'*20)
        print(f" 真实值 ：{true_score}")
        print(f" 算法1得分 ：{score_1}")
        print(f" 算法2得分 ：{score_2}")
        print('-' * 20)
        # 检查差距过大的策略

        if(true_score-score_1>=10 ):
            print("算法1得分较低")
            print(A)
            print(B)
            print("算法1这样的移动造成了相对于真实值较低的得分")
            print(f" 算法1的预测移动和预测得分  ：{move_1},{score_1}")
            print(f" 但是真实最佳移动和真实值是：{true_move},{true_score}")


        if(true_score-score_2>=10):
            print("算法2得分较低")
            print(A)
            print(B)
            print("算法2这样的移动造成了相对于真实值较低的得分")
            print(f" 算法2的预测移动和预测得分  ：{move_2},{score_2}")
            print(f" 但是真实最佳移动和真实值是：{true_move},{true_score}")

            print('-'*20)

        test_scores_1.append(score_1)
        test_scores_2.append(score_2)
        true_score_list.append(true_score)

        # 保存本轮的得分数据
        all_scores_1.append(score_1)
        all_scores_2.append(score_2)
        all_true_scores.append(true_score)

    print("所有轮次计算完成，开始统计数据...")

    data_1 = np.array(test_scores_1)
    data_2 = np.array(test_scores_2)
    data_true = np.array(true_score_list)

    times_1 = np.array(times_list1)
    times_2 = np.array(times_list2)

    stats_1 = compute_statistics(data_1)
    stats_2 = compute_statistics(data_2)
    stats_true = compute_statistics(data_true)

    stats_times_1 = np.sum(times_1)
    stats_times_2 = np.sum(times_2)

    print("统计信息计算完成，准备输出...")

    print_statistics("算法1", stats_1)
    print_statistics("算法2", stats_2)
    print_statistics("真实值", stats_true)

    print(f"""【运行时间】
    算法1运行时间: {stats_times_1}
    算法2运行时间: {stats_times_2}
    """)

    # 计算均方误差（MSE）
    mse_1 = np.mean((data_1 - data_true) ** 2)
    print(f"【均方误差（MSE）】")
    print(f"算法1与真实值的均方误差: {mse_1}")

    mse_2 = np.mean((data_2 - data_true) ** 2)
    print(f"【均方误差（MSE）】")
    print(f"算法2与真实值的均方误差: {mse_2}")

    # 统计检验分析
    print("-" * 20)
    print("\n【算法1与真实值的偏差分析】\n")
    print("*所有偏差均按照真实值相应数据减去预测值相应数据的方式计算")
    compute_statistical_tests(data_1, data_true)
    print("-" * 20)
    print("\n【算法2与真实值的偏差分析】\n")
    print("*所有偏差均按照真实值相应数据减去预测值相应数据的方式计算")
    compute_statistical_tests(data_2, data_true)

    plot = True  # Set to True to generate plot

    if plot:
        # 创建一个1x2的图表布局
        fig, axs = plt.subplots(1, 2, figsize=(20, 8))

        # 设置全局字体大小
        plt.rcParams.update({'font.size': 12})

        # === 计算全局范围和区间 ===
        interval_width = 5

        # Calculate min/max based on ALL THREE datasets for Y-axis scaling
        overall_min_val = np.min([np.min(data_true), np.min(data_1), np.min(data_2)])
        overall_max_val = np.max([np.max(data_true), np.max(data_1), np.max(data_2)])

        # Define intervals based on this overall range, rounded to interval_width
        min_score = int(np.floor(overall_min_val / interval_width) * interval_width)
        max_score = int(np.ceil(overall_max_val / interval_width) * interval_width)

        # Ensure max_score is at least one interval above min_score
        if max_score <= min_score:
            max_score = min_score + interval_width

        # Recalculate intervals and centers based on the new min_score, max_score
        intervals = list(range(min_score, max_score + interval_width, interval_width))
        if len(intervals) < 2:
            print(f"Warning: Not enough data range ({overall_min_val:.2f} to {overall_max_val:.2f}) "
                  f"to create multiple intervals with width {interval_width}.")
            min_score_adj = int(np.floor(overall_min_val))
            max_score_adj = int(np.ceil(overall_max_val))
            if max_score_adj <= min_score_adj: max_score_adj = min_score_adj + 1
            intervals = [min_score_adj, max_score_adj]
            interval_width_adj = intervals[1] - intervals[0]  # Use adjusted width
            interval_centers = np.array([intervals[0]]) + interval_width_adj / 2.0
            interval_labels = [f"[{intervals[0]},{intervals[1]})"]

        else:
            interval_labels = [f"[{intervals[i]},{intervals[i + 1]})" for i in range(len(intervals) - 1)]
            interval_centers = np.array(intervals[:-1]) + (intervals[1] - intervals[0]) / 2.0

        # === 偏差计算 (基于 data_true 的值落入哪个区间) ===
        interval_errors_1 = [[] for _ in range(len(intervals) - 1)]
        interval_errors_2 = [[] for _ in range(len(intervals) - 1)]

        for i in range(len(data_true)):
            true_val = data_true[i]
            bin_index = -1
            for j in range(len(intervals) - 1):
                if intervals[j] <= true_val < intervals[j + 1]:
                    bin_index = j
                    break
            if bin_index == -1 and true_val == intervals[-1] and len(intervals) > 1:
                bin_index = len(intervals) - 2

            if bin_index != -1 and 0 <= bin_index < len(interval_errors_1):
                interval_errors_1[bin_index].append(data_1[i] - data_true[i])
                interval_errors_2[bin_index].append(data_2[i] - data_true[i])

        mean_errors_1 = [np.mean(errors) if errors else 0 for errors in interval_errors_1]
        mean_errors_2 = [np.mean(errors) if errors else 0 for errors in interval_errors_2]
        sample_counts = [len(errors) for errors in interval_errors_1]

        # === 绘图 ===

        # 1. 小提琴图 (Violin Plot - Left: axs[0])
        violin_parts = axs[0].violinplot([data_true, data_1, data_2], showmeans=True, showmedians=False)
        axs[0].set_title('Score Distribution Violin Plot', fontsize=14)
        axs[0].set_ylabel('Score', fontsize=12)
        axs[0].set_xticks([1, 2, 3])
        axs[0].set_xticklabels(['Ground Truth', 'Algorithm 1', 'Algorithm 2'])
        axs[0].tick_params(axis='both', labelsize=11)
        axs[0].grid(True, linestyle='--', alpha=0.6, axis='y')

        # 设置小提琴图的y轴范围和刻度 (using the overall min/max score)
        axs[0].set_ylim(min_score, max_score)
        axs[0].set_yticks(intervals)
        axs[0].set_yticklabels([f'{i}' for i in intervals])

        # 2. 偏差条形图 (Bias Plot - Right: axs[1]) - Horizontal Bar Chart
        current_interval_width = intervals[1] - intervals[0]  # Use actual width
        bar_total_thickness = current_interval_width * 0.7
        individual_bar_thickness = bar_total_thickness / 2

        # Plot bars
        axs[1].barh(interval_centers - individual_bar_thickness / 2, mean_errors_1,
                    height=individual_bar_thickness, label='Algorithm 1 Bias', color='tab:blue', alpha=0.8)
        axs[1].barh(interval_centers + individual_bar_thickness / 2, mean_errors_2,
                    height=individual_bar_thickness, label='Algorithm 2 Bias', color='tab:green', alpha=0.8)

        # --- Set up axs[1] y-axis to align with axs[0] ---
        axs[1].set_ylim(min_score, max_score)
        axs[1].set_yticks(intervals)
        axs[1].set_yticklabels([f'{i}' for i in intervals])

        axs[1].set_title('Mean Prediction Bias by True Score Interval', fontsize=14)
        axs[1].set_xlabel('Mean Bias (Predicted - True)', fontsize=12)
        axs[1].set_ylabel('True Score', fontsize=12)
        axs[1].tick_params(axis='both', labelsize=11)
        axs[1].axvline(x=0, color='red', linestyle='--', linewidth=1)
        axs[1].legend(fontsize=10)
        axs[1].grid(True, linestyle='--', alpha=0.6, axis='x')

        # --- 添加样本数量标签 (Adaptive Placement Logic) ---

        # 1. Draw canvas to get reliable initial limits
        fig.canvas.draw()

        # 2. Prepare storage and track needed x-range
        annotations_args = []
        min_x_needed = float('inf')
        max_x_needed = float('-inf')
        xmin_plot_initial, xmax_plot_initial = axs[1].get_xlim()  # Limits after bars are drawn

        # Include bar ends in initial range assessment
        all_bar_ends = [b for b in mean_errors_1 + mean_errors_2 if b is not None and not np.isnan(b)]
        min_bar_end = min(all_bar_ends) if all_bar_ends else xmin_plot_initial
        max_bar_end = max(all_bar_ends) if all_bar_ends else xmax_plot_initial
        min_x_needed = min(min_x_needed, min_bar_end)
        max_x_needed = max(max_x_needed, max_bar_end)

        # 3. Determine annotation positions adaptively
        for i, count in enumerate(sample_counts):
            if count > 0 and i < len(interval_centers):  # Ensure index valid for interval_centers
                bar1_end = mean_errors_1[i]
                bar2_end = mean_errors_2[i]
                abs_bias1 = abs(bar1_end)
                abs_bias2 = abs(bar2_end)
                target_bar_end = bar1_end if abs_bias1 >= abs_bias2 else bar2_end
                is_positive_bar = target_bar_end >= 0

                label_text = f'n={count}'
                plot_width = xmax_plot_initial - xmin_plot_initial
                if plot_width == 0: plot_width = 1
                offset = plot_width * 0.015  # Offset for outside placement
                inner_offset = plot_width * 0.01  # Offset for inside placement

                # Calculate ideal position (outside)
                ideal_x_pos = target_bar_end + offset if is_positive_bar else target_bar_end - offset
                ideal_ha = 'left' if is_positive_bar else 'right'

                # Determine final position
                final_x_pos = ideal_x_pos
                final_ha = ideal_ha
                text_color = 'dimgray'

                # Check boundaries and adjust if needed
                if is_positive_bar and ideal_x_pos > xmax_plot_initial:
                    final_x_pos = target_bar_end - inner_offset
                    final_ha = 'right'
                    text_color = 'white'
                elif not is_positive_bar and ideal_x_pos < xmin_plot_initial:
                    final_x_pos = target_bar_end + inner_offset
                    final_ha = 'left'
                    text_color = 'white'

                # Store args
                annotations_args.append({
                    'text': label_text,
                    'xy': (final_x_pos, interval_centers[i]),
                    'ha': final_ha, 'va': 'center',
                    'fontsize': 8, 'color': text_color,
                    'clip_on': True
                })
                # Update needed range
                min_x_needed = min(min_x_needed, final_x_pos)
                max_x_needed = max(max_x_needed, final_x_pos)

        # 4. Add all annotations
        for args in annotations_args:
            axs[1].annotate(**args)

        # 5. Adjust final X-axis limits with padding
        x_range_needed = max_x_needed - min_x_needed
        if x_range_needed <= 0: x_range_needed = abs(max_x_needed) * 0.1 + 1  # Handle zero/small range
        padding = x_range_needed * 0.05  # 5% padding

        final_xmin = min_x_needed - padding
        final_xmax = max_x_needed + padding
        axs[1].set_xlim(final_xmin, final_xmax)

        # --- 添加偏差图的说明文本 ---
        axs[1].text(0.98, -0.08, "n=sample size in true score interval", transform=axs[1].transAxes,
                    ha='right', va='top', fontsize=9, color='dimgray')

        # --- 添加整体图表标题 ---
        fig.suptitle('Algorithm Performance Comparison: Score Distribution & Prediction Bias', fontsize=16, y=0.99)

        # --- 添加共享的水平参考线 ---
        for boundary in intervals:
            # Use slightly different alpha/style for less visual clutter if desired
            axs[0].axhline(y=boundary, color='grey', linestyle=':', linewidth=0.8, alpha=0.6)
            axs[1].axhline(y=boundary, color='grey', linestyle=':', linewidth=0.8, alpha=0.6)

        # --- 调整布局并显示 ---
        plt.tight_layout(rect=[0, 0.03, 1, 0.96])  # Adjust rect for titles/labels
        plt.show()
  

def init_deck_tool():
    return [i for i in range(1, 14) for _ in range(4)]


def deal_cards_tool():
    deck = init_deck_tool()
    random.shuffle(deck)
    a_unique = set()
    A = []
    while len(A) < 6:
        card = deck.pop()
        if card not in a_unique:
            a_unique.add(card)
            A.append(card)

    available_A = [card for card in deck if card in a_unique]
    # 第一张牌必须是与A中某张牌数字相同的牌
    selected = random.choice(available_A)
    deck.remove(selected)  # 从剩余牌中移除选中的牌
    B = [selected]
    # 抽取剩余两张牌
    for _ in range(2):
        B.append(deck.pop())
    return A, B


def TestModel_with_given_A_B(other_model, A, B):
    # 计算 other_model 算法的运行时间
    start_time_other = time.time()
    move = other_model(A.copy(), B.copy())
    score=strategy_TrueScore(A, B, move)

    end_time_other = time.time()
    time_other = end_time_other - start_time_other  # 计算其他算法时间
    return score, time_other,move



    def strategy_TrueScore(A, B, strategy):
    try:
        # 第一步插入
        score1, _, _, _, A = simulate_insertion_tool(
            A,
            B[strategy[0][0]],
            min(len(A), strategy[0][1]))

        # print(f"1. 将 {B[strategy[0][0]]} 插入A<{strategy[0][1]}>号位  得分: {score1}    A变为{A}")

        # 第二步插入
        score2, _, _, _, A = simulate_insertion_tool(
            A,
            B[strategy[1][0]],
            min(len(A),strategy[1][1])
        )
        # print(f"2. 将 {B[strategy[1][0]]} 插入A<{strategy[1][1]}>号位  得分: {score2}    A变为{A}")

        # 第三步插入
        score3, _, _, _, A = simulate_insertion_tool(
            A,
            B[strategy[2][0]],
           min(len(A),strategy[2][1]))

        # print(f"3. 将 {B[strategy[2][0]]} 插入A<{strategy[2][1]}>号位  得分: {score3}    A变为{A}")

        return score1 + score2 + score3

    except IndexError as e:

        print("相关变量的值：")
        print(f"strategy: {strategy}")
        print(f"A: {A}")
        print(f"B: {B}")