String::Trim = () ->
	return @replace(/(^\s*)|(\s*$)/g, "")

# ** no bracket
countTab = (str) ->
	count = 0
	for i in [0...str.length]
		if str[i] is '\t' then count++
		else break
	return count

# ':' Chinese or English
# ',' Chinese or English
parseOneLine = (line) ->
	line.replace(/：/g, ':')
	n = line.indexOf(':')
	result = []
	if n > -1
		result.push line[0...n] if n isnt 0
		result.push ':'
		result.push line[n+1...]
	else
		result = line.Trim().split(' ')
	return (t for t in result when t isnt '')

parseLine = (src) ->
	lines = src.replace(/\r\n/g, '\n').split('\n')
	lines = (t for t in lines when t.Trim() isnt '')
	createCmd = (n, tab) ->
		cmd = []
		while n < lines.length
			l = lines[n]
			ctab = countTab(l)
			if ctab is tab
				cmd.push(parseOneLine(l))
				n++
			else if ctab > tab
				lc = cmd.pop()
				[n, tc] = createCmd(n, ctab)
				cmd.push [lc..., tc...]
			else
				return [n, cmd]
		return [n, cmd]
	[n, cmd] = createCmd(0, 0)
	return cmd

# ** with bracket
atom = (s) ->
	s = s.Trim()
	if s is '('
		return '['
	if s is ')'
		return '],'
	if s is ','
		return ''
	return "\'" + s + "\',"

###*
 * parseStp as a tree
 * use ", ( ) \s " to split
 * @param  {string} src the source text
 * @return {array}     the tree
###
parseStp = (src) ->
	# parseStp tree " , ( ) "
	tokens = src.replace(/\(/g, ' ( ')
	.replace(/\)/g, ' ) ')
	.replace(/,/g, ' , ')
	.replace(/\t/g, ' ')
	.split(' ')
	t = (atom(s) for s in tokens when s.Trim() isnt '')
	.join(' ')
	t = t.substring(0, t.length-1) # delete the last ','
	try
		eval(t)
	catch error
		console.log error
		console.log src
		return error


###*
 * aim = {
 *  	showChoice: (arg) ->
 *  	check: (arg)->
 *  	flag: (arg)->  	
 * }
###
class Kernel
	###*
	 * create a kernel with source code
	 * @param  {string} str source code
     * @param  {layer} target
	###
	constructor: (str, @evn) ->
		@init(str)

	init: (str) ->
		@jscode = {}
		@cmds = [parseLine(str)]
		@waitInput = false

	###*
	 * run next command
	 * skip, string
	 * fix, [[]] to []
	 * @param  {number}   n [choice]
	 * @return {runMessage}
	 * 'error', 'end', 'waitChoice', 'noFunction'
	###
	next: (n) ->
		if @waitInput and (not n?)
			console.log 'input error: wait input'
			return 'waitChoice'
		exp = @cmds.pop()
		unless exp?
			console.log 'script end'
			return 'end'
		if exp instanceof Array is false
			console.log 'skip: ' + exp
			return @next()
		else if exp.length is 1
			console.log 'fix: ' + exp[0]
			@cmds.push(exp[0])
			return @next()
		else if exp[0] instanceof Array
			@cmds = @cmds.concat(exp.reverse())
			return @next()
		else if typeof exp[0] is 'string'
			console.log 'exp is : ' + exp[0]
			switch exp[0]
				when 'sequence'
					if exp.length < 2 # sequence, A
						console.log 'error: sequence is not enough'
						return 'argumentError'
					exp.reverse()
					@cmds = @cmds.concat(exp[...-1])
					return @next()
				when 'choice'
					if exp.length < 3 # choice, A, B
						console.log 'error: choice is not enough'
						return 'argumentError'
					unless n?
						@evn.showChoice(exp[1...])
						console.log 'choice wait command'
						@cmds.push(exp)
						@waitInput = true
						return 'waitChoice'
					else
						console.log 'chooce ' + n
						if n < 1 or n > exp.length
							console.log 'error: choice is out of bound'
							return 'error'
						@waitInput = false
						exp[n][0] = 'sequence'
						@cmds.push(exp[n])
						return @next()
				when 'if'
				# use my eval to choice, temp use only support 'check'
					if exp.length < 3 # if, condition, A, [b]
						console.log 'error: condition is not enough'
						return 'argumentError'
					cond = @evn.check(exp[1])
					if cond
						@cmds.push(exp[2])
					else if exp.length is 4
						@cmds.push(exp[3])
					return @next()
				when 'goto'
				# to find the tag
					console.log 'to find tag: ' + exp[1]
					temp = @findTag(exp[1])
					if temp >= 0
						@cmds = @cmds[0...temp]
						return @next()
					# else find path
					return 'goto'
				else
					if exp.indexOf(':') isnt -1
						@evn._showText('character:' + exp)
						return 'character'
					else
						console.log 'no function'
						@evn._showText('no function: ' + exp)
						return 'noFunction'

	findTag: (str) ->
		for i in [@cmds.length-1..0]
			if @cmds[i][0] is 'tag' and @cmds[i][1] is str
				return i
		return -1


