# 2025-12-XXX
v1.7.1

- Refactored the code to be more clearly split up
    - data types and scoreboard rows put into their own files
    - these files are loaded by the main logic before they're used
    - also made local copies of references to these to avoid the global table lookup every time
        - mainly for the enemy types and attack types
        - but it covers the ammo and disabled stuff too
- Added debug messages for missing enemy breeds
    - added "skip" section for intentionally not categorized enemies
        - it's just the two ritualists at the moment
        - they are internally classified as `ritualist` instead of lessers or whatever, and I don't think it's justified to create a whole new row for this (considering how many there already are)
    - this is like the damage types report. when there's an unrecognized enemy, it'll print a message saying what it is

# 2025-12-02
v1.7.0

No Man's Land - Hive Scum

- Fixed crash from ammo values
    - `current_ammunition_clip` and `max_ammunition_clip` are now table returns
- Added Toxin damage row
- Added Hive Scum missile launcher backblast to ranged damage `missile_launcher_knockback`
- Refactored (devs only)
    - Uncategorized types, error message
        - put into function
        - less copy pasted code
    - Local references for global functions
        - for less overhead
        - these get called a looot
    - Reused localizations are now stored in variables

# 2025-10-01
v1.6.1

- Fixed typo for explosions affecting melee hitrate in localization
- Some localizations Sai added

# 2025-09-26
v1.6.0

- Added toggles for explosions affecting hitrates
    - One for ranged and one for melee, both defaulted to `true` to be consistent with the original settings
    - So it doesn't artificially deflate your crit/weakspot rate
        - I don't think explosions can crit
        - There are settings for the server to override explosions to not do crits
        - in `scripts/extension_systems/weapon/actions/action_melee_explosive` there's a check to set `is_critical_strike = false` every time
    - Created a helper function to check for it
        - Checks if user wants this to not happen
        - Checks if the end of the damage type ends in "explosion"
            - in `scripts/settings/equipment/weapon_templates/bolt_pistols/settings_templates/boltpistole_damage_profile_templates`
            - there is an entry `damage_templates.boltpistol_stop_explosion`
            - this naming scheme is consistent with other bolter explosions
            - hopefully this doesn't mess up later :)

# 2025-09-25
v1.5.2

- `game_mode` instead of `game_mode_manager`
- I had it like this before but decided to change it for no reason :)

# 2025-09-24
v1.5.1

- Fixed Havoc manager location change, causing the error on map change (fr this time??)
- It got moved to havoc_extension from `Managers.state.game_mode_manager():extension("havoc")`
    - looks like this new one also doubles as the check for if you're on havoc or not
    - settings table was the same afaik

# 2025-09-23: Bound by Duty
v1.5.0

- Added Scab Plasma Gunner
- Fixed Havoc manager location change, causing the error on map change (thanks Wobin and Vatinas)

# 2025-08-UNRELEASED
v1.4.1

MOVED TO BRANCH BECAUSE IT DIDN'T WORK LOL

- Refactored code to manage blank rows on the Scoreboard, `manage_blank_rows()`
    - What it actually does is make sure that blank values are actually blank, instead of "lol" (which is what the base Scoreboard does)
    - Before, the logic to check if this needed to be done was being executed **literally every game tick**
    - This *needs* to be done:
        - Before the Scoreboard is shown
        - After a new player joins
    - Now, I trimmed it down to two main situations:
        1. Before (and while) the Scoreboard is shown in the Tactical Overlay
        2. Right at match end, on entering the end view
    - Removed from `manage_blank_rows()`:
        - Only run during matches check, `in_match` 
            - The hooks and other checks inside of it account for only working when there's players
            - Now it can work when entering the end view screen
        - Empty text per players check, `not row["data"][account_id]["text"]`
            - Initialized blank rows
            - When it ran every tick, it intercepted the scoreboard immediately when a player joined, so this check was to make that only run once that happens instead of writing blank rows every single time
            - Since blank rows won't be overwritten
    - Removed `replace_row_value("highest_single_hit", ...)` from `set_blank_rows()`
        - When it was initializing blank rows, it also set highest damage in a single hit to 0 to initialize
        - There is already a fallback in the actual counting
        - However, if a player joins without doing any damage, this won't happen
        - Moved the check to `manage_blank_rows()`
            - Has its own check
            - Before, it wouldn't happen if the first blank row was already handled

# 2025-07-26
v1.4.0

- Fixed incorrect wasted ammo check for Ammo Crates
    - stupid bitch made a typo
    - die
