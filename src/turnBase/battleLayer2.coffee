BattleLayer2 = cc.Layer.extend
	## kernel ##
	wait: (t) ->
		that = this
		@scheduleOnce(
			() -> that.isWaitCmd--
		, t, @isWaitCmd+'wait'+t) # to hash
	evn_delay: (t) -> # delay aciton
		@wait(t)
	evn_start: (arg...) ->
		console.log("battleLayer2.coffee defaultAction (#201): " + 'default start Action');  # TODO:debug
		@wait(1)
	evn_log: (arg...) ->
		console.log 'log:' + arg
		@wait(2)
	evn_open: (n, m) ->
		console.log 'open' + n + m
		temp = gs.battleArray[n*3+m]
		temp.testBallAction(temp.getPosition())
		@wait(0.5)
	evn_attack: (n) ->
		temp = gs.battleArray[n]
		temp.attack()
		@wait(3)
	evn_showDamage: (n) ->
		temp = gs.battleArray[n]
		@showDamage(temp.getPosition(), 999)
		@wait(0.5)
	evn_evolute: (n, id) ->
		temp = gs.battleArray[n]
		temp.evolute(id)
		@wait(0.5)
	evn_changeLook: (n, m) ->
#		t = pokemonDataArray[id-1] if pokemonDataArray[id-1]?
#		aimLook = new cc.Sprite(gs.getPicture(@pd.id))
		source = gs.battleArray[n]
		aim = gs.battleArray[m]
		source.changeLook(aim)

	evn_showSkill: (pokemon, skill) ->
		console.log("battleLayer2.coffee evn_showSkill (#30): " + 'show some skill');  # TODO:debug
		@wait(0.5)

	evn_whenCall: (pokemon, player, x, y) ->
		console.log("battleLayer2.coffee evn_whenCall (#45): " + 'whenCall log');  # TODO:debug
		card = pokemon.pl
		loc = location(y, x)
		card.callCard(loc)
		@wait(0.5)

	evn_whenRegain: (pokemon, player, x, y) ->
		# get position from (x, y)
		# location(x, y)
		console.log("battleLayer2.coffee evn_whenRegain (#33): " + 'when ragain' + x + y);  # TODO:debug
		console.log(location(x))
		@wait(0.5)
	evn_lightning: (n, m) ->
		if m?
			@evn_lightningStrike(n, m)
			return
		temp = gs.battleArray[n]
		loc = temp.getPosition()
		temp.particleDot(res.lightning_plist, loc)
		@wait(0.1)
	evn_lightningStrike: (n, m) ->
		source = gs.battleArray[n]
		aim = gs.battleArray[m]
		source.lightningStrike(source.getPosition(), aim.getPosition(), aim, 10)
		@wait(0.15)
	evn_attackEnd: (n) ->

		@wait(1)

	cmds:[
#		['open', 0, 2]
#		['open', 0, 0]
		['open', 0, 1]
#		['open', 0, 3]
#		['open', 0, 4]
		['open', 0, 5]
		['delay', 1]
#		['lightning',5]
#		['lightning',5]
#		['lightning',5]
#		['lightningStrike', 5, 1]
#		['lightningStrike', 1, 0]
#		['lightningStrike', 0, 3]
#		['lightningStrike', 3, 1]
#		['lightningStrike', 1, 2]
#		['spawn'
#		 ['lightningStrike', 5, 0]
#		 ['lightningStrike', 0, 1]
#		 ['lightningStrike', 1, 2]]
		['delay', 1]
#		['changeLook', 3, 1]
		['delay', 1]
	]
	pc: 0
	isWaitCmd: 0
	isRunCmd: false # the opposite is isWaitCmd
	myEval: (exp) ->
		if exp[0] is 'spawn'
			@myEval(t) for t in exp[1..]
		else
			@isWaitCmd++
			unless @['evn_' + exp[0]]? then throw 'no such evn_ function'
			@['evn_' + exp[0]].apply(@, exp[1..])
	kernelUpdate: () ->
