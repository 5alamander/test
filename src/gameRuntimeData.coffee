class Player # player or the AI
	constructor: (@id, @name) ->

#game scene to store data, a singleton object

class NodeOperateChain
	constructor: (@node) ->
		@prev = []
		@prev.push @node

	###
	#
    #@cb {Function} click callback function
	###
	click: (cb) ->
		that = this
		unless cb? then throw "callback is not defined"
		eventListener = cc.EventListener.create(
			event: cc.EventListener.TOUCH_ONE_BY_ONE
			swallowTouches: true
			onTouchBegan: (event) ->
				loc = event.getLocation()
				rect = that.node.getBoundingBox()
				if cc.rectContainsPoint(rect, loc)
					cb.call(that.node, event)
					return true
				else return false
		)
#		if @node instanceof cc.Layer then p = @node else p = @node.getParent()
		cc.eventManager.addListener(eventListener, @node) #todo:learn addListener
		return this


	bindTimer: (isParticle = false) ->
		t = gs.battleLayer
		unless t? then throw "the battle Layer does not been created"
		@node._scheduler = t._scheduler
		@node._actionManager = t._actionManager
		@node.scheduleUpdate() if isParticle
		return this


# gs({cc.Node}) the chain of node
# @select {cc.Node|Number} if node, must small than layer
#
gs = (select) ->
		if (select instanceof cc.Node)
			return new NodeOperateChain(select)

gs.init = () ->
	@preLoadArray = []

	# game data
	@uids = {} # turn based would use
	@uidCount = 0
	@trigger = {}
	@enemyArray = []
	@playerArray = []
	@battleArray = []

	@battleLayer = null

	@size = cc.winSize

gs.start = (@levelData, @playerData) ->
	@init()

gs.getPicture = (id) ->
	if typeof id is 'string' then id = Number(id)
	if id < 1000
		id = (id + 1000).toString()[1...]
	else
		id = (id + 10000).toString()[1...]
	return 'res/pokemons/image' + id + '.png'
# tools for this
gs.getPreLoad = () ->
	r1 = (gs.getPicture(c?.pd?.id) for c in @enemyArray)
	r2 = (gs.getPicture(c?.pd?.id) for c in @playerArray)
	return [r1..., r2...]

# tools for game
gs.registerCard = (card) ->
	@uids[@uidCount++] = card
	card.uid = @uidCount

gs.listen = (waiter, eventName) ->
	unless @trigger[eventName]? then @trigger[eventName] = []
	@trigger[eventName].push waiter

gs.disListen = (waiter, eventName) ->
	if @trigger[eventName]?
		@trigger[eventName] = (card for card in @trigger[eventName] when card isnt waiter)

gs.broadCast = (eventName, args...) ->
	unless @trigger[eventName]? then return false # pass it
	for waiter in @trigger[eventName]
		continue if waiter.isSilence
		waitter[eventName](args...) # the event won't be passed in real time scene
	return true

# general tools
gs.random = (n) ->
	Math.floor(Math.random() * n)

gs.remove = (list, n) ->
	t = list[n]
	list.splice(n, 1)
	return t

gs.spliteFrame = (str, row, col) ->
	texture = cc.textureCache.addImage(str)
	{width, height} = texture.getContentSize()
	w = width / col | 0
	h = height / row | 0
	frames = []
	for i in [0...row]
		temp = []
		for j in [0...col]
			temp.push new cc.SpriteFrame(texture, cc.rect(j*w, i*h, w, h))
		frames.push temp
	return frames

## get nearest n target
gs.getNearest = (p, n) ->
	{x, y} = p
	arr = (t for t in gs.battleArray when t isnt p)
	arr.sort((p1, p2) ->
		if (Math.pow(p1.x-x,2)+Math.pow(p1.y-y,2)) < (Math.pow(p2.x-x,2)+Math.pow(p2.y-y,2))
			return -1
		else
			return 1
	)
	if n? > 1 then return arr[0...n]
	else return arr[0]

gs.getNearestGrid = (p) ->
	{x, y} = p
	arr = gs.uLoc.concat(gs.dLoc)
	arr.sort((p1, p2) ->
		if (Math.pow(p1.x-x,2)+Math.pow(p1.y-y,2)) < (Math.pow(p2.x-x,2)+Math.pow(p2.y-y,2))
			return -1
		else
			return 1
	)
	temp = arr[0]
	y = (if temp in gs.uLoc then 0 else 1)
	x = (if y is 0 then gs.uLoc.indexOf(temp) else gs.dLoc.indexOf(temp))
	return {x, y}

gs.init()

root = exports ? window
root.gs = gs;

