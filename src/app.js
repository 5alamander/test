
var HelloWorldLayer = cc.Layer.extend({
    sprite:null,
    ctor:function () {
        //////////////////////////////
        // 1. super init first
        this._super();

        /////////////////////////////
        // 2. add a menu item with "X" image, which is clicked to quit the program
        //    you may modify it.
        // ask the window size
        var size = cc.winSize;

        // add a "close" icon to exit the progress. it's an autorelease object
        var closeItem = new cc.MenuItemImage(
            res.CloseNormal_png,
            res.CloseSelected_png,
            function () {
                cc.log("Menu is clicked!");
                //cc.log(closeItem);

                cc.log("test webStorage");
                localStorage.clear();
                localStorage.setItem("test", JSON.stringify({a:1,b:2,c:[1,2,3]}));
                var str = localStorage.getItem("test");
                cc.log(str);
                str = JSON.parse(str);
                cc.log(str);

            }, this);
        closeItem.attr({
            x: size.width - 20,
            y: 20,
            anchorX: 0.5,
            anchorY: 0.5
        });

        var menu = new cc.Menu(closeItem);
        menu.x = 0;
        menu.y = 0;
        this.addChild(menu, 1);

        /////////////////////////////
        // 3. add your codes below...
        // add a label shows "Hello World"
        // create and initialize a label
        var helloLabel = new cc.LabelTTF("Hello World", "Arial", 38);
        // position the label on the center of the screen
        helloLabel.x = size.width / 2;
        helloLabel.y = 0;
        // add the label as a child to this layer
        this.addChild(helloLabel, 5);

        // add "HelloWorld" splash screen"
        this.sprite = new cc.Sprite(res.HelloWorld_png);
        this.sprite.attr({
            x: size.width / 2,
            y: size.height / 2,
            scale: 0.5,
            rotation: 180
//            skewX: 0,
//            skewY: 70
        });

//        this.sprite.runAction(
//        	cc.rotateBy(1, 30, 0)
//        )
        var that = this;
        var eventListener = cc.EventListener.create({
        	event: cc.EventListener.MOUSE,
        	onMouseDown: function(event) {

                if (that.sprite.getNumberOfRunningActions() > 0) {
                    cc.log("sprite is running")
                }
                else {
                    cc.log("add new action");
                    that.sprite.runAction(
                        //cc.rotateBy(1, -180, 0)
                        cc.orbitCamera(1, 1, 0, 0, 360, 0, 0)
                    );

                }

                cc.log(event);

            }
            //onMouseMove: function(event) {
            //    var pos = event.getLocation();
            //    cc.log("pos: ", parseInt(pos.x), parseInt(pos.y));
            //}

        });
        cc.eventManager.addListener(eventListener, this);

        this.addChild(this.sprite, 0);

        this.sprite.runAction(
            cc.sequence(
                cc.rotateTo(0.5, 0),
                cc.scaleTo(0.5, 1, 1)
                //cc.rotateBy(2,180,0)
            )
        );
        helloLabel.runAction(
            cc.spawn(
                cc.moveBy(2.5, cc.p(0, size.height - 40)),
                cc.tintTo(2.5,255,125,0)
            )
        );

        return true;
    }
});

var BattleScene = cc.Scene.extend({

    onEnter:function () {
        this._super();

        //*****can not use orbitCamera()
        //this.temp_projection = cc.director.getProjection;
        cc.director.setProjection(cc.Director.PROJECTION_2D);
        //cc.director.setDepthTest(true);

        //var layer = new HelloWorldLayer();
        var layer = new BattleLayer();
        //var layer = new TimerLayer();
        this.addChild(layer);
    },
    onExit: function() {
        //*****can not use orbitCamera()
        //cc.director.setProjection(this.temp_projection);
        //cc.director.setDepthTest(false);
    },
    update: function() {

    }

});

var WelcomeScene = cc.Scene.extend({
    onEnter: function () {
        this._super();

        cc.director.setProjection(cc.Director.PROJECTION_2D);

        var layer = new WelcomeLayer();
        this.addChild(layer)
    },
    onExit: function () {
    },
    update: function () {
    }
});

var MapScene = cc.Scene.extend({
    onEnter: function () {
        this._super();
        cc.director.setProjection(cc.Director.PROJECTION_2D);
        cc.director.setDepthTest(true);
        var layer = new MapLayer();
        this.addChild(layer)
    },
    onExit: function () {
    },
    update: function () {
    }
});

