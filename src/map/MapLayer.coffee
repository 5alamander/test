Character = cc.Sprite.extend
	isWalk: false
	ctor: () ->
		@_super()
		frames = gs.spliteFrame("res/map/player.png", 4, 4)
		walkAnim = (frames) ->
			anim = new cc.Animation(frames, 1/4)
			return cc.repeatForever(cc.animate(anim))
		@walkDown = walkAnim frames[0]
		@walkLeft = walkAnim frames[1]
		@walkRight = walkAnim frames[2]
		@walkUp = walkAnim frames[3]

MapLayer = cc.Layer.extend
	ctor: (mapPath)->
		@_super()
		cc.FIX_ARTIFACTS_BY_STRECHING_TEXEL = 1 # 纹理应用缩小为99%
		@map = new cc.TMXTiledMap(mapPath)
		#t.getTexture().setAliasTexParameters() for t in map.getChildren() #貌似不需要抗锯齿了
		@addChild(@map, 0)
		# 识别地图元素
		@mapInit()

		console.log("To Watch: MapLayer.coffee (#7):");  #TODO:path
		console.log(@map); #TODO:show details

		@createPlayer()

		that = this
		tileCoordForPosition = (p) ->
			x = (p.x-that.x) / @map.getTileSize().width
			y = ((@map.getMapSize().height * @map.getTileSize().height) - p.y + that.y) / @map.getTileSize().height
			return cc.p(x|0, y|0)

		gs(@map).click (event)->
			myDirector.battle()
			return
#			t = tileCoordForPosition(event.getLocation())
#			console.log("MapLayer.coffee  (#27): " + t.x + ' ' + t.y);  # TODO:debug
#			that.setPosition(event.getLocation())
#			myDirector.battle()

#		@scheduleOnce(
#			->myDirector.battle()
#			3)

	playerMove: (x, y) ->
		@map.runAction(cc.moveBy(0.5, -x, -y).easing(cc.easeSineInOut()))
		@player.runAction(cc.moveBy(0.5, x, y).easing(cc.easeSineInOut()))

	createPlayer: () ->
		@player = new Character()
		@map.addChild @player, 10
		@player.attr({x:400,y:200})
		@player.runAction(@player.walkLeft)

	mapInit:() ->
		# locate the player location
		# create npc
		# create items

	createButton: () ->
		that = this
		padb = new cc.Sprite("res/map/padb.png")
		padb.setPosition(padb.width/2+30, padb.height/2+30)
		padb.setOpacity(100)
		@addChild padb, 50

		gs(padb).click (event) ->
			loc = event.getLocation()
			loc0 = this.getPosition()
			dx = loc.x - loc0.x
			dy = loc.y - loc0.y
			if Math.abs(dx) > Math.abs(dy)
				if dx > 0
					that.player.stopAllActions()
					that.playerMove(32, 0)
					that.player.runAction(that.player.walkRight)
				else
					that.player.stopAllActions()
					that.playerMove(-32, 0)
					that.player.runAction(that.player.walkLeft)
			else
				if dy > 0
					that.player.stopAllActions()
					that.playerMove(0, 32)
					that.player.runAction(that.player.walkUp)
				else
					that.player.stopAllActions()
					that.playerMove(0, -32)
					that.player.runAction(that.player.walkDown)


		padf = new cc.Sprite("res/map/padf.png")
		padf.setPosition(padb.width/2+30, padb.height/2+30)
		padf.setOpacity(100)
		@addChild padf, 51

		btna = new cc.Sprite("res/map/btna.png")
		btna.setPosition(800-btna.width*0.682-20, btna.height*1.618+20)
		btna.setOpacity(100)
		@addChild btna, 50

		btnb = new cc.Sprite("res/map/btnb.png")
		btnb.setPosition(800-btnb.width*1.618-20, btnb.height*0.618+20)
		btnb.setOpacity(100)
		@addChild btnb, 50
		gs(btnb).click () ->
			myDirector.welcome()


		#todo:abstract
		#gs(this).sprite("........") use the name to create sprite with the name confirm

#		@setViewPortInPoints()



root = exports ? window
root.MapLayer = MapLayer

