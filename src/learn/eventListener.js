/**
 * Created by Administrator on 2015/4/30.
 */
var eventListener = cc.EventListener.create({
    event: cc.EventListener.MOUSE,
    onMouseDown: function (event) {

    }
});

var someTarget = {};
cc.eventManager.addListener(eventListener, someTarget /*[array]*/);