- Refactors
    - Helper function to check settings when there's a subwidget for havoc only
    - Helper functions to create widgets with a subwidget for havoc only
    - Standardized havoc only widget titles so I can reuse the one localization text
- Added option to track ammo crate waste only in Havoc (technically a new feature so it's 1.4.0 instead of 1.3.1, by my standards)

# 2025-07-25
v1.3.0

- Fix for Havoc crate pickups (thanks for noticing, Vatinas!)
    - Havoc modifier was being applied only to the ammo missing, not the actual pickup amount, so values were too low
        - e.g. Have 40% ammo and use crate with Havoc modifier of 85%
        - OLD: pickup was calculated as 60% * 85% = 51%
        - NEW: Pickup is 100% * 85% = 85%
    - Now calculates actual pickup amount and percentage
- Added more settings options
    - Grouped up ammo settings (messages and waste)
    - Added toggle to track ammo crate waste (defaulted to off to not have unexpected changes)
    - Added toggle to add ammo crate to total percentage of pickup
        - Added toggle to only do this in Havoc
        - Defaults to off to not have unexpected changes
- Refactored
    - Ammo pickup variables moved around to have less copied code (now that waste can be tracked for both)
    - Scoreboard mod check
        - Needs to check if Scoreboard is installed
        - Before, it was checking this... literally every single time something needed to be tracked...
        - Now I check it once on startup, when all mods load, and exit with an error message if it's not found
        - Also removed the checks for `if scoreboard then` because it's implied by having reached this far
    - Made mod version a global
        - Slightly worse performance on restart
        - Now other mods can check this mod's version, in case they rely on one of the features from a specific version onward
        - ...Nobody is going to do this
    - Moved hooks to only be executed after all mods are loaded, so they don't get executed if Scoreboard is not installed
- Logged uncategorized ammo pickup types, in case that's ever a thing
- Style
    - Moved helper functions above hooks
    - Indented breed tables and such, so my IDE can collapse them all at once
- Completely shit my pants when I saw `mod:manage_blank_rows()` was being called LITERALLY EVERY GAME TICK? BUTTER MY BUTT AND CALL ME A BISCUIT

# 2025-07-08
v1.2.5

- Localization fixes from Sai

# 2025-07-08
v1.2.4

- Added Brazilian Portuguese localization from Talesz

# 2025-07-08
v1.2.3

- Added fallback for havoc ammo modifier
    - Defaults to 1 if not found in table (low havocs don't use the values from that)
    - Added silent logging for this so I can debug later
- Made local variable for tostring for performance

# 2025-07-07
v1.2.2

- Readded the debug message suppression (how did that disappear???)
    - now also prints it silently into the log if they're suppressed
    - probably lost it when i used the versions with localizations from the nexus page
- Added `psyker_heavy_swings_shock` to ranged damage (tyvm syllogism :prayge:)
    - Put in ranged because it's electrocution on heavies from Smite sub talent and dog electrocution remote detonation (`adamant_whistle_electrocution` so I'm assuming that's what it is)
    - In `settings/buff/weapon_buff_templates.lua` they added the buff category to it, so before it was probably defaulting to melee/ranged (checked myself and thanks to syllogism for checking first)
    - `templates.adamant_whistle_electrocution.attack_type = attack_types.buff`

# 2025-07-01
v1.2.2-beta-fail

- Added check to separate shock maul electrocution and dog electrocution
    - Put `shockmaul_stun_interval_damage` into both `melee_damage_profiles` and `companion_damage_profiles`
    - Add to melee damage if it matches the damage profile AND attack type was NOT dog
    - No check needed for companion damage because it's an elseif
- nvm this was shit

# 2025-07-01
v1.2.1-beta

- Added localizations for new settings
    - I don't know who added these so I can't credit :(
    - Russian, Simplified Mandarin, and Traditional Mandarin
    - Originally these were from xsSplater, deluxghost, and SyuanTsai respectively (idk if they came back to do these new ones)

# 2025-06-27
v1.2.0-beta-branch

- Moved some units and damage types around
    - Mutator disablers (Grandfather's Gifts) from specialists to disablers. **Thanks Tunnfisk!**
    - Fix for bleed and warpfire damage counting as melee (removing buff from melee type. **thanks syllogism!**)
    - Moved `shockmaul_stun` to dog damage type, since shock maul electricity damage is less important than dog shocks (thanks for the suggestion syllogism!). Planning on a "cleaner" solution to this later
- Added ammo pickup modifiers from Havoc (pickups give less)
    - Check if mission is Havoc when starting a mission
    - If so, set the ammo modifier from the Havoc settings template
- Some code reorganizing to make it easier for me to read
- Coding style for the localizations