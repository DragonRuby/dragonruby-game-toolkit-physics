INFINITY= 10**10
MAX_VELOCITY = 5.0
require 'app/vector2d.rb'
require 'app/blocks.rb'
require 'app/ball.rb'
require 'app/rectangle.rb'
require 'app/linearCollider.rb'



#Method to init default values
def defaults args
  args.state.board_width ||= args.grid.w / 4
  args.state.board_height ||= args.grid.h
  args.state.game_area ||= [(args.state.board_width + args.grid.w / 8), 0, args.state.board_width, args.grid.h]
  args.state.balls ||= []
  args.state.num_balls ||= 0
  args.state.ball_created_at ||= args.state.tick_count
  args.state.ball_hypotenuse = (10**2 + 10**2)**0.5
  args.state.rectangle ||=  Rectangle.new args


  init_blocks args
  init_balls args
end

begin :default_methods
  def init_blocks args
    block_size = args.state.board_width / 8
    #Space inbetween each block
    block_offset = 4

    #Possible orientations are :right, :left, :up, :down

    args.state.square ||= Square.new(args, 2, 0, block_size, :right, block_offset)
    args.state.square2 ||= Square.new(args, 5, 0, block_size, :right, block_offset)
    args.state.square3 ||= Square.new(args, 6, 7, block_size, :right, block_offset)

    #args.state.tshape ||= TShape.new(args, 0, 1, block_size, :left, block_offset)
    #args.state.tshape2 ||= TShape.new(args, 3, 3, block_size, :down, block_offset)
    #args.state.tshape3 ||= TShape.new(args, 0, 8, block_size, :right, block_offset)
    #args.state.tshape4 ||= TShape.new(args, 0, 11, block_size, :up, block_offset)

    #args.state.line ||= Line.new(4, 0, block_size, :up, block_offset)
    #args.state.line2 ||= Line.new(7, 0, block_size, :up, block_offset)
    #args.state.line3 ||= Line.new(0, 7, block_size, :right, block_offset)
  end

  def init_balls args
    return unless args.state.num_balls < 99


    #only create a new ball every 10 ticks
    return unless args.state.ball_created_at.elapsed_time > 10

    args.state.balls.append(Ball.new(args))
    args.state.ball_created_at = args.state.tick_count
    args.state.num_balls += 1
  end
end

#Render loop
def render args
  bgClr = {r:10, g:10, b:200}
  args.outputs.solids << [0, 0, $args.grid.right, $args.grid.top, bgClr[:r], bgClr[:g], bgClr[:b]];
  args.outputs.borders << args.state.game_area

  render_instructions args
  render_shapes args

  render_balls args

  args.state.rectangle.draw args

  args.outputs.sprites << [$args.grid.right-(args.state.board_width + args.grid.w / 8), 0, $args.grid.right, $args.grid.top, "sprites/square-white-2.png", 0, 255, bgClr[:r], bgClr[:g], bgClr[:b]]
  args.outputs.sprites << [0, 0, (args.state.board_width + args.grid.w / 8), $args.grid.top, "sprites/square-white-2.png", 0, 255, bgClr[:r], bgClr[:g], bgClr[:b]]
end

begin :render_methods
  def render_instructions args
    #gtk.current_framerate
    args.outputs.labels << [20, $args.grid.top-20, "FPS: " + $gtk.current_framerate.to_s]
  end

  def render_shapes args
    args.state.square.draw args
    args.state.square2.draw args
    args.state.square3.draw args

    #args.state.line.draw args
    #args.state.line2.draw args
    #args.state.line3.draw args

    #args.state.tshape.draw args
    #args.state.tshape2.draw args
    #args.state.tshape3.draw args
    #args.state.tshape4.draw args

  end

  def render_balls args
    #args.state.balls.each do |ball|
      #ball.draw args
    #end

    args.outputs.sprites << args.state.balls.map do |ball|
      ball.getDraw args
    end
  end
end

#Calls all methods necessary for performing calculations
def calc args
  args.state.rectangle.update args
  args.state.square.update args
  args.state.square2.update args
  args.state.square3.update args
  #args.state.tshape3.update args
  #args.state.tshape4.update args
end

begin :calc_methods

end

def tick args
  defaults args
  render args
  calc args
end
