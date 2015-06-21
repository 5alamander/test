/**
 * Created by Administrator on 2015/4/29.
 */
cc.tintBy(
    0.1,//duration
    255,//read
    255,//green
    255//blue
);

cc.blink(
    0.1,//duration
    2//blink times
);

cc.delayTime(
    1//duration
);

cc.follow(
    new cc.Node(),//follow node
    new cc.Rect()//follow range
);

/** easing */
cc.easeBounceIn();//起始位置弹性
cc.easeBounceOut();//结束位置弹性

cc.easeBackIn();//force back on start point
cc.easeBackOut();//force back on end point

cc.easeElasticIn();//elastic force on start point
cc.easeElasticOut();//elastic force on end point

cc.easeExponentialIn();//slow start
cc.easeExponentialOut();//slow end

cc.easeSineIn();//slow start by sin()
cc.easeSineOut();//slow end by sin()

cc.speed(
    new cc.moveBy(),
    10// speed
);

cc.repeat(
    new cc.fadeIn(1),//action
    1//times
);

cc.repeatForever(
    new cc.fadeIn(1)
);

cc.callFunc(
    function () {

    },
    this,//function target
    [1,2,3]//function parameter
);
