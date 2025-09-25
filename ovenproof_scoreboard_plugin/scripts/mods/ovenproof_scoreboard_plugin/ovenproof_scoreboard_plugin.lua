local mod = get_mod("ovenproof_scoreboard_plugin")

-- ########################
-- REQUIRES
-- ########################
local PlayerUnitStatus = mod:original_require("scripts/utilities/attack/player_unit_status")
local InteractionSettings = mod:original_require("scripts/settings/interaction/interaction_settings")
local interaction_results = InteractionSettings.results
local TextUtilities = mod:original_require("scripts/utilities/ui/text")
--local SmallClipPickup = require("scripts/settings/pickup/pickups/consumable/small_clip_pickup")
--local LargeClipPickup = require("scripts/settings/pickup/pickups/consumable/large_clip_pickup")

-- #######
-- Optimizations for globals
-- #######
local tostring = tostring

-- #######
-- Mod Locals
-- #######
mod.version = "1.5.0"
local debug_messages_enabled = mod:get("enable_debug_messages")

local in_match
local is_playing_havoc
local scoreboard
-- ammo pickup given as a percentage, such as 0.85
mod.ammunition_pickup_modifier = 1

-- ########################
-- Data tables
-- ########################
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
	}
-- ------------
-- Damage Types
-- ------------
	mod.melee_attack_types ={
		"melee",
		"push",
		-- "buff", -- regular Shock Maul and Arbites power maul stun intervals. also covers warp and bleed
	}
	mod.melee_damage_profiles ={
		-- "shockmaul_stun_interval_damage", -- shock maul electrocution and Arbites dog shocks
		"powermaul_p2_stun_interval",
		"powermaul_p2_stun_interval_basic",
		"powermaul_shield_block_special",
		
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
		--"flamer_assault", -- Flaming shots from PBB. this just uses "burning"
	}
	mod.warpfire_damage_profiles ={
		"warpfire",
	}
	--[[
	mod.electrocution_damage_profiles = {
		"shockmaul_stun_interval_damage",
		"powermaul_p2_stun_interval",
		"powermaul_p2_stun_interval_basic",
		"powermaul_shield_block_special",
		"shock_grenade_stun_interval",
		"psyker_protectorate_spread_chain_lightning_interval",
		"default_chain_lighting_interval",
		"psyker_smite_kill",
	}
	]]
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
	}
-- ------------
-- Other Stats
-- ------------
	mod.states_disabled = {
		-- NB: Disabled some of these due to personal preference
		"ledge_hanging",
		-- "warp_grabbed",
		"grabbed",
		"consumed",
		"netted",
		--"mutant_charged",
		"pounced"
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
	}
	-- scripts/settings/pickup/pickups/consumable large_clip_pickup and small_clip_pickup
	mod.ammunition_percentage = {
		small_clip = 0.15,
		-- small_clip = SmallClipPickup.ammunition_percentage,
		large_clip = 0.5,
		-- large_clip = LargeClipPickup.ammunition_percentage,
		crate = 1,
	}

-- Setup tables for tracking later
-- 		to count ammo wasted
mod.current_ammo = {}
-- 		to see who's interacting
mod.interaction_units = {}
--		to see who's disabled (and for when they get freed)
mod.disabled_players = {}

-- ########################
-- Helper Functions
-- ########################
local function player_from_unit(unit)
	local players = Managers.player:players()
	for _, player in pairs(players) do
		if player.player_unit == unit then
			return player
		end
	end
	return nil
end

-- ############
-- Manage Blank Rows
-- ############
mod.manage_blank_rows = function()
	if in_match then
		local row = scoreboard:get_scoreboard_row("blank_1")
		local players = Managers.player:players() or {}

		if row and players then
			if row["data"] then
				for _, player in pairs (players) do
					local account_id = player:account_id() or player:name()
					if account_id then
						row["data"][account_id] = row["data"][account_id] or {}
						if not row["data"][account_id]["text"] then
							mod:set_blank_rows(account_id)
						end
					end
				end
			end
		end
	end
end

-- ############
-- Set All Blank Rows
-- ############
mod.set_blank_rows = function (self, account_id)
	-- for i in range (1, 13), increment of 1
	for i = 1,13,1 do
		mod:replace_row_value("blank_"..i, account_id, "\u{200A}")
	end
	mod:replace_row_value("highest_single_hit", account_id, "\u{200A}0\u{200A}")
end

-- ############
-- Add Damage Taken/Done Ratio
-- ############
--[[
mod.add_damage_taken_done_ratio = function(self, account_id)

end
]]

-- ############
-- Replace entire value in scoreboard
-- ############
mod.replace_row_value = function(self, row_name, account_id, value)
	local row = scoreboard:get_scoreboard_row(row_name)
	if row then
		local validation = row.validation
		if tonumber(value) then
			local value = value and math.max(0, value) or 0
			row.data = row.data or {}
			row.data[account_id] = row.data[account_id] or {}			
			row.data[account_id].value = value
			row.data[account_id].score = value
			row.data[account_id].text = nil
		else
			row.data = row.data or {}
			row.data[account_id] = row.data[account_id] or {}
			row.data[account_id].text = value
			row.data[account_id].value = 0
			row.data[account_id].score = 0
		end
	end
end

-- ############
-- Force replacement of text value in scoreboard
-- ############
mod.replace_row_text = function(self, row_name, account_id, value)
	local row = scoreboard:get_scoreboard_row(row_name)
	if row then
		row.data = row.data or {}
		row.data[account_id] = row.data[account_id] or {}
		row.data[account_id].text = value
		--row.data[account_id].value = value
		--row.data[account_id].score = value
	end
end

-- ############
-- Get a row value from scoreboard
-- ############
mod.get_row_value = function(self, row_name, account_id)
	local row = scoreboard:get_scoreboard_row(row_name)
	return row.data[account_id] and row.data[account_id].score or 0
