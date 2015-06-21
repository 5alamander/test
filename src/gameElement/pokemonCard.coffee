ElementColor =
	'冰': res.back_bin
	'草': res.back_cao
	'超能': res.back_chao
	'虫': res.back_chong
	'地面': res.back_di
	'电': res.back_dian
	'格斗': res.back_dou
	'毒': res.back_du
	'恶': res.back_e
	'飞行': res.back_fei
	'钢': res.back_gang
	'鬼': res.back_gui
	'火': res.back_huo
	'龙': res.back_long
	'普通': res.back_pu
	'水': res.back_shui
	'岩': res.back_yan
	'妖': res.back_yao

class Skill
	constructor: (@node) ->
		@prev = new cc.ParticleSystem("res/particles_effect/sun_ray_prev.plist")
		@prev.stopSystem()
		@prev.setPosition(0,0)
		@ray = new cc.ParticleSystem("res/particles_effect/ray/sun_ray.plist")
		@ray.stopSystem()
		@ray.setPosition(0,0)
		@node.addChild(@prev, 10)
		@node.addChild(@ray, 10)
		@prev.setPositionType(cc.ParticleSystem.TYPE_GROUPED)
		@ray.setPositionType(cc.ParticleSystem.TYPE_GROUPED)
		gs(@prev).bindTimer(true)
		gs(@ray).bindTimer(true)
	prepaire: () ->
		@prev.resetSystem()
	start: () ->
		@prev.stopSystem()
		@ray.resetSystem()

class feiyekuaidao
	constructor: (@node) ->
		@decrate = new cc.ParticleSystem("res/particles_effect/grass_decorate.plist")

Ball = cc.Node.extend
	ballUp: null
	ballDown: null
	# may pass in ball parameter
	particle: null
	ctor: () ->
		@_super()
		@ballUp = new cc.Sprite("#ball/ballup.png")
		@ballDown = new cc.Sprite("#ball/balldown.png")
		@ballUp.setScale 0.9
		@ballDown.setScale 0.9
		@setScale 0.25

		this.addChild @ballUp, 5
		this.addChild @ballDown, 4

		# todo:simplify
		gs(this).bindTimer()
		gs(@ballUp).bindTimer()
		gs(@ballDown).bindTimer()

#		@particle = new cc.ParticleSystem("res/particles_effect/attack_effect.plist")
#		@particle.stopSystem()
#		@particle.setPositionType(cc.ParticleSystem.TYPE_FREE);
#		@addChild(@particle, 10)

	_closeAndShow: () ->
		@ballUp.attr({y:0, opacity:255})
		@ballDown.attr({y:0, opacity:255})
		@setScale 0.25

	_openAndHid: () ->
		@ballUp.attr({y:100, opacity:0})
		@ballDown.attr({y:-100, opacity:0})
		@setScale 1

	# put in current ag as deffer
	open: (cag) ->
		that = this
		moveUp = cc.moveBy(0.5, 0, 100).easing(cc.easeExponentialOut())
		moveDown = cc.moveBy(0.5, 0, -100).easing(cc.easeExponentialOut())
		bothAction = cc.spawn(
			cc.rotateBy(0.5, 720)
			cc.scaleTo(0.5, 1)
		)
		@runAction(bothAction)
		@ballUp.runAction(moveUp)
		@ballUp.runAction(cc.fadeOut(0.5))
		@ballDown.runAction(moveDown)
		@ballDown.runAction(cc.fadeOut(0.5))

	close: (cag) ->
		moveUp = cc.moveBy(0.5, 0, 100).easing(cc.easeExponentialIn())
		moveDown = cc.moveBy(0.5, 0, -100).easing(cc.easeExponentialIn())
		bothAction = cc.spawn(
			cc.rotateBy(0.5, 720)
			cc.scaleTo(0.5, 0.25)
		)
		@runAction(bothAction)
		@ballUp.runAction(moveDown)
		@ballUp.runAction(cc.fadeIn(0.5))
		@ballDown.runAction(moveUp)
		@ballDown.runAction(cc.fadeIn(0.5))