#		console.log @isWaitCmd
		if @isWaitCmd > 0 then return # pass
		if !(@pc < @cmds.length)
			@isRunCmd = false # no commander, wait command
			return
		@myEval @cmds[@pc++]
	runCmd: (cmds) ->
		if cmds.length < 0 then throw 'no commands'
		if @isWaitCmd > 0 or @isRunCmd or @pc < @cmds.length
			console.log 'it is not finish'
			return 'isRunning'
		@cmds = cmds
		@pc = 0
		@isWaitCmd = 0
		@isRunCmd = true
	## kernel end ##

	sprite: null
	ctor: ->
		@_super()
		that = this
		@_initBattleTimer()
		@_loadRes()
		@_create6Position()
		@_createTable(
			[1,2,3,4,5,6],
			[7,8,9,10,11,12])
		console.log("To Watch: battleLayer2.coffee (#107):");  #TODO:path
		console.log(@table); #TODO:show details
		## action kernel
		@schedule(@kernelUpdate, 0.05, cc.REPEAT_FOREVER, 0, 'kernelUpdate')
		## kernel end

		size = cc.winSize
		closeItem = new cc.MenuItemImage(
			res.CloseNormal_png
			res.CloseSelected_png
			() ->
				myDirector.battle2()
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

		# set scheduler time
		@getScheduler().setTimeScale(1)
#		gs(helloLabel).bindTimer()

		@xy = new cc.LabelTTF("单击鼠标扔球", "arial", 16)
		@addChild @xy, 100

		this.stage = new cc.Sprite(res.stage)
		@stage.attr({
			x:size.width/2
			y:size.height/2
		})
#		@addChild(@stage, 0)


#		### ###
		@addPokemon = (n) ->
			if pokemonDataArray[n-1]? then t = pokemonDataArray[n-1]
			else t = {id: n}
			temp = new PokemonCard t, 1
			that.addChild temp, 5
			gs.playerArray.push temp
			gs.battleArray.push temp
			return temp
#		@addPokemon(17)
#		@addPokemon(15)

#		for i in [0..2]
#			temp = @addPokemon(i+10)
#			temp.setPosition(gs.uLoc[i])
#		for i in [0..2]
#			temp = @addPokemon(i+10)
#			temp.setPosition(gs.dLoc[i])
		temp = @addPokemon(42)
		temp.setVisible(false)
		temp.setPosition(gs.uLoc[0])

		temp = @addPokemon(281)
#		temp.backScale = 0.75
		temp.setPosition(gs.uLoc[1])

		temp = @addPokemon(148)
#		temp.backScale = 0.9
		temp.setVisible(false)
		temp.setPosition(gs.uLoc[2])

		temp = @addPokemon(142)
#		temp.backScale = 0.75
		temp.setVisible(false)
		temp.setPosition(gs.dLoc[0])

		temp = @addPokemon(91)  # 93
		temp.setVisible(false)
		temp.setPosition(gs.dLoc[2])

		temp = @addPokemon(123)
#		temp.backScale = 0.75
		temp.setPosition(gs.dLoc[1])

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
#				that.xy.setString(x + " " + y)
				that.xy.setString("")
				that.xy.x = p.x
				that.xy.y = p.y
		)
		cc.eventManager.addListener(mouseCheck, this)

		eventListener = cc.EventListener.create(
			event: cc.EventListener.TOUCH_ONE_BY_ONE
			onTouchBegan: (event) ->
				touchPoint = event.getLocation()
				that.particle.setPosition touchPoint
#				that.particle.resetSystem()

				temp = gs.playerArray[0]
				gs.playerArray = gs.playerArray[1...] #todo:pack in remove
#				if temp? then temp.testBallAction(event.getLocation())
#				that.runCmd(that.table.cmds)
				grid = gs.getNearestGrid(touchPoint)
#				that.runCmd([
#					['whenCall', that.table.attacker.handList[0], 0, grid.x, grid.y]
#				])


#				gs.battleArray[1].lightningStrike({x:400+Math.random()*400, y:460+Math.random()*200}, touchPoint)
#				gs.battleArray[1].crossBoom(touchPoint)

#				# fly fist
#				gs.battleArray[1].shrink 'res/temp/shrink01.png',
#					rotate: 180
#					cb: ->
##						gs.battleArray[1].particleDot("res/particles_effect/attack_fire.plist", touchPoint)
#						gs.battleArray[1].shrink 'res/temp/foot.png',
#							scale: 4
#							ease: cc.easeBounceOut()
#							scaleTo: 0.5
##						gs.battleArray[1].buffWave 'res/temp/buff_spd.png'
#						gs.battleArray[1].wave 'res/temp/wave01.png',
##							loc: touchPoint
#							scale: 0.7
#						gs.battleArray[1].wave 'res/temp/wave02.png',
##							loc: touchPoint
#							scale: 4
#						gs.battleArray[1].showLog '+spd'
#					loc: touchPoint

#				gs.battleArray[1].whip 'res/temp/yezi.png',
#					scale: 2
#					rotate: 180
#					rotateBy: -270
#					loc: touchPoint
#					cb: ->
#						gs.battleArray[1].rage ->
#							gs.battleArray[1].buffWave('res/temp/buff_atk.png')
#				gs.battleArray[5].particleDot 'res/particles_effect/ray/sun_ray.plist'
#				gs.battleArray[1].showLog '怒钳剪'
				gs.battleArray[1].testSkillLook('z')
				console.log grid
		)
		cc.eventManager.addListener(eventListener, this)

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

	_createTable: (atkIds, defIds) ->
		atkList = (@_createCard(t, 1) for t in atkIds)
		defList = (@_createCard(t, 0) for t in defIds)
		return @table = new Table(atkList, defList)

	_createCard: (id, flag) ->
		tData = pokemonDataArray[id-1] or pokemonDataArray[151]
		tCard = new PokemonCard tData, 1
		@addChild tCard, 5
		if flag is 0 then tCard.setPosition(gs.uhLoc)
		else tCard.setPosition(gs.dhLoc)
		return new CardMode tData, tCard

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

	showDamage: (loc, n, size) ->
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

# get location in screen
location = (row, column) ->
	if column?
		unless row in [0..2] and column in [0..2] then throw 'ERROR: location out of boundary'
		t = null
		if row is 0 then t = gs.uLoc
		else t = gs.dLoc
		return t[column]
	else
		unless row in [0, 1] then throw 'ERROR: location out of boundary'
		t = (if row is 0 then gs.uhLoc else gs.dhLoc)
		return t

root = exports ? window
root.BattleLayer2 = BattleLayer2