end

-- ############
-- Check Setting and If It's Only for Havoc
--	The idea is I have a setting to toggle x, with a suboptions to only check x if playing Havoc
--	This chain of checks will tell if that condition is met
--	Do not track this: return False at check 1
--	Track this
--		and don't care if havoc: return True at check 2.2
--		and cares if havoc
--			not currently playing havoc: return False at check 2.2.2
--			is playing havoc: return True at check 2.2.2
-- ############
local function setting_is_enabled_and_check_if_havoc_only(main_setting, is_playing_havoc)
	local only_in_havoc = mod:get(main_setting.."_only_in_havoc")
	return mod:get(main_setting) and ((not only_in_havoc) or (only_in_havoc and is_playing_havoc))
end

-- ########################
-- Executions on Game States
-- ########################

-- Manage blank rows on update
--	WAIT WHAT THE FUCK THIS RUNS ON EVERY SINGLE GAME TICK???
function mod.update(main_dt)
	mod:manage_blank_rows()
end

-- ############
-- Check Setting Changes
-- ############
function mod.on_setting_changed(setting_id)
	debug_messages_enabled = mod:get("enable_debug_messages")
	--[[
	-- Scoreboard can't be disabled mid-game
	scoreboard = get_mod("scoreboard")
	if not scoreboard then
		mod:error(mod:localize("error_scoreboard_missing"))
		return
	end
	]]
end

