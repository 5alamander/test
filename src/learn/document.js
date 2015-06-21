
/*
player drived this action
 */
function call(who, to) {}

function ragain(who, to) {}

/*
table.em.broadcast
 */

// whenTurnStart
em.broadcast('whenTurnStart', turnCount)
cmd = ['whenTurnStart', turnCount]

// whenTurnEnd
em.broadcast('whenTurnEnd', turnCount)

// whenCall
em.broadcast('whenCall', pokemon, dirver, x, y)
cmd = ['whenCall', pokemon, driver, x, y]

// whenRegain
em.broadcast('whenRegain', pokemon, dirver, x, y)
cmd = ['whenRegain', pokemon, driver, x, y]

// addBuff
em.broadcast('whenAddBuff', buff, toCard, driver)
cmd = ['whenAddBuff', buff, toCard, driver]

// showSkill
cmd = ['showSkill', pokemon, skill]


