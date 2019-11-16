import pygame


# Define some colors.
BLACK = pygame.Color('black')
WHITE = pygame.Color('white')


# This is a simple class that will help us print to the screen.
# It has nothing to do with the joysticks, just outputting the
# information.
class TextPrint(object):
    def __init__(self):
        self.reset()
        self.font = pygame.font.Font(None, 20)

    def tprint(self, screen, textString):
        textBitmap = self.font.render(textString, True, BLACK)
        screen.blit(textBitmap, (self.x, self.y))
        self.y += self.line_height

    def reset(self):
        self.x = 10
        self.y = 10
        self.line_height = 15

    def indent(self):
        self.x += 10

    def unindent(self):
        self.x -= 10


pygame.init()

# Set the width and height of the screen (width, height).
#screen = pygame.display.set_mode((500, 700))

#pygame.display.set_caption("My Game")

# Loop until the user clicks the close button.
done = False


# Initialize the joysticks.
pygame.joystick.init()

# Get ready to print.
#textPrint = TextPrint()

# -------- Main Program Loop -----------
while not done:
    #
    # EVENT PROCESSING STEP
    #
    # Possible joystick actions: JOYAXISMOTION, JOYBALLMOTION, JOYBUTTONDOWN,
    # JOYBUTTONUP, JOYHATMOTION

    #
    # DRAWING STEP
    #
    # First, clear the screen to white. Don't put other drawing commands
    # above this, or they will be erased with this command.
#    screen.fill(WHITE)
#    textPrint.reset()

    # Get count of joysticks.
    joystick_count = pygame.joystick.get_count()

    print( "Number of joysticks: {}".format(joystick_count))

    # For each joystick:
    for i in range(joystick_count):
        joystick = pygame.joystick.Joystick(i)
        joystick.init()

        print "Joystick {}".format(i)

        # Get the name from the OS for the controller/joystick.
        name = joystick.get_name()
        print "Joystick name: {}".format(name)

        # Usually axis run in pairs, up/down for one, and left/right for
        # the other.
        axes = joystick.get_numaxes()
        print "Number of axes: {}".format(axes)

        for i in range(axes):
            axis = joystick.get_axis(i)
            print "Axis {} value: {:>6.3f}".format(i, axis)

        buttons = joystick.get_numbuttons()
        print "Number of buttons: {}".format(buttons)

        for i in range(buttons):
            button = joystick.get_button(i)
            print "Button {:>2} value: {}".format(i, button)

        hats = joystick.get_numhats()
        print "Number of hats: {}".format(hats)

        # Hat position. All or nothing for direction, not a float like
        # get_axis(). Position is a tuple of int values (x, y).
        for i in range(hats):
            hat = joystick.get_hat(i)
            print "Hat {} value: {}".format(i, str(hat))

    #
    # ALL CODE TO DRAW SHOULD GO ABOVE THIS COMMENT
    #

    # Go ahead and update the screen with what we've drawn.


# Close the window and quit.
# If you forget this line, the program will 'hang'
# on exit if running from IDLE.
pygame.quit()