-- ############
-- ** Mod Startup **
-- ############
function mod.on_all_mods_loaded()
	debug_messages_enabled = mod:get("enable_debug_messages")
	scoreboard = get_mod("scoreboard")
	if not scoreboard then
		mod:error(mod:localize("error_scoreboard_missing"))
		return
	end
	mod:info("Version "..mod.version.." loaded uwu nya :3")

	-- ################################################
	-- HOOKS
	-- ################################################
	--[[
	-- ############
	-- Calculate Ratio
	--	Needs to be done:
	--		mid game when opening tactical overlay
	--		at least once before the post match view
	-- ############
	-- ######
	-- When opening tactical overlay
	-- 	Runs on opening and every tick while it's open
	-- ######
	mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings, ...)
		mod:add_damage_taken_done_ratio()
		--mod:echo("IF YOU SEE THIS YELL AT ME: tactical overlay widgets")
		func(self, dt, t, input_service, ui_renderer, render_settings, ...)
		-- base mod hooks onto this first, but executes after the original function
	end)
	-- ######
	-- Before game end
	-- ######
	mod:hook(CLASS.EndView, "on_enter", function(func, self)
		mod:add_damage_taken_done_ratio()
		--mod:echo("IF YOU SEE THIS YELL AT ME: entering end view")
		func(self)
		-- base mod hooks onto this first, but executes after the original function
	end)
	]]

	-- ############
	-- Interactions Started?
	-- ############
	mod:hook(CLASS.InteracteeExtension, "started", function(func, self, interactor_unit, ...)

		mod.interaction_units[self._unit] = interactor_unit

		-- Ammunition
		local unit_data_extension = ScriptUnit.extension(interactor_unit, "unit_data_system")
		local wieldable_component = unit_data_extension:read_component("slot_secondary")
		mod.current_ammo[interactor_unit] = wieldable_component.current_ammunition_reserve

		func(self, interactor_unit, ...)
	end)

	-- ############
	-- Exploration: Equipment Use and Pickups
	--	Track materials picked up, health stations used, and ammo picked up
	--	Interactions stopped
	-- ############
	mod:hook(CLASS.InteracteeExtension, "stopped", function(func, self, result, ...)
		if result == interaction_results.success then
			local type = self:interaction_type() or ""
			local unit = self._interactor_unit
			if unit then
				local player = Managers.player:player_by_unit(unit)
				local profile = player:profile()
				if player then
					local account_id = player:account_id() or player:name()
					local color = Color.citadel_casandora_yellow(255, true)
					if type == "forge_material" then
						scoreboard:update_stat("total_material_pickups", account_id, 1)
					elseif type == "health_station" then
						scoreboard:update_stat("total_health_stations", account_id, 1)
					elseif type == "grenade" then
						scoreboard:update_stat("ammo_grenades", account_id, 1)
						if mod:get("ammo_messages") then
							local text = TextUtilities.apply_color_to_text(mod:localize("message_grenades_text"), color)
							local message = mod:localize("message_grenades_body", text)
							Managers.event:trigger("event_combat_feed_kill", unit, message)
						end
					elseif type == "ammunition" then
						local ammo = mod.ammunition[self._override_contexts.ammunition.description]
						-- Get components
						local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
						local wieldable_component = unit_data_extension:read_component("slot_secondary")
						-- Get ammo numbers
						local current_ammo_clip = wieldable_component.current_ammunition_clip
						local max_ammo_clip = wieldable_component.max_ammunition_clip
						local current_ammo_reserve = mod.current_ammo[unit]
						local max_ammo_reserve = wieldable_component.max_ammunition_reserve
						-- Calculate relevant ammo values relative to the "combined" ammo reserve, i.e. base reserve + clip
						local current_ammo_combined = current_ammo_clip + current_ammo_reserve
						local max_ammo_combined = max_ammo_clip + max_ammo_reserve
						local ammo_missing = max_ammo_combined - current_ammo_combined
						
						-- Base pickup rate (decimal). Defaults to crate as a failsafe
						local base_pickup_from_source = mod.ammunition_percentage[ammo] or 1
						-- Calculating amount picked up
						--		Ammo pickups are rounded up by the game
						-- 		mod.mmunition_pickup_modifier to account for Havoc modifiers. set by state change check
						local pickup = math.ceil(base_pickup_from_source * mod.ammunition_pickup_modifier * max_ammo_reserve)

						local wasted = math.max(pickup - ammo_missing, 0)
						local pickup_pct = 100 * (pickup / max_ammo_combined)
						local wasted_pct = 100 * (wasted / max_ammo_reserve)
						
						-- Small boxes and Big bags
						if ammo == "small_clip" or ammo == "large_clip" then
							scoreboard:update_stat("ammo_percent", account_id, pickup_pct)
							scoreboard:update_stat("ammo_wasted_percent", account_id, wasted_pct)
							if mod:get("ammo_messages") then
								local pickup_text = TextUtilities.apply_color_to_text(mod:localize("message_"..ammo), color)
								local displayed_waste = math.max(1, math.round(wasted_pct))
								local wasted_text = TextUtilities.apply_color_to_text(tostring(displayed_waste).."%", color)
								local message = ""
								if wasted == 0 then
									message = mod:localize("message_ammo_no_waste", pickup_text)
								else
									message = mod:localize("message_ammo_waste", pickup_text, wasted_text)
								end
								Managers.event:trigger("event_combat_feed_kill", unit, message)
							end
						-- Deployabla Ammo Crates
						elseif ammo == "crate" then
							-- Amount of Ammo Crate uses
							scoreboard:update_stat("ammo_crates", account_id, 1)
							-- Adding to total percentage of ammo
							local count_crates_to_total_ammo = setting_is_enabled_and_check_if_havoc_only("track_ammo_crate_in_percentage", is_playing_havoc)
							if count_crates_to_total_ammo then
								scoreboard:update_stat("ammo_percent", account_id, pickup_pct)
							end
							if mod:get("ammo_messages") then
								-- Text formatting
								-- 		Formatting for percentage of ammo picked up
								local text_ammo_taken = TextUtilities.apply_color_to_text(tostring(math.round(pickup_pct)).."%", color)
								-- 		Formatting for Ammo Crate name
								local text_crate = TextUtilities.apply_color_to_text(mod:localize("message_ammo_crate_text"), color)
								local message = ""
								-- Only prints waste message if that's enabled, and if there was actually waste found
								local count_waste_for_crates = setting_is_enabled_and_check_if_havoc_only("track_ammo_crate_waste", is_playing_havoc)
								if count_waste_for_crates and (not (wasted == 0)) then
									local displayed_waste = math.max(1, math.round(wasted_pct))
									local wasted_text = TextUtilities.apply_color_to_text(tostring(displayed_waste).."%", color)
									message = mod:localize("message_ammo_crate_waste", text_ammo_taken, text_crate, wasted_text)
								else
									message = mod:localize("message_ammo_crate", text_ammo_taken, text_crate)
								end
								-- Puts message into combat feed
								Managers.event:trigger("event_combat_feed_kill", unit, message)
							end
						else
							local uncategorized_ammo_pickup_message = "Uncategorized ammo pickup! It is: "..tostring(ammo)
							if debug_messages_enabled then
								mod:echo(uncategorized_ammo_pickup_message)
							else
								mod:info(uncategorized_ammo_pickup_message)
							end
						end
					end
				end
			end
		end
		func(self, result, ...)
	end)

	-- ############
	-- Defense
	--	Track damage taken and times disabled/downed/killed
	--	Player State
	-- ############
	mod:hook(CLASS.PlayerHuskHealthExtension, "fixed_update", function(func, self, unit, dt, t, ...)
		local Breed = scoreboard:original_require("scripts/utilities/breed")
		if unit then
			local player = Managers.player:player_by_unit(unit)
			if player then		
				local account_id = player:account_id() or player:name()			
				local player_state = self._character_state_read_component.state_name
				if self._damage and self._damage > 0 then
					scoreboard:update_stat("total_damage_taken", account_id, self._damage)
				end
				
				local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
				local disabled_character_state_component = unit_data_extension:read_component("disabled_character_state")
				if disabled_character_state_component then
					local is_disabled = disabled_character_state_component.is_disabled
					local is_pounced = is_disabled and disabled_character_state_component.disabling_type == "pounced"
					local disabling_unit = disabled_character_state_component.disabling_unit
					
					if is_disabled and disabling_unit then
						mod.disabled_players[account_id] = disabling_unit
					end
				end

				self._player_state_tracker = self._player_state_tracker or {}
				self._player_state_tracker[account_id] = self._player_state_tracker[account_id] or {}
				self._player_state_tracker[account_id].state = self._player_state_tracker[account_id].state or {}
				
				if self._player_state_tracker[account_id].state ~= player_state then
					if not table.array_contains(mod.states_disabled, self._player_state_tracker[account_id].state) and not table.array_contains(mod.states_disabled, player_state) then
						mod.disabled_players[account_id] = nil
					end
					self._player_state_tracker[account_id].state = player_state
					if table.array_contains(mod.states_disabled, player_state) then
						scoreboard:update_stat("total_times_disabled", account_id, 1)
					elseif player_state == "knocked_down" then
						scoreboard:update_stat("total_times_downed", account_id, 1)
					elseif player_state == "dead" then
						scoreboard:update_stat("total_times_killed", account_id, 1)
					end
				end
			end
		end
		func(self, unit, dt, t, ...)
	end)

	-- ############
	-- Defense: Helping Allies
	-- 	Tracks allies undisabled/revived/rescued
	--	Player Interactions
	-- ############
	mod:hook(CLASS.PlayerInteracteeExtension, "stopped", function(func, self, result, ...)
		local type = self:interaction_type() or ""
		if result == interaction_results.success then
			local unit = self._interactor_unit
			if unit then
				local player = Managers.player:player_by_unit(unit)
				if player then
					--mod:echo("interaction - player "..player:name()..", type: "..type)
					local account_id = player:account_id() or player:name()
					if type == "pull_up" or type == "remove_net" then
						scoreboard:update_stat("total_operatives_helped", account_id, 1)
					elseif type == "revive" then
						scoreboard:update_stat("total_operatives_revived", account_id, 1)
					elseif type == "rescue" then
						scoreboard:update_stat("total_operatives_rescued", account_id, 1)
					end
				end
			end
		end
		func(self, result, ...)
	end)

	-- ############
	-- Offense
	--	Damage, kills, and crit/weakspot rate
	--	Attack reports
	-- ############
	mod:hook(CLASS.AttackReportManager, "add_attack_result", function(func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
		local Breed = scoreboard:original_require("scripts/utilities/breed")
		local player = attacking_unit and player_from_unit(attacking_unit)
		local target_is_player = attacked_unit and player_from_unit(attacked_unit)
		local actual_damage
		
		-- only add damage if done by a player. could there be a check for companion that can be associated with the player?
		if player then
			local account_id = player:account_id() or player:name()
			
			if damage > 0 then			
				local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
				local breed_or_nil = unit_data_extension and unit_data_extension:breed()
				local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)

				-- only when hitting an npc (only enemies can be damaged by you)
				if target_is_minion then
					local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
					local damage_taken = unit_health_extension and unit_health_extension:damage_taken()
					local max_health = unit_health_extension and unit_health_extension:max_health()

					if attack_result == "died" then
						if Managers.state.mission:mission().name == "tg_shooting_range" then
							actual_damage = max_health - damage_taken + damage
						else
							actual_damage = max_health - damage_taken
						end
						scoreboard:update_stat("total_kills", account_id, 1)

						-- killed a disabler while an ally was disabled
						if table.array_contains(mod.disablers, breed_or_nil.name) then
							for k,v in pairs(mod.disabled_players) do
								if v == attacked_unit then
									scoreboard:update_stat("total_operatives_helped", account_id, 1)
									mod.disabled_players[k] = nil
								end
							end
						end

					else
						actual_damage = damage
					end
					
					scoreboard:update_stat("total_damage", account_id, actual_damage)
					
					-- ------------------------
					-- Updating Fun Stuff
					-- ------------------------
					self._attack_report_tracker = self._attack_report_tracker or {}
					self._attack_report_tracker[account_id] = self._attack_report_tracker[account_id] or {}
					self._attack_report_tracker[account_id].highest_single_hit = self._attack_report_tracker[account_id].highest_single_hit or 0
					self._attack_report_tracker[account_id].one_shots = self._attack_report_tracker[account_id].one_shots or 0

					if actual_damage > self._attack_report_tracker[account_id].highest_single_hit then
						self._attack_report_tracker[account_id].highest_single_hit = actual_damage
						mod:replace_row_text("highest_single_hit", account_id, math.floor(damage))
					end
					
					if actual_damage == max_health then
						scoreboard:update_stat("one_shots", account_id, 1)
					end	

					-- ------------------------
					-- Splitting damage into subtypes (melee, ranged, etc.)
					-- ------------------------
					-- ------------
					--	Melee
					-- ------------
					-- manual exception for companion, due to shared damage profile
					if table.array_contains(mod.melee_attack_types, attack_type) or (table.array_contains(mod.melee_damage_profiles, damage_profile.name) and not table.array_contains(mod.companion_attack_types, attack_type)) then
						self._melee_rate = (self._melee_rate or {})
						self._melee_rate[account_id] = self._melee_rate[account_id] or {}
						self._melee_rate[account_id].hits = self._melee_rate[account_id].hits or 0
						self._melee_rate[account_id].hits = self._melee_rate[account_id].hits +1
						self._melee_rate[account_id].weakspots = self._melee_rate[account_id].weakspots or 0
						self._melee_rate[account_id].crits = self._melee_rate[account_id].crits or 0
											
						scoreboard:update_stat("total_melee_damage", account_id, actual_damage)
						if hit_weakspot then
							self._melee_rate[account_id].weakspots = self._melee_rate[account_id].weakspots + 1
						end
						if is_critical_strike then
							self._melee_rate[account_id].crits = self._melee_rate[account_id].crits + 1
						end
						if attack_result == "died" then
							scoreboard:update_stat("total_melee_kills", account_id, 1)
						end
						
						self._melee_rate[account_id].cr = self._melee_rate[account_id].crits / self._melee_rate[account_id].hits * 100
						self._melee_rate[account_id].wr = self._melee_rate[account_id].weakspots / self._melee_rate[account_id].hits * 100
						
						mod:replace_row_value("melee_cr", account_id, self._melee_rate[account_id].cr)
						mod:replace_row_value("melee_wr", account_id, self._melee_rate[account_id].wr)
					-- ------------
					--	Ranged
					-- ------------
					elseif table.array_contains(mod.ranged_attack_types, attack_type) or table.array_contains(mod.ranged_damage_profiles, damage_profile.name) then
						self._ranged_rate = self._ranged_rate or {}
						self._ranged_rate[account_id] = self._ranged_rate[account_id] or {}
						self._ranged_rate[account_id].hits = self._ranged_rate[account_id].hits or 0
						self._ranged_rate[account_id].hits = self._ranged_rate[account_id].hits +1
						self._ranged_rate[account_id].weakspots = self._ranged_rate[account_id].weakspots or 0
						self._ranged_rate[account_id].crits = self._ranged_rate[account_id].crits or 0
						
						scoreboard:update_stat("total_ranged_damage", account_id, actual_damage)
						if hit_weakspot then
							self._ranged_rate[account_id].weakspots = self._ranged_rate[account_id].weakspots + 1
						end
						if is_critical_strike then
							self._ranged_rate[account_id].crits = self._ranged_rate[account_id].crits + 1
						end
						if attack_result == "died" then
							scoreboard:update_stat("total_ranged_kills", account_id, 1)
						end
						
						self._ranged_rate[account_id].cr = self._ranged_rate[account_id].crits / self._ranged_rate[account_id].hits * 100
						self._ranged_rate[account_id].wr = self._ranged_rate[account_id].weakspots / self._ranged_rate[account_id].hits * 100
						
						mod:replace_row_value("ranged_cr", account_id, self._ranged_rate[account_id].cr)
						mod:replace_row_value("ranged_wr", account_id, self._ranged_rate[account_id].wr)
					-- ------------
					--	Companion
					-- ------------
					elseif table.array_contains(mod.companion_attack_types, attack_type) or table.array_contains(mod.companion_damage_profiles, damage_profile.name) then
						-- Crit and Weakspot rates don't matter
						--[[
						self._companion_rate = self._companion_rate or {}
						self._companion_rate[account_id] = self._companion_rate[account_id] or {}
						self._companion_rate[account_id].hits = self._companion_rate[account_id].hits or 0
						self._companion_rate[account_id].hits = self._companion_rate[account_id].hits +1
						self._companion_rate[account_id].weakspots = self._companion_rate[account_id].weakspots or 0
						self._companion_rate[account_id].crits = self._companion_rate[account_id].crits or 0
						]]
						
						scoreboard:update_stat("total_companion_damage", account_id, actual_damage)
						--[[
						if hit_weakspot then
							self._companion_rate[account_id].weakspots = self._companion_rate[account_id].weakspots + 1
						end
						]]
						--[[
						if is_critical_strike then
							self._companion_rate[account_id].crits = self._companion_rate[account_id].crits + 1
						end
						]]
						if attack_result == "died" then
							scoreboard:update_stat("total_companion_kills", account_id, 1)
						end
						
						--[[
						self._companion_rate[account_id].cr = self._companion_rate[account_id].crits / self._companion_rate[account_id].hits * 100
						self._companion_rate[account_id].wr = self._companion_rate[account_id].weakspots / self._companion_rate[account_id].hits * 100
						
						mod:replace_row_value("companion_cr", account_id, self._companion_rate[account_id].cr)
						mod:replace_row_value("companion_wr", account_id, self._companion_rate[account_id].wr)
						]]
					-- ------------
					--	Bleed
					-- ------------
					elseif table.array_contains(mod.bleeding_damage_profiles, damage_profile.name) then
						self._bleeding_rate = self._bleeding_rate or {}
						self._bleeding_rate[account_id] = self._bleeding_rate[account_id] or {}
						self._bleeding_rate[account_id].hits = self._bleeding_rate[account_id].hits or 0
						self._bleeding_rate[account_id].hits = self._bleeding_rate[account_id].hits + 1
						self._bleeding_rate[account_id].crits = self._bleeding_rate[account_id].crits or 0
						
						scoreboard:update_stat("total_bleeding_damage", account_id, actual_damage)
						--if is_critical_strike then
						--	self._bleeding_rate[account_id].crits = self._bleeding_rate[account_id].crits + 1
						--end
						if attack_result == "died" then
							scoreboard:update_stat("total_bleeding_kills", account_id, 1)
						end
						
						--self._bleeding_rate[account_id].cr = self._bleeding_rate[account_id].crits / self._bleeding_rate[account_id].hits * 100
						
						--mod:replace_row_value("bleeding_cr", account_id, self._bleeding_rate[account_id].cr)
					-- ------------
					--	Burning
					-- ------------
					elseif table.array_contains(mod.burning_damage_profiles, damage_profile.name) then
						self._burning_rate = (self._burning_rate or {})
						self._burning_rate[account_id] = (self._burning_rate[account_id] or {})
						self._burning_rate[account_id].hits = (self._burning_rate[account_id].hits or 0) + 1
						self._burning_rate[account_id].crits = (self._burning_rate[account_id].crits or 0)
						
						scoreboard:update_stat("total_burning_damage", account_id, actual_damage)
						--if is_critical_strike then
						--	self._burning_rate[account_id].crits = self._burning_rate[account_id].crits + 1
						--end
						if attack_result == "died" then
							scoreboard:update_stat("total_burning_kills", account_id, 1)
						end
						
						--self._burning_rate[account_id].cr = self._burning_rate[account_id].crits / self._burning_rate[account_id].hits * 100
						
						--mod:replace_row_value("burning_cr", account_id, self._burning_rate[account_id].cr)
					-- ------------
					--	Warp
					-- ------------
					elseif table.array_contains(mod.warpfire_damage_profiles, damage_profile.name) then
						self._warpfire_rate = (self._warpfire_rate or {})
						self._warpfire_rate[account_id] = (self._warpfire_rate[account_id] or {})
						self._warpfire_rate[account_id].hits = (self._warpfire_rate[account_id].hits or 0) + 1
						self._warpfire_rate[account_id].crits = (self._warpfire_rate[account_id].crits or 0)
						
						scoreboard:update_stat("total_warpfire_damage", account_id, actual_damage)
						--if is_critical_strike then
						--	self._warpfire_rate[account_id].crits = self._warpfire_rate[account_id].crits + 1
						--end
						if attack_result == "died" then
							scoreboard:update_stat("total_warpfire_kills", account_id, 1)
						end
						
						--self._warpfire_rate[account_id].cr = self._warpfire_rate[account_id].crits / self._warpfire_rate[account_id].hits * 100
						
						--mod:replace_row_value("warpfire_cr", account_id, self._warpfire_rate[account_id].cr)
					-- ------------
					-- 	Environmental
					-- ------------
					elseif table.array_contains(mod.environmental_damage_profiles, damage_profile.name) then
						self._environmental_rate = (self._environmental_rate or {})
						self._environmental_rate[account_id] = (self._environmental_rate[account_id] or {})
						self._environmental_rate[account_id].hits = (self._environmental_rate[account_id].hits or 0) + 1
						self._environmental_rate[account_id].crits = (self._environmental_rate[account_id].crits or 0)
						
						scoreboard:update_stat("total_environmental_damage", account_id, actual_damage)
						--if is_critical_strike then
						--	self._environmental_rate[account_id].crits = self._environmental_rate[account_id].crits + 1
						--end
						if attack_result == "died" then
							scoreboard:update_stat("total_environmental_kills", account_id, 1)
						end
						
						--self._environmental_rate[account_id].cr = self._environmental_rate[account_id].crits / self._environmental_rate[account_id].hits * 100
						
						--mod:replace_row_value("environmental_cr", account_id, self._environmental_rate[account_id].cr)
					-- ------------
					-- 	Error Catching
					-- ------------
					else
						--Print damage profile and attack type of out of scope attacks
						local error_string = "Player: "..player:name()..", Damage profile: " .. damage_profile.name .. ", attack type: " .. tostring(attack_type)..", damage: "..actual_damage
						if debug_messages_enabled then
							mod:echo(error_string)
						else
							mod:info(error_string)
						end
					end	

					-- ------------------------
					-- Categorizing which enemy was damaged
					-- TODO maybe this could be a switch
					-- ------------------------
					if table.array_contains(mod.melee_lessers, breed_or_nil.name) then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("melee_lesser_kills", account_id, 1)
						end
					elseif table.array_contains(mod.ranged_lessers, breed_or_nil.name) then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("ranged_lesser_kills", account_id, 1)
						end
					elseif table.array_contains(mod.melee_elites, breed_or_nil.name) then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("melee_elite_kills", account_id, 1)
						end
					elseif table.array_contains(mod.ranged_elites, breed_or_nil.name) then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("ranged_elite_kills", account_id, 1)
						end
					elseif table.array_contains(mod.specials, breed_or_nil.name) then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("damage_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("damage_special_kills", account_id, 1)
						end
					elseif table.array_contains(mod.disablers, breed_or_nil.name) then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("disabler_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("disabler_special_kills", account_id, 1)
						end
					elseif table.array_contains(mod.bosses, breed_or_nil.name) then
						scoreboard:update_stat("total_boss_damage", account_id, actual_damage)
						scoreboard:update_stat("boss_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_boss_kills", account_id, 1)
							scoreboard:update_stat("boss_kills", account_id, 1)
						end
					end
				elseif target_is_player then
					scoreboard:update_stat("friendly_damage", account_id, damage)
				end
			end
			
			if attack_result == "friendly_fire" then
				-- Note: I had one singular instance where I crashed from trying to index target_is_player when it was nil,
				-- so I added a check for that, even though it only happened once. Better safe than sorry, eh? -Vatinas
				local target_account_id = target_is_player and (target_is_player:account_id() or target_is_player:name())
				if target_account_id then
					scoreboard:update_stat("friendly_shots_blocked", target_account_id, 1)
				end
			end
		end
		return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
	end)
end

-- ############
-- Check Game State Changes
-- 	Entering a match
-- ############
function mod.on_game_state_changed(status, state_name)
	-- think this means "entering gameplay" from "hub"
	if state_name == "GameplayStateRun" and status == "enter" and Managers.state.mission:mission().name ~= "hub_ship" then
		in_match = true
		local havoc_extension = Managers.state.game_mode:game_mode():extension("havoc")
		-- is_playing_havoc = Managers.state.difficulty:get_parsed_havoc_data()
		if havoc_extension then
			is_playing_havoc = true
			-- adding fallback 
			-- havoc modifier goes from 0.85-0.4, but lower ranks just use 1
			mod.ammunition_pickup_modifier = havoc_extension:get_modifier_value("ammo_pickup_modifier") or 1
			mod:info("Havoc ammo modifier: "..tostring(mod.ammunition_pickup_modifier))
		else
			mod.ammunition_pickup_modifier = 1 
		end
	else
		in_match = false
		is_playing_havoc = false
	end
end

-- ########################
-- Row Categorization
-- ########################
mod.scoreboard_rows = {
--Rows exploration_tier_0
	{name = "total_material_pickups",
		text = "row_total_material_pickups",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "exploration_tier_0",
	},
	{name = "ammo_1",
		text = "row_ammo_1",
		group = "group_1",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"ammo_percent",
			"ammo_wasted_percent",
		},
		setting = "exploration_tier_0",
	},
	{name = "ammo_percent",
		text = "row_ammo_percent",
		group = "group_1",
		validation = "DESC",
		iteration = "ADD",
		parent = "ammo_1",
		setting = "exploration_tier_0",
	},
	{name = "ammo_wasted_percent",
		text = "row_ammo_wasted",
		group = "group_1",
		validation = "DESC",
		iteration = "ADD",
		parent = "ammo_1",
		setting = "exploration_tier_0",
	},
	{name = "ammo_2",
		text = "row_ammo_2",
		group = "group_1",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"ammo_grenades",
			"ammo_crates",
		},
		setting = "exploration_tier_0",
	},
	{name = "ammo_grenades",
		text = "row_ammo_grenades",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "ammo_2",
		setting = "exploration_tier_0",
	},
	{name = "ammo_crates",
		text = "row_ammo_crates",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "ammo_2",
		setting = "exploration_tier_0",
	},
	{name = "blank_1",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "exploration_tier_0",
		is_text = true,
	},
--Rows defense_tier_0
	{name = "total_health",
		text = "row_total_health",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"total_damage_taken",
			"total_health_stations",
		},
		group = "group_1",
		setting = "defense_tier_0",
	},
	{name = "total_damage_taken",
		text = "row_total_damage_taken",
		validation = "DESC",
		iteration = "DIFF",
		group = "group_1",
		parent = "total_health",
		setting = "defense_tier_0",
	},
	{name = "total_health_stations",
		text = "row_total_health_stations",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_health",
		setting = "defense_tier_0",
	},
	{name = "total_friendly",
		text = "row_total_friendly",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"friendly_damage",
			"friendly_shots_blocked",
		},
		group = "group_1",
		setting = "defense_tier_0",
	},
	{name = "friendly_damage",
		text = "row_friendly_damage",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_friendly",
		setting = "defense_tier_0",
	},
	{name = "friendly_shots_blocked",
		text = "row_friendly_shots_blocked",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_friendly",
		setting = "defense_tier_0",
	},
	{name = "blank_2",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "defense_tier_0",
		is_text = true,
	},
	{name = "total_disabled_helped",
		text = "row_total_disabled_helped",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"total_times_disabled",
			"total_operatives_helped",
		},
		group = "group_1",
		setting = "defense_tier_0",
	},
	{name = "total_times_disabled",
		text = "row_total_times_disabled",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_disabled_helped",
		setting = "defense_tier_0",
	},
	{name = "total_operatives_helped",
		text = "row_total_operatives_helped",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_disabled_helped",
		setting = "defense_tier_0",
	},
	{name = "total_downed_revived",
		text = "row_total_downed_revived",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_times_downed",
			"total_operatives_revived",
		},
		group = "group_1",
		setting = "defense_tier_0",
	},
	{name = "total_times_downed",
		text = "row_total_times_downed",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_downed_revived",
		setting = "defense_tier_0",
	},
	{name = "total_operatives_revived",
		text = "row_total_operatives_revived",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_downed_revived",
		setting = "defense_tier_0",
	},
	{name = "total_killed_rescued",
		text = "row_total_killed_rescued",
		validation = "DESC",
		iteration = "ADD",
		summary = {
			"total_times_killed",
			"total_operatives_rescued",
		},
		group = "group_1",
		setting = "defense_tier_0",
	},
	{name = "total_times_killed",
		text = "row_total_times_killed",
		validation = "DESC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_killed_rescued",
		setting = "defense_tier_0",
	},
	{name = "total_operatives_rescued",
		text = "row_total_operatives_rescued",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_killed_rescued",
		setting = "defense_tier_0",
	},
	{name = "blank_3",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "defense_tier_0",
		is_text = true,
	},
