from manim import *

class GeneratedGIF(Scene):
    def construct(self):
        # Define matrix data
        matrix_data = [[0.1, 0.2, 0.7],
                       [0.01, 0.99, 0],
                       [0.3, 0.3, 0.4]]
        matrix = DecimalMatrix(matrix_data, 
                               element_to_mobject_config={"num_decimal_places": 2},
                               h_buff=1.5, 
                               v_buff=1.5).set_color(WHITE)
        
        # Define header text
        header = Text("Markov Matrix Example", color=YELLOW).scale(0.7)
        header.move_to(3*UP)

        # Position matrix under header
        matrix.next_to(header, DOWN)

        # Framebox to highlight the matrix
        box = SurroundingRectangle(matrix, color=BLUE, buff=0.1)

        # Animation: simultaneous header, matrix, and box creation
        self.play(Create(header), Create(matrix), Create(box), run_time=2)

        # Information text about Markov matrices specifications
        info_text = Text("Rows sum to 1", color=GREEN).scale(0.5)
        info_text.next_to(matrix, DOWN)

        # Animation: Show info text
        self.play(Write(info_text), run_time=2)