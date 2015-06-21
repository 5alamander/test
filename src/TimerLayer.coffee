TimerLayer = cc.Layer.extend
	ctor: () ->
		@_super()
		size = cc.winSize

		that = this
		this.tc = 0
		@schedule(
			() ->
				that.tc += 1
			1, #interval
			cc.REPEAT_FOREVER, #repeat
			2, #delay
		)
		@schedule(@timeCallBack, 1, 10, 1)
		@scheduleOnce(@timeCallBackOnce, 10)

#		@scheduleUpdate()

	timeCallBack: () ->
		cc.log 'timeCallBack'

	timeCallBackOnce: () ->
		cc.log 'timeCallbackOnce'

	update: (dt) ->
		cc.log 'update'

root = exports ? window
root.TimerLayer = TimerLayer