myDirector = {
    welcome: function () {
        MyLoaderScene.preload(g_resources,
            function () {
                var s;
                if(cc.sys.isMobile){
                    s = new cc.TransitionFade(1, new WelcomeScene());
                    cc.director.runScene(s)
                }else{
                    s = new cc.TransitionFade(1, new WelcomeScene());
                    cc.director.runScene(s)
                }
            },this)
    },

    battle: function () {
        gs.init();
        // get preLoad

        MyLoaderScene.preload(g_resources,
            function () {
                var s;

                if(cc.sys.isMobile){
                    s = new cc.TransitionFade(1, new BattleScene());
                    cc.director.runScene(s)
                }else{
                    s = new cc.TransitionFade(1, new BattleScene());
                    cc.director.runScene(s)
                }
            },this)
    },

    battle2: function () {
        gs.init();
        MyLoaderScene.preload(g_resources,
            function () {
                var s;
                if(cc.sys.isMobile){
                    s = new cc.TransitionFade(1, new BattleLayer2());
                    cc.director.runScene(s)
                }else{
                    s = new cc.TransitionFade(1, new BattleLayer2());
                    cc.director.runScene(s)
                }
            },this)
    },

    map: function (mapPath) {
        var res = ["res/map/室内.png",'res/map/室外.png',
            "res/map/室内2.png","res/map/player.png",
        "res/map/btna.png","res/map/btnb.png","res/map/padb.png","res/map/padf.png"];
        res.push(mapPath);
        MyLoaderScene.preload(res,
            function () {
                var s;
                if(cc.sys.isMobile){
                    mapLayer = new MapLayer(mapPath);
                    mapLayer.createButton();
                    s = new cc.TransitionFade(1, mapLayer);
                    cc.director.runScene(s)
                }else{
                    mapLayer = new MapLayer(mapPath);
                    mapLayer.createButton();
                    s = new cc.TransitionFade(1, mapLayer);
                    cc.director.runScene(s)
                }
            },this)
    },

    dialouge: function () {
        MyLoaderScene.preload(g_resources,
            function () {
                var s;
                if(cc.sys.isMobile){
                    s = new cc.TransitionFade(1, new DialogLayer());
                    cc.director.runScene(s)
                }else{
                    s = new cc.TransitionFade(1, new DialogLayer());
                    cc.director.runScene(s)
                }
            },this)
    }
};

myTools = {
    //+---------------------------------------------------
    //| 求两个时间的天数差 日期格式为 YYYY-MM-dd
    //+---------------------------------------------------
    daysBetween: function (DateOne,DateTwo){
        if (typeof DateOne !== 'string'){DateOne = DateOne.toString();}
        if (typeof DateTwo !== 'string'){DateTwo = DateTwo.toString();}

        var OneMonth = DateOne.substring(5,DateOne.lastIndexOf ('-'));
        var OneDay = DateOne.substring(DateOne.length,DateOne.lastIndexOf ('-')+1);
        var OneYear = DateOne.substring(0,DateOne.indexOf ('-'));

        var TwoMonth = DateTwo.substring(5,DateTwo.lastIndexOf ('-'));
        var TwoDay = DateTwo.substring(DateTwo.length,DateTwo.lastIndexOf ('-')+1);
        var TwoYear = DateTwo.substring(0,DateTwo.indexOf ('-'));

        var cha=((Date.parse(OneMonth+'/'+OneDay+'/'+OneYear)- Date.parse(TwoMonth+'/'+TwoDay+'/'+TwoYear))/86400000);
        return Math.abs(cha);
    },
    saveData: function() {
        localStorage.setItem("mySaves", JSON.stringify(mySaves));
        return mySaves;
    },
    loadData: function () {
        var str = localStorage.getItem("mySaves");
        if (str == null) return;
        mySaves = JSON.parse(str);
        return mySaves;
    },
    showStorage: function () {
        var output = "";
        if (window.localStorage) {
            if (localStorage.length) {
                for (var i = 0; i < localStorage.length; i++) {
                    output += localStorage.key(i) + ': ' + localStorage.getItem(localStorage.key(i)) + '\n';
                }
            } else {
                output += 'There is no data stored for this domain.';
            }
        } else {
            output += 'Your browser does not support local storage.'
        }
        console.log(output);
    }
};

mySaves = {};