PokemonCard = cc.Sprite.extend
	# the game look
	wd2:0
	hd2:0
	backImage: null
	frontImage: null
	pokemonImage: null
	ballUp: null
	ballDown: null
	ball: null
	# game look state
	_isMirror: false
	_isInBall: false
	_isBack: false
	_isActing: false
	# game logic attribute
	uid: 0
	tags: []

	_isTempUse: 0

	# pd: pokemonData, ed: entityData
	ctor: (@pd, @ed, @_isMirror = false, @_isBack = false) ->
		@_super()
		# copy the data to Card
		# load image by pokemonData.id
		# create skill by pokemonData.skills[]
		# set skill listens to the gameScene
		@setAnchorPoint(0.5, 0.5)

		e1 = @pd.e1
		e2 = @pd.e2
		unless @pd.e1?
			@frontImage = new cc.Sprite(res.back_huo)
			@backImage = new cc.Sprite(res.back_yao)
			@frontImage = new cc.Sprite(res.back_chong) if @pd.id is 291
			@frontImage = new cc.Sprite(res.back_chao) if @pd.id is 281
		else
			@frontImage = new cc.Sprite(ElementColor[e1])
			backColor = if e2 isnt '' then ElementColor[e2] else ElementColor[e1]
			@backImage = new cc.Sprite(backColor)

		@pokemonImage = new cc.Sprite(gs.getPicture(@pd.id))

		@ball = new Ball()
		this.addChild @ball, 5

		@_initCardLook()

		@_initCardAction()

		@_putInBall()
		@setPosition(gs.dhLoc)


	_initCardLook: () ->
#		stencil = new cc.Sprite("#all/start.png")#
#		clipper = new cc.ClippingNode(stencil)
#		clipper.setInverted(true)
#		clipper.setAlphaThreshold(0)
#		@addChild clipper, 0
#		clipper.addChild @backImage, 0
#		clipper.addChild @frontImage, 1
#		clipper.addChild @pokemonImage, 2
		@addChild @backImage, 0
		@addChild @frontImage, 1
		@addChild @pokemonImage, 2

		#todo:simplify
		gs(this).bindTimer()
		gs(@backImage).bindTimer()
		gs(@frontImage).bindTimer()
		gs(@pokemonImage).bindTimer()

		#scale
		@backScale = 0.5
		@backImage.setScale @backScale
		@frontImage.setScale @backScale
		@pokemonImage.setScale 0.8

		@wd2 = @frontImage.width
		@hd2 = @frontImage.height

	_initCardAction: () ->
		that = this
		#create action, all card is the same
		# todo:normal distribution
		@flipCardAction = ->
			cc.spawn(
				cc.scaleBy(0.5, -1, 1).easing(cc.easeCircleActionInOut(0.5))
				cc.sequence(
					cc.skewBy(0.25, 10, 30)
					cc.callFunc(() ->
						if that._isBack isnt true
							that.frontImage.runAction(cc.fadeOut(0))
							that._isBack = true
						else
							that.frontImage.runAction(cc.fadeIn(0))
							that._isBack = false
					)
					cc.skewBy(0.25, -10, -30)))

	_getBoundingBox: () ->
		p = @getPosition()
		rect = cc.rect(-@wd2+p.x, -@hd2+p.y, @wd2+p.x, @hd2+p.y);
		return rect

	flipCard: () ->
		@runAction(@flipCardAction()) unless @getNumberOfRunningActions() > 0

	_putInBall: () ->
		@_isInBall = true
		@ball._closeAndShow()
		@backImage.attr({opacity:0, scale:0.1})
		@frontImage.attr({opacity:0, scale:0.1})
		@pokemonImage.attr({opacity:0, scale:0.1})#fixme:Not All the Same

	_putOutsideBall: () ->
		@_isInBall = false
		@ball._openAndHid()
		@backImage.attr({opacity:255, scale:@backScale})
		@frontImage.attr({opacity:255, scale:@backScale}) unless @_isBack
		@pokemonImage.attr({opacity:255, scale:0.8})#fixme:Not All the Same

	callCard: (loc) ->
		that = this
		@_isActing = true
		@_putInBall()
		openAction = (scaleTo) ->
			cc.spawn(cc.fadeIn(0.5), cc.scaleTo(0.5, scaleTo).easing(cc.easeElasticOut()))
		step2 = () ->
			that.backImage.runAction(openAction(that.backScale))
			that.frontImage.runAction(openAction(that.backScale))
			that.pokemonImage.runAction(openAction(0.8))
			that.ball.open(10)
			that._isInBall = false
			@runAction(cc.sequence(cc.delayTime(0.5), cc.callFunc(->
				that._isActing = false
				that.attack() if that.pd?.id is "15"
				that.pussle(1.5) if that.pd?.id is "5"
			)))

		@runAction(cc.sequence(
			cc.spawn(
				cc.jumpTo(0.5, loc, 100, 1).easing(cc.easeSineInOut())
				cc.rotateBy(0.5, 720))
			cc.callFunc(step2, this)
		))

		@scheduleOnce(()->
			that.flipCard()
		,2.5) if @pd?.id is '17'

		# yanguanlieyan
		#		@scheduleOnce(() ->
