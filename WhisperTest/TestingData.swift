//
//  TestingData.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

enum TestingData {
    static let script = """
    What's a Markov matrix?
    Can I just write down a typical Markov matrix, say .1, .2, .7, .01, .99 0, let's say, .3, .3, .4. Okay. There's a -- a
    totally just invented Markov matrix. What makes it a Markov matrix?
    Two properties that this -- this matrix has.
    So two properties are -- one, every entry is greater equal zero.
    All entries greater than or equal to zero.
    And, of course, when I square the matrix, the entries will still be greater/equal zero.
    I'm going to be interested in the powers of this matrix.
    """
}

extension TestingData {
    static let latex = #"""
    Level 1:
    Imagine you have a system where a population can move between different states. For example, a group of people can be in one of two rooms. Each person can stay in the same room or move to the other room. The probabilities of these movements can be described by a matrix, where each entry represents the probability of moving from one state to another. This type of matrix is called a Markov matrix.
    A Markov matrix has non-negative entries, and the columns sum to 1. This represents the fact that the probabilities of moving to different states from a given state must add up to 1.
    Level 2:
    Now, let's dive a little deeper into Markov matrices. If we raise a Markov matrix to a power, we get another Markov matrix. This is because the entries in the matrix represent probabilities, and the product of two matrices represents the combination of two sets of probabilities.
    For example, consider a system with two states, A and B. The Markov matrix for this system might look like this:
    \begin{bmatrix}
    0.5 & 0.5 \
    0.3 & 0.7
    \end{bmatrix}
    If we raise this matrix to the second power, we get:
    \begin{bmatrix}
    0.4 & 0.6 \
    0.42 & 0.58
    \end{bmatrix}
    This new matrix still represents a valid Markov matrix, as the entries are non-negative and the columns sum to 1.
    Level 3:
    Now, let's talk about the long-term behavior of Markov matrix systems. As we raise the matrix to higher and higher powers, the system approaches a steady state. This steady state is represented by the eigenvector corresponding to the eigenvalue of 1.
    For example, consider the Markov matrix from before:
    \begin{bmatrix}
    0.5 & 0.5 \
    0.3 & 0.7
    \end{bmatrix}
    The eigenvalues for this matrix are 1 and 0.4. The eigenvector corresponding to the eigenvalue of 1 is [0.6, 0.4]. As we raise the matrix to higher powers, the system approaches this steady state.
    This steady state represents the long-term behavior of the system. In our example, it tells us that over time, the system will approach a state where 60% of the population is in state A and 40% is in state B.
    So, in essence, Markov matrices provide a powerful tool for describing and analyzing systems where population moves between states with probabilities as matrix entries. The long-term behavior of these systems approaches a steady state, represented by the eigenvector corresponding to the eigenvalue of 1.
    """#
}
