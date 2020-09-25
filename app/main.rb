WIDTH = 1280
HEIGHT = 720
INFINITY= 10**10


class Vector2d
  attr_accessor :x, :y

  def initialize x=0, y=0
    @x=x
    @y=y
  end

  #returns a vector multiplied by scalar x
  #x [float] scalar
  def mult x
    r = Vector2d.new(0,0)
    r.x=@x*x
    r.y=@y*x
    r
  end

  # vect [Vector2d] vector to copy
  def copy vect
    Vector2d.new(@x, @y)
  end

  #returns a new vector equivalent to this+vect
  #vect [Vector2d] vector to add to self
  def add vect
    Vector2d.new(@x+vect.x,@y+vect.y)
  end

  #returns a new vector equivalent to this-vect
  #vect [Vector2d] vector to subtract to self
  def sub vect
    Vector2d.new(@x-vect.c, @y-vect.y)
  end

  #return the magnitude of the vector
  def mag
    ((@x**2)+(@y**2))**0.5
  end

  #returns a new normalize version of the vector
  def normalize
    Vector2d.new(@x/mag, @y/mag)
  end

  #TODO delet?
  def distABS vect
    (((vect.x-@x)**2+(vect.y-@y)**2)**0.5).abs()
  end
end


class Paddle
  attr_accessor :enabled

  def initialize ()
    @x=WIDTH/2
    @y=100
    @width=100
    @height=20
    @speed=10
    @enabled = true

    @xyCollision = LinearCollider.new([@x,@y+@height],[@x+@width,@y+@height])
  end

  def update args
    @xyCollision.resetPoints([@x,@y+@height],[@x+@width,@y+@height])
    @xyCollision.update args


    args.inputs.keyboard.key_held.left  ||= false
    args.inputs.keyboard.key_held.right  ||= false

    if not (args.inputs.keyboard.key_held.left == args.inputs.keyboard.key_held.right)
      if args.inputs.keyboard.key_held.left && @enabled
        @x-=@speed
      elsif args.inputs.keyboard.key_held.right && @enabled
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

class Ball
  #TODO limit accessors?
  attr_accessor :xy, :width, :height, :velocity


  #@xy [Vector2d] x,y position
  #@velocity [Vector2d] velocity of ball
  def initialize
    @xy = Vector2d.new(WIDTH/2,500)
    @velocity = Vector2d.new(2,-2)
    @width =  20
    @height = 20
  end

  #move the ball according to its velocity
  def update args
    @xy.x+=@velocity.x
    @xy.y+=@velocity.y
  end

  #render the ball to the screen
  def render args
    args.outputs.solids << [@xy.x,@xy.y,@width,@height,255,0,255];
    args.outputs.labels << [20,args.grid.h-50,"velocity: " +@velocity.x.to_s+","+@velocity.y.to_s]
  end

  def rect
    [@xy.x,@xy.y,@width,@height]
  end

end

