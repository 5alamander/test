BattleLayer = cc.Layer.extend
	sprite: null
	ctor: ->
		@_super()
		that = this
		@_initBattleTimer()

		@_loadRes()

		@_create6Position()

		size = cc.winSize
		closeItem = new cc.MenuItemImage(
			res.CloseNormal_png
			res.CloseSelected_png
			() ->
#				myDirector.welcome()
				myDirector.battle()
			this
		)
		closeItem.attr
			x: size.width - 20
			y: 20
			anchorX: 0.5
			anchorY: 0.5

		menu = new cc.Menu closeItem
		menu.x = 0
		menu.y = 0
		@addChild menu, 1

		helloLabel = new cc.LabelTTF("妙蛙草藏在哪(⊙_⊙)？", "Arial", 30)
		helloLabel.x = size.width / 2;
		helloLabel.y = 0;
		@addChild helloLabel, 5
		@getScheduler().setTimeScale(1)
		gs(helloLabel).bindTimer()

		@xy = new cc.LabelTTF("单击鼠标扔球", "arial", 16)
		@addChild @xy, 100

		this.stage = new cc.Sprite(res.stage)
		@stage.attr({
			x:size.width/2
			y:size.height/2
		})
#		@addChild(@stage, 0)

#		### ###
#		for i in [0..1]
#			temp = new PokemonCard pokemonDataArray[3*i],1
#			@addChild temp, 5
#			gs.playerArray.push temp
#			gs.battleArray.push temp
#		gs.battleArray[1]._isTempUse = 1
		@addPokemon = (n) ->
			if pokemonDataArray[n-1]? then t = pokemonDataArray[n-1]
			else t = {id: n}
			temp = new PokemonCard t, 1
			that.addChild temp, 5
			gs.playerArray.push temp
			gs.battleArray.push temp
			return temp
		@addPokemon(14)
		@addPokemon(15)


		@particle = new cc.ParticleSystem("res/particles_effect/attack_fire.plist")
		gs(@particle).bindTimer(true)
		@particle.stopSystem()

#		this.stage.addChild @particle, 10
#		this.stage.setVisible(false)
		@addChild @particle, 10



		mouseCheck = cc.EventListener.create(
			event: cc.EventListener.MOUSE
			onMouseMove: (event) ->
				p = event.getLocation()
				x = p.x|0
				y = p.y|0
				that.xy.setString(x + " " + y)
				that.xy.x = p.x
				that.xy.y = p.y

		)
		cc.eventManager.addListener(mouseCheck, this)

		eventListener = cc.EventListener.create(
			event: cc.EventListener.TOUCH_ONE_BY_ONE
			onTouchBegan: (event) ->
				that.particle.setPosition event.getLocation()
				that.particle.resetSystem()

				touch = event.getLocation()

				console.log("battleLayer.coffee onTouchBegan (#78): " + "touch");  # TODO:debug
				for t in gs.battleArray
					box = t.getBoundingBox()
					if cc.rectContainsPoint(box, touch)
						that.xy.setString('hit'+touch.x)
						return
				temp = gs.playerArray[0]
				gs.playerArray = gs.playerArray[1...] #todo:pack in remove
				if temp? then temp.testBallAction(event.getLocation())
		)
		cc.eventManager.addListener(eventListener, this)

		helloLabel.runAction(
			cc.spawn(
				cc.moveBy(2.5, cc.p(0, size.height - 40))
				cc.tintTo(2.5, 255, 125, 0)
			)
		)

#		@_scheduler.setTimeScale(0.5)

		###  auto cast ball
		@schedule(
			() ->
				r1 = Math.random() * 170 - 85
				r2 = Math.random() * 170 - 85
				temp = gs.playerArray[0]
				gs.playerArray = gs.playerArray[1...]
				if temp? then temp.testBallAction(cc.p(size.width/2 + r1, size.height/2 + r2))
			,5,20,2
		)###

		@schedule(
			() ->
				rect1 = that.stage.getBoundingBox()
				rect2 = that.particle.getBoundingBox()
				r = cc.rectIntersection(rect1, rect2)
				if r.width is 0 and r.height is 0 then return
				console.log("To Watch: battleLayer.coffee (#123):");  #TODO:path
				console.log(r); #TODO:show details
			,0.02
		)

		return true

	_initBattleTimer: () ->
		gs.battleLayer = this
		defaultSchedule = cc.director.getScheduler()
		@_scheduler = new cc.Scheduler()
		defaultSchedule.scheduleUpdate(@_scheduler, 0, false)
		@_actionManager = new cc.ActionManager()
		@_scheduler.scheduleUpdate(@_actionManager, 0, false)

	_loadRes:() ->
		cc.spriteFrameCache.addSpriteFrames(res.res_plist);
		cc.textureCache.addImage(res.res_png);

	_create6Position: () ->
		size = cc.winSize
		width = size.width
		height = size.height
		r = 0.414 # that is it, no why
		gs.uLoc = [
			cc.p(-0.5*width*r + width/2, 0.5*height*r + height/2)
			cc.p(width/2, 0.5*height*r + height/2)
			cc.p(0.5*width*r + width/2, 0.5*height*r + height/2)]
		gs.dLoc = [
			cc.p(-0.5*width*r + width/2, -0.5*height*r + height/2)
			cc.p(width/2, -0.5*height*r + height/2)
			cc.p(0.5*width*r + width/2, -0.5*height*r + height/2)]
		gs.uhLoc = cc.p(width/2, height + 100)
		gs.dhLoc = cc.p(width/2, -100)
		# test
#		that = this
#		t = (p) ->
#			a = new PokemonCard 1, 1
#			a.attr(x:p.x, y:p.y)
#			that.addChild a, 0
#		t(a) for a in gs.uLoc
#		t(a) for a in gs.dLoc

	showDamage: (loc, n, size) ->
		console.log("battleLayer.coffee showDamage (#181): " + "show");  # TODO:debug
		that = this
		label = new cc.LabelTTF(n.toString(), "Arial", 40)
		if size? then label.setFontSize(size)
		label.setPosition(loc)
		label.setColor(cc.color(255,240,0))
		@addChild(label, 100)
		label.runAction(cc.sequence(
			cc.spawn(
				cc.moveBy(0.5, 0, 70).easing(cc.easeSineOut())
				cc.scaleTo(0.5, 1.3).easing(cc.easeElasticIn())
#				cc.fadeOut(0.5).easing(cc.easeExponentialOut())
			)
			cc.callFunc(() ->
				that.removeChild(label, true)
			)
		))


root = exports ? window
root.BattleLayer = BattleLayer
