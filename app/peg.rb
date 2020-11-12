class Peg
    def initialize(x, y, block_size)
        @x = x
        @y = y
        @block_size = block_size

        @radius = block_size/2.0
        @center = {x: x+block_size/2.0, y: y+block_size/2.0}

        @r = 255
        @g = 0
        @b = 0
   end

  def draw args
    #Offset the coordinates to the edge of the game area
    #args.outputs.solids << [@x, @y, @block_size, @block_size, @r, @g, @b]
    args.outputs.sprites << [
      @x,
      @y,
      @block_size,
      @block_size,
      "sprites/circle-white.png",
      0,
      255,
      @r,    #r
      @g,    #g
      @b   #b
    ]
  end


  def calc args
    if collisionWithBounce? args
      collide args
      @r = 0
      @b = 0
      @g = 255
    else
    end
  end



  def collisionWithBounce? args
    squareDistance = (
      (args.state.ball.center.x - @center.x) *
      (args.state.ball.center.x - @center.x) +
      (args.state.ball.center.y - @center.y) *
      (args.state.ball.center.y - @center.y)
    )
    radiusSum = (
      (args.state.ball.radius + @radius) *
      (args.state.ball.radius + @radius)
    )
    return (squareDistance <= radiusSum)
  end

  def getRepelMagnitude (args, fbx, fby, vrx, vry, ballMag)
    #puts "data:" + fbx.to_s + "|" + fby.to_s + "|" + vrx.to_s + "|" + vry.to_s + "|" + ballMag.to_s

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

    if (args.state.ball.center.x > @center.x)
      return x2*-1
    end
    return x2

    #return r
  end

  def collide args
    normalOfRCCollision = [
      {x: @center.x, y: @center.y},
      {x: args.state.ball.center.x, y: args.state.ball.center.y},
    ]

    normalSlope = (normalOfRCCollision[1].y - normalOfRCCollision[0].y)/(normalOfRCCollision[1].x - normalOfRCCollision[0].x)
    slope = normalSlope**-1.0 * -1
    pointA = {x: args.state.ball.center.x-1, y: -(slope-args.state.ball.center.y)}
    pointB = {x: args.state.ball.center.x+1, y: slope+args.state.ball.center.y}

    perpVect = {x: pointB.x - pointA.x, y:pointB.y - pointA.y}
    mag  = (perpVect.x**2 + perpVect.y**2)**0.5
    perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}
    perpVect = {x: -perpVect.y, y: perpVect.x}
    if perpVect.y > 0 #ensure perpVect points upward
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end
    #perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}

    previousPosition = {
      x:args.state.ball.center.x-args.state.ball.velocity.x,
      y:args.state.ball.center.y-args.state.ball.velocity.y
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

    velocityMag = (args.state.ball.velocity.x**2 + args.state.ball.velocity.y**2)**0.5
    theta_ball=Math.atan2(args.state.ball.velocity.y,args.state.ball.velocity.x) #the angle of the ball's velocity
    theta_repel=Math.atan2(args.state.ball.center.y,args.state.ball.center.x) #the angle of the repelling force(perpVect)

    fbx = velocityMag * Math.cos(theta_ball) #the x component of the ball's velocity
    fby = velocityMag * Math.sin(theta_ball) #the y component of the ball's velocity
    repelMag = getRepelMagnitude(args, fbx, fby, perpVect.x, perpVect.y, (args.state.ball.velocity.x**2 + args.state.ball.velocity.y**2)**0.5)
    frx = repelMag* Math.cos(theta_repel) #the x component of the repel's velocity | magnitude is set to twice of fbx
    fry = repelMag* Math.sin(theta_repel) #the y component of the repel's velocity | magnitude is set to twice of fby

    fsumx = fbx+frx #sum of x forces
    fsumy = fby+fry #sum of y forces
    fr = velocityMag#fr is the resulting magnitude
    thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
    xnew = fr*Math.cos(thetaNew)#resulting x velocity
    ynew = fr*Math.sin(thetaNew)#resulting y velocity
    if (args.state.ball.center.x >= @center.x)
      xnew=xnew.abs
    end

    args.state.ball.velocity.x = xnew
    if args.state.ball.center.y > @center.y
      args.state.ball.velocity.y = ynew + GRAVITY * 0.01
    else
      args.state.ball.velocity.y = ynew - GRAVITY * 0.01
    end

    args.state.ball.center.x+= args.state.ball.velocity.x
    args.state.ball.center.x+= args.state.ball.velocity.y

  end


end