#The LinearCollider (theoretically) produces collisions upon a line segment defined by two x,y cordinates
class LinearCollider

  #start [Array of length 2] start of the line segment as a x,y cordinate
  #last [Array of length 2] end of the line segment as a x,y cordinate

  #inorder for the LinearCollider to be functional the line segment must be said to have a thickness
  #(as it is unlikly that a colliding object will land exactly on the linesegment)

  #extension defines if the line's thickness extends negatively or positively
  #extension :pos     extends positively
  #extension :neg     extends negatively

  #thickness [float] how thick the line should be (should always be at least as large as the magnitude of the colliding object)
  def initialize (start, last, extension=:neg, thickness=10)
    @x1=start[0]
    @y1=start[1]
    @x2=last[0]
    @y2=last[1]
    @thickness = thickness
    @extension = extension
  end

  def resetPoints(start,last)
      @x1=start[0]
      @y1=start[1]
      @x2=last[0]
      @y2=last[1]
  end

  #TODO: Ugly function
  def slope (extend=false)
    x1_l = (extend) ? @x1 + @thickness*(@extension == :neg ? -1 : 1) : @x1
    y1_l = (extend) ? @y1 + @thickness*(@extension == :neg ? -1 : 1): @y1
    x2_l = (extend) ? @x2 + @thickness*(@extension == :neg ? -1 : 1) : @x2
    y2_l = (extend) ? @y2 + @thickness*(@extension == :neg ? -1 : 1) : @y2

    if (x2_l-x1_l == 0) || (x2_l==x1_l)
      INFINITY
    else
      (y2_l+-y1_l)/(x2_l+-x1_l)
    end
  end

  #TODO: Ugly function
  def intercept (extend=false)
    x1_l = (extend) ? @x1 + @thickness*(@extension == :neg ? -1 : 1) : @x1
    y1_l = (extend) ? @y1 + @thickness*(@extension == :neg ? -1 : 1): @y1
    x2_l = (extend) ? @x2 + @thickness*(@extension == :neg ? -1 : 1) : @x2
    y2_l = (extend) ? @y2 + @thickness*(@extension == :neg ? -1 : 1) : @y2

    if (slope == INFINITY)
      -INFINITY
    elsif slope == -1*INFINITY
      INFINITY
    else
      y1_l+-1.0*(slope(extend)*x1_l)
    end

  end

  def update args

    #each of the four points on the square ball - NOTE simple to extend to a circle
    points=[  [args.state.ball.xy.x,                          args.state.ball.xy.y],
              [args.state.ball.xy.x+args.state.ball.width,    args.state.ball.xy.y],
              [args.state.ball.xy.x,                          args.state.ball.xy.y+args.state.ball.height],
              [args.state.ball.xy.x+args.state.ball.width,    args.state.ball.xy.y + args.state.ball.height]
            ]

    #for each point p in points
    for p in points
      bx = p[0]
      by = p[1]

      #test if a collision has occurred
      isCollision = false
      if (slope() ==  INFINITY) #INFINITY slop breaks down when trying to determin collision, ergo it requires a special test
        if (bx >= [@x1,@x2].min+(@extension == :pos ? -@thickness : 0) &&
            bx <= [@x1,@x2].max+(@extension == :neg ? @thickness : 0) &&
            by >= [@y1,@y2].min && by <= [@y1,@y2].max)
          isCollision=true
        end
      else #if slop is not INFINITY
        #TODO: this if statement is ugly and can be simplifyed.
        if (@extension == :neg && (by <= slope()*bx+intercept() && by >= bx*slope(true)+intercept(true)))||
          ((@extension == :pos &&(by >= slope()*bx+intercept() && by <= bx*slope(true)+intercept(true))))
          if (bx >= [@x1,@x2].min &&
             bx <= [@x1,@x2].max &&
             by >= [@y1,@y2].min+(@extension == :neg ? -@thickness : 0) && by <= [@y1,@y2].max+(@extension == :pos ? @thickness : 0))
           isCollision=true
          end
        end
      end

      #isCollision.md has more information on this section
      #TODO: section can certainly be simplifyed
      if (isCollision)
        u = Vector2d.new(1.0,((slope==0) ? INFINITY : -1/slope)*1.0).normalize #normal perpendicular (to line segment) vector
        #the vector with the repeling force can be u or -u depending of where the ball was coming from in relation to the line segment
        previousBallPosition=Vector2d.new(bx-args.state.ball.velocity.x,by-args.state.ball.velocity.y)
        vectorRepel = (previousBallPosition.y > slope()*previousBallPosition.x+intercept()) ? (u.mult(1)) : (u.mult(-1))
        if (slope == INFINITY) #slope INFINITY breaks down in the above test, ergo it requires a custom test
          vectorRepel = (previousBallPosition.x > @x1) ? (u.mult(1)) : (u.mult(-1))
        end
        #vectorRepel now has the repeling force

        mag = args.state.ball.velocity.mag
        theta_ball=Math.atan2(args.state.ball.velocity.y,args.state.ball.velocity.x) #the angle of the ball's velocity
        theta_repel=Math.atan2(vectorRepel.y,vectorRepel.x) #the angle of the repeling force
        fbx = mag * Math.cos(theta_ball) #the x component of the ball's velocity
        fby = mag * Math.sin(theta_ball) #the y component of the ball's velocity

        frx = (fbx*2).abs * Math.cos(theta_repel) #the x component of the ball's velocity | magnitude is set to twice of fbx
        fry = (fby*2).abs * Math.sin(theta_repel) #the y component of the ball's velocity | magnitude is set to twice of fby

        fsumx = fbx+frx #sum of x forces
        fsumy = fby+fry #sum of y forces
        fr = (fsumx**2 + fsumy**2)**0.5 #fr is the resulting magnitude
        thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
        xnew = fr*Math.cos(thetaNew) #resulting x velocity
        ynew = fr*Math.sin(thetaNew) #resulting y velocity

        args.state.ball.velocity = Vector2d.new(xnew,ynew)
        break #no need to check the other points
      else
        #by <= slope()*bx+intercept && by >= slope(true)*bx+intercept(true)))
      end
    end
  end