#			p = new cc.ParticleSystem("res/particles_effect/buff.plist")
#			point = that.getPosition()
#			p.setPosition(point.x, point.y - 30)
#			gs.battleLayer.addChild p, 50
#		, 3)
		@scheduleOnce(->
			that.attack()
		,1.5) if that.pd?.id is '93'
		@scheduleOnce(->
			that.attack(0,0,1)
		,2) if that.pd?.id is '6'

		skill = new Skill(this)
		@scheduleOnce(() ->
			skill.prepaire()
		,1.5
		) if @pd.id is "1"
		@scheduleOnce(() ->
			skill.start()
		,2.6
		) if @pd.id is "1"
		@scheduleOnce(() ->
			gs.battleLayer.getScheduler().setTimeScale(3)
			console.log("pokemonCard.coffee  (#242): " + "set time");  # TODO:debug
		,1.5
		) if @pd.id is 251

#		@scheduleOnce(() ->
#			that.evolute(18) # jin hua
#		,1.5
#		) if @pd.id is "17"
#		@scheduleOnce(() ->
#			that.slipCard() #fen sheng
#		,1.5) if @pd.id is "8"


		# feiyekuaidao
#		create = () ->
#			decorate = new VectorEffect(gs.battleLayer)
#			decorate.setPosition(that.getPosition())
#			n = gs.random(430) - 215
#			b = [cc.p(n,-190), cc.p(n,200), cc.p(0, 400)]
#			decorate.runAction(
#				cc.bezierBy(1, b).easing(cc.easeSineIn()))
#		@schedule(() ->
#			create()
#		,0.5,5,0.7)

		createWeb = (aim, t = 0.6) ->
			web = new cc.Sprite("res/temp/spiderweb.png")
			web.setPosition(that.getPosition())
			web.setScale(0.1)
			gs.battleLayer.addChild web, 100
			loc = (if aim? then aim else gs.getNearest(that).getPosition())
			web.runAction(cc.sequence(
				cc.spawn(
					cc.scaleTo(t, 2)
					cc.rotateBy(t, 80)
					cc.moveTo(t,loc)
				)
				cc.delayTime(2)
				cc.fadeOut(1)
				cc.callFunc(() ->
					gs.battleLayer.removeChild web, true
				)
			))
			gs._tempUseWeb = web
			gs._tempUseP = that
		#lukaliou
