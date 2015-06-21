###*
 * @property 'fullName',
		get: -> 
		set: (name) -> 
 * @param  {string} prop [name of property]
 * @param  {[type]} desc [description]
 * @return {[type]}      [description]
###
Function::property = (prop, desc) ->
	Object.defineProperty @prototype, prop, desc

Array::delete = (o) ->
	n = @indexOf o
	if n is -1 then return null
	@splice(n, 1)
	@delete(o)
	return this

remove = (list, n) ->
	t = list[n]
	list.splice(n, 1)
	return t

random = (n) ->
	Math.floor(Math.random() * n)


ElementTable =
	'普通':{
		'岩': 0.75
		'鬼': 0
		'钢': 0.75
	}
	'火':{
		'火': 0.75
		'水': 0.75
		'草': 1.5
		'冰': 1.5
		'虫': 1.5
		'岩': 0.75
		'龙': 0.75
		'钢': 1.5
	}
	'水':{
		'火': 1.5
		'水': 0.75
		'草': 0.75
		'地面': 1.5
		'岩': 1.5
		'龙': 0.75
	}
	'草':{
		'火': 0.75
		'水': 1.5
		'草': 0.75
		'毒': 0.75
		'地面': 1.5
		'飞行': 0.75
		'虫': 0.75
		'岩': 1.5
		'龙': 0.75
		'钢': 0.75
	}
	'电':{
		'水': 1.5
		'草': 0.75
		'电': 0.75
		'地面': 0
		'飞行': 1.5
		'龙': 0.75
	}
	'冰':{
		'火': 0.75
		'水': 0.75
		'草': 1.5
		'冰': 0.75
		'地面': 1.5
		'飞行': 1.5
		'龙': 1.5
		'钢': 0.75
	}
	'格斗':{
		'普通': 1.5
		'冰': 1.5
		'毒': 0.75
		'飞行': 0.75
		'超能': 0.75
		'虫': 0.75
		'岩': 1.5
		'鬼': 0
		'恶': 1.5
		'钢': 1.5
		'妖': 0.75		
	}
	'毒':{
		'草': 1.5
		'毒': 0.75
		'地面': 0.75
		'岩': 0.75
		'鬼': 0.75
		'钢': 0
		'妖': 1.5
	}
	'地面':{
		'火': 1.5
		'草': 0.75
		'电': 1.5
		'毒': 1.5
		'飞行': 0
		'虫': 0.75
		'岩': 1.5
		'钢': 1.5
	}
	'飞行':{
		'草': 1.5
		'电': 0.75
		'格斗': 1.5
		'虫': 1.5
		'岩': 0.75
		'钢': 0.75
	}
	'超能':{
		'格斗': 1.5
		'毒': 1.5
		'超能': 0.75
		'恶': 0
		'钢': 0.75
	}
	'虫':{
		'火': 0.75
		'草': 1.5
		'格斗': 0.75
		'毒': 0.75
		'飞行': 0.75
		'超能': 0.75
		'鬼': 0.75
		'恶': 1.5
		'钢': 0.75
		'妖': 0.75
	}
	'岩':{
		'火': 1.5
		'冰': 1.5
		'格斗': 0.75
		'地面': 0.75
		'飞行': 1.5
		'虫': 1.5
		'钢': 0.75
	}
	'鬼':{
		'普通': 0
		'超能': 1.5
		'鬼': 1.5
		'恶': 0.75
	}
	'龙':{
		'龙': 1.5
		'钢': 0.75
		'妖': 0
	}
	'恶':{
		'格斗': 0.75
		'超能': 1.5
		'鬼': 1.5
		'恶': 0.75
		'妖': 0.75
	}
	'钢':{
		'火': 0.75
		'水': 0.75
		'电': 0.75
		'冰': 1.5
		'岩': 1.5
		'钢': 0.75
		'妖': 1.5
	}
	'妖':{
		'火': 0.75
		'格斗': 1.5
		'毒': 0.75
		'龙': 1.5
		'恶': 1.5
		'钢': 0.75
	}

ElementRate = (e1, e2) ->
	unless ElementTable[e1]? then throw 'ERROR: no such a element'
	r = 1
	r = ElementTable[e1][e2] if ElementTable[e1][e2]?
	return r

