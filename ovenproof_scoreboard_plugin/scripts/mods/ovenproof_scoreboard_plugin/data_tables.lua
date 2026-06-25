local mod = get_mod("ovenproof_scoreboard_plugin")

-- ------------
-- Enemy Breeds
-- ------------
mod.melee_lessers = {
    "chaos_newly_infected",
    "chaos_poxwalker",
    "cultist_melee",
    "renegade_melee",
    "chaos_armored_infected",
    "chaos_mutated_poxwalker",
    "chaos_lesser_mutated_poxwalker",
    "cultist_vanguard",
    "renegade_vanguard",
}
mod.ranged_lessers = {
    "cultist_assault",
    "renegade_assault",
    "renegade_rifleman",
}
mod.melee_elites = {
    "cultist_berzerker",
    "renegade_berzerker",
    "renegade_executor",
    "chaos_ogryn_bulwark",
    "chaos_ogryn_executor",
}
mod.ranged_elites = {
    "cultist_gunner",
    "renegade_gunner",
    "cultist_shocktrooper",
    "renegade_shocktrooper",
    "chaos_ogryn_gunner",
    "renegade_radio_operator",
    "renegade_plasma_gunner",
}
mod.specials = {
    "chaos_poxwalker_bomber",
    "renegade_grenadier",
    "cultist_grenadier",
    "renegade_sniper",
    "renegade_flamer",
    "cultist_flamer",
}
mod.disablers = {
    "chaos_hound",
    "chaos_hound_mutator",
    "cultist_mutant",
    "cultist_mutant_mutator",
    "renegade_netgunner",
    "chaos_armored_hound",
}
mod.bosses = {
    "chaos_beast_of_nurgle",
    "chaos_daemonhost",
    "chaos_spawn",
    "chaos_plague_ogryn",
    "chaos_plague_ogryn_sprayer",
    "renegade_captain",
    "renegade_twin_captain",
    "renegade_twin_captain_two",
    "cultist_captain",
    "chaos_mutator_daemonhost",
    "chaos_ogryn_houndmaster",
}
mod.skip = {
    "chaos_mutator_ritualist",
    "cultist_ritualist",
    -- what the fuck is "nurgle_flies",
}
-- ------------
-- Damage Types
-- ------------
mod.melee_attack_types ={
    "melee",
    "push",
    -- "buff", -- regular Shock Maul and Arbites power maul stun intervals. also covers warp and bleed so don't use lol
}
mod.melee_damage_profiles ={
    -- "shockmaul_stun_interval_damage", -- shock maul electrocution and Arbites dog shocks. dog shock is more important imo so I put it there
    "powermaul_p2_stun_interval",
    "powermaul_p2_stun_interval_basic",
    "powermaul_shield_block_special",
    "powermaul_p3_arc_chain_lightning_link_damage", -- Skitarii arc maul jumps
    "chain_lightning_killing_blow",
}
mod.ranged_attack_types ={
    "ranged",
    "explosion",
    "shout",
}
mod.ranged_damage_profiles ={
    "shock_grenade_stun_interval",
    "psyker_protectorate_spread_chain_lightning_interval",
    "default_chain_lighting_interval",
    "psyker_smite_kill",
    "psyker_heavy_swings_shock", -- Psyker Smite on heavies and Remote Detonation on dog?
    "missile_launcher_knockback", -- Hives Cum backblast
    "arc_rifle_arc_chain_lightning_link_damage", -- Skitarii arc rifle jumps
    "cryptic_discharge_shock_damage", -- Skitarii voltage overload thing. Putting it here as a fallback for if not tracking blitz
    "cryptic_discharge_weapon_shock", 
    "discharge_chain_jump_damage",
    "arc_grenade_chain_jump_damage", -- Skitarii Arc Grenade. Putting it here as a fallback for if not tracking blitz
}
mod.blitz_attack_types ={
	"psyker_test",
}
mod.blitz_damage_profiles ={
	"psyker_smite_kill",
	"psyker_protectorate_channel_chain_lightning_activated",
	"psyker_protectorate_spread_chain_lightning_interval",
	"psyker_protectorate_chain_lighting",
	"psyker_protectorate_chain_lighting_fast",
	"psyker_throwing_knives",
	"psyker_throwing_knives_aimed",
	"psyker_throwing_knives_aimed_pierce",
	"psyker_throwing_knives_psychic_fortress",
	"zealot_throwing_knives",
	"psyker_heavy_swings_shock",
	"whistle_explosion",
	"close_whistle_explosion",
	"shock_grenade",
	"shock_grenade_stun_interval",
	"adamant_grenade",
	"adamant_grenade_impact",
	"close_adamant_grenade",
	"shock_mine_self_destruct",
	"krak_grenade",
	"krak_grenade_impact",
	"close_krak_grenade",
	"close_frag_grenade",
	"frag_grenade",
	"frag_grenade_impact",
	"ogryn_grenade",
	"close_ogryn_grenade",
	"ogryn_grenade_impact",
	"ogryn_box_cluster_frag_grenade",
	"ogryn_box_cluster_close_frag_grenade",
	"ogryn_grenade_box_impact",
	"ogryn_grenade_box_cluster_impact",
	"ogryn_friendly_rock_impact",
	"broker_flash_grenade",
	"broker_flash_grenade_impact",
	"broker_flash_grenade_close",
	"broker_missile_launcher_explosion_close",
	"broker_missile_launcher_explosion",
	"broker_missile_launcher_impact",
	"missile_launcher_knockback",
    "cryptic_discharge_shock_damage", -- Skitarii voltage overload thing
    "cryptic_discharge_weapon_shock", -- Skitussy overload arc
    "discharge_chain_jump_damage",
    "arc_grenade_chain_jump_damage", -- Skitarii Arc Grenade
}
-- Dog damage doesn't count as melee/ranged for penances
--	but the shock bomb collar counts for puncture, which is covered by "explosion" being in ranged_attack_types
mod.companion_attack_types ={
    "companion_dog", -- covers the breed_pounce types
}
mod.companion_damage_profiles ={
    "adamant_companion_initial_pounce", -- never seen it come up but it's in the code
    -- "adamant_companion_human_pounce",
    -- "adamant_companion_ogryn_pounce",
    -- "adamant_companion_monster_pounce",
    "shockmaul_stun_interval_damage", -- shock maul electrocution and Arbites dog shocks
    -- Skitussy Skull
    "default_companion_servo_skull_lasgun_killshot",
    "improved_companion_servo_skull_lasgun_killshot",
    "companion_servo_skull_flamer",
}

