from manim import *

class GeneratedGIF(Scene):
    def construct(self):
        # Title for context
        title = Text("A Typical Markov Matrix", font_size=36).shift(UP * 3.5)
        self.play(Create(title))
        
        # Markov matrix example
        matrix_values = [[0.1, 0.2, 0.7], [0.01, 0.99, 0], [0.3, 0.3, 0.4]]
        matrix_mob = Matrix(matrix_values, v_buff=0.8, h_buff=1.5).scale(0.7)  # Adjust buffers for clarity
        
        #Label for the matrix
        matrix_label = Text("Markov Matrix", font_size=24).next_to(matrix_mob, UP)
        
        # Group the matrix and its label for a nice alignment
        matrix_group = VGroup(matrix_mob, matrix_label).move_to(ORIGIN)
        
        self.play(Create(matrix_mob), run_time=2)
        self.play(Write(matrix_label), run_time=1)
        self.wait(1)  # Hold the frame for one second before concluding the scene
        
        # Explanation part - what makes it a Markov matrix (Sum = 1 for each column)
        verify_texts = VGroup(
            Text("Each column sums to 1", font_size=24),
            Text("Non-negative entries", font_size=24)
        ).arrange(DOWN, center=False, aligned_edge=LEFT).next_to(matrix_group, DOWN, buff=1)
        
        self.play(FadeIn(verify_texts), run_time=1)
        self.wait(1)  # Ensuring the explanation is understood