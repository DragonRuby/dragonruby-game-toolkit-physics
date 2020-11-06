INFINITY= 10**10

require 'app/vector2d.rb'
require 'app/peg.rb'
require 'app/ball.rb'
require 'app/bucket.rb'

#Method to init default values
def defaults args
  args.state.pegs ||= []
  args.state.bucket ||= Bucket.new(250, args)
  init_pegs args
end

begin :default_methods
  def init_pegs args
    num_horizontal_pegs = 14
    num_rows = 6
    
    return unless args.state.pegs.count < num_rows * num_horizontal_pegs

    block_size = 32
    block_spacing = 50
    total_width = num_horizontal_pegs * (block_size + block_spacing)
    starting_offset = (args.grid.w - total_width) / 2 + block_size
    
    for i in (0...num_rows)
      for j in (0...num_horizontal_pegs)
        row_offset = 0
        if i % 2 == 0
          row_offset = 20
        else
          row_offset = -20
        end
        args.state.pegs.append(Peg.new(j * (block_size+block_spacing) + starting_offset + row_offset, (args.grid.h - block_size * 2) - (i * block_size * 2), block_size))
      end
    end
  end

  def init_balls args

  end
end

#Render loop
def render args
  args.outputs.borders << args.state.game_area
  render_pegs args
  args.state.bucket.draw args
end

begin :render_methods
  def render_instructions args
  end

  #Draw the pegs in a grid pattern
  def render_pegs args
    args.state.pegs.each do |peg|
      peg.draw args
    end
  end

  def render_balls args
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
