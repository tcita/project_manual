<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({ tex2jax: {inlineMath: [['\[', '\]']]}, messageStyle: "none" });
</script>

# What Happens When You Turn a Card Game into an NP-Complete Problem? (A Personal Exploration )


## Overview

From an engineering perspective, I designed and implemented a turn-based PvE card game using the Unity engine. The game features simple rules yet requires both luck and strategic decision-making. The computer opponent’s strategy is powered by a locally deployed server running a trained ensemble AI model.

Theoretically, I abstracted the game mechanics into a subsequence selection and score maximization problem governed by specific rules. Through in-depth analysis, I discovered that the actual decision space grows combinatorially with the number of moves, leading to an explosive increase in complexity. To understand its computational complexity, I examined a generalized version of this card game. Suspecting the abstracted problem might be NP-Hard, I formally reduced it to the Subset Sum problem, thereby proving that the problem is not only NP-Hard but also NP-Complete. Consequently, exact solutions become computationally infeasible even for moderately sized instances.

To address this challenge, I explored a general-purpose solution approach based on a lightweight surrogate model that integrates a Transformer architecture with a genetic algorithm. The core idea is to leverage an exact exhaustive-search algorithm to generate high-quality training samples within a computationally tractable problem scale, then train a computationally inexpensive AI model to mimic the optimal decision-making behavior observed in those samples.

This document is not a formal academic paper, nor does it claim to present rigorously validated academic contributions. Rather, it functions as a high-fidelity project report or a personal portfolio piece—demonstrating both theoretical understanding and engineering capabilities within a carefully designed sandbox environment. The work achieves a meaningful depth of exploration and incorporates several innovative elements, aiming to showcase my proficiency and readiness in applying advanced computational techniques to complex real-world-inspired problems.

## Project Highlights

- **Abstraction and Implementation of Problem Modeling**

- **Rigorous Algorithmic Analysis**

- **Proof of NP-Completeness for a Custom-Designed Problem, with Supporting Discussion**  
  > *Note: The core proof appears in the main text; extended discussion is provided in the appendix.*

- **Comprehensive AI Model Evaluation Framework**

- **Design, Implementation, and Analysis of a Surrogate Model, including Discussions on Generalization and Robustness**

- **Batch Processing and Multithreading Optimizations for the Ensemble Model**

- **Custom Development and Extension of a Relatively Complex Game Framework**

- **End-to-End System Design and Implementation**

- **Discussion of a Tree-Based Representation Well-Suited for Expressing Combinatorial Problems (Appendix)**
> Note: The actual code implementation is available at  https://github.com/tcita/python_server.git

## Document Structure

This document is divided into four main sections:

### 1. Game Rules and Algorithmic Analysis  
This section provides a detailed description of the game rules and their programmatic implementation, including:  
- **Game Rules**  
- **Algorithmic Analysis**  
- **Proof of NP-Completeness**  
- **Discussion on Algorithmic Optimizations and the Proposal of an AI Surrogate Model**

### 2. AI Technical Details  
This section delves into the inner workings of the AI system used in the game and its core implementation, covering:  
- **AI Model Implementation**  
- **Model Training**  
- **Ablation Studies on Data Preprocessing**  
- **Model Evaluation**  
- **Ensemble Model Evaluation and Optimization**  
- **Discussion on Modeling Paradigm Conflicts and Inductive Biases in the Transformer Architecture**

### 3. Server Deployment and Game Architecture  
This section presents the Unity client architecture and live gameplay demonstration, including:  
- **AI Model Server Setup**  
- **Client-Side Game Architecture**  
- **Live Gameplay Demonstration**

### 4. Appendix, Author’s Self-Reflection (Q&A), and Other Supplementary Materials


## Part I: Game Rules and Algorithmic Analysis

### Game Rules and Gameplay Example

The game rules are somewhat similar to "Tile Matching" (card game). Players score points by pairing cards to eliminate them. When it's the computer's turn, the current game state is captured, and the dynamic card layout data is sent to a local AI server. The AI returns its predicted optimal move, which is then automatically executed and displayed to the user on the client side. After three rounds, the player with the higher total score wins.

**Initial Setup**

1. The system creates a list **P** containing 52 numbers, where each integer from 1 to 13 appears exactly four times (13 × 4 = 52 elements in total).
2. **Six distinct elements** are randomly drawn from list **P** to form list **A**.
    * **Example:** Suppose we obtain **A = {1, 2, 3, 7, 4, 6}**.
    * **(Note)** In this specific study, the number of elements in **A** is fixed at 6.
3. Then, **three elements (allowing duplicates)** are randomly drawn from the remaining elements of **P** to form list **B**.
    * **Example:** Suppose we obtain **B = {4, 3, 9}**.
    * **(Note)** In this specific study, the number of elements in **B** is fixed at 3.

