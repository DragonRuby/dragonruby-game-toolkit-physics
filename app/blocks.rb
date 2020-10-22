class Square
    def initialize(args, x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation


        Kernel.srand()
        @r = rand(255)
        @g = rand(255)
        @b = rand(255)

        x_offset = (args.state.board_width + args.grid.w / 8) + @block_offset / 2
        @x_adjusted = @x + x_offset
        @y_adjusted = @y
        @size_adjusted = @block_size * 2 - @block_offset

        hypotenuse=args.state.ball_hypotenuse
        @bold = [(@x_adjusted-hypotenuse/2)-1, (@y_adjusted-hypotenuse/2)-1, @size_adjusted + hypotenuse + 2, @size_adjusted + hypotenuse + 2]

        @points = [
          {x:@x_adjusted, y:@y_adjusted},
          {x:@x_adjusted+@size_adjusted, y:@y_adjusted},
          {x:@x_adjusted+@size_adjusted, y:@y_adjusted+@size_adjusted},
          {x:@x_adjusted, y:@y_adjusted+@size_adjusted}
        ]
        @colliders = [
          LinearCollider.new(@points[0],@points[1], :neg),
          LinearCollider.new(@points[1],@points[2], :neg),
          LinearCollider.new(@points[2],@points[3], :pos),
          LinearCollider.new(@points[0],@points[3], :pos)
        ]
   end

   def draw(args)
    #Offset the coordinates to the edge of the game area
    x_offset = (args.state.board_width + args.grid.w / 8) + @block_offset / 2
    args.outputs.solids << [@x + x_offset, @y, @block_size * 2 - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
    #args.outputs.solids << @bold.append([255,0,0])

   end

   def update args
     for b in args.state.balls
       if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
         for c in @colliders
           #puts args.state.ball.velocity
           if c.collision?(args, b.getPoints(args))
             c.collide args, b
           end
         end
       end
     end
   end
end

class TShape
    def initialize(args, x, y, block_size, orientation, block_offset)
        @x = x * block_size
        @y = y * block_size
        @block_size = block_size
        @block_offset = block_offset
        @orientation = orientation

        Kernel.srand()
        @r = rand(255)
        @g = rand(255)
        @b = rand(255)

        @shapePoints = getShapePoints(args)
        minX={x:INFINITY, y:0}
        minY={x:0, y:INFINITY}
        maxX={x:-INFINITY, y:0}
        maxY={x:0, y:-INFINITY}
        for p in @shapePoints
          if p.x < minX.x
            minX = p
          end
          if p.x > maxX.x
            maxX = p
          end
          if p.y < minY.y
            minY = p
          end
          if p.y > maxY.y
            maxY = p
          end
        end


        hypotenuse=args.state.ball_hypotenuse

        @bold = [(minX.x-hypotenuse/2)-1, (minY.y-hypotenuse/2)-1, -((minX.x-hypotenuse/2)-1)+(maxX.x + hypotenuse + 2), -((minY.y-hypotenuse/2)-1)+(maxY.y + hypotenuse + 2)]
        #@colliders = [
          #LinearCollider.new(@points[0],@points[1], :neg),
          #LinearCollider.new(@points[1],@points[2], :neg),
          #LinearCollider.new(@points[2],@points[3], :pos),
          #LinearCollider.new(@points[0],@points[3], :pos)
        #]
    end
    def getShapePoints(args)
      points=[]
      x_offset = (args.state.board_width + args.grid.w / 8) + (@block_offset / 2)

      if @orientation == :right
          #args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2, @block_size, @r, @g, @b]
          points = [
            {x:@x + x_offset, y:@y},
            {x:(@x + x_offset)+(@block_size - @block_offset), y:@y},
            {x:(@x + x_offset)+(@block_size - @block_offset),y:@y + @block_size},
            {x:(@x + x_offset)+ @block_size * 2,y:@y + @block_size},
            {x:(@x + x_offset)+ @block_size * 2,y:@y + @block_size+@block_size},
            {x:(@x + x_offset)+(@block_size - @block_offset),y:@y + @block_size+@block_size},
            {x:(@x + x_offset)+(@block_size - @block_offset), y:@y+ @block_size * 3 - @block_offset},
            {x:@x + x_offset , y:@y+ @block_size * 3 - @block_offset}
          ]
          @colliders = [
            LinearCollider.new(@points[0],@points[1], :neg),
            LinearCollider.new(@points[1],@points[2], :neg),
            LinearCollider.new(@points[2],@points[3], :neg),
            LinearCollider.new(@points[3],@points[4], :neg),
            LinearCollider.new(@points[4],@points[5], :pos),
            LinearCollider.new(@points[5],@points[6], :pos),
            LinearCollider.new(@points[6],@points[7], :pos),
            LinearCollider.new(@points[0],@points[7], :pos)
          ]
      elsif @orientation == :up
          #args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 2, @r, @g, @b]
          points = [
            {x:@x + x_offset, y:@y},
            {x:(@x + x_offset)+(@block_size * 3 - @block_offset), y:@y},
            {x:(@x + x_offset)+(@block_size * 3 - @block_offset), y:@y+(@block_size - @block_offset)},
            {x:@x + x_offset + @block_size + @block_size, y:@y+(@block_size - @block_offset)},
            {x:@x + x_offset + @block_size + @block_size, y:@y+@block_size*2},
            {x:@x + x_offset + @block_size, y:@y+@block_size*2},
            {x:@x + x_offset + @block_size, y:@y+(@block_size - @block_offset)},
            {x:@x + x_offset, y:@y+(@block_size - @block_offset)}
          ]
          @colliders = [
            LinearCollider.new(@points[0],@points[1], :neg),
            LinearCollider.new(@points[1],@points[2], :neg),
            LinearCollider.new(@points[2],@points[3], :pos),
            LinearCollider.new(@points[3],@points[4], :pos),
            LinearCollider.new(@points[4],@points[5], :pos),
            LinearCollider.new(@points[5],@points[6], :pos),
            LinearCollider.new(@points[6],@points[7], :pos),
            LinearCollider.new(@points[0],@points[7], :pos)
          ]
      elsif @orientation == :left
          #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2 - @block_offset, @block_size - @block_offset, @r, @g, @b]
          points = [
            {x:@x + x_offset, y:@y},
            {x:0, y:0},
            {x:0, y:0},
            {x:0, y:0},
            {x:0, y:0},
            {x:0, y:0},
            {x:0, y:0},
            {x:0, y:0}
          ]
      elsif @orientation == :down
          #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
      end
      return points
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

        #psize = 5.0
        #for p in @shapePoints
          #args.outputs.solids << [p.x-psize/2, p.y-psize/2, psize, psize, 0, 0, 0]
        #end
    end

    def update args

      if @orientation == :up

        for b in args.state.balls
          if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
            for c in @colliders
              if c.collision?(args, b.getPoints(args))
                #c.collide args, b
              end
            end
          end
        end
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