class Trigger

	@::BEFOR = 0
	@::AFTER = 1
	@::AVOID = 2

	constructor: (@name, @father = null) ->
		@clear()

	clear: () ->
		@bf = [] # bf means before array
		@af = [] # af means after array
		@av = [] # av means avoid array

	listen: (waitter, n = 0) ->
		if n is @BEFOR then @bf.push waitter
		if n is @AFTER then @af.push waitter
		if n is @AVOID then @av.push waitter

	disListen: (waitter) ->
		@bf.delete waitter
		@af.delete waitter
		@av.delete waitter

	setcb: (@cb) ->

	cb: (args...) -> console.log @name + ' callback: ' + args

	###*
	 * #{name}, #{name}After, #{name}Avoid
	 * @param  {Array} args... all type
	 * @return {boolean}  return true if succeed, else false
	###
	broadcast: (args) ->
		console.log 'broadcast: ' + @name
		passThis = true # if not break it would be true
		passFather = true # if no father would be true
		# notify all waitter
		for w in @bf
			continue if w.isSilence
			if w[@name](args...) is false
				passThis = false
				break
		# pass & call father broadcast
		if passThis and @father?
			passFather = @father.broadcast(args)
		# not pass this or father not pass
		if !passThis or !passFather
			console.log 'broadcast: ' + @name + 'Avoid'
			w[@name+'Avoid']?(args...) for w in @av
			return false
		# if passThis and passFather
		@cb.call(this, args...)
		console.log 'broadcast: ' + @name + 'After'
		w[@name+'After']?(args...) for w in @af
		return true

###*
 * attribute is all triggers
###
class EventManager

	constructor: () ->
		tree = [
			['whenAttack', 'whenMagicAttack', 'whenPhysicAttack']
			'whenCall',
			'whenRegain',
			['whenChange', 'whenEvolute']
			'whenTurnStart',
			'whenTurnEnd',
			['whenAddBuff', 'whenAddBadBuff', 'whenAddGoodBuff']
		]
		@init(tree)

	init: (exp, father = null) ->
		that = this
		createTree = (exp, father) ->
			if exp instanceof Array
				if exp[0] instanceof Array
					createTree(exp[0], father)
					for e in exp[1...]
						createTree(e, father)
				else
					t = that[exp[0]] = new Trigger(exp[0], father)
					for e in exp[1...]
						createTree(e, t)
			else
				that[exp] = new Trigger(exp, father)
		createTree(exp, father)

	clear: () ->
		for k, v of this when v instanceof Trigger
			v.clear()

	setcbs: (cbs) ->
		for key, cb of cbs
			@[key]?.setcb cb

	listen: (waitter, eventName) ->
		n = 0
		t = eventName.indexOf('After')
		if t > 0
			n = 1
			eventName = eventName[0...t]
		d = eventName.indexOf('Avoid')
		if d > 0
			n = 2
			eventName = eventName[0...d]
		unless @[eventName]? then throw 'listen to a trigger not defined: ' + eventName
		@[eventName].listen(waitter, n)

	disListen: (waitter, eventName) ->
		if @[eventName]?
			@[eventName].disListen(waitter)

	broadcast: (eventName, args...) ->
		unless @[eventName]? then throw 'broadcast a trigger not defined: ' + eventName
		return @[eventName].broadcast(args)


# ************* check **************
checkEM = (e) ->
	console.log 'checkEM--------------------'
	for k, v of e when v instanceof Trigger
		console.log e[k].name + ' -> ' + e[k].father?.name
	console.log 'checkEM end----------------'

checkEMBuff = (e) ->
	console.log 'checkEMBuff----------------'
	for k, v of e when v instanceof Trigger
		temp = e[k]
		console.log k + ': '
		console.log temp.bf.concat(temp.af).concat(temp.av)
	console.log 'checkEMBuff end------------'
# ************* check **************
# checkEM(em)

# console.log em
# em.broadcast('whenCall', 1,2,3,4)

# console.log em.whenGet


