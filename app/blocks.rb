class Square
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation
   end

   def draw(args)
    #Offset the coordinates to the edge of the game area 
    x_offset = (args.state.board_width + args.grid.w / 8)
    args.outputs.solids << [@x + x_offset + @block_offset / 2, @y, @block_size * 2 - @block_offset, @block_size * 2 - @block_offset]
   end
end

class TShape
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation
    end

    def draw(args)
        #Offset the coordinates to the edge of the game area 
        x_offset = (args.state.board_width + args.grid.w / 8)

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 3]
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2, @block_size]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3, @block_size]
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 2]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 3]
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2, @block_size]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3, @block_size]
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 2]
        end
    end
end

class UShape
    def initialize(x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation
    end

    def draw(args)
        x_offset = (args.state.board_width + args.grid.w / 8)

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 3]
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size]
            args.outputs.solids << [@x + x_offset + @block_size, @y + @block_size * 2, @block_size, @block_size]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3, @block_size]
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size, @block_size]
            args.outputs.solids << [@x + x_offset + @block_size * 2, @y + @block_size, @block_size, @block_size]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 3]
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size]
            args.outputs.solids << [@x + x_offset, @y + @block_size * 2, @block_size, @block_size]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3, @block_size]
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size]
            args.outputs.solids << [@x + x_offset + @block_size * 2, @y, @block_size, @block_size]
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
    end

    def draw(args)
        x_offset = (args.state.board_width + args.grid.w / 8)

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3, @block_size]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 3]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset, @y, @block_size * 3, @block_size]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 3]
        end
    end
end

class LongLine
    def initialize(x, y, block_size, orientation, block_offset)
        @x = block_size
        @y = block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation
    end

    def draw(args)
        x_offset = (args.state.board_width + args.grid.w / 8)

        if @orientation == :right
            args.outputs.solids << [@x + x_offset, @y, @block_size * 4, @block_size]
        elsif @orientation == :up
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 4]
        elsif @orientation == :left
            args.outputs.solids << [@x + x_offset, @y, @block_size * 4, @block_size]
        elsif @orientation == :down
            args.outputs.solids << [@x + x_offset, @y, @block_size, @block_size * 4]
        end
    end
end