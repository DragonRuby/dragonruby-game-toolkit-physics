WIDTH = 1280
HEIGHT= 720
INFINITY= 10**100

class Vector2d
  attr_accessor :x, :y

  def initialize x=0, y=0
    @x=x
    @y=y;
  end

  def copy vect
    Vector2d.new(@x, @y)
  end

  def add vect
    Vector2d.new(@x+vect.x,@y+vect.y)
  end
  def sub vect
    Vector2d.new(@x-vect.c, @y-vect.y)
  end
  def mag
    ((@x**2)+(@y**2))**0.5
  end

  def distABS vect
    tmp =  ((vect.x-@x)**2+(vect.y-@y)**2)**0.5
    if (tmp < 0)
      tmp*=-1
    end
    tmp
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

    if @xy.x<0
      collision -1*INFINITY
    elsif @xy.x+@width > WIDTH
      collision INFINITY
    elsif @xy.y < 0
      collision 0
      puts "here"
    elsif @xy.y+@height > HEIGHT
      collision 0
    end


  end

  def render args
    args.outputs.solids << [@xy.x,@xy.y,@width,@height,255,0,255];
    args.outputs.labels << [100,HEIGHT-100,@velocity.x.to_s+" "+@velocity.y.to_s]
    #args.outputs.sprites << [@xy.x,@xy.y,@width,@height,"sprites/ball.png"];
  end

  def rect
    [@xy.x,@xy.y,@width,@height]
  end

  def collision slope
    #TODO atan2 error
    #theta = Math.tan(theta - Math.atan2(@velocity.x,@velocity.x))
    #@velocity=Vector2d.new(Math.cos(theta)*@velocity.mag,Math.sin(theta)*@velocity.mag);
    origin = Vector2d.new(0,0);
    backMag = Vector2d.new(-@velocity.x,-@velocity.y);
    perpSlope = (slope == 0) ? INFINITY : -(1/slope);
    newB = backMag.y + -(perpSlope*backMag.x)
    #y=perpSlopex+newB
    m1=@velocity.y/@velocity.x #TODO x=0
    b1=1

    m2=perpSlope
    b2=newB

    #  ┌    ┐    ┌  ┐                             ┌      ┐
    #M=│m1 1│  N=│b1│ d=1/((-m1)-(-m2))  M^(-1)= d│1 -1  │
    #  │m2 1│    │b2│                             │-m2 m1│
    #  └    ┘    └  ┘                             └      ┘

    #        ┌            ┐            ┌                    ┐
    #M^(-1)= │d       -d  │ (M^(-1))N= │(d*b1)+(-d+b2)      │
    #        │-m2*d   m1*d│            │(-m2*d*b1)+(m1*d*b2)│
    #        └            ┘            └                    ┘
    d = 1/((-m1)+-(-m2))
    #puts "d:" + d.to_s + "  m1:" + m1.to_s + "  m2:" + m2.to_s
    pointThree=Vector2d.new(((d*b1)+(-d+b2)),((-m2*d*b1)+(m1*d*b2)))
    #puts "p3.x:" + pointThree.x.to_s + "  p3.y" + pointThree.y.to_s
    hypotenuse=backMag.mag
    opposite=pointThree.distABS(backMag)
    adjacent=Vector2d.new(0,0).distABS(pointThree)

    #puts "opposite:" + opposite.to_s + "  adjacent:" + adjacent.to_s
    theta = Math.atan2(opposite,adjacent)
    slopetheta =0
    if (slope > 0)
      sx=0.1
      h=Vector2d.new(0,0).distABS(Vector2d.new(sx,slope*sx))
      slopetheta = Math.acos(sx/h);
    elsif(slope < 0)
      sx=0.1
      h=Vector2d.new(0,0).distABS(Vector2d.new(sx,slope*sx))
      slopetheta = Math.acos(sx/h);
    end


    if (@velocity.x>0 && @velocity.y>0) #TO QII
      theta=slopetheta+theta
    elsif (@velocity.x<0 && @velocity.y>0) #TO QI TO Q3
      theta = ((Math::PI-slopetheta)+theta)
      #v2 = Vector2d.new(velocity.mag*Math.cos(theta),velocity.mag*Math.sin(theta))
    elsif (@velocity.x>0 && @velocity.y<0) #TO QIII TO Q1
      theta = -slopetheta+theta
    elsif (@velocity.x<0 && @velocity.y<0) #TO QIV
      theta = (Math::PI+slopetheta-theta)
    end
    @velocity = Vector2d.new(@velocity.mag*Math.cos(theta),@velocity.mag*Math.sin(theta))


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