# create buff with the tag to add to Trigger
# tags: array, triggers name
# cost: int, for hearthstone
# atk: int,
# maxHp: int,
# isSilence: bool
# owner: CardMode
# lifeTime: int
# turnCount: int, for life,(to freaze)
# onUpdate: function, call back function
# table: Table
class Buff

	this::isSilence = false

	this::owner = null #a default owner to test
	this::lifeTime = 1 #default lifeTime is 1
	
	constructor: (initial) ->
		console.log 'create a buff'
		@turnCount = 0
		@tags = []
		for key, value of initial
			@tags.push key if key.indexOf('when') is 0 #create the tags by it's attribute
			@decorateByST key, value

	# the default interval is 1
	turnUpdate: (n) ->
		@lifeTime -= n
		@turnCount += n
		unless @lifeTime > 0 then return
		unless @isSilence is false then return
		@onUpdate?(n)

	# should be used by card
	activate: -> #add it to cetain tags in gs
		@table.em.listen this, tag for tag in @tags

	destroy: -> #disActivate the card from the gs
		@table.em.disListen this, tag for tag in @tags

	# higher order function? to decorate the func and add to this
	# decorate by silence and lifeTime
	decorateByST: (key, func) ->
		#if this[key]? then throw new Error 'the key has already exist'
		this[key] = (args...) ->
			if @isSilence or (@lifeTime <= 0) then return
			func.call this, args...

Buff.testBuff = () ->
	return new Buff(
		whenAttack: ->
			console.log 'buff attack log'
		whenAttackAfter: ->
			console.log 'buff attack after log'
	)

class BuffHandler

	constructor: () ->
		@buffs = []

	setPlayerAndTable: (@player, @table) ->
		return this

	addBuff: (buff) ->
		buff.owner = this
		buff.table = @table
		buff.activate()
		@buffs.push buff

	removeBuff: (buff) ->
		buff.destroy()
		buff.owner = null
		buff.table = null
		@buffs.delete buff

#
#(x, y): int, in grid
#buffs: array, buffs array
#skills: array, to hold skills
#player: Player,
#table: Table,
#
#hp: int
#maxHp: int
#hpRate|_hpRate: int
#hpExtra: int
#
class CardMode extends BuffHandler
	#data
	this::hp = 310
	this::maxHp = 310
	this::_hpRate = 1
	this::hpExtra = 0

	this::x = 0 # in grid
	this::y = 0

	constructor: (@pd, @pl) ->
		super()
		@createData() if @pd?
		@skills = []

	createData: () ->
		@id = @pd.id
		@name = @pd.name
		@hp = @pd.hp
		@maxHp = @pd.hp
		@atk = @pd.atk
		@def = @pd.def
		@satk = @pd.satk
		@sdef = @pd.sdef
		@spd = @pd.spd

	hpChange: (d) ->
		if d > 0 # heal
			@hp += d
			if @hp > @maxHp then @hp = @maxHp
		else if d < 0 # damage
			if @hpExtra > 0 # no damage
				@hpExtra += d
				if @hpExtra < 0 then @hpExtra = 0
			else 
				@hp += d
		return @

	turnUpdate: (n) ->
		for buff in @buffs
			buff.turnUpdate(n)
		@buffs = (b for b in @buffs when b.lifeTime > 0)

	# called by actionlist
	act: () ->
		@table.cmds.push(['actStart', this])
		# check
		# is skill ready to spell
		# is ready to Attack

	isAlive: () ->
		if @hp > 0
			return true
		else
			return false

	# static
	that = this
	this.property 'hpRate',
		set: (v) ->
			d = v / @_hpRate
			@hp *= d
			@maxHp *= d
			@_hpRate = v
		get: () ->
			return @_hpRate

	createAttribute = (name, value = 100) ->
		n = '_' + name
		r = name + 'Rate'
		e = name + 'Extra'
		l = '_' + name + 'Level' # ((4+t)/4) & (4/(4-t))
		v = name + 'Value'
		ln = name + 'Level'
		that::[n] = value
		that::[r] = 1
		that::[e] = 0
		that::[l] = 0
		that.property ln,
			set: (v) ->
				v = 6 if v > 6
				v = -6 if v < -6
				@[l] = v
				return this
			get: () ->
				return @[l]
		that.property v,
			set: (v) -> return this
			get: () ->
				t = @[ln]
				if t > 0
					t = (4 + t) / 4
				else if t < 0
					t = 4 / (4 - t)
				return @[name] * t
		that.property name,
			set: (v) ->
				@[n] = (v - @[e]) / @[r]
				return this
			get: () ->
				return @[n] * @[r] + @[e]

	createAttribute 'atk'
	createAttribute 'def'
	createAttribute 'satk'
	createAttribute 'sdef'
	createAttribute 'spd'
	createAttribute 'acc'

