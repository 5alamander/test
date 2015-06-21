/**
 * Created by Administrator on 2015/4/27.
 */
node_xj = require("xls-to-json");
console.log(node_xj);
result="";
//node_xj(
//    {
//        input: "originData.xls",
//        output: "t.js",// no use
//        sheet: "base"
//    },
//
//    function (err, r) {
//        if (err) {
//            console.log(err);
//        } else {
//            writeJS("originData", JSON.stringify(r));
//        }
//    }
//);

XlsToJs('originData.xls', 'base', 'originData');



function XlsToJs(xls, sheet, jsName) {
    node_xj(
        {
            input: xls,
            output: "t.js",// no use
            sheet: sheet
        },

        function (err, r) {
            if (err) {
                console.log(err);
            } else {
                writeJS(jsName, JSON.stringify(r));
            }
        }
    )
}

function writeJS(name, str) {
    var fs = require('fs');
    fs.writeFile(
        "../src/"+name+".js",
        name+"="+str+";",
        function (err) {
            if (err) {
                return console.log(err);
            }
            console.log(str);
            console.log('create originData.js');
        }
    );
}