--Rows offense_rates
	{name = "total_weakspot_rates",
		text = "row_total_weakspot_rates",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_wr",
			"ranged_wr",
			-- "companion_wr", -- Don't think dogs can headshot
		},
		group = "group_1",
		setting = "offense_rates",
	},
	{name = "melee_wr",
		text = "row_melee_weakspot_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_weakspot_rates",
		setting = "offense_rates",
	},
	{name = "ranged_wr",
		text = "row_ranged_weakspot_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_weakspot_rates",
		setting = "offense_rates",
	},
	--[[
	{name = "companion_wr",
		text = "row_companion_weakspot_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_weakspot_rates",
		setting = "offense_rates",
	},
	]]
	{name = "total_critical_rates",
		text = "row_total_critical_rates",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_cr",
			"ranged_cr",
			-- "companion_cr", -- Don't think dogs can crit
		},
		group = "group_1",
		setting = "offense_rates",
	},
	{name = "melee_cr",
		text = "row_melee_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_critical_rates",
		setting = "offense_rates",
	},
	{name = "ranged_cr",
		text = "row_ranged_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_critical_rates",
		setting = "offense_rates",
	},
	--[[
	{name = "companion_cr",
		text = "row_companion_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_critical_rates",
		setting = "offense_rates",
	},
	]]
	--[[{name = "total_dot_rates_1",
		text = "row_total_dot_rates_1",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"bleeding_cr",
			"burning_cr",
		},
		group = "group_1",
		setting = "offense_rates",
	},
	{name = "bleeding_cr",
		text = "row_bleeding_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_dot_rates_1",
		setting = "offense_rates",
	},
	{name = "burning_cr",
		text = "row_burning_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_dot_rates_1",
		setting = "offense_rates",
	},
	{name = "total_dot_rates_2",
		text = "row_total_dot_rates_2",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"warpfire_cr",
			"environmental_cr",
		},
		group = "group_1",
		setting = "offense_rates",
	},
	{name = "warpfire_cr",
		text = "row_warpfire_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_dot_rates_2",
		setting = "offense_rates",
	},
	{name = "environmental_cr",
		text = "row_environmental_critical_rate",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_dot_rates_2",
		setting = "offense_rates",
	},--]]
	{name = "blank_4",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "offense_rates",
		is_text = true,
	},
