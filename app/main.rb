INFINITY= 10**10

require 'app/blocks.rb'

#Method to init default values
def defaults args
  args.state.board_width ||= args.grid.w / 4
  args.state.board_height ||= args.grid.h
  args.state.game_area ||= [(args.state.board_width + args.grid.w / 8), 0, args.state.board_width, args.grid.h]
  init_blocks args
end

begin :default_methods
  def init_blocks args
    block_size = args.state.board_width / 8
    #Space inbetween each block
    block_offset = 4
    
    #Possible orientations are :right, :left, :up, :down

    args.state.square ||= Square.new(2, 0, block_size, :right, block_offset)
    args.state.square2 ||= Square.new(5, 0, block_size, :right, block_offset)
    args.state.square3 ||= Square.new(6, 7, block_size, :right, block_offset)
 
    args.state.tshape ||= TShape.new(0, 0, block_size, :left, block_offset)
    args.state.tshape2 ||= TShape.new(3, 3, block_size, :down, block_offset)
    args.state.tshape3 ||= TShape.new(6, 0, block_size, :left, block_offset)

    args.state.line ||= Line.new(4, 0, block_size, :up, block_offset)
    args.state.line2 ||= Line.new(7, 0, block_size, :up, block_offset)
    args.state.line3 ||= Line.new(0, 7, block_size, :right, block_offset)
  end
end

#Render loop
def render args
  render_instructions args

  args.state.square.draw args
  args.state.square2.draw args
  args.state.square3.draw args

  args.state.line.draw args
  args.state.line2.draw args
  args.state.line3.draw args

  args.state.tshape.draw args
  args.state.tshape2.draw args

  
  args.outputs.borders << args.state.game_area
end

begin :render_methods
  def render_instructions args
  end
end

#Calls all methods necessary for performing calculations
def calc args

end

begin :calc_methods
 
end

def tick args
  defaults args
  render args
  calc args
end
