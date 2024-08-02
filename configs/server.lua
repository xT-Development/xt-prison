return {
    EnableJailCommand = true,                   -- Jail command using ox_lib input menu

    PlayersDatabaseTable = 'players',           -- Database table name for players (set this for your framework)
    PlayersDatabaseIdentifier = 'citizenid',    -- Players identifier column in the database (set this for your framework)

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