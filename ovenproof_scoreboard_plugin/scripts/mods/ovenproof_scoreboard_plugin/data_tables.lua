local mod = get_mod("ovenproof_scoreboard_plugin")

-- ==============================================================
-- Enemy Breeds
-- ==============================================================
mod.melee_lessers = {
    ["chaos_newly_infected"] = true,
    ["chaos_poxwalker"] = true,
    ["cultist_melee"] = true,
    ["renegade_melee"] = true,
    ["chaos_armored_infected"] = true,
    ["chaos_mutated_poxwalker"] = true,
    ["chaos_lesser_mutated_poxwalker"] = true,
    ["cultist_vanguard"] = true,
    ["renegade_vanguard"] = true,
}
mod.ranged_lessers = {
    ["cultist_assault"] = true,
    ["renegade_assault"] = true,
    ["renegade_rifleman"] = true,
}
mod.melee_elites = {
    ["cultist_berzerker"] = true,
    ["renegade_berzerker"] = true,
    ["renegade_executor"] = true,
    ["chaos_ogryn_bulwark"] = true,
    ["chaos_ogryn_executor"] = true,
}
mod.ranged_elites = {
    ["cultist_gunner"] = true,
    ["renegade_gunner"] = true,
    ["cultist_shocktrooper"] = true,
    ["renegade_shocktrooper"] = true,
    ["chaos_ogryn_gunner"] = true,
    ["renegade_radio_operator"] = true,
    ["renegade_plasma_gunner"] = true,
}
mod.specials = {
    ["chaos_poxwalker_bomber"] = true,
    ["renegade_grenadier"] = true,
    ["cultist_grenadier"] = true,
    ["renegade_sniper"] = true,
    ["renegade_flamer"] = true,
    ["cultist_flamer"] = true,
}
mod.disablers = {
    ["chaos_hound"] = true,
    ["chaos_hound_mutator"] = true,
    ["cultist_mutant"] = true,
    ["cultist_mutant_mutator"] = true,
    ["renegade_netgunner"] = true,
    ["chaos_armored_hound"] = true,
}
mod.bosses = {
    ["chaos_beast_of_nurgle"] = true,
    ["chaos_daemonhost"] = true,
    ["chaos_spawn"] = true,
    ["chaos_plague_ogryn"] = true,
    ["chaos_plague_ogryn_sprayer"] = true,
    ["renegade_captain"] = true,
    ["renegade_twin_captain"] = true,
    ["renegade_twin_captain_two"] = true,
    ["cultist_captain"] = true,
    ["chaos_mutator_daemonhost"] = true,
    ["chaos_ogryn_houndmaster"] = true,
}
mod.skip = {
    ["chaos_mutator_ritualist"] = true,
    ["cultist_ritualist"] = true,
    -- what the fuck is "nurgle_flies" (@Backup158: It's an expeditions thing)
}
-- ==============================================================
-- Damage Types
-- ==============================================================
mod.melee_attack_types = {
    ["melee"] = true,
    ["push"] = true,
    -- ["buff"] = true, -- regular Shock Maul and Arbites power maul stun intervals. also covers warp and bleed so don't use lol
}
mod.melee_damage_profiles = {
    -- "shockmaul_stun_interval_damage"] = true, -- shock maul electrocution and Arbites dog shocks. dog shock is more important imo so I put it there
    ["powermaul_p2_stun_interval"] = true,
    ["powermaul_p2_stun_interval_basic"] = true,
    ["powermaul_shield_block_special"] = true,
    ["powermaul_p3_arc_chain_lightning_link_damage"] = true, -- Skitarii arc maul jumps
    ["chain_lightning_killing_blow"] = true,
}
mod.ranged_attack_types = {
    ["ranged"] = true,
    ["explosion"] = true,
    ["shout"] = true,
}
mod.ranged_damage_profiles = {
    ["shock_grenade_stun_interval"] = true,
    ["psyker_protectorate_spread_chain_lightning_interval"] = true,
    ["default_chain_lighting_interval"] = true,
    ["psyker_smite_kill"] = true,
    ["psyker_heavy_swings_shock"] = true, -- Psyker Smite on heavies and Remote Detonation on dog?
    ["missile_launcher_knockback"] = true, -- Hives Cum backblast
    ["arc_rifle_arc_chain_lightning_link_damage"] = true, -- Skitarii arc rifle jumps
    ["cryptic_discharge_shock_damage"] = true, -- Skitarii voltage overload thing. Putting it here as a fallback for if not tracking blitz
    ["cryptic_discharge_weapon_shock"] = true, 
    ["discharge_chain_jump_damage"] = true,
    ["arc_grenade_chain_jump_damage"] = true, -- Skitarii Arc Grenade. Putting it here as a fallback for if not tracking blitz
    ["force_field_chain_jump_damage"] = true, -- Skitarii Integrated Refraction Emitter with Voltaic Resistance. Fallback if not tracking Blitz
    ["cryptic_arc_shock_damage"] = true, -- Skitarii force field arc and discharge arc. I don't have an option to track electrocution separately.
    ["cryptic_arc_grenade_shock_damage"] = true, -- Skitarii Arc grenade direct damage?
}
mod.blitz_attack_types = {
    ["psyker_test"] = true,
}
mod.blitz_damage_profiles = {
    ["psyker_smite_kill"] = true,
    ["psyker_protectorate_channel_chain_lightning_activated"] = true,
    ["psyker_protectorate_spread_chain_lightning_interval"] = true,
    ["psyker_protectorate_chain_lighting"] = true,
    ["psyker_protectorate_chain_lighting_fast"] = true,
    ["psyker_throwing_knives"] = true,
    ["psyker_throwing_knives_aimed"] = true,
    ["psyker_throwing_knives_aimed_pierce"] = true,
    ["psyker_throwing_knives_psychic_fortress"] = true,
    ["zealot_throwing_knives"] = true,
    ["psyker_heavy_swings_shock"] = true,
    ["whistle_explosion"] = true,
    ["close_whistle_explosion"] = true,
    ["shock_grenade"] = true,
    ["shock_grenade_stun_interval"] = true,
    ["adamant_grenade"] = true,
    ["adamant_grenade_impact"] = true,
    ["close_adamant_grenade"] = true,
    ["shock_mine_self_destruct"] = true,
    ["krak_grenade"] = true,
    ["krak_grenade_impact"] = true,
    ["close_krak_grenade"] = true,
    ["close_frag_grenade"] = true,
    ["frag_grenade"] = true,
    ["frag_grenade_impact"] = true,
    ["ogryn_grenade"] = true,
    ["close_ogryn_grenade"] = true,
    ["ogryn_grenade_impact"] = true,
    ["ogryn_box_cluster_frag_grenade"] = true,
    ["ogryn_box_cluster_close_frag_grenade"] = true,
    ["ogryn_grenade_box_impact"] = true,
    ["ogryn_grenade_box_cluster_impact"] = true,
    ["ogryn_friendly_rock_impact"] = true,
    ["broker_flash_grenade"] = true,
    ["broker_flash_grenade_impact"] = true,
    ["broker_flash_grenade_close"] = true,
    ["broker_missile_launcher_explosion_close"] = true,
    ["broker_missile_launcher_explosion"] = true,
    ["broker_missile_launcher_impact"] = true,
    ["missile_launcher_knockback"] = true,
    ["cryptic_discharge_shock_damage"] = true, -- Skitarii voltage overload thing
    ["cryptic_discharge_weapon_shock"] = true, -- Skitussy overload arc
    ["discharge_chain_jump_damage"] = true,
    ["arc_grenade_chain_jump_damage"] = true, -- Skitarii Arc Grenade
    ["force_field_chain_jump_damage"] = true, -- Skitarii Integrated Refraction Emitter with Voltaic Resistance
    ["cryptic_arc_grenade_shock_damage"] = true, -- Skitarii Arc grenade direct damage?
}
-- Dog damage doesn't count as melee/ranged for penances
--	but the shock bomb collar counts for puncture, which is covered by "explosion" being in ranged_attack_types
mod.companion_attack_types = {
    ["companion_dog"] = true, -- covers the breed_pounce types
}
mod.companion_damage_profiles = {
    ["adamant_companion_initial_pounce"] = true, -- never seen it come up but it's in the code
    -- "adamant_companion_human_pounce"] = true,
    -- "adamant_companion_ogryn_pounce"] = true,
    -- "adamant_companion_monster_pounce"] = true,
    ["shockmaul_stun_interval_damage"] = true, -- shock maul electrocution and Arbites dog shocks
    -- Skitussy Skull
    ["default_companion_servo_skull_lasgun_killshot"] = true,
    ["improved_companion_servo_skull_lasgun_killshot"] = true,
    ["companion_servo_skull_flamer"] = true,
}

