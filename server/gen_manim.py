from manim import *

class GeneratedGIF(Scene):
    def construct(self):
        # Define colors
        matrix_color = YELLOW
        header_color = BLUE
        
        # Header text
        header_text = Text("Markov Matrix", color=header_color).scale(0.8)
        header_text.to_edge(UP, buff=0.5)
        
        # Define the Markov matrix
        matrix_values = [[0.1, 0.2, 0.7], [0.01, 0.99, 0.0], [0.3, 0.3, 0.4]]
        matrix_mob = Matrix(matrix_values, v_buff=0.8).set_color(matrix_color)
        
        # Align matrix under header
        matrix_mob.next_to(header_text, DOWN)
        
        # Group header and matrix for better control
        group = VGroup(header_text, matrix_mob)
        
        # Ensure the group fits the scene without surpassing the bounding window
        group.scale(0.9)
        
        self.play(Create(header_text), run_time=1)
        self.play(Create(matrix_mob), run_time=3)