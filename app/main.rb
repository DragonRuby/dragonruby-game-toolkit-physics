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
  def initialize
    @xCenter = $args.grid.right/2
    @yCenter = $args.grid.top/2
    @radius = 50
    @clr = {r: 255,g: 0,b: 0}
  end
  def collisionWithBounce? args
    squareDistance = (args.state.bounce.xCenter - @xCenter) * (args.state.bounce.xCenter - @xCenter) + (args.state.bounce.yCenter - @yCenter) * (args.state.bounce.yCenter - @yCenter)
    radiusSum = (args.state.bounce.radius + @radius) * (args.state.bounce.radius + @radius);
    return (squareDistance <= radiusSum)
  end

  def update args
    if collisionWithBounce? args
      @clr = {r: 0,g: 255,b: 0}
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
  end

  if args.inputs.keyboard.key_down.enter
    alpha = 0.03
    args.state.bounce.velocity.y = (args.state.pointB.y - args.state.pointA.y) * alpha
    args.state.bounce.velocity.x = (args.state.pointB.x - args.state.pointA.x) * alpha
    args.state.bounce.xCenter = args.state.pointA.x
    args.state.bounce.yCenter = args.state.pointA.y
  end
end

def render args
  args.state.bounce.render args
  args.state.roundCollision.render args

  if (args.state.pointA != nil && args.state.pointB != nil)
    args.outputs.lines << [  args.state.pointA.x,  args.state.pointA.y, args.state.pointB.x, args.state.pointB.y]
    args.outputs.solids << [args.state.pointB.x-5, args.state.pointB.y-5, 10,10,0,0,0]
  elsif args.state.pointA != nil
    args.outputs.solids << [args.state.pointA.x-5, args.state.pointA.y-5, 10,10,0,0,0]
  end
end


def tick args
  defaults args
  update args
  render args
end
