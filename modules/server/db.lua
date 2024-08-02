return {
    UPDATE_JAILTIME = 'UPDATE %s SET jailtime = ? WHERE %s = ?',
    LOAD_JAILTIME = 'SELECT `jailtime` FROM `%s` WHERE `%s` = ?',
    GET_INVENTORY = 'SELECT * FROM ox_inventory WHERE owner = ? AND name = ?',
    DELETE_INVENTORY = 'DELETE FROM ox_inventory WHERE name = ?'
}