**Insertion Positions**

* Valid insertion positions include all gaps between elements of **A** as well as both ends.
* For the example **A = {1, 2, 3, 7, 4, 6}**, the insertion positions (numbered) are:
    ① 1 ② 2 ③ 3 ④ 7 ⑤ 4 ⑥ 6 ⑦
* There are a total of 6 + 1 = 7 possible insertion positions.

**Start of a Turn**

* On their turn, a player selects one card from **B** and inserts it into one of the valid insertion positions in **A**.
* Once selected and inserted, the card is removed from **B** and added to **A**.

**Example Turn Sequence**

**First Move**

1. The player chooses to take the card `3` from **B** and insert it into position ① of **A** (i.e., before **A[0]**).
2. **A** and **B** are updated:
    * **A** becomes **{3, 1, 2, 3, 7, 4, 6}**
    * **B** becomes **{4, 9}**

**Matching Rule**

* After insertion, examine the newly inserted card (`3`). Search **A** for any other element with the same numerical value.
* **Example:** The newly inserted card is `3`. In **{3, 1, 2, 3, 7, 4, 6}**, **A[3]** also equals `3`, forming a match with the newly inserted `3`.
* **(Note)** At most one matching element exists in **A** for any newly inserted card. This is guaranteed because **A** initially contains only unique values.

**Scoring and Removal (First Move)**

1. Upon finding a match, define a sequence starting from the newly inserted card up to (and including) the matched element.
    * **Example:** The new `3` is at **A[0]**, and the matched `3` is at **A[3]**. The sequence is **A[0]** through **A[3]**: **{3, 1, 2, 3}**.
2. This matched sequence is removed from **A**.
3. Score is calculated as the sum of all values in the sequence.
    * **Example:** Score₁ = 3 + 1 + 2 + 3 = 10.
4. **A** is dynamically updated:
    * After removing **{3, 1, 2, 3}**, **A** becomes **{7, 4, 6}**.
    * **B** remains unchanged as **{4, 9}**.
5. Insertion positions are updated accordingly: for **A = {7, 4, 6}**, valid positions become ① 7 ② 4 ③ 6 ④.

**Second Move**

1. The player chooses to take the card `9` from **B** and insert it into position ④ of **A**.
2. **A** and **B** are updated:
    * **A** becomes **{7, 4, 6, 9}**.
    * **B** becomes **{4}**.
3. Check for matches: the newly inserted card is `9`. In **{7, 4, 6, 9}**, no other element equals `9`.
4. No match occurs, so Score₂ = 0.
5. **A** and **B** remain in their current states.
6. Insertion positions become ① 7 ② 4 ③ 6 ④ 9 ⑤.

**Third Move**

1. The player takes the last remaining card `4` from **B** and inserts it into position ⑤ of **A**.
2. **A** and **B** are updated:
    * **A** becomes **{7, 4, 6, 9, 4}**.
    * **B** becomes **{}** (empty).
3. Check for matches: the newly inserted card is `4`. In **{7, 4, 6, 9, 4}**, **A[1]** also equals `4`, matching the newly inserted **A[4]**.
4. The matched sequence is from **A[1]** to **A[4]**: **{4, 6, 9, 4}**.
5. Score is recorded: Score₃ = 4 + 6 + 9 + 4 = 23.
6. After removing **{4, 6, 9, 4}**, **A** becomes **{7}**.
7. **B** is already empty (**{}**).

**End of Turn**

* All players (in this example, just the human player) have played three cards, and all elements from **B** have been inserted into **A**.
* The turn ends.

**Total Score**

* The total score is the sum of all scores obtained during the turn.
* **Example:** Total Score = Score₁ + Score₂ + Score₃ = 10 + 0 + 23 = 33.


### Exhaustive Recursive Algorithm Analysis

To compute the optimal strategy for a given pair of lists **A** and **B**, we first clarify the following key concepts:

***Given A and B***:  
- **A** is an integer list of length *m*, with all elements distinct, each in the range 1 to *K*.  
- **B** is an integer list of length *n*, with elements allowed to repeat, each also in the range 1 to *K*.

***Strategy***:  
In this context, a *strategy* specifies **both**:  
1. The **order** in which elements from **B** are inserted, and  
2. The **insertion positions** in **A** where each selected element is placed.  

Thus, a complete strategy fully determines the sequence of moves: for each element taken from **B**, we decide *when* (in which turn) to play it and *where* (at which valid position) to insert it into the current **A**.