end

#Method to init default values
def defaults args
  args.state.game_board ||= [(args.grid.w / 2 - args.grid.w / 4), 0, (args.grid.w / 2), args.grid.h]
  args.state.bricks ||= []
  args.state.num_bricks ||= 0
  args.state.game_over_at ||= 0
end

#Render loop
def render args
  render_instructions args
  render_board args
  render_bricks args
end

begin :render_methods

  #Method to display the instructions of the game
  def render_instructions args
    return if args.state.key_event_occurred
    if args.inputs.mouse.click ||
      args.inputs.keyboard.directional_vector ||
      args.inputs.keyboard.key_down.enter ||
      args.inputs.keyboard.key_down.space ||
      args.inputs.keyboard.key_down.escape
      args.state.key_event_occurred = true
    end

    args.outputs.labels << [225, args.grid.h - 30, "S and D to move the paddle left and right",  0, 1]
  end

  def render_board args
    args.outputs.borders << args.state.game_board
  end

  def render_bricks args
    args.outputs.solids << args.state.bricks.map(&:rect)
  end
end

#Calls all methods necessary for performing calculations
def calc args
  add_bricks args
  calc_collision args
  reset_game args

  #If 60 frames have passed since the game ended, restart the game
  if args.state.game_over_at != 0 && args.state.game_over_at.elapsed_time == 60
    args.state.ball = Ball.new
    args.state.paddle = Paddle.new

    args.state.bricks = []
    args.state.colliders = []
    args.state.num_bricks = 0
  end
end

begin :calc_methods
  def add_bricks args
    return if args.state.num_bricks >= 40

    #Width of the game board is 640px
    brick_width = (args.grid.w / 2) / 10
    brick_height = brick_width / 2

    (4).map_with_index do |y|
      #Make a box that is 10 bricks wide and 4 bricks tall
      args.state.bricks += (10).map_with_index do |x| 
        args.state.new_entity(:brick) do |b|
          b.x = x * brick_width + (args.grid.w / 2 - args.grid.w / 4)
          b.y = args.grid.h - ((y + 1) * brick_height)
          b.rect = [b.x + 1, b.y - 1, brick_width - 2, brick_height - 2, 135, 135, 135]

          #Add a linear collider to the brick
          b.collider = LinearCollider.new([(b.x+1), (b.y-1)], [(b.x+1 + brick_width-2), (b.y-1)], :neg, (0))
          b.broken = false

          args.state.num_bricks += 1
        end
      end
    end
  end

  def reset_game args
    if args.state.ball.xy.y < 20 && args.state.game_over_at.elapsed_time > 60
      #Freeze the ball
      args.state.ball.velocity.x = 0
      args.state.ball.velocity.y = 0
      #Freeze the paddle
      args.state.paddle.enabled = false

      args.state.game_over_at = args.state.tick_count
    end

    if args.state.game_over_at.elapsed_time < 60 && args.state.tick_count > 60
      #Display a "Game over" message
      args.outputs.labels << [100, 100, "GAME OVER", 10]
    end
  end

  def calc_collision args
    ball = args.state.ball
    ball_rect = [ball.xy.x, ball.xy.y, 10, 10]

    #Loop through each brick to see if the ball is colliding with it
    args.state.bricks.each do |b|
      if b.rect.intersect_rect?(ball_rect)
        b.broken = true
      end
    end

    args.state.bricks = args.state.bricks.reject(&:broken)
  end
end


$mode = :both
def tick args
  if $mode == :paddle || $mode == :both
      args.state.paddle ||= Paddle.new
      args.state.ball   ||= Ball.new
      args.state.westWall  ||= LinearCollider.new([args.grid.w/4,0],[args.grid.w/4,args.grid.h], :pos)
      args.state.eastWall  ||= LinearCollider.new([3*args.grid.w*0.25,0],[3*args.grid.w*0.25,args.grid.h])
      args.state.southWall ||= LinearCollider.new([0,0],[args.grid.w,0])
      args.state.northWall ||= LinearCollider.new([0,args.grid.h],[args.grid.w,args.grid.h],:pos)

      args.state.paddle.update args
      args.state.ball.update args

      args.state.westWall.update args
      args.state.eastWall.update args
      args.state.southWall.update args
      args.state.northWall.update args

      args.state.paddle.render args
      args.state.ball.render args
  end
  if $mode == :brick || $mode == :both
    defaults args
    render args
    calc args

    args.state.bricks.each do |b|
      b[:collider].update args
    end
  end
end
