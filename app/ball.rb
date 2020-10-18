  
class Ball
    attr_accessor :velocity
  
    def initialize args
        #Start the ball in the top center
        @x = args.grid.w / 2
        @y = args.grid.h - 20

        @velocity = Vector2d.new(2, -2)
        @width =  20
        @height = 20

        @left_wall = (args.state.board_width + args.grid.w / 8)
        @right_wall = @left_wall + args.state.board_width

        @max_velocity = 7
    end
  
    #Move the ball according to its velocity
    def update args
        @x += @velocity.x
        @y += @velocity.y
    end

    def wallBounds args
        if @x < @left_wall || @x + @width > @right_wall
            @velocity.x *= -1.1
            if @velocity.x > @max_velocity
                @velocity.x = @max_velocity
            elsif @velocity.x < @max_velocity * -1
                @velocity.x = @max_velocity * -1
            end
        end
        if @y < 0 || @y + @height > args.grid.h
            @velocity.y *= -1.1
            if @velocity.y > @max_velocity
                @velocity.y = @max_velocity
            elsif @velocity.y < @max_velocity * -1
                @velocity.y = @max_velocity * -1
            end
        end
    end
  
    #render the ball to the screen
    def draw args
        wallBounds args
        update args
        args.outputs.solids << [@x, @y, @width, @height, 255, 255, 0];
    end 
  end