mod.bleeding_damage_profiles ={
    "bleeding",
    "psyker_stun", -- Mortis Trials psyker bleed
}
mod.burning_damage_profiles ={
    "burning",
    "flame_grenade_liquid_area_fire_burning",
    "liquid_area_fire_burning_barrel",
    "liquid_area_fire_burning",
    --"flamer_assault", -- Flaming shots from PBB. False bug report: this just uses "burning"
    "phosphor_burning", -- phosphor burns from pistol and servo skull blitz. can't distinguish between the two so here it goes.
}
mod.warpfire_damage_profiles ={
    "warpfire",
}
mod.electrocution_damage_profiles = {
    "shockmaul_stun_interval_damage",
    "powermaul_p2_stun_interval",
    "powermaul_p2_stun_interval_basic",
    "powermaul_shield_block_special",
    "shock_grenade_stun_interval",
    "psyker_protectorate_spread_chain_lightning_interval",
    "default_chain_lighting_interval",
    "psyker_smite_kill",
    -- skitussy
    "powermaul_p3_arc_chain_lightning_link_damage",
    "cryptic_discharge_shock_damage",
    "arc_rifle_arc_chain_lightning_link_damage",
    "chain_lightning_killing_blow",
}
mod.toxin_damage_profiles = {
    "toxin_variant_1",	
    "toxin_variant_2",	
    "toxin_variant_3",
    "horde_mode_self_propagating_toxin", -- hordes_buff_broker_tox_grenade_applies_self_propagating_toxin applies a toxin that's this?
    --"broker_toxin_stacks_stun_interval", -- stun only?
}
mod.environmental_damage_profiles = {
    "barrel_explosion",
    "barrel_explosion_close",
    "fire_barrel_explosion",
    "fire_barrel_explosion_close",
    "kill_volume_and_off_navmesh",
    "kill_volume_with_gibbing",
    "default",
    "poxwalker_explosion",
    "poxwalker_explosion_close",
    "poxwalker_bomber_instakill",
}

-- ------------
-- Other Stats
-- ------------
mod.states_disabled = {
    "consumed", -- Beast of Nurgle vore
    "grabbed", -- Chaos Spawn
    "ledge_hanging",
    "netted",
    "pounced"
    -- NB: Disabled some of these due to personal preference
    --"mutant_charged",
    --"warp_grabbed",
}
-- Put into an array to keep the order in the mod options (this is used by the xxx_data.lua)
mod.optional_states_disabled = {
    [1] = "catapulted", -- YEET (from knockback)
    [2] = "mutant_charged",
    [3] = "warp_grabbed", -- Daemonhost execution
    -- @backup158: game also counts hogtied and knocked_down but I'm not even considering those as possibilities for players to want to track
}
mod.forge_material = {
    loc_pickup_small_metal = "small_metal",
    loc_pickup_large_metal = "large_metal",
    loc_pickup_small_platinum = "small_platinum",
    loc_pickup_large_platinum = "large_platinum",
}
mod.ammunition = {
    loc_pickup_consumable_small_clip_01 = "small_clip",
    loc_pickup_consumable_large_clip_01 = "large_clip",
    loc_pickup_deployable_ammo_crate_01 = "crate",
    loc_pickup_consumable_small_grenade_01 = "grenades",
    -- Expeditions
    --  These count as Ammunition
    loc_game_mode_expedition_pickup_price_desc = "expedition_pocketable",
}
-- scripts/settings/pickup/pickups/consumable large_clip_pickup and small_clip_pickup
mod.ammunition_percentage = {
    small_clip = 0.15,
    -- small_clip = SmallClipPickup.ammunition_percentage,
    large_clip = 0.5,
    -- large_clip = LargeClipPickup.ammunition_percentage,
    crate = 1,
}
-- Same as above
--  Found by going into @scripts/components/pickup_spawner.lua
mod.expeditions_currency = {
    loc_expeditions_pickup_currency_quality_low = {
        id = "expedition_currency_small_tier_1",
        amount = 5,
    },
    loc_expeditions_pickup_currency_quality_medium = {
        id = "expedition_currency_small_tier_2",
        amount = 10,
    },
}
-- Tech-remnants
mod.expeditions_loot = {
    -- Multiple cases
    --  When a Disabler steals your stuff
    --  Dropped everything on death
    --  Drop from killing a boss
    loc_expeditions_pickup_loot_player_drop = {
        id = "expedition_loot_player_drop",
        amount = mod:get("exploration_player_loot_value") or 0,
    },
    loc_expeditions_pickup_loot_quality_low = {
        id = "expedition_loot_small_tier_1",
        amount = 10,
    },
    loc_expeditions_pickup_loot_quality_medium = {
        id = "expedition_loot_small_tier_2",
        amount = 25,
    },
    loc_expeditions_pickup_loot_quality_high = {
        id = "expedition_loot_small_tier_3",
        amount = 50,
    },
}