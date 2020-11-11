INFINITY= 10**10

GRAVITY = -0.08

class Bounce
  attr_accessor :velocity, :xCenter, :yCenter, :radius
  def initialize
    @xCenter = 100
    @yCenter = 100
    @radius = 20
    @velocity = {x: 2, y: 2}
  end

  def update args
      @xCenter    += @velocity.x
      @yCenter    += @velocity.y
      @velocity.y +=GRAVITY
      alpha=0.2
      if @yCenter-@radius <= 0
        @velocity.y  = (@velocity.y.abs*0.7).abs
        @velocity.x  = (@velocity.x.abs*0.9).abs * ((@velocity.x < 0) ? -1 : 1)

        if @velocity.y.abs() < alpha
          @velocity.y=0
        end
        if @velocity.x.abs() < alpha
          @velocity.x=0
        end
      end

      if @xCenter > args.grid.right+@radius*2
        @xCenter = 0-@radius
      elsif @xCenter< 0-@radius*2
        @xCenter = args.grid.right + @radius
      end
  end

  def render args
    args.outputs.sprites << [
      @xCenter-@radius,
      @yCenter-@radius,
      @radius*2,
      @radius*2,
      "sprites/circle-white.png",
      0,
      255,
      0, #r
      0,   #g
      255    #b
    ]
    args.outputs.labels << [100, 100, @velocity.x.to_s + " " + @velocity.y.to_s]
  end
end

class RoundCollision
  attr_accessor :didLines
  def initialize
    @xCenter = $args.grid.right/2
    @yCenter = $args.grid.top/2
    @radius = 50
    @clr = {r: 255,g: 0,b: 0}

    @didLines = false
  end
  def collisionWithBounce? args
    squareDistance = (args.state.bounce.xCenter - @xCenter) * (args.state.bounce.xCenter - @xCenter) + (args.state.bounce.yCenter - @yCenter) * (args.state.bounce.yCenter - @yCenter)
    radiusSum = (args.state.bounce.radius + @radius) * (args.state.bounce.radius + @radius);
    return (squareDistance <= radiusSum)
  end

  def getRepelMagnitude (fbx, fby, vrx, vry, ballMag)
    a = fbx ; b = vrx ; c = fby
    d = vry ; e = ballMag
    if b**2 + d**2 == 0
      #unexpected
    end
    x1 = (-a*b+-c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 + d**2 - a**2 * d**2)**0.5)/(b**2 + d**2)
    x2 = -((a*b + c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 * d**2 - a**2 * d**2)**0.5)/(b**2 + d**2))
    err = 0.00001
    o = ((fbx + x1*vrx)**2 + (fby + x1*vry)**2 ) ** 0.5
    p = ((fbx + x2*vrx)**2 + (fby + x2*vry)**2 ) ** 0.5
    r = 0
    if (ballMag >= o-err and ballMag <= o+err)
      r = x1
    elsif (ballMag >= p-err and ballMag <= p+err)
      r = x2
    else
      #unexpected
    end
    return r
  end

  def collide args
    normalOfRCCollision = [
      {x: @xCenter, y: @yCenter},
      {x: args.state.bounce.xCenter, y: args.state.bounce.yCenter},
    ]

    normalSlope = (normalOfRCCollision[1].y - normalOfRCCollision[0].y)/(normalOfRCCollision[1].x - normalOfRCCollision[0].x)
    slope = normalSlope**-1.0 * -1
    pointA = {x: args.state.bounce.xCenter-1, y: -(slope-args.state.bounce.yCenter)}
    pointB = {x: args.state.bounce.xCenter+1, y: slope+args.state.bounce.yCenter}


    perpVect = {x: pointB.x - pointA.x, y:pointB.y - pointA.y}
    mag  = (perpVect.x**2 + perpVect.y**2)**0.5
    perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}
    perpVect = {x: -perpVect.y, y: perpVect.x}
    if perpVect.y > 0 #ensure perpVect points upward
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end
    #perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}

    previousPosition = {
      x:args.state.bounce.xCenter-args.state.bounce.velocity.x,
      y:args.state.bounce.yCenter-args.state.bounce.velocity.y
    }

    yInterc = pointA.y + -slope*pointA.x
    if slope == INFINITY
      if previousPosition.x < pointA.x
        perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
        yInterc = -INFINITY
      end
    elsif previousPosition.y < slope*previousPosition.x + yInterc #check if ball is bellow or above the collider to determine if perpVect is - or +
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end

    velocityMag = (args.state.bounce.velocity.x**2 + args.state.bounce.velocity.y**2)**0.5
    theta_ball=Math.atan2(args.state.bounce.velocity.y,args.state.bounce.velocity.x) #the angle of the ball's velocity
    theta_repel=Math.atan2(args.state.bounce.yCenter,args.state.bounce.xCenter) #the angle of the repelling force(perpVect)

    fbx = velocityMag * Math.cos(theta_ball) #the x component of the ball's velocity
    fby = velocityMag * Math.sin(theta_ball) #the y component of the ball's velocity

    repelMag = getRepelMagnitude(fbx, fby, perpVect.x, perpVect.y, (args.state.bounce.velocity.x**2 + args.state.bounce.velocity.y**2)**0.5)
    frx = repelMag* Math.cos(theta_repel) #the x component of the repel's velocity | magnitude is set to twice of fbx
    fry = repelMag* Math.sin(theta_repel) #the y component of the repel's velocity | magnitude is set to twice of fby

    fsumx = fbx+frx #sum of x forces
    fsumy = fby+fry #sum of y forces
    fr = velocityMag#fr is the resulting magnitude
    thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
    xnew = fr*Math.cos(thetaNew)#resulting x velocity
    ynew = fr*Math.sin(thetaNew)#resulting y velocity
    if (args.state.bounce.xCenter >= @xCenter)
      xnew=xnew.abs
    end
    args.state.bounce.velocity.x = xnew
    args.state.bounce.velocity.y = ynew * GRAVITY.abs*4
    args.state.bounce.xCenter+= args.state.bounce.velocity.x
    args.state.bounce.yCenter+= args.state.bounce.velocity.y

    @didLines = true
  end

  def update args
    if collisionWithBounce? args
      @clr = {r: 0,g: 255,b: 0}
      collide args
    else
      @clr = {r: 255,g: 0,b: 0}
    end
  end
  def render args
    args.outputs.sprites << [
      @xCenter-@radius,
      @yCenter-@radius,
      @radius*2,
      @radius*2,
      "sprites/circle-white.png",
      0,
      255,
      @clr.r, #r
      @clr.g,   #g
      @clr.b    #b
    ]
  end
