VectorEffect = cc.ParticleSystem.extend
	ax: 0
	ay: 0
	vx: 0
	vy: 0
	ctor: (@battle) ->
		@_super(res.fly_decorate)
		@setPositionType(cc.ParticleSystem.TYPE_FREE)
		@battle.addChild(this, 10)
		@setPosition(400, 225)

		@t = 0
		@lt = 2 # life time

	initSpeed: (@vx, @vy, @ax, @ay) ->
		

	update: (dt) ->
		@_super(dt)
		@t += dt
		this.setPosition(@x+@vx, @y+@vy)
		@vx += @ax
		@vy += @ay
		#check bound | or use lifetime
		if @x < -200 or @x > gs.size.width + 200 or @y < -200 or @y > gs.size.height + 200
			@stopSystem()
		if @t > @lt
			@stopSystem()
		if @t > @lt * 1.5
			@removeSelf()
		#check collision

	removeSelf: () ->
		@battle.removeChild(this, true)
		console.log("vectorEffect.coffee removeSelf (#27): " + "delete");  # TODO:debug

root = exports ? window
root.VectorEffect = VectorEffect