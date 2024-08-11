
-- List of resources with compat

return {
    xt_prisonjobs = (GetResourceState('xt-prisonjobs') == 'started'),
    randol_medical = (GetResourceState('randol_medical') == 'started'),
    qb_target = (GetResourceState('qb-target') == 'started'),
}