--Rows offense_tier_0
	{name = "total",
		text = "row_total",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_kills",
			"total_damage",
		},
		group = "group_1",
		setting = "offense_tier_0",
	},
	{name = "total_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total",
		setting = "offense_tier_0",
	},
	{name = "total_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total",
		setting = "offense_tier_0",
	},
	{name = "blank_5",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "offense_tier_0",
		is_text = true,
	},
--Rows offense_tier_1
	-- Melee Totals
	{name = "total_melee",
		text = "row_total_melee",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_melee_kills",
			"total_melee_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_melee_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_melee",
		setting = "offense_tier_1",
	},
	{name = "total_melee_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_melee",
		setting = "offense_tier_1",
	},
	-- Ranged Totals
	{name = "total_ranged",
		text = "row_total_ranged",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_ranged_kills",
			"total_ranged_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_ranged_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_ranged",
		setting = "offense_tier_1",
	},
	{name = "total_ranged_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_ranged",
		setting = "offense_tier_1",
	},
	-- Companion Totals
	{name = "total_companion",
		text = "row_total_companion",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_companion_kills",
			"total_companion_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_companion_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_companion",
		setting = "offense_tier_1",
	},
	{name = "total_companion_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_companion",
		setting = "offense_tier_1",
	},
	-- Bleeding Totals
	{name = "total_bleeding",
		text = "row_total_bleeding",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_bleeding_kills",
			"total_bleeding_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_bleeding_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_bleeding",
		setting = "offense_tier_1",
	},
	{name = "total_bleeding_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_bleeding",
		setting = "offense_tier_1",
	},
	{name = "total_burning",
		text = "row_total_burning",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_burning_kills",
			"total_burning_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_burning_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_burning",
		setting = "offense_tier_1",
	},
	{name = "total_burning_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_burning",
		setting = "offense_tier_1",
	},
	{name = "total_warpfire",
		text = "row_total_warpfire",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_warpfire_kills",
			"total_warpfire_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_warpfire_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_warpfire",
		setting = "offense_tier_1",
	},
	{name = "total_warpfire_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_warpfire",
		setting = "offense_tier_1",
	},
	{name = "total_environmental",
		text = "row_total_environmental",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_environmental_kills",
			"total_environmental_damage",
		},
		group = "group_1",
		setting = "offense_tier_1",
	},
	{name = "total_environmental_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_environmental",
		setting = "offense_tier_1",
	},
	{name = "total_environmental_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_environmental",
		setting = "offense_tier_1",
	},
	{name = "blank_6",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "offense_tier_1",
		is_text = true,
	},
