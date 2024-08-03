local qb = (GetResourceState('qb-core') == 'started')
local esx = (GetResourceState('es_extended') == 'started')
local ox = (GetResourceState('ox_core') == 'started')
local nd = lib.checkDependency('ND_Core', '2.0.0')

local db = {
    table = qb and 'players' or esx and 'users' or nd and 'nd_characters' or ox and 'characters',
    identifier = qb and 'citizenid' or esx and 'identifier' or nd and 'charid' or ox and 'charid',
}

return {
    UPDATE_JAILTIME = ('UPDATE %s SET jailtime = ? WHERE %s = ?'):format(db.table, db.identifier),
    LOAD_JAILTIME = ('SELECT `jailtime` FROM `%s` WHERE `%s` = ?'):format(db.table, db.identifier),
    GET_INVENTORY = 'SELECT * FROM ox_inventory WHERE owner = ? AND name = ?',
    DELETE_INVENTORY = 'DELETE FROM ox_inventory WHERE name = ?'
}