CardMode.testCard = (id, name) ->
	return new CardMode
		id: id or -1
		name: name or 'Unknown'

class Grid
	this::pokemon = null

	constructor: (@row, @col, @player, @table) ->
		@gridHandler = new BuffHandler()
		@gridHandler.setPlayerAndTable(@player, @table)

	setPokemon: (@pokemon) ->
		@pokemon.x = @col
		@pokemon.y = @row

	removePokemon: () ->
		@pokemon.x = -1
		@pokemon.y = -1
		@pokemon = null

###*
 * name: string
 * flag: number (DEFENSER = 0, ATTACKER = 1)
 * field: array, grids in battle field
 * playerHandler: CardMode, to handle player buffs
 * list: array, all pokemons
 * handList: array, pokemon in hand
 * callList: array, pokemon in battle
 * table: Table, battle field
###
class Player
	this::DEFENSER = 0
	this::ATTACKER = 1
	constructor: (@name, @flag, @table) ->
		@field = []
		@field.push(new Grid(@flag, i, this, @table)) for i in [0..2]
		@playerHandler = new BuffHandler() # to handle buffs
		@playerHandler.setPlayerAndTable(this, @table)

	setList: (@list) ->
		@handList = @list.slice(0)
		@callList = []
		t.setPlayerAndTable(this, @table) for t in @list

	createACard: (id, isHand = true, index = -1) ->
		# remember to setPlayerAndTable


###*
 * cmds: array, to log actions
 * defenser: player
 * attacker: player, to be enemy with each other
 * battle: array[2][3], to hold grids
 * list: array, to hold all pokemon
 * callList: array, which in battle, use when [actSequence]
 * actionList: array, used in [actSequence] in a turn
 * weatherHandler: CardMode, to handle weather buffs