--Rows offense_tier_2
	{name = "total_lesser",
		text = "row_total_lesser",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_lesser_kills",
			"total_lesser_damage",
		},
		group = "group_1",
		setting = "offense_tier_2",
	},
	{name = "total_lesser_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_lesser",
		setting = "offense_tier_2",
	},
	{name = "total_lesser_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_lesser",
		setting = "offense_tier_2",
	},
	{name = "total_elite",
		text = "row_total_elite",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_elite_kills",
			"total_elite_damage",
		},
		group = "group_1",
		setting = "offense_tier_2",
	},
	{name = "total_elite_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_elite",
		setting = "offense_tier_2",
	},
	{name = "total_elite_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_elite",
		setting = "offense_tier_2",
	},
	{name = "total_special",
		text = "row_total_special",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_special_kills",
			"total_special_damage",
		},
		group = "group_1",
		setting = "offense_tier_2",
	},
	{name = "total_special_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_special",
		setting = "offense_tier_2",
	},
	{name = "total_special_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_special",
		setting = "offense_tier_2",
	},
	{name = "total_boss",
		text = "row_total_boss",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"total_boss_kills",
			"total_boss_damage",
		},
		group = "group_1",
		setting = "offense_tier_2",
	},
	{name = "total_boss_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_boss",
		setting = "offense_tier_2",
	},
	{name = "total_boss_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "total_boss",
		setting = "offense_tier_2",
	},
	{name = "blank_7",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "offense_tier_2",
		is_text = true,
	},
