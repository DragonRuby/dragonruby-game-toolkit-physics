INFINITY= 10**10

GRAVITY = -0.04

class Bounce
  def initialize
    @xCenter = 100
    @yCenter = 100
    @radius = 20
    @velocity = {x: 4, y: 4}
  end

  def update args
      @xCenter    += @velocity.x
      @yCenter    += @velocity.y
      @velocity.y +=GRAVITY
      alpha=0.3
      if @yCenter-@radius <= 0
        @velocity.y  = (@velocity.y.abs*0.7).abs
        @velocity.x  = (@velocity.x.abs*0.9).abs

        if @velocity.y.abs() < alpha
          @velocity.y=0
        end
        if @velocity.x.abs() < alpha
          @velocity.x=0
        end
      end

      if @xCenter - @radius - 4 > args.grid.right
        @xCenter = 0 -@radius -4
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


def defaults args
  args.state.bounce||=Bounce.new

end

def update args
  args.state.bounce.update args
end

def render args
  args.state.bounce.render args
end


def tick args
  defaults args
  update args
  render args
end
