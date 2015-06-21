/**
 * Created by Berserk on 2015/4/21.
 * use name to find data in ObjectData.
 * use id to find data in ArrayData.
 */

// copy from the originData
// witch is
pokemonDataArray = originData;

// auto-create Object
pokemonDataObject = {};
for (i = 0, len = pokemonDataArray.length; i < len; i++) {
    var v = pokemonDataArray[i];
    if (i.name === null) throw "pokemonDataObject ERROR: a name has lost";
    pokemonDataObject[v.name] = v;
}

getPokemonData = function (n) {
    var type = typeof n;
    var r;
    if (type == 'number') {
        r = pokemonDataArray[n];
        if (typeof r == 'undefined') throw "there's no such id";
    }
    else if (type == 'string') {
        r = pokemonDataObject[n];
        if (typeof r == 'undefined') throw "there's no such name";
    }
    else
        throw "index must be 'number/string'";
    return r;
};