--Rows offense_tier_3
	{name = "melee_lesser",
		text = "row_melee_lesser",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_lesser_kills",
			"melee_lesser_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "melee_lesser_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "melee_lesser",
		setting = "offense_tier_3",
	},
	{name = "melee_lesser_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "melee_lesser",
		setting = "offense_tier_3",
	},
	{name = "ranged_lesser",
		text = "row_ranged_lesser",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"ranged_lesser_kills",
			"ranged_lesser_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "ranged_lesser_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "ranged_lesser",
		setting = "offense_tier_3",
	},
	{name = "ranged_lesser_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "ranged_lesser",
		setting = "offense_tier_3",
	},
	{name = "melee_elite",
		text = "row_melee_elite",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"melee_elite_kills",
			"melee_elite_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "melee_elite_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "melee_elite",
		setting = "offense_tier_3",
	},
	{name = "melee_elite_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "melee_elite",
		setting = "offense_tier_3",
	},
	{name = "ranged_elite",
		text = "row_ranged_elite",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"ranged_elite_kills",
			"ranged_elite_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "ranged_elite_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "ranged_elite",
		setting = "offense_tier_3",
	},
	{name = "ranged_elite_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "ranged_elite",
		setting = "offense_tier_3",
	},
	{name = "damage_special",
		text = "row_damage_special",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"damage_special_kills",
			"damage_special_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "damage_special_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "damage_special",
		setting = "offense_tier_3",
	},
	{name = "damage_special_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "damage_special",
		setting = "offense_tier_3",
	},
	{name = "disabler_special",
		text = "row_disabler_special",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"disabler_special_kills",
			"disabler_special_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "disabler_special_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "disabler_special",
		setting = "offense_tier_3",
	},
	{name = "disabler_special_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "disabler_special",
		setting = "offense_tier_3",
	},
	{name = "boss",
		text = "row_boss",
		validation = "ASC",
		iteration = "ADD",
		summary = {
			"boss_kills",
			"boss_damage",
		},
		group = "group_1",
		setting = "offense_tier_3",
	},
	{name = "boss_kills",
		text = "row_kills",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "boss",
		setting = "offense_tier_3",
	},
	{name = "boss_damage",
		text = "row_damage",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		parent = "boss",
		setting = "offense_tier_3",
	},
	{name = "blank_8",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "offense_tier_3",
		is_text = true,
	},
--Rows fun_stuff_01
	{name = "one_shots",
		text = "row_one_shots",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "fun_stuff_01",
	},
	{name = "highest_single_hit",
		text = "row_highest_single_hit",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "fun_stuff_01",
		is_text = true,
	},
	{name = "blank_9",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "fun_stuff_01",
		is_text = true,
	},
--Rows blanks
	{name = "blank_10",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "bottom_padding",
		is_text = true,
	},
	{name = "blank_11",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "bottom_padding",
		is_text = true,
	},
	{name = "blank_12",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "bottom_padding",
		is_text = true,
	},
	{name = "blank_13",
		text = "row_blank",
		validation = "ASC",
		iteration = "ADD",
		group = "group_1",
		setting = "bottom_padding",
		is_text = true,
	},
}