***Matching***:  
Immediately after selecting a card from **B** and inserting it into a specific position in **A**, we perform the following check:  
① Whether the value of the newly inserted card matches the value of **any pre-existing card** already present in **A**.  
② If such a matching card exists in **A**, we say a **"match"** has occurred.

***Match Sequence*** and ***Removal***:  
When a match occurs, a **"match sequence"** is identified. This sequence includes:  
① The newly inserted card,  
② The pre-existing card in **A** with the same value, and  
③ All cards located **between** these two cards in the current list **A**.  

This entire contiguous subsequence is then **removed** from **A**.

***Score***:  
The score for this move equals the **sum of all values** in the removed match sequence.

***No Match and Zero Score***:  
If the value of the newly inserted card does **not** appear anywhere else in the current **A**, then **no match** occurs. In this case, the match sequence is empty, nothing is removed from **A**, and the score for this move is **0**.

***Total Score***:  
Applying a given strategy means sequentially inserting all elements of **B** into **A** according to the specified order and positions. Each insertion triggers a match check, yields a score (possibly zero), and potentially modifies **A**. The **total score** is the sum of the scores from all *n* insertions (in our specific problem, *n* = 3).

***Best Strategy***:  
The **best strategy** is the one that **maximizes the total score** over all possible strategies.

First, we perform a generalized mathematical analysis of the problem:

---

### Time Complexity Analysis

For each element in **B**, the algorithm attempts to insert it into every possible position in the current **A**, then recursively processes the remaining elements. Suppose \(|B| = n\) and \(|A| = m\). In the first step, there are \(n\) choices for which element to insert, and for each such choice, there are \(m+1\) possible insertion positions. Thus, there are \(n \cdot (m+1)\) possible paths at the first level.

After inserting an element at an arbitrary position, let \(p\) denote the probability that a match occurs.

---

### Expected Length of the Removed Subsequence Upon a Match

We now analyze the expected length of the subsequence removed when a match occurs.

Consider the following simplified scenario:  
We have a sequence **A** of \(m\) distinct integers. A value \(x \in A\) already exists in **A**. Now we insert another copy of \(x\) into a uniformly random position among the \(m+1\) possible insertion slots, forming a new sequence **A′**. This creates a contiguous subsequence \([x \ldots x]\), which is then removed. What is the expected length of this removed subsequence?

This can be further reduced to a purely combinatorial problem:

> From the integers \(1, 2, \ldots, m+1\), select two distinct numbers uniformly at random. What is the expected number of integers between them, inclusive?

Let the two selected positions be \(i\) and \(j\) with \(i < j\). The distance (inclusive length) is \(d = j - i + 1\), where \(2 \leq d \leq m+1\).

The expected value is:

\[
\mathbb{E}[d] = \frac{\displaystyle \sum_{d=2}^{m+1} d \cdot (m - d + 2)}{\binom{m+1}{2}}
= \frac{(m+2)\sum_{d=2}^{m+1} d - \sum_{d=2}^{m+1} d^2}{\binom{m+1}{2}}
\]

Applying the formulas for the sum of an arithmetic series and the sum of squares, and simplifying, we obtain:

\[
\mathbb{E}[d] = \frac{m + 5}{3}
\]

Therefore, **the expected length of the removed subsequence upon a successful match is \(\frac{|A| + 5}{3}\)**.

