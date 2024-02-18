from manim import *

class GeneratedGIF(Scene):
    def construct(self):
        # Setup the matrix
        matrix_m = Matrix([[0.5, 0.5], [0.4, 0.6]],
                          v_buff=1.0, h_buff=1.0).scale(0.7)

        # Header text
        header = Text("Squaring Markov Matrix", color=BLUE).to_edge(UP)

        # Square the matrix descriptor
        squared_matrix_description = Text(
            "Squaring the matrix keeps its properties",
            font_size=24
        ).next_to(matrix_m, DOWN)

        # Animation: Show the header, then the matrix, and finally the description
        self.play(Create(header))
        self.play(Write(matrix_m), run_time=1)
        self.play(Write(squared_matrix_description), run_time=1)