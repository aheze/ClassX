//
//  TestingData.swift
//  WhisperTest
//
//  Created by Andrew Zheng (github.com/aheze) on 2/17/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct TestingConfiguration {
    var mockTranscript: String
    
    // use snapshots instead of uploading to server
    var useSnapshotsForVisualizations = true
    var snapshots: [Snapshot]
    

    struct Snapshot {
        var visualizations: [Visualization]
    }

    static let mock = TestingConfiguration(
        mockTranscript: TestingData.script,
        snapshots: [
            Snapshot(
                visualizations: [
                    Visualization(id: UUID().uuidString, visualizationType: .image, mainBody: "https://www.mathworks.com/help/examples/econ/win64/VisualizeMarkovChainStructureAndEvolutionExample_01.png")
                ]
            ),
            Snapshot(
                visualizations: [
                    Visualization(id: UUID().uuidString, visualizationType: .image, mainBody: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Markovkate_01.svg/260px-Markovkate_01.svg.png"),
                    Visualization(id: UUID().uuidString, visualizationType: .plainText, mainBody: "Here is some plain text!")
                ]
            ),
            Snapshot(visualizations: []) // nothing for the 3rd line
        ]
    )
}

enum TestingData {
    static let script = """
    What's a Markov matrix?
    Can I just write down a typical Markov matrix, say .1, .2, .7, .01, .99 0, let's say, .3, .3, .4. Okay.
    There's a totally just invented Markov matrix. What makes it a Markov matrix?
    """
}

extension TestingData {
//    static let latex = #"""
//    \begin{bmatrix}
//    0.5 & 0.5 \\
//    0.3 & 0.7
//    \end{bmatrix}
//    """#

    static let latex = #"""
    **Level 1: Introduction to Markov Matrices (Markdown)**

    Markov matrices are a special type of matrix that have non-negative entries (entries that are greater than or equal to zero) and columns that sum to 1. These matrices are used to describe systems where population moves between states with probabilities as matrix entries.

    For example, consider a simple system where a population of 100 individuals can be in one of two states: A or B. The probability of moving from state A to state B is 0.4, and the probability of moving from state B to state A is 0.6. We can represent this system with a Markov matrix:

    $$
    P = \begin{bmatrix}
    0.6 & 0.4 \\
    0.6 & 0.4
    \end{bmatrix}
    $$

    **Level 2: Eigenvalues and Powers of Markov Matrices (LaTeX)**

    One important property of Markov matrices is that 1 is an eigenvalue, and all other eigenvalues are less than 1 in absolute value. This means that when we raise a Markov matrix to a power, the entries of the resulting matrix will converge to the eigenvector corresponding to the eigenvalue of 1.

    For example, consider the Markov matrix P from the previous example. The eigenvalues of P are 1 and 0. The eigenvector corresponding to the eigenvalue of 1 is [2/3, 1/3], which represents the long-term distribution of the population between states A and B.

    $$
    P^n = \begin{bmatrix}
    0.6 & 0.4 \\
    0.6 & 0.4
    \end{bmatrix}^n \rightarrow \begin{bmatrix}
    2/3 & 1/3 \\
    2/3 & 1/3
    \end{bmatrix} \text{ as } n \rightarrow \infty
    $$

    **Level 3: Analogy of Markov Matrices to a Game of Dice (LaTeX)**

    To understand the concept of Markov matrices, let's consider a game of dice. Imagine you have two dice, one red and one blue. The red die has 4 sides with the number 1, and 2 sides with the number 2. The blue die has 3 sides with the number 1, and 3 sides with the number 2. You roll both dice and add up the numbers.

    The probability of getting a sum of 2 is 2/36 (roll a 1 on the red die and a 1 on the blue die), and the probability of getting a sum of 3 is 4/36 (roll a 1 on the red die and a 2 on the blue die, or roll a 2 on the red die and a 1 on the blue die). We can represent this system with a Markov matrix:

    $$
    P = \begin{bmatrix}
    2/36 & 4/36 \\
    3/36 & 9/36
    \end{bmatrix}
    $$

    The eigenvalues of P are 1 and 1/4. The eigenvector corresponding to the eigenvalue of 1 is [4/7, 3/7], which represents the long-term distribution of the sums of the dice rolls.

    In this way, Markov matrices can be thought of as a mathematical representation of a game of chance, where the probabilities of different outcomes are used to describe the transitions between states.
    """#
}
