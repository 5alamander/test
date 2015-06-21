/**
 * Created by Berserk on 2015/4/14.
 */

//write
localStorage.setItem("key", "data");

//read
var data = localStorage.getItem("key");
var key = localStorage.key(12);

//remove
localStorage.removeItem('key');
localStorage.clear();

//travel
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

//write json
localStorage.setItem("test", JSON.stringify({a:1,b:2,c:[1,2,3]}));
data = localStorage.getItem("test");
data = JSON.parse(data);

//data type
var r = typeof data;
/**
 typeof   2      输出   number
 typeof   null   输出   object
 typeof   {}    输出   object
 typeof    []    输出   object
 typeof   (function(){})   输出  function
 typeof    undefined         输出  undefined
 typeof   '222'                 输出    string
 typeof  true                   输出     boolean
 */

var r = Object.prototype.toString.call(data);
/**
 var   gettype=Object.prototype.toString
 gettype.call('aaaa')        输出      [object String]
 gettype.call(2222)         输出      [object Number]
 gettype.call(true)          输出      [object Boolean]
 gettype.call(undefined)  输出      [object Undefined]
 gettype.call(null)                  输出   [object Null]
 gettype.call({})                   输出   [object Object]
 gettype.call([])                    输出   [object Array]
 gettype.call(function(){})     输出   [object Function]
 */