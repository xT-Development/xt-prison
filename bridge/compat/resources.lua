
-- List of resources with compat

return {
    randol_medical = (GetResourceState('randol_medical') == 'started'),
    qb_target = (GetResourceState('qb-target') == 'started'),
}