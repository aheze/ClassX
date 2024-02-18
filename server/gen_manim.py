from manim import *

class GeneratedGIF(Scene):
    def construct(self):
        # Define the text for the matrix and the question
        title = Text("What's a Markov Matrix?", font_size=36)
        matrix_text = MathTex("\\begin{bmatrix} 0.1 & 0.2 & 0.7 \\\\ 0.01 & 0.99 & 0 \\\\ 0.3 & 0.3 & 0.4 \\end{bmatrix}", font_size=28)
        question = Text("What makes it a Markov matrix?", font_size=24)

        # Align the elements
        title.to_edge(UP, buff=0.5)
        matrix_text.next_to(title, DOWN, buff=0.5)
        question.next_to(matrix_text, DOWN, buff=0.5)

        # Grouping for easy animation
        all_elements = VGroup(title, matrix_text, question)

        # Colors for highlighting
        title.set_color(YELLOW)
        matrix_text.set_color(GREEN)
        question.set_color(BLUE)

        # Animation
        self.play(Create(all_elements), run_time=4)
        self.wait()

        # Ensure not to surpass bounding window
        all_elements.scale(0.9)