WIDTH = 1280
HEIGHT= 720
INFINITY= 10**10

require 'app/vector2d.rb'
require 'app/paddle.rb'
require 'app/ball.rb'
require 'app/linearCollider.rb'

#Method to init default values
def defaults args
  args.state.game_board ||= [(WIDTH / 2 - WIDTH / 4), 0, (WIDTH / 2), HEIGHT]
  args.state.bricks ||= []
  args.state.num_bricks ||= 0
end

#Render loop
def render args
  render_instructions args
  render_board args
  render_bricks args


end

begin :render_methods

  #Method to display the instructions of the game
  def render_instructions args
    args.outputs.labels << [225, HEIGHT - 30, "S and D to move the paddle left and right",  0, 1]
  end

  def render_board args
    args.outputs.borders << args.state.game_board
  end

  def render_bricks args
    args.outputs.solids << args.state.bricks.map(&:rect)
  end

  def add_new_bricks args
    return if args.state.num_bricks > 40

    #Width of the game board is 640px
    brick_width = (WIDTH / 2) / 10
    brick_height = brick_width / 2
    x = 0
    y = 0

    while y < 4
      #Make a box that is 10 bricks wide and 4 bricks tall
      args.state.bricks += (10).map do
        args.state.new_entity(:brick) do |b|
          b.x = x * brick_width + (WIDTH / 2 - WIDTH / 4)
          b.y = HEIGHT - ((y + 1) * brick_height)
          b.rect = [b.x + 1, b.y - 1, brick_width - 2, brick_height - 2, 135, 135, 135]
          args.state.num_bricks += 1
          x += 1
        end
      end
      x = 0
      y += 1
    end
  end
end

#Calls all methods necessary for performing calculations
def calc args
  add_new_bricks args
end

$mode = :both
def tick args
  if $mode == :paddle || $mode == :both
      args.state.paddle ||= Paddle.new
      args.state.ball   ||= Ball.new
      args.state.westWall  ||= LinearCollider.new([WIDTH/4,0],[WIDTH/4,HEIGHT], :pos)
      args.state.eastWall  ||= LinearCollider.new([3*WIDTH*0.25,0],[3*WIDTH*0.25,HEIGHT])
      args.state.southWall ||= LinearCollider.new([0,0],[WIDTH,0])
      args.state.northWall ||= LinearCollider.new([0,HEIGHT-32*4],[WIDTH,HEIGHT-32*4],:pos)

      args.state.paddle.update args
      args.state.ball.update args

      args.state.westWall.update args
      args.state.eastWall.update args
      args.state.southWall.update args
      args.state.northWall.update args

      args.state.paddle.render args
      args.state.ball.render args
  end
  if $mode == :brick || $mode == :both
    defaults args
    render args
    calc args
  end
end