mod.bleeding_damage_profiles = {
    ["bleeding"] = true,
    ["psyker_stun"] = true, -- Mortis Trials psyker bleed
}
mod.burning_damage_profiles = {
    ["burning"] = true,
    ["flame_grenade_liquid_area_fire_burning"] = true,
    ["liquid_area_fire_burning_barrel"] = true,
    ["liquid_area_fire_burning"] = true,
    --"flamer_assault"] = true, -- Flaming shots from PBB. False bug report: this just uses "burning"
    ["phosphor_burning"] = true, -- phosphor burns from pistol and servo skull blitz. can't distinguish between the two so here it goes.
}
mod.warpfire_damage_profiles = {
    ["warpfire"] = true,
}
mod.electrocution_damage_profiles = {
    ["shockmaul_stun_interval_damage"] = true,
    ["powermaul_p2_stun_interval"] = true,
    ["powermaul_p2_stun_interval_basic"] = true,
    ["powermaul_shield_block_special"] = true,
    ["shock_grenade_stun_interval"] = true,
    ["psyker_protectorate_spread_chain_lightning_interval"] = true,
    ["default_chain_lighting_interval"] = true,
    ["psyker_smite_kill"] = true,
    -- skitussy
    ["powermaul_p3_arc_chain_lightning_link_damage"] = true,
    ["cryptic_discharge_shock_damage"] = true,
    ["arc_rifle_arc_chain_lightning_link_damage"] = true,
    ["chain_lightning_killing_blow"] = true,
    ["force_field_chain_jump_damage"] = true, -- Skitarii Integrated Refraction Emitter with Voltaic Resistance
    ["cryptic_arc_shock_damage"] = true, -- Skitarii force field arc and discharge arc
    ["cryptic_arc_grenade_shock_damage"] = true, -- Skitarii Arc grenade direct damage?
}
mod.toxin_damage_profiles = {
    ["toxin_variant_1"] = true,	
    ["toxin_variant_2"] = true,	
    ["toxin_variant_3"] = true,
    ["horde_mode_self_propagating_toxin"] = true, -- hordes_buff_broker_tox_grenade_applies_self_propagating_toxin applies a toxin that's this?
    --"broker_toxin_stacks_stun_interval"] = true, -- stun only?
}
mod.environmental_damage_profiles = {
    ["barrel_explosion"] = true,
    ["barrel_explosion_close"] = true,
    ["fire_barrel_explosion"] = true,
    ["fire_barrel_explosion_close"] = true,
    ["kill_volume_and_off_navmesh"] = true,
    ["kill_volume_with_gibbing"] = true,
    ["default"] = true,
    ["poxwalker_explosion"] = true,
    ["poxwalker_explosion_close"] = true,
    ["poxwalker_bomber_instakill"] = true,
}

-- ==============================================================
-- Other Stats
-- ==============================================================
mod.states_disabled = {
    ["consumed"] = true, -- Beast of Nurgle vore
    ["grabbed"] = true, -- Chaos Spawn
    ["ledge_hanging"] = true,
    ["netted"] = true,
    ["pounced"] = true,
    -- NB: Disabled some of these due to personal preference
    --"mutant_charged",
    --"warp_grabbed",
}
-- Put into an array to keep the order in the mod options (this is used by the xxx_data.lua)
mod.optional_states_disabled = {
    ["catapulted"] = true, -- YEET (from knockback)
    ["mutant_charged"] = true,
    ["warp_grabbed"] = true, -- Daemonhost execution
    -- @Backup158: game also counts hogtied and knocked_down but I'm not even considering those as possibilities for disabled, since those would just double count downed and killed
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
    --  The purchasable grenade/strafing things. These count as Ammunition
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