Consequently, if the current length of **A** is \(|A|\), then after a match, the expected new length \(|A'|\) is:

\[
\mathbb{E}[|A'|] = |A| + 1 - \frac{|A| + 5}{3} = \frac{2|A| - 2}{3}
\]

---

### Expected Matching Probability Over Time

Now consider the matching probability dynamics.

We have a sequence **A** of length \(m\) with all distinct elements. We insert an element \(b\) (from **B**, which may contain duplicates) into a random position in **A**. With probability \(p\), a match occurs; otherwise (with probability \(1-p\)), nothing is removed.

Let:
- \(E[K]\): expected number of elements in **A** that can match any element in the remaining **B**.
- \(E[K']\): expected number of such matchable elements in **A** after a successful match.

Due to the linearity of expectation and the earlier result on sequence length reduction, after a match:

\[
E[K'] \approx \frac{2E[K] - 2}{3}
\]

Meanwhile, the size of **B** decreases by 1.

The matching probability at any step is approximately:

\[
p = \frac{\text{number of matchable elements in } A}{\text{size of remaining } B}
\]

Thus, after a successful match:
- Numerator (matchable count) shrinks roughly by a factor of \(2/3\),
- Denominator (size of **B**) decreases by 1.

Assuming large values (\(x = E[K] \gg 1\), \(y = |B| \gg 1\)), we observe:

\[
\frac{x}{y} > \frac{(2x - 2)/3}{y - 1} \approx \frac{2x}{3(y - 1)} \approx \frac{2}{3} \cdot \frac{x}{y}
\]

Hence, **the matching probability \(p\) decreases after a successful match**.

Conversely, if no match occurs:
- **A** grows by 1 (since the new element is added without removal),
- The new element may itself become a future match target, so the number of matchable elements **increases or stays the same**,
- **B** still shrinks by 1.

Therefore, **\(p\) increases significantly after a failed match**.

This leads to a key insight:

> The system exhibits a **negative feedback loop**:  
> - If a match occurs → \(p\) decreases;  
> - If no match occurs → \(p\) increases.  

This behavior aligns with intuition and stabilizes the system.

---

### State Evolution Model

Define \(M_t\) as the length of **A** at the beginning of step \(t\). The system evolves as:

- With probability \(p_t\) (match succeeds):
  \[
  M_{t+1} = \frac{2M_t - 2}{3}
  \]
- With probability \(1 - p_t\) (no match):
  \[
  M_{t+1} = M_t + 1
  \]

Here, \(p_t\) depends on the overlap between the current **A** and the remaining **B**.

> Due to the negative feedback described above, the system self-regulates:  
> - Elimination reduces \(M\) → lowers future \(p_t\);  
> - No elimination increases \(M\) → raises future \(p_t\).  

Thus, \(M_t\) neither explodes nor collapses to zero, but fluctuates around a **dynamic equilibrium**.

---

### Steady-State Analysis

Assume the system reaches a steady state where the expected length remains constant: \(\mathbb{E}[M_t] \approx M\) for all \(t\). Approximate \(p_t \approx p\) as a constant depending only on \(M\) and the current size of **B** (denoted \(y\)).

Then:

\[
M = p \cdot \frac{2M - 2}{3} + (1 - p)(M + 1)
\]

Solving for \(M\):

\[
M = \frac{3}{p} - 5
\]

---

### Estimating the Equilibrium Length

To estimate \(p\) and locate the balance point, we adopt a **mean-field approximation**:

- Although **B** is a fixed input sequence, **A** evolves dynamically.
- Both share the same alphabet (values 1 to \(K\)).
- In expectation, the number of matchable elements between **A** and the remaining **B** is proportional to \(M\).

We make two key assumptions:

1. **Mean-field approximation**: In the large-system limit, the instantaneous matching probability can be approximated by its expected value, and this probability is proportional to the current length \( M \) of sequence A.
2. **Quasi-static approximation**: Since \(y = |B|\) changes slowly (decreases by 1 per step), the system quickly equilibrates at each fixed \(y\).

Thus:

\[
p_t \approx c \cdot \frac{M_t}{y} \quad \text{(for some constant } c\text{)}
\]

In equilibrium, \(M \approx 3/p - 5 \approx 3/p\) (ignoring the constant for scaling analysis). Substituting \(p \approx M / y\):

\[
M \approx \frac{3}{p} \approx \frac{3y}{M} \quad \Rightarrow \quad M^2 \approx 3y
\]

Therefore, for most of the process (when \(y = \Theta(n)\)):

\[
M_t = \Theta(\sqrt{n})
\]

This implies that the typical length of the dynamic sequence **A** scales with the square root of the initial size of **B**.

### Overall Time Complexity Estimation

Since \[ M_t = \Theta(\sqrt{n}) \] holds in typical cases, the total time complexity is:
\[
T = \sum_{t=1}^{n} O(M_t) \approx \sum_{t=1}^{n} O(\sqrt{n}) = O(n \cdot \sqrt{n}) = O(n^{3/2}).
\]

More precisely, if we treat \( M_t \approx \sqrt{n - t} \) as a continuous function, then:
\[
T \approx \int_0^n \sqrt{t} \, dt = \frac{2}{3} n^{3/2} = \Theta(n^{3/2}).
\]

This model is primarily intended for analyzing the macroscopic statistical behavior of the system when \[ M \gg 1 \]. We assume that the probability of the system being completely emptied [i.e., \[ M = 0 \] or \[ M = 1 \]] during execution is negligible. The validity of this assumption stems from the fact that the equilibrium point established by the negative feedback mechanism, \[ M_{\text{eq}} \approx \sqrt{3y/c} \], decreases slowly as \[ y \] diminishes, yet remains far from zero as long as \[ y \] is still relatively large. Consequently, the system spends the vast majority of its time in states where \[ M \] is sufficiently large. Our analysis characterizes the system's behavior in this steady-state regime and does not precisely capture the dynamics near absorbing or reflecting boundaries at very small values of \[ M \]—for example, if all elements of \[ A \] are completely eliminated after being matched by a subset of \[ B \], then subsequent insertions of \[ B \] would cause elements from \[ B \] to match among themselves.