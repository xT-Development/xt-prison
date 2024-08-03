return {
    EnableJailCommand = true,                   -- Jail command using ox_lib input menu

    UnemployedJobName = 'unemployed',           -- Name of unemployed job (if remove job is enabled)

    CanteenMeal = {                             -- Food & Drink received from canteen
        food = {
            item = 'burger',
            count = 1
        },
        drink = {
            item = 'water',
            count = 1
        }
    },

    PoliceJobs = {                              -- Police jobs
        'police',
        'lspd',
    },

    Lifers = {                                  -- Lifer identifiers
        'RANDOLIOCID',
        'QWADEBOTCID'
    }
}