###
class Table

	constructor: (attackerList, defenserList) ->
		table = this
		@init(attackerList, defenserList)
		@cmds = []
		@em = new EventManager()
		@em.setcbs({
			# turnCount: int
			whenTurnStart: (turnCount) ->
				table.cmds.push ['whenTurnStart', turnCount]

			# card: CardMode
			# driver: CardMode | Player
			# (row, col): to 
			whenCall: (card, driver, row, col) ->
				table.cmds.push ['whenCall', card, driver, row, col]
				console.log 'when call: ' + card.name
				player = (if driver instanceof Player then driver else driver.player)
				grid = table.battle[row][col]
				card = player.handList.shift()
				grid.setPokemon(card)
				table.callList.push(card)

			# card: CardMode
			# driver: CardMode | Player
			# (row, col): from
			whenRegain: (card, driver, row, col) ->
				table.cmds.push ['whenRegain', card, driver, row, col]
				console.log 'when regain: ' + card.name
				grid = table.battle[row][col]
				grid.removePokemon()
				player = (if driver instanceof Player then driver else driver.player)
				player.handList.push(card)
				table.callList.delete(card)

			# buff: Buff
			# toCard: CardMode
			# driver: CardMode | Player
			whenAddBuff: (buff, toCard, driver) ->
				table.cmds.push ['whenAddBuff', buff, toCard, driver]
				toCard.addBuff(buff)
		})

	init: (attackerList, defenserList) ->
		@defenser = new Player('npc', 0, this)
		@attacker = new Player('me', 1, this)
		@defenser.enemy = @attacker
		@attacker.enemy = @defenser
		@attacker.setList(attackerList)
		@defenser.setList(defenserList)
		#battle field
		@battle = [@defenser.field, @attacker.field]
		#all list
		@list = @defenser.list.concat @attacker.list
		#all call list
		@callList = []
		#current turn actions
		@actionList = []
		@weatherHandler = new BuffHandler() # to handle weather buffs
		@weatherHandler.setPlayerAndTable(null, this)

	# the aim is to sovle die together
	turnUpdate: (n) ->
		removeList = []
		# handle
		@weatherHandler.turnUpdate(n)
		@attacker.playerHandler.turnUpdate(n)
		@defenser.playerHandler.turnUpdate(n)
		t.gridHandler.turnUpdate(n) for t in @defenser.field
		t.gridHandler.turnUpdate(n) for t in @attacker.field
		# update
		for t in @list
			t.turnUpdate(n)
			if t.hp <= 0 then removeList.push t
		if removeList.length > 0
			# die action
			t.die() for t in removeList
			# remove
			@list = (t for t in @list when t.hp > 0)

	call: (who, to) ->
		unless who in [0, 1] and to in [0, 1, 2] then throw "[Table] call out of bound: who[#{who}], to[#{to}]"
		player = (if who is 0 then @defenser else @attacker)
		grid = @battle[who][to]
		p = player.handList[0]
		unless p? then return
		if grid.pokemon?
			@regain(who, to)
		@em.broadcast('whenCall', p, player, who, to) #
		return p

	regain: (who, to) ->
		unless who in [0, 1] and to in [0, 1, 2] then throw "[Table] regain out of bound: who[#{who}], to[#{to}]"
		player = (if who is 0 then @defenser else @attacker)
		grid = @battle[who][to]
		p = grid.pokemon
		unless p? then return
		@em.broadcast('whenRegain', p, player, who, to) #
		return p

	# todo:delete
	createInBattle: (p, row, col) ->
		# p.x = x
		# p.y = y
		# @battle[x][y].pokemon = p
		# @callList.push(p)
		# @list.push(p)

	get: (row, col) ->
		@battle[row][col].pokemon

	removeFromBattle: (row, col) ->
		p = @battle[row][col].pokemon
		@battle[row][col] = null
		@callList.delete p
		return p	

	isEmpty: (row, col) ->
		if @battle[row][col].pokemon is null then return true
		else return false

	actSequence: () ->
		@actionList = @callList.slice(0)
		while @actionList.length > 0
			p = @getFirstAction()
			p.act()
			console.log 'actSequence : ' + p.spd

	getFirstAction: () ->
		# sort actionList by spd, decrease sort
		sortBySpd = (a, b) ->
			return -1 * (a.spd + a.spdLevel - b.spd - b.spdLevel)
		@actionList.sort(sortBySpd)
		return @actionList.shift()

	# next instruction
	next: (n) ->
		@cmds = []
		# put card in table 
		@call(1, n)
		# wait ai
		t = random(3)
		@call(0, t)
		# turn start
		@em.broadcast('whenTurnStart', 0)
		# attack in sequence
		@actSequence()
		# turn end
		@em.broadcast('whenTurnEnd', 0)



# c = new CardMode()
# c.addBuff(Buff.testBuff())
# c.atkExtra = 50
# c.hpRate = 2
# c.hpExtra = 100
# c.hpChange -10000
# c.hpRate = 1
# console.log c.hp
# console.log c.hpExtra
# c.turnUpdate(1)
# c.turnUpdate(1)
# em.broadcast('whenAttack', 1,2,3)
# checkEMBuff(em)

a = []
for i in [0...6]
	a.push CardMode.testCard()
b = []
for i in [0...6]
	b.push CardMode.testCard()

table = new Table(a, b)
skill = {
	whenCallAfter: (card, driver, x, y) ->
		console.log 'skill catch: ' + card.spd
		table = card.table
		em = card.table.em
		if y is 1
			table.cmds.push ['showSkill', 'owner', 'skill']
			em.broadcast('whenRegain', card, driver, x, y)
}
table.em.listen(skill, 'whenCallAfter')

table.call 1, 1
	.spd = 1
t = table.call 1, 2
t.spd = 100
t.spdLevel = -6
table.actSequence()
table.regain 1, 1

#console.log t.spdValue
console.log table.cmds
# console.log table.battle[1][2].pokemon.buffs

# 
root = exports ? window
root.Trigger = Trigger
root.EventManager = EventManager
root.Buff = Buff
root.CardMode = CardMode
root.Table = Table


