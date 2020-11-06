class Peg
    def initialize(x, y, block_size)
        @x = x
        @y = y
        @block_size = block_size

        @r = 255
        @g = 0
        @b = 0
   end

   def draw(args)
    #Offset the coordinates to the edge of the game area 
    args.outputs.solids << [@x, @y, @block_size, @block_size, @r, @g, @b]
   end
end