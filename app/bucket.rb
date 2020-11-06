class Bucket
    def initialize(width, args)
        @width = width
        @height = 20

        @x = (args.grid.w / 2) - (@width / 2)
        @y = 0
        @left = true
    end

    def draw args
        args.outputs.solids << [@x, @y, @width, @height, 0, 0, 0]
        
        if @left
            @x -= 5
            if @x <= 0
                @left = false
            end
        else
            @x += 5
            if @x + @width >= args.grid.w
                @left = true
            end
        end
    end
end