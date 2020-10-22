
class Ball
    attr_accessor :velocity
    attr_reader :x, :y, :hypotenuse, :width, :height

    def initialize args
        #Start the ball in the top center
        @x = args.grid.w / 2
        @y = args.grid.h - 20

        @velocity = Vector2d.new(2, -2)
        @width =  10
        @height = 10

        @left_wall = (args.state.board_width + args.grid.w / 8)
        @right_wall = @left_wall + args.state.board_width

        @max_velocity = MAX_VELOCITY
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
        #args.outputs.solids << [@x, @y, @width, @height, 255, 255, 0];
        #args.outputs.sprits << {
          #x: @x,
          #y: @y,
          #w: @width,
          #h: @height,
          #path: "sprites/ball10.png"
        #}
        args.outputs.sprites <<[@x, @y, @width, @height, "sprites/ball10.png"]
    end

    def getDraw args
      wallBounds args
      update args
      return [@x, @y, @width, @height, "sprites/ball10.png"]
    end

    def getPoints args
      points = [
        {x:@x+@width/2, y: @y},
        {x:@x+@width, y:@y+@height/2},
        {x:@x+@width/2,y:@y+@height},
        {x:@x,y:@y+@height/2}
      ]
      #psize = 5.0
      #for p in points
        #args.outputs.solids << [p.x-psize/2.0, p.y-psize/2.0, psize, psize, 0, 0, 0];
      #end
      return points
    end

    def serialize
      {x: @x, y:@y}
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
