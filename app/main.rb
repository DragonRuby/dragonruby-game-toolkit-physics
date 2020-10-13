INFINITY= 10**10
WIDTH=1280
HEIGHT=720

def init args
  args.state.ballVelocity||= {x: 5, y: 5}
  args.state.ballPosition||= {x: 200, y: 200}
  args.state.ballSize    ||= 20

  args.state.collisionA  ||= {x: 0,   y: 0  }
  args.state.collisionB  ||= {x: 100, y: 100}

  args.state.pointMove ||= :collisionA
end

def wallBounds args
  if args.state.ballPosition.x < 0 || args.state.ballPosition.x+args.state.ballSize > WIDTH
    args.state.ballVelocity.x *= -1
  end
  if args.state.ballPosition.y < 0 || args.state.ballPosition.y+args.state.ballSize > HEIGHT
    args.state.ballVelocity.y *= -1
  end
end

def collisionSlope args
  if (args.state.collisionB.x - args.state.collisionA.x == 0)
    return INFINITY
  end
  return (args.state.collisionB.y - args.state.collisionA.y) / (args.state.collisionB.x - args.state.collisionA.x)
end

def collision? args, points
  collisionWidth = 50
  slope = collisionSlope args
  result = false

  # calculate a vector with a magnitude of (1/2)collisionWidth and a direction perpendicular to the collision line
  vect = {x: args.state.collisionB.x - args.state.collisionA.x, y:args.state.collisionB.y - args.state.collisionA.y}
  mag  = (vect.x**2 + vect.y**2)**0.5
  vect = {y: -1*(vect.x/(mag))*collisionWidth*0.5, x: (vect.y/(mag))*collisionWidth*0.5}

  #four point rectangle
  rpointA = {x:args.state.collisionA.x + vect.x, y:args.state.collisionA.y + vect.y}
  rpointB = {x:args.state.collisionB.x + vect.x, y:args.state.collisionB.y + vect.y}
  rpointC = {x:args.state.collisionB.x - vect.x, y:args.state.collisionB.y - vect.y}
  rpointD = {x:args.state.collisionA.x - vect.x, y:args.state.collisionA.y - vect.y}

  #area of a triangle
  triArea = -> (a,b,c) { ((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))/2.0).abs }

  #if at least on point is in the rectangle then collision? is true - otherwise false
  for point in points
    #Check whether a given point lies inside a rectangle or not:
    #if the sum of the area of traingls, PAB, PBC, PCD, PAD equal the area of the rec, then an intersection has occured
    areaRec =  triArea.call(rpointA, rpointB, rpointC)+triArea.call(rpointA, rpointC, rpointD)
    areaSum = [
      triArea.call(point, rpointA, rpointB),triArea.call(point, rpointB, rpointC),
      triArea.call(point, rpointC, rpointD),triArea.call(point, rpointA, rpointD)
    ].inject(0){|sum,x| sum + x }
    e = 0.0001 #allow for minor error
    if areaRec>= areaSum-e and areaRec<= areaSum+e
      result = true
      #return true
      break
    end
  end
  #return false

  args.outputs.lines <<  [rpointA.x, rpointA.y, rpointB.x, rpointB.y,     255, 000, 000]
  args.outputs.lines <<  [rpointC.x, rpointC.y, rpointD.x, rpointD.y,     255, 255, 000]
  return result

end

#see documentation
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
  slope = collisionSlope args

  # perpVect: normal vector perpendicular to collision
  perpVect = {x: args.state.collisionB.x - args.state.collisionA.x, y:args.state.collisionB.y - args.state.collisionA.y}
  mag  = (perpVect.x**2 + perpVect.y**2)**0.5
  perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}
  perpVect = {x: -perpVect.y, y: perpVect.x}
  if perpVect.y > 0 #ensure perpVect points upward
    perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
  end
  previousPosition = {
    x:args.state.ballPosition.x-args.state.ballVelocity.x,
    y:args.state.ballPosition.y-args.state.ballVelocity.y
  }
  yInterc = args.state.collisionA.y + -slope*args.state.collisionA.x
  if previousPosition.y < slope*previousPosition.x + yInterc #check if ball is bellow or above the collider to determine if perpVect is - or +
    perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
  end

  velocityMag = (args.state.ballVelocity.x**2 + args.state.ballVelocity.y**2)**0.5
  theta_ball=Math.atan2(args.state.ballVelocity.y,args.state.ballVelocity.x) #the angle of the ball's velocity
  theta_repel=Math.atan2(perpVect.y,perpVect.x) #the angle of the repelling force(perpVect)

  fbx = velocityMag * Math.cos(theta_ball) #the x component of the ball's velocity
  fby = velocityMag * Math.sin(theta_ball) #the y component of the ball's velocity

  #the magnitude of the repelling force
  repelMag = getRepelMagnitude(fbx, fby, perpVect.x, perpVect.y, (args.state.ballVelocity.x**2 + args.state.ballVelocity.y**2)**0.5)
  frx = repelMag* Math.cos(theta_repel) #the x component of the repel's velocity | magnitude is set to twice of fbx
  fry = repelMag* Math.sin(theta_repel) #the y component of the repel's velocity | magnitude is set to twice of fby

  fsumx = fbx+frx #sum of x forces
  fsumy = fby+fry #sum of y forces
  fr = velocityMag#fr is the resulting magnitude
  thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
  xnew = fr*Math.cos(thetaNew)#resulting x velocity
  ynew = fr*Math.sin(thetaNew)#resulting y velocity
  args.state.ballVelocity = {x: xnew, y: ynew}
end

def tick args
  init args

  wallBounds args
  args.state.ballPosition.x += args.state.ballVelocity.x
  args.state.ballPosition.y += args.state.ballVelocity.y

  ballPoints = [
    {x: args.state.ballPosition.x, y: args.state.ballPosition.y},
    {x: args.state.ballPosition.x+args.state.ballSize, y: args.state.ballPosition.y},
    {x: args.state.ballPosition.x, y: args.state.ballPosition.y+args.state.ballSize},
    {x: args.state.ballPosition.x+args.state.ballSize, y: args.state.ballPosition.y+args.state.ballSize}
  ]
  if collision? args, ballPoints
    collide args
  end

  args.outputs.lines <<  [args.state.collisionA.x,  args.state.collisionA.y, args.state.collisionB.x, args.state.collisionB.y]
  args.outputs.solids << [args.state.ballPosition.x,args.state.ballPosition.y,args.state.ballSize,args.state.ballSize, 255,0,0]


  if args.inputs.mouse.click
    if args.state.pointMove == :collisionA
      args.state.collisionA = {x: args.inputs.mouse.click.point.x, y: args.inputs.mouse.click.point.y}
      args.state.pointMove = :collisionB
    else
      args.state.collisionB= {x: args.inputs.mouse.click.point.x, y: args.inputs.mouse.click.point.y}
      args.state.pointMove = :collisionA
    end
  end
end