DialogLayer = cc.Layer.extend
	_loadRes: () ->
		cc.spriteFrameCache.addSpriteFrames(res.res_plist)
		cc.textureCache.addImage(res.res_png)

	_loadStp: (name) ->
		return cc.loader._loadTxtSync('src/' + name)

	_createUI: () ->
		that = this
		size = cc.winSize
		@ui = {}

		# backGround
		t = @ui.backGround = new cc.Sprite('res/background/bg.jpg')
		t.attr(
			x: size.width / 2
			y: size.height / 2
			scale: 1.2
		)
		@addChild t, -10
		# back Mask
		t = @ui.backMask = new cc.Sprite(res.black_back)
		t.attr(
			x: size.width / 2
			y: size.height / 2
			scale: 8
		)
		@addChild t, -1
		t.setVisible(false)

		# dialogBack
		t = @ui.dialogBack = new ccui.ImageView(res.dialog_back)
		t.setScale9Enabled(true)
		t.setContentSize(cc.size(size.width - 40, size.height * 0.3))
		t.attr(
			x: size.width / 2
			y: t.height / 2 + 10
		)
		@addChild t, 10
		# dialogTxt
		t = @ui.dialogTxt = new ccui.Text("","Arial",28);
		t.ignoreContentAdaptWithSize(false);
		t.setContentSize(@ui.dialogBack.width-40, @ui.dialogBack.height-30);
		t.attr(
			x: @ui.dialogBack.width / 2
			y: @ui.dialogBack.height / 2
		)
		t.setTextColor(cc.color(0,0,0,255))
		t.setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
		@ui.dialogBack.addChild t, 10

		# choice back
		t = @ui.choiceBack = new cc.Sprite(res.black_back)
		t.attr(
			x: size.width / 2
			y: size.height / 2
			scale: 8
		)
		@addChild t, 20
		t.setOpacity 0

		# choice pane
		t = @ui.choicePane = new cc.Node()
		@addChild t, 21
		t.setVisible false

		# character

	_showChoice: (c) ->
		unless c instanceof Array then throw 'showChoice error'
		layer = this
		size = cc.winSize
		@evn.isWaitingChoice = true
		@ui.choiceBack.runAction(cc.fadeIn(0.6))
		@ui.choicePane.setVisible true
		n = c.length
		offsetY = (n - 1) / 2
		choiceAction = ->
			if @opacity < 60 then return # to see choice clearly
			if @_waitDelete? is true then return
			choice = this
			layer.scheduleOnce( ->
				layer._hideChoice()
			,1.5)
			layer.scheduleOnce( ->
				layer.k.next(choice.choiceIndex)
				layer.evn.isWaitingChoice = false
			,2.5)
			@runAction(cc.sequence(
				cc.spawn(
					cc.scaleTo(0.8, 1.6).easing(cc.easeSineInOut())
					cc.moveTo(0.8, size.width/2, size.height/2))
				cc.blink(0.6, 3).easing(cc.easeSineIn())
			))
			j = 0
			for tc in layer.ui.choicePane._children when tc isnt @
				tc._waitDelete = true
				tc.runAction(cc.sequence(
					cc.delayTime(j++ * 0.4)
					cc.spawn(
						cc.moveBy(1, 400, 0).easing(cc.easeSineInOut())
						cc.fadeOut(1)
					)
				))

		for i in [0...n]
			t = new cc.LabelTTF(c[i], "Arial", 36)
			t.choiceIndex = i + 1
			t.attr({
				x: size.width / 2
				y: size.height / 2 - 36 * 1.8 * (i - offsetY)
				opacity: 0})
			@ui.choicePane.addChild t, 10
			t.runAction(cc.sequence(cc.delayTime(0.25*(i+1)), cc.fadeIn(0.6)))
			gs(t).click(choiceAction)

	_hideChoice: () ->
		@ui.choiceBack.runAction(cc.fadeOut(0.6))
		@ui.choicePane.setVisible false
		@ui.choicePane.removeAllChildren true

	_showText: (text = '') ->
		that = this
		@evn.isShowingText = true
		@evn.currentText = text
		count = 0
		@_showTextSchedule = () ->
			count++
			that.ui.dialogTxt.setString(text[0..count])
			if count > text.length
				that.unschedule(that._showTextSchedule)
				that.evn.isShowingText = false
		@schedule(that._showTextSchedule, 0.15, cc.REPEAT_FOREVER, 0.1)

	_cutTextShow: () ->
		that = this
		that.unschedule(that._showTextSchedule)
		that.ui.dialogTxt.setString(that.evn.currentText)
		that.evn.isShowingText = false

	evn: {
		currentText: ''
		isShowingText: false
		isWaitingChoice: false
	}

	config: {
		showTextSpeed: 0.15
	}

	state: {
		storyProgress: 1
	}

	showChoice: (arg) ->
		c = (t[0] for t in arg)
		@_showChoice(c)

	check: (arg)->
		@_showText('check:' + arg)
		console.log 'call check : ' + arg
		return true

	flag: (arg)->
		@_showText('flag:' + arg)
		console.log 'call check : ' + arg
		return true

	ctor: () ->
		that = this
		@_super()
		@_loadRes()
		@_createUI()

		size = cc.winSize

		c1 = new cc.Sprite('res/character/c_a.png')
		c1.attr(
			x: 250
			y: 250
			scale: 1.5
		)
		c2 = new cc.Sprite('res/character/c_b.png')
		c2.attr(
			x: size.width - 250
			y: 250
			scale: 1.5
		)
		@addChild c1, 1
		@addChild c2, 2

		data = @_loadStp('temp.strip')
		if @k? then throw 'k is being used'
		@k = new Kernel(data, @)

		countn = 0
		gs(this).click(() ->
			if that.evn.isShowingText
				that._cutTextShow()
			else if that.evn.isWaitingChoice
				return 'wait choice'
			else
				that.k.next()
				console.log("dialogLayer.coffee click (#73): " + 'show next');  # TODO:debug
		)

#		@_showChoice(['选择1 aaa','选择2 bbb','选择3 ccc','选择4 eeeea'])
#		@_hideChoice()

#		console.log(@_loadStp('temp.strip')); #TODO:show details



root = exports ? window
root.DialogLayer = DialogLayer