<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({ tex2jax: {inlineMath: [['$', '$']]}, messageStyle: "none" });
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