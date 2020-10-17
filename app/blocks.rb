class Square
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation


        Kernel.srand()
        @r = rand(255)
        @g = rand(255)
        @b = rand(255)
   end

   def draw(args)
    #Offset the coordinates to the edge of the game area 
    x_offset = (args.state.board_width + args.grid.w / 8) + @block_offset / 2
    args.outputs.solids << [@x + x_offset, @y, @block_size * 2 - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
   end
end

class TShape
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation

        Kernel.srand()
        @r = rand(255)
        @g = rand(255)
        @b = rand(255)
    end

    def draw(args)
        #Offset the coordinates to the edge of the game area 
        x_offset = (args.state.board_width + args.grid.w / 8) + (@block_offset / 2)

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2, @block_size, @r, @g, @b]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 2, @r, @g, @b]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2 - @block_offset, @block_size - @block_offset, @r, @g, @b]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
        end
    end
end

class Line
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation

        Kernel.srand()
        @r = rand(255)
        @g = rand(255)
        @b = rand(255)
    end

    def draw(args)
        x_offset = (args.state.board_width + args.grid.w / 8) + @block_offset / 2

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
        end
    end
end