WIDTH = 1280
HEIGHT= 720

class Vector2d
  attr_accessor :x, :y

  def initialize x=0, y=0
    @x=x
    @y=y;
  end

  def add vect
    Vector2d.new(@x+vect.x,@y+vect.y)
  end
  def mag
    ((@x**2)+(@y**2))**0.5
  end

  def degree slope

  end
end

class Paddle
  def initialize ()
    @x=10
    @y=100
    @width=100
    @height=20
    @speed=10
  end

  def picoll
    Math::PI/2
  end

  def update args
    args.inputs.keyboard.key_held.left ||= false
    args.inputs.keyboard.key_held.right  ||= false

    if not (args.inputs.keyboard.key_held.left == args.inputs.keyboard.key_held.right)
      if args.inputs.keyboard.key_held.left
        @x-=@speed
      else
        @x+=@speed
      end
    end

    @x = (@x+@width > WIDTH) ? WIDTH-@width : (@x<0) ? 0 : @x;
  end

  def render args
    args.outputs.solids << [@x,@y,@width,@height,255,0,0];
  end

  def rect
    [@x, @y, @width, @height]
  end
end

class Ball
  def initialize
    @xy = Vector2d.new(100,500)
    @velocity = Vector2d.new(2,-2)
    @width =  100
    @height = 100

  end

  def update args
    @xy=@xy.add(@velocity)

    mode=1
    if (@velocity.x < 0 && @velocity.y > 0)
      mode=-(1/4)
    elsif (@velocity.x < 0 && @velocity.y < 0)
      mode=(1/4)+1
    end

    if rect.intersect_rect?(args.state.paddle.rect)
      args.state.ball.collision((Math::PI/2)*mode)
    elsif @xy.y + @height > HEIGHT
      @xy.y = HEIGHT-@height
      args.state.ball.collision(Math::PI*mode)
    elsif @xy.y < 0
      @xy.y = 0
      args.state.ball.collision((Math::PI/2)*mode)
    elsif @xy.x + @width > WIDTH
      @xy.x = WIDTH-@width
      args.state.ball.collision(((Math::PI/4))*-1*mode)
    elsif @xy.x < 0
      @xy.x = 0
      args.state.ball.collision(((Math::PI/4))*mode)
    end

    sstr = "x:"+ @velocity.x.to_s + "   y:" +  @velocity.y.to_s

    args.outputs.labels << [10,HEIGHT-100,sstr]

  end

  def render args
    args.outputs.solids << [@xy.x,@xy.y,@width,@height,255,0,255];
    #args.outputs.sprites << [@xy.x,@xy.y,@width,@height,"sprites/ball.png"];
  end

  def rect
    [@xy.x,@xy.y,@width,@height]
  end

  def collision theta
    #TODO atan2 error
    theta = Math.tan(theta - Math.atan2(@velocity.x,@velocity.x))
    @velocity=Vector2d.new(Math.cos(theta)*@velocity.mag,Math.sin(theta)*@velocity.mag);
  end
end
$t=1

def tick args
  args.state.paddle ||= Paddle.new
  args.state.ball   ||= Ball.new

  args.state.paddle.update args
  args.state.ball.update args

  args.state.paddle.render args
  args.state.ball.render args
end
