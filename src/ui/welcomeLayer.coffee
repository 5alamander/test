Button = cc.MenuItemImage.extend
	doEffect: null
	ctor: (normal) ->
		that = this
		@_super(
			normal,
			normal,
			() ->
				that.onTouchBegan()
			this
		)
		that = this

	onTouchBegan: () ->
		that = this
		@stopAllActions()
		@runAction(
			cc.sequence(
				cc.scaleTo(0.3, 1.2).easing(cc.easeElasticOut())
				cc.blink(0.5, 2)
				cc.callFunc(
					() ->
						that.doEffect?()
					that
				)
				cc.scaleTo(0.3, 1).easing(cc.easeElasticOut())
			)
		)

WelcomeLayer = cc.Layer.extend

	_loadRes:() ->
		cc.spriteFrameCache.addSpriteFrames(res.res_plist);
		cc.textureCache.addImage(res.res_png);

	ctor: () ->
		@_super()
		that = this
		@_loadRes()
		size = cc.winSize
		@attr(
			x: size.width/2, y: size.height/2
		)

		logo = new cc.Sprite("#all/logo.png")
		logo.attr(
			y: size.height * 0.118
			scale: 0.5
			opacity: 0
		)
		@addChild logo, 10 # almost the top

		button1 = new Button("#all/start.png")
		button1.attr(
			y: size.height * -0.118
		)
		button1.doEffect = () ->
			myDirector.battle()

		button2 = new Button("#all/select.png")
		button2.attr(
			y: button1.y - button2.height * 1.618
		)
		button2.doEffect = () ->
			alert '此处正在施工，|++++++++|o(￣ヘ￣o＃)'

		menu = new cc.Menu [button1, button2]
		menu.attr({x: 0, y: 0})
		@addChild menu, 10

		@shake(logo, cc.rotateTo, 2.5, [6], [-6], cc.easeSineInOut())
		logo.runAction(
			cc.sequence(
				cc.delayTime(0.8)
				cc.fadeIn(1)
				cc.callFunc(
					() ->
						that.shake(logo, cc.scaleTo, 2.5, [0.52], [0.5], cc.easeSineInOut())
					that
				)
			)
		)
#		@shake(logo, cc.scaleTo, 2.5, [0.52], [0.5], cc.easeSineInOut())
		button1.setOpacity(0)
		button2.setOpacity(0)
		button1.runAction(cc.sequence(
			cc.delayTime(1), cc.fadeIn(1)
		))
		button2.runAction(cc.sequence(
			cc.delayTime(1.3), cc.fadeIn(1)
		))

		@createBackGround(n) for n in [1..5]

		t = new ccui.Button()

	shake: (target, act, time, max, min, ease = null) ->
		target.runAction(
			cc.repeatForever(
				cc.sequence(
					if ease? then act(time, max...).easing(ease) else act(time, max...)
					if ease? then act(time, min...).easing(ease) else act(time, min...))))

	createBackGround: (n) ->

		layer0 = new cc.Sprite("#backGround/welcome/#{n}.png")
		@addChild layer0, n
		layer0.setScale 2.003
		layer0.getTexture().setAliasTexParameters() # 纹理抗锯齿

		layer1 = new cc.Sprite("#backGround/welcome/#{n}.png")
		@addChild layer1, n
		layer1.attr(
			scale: 2.004, x: layer1.width*2
		)
		layer1.getTexture().setAliasTexParameters()

		t = [0.2, 0.5, 0.9, 2, 4][n-1]
		f = () ->
			@x = @x - t
			if @x < -@width*2 then @x = @x + @width*4
		layer0.schedule(f, 0.05, cc.REPEAT_FOREVER)
		layer1.schedule(f, 0.05, cc.REPEAT_FOREVER)

		if n is 1
			layer0.setX = -20; layer1.setX = -20
			@shake(layer0, cc.moveBy, 6, [0, 20], [0, -20], cc.easeSineInOut())
			@shake(layer1, cc.moveBy, 6, [0, 20], [0, -20], cc.easeSineInOut())

root = exports ? window
root.WelcomeLayer = WelcomeLayer