#		@scheduleOnce(() ->
#			createWeb(gs.battleArray[2], 0.8)
#		,1.5) if @pd.id is "10"
#		@scheduleOnce(() ->
#			createWeb(gs.getNearest(that).getPosition(), 0.3)
#		,2.3) if @pd.id is 448
#		@scheduleOnce(() ->
#			createWeb(gs.battleArray[1], 0.3)
#		,3.0) if @pd.id is 448

		#fang she, yeshashou
#		@scheduleOnce(() ->
##			that.pussle(1, 'res/pokemons/image282.png')
#			web = gs._tempUseWeb
#			aim = gs._tempUseP
#			loc = aim.getPosition()
#			web.cleanup()
#			web.runAction(cc.sequence(
#				cc.spawn(
#					cc.scaleTo(0.6, 2)
#					cc.rotateBy(0.6, 80)
#					cc.moveTo(0.6,loc)
#				)
#				cc.delayTime(2)
#				cc.fadeOut(1)
#				cc.callFunc(() ->
#					gs.battleLayer.removeChild web, true
#				)
#			))
#
#			p = new cc.ParticleSystem("res/particles_effect/a.plist")
#			p.setStartColor(cc.color(10,186,40))
#			p.setEndColor(cc.color(40,186,40))
#			p.setPosition(that.getPosition())
#			gs.battleLayer.addChild(p, 120)
#		,2.5) if @pd.id is 282


#		@scheduleOnce(@regainCard, 4.6) unless @pd.id is '17'

	attack: (x, y, type) ->
		that = this
#		aim = gs.getNearest(this)
		aim = gs.battleArray[1]
		loc = aim.getPosition()
		dx = (loc.x - @x) * 0.8
		dy = (loc.y - @y) * 0.8
		myLoc = {x:@x, y:@y}
		act =cc.sequence(
				cc.moveBy(0.6, dx, dy).easing(cc.easeBackIn())
				cc.callFunc(() ->
					rect = cc.rectIntersection(that.getBoundingBox(), aim.getBoundingBox())
					point = cc.p(cc.rectGetMidX(rect), cc.rectGetMidY(rect))
					aim.beHit(point)
#					that.beHit(point)
					p = new cc.ParticleSystem("res/particles_effect/attack_fire.plist")
					p.setPosition(point)
					gs.battleLayer.showDamage(point, 400)
					gs.battleLayer.addChild p, 50

					path = (if type? then 'claw2.png' else 'claw1.png')
					claw = new cc.Sprite('res/temp/'+path)
					claw.setPosition(point)
					if type?
						claw.setScale(4, 1.5)
						gs.battleLayer.showDamage(gs.uLoc[0], 100)
						gs.battleArray[0].beHit(point)
						gs.battleArray[2].beHit(point)
						gs.battleLayer.showDamage(gs.uLoc[2], 100)
					else
						claw.setScale(1.5, 2)
					claw.runAction(cc.sequence(
						cc.delayTime(0.2)
						cc.fadeOut(0.4)
						cc.callFunc(->
							gs.battleLayer.removeChild(claw, true)
						)
					))
#					claw.setOpacity(0)
					gs.battleLayer.addChild claw, 49
				)
				cc.moveTo(1.5, myLoc).easing(cc.easeSineIn())
			)
		@runAction(act)

	beHit: (p, distance = 30) ->
		that = this
		{x,y} = this
		dx = x-p.x
		dy = y-p.y
		v = cc.pNormalize(cc.p(dx, dy))
		v = cc.pMult(v, distance)
		@runAction(cc.sequence(
			cc.moveBy(0.5, v).easing(cc.easeElasticOut())
			cc.callFunc(() ->
				# pass
			)
			cc.moveBy(1, cc.pMult(v, -1)).easing(cc.easeSineInOut())
		))

	regainCard: (loc) ->
		that = this
		@_isActing = true
		@_putOutsideBall()
		closeAction = (scaleTo) ->
			cc.spawn(cc.fadeOut(1), cc.scaleTo(0.5, scaleTo).easing(cc.easeElasticIn()))
		@backImage.runAction(closeAction(0.1))
		@frontImage.runAction(closeAction(0.1))
		@pokemonImage.runAction(closeAction(0.1))
		@ball.close(10)

		@runAction(cc.sequence(
			cc.delayTime(0.5)
			cc.callFunc(->that._isInBall = true)
			cc.spawn(
				cc.jumpTo(0.5, gs.dhLoc, 100, 1).easing(cc.easeSineInOut())
				cc.rotateBy(0.5, 720))
			cc.callFunc(->
				that._isActing = false
				gs.playerArray.push(that)
			)
		))

	update: (dt) ->
		cc.log 'I am awake : ' + dt

	testBallAction: (loc) ->
		@issmall = true unless @issmall?