end


def defaults args
  args.state.bounce||=Bounce.new
  args.state.roundCollision||=RoundCollision.new
  args.state.pointA||=nil
  args.state.pointB||=nil
end

def update args
  args.state.bounce.update args
  args.state.roundCollision.update args

  p = args.inputs.mouse.click
  if (p != nil)
    if args.state.pointA == nil
      args.state.pointA = p
    elsif args.state.pointB == nil
      args.state.pointB = p
    end
  end

  if args.inputs.keyboard.key_down.r
    args.state.pointA = nil
    args.state.pointB = nil
    args.state.roundCollision.didLines=false
  end

  if args.inputs.keyboard.key_down.enter
    alpha = 0.03
    args.state.bounce.velocity.y = (args.state.pointB.y - args.state.pointA.y) * alpha
    args.state.bounce.velocity.x = (args.state.pointB.x - args.state.pointA.x) * alpha
    args.state.bounce.xCenter = args.state.pointA.x
    args.state.bounce.yCenter = args.state.pointA.y
  end
end

$lines = []
$solids = []

def render args
  args.state.bounce.render args
  args.state.roundCollision.render args

  if (args.state.pointA != nil && args.state.pointB != nil)
    args.outputs.lines << [  args.state.pointA.x,  args.state.pointA.y, args.state.pointB.x, args.state.pointB.y]
    args.outputs.solids << [args.state.pointB.x-5, args.state.pointB.y-5, 10,10,0,0,0]
  elsif args.state.pointA != nil
    args.outputs.solids << [args.state.pointA.x-5, args.state.pointA.y-5, 10,10,0,0,0]
  end

  for l in $lines
    args.outputs.lines << l
  end

  for s in $solids
    args.outputs.solids << s
  end
end


def tick args
  defaults args
  update args
  render args
end
