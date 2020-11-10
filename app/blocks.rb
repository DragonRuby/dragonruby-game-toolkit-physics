MAX_COUNT=100

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

        @count = rand(MAX_COUNT)+1

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
        @squareColliders = [
          SquareCollider.new(@points[0].x,@points[0].y,{x:-1,y:-1}),
          SquareCollider.new(@points[1].x-COLLISIONWIDTH,@points[1].y,{x:1,y:-1}),
          SquareCollider.new(@points[2].x-COLLISIONWIDTH,@points[2].y-COLLISIONWIDTH,{x:1,y:1}),
          SquareCollider.new(@points[3].x,@points[3].y-COLLISIONWIDTH,{x:-1,y:1}),
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
    #args.outputs.solids << [@x + x_offset, @y, @block_size * 2 - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
    args.outputs.solids <<{x: (@x + x_offset), y: (@y), w: (@block_size * 2 - @block_offset), h: (@block_size * 2 - @block_offset), r: @r , g: @g , b: @b }
    #args.outputs.solids << @bold.append([255,0,0])
    args.outputs.labels << [@x + x_offset + (@block_size * 2 - @block_offset)/2, (@y) + (@block_size * 2 - @block_offset)/2, @count.to_s]

   end

   def update args
     didHit = false
     for b in args.state.balls
       if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
         didSquare = false
         for s in @squareColliders
           if (s.collision?(args, b))
             didSquare = true
             didHit = true
             s.collide(args, b)
           end
         end
         if (didSquare == false)
           for c in @colliders
             #puts args.state.ball.velocity
             if c.collision?(args, b.getPoints(args),b)
               c.collide args, b
               didHit = true
             end
           end
         end
       end
     end
     if (didHit)
       @count=@count-1
       if (@count == 0)
         args.state.squares.delete(self)
       end
     end
   end #end update
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

        @count = rand(MAX_COUNT)+1


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
          @squareColliders = [
            SquareCollider.new(points[0].x,points[0].y,{x:-1,y:-1}),
            SquareCollider.new(points[1].x-COLLISIONWIDTH,points[1].y,{x:1,y:-1}),
            SquareCollider.new(points[2].x,points[2].y-COLLISIONWIDTH,{x:1,y:-1}),
            SquareCollider.new(points[3].x-COLLISIONWIDTH,points[3].y,{x:1,y:-1}),
            SquareCollider.new(points[4].x-COLLISIONWIDTH,points[4].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[5].x,points[5].y,{x:1,y:1}),
            SquareCollider.new(points[6].x-COLLISIONWIDTH,points[6].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[7].x,points[7].y-COLLISIONWIDTH,{x:-1,y:1}),
          ]
          @colliders = [
            LinearCollider.new(points[0],points[1], :neg),
            LinearCollider.new(points[1],points[2], :neg),
            LinearCollider.new(points[2],points[3], :neg),
            LinearCollider.new(points[3],points[4], :neg),
            LinearCollider.new(points[4],points[5], :pos),
            LinearCollider.new(points[5],points[6], :neg),
            LinearCollider.new(points[6],points[7], :pos),
            LinearCollider.new(points[0],points[7], :pos)
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
          @squareColliders = [
            SquareCollider.new(points[0].x,points[0].y,{x:-1,y:-1}),
            SquareCollider.new(points[1].x-COLLISIONWIDTH,points[1].y,{x:1,y:-1}),
            SquareCollider.new(points[2].x-COLLISIONWIDTH,points[2].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[3].x,points[3].y,{x:1,y:1}),
            SquareCollider.new(points[4].x-COLLISIONWIDTH,points[4].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[5].x,points[5].y-COLLISIONWIDTH,{x:-1,y:1}),
            SquareCollider.new(points[6].x-COLLISIONWIDTH,points[6].y,{x:-1,y:1}),
            SquareCollider.new(points[7].x,points[7].y-COLLISIONWIDTH,{x:-1,y:1}),
          ]
          @colliders = [
            LinearCollider.new(points[0],points[1], :neg),
            LinearCollider.new(points[1],points[2], :neg),
            LinearCollider.new(points[2],points[3], :pos),
            LinearCollider.new(points[3],points[4], :neg),
            LinearCollider.new(points[4],points[5], :pos),
            LinearCollider.new(points[5],points[6], :neg),
            LinearCollider.new(points[6],points[7], :pos),
            LinearCollider.new(points[0],points[7], :pos)
          ]
      elsif @orientation == :left
          #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2 - @block_offset, @block_size - @block_offset, @r, @g, @b]
          xh = @x + x_offset
          #points = [
            #{x:@x + x_offset, y:@y},
            #{x:(@x + x_offset)+(@block_size - @block_offset), y:@y},
            #{x:(@x + x_offset)+(@block_size - @block_offset),y:@y + @block_size},
            #{x:(@x + x_offset)+ @block_size * 2,y:@y + @block_size},
            #{x:(@x + x_offset)+ @block_size * 2,y:@y + @block_size+@block_size},
            #{x:(@x + x_offset)+(@block_size - @block_offset),y:@y + @block_size+@block_size},
            #{x:(@x + x_offset)+(@block_size - @block_offset), y:@y+ @block_size * 3 - @block_offset},
            #{x:@x + x_offset , y:@y+ @block_size * 3 - @block_offset}
          #]
          points = [
            {x:@x + x_offset + @block_size, y:@y},
            {x:@x + x_offset + @block_size + (@block_size - @block_offset), y:@y},
            {x:@x + x_offset + @block_size + (@block_size - @block_offset),y:@y+@block_size*3- @block_offset},
            {x:@x + x_offset + @block_size, y:@y+@block_size*3- @block_offset},
            {x:@x + x_offset+@block_size, y:@y+@block_size*2- @block_offset},
            {x:@x + x_offset, y:@y+@block_size*2- @block_offset},
            {x:@x + x_offset, y:@y+@block_size},
            {x:@x + x_offset+@block_size, y:@y+@block_size}
          ]
          @squareColliders = [
            SquareCollider.new(points[0].x,points[0].y,{x:-1,y:-1}),
            SquareCollider.new(points[1].x-COLLISIONWIDTH,points[1].y,{x:1,y:-1}),
            SquareCollider.new(points[2].x-COLLISIONWIDTH,points[2].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[3].x,points[3].y-COLLISIONWIDTH,{x:-1,y:1}),
            SquareCollider.new(points[4].x-COLLISIONWIDTH,points[4].y,{x:-1,y:1}),
            SquareCollider.new(points[5].x,points[5].y-COLLISIONWIDTH,{x:-1,y:1}),
            SquareCollider.new(points[6].x,points[6].y,{x:-1,y:-1}),
            SquareCollider.new(points[7].x-COLLISIONWIDTH,points[7].y-COLLISIONWIDTH,{x:-1,y:-1}),
          ]
          @colliders = [
            LinearCollider.new(points[0],points[1], :neg),
            LinearCollider.new(points[1],points[2], :neg),
            LinearCollider.new(points[2],points[3], :pos),
            LinearCollider.new(points[3],points[4], :neg),
            LinearCollider.new(points[4],points[5], :pos),
            LinearCollider.new(points[5],points[6], :neg),
            LinearCollider.new(points[6],points[7], :neg),
            LinearCollider.new(points[0],points[7], :pos)
          ]
      elsif @orientation == :down
          #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
          #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]

          points = [
            {x:@x + x_offset, y:@y+(@block_size*2)-@block_offset},
            {x:@x + x_offset+ @block_size*3-@block_offset, y:@y+(@block_size*2)-@block_offset},
            {x:@x + x_offset+ @block_size*3-@block_offset, y:@y+(@block_size)},
            {x:@x + x_offset+ @block_size*2-@block_offset, y:@y+(@block_size)},
            {x:@x + x_offset+ @block_size*2-@block_offset, y:@y},#
            {x:@x + x_offset+ @block_size, y:@y},#
            {x:@x + x_offset + @block_size, y:@y+(@block_size)},
            {x:@x + x_offset, y:@y+(@block_size)}
          ]
          @squareColliders = [
            SquareCollider.new(points[0].x,points[0].y-COLLISIONWIDTH,{x:-1,y:1}),
            SquareCollider.new(points[1].x-COLLISIONWIDTH,points[1].y-COLLISIONWIDTH,{x:1,y:1}),
            SquareCollider.new(points[2].x-COLLISIONWIDTH,points[2].y,{x:1,y:-1}),
            SquareCollider.new(points[3].x,points[3].y-COLLISIONWIDTH,{x:1,y:-1}),
            SquareCollider.new(points[4].x-COLLISIONWIDTH,points[4].y,{x:1,y:-1}),
            SquareCollider.new(points[5].x,points[5].y,{x:-1,y:-1}),
            SquareCollider.new(points[6].x-COLLISIONWIDTH,points[6].y-COLLISIONWIDTH,{x:-1,y:-1}),
            SquareCollider.new(points[7].x,points[7].y,{x:-1,y:-1}),
          ]
          @colliders = [
            LinearCollider.new(points[0],points[1], :pos),
            LinearCollider.new(points[1],points[2], :pos),
            LinearCollider.new(points[2],points[3], :neg),
            LinearCollider.new(points[3],points[4], :pos),
            LinearCollider.new(points[4],points[5], :neg),
            LinearCollider.new(points[5],points[6], :pos),
            LinearCollider.new(points[6],points[7], :neg),
            LinearCollider.new(points[0],points[7], :neg)
          ]
      end
      return points
    end

    def draw(args)
        #Offset the coordinates to the edge of the game area
        x_offset = (args.state.board_width + args.grid.w / 8) + (@block_offset / 2)

        if @orientation == :right
            #args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset), y: @y, w: @block_size - @block_offset, h: (@block_size * 3 - @block_offset), r: @r , g: @g, b: @b}
            #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2, @block_size, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset), y: (@y + @block_size), w: (@block_size * 2), h: (@block_size), r: @r , g: @g, b: @b }
        elsif @orientation == :up
            #args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset), y: (@y), w: (@block_size * 3 - @block_offset), h: (@block_size - @block_offset), r: @r , g: @g, b: @b}
            #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size, @block_size * 2, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset + @block_size), y: (@y), w: (@block_size), h: (@block_size * 2), r: @r , g: @g, b: @b}
        elsif @orientation == :left
            #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset + @block_size), y: (@y), w: (@block_size - @block_offset), h: (@block_size * 3 - @block_offset), r: @r , g: @g, b: @b}
            #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 2 - @block_offset, @block_size - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset), y: (@y + @block_size), w: (@block_size * 2 - @block_offset), h: (@block_size - @block_offset), r: @r , g: @g, b: @b}
        elsif @orientation == :down
            #args.outputs.solids << [@x + x_offset, @y + @block_size, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset), y: (@y + @block_size), w: (@block_size * 3 - @block_offset), h: (@block_size - @block_offset), r: @r , g: @g, b: @b}
            #args.outputs.solids << [@x + x_offset + @block_size, @y, @block_size - @block_offset, @block_size * 2 - @block_offset, @r, @g, @b]
            args.outputs.solids << {x: (@x + x_offset + @block_size), y: (@y), w: (@block_size - @block_offset), h: ( @block_size * 2 - @block_offset), r: @r , g: @g, b: @b}
        end

        #psize = 5.0
        #for p in @shapePoints
          #args.outputs.solids << [p.x-psize/2, p.y-psize/2, psize, psize, 0, 0, 0]
        #end
        args.outputs.labels << [@x + x_offset + (@block_size * 2 - @block_offset)/2, (@y) + (@block_size * 2 - @block_offset)/2, @count.to_s]

    end

    def update args
      didHit = false
      for b in args.state.balls
        if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
          didSquare = false
          for s in @squareColliders
            if (s.collision?(args, b))
              didSquare = true
              didHit=true
              s.collide(args, b)
            end
          end
          if (didSquare == false)
            for c in @colliders
              #puts args.state.ball.velocity
              if c.collision?(args, b.getPoints(args), b)
                c.collide args, b
                didHit=true
              end
            end
          end
        end
      end
      if (didHit)
        @count=@count-1
        if (@count == 0)
          args.state.tshapes.delete(self)
        end
      end
    end #end update

end

class Line
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

        @count = rand(MAX_COUNT)+1

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
    end

    def getShapePoints(args)
      points=[]
      x_offset = (args.state.board_width + args.grid.w / 8) + (@block_offset / 2)

      if @orientation == :right
        #args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
        xa =@x + x_offset
        ya =@y
        wa =@block_size * 3 - @block_offset
        ha =(@block_size - @block_offset)
      elsif @orientation == :up
        #args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
        xa =@x + x_offset
        ya =@y
        wa =@block_size - @block_offset
        ha =@block_size * 3 - @block_offset

      elsif @orientation == :left
        #args.outputs.solids << [@x + x_offset, @y, @block_size * 3 - @block_offset, @block_size - @block_offset, @r, @g, @b]
        xa =@x + x_offset
        ya =@y
        wa =@block_size * 3 - @block_offset
        ha =@block_size - @block_offset
      elsif @orientation == :down
        #args.outputs.solids << [@x + x_offset, @y, @block_size - @block_offset, @block_size * 3 - @block_offset, @r, @g, @b]
        xa =@x + x_offset
        ya =@y
        wa =@block_size - @block_offset
        ha =@block_size * 3 - @block_offset
      end
      points = [
        {x: xa, y:ya},
        {x: xa + wa,y:ya},
        {x: xa + wa,y:ya+ha},
        {x: xa, y:ya+ha},
      ]
      @squareColliders = [
        SquareCollider.new(points[0].x,points[0].y,{x:-1,y:-1}),
        SquareCollider.new(points[1].x-COLLISIONWIDTH,points[1].y,{x:1,y:-1}),
        SquareCollider.new(points[2].x-COLLISIONWIDTH,points[2].y-COLLISIONWIDTH,{x:1,y:1}),
        SquareCollider.new(points[3].x,points[3].y-COLLISIONWIDTH,{x:-1,y:1}),
      ]
      @colliders = [
        LinearCollider.new(points[0],points[1], :neg),
        LinearCollider.new(points[1],points[2], :neg),
        LinearCollider.new(points[2],points[3], :pos),
        LinearCollider.new(points[0],points[3], :pos),
      ]
      return points
    end
    def update args
      didHit=false
      for b in args.state.balls
        if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
          didSquare = false
          for s in @squareColliders
            if (s.collision?(args, b))
              didSquare = true
              s.collide(args, b)
              didHit=true
            end
          end
          if (didSquare == false)
            for c in @colliders
              #puts args.state.ball.velocity
              if c.collision?(args, b.getPoints(args),b)
                c.collide args, b
                didHit=true
              end
            end
          end
        end
      end
      if (didHit)
        @count=@count-1
        if (@count == 0)
          args.state.lines.delete(self)
        end
      end
    end #end update

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

        args.outputs.labels << [@x + x_offset + (@block_size * 2 - @block_offset)/2, (@y) + (@block_size * 2 - @block_offset)/2, @count.to_s]

    end
end