#		if @issmall and !@_isActing
#			@callCard(loc)
#			@issmall = false
#		else if !@issmall and !@_isActing
#			@regainCard(loc)
#			@issmall = true

		@callCard(loc) unless @_isActing
		

	evolute: (id) ->
		aimPicture = null
		if typeof id is 'number'
			aimPicture = gs.getPicture(id)
		else
			aimPicture = 'res/pokemons/image151.png'
		that = this
		scaleBack = () ->
			that.backImage.runAction(cc.scaleTo(0.5, that.backScale))
			that.frontImage.runAction(cc.scaleTo(0.5, that.backScale))
		@pussle(1, aimPicture)
		@runAction(cc.spawn(

			cc.sequence(cc.delayTime(0.75), cc.callFunc(
				() -> that.pokemonImage.setTexture(aimPicture)
			))
			cc.sequence(
				cc.delayTime(0.5)
				cc.callFunc(->that.pussle(1, aimPicture))
				cc.callFunc(->
					scaleBack()
					p = new cc.ParticleSystem("res/particles_effect/a.plist")
					p.setStartColor(cc.color(10,186,40))
					p.setEndColor(cc.color(40,186,40))
					p.setPosition(that.getPosition())
					gs.battleLayer.addChild(p, 120)
				)
				@flipCardAction()
			)
		))

	changeLook: (aim) ->
		that = this
		pokemonImage = aim.pokemonImage.getTexture()
		frontImage = aim.frontImage.getTexture()
		backImage = aim.backImage.getTexture()
		scaleBack = () ->
			that.backImage.runAction(cc.scaleTo(0.5, that.backScale))
			that.frontImage.runAction(cc.scaleTo(0.5, that.backScale))
