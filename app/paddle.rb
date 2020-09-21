class Paddle
  def initialize ()
    @x=WIDTH/2
    @y=100
    @width=100
    @height=20
    @speed=10

    @xyCollision = LinearCollider.new([@x,@y+@height],[@x+@width,@y+@height])
  end

  def update args
    @xyCollision.resetPoints([@x,@y+@height],[@x+@width,@y+@height])
    @xyCollision.update args


    args.inputs.keyboard.key_held.left  ||= false
    args.inputs.keyboard.key_held.right  ||= false

    if not (args.inputs.keyboard.key_held.left == args.inputs.keyboard.key_held.right)
      if args.inputs.keyboard.key_held.left
        @x-=@speed
      else
        @x+=@speed
      end
    end

    xmin =WIDTH/4
    xmax = 3*(WIDTH/4)
    @x = (@x+@width > xmax) ? xmax-@width : (@x<xmin) ? xmin : @x;
  end

  def render args
    args.outputs.solids << [@x,@y,@width,@height,255,0,0];
  end

  def rect
    [@x, @y, @width, @height]
  end
end