#		@pussle(1, pokemonImage)
		@runAction(cc.spawn(
			cc.sequence(cc.delayTime(0.75), cc.callFunc(
				() ->
					that.pokemonImage.setTexture(pokemonImage)
					that.pokemonImage.setFlippedX(true)
					that.frontImage.setTexture(frontImage)
					that.backImage.setTexture(backImage)
			))
			cc.sequence(
				cc.delayTime(0.5)
				cc.callFunc(->
					that.backScale = aim.backScale
					scaleBack()
				)
				@flipCardAction()
			)
		))

	pussle: (t, res) ->
		t = 0.5 unless t?
		unless res? then res = 'res/pokemons/image006.png'
		image = new cc.Sprite(res)
		image.setPosition(@getPosition())
		image.setScale(@getScale())
		gs.battleLayer.addChild image, 100
		image.runAction(cc.sequence(
			cc.spawn(
				cc.scaleTo(t, 2).easing(cc.easeExponentialOut())
				cc.fadeOut(t)
			)
			cc.callFunc(() ->
				gs.battleLayer.removeChild image, true
			)
		))

	crossBoom: (loc, scale = 1, type = 0) ->
		boom = gs.spliteFrame('res/temp/cross.png', 4, 5)
		boomAnim = new cc.Animation(boom[0].concat(boom[1]).concat(boom[2]).concat(boom[3]), 0.8 / 20, 1)
		s = new cc.Sprite()
		gs.battleLayer.addChild s, 200
		s.attr
			x: loc.x
			y: loc.y
			scale: scale
		s.runAction(cc.sequence(
			cc.animate(boomAnim)
			cc.delayTime(0.5)
			cc.callFunc(->gs.battleLayer.removeChild(s, true))
		))

	lightningStrike: (from, aim, beHitCard, hitPower, type = 0) ->
		that = this
		r = -90 - cc.pToAngle(cc.pSub(aim, from)) * 180 / Math.PI
		d = cc.pDistance(aim, from)
		rd = Math.random()
		rd0 = Math.random()
		console.log r
		lightningFrames = gs.spliteFrame('res/Lightning.png', 1, 6)
		lightningAnim = new cc.Animation(lightningFrames[0], 0.4 / 6, 1)
		ls = new cc.Sprite()
		gs.battleLayer.addChild ls, 200
		ls.attr
			x: from.x
			y: from.y
			scaleX: 2 + rd * 3
			scaleY: 0
		ls.setAnchorPoint(0.5, 1)
		ls.setRotation(r)
		ls.runAction(cc.sequence(
			cc.spawn(
				cc.scaleTo(0.1+rd0*0.3, 1+rd*2, d/512).easing(cc.easeBounceOut())
				cc.animate(lightningAnim)
				cc.sequence(
					cc.delayTime(0.1)
					cc.callFunc(->
						if beHitCard? then beHitCard.beHit(from, hitPower)
						that.particleDot(res.lightning_plist, aim)))
			)
			cc.callFunc(()->
				ls.stopAllActions()
				gs.battleLayer.removeChild(ls, true)
			)
		))

	slipCard: () ->
		that = this
		xoffset = @frontImage.width
		create = (dx) ->
			image = new cc.Sprite("res/pokemons/image008.png")
			image.setPosition(that.getPosition())
			image.setScale(that.pokemonImage.getScale())
			gs.battleLayer.addChild image, 100
			image.runAction(cc.sequence(
				cc.spawn(
					cc.moveBy(1.5, dx, 0).easing(cc.easeElasticInOut())
					cc.blink(1.5, 4).easing(cc.easeSineOut())
				)
				cc.fadeOut(0.8)
				cc.callFunc(() ->
					gs.battleLayer.removeChild image, true
				)
			))
		tdx = xoffset*0.7
		create(tdx * n) for n in [-3,-2,-1,1,2,3]

	particleDot: (res, loc, type = 0) ->
		p = new cc.ParticleSystem(res)
		p.setPosition(loc or @getPosition())
		gs.battleLayer.addChild(p, 210)
		@scheduleOnce(() ->
			gs.battleLayer.removeChild(p, true)
		,p.life+0.2) # it need a key

	# {loc, sacle, scaleTo, rotate, ease, cb}
	shrink: (res, option = {}) ->
		s = new cc.Sprite(res)
		{loc, scale, scaleTo, rotate, ease, t, last, cb} = option
		s.setPosition(loc or @getPosition())
		s.setScale(scale or 1)
		gs.battleLayer.addChild(s, 200)
		action = cc.spawn(
			cc.scaleTo(t or 0.5, scaleTo or 0.1)
			cc.rotateBy(t or 0.5, rotate or 0)
		)
		if ease? then action.easing(ease)
		s.runAction(cc.sequence(
			action
			cc.callFunc(-> cb?() )
			cc.delayTime(last or 0)
			cc.callFunc(->
				gs.battleLayer.removeChild(s, true)
			)
		))

	# {loc, scale, rotate, cb}
	wave: (res, option = {}) ->
		s = new cc.Sprite(res)
		{loc, scale, rotate, cb} = option
		s.setPosition(loc or @getPosition())
		s.setScale(0.1)
		gs.battleLayer.addChild(s, 200)
		s.runAction(cc.sequence(
			cc.spawn(
				cc.scaleTo(0.5, scale or 1)
				cc.rotateBy(0.5, rotate or 0)
				cc.fadeOut(0.5)
			).easing(cc.easeBounceIn())
			cc.callFunc(->
				gs.battleLayer.removeChild(s, true)
				cb?()
			)
		))

	# {loc, aim, scale, rotate, rotateBy, cb}
	whip: (res, option = {}) ->
		s = new cc.Sprite(res)
		{loc, aim, scale, rotate, rotateBy, cb} = option
		that = this
		s.setPosition(loc or @getPosition())
		s.setScale((scale or 1) * 2)
		s.setRotation(rotate or 0)
		gs.battleLayer.addChild(s, 200)
		s.runAction(cc.sequence(
			cc.spawn(
				cc.rotateBy(0.5, rotateBy or 0).easing(cc.easeSineInOut())
				cc.scaleTo(0.5, scale or 1)
				cc.sequence(
					cc.moveTo(0.25, aim or @getPosition())
					cc.callFunc(->
						that.beHit(loc, 20)
						that.particleDot("res/particles_effect/attack_fire.plist", aim or that.getPosition())
					)
					cc.moveTo(0.25, loc or @getPosition())
				).easing(cc.easeExponentialInOut())
			)
			cc.callFunc(->
				gs.battleLayer.removeChild(s, true)
				cb?()
			)
		))

	luster: (cb) ->
		that = this
		stencil = new cc.Sprite(res.back_bin)
		stencil.setScale 0.5
		clipper = new cc.ClippingNode(stencil)
		clipper.setInverted(false)
		clipper.setAlphaThreshold(0)
		luster = new cc.Sprite('res/temp/luster.png')
		@addChild clipper, 1
		clipper.addChild luster
		luster.attr
			y: -45
			scale: 1.6
		luster.runAction(cc.sequence(
			cc.moveBy(0.4, 0, 100)
			cc.moveTo(0, 0, -45)
			cc.moveBy(0.4, 0, 100)
			cc.callFunc(->
				that.removeChild clipper, true
				cb?()
			)
		))

	shield: (cb) ->
		that = this
		stencil = new cc.Sprite('res/temp/shieldMask.png')
		stencil.setScale 0.5
		clipper = new cc.ClippingNode(stencil)
		clipper.setInverted(false)
		clipper.setAlphaThreshold(0)
		luster = new cc.Sprite('res/temp/luster.png')
		@addChild clipper, 201
		clipper.addChild luster
		luster.attr
			y: -45
			scale: 2.3
		luster.runAction(cc.sequence(
			cc.moveBy(0.4, 0, 125)
			cc.moveTo(0, 0, -45)
			cc.moveBy(0.4, 0, 125)
			cc.callFunc(->
				that.removeChild clipper, true
				cb?()
			)
		))

	buffWave: (path, option = {}) ->
		that = this
		{cb} = option
		stencil = new cc.Sprite(res.back_bin)
		stencil.setScale 0.5
		clipper = new cc.ClippingNode(stencil)
		clipper.setInverted(false)
		clipper.setAlphaThreshold(0)
		buffWave0 = new cc.Sprite(path or 'res/temp/buff_atk.png')
		buffWave1 = new cc.Sprite(path or 'res/temp/buff_atk.png')
		@addChild clipper, 2
		clipper.addChild buffWave0
		clipper.addChild buffWave1
		buffWave0.attr
			opacity: 135
		buffWave1.attr
			y: -200
			opacity: 135
		buffWave0.runAction(
			cc.moveBy(0.7, 0, 100)
		)
		buffWave1.runAction(cc.sequence(
			cc.moveBy(0.7, 0, 100)
			cc.callFunc(->
				that.removeChild clipper, true
				cb?()
			)
		))

	rage: (cb) ->
		that = this
		rage0 = new cc.Sprite('res/temp/rage.png')
		rage1 = new cc.Sprite('res/temp/rage.png')
		@addChild rage0, 10
		@addChild rage1, 10
		rage0.attr
			opacity: 0
			scale: 2
			x: 20
			y: 40
		rage1.attr
			opacity: 0
			scale: 1.5
			x: 40
			y: 10
		showAction = cc.sequence(
			cc.fadeIn(0.1)
			cc.scaleBy(0.5, -0.5).easing(cc.easeElasticInOut())
			cc.fadeOut(0.1)
		)
		rage0.runAction(showAction)
		rage1.runAction(cc.sequence(
			cc.delayTime(0.3)
			showAction.clone()
			cc.callFunc(->
				that.removeChild rage0, true
				that.removeChild rage1, true
				cb?()
			)
		))

	removeAction: (that, childs) ->
		return cc.callFunc(->
			that.removeChild(c, true) for c in childs
		)

	growOut: (res, option) ->
		s = new cc.Sprite(res)
		{loc, directoin, scale, rotate, ease, hitCb, cb} = option
		s.setPosition(loc or cc.p(0,0))
		s.attr(
			y: -26
			scaleY: 0.5
		)
		@addChild s, 205
		action = cc.spawn(
			cc.scaleTo(0.5, 1, 1)
			cc.moveBy(0.5, 0, 26)
			cc.sequence(
				cc.delayTime(0.22)
				cc.callFunc(->hitCb?())
			)
		);
		if ease? then action.easing(ease)
		s.runAction(cc.sequence(
			action
			@removeAction(this, [s])
			cc.callFunc(->cb?())
		))

	throwOut: (res, cb) ->
		s = new cc.Sprite(res)
		@addChild s, 200
		s.setScale(0.2)
		s.runAction(cc.sequence(
			cc.spawn(
				cc.moveTo(0.5, 60, 40).easing(cc.easeSineOut())
				cc.scaleTo(0.5, 0.7)
				cc.fadeIn(0.4)
				cc.sequence(cc.delayTime(0.2)
					cc.callFunc(->cb?())
				)
			)
			@removeAction(this, [s])
		))

	showLog: (str) ->
		that = this
		label = new cc.LabelTTF(str, "Arial", 22)
		label.setColor(cc.color(255,70,0))
		@addChild label, 200
		label.runAction(cc.sequence(
			cc.spawn(
				cc.moveTo(0.5, 60, 40).easing(cc.easeSineOut())
				cc.scaleTo(0.5, 1.4)
				cc.fadeIn(0.4)
			)
			cc.callFunc(->
				that.removeChild label, true
			)
		))

	testSkillLook: (str) ->
		that = this
		switch str
			when 'foot'
				@shrink 'res/temp/shrink01.png',
					rotate: 180
					cb: ->
						that.shrink 'res/temp/foot.png',
							scale: 4
							ease: cc.easeBounceOut()
							scaleTo: 0.5
						that.wave 'res/temp/wave01.png',
							scale: 0.7
						that.wave 'res/temp/wave02.png',
							scale: 4
			when 'shield'
				@shrink 'res/temp/shield.png',
					scale: 0.1
					scaleTo: 0.62
					ease: cc.easeElasticOut()
					cb: ->
						that.shield()
					last: 0.9
			when 'growOut'
				@growOut 'res/temp/thorn.png',
					ease: cc.easeElasticOut()
#					hitCb: -> that.testSkillLook('shield')
			when 'z'
				@throwOut 'res/temp/Zzz.png',
					cb: -> that.throwOut('res/temp/Zzz.png')
			else
				console.log 'a'



root = exports ? window
root.PokemonCard = PokemonCard