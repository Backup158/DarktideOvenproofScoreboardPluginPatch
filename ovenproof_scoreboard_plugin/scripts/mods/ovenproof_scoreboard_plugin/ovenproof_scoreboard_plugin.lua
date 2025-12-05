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
local pairs = pairs

local math = math
local math_max = math.max
local math_ceil = math.ceil
local math_floor = math.floor
local math_round = math.round

local tonumber = tonumber
local tostring = tostring
local string = string
local string_len = string.len
local string_sub = string.sub

local table = table
local table_array_contains = table.array_contains
-- TODO what about color text?

-- #######
-- Mod Locals
-- #######
mod.version = "1.7.0"
local debug_messages_enabled
local explosions_affect_ranged_hitrate
local explosions_affect_melee_hitrate

local in_match
local is_playing_havoc
local scoreboard
-- ammo pickup given as a percentage, such as 0.85
mod.ammunition_pickup_modifier = 1

-- ########################
-- Data
-- ########################
local scoreboard_rows = mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/scoreboard_rows")

local data_tables = mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/data_tables")

local mod_melee_lessers = mod.melee_lessers
local mod_ranged_lessers = mod.ranged_lessers
local mod_melee_elites = mod.melee_elites
local mod_ranged_elites = mod.ranged_elites
local mod_melee_lessers = mod.melee_lessers
local mod_specials = mod.specials
local mod_disablers = mod.disablers
local mod_bosses = mod.disablers
local mod_skip = mod.skip

local mod_melee_attack_types = mod.melee_attack_types
local mod_melee_damage_profiles = mod.melee_damage_profiles
local mod_ranged_attack_types = mod.ranged_attack_types
local mod_ranged_damage_profiles = mod.ranged_damage_profiles
local mod_companion_attack_types = mod.companion_attack_types
local mod_companion_damage_profiles = mod.companion_damage_profiles
local mod_bleeding_damage_profiles = mod.bleeding_damage_profiles
local mod_burning_damage_profiles = mod.burning_damage_profiles
local mod_warpfire_damage_profiles = mod.warpfire_damage_profiles
local mod_electrocution_damage_profiles = mod.electrocution_damage_profiles
local mod_toxin_damage_profiles = mod.toxin_damage_profiles
local mod_environmental_damage_profiles = mod.environmental_damage_profiles

local mod_states_disabled = mod.states_disabled
local mod_forge_material = mod.forge_material
local mod_ammunition = mod.ammunition
local mod_ammunition_percentage = mod.ammunition_percentage

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
-- ############
-- Echo or Info Message Based on Debug
-- if debug mode is active, display on screen so user can easily report
-- ############
local function echo_or_info_message_based_on_debug(message)
	if debug_messages_enabled then
		mod:echo(message)
	else
		mod:info(message)
	end
end

-- ############
-- Player from Unit
-- ############
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
-- Need to Revert Explosion Hitrate?
-- DESCRIPTION: Checks if user does not want explosions to affect hitrate, and if the given damage type is an explosion
-- PARAMETERS:
--	is_damage_type_affecting_hitrate; boolean; if user wants explosions to affect hitrate
--	damage_name; string; name of the damage type, such as "bolter_m2_stop_explosion"
-- RETURN: true if both conditions in description are true
-- ############
local function need_to_revert_explosion_hitrate(is_damage_type_affecting_hitrate, damage_name)
	return not is_damage_type_affecting_hitrate 
			and string_len(damage_name) > 8 -- make sure name is long enough to get a substring without crashing
			and string_sub(damage_name, -9) == "explosion" -- if it ends in "explosion" such as "bolter_m2_stop_explosion" (there's 2 each)
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
-- this may not be possible since the original mod makes rows only increase or decrease in value
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
			local value = value and math_max(0, value) or 0
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

local function set_locals_for_settings()
	debug_messages_enabled = mod:get("enable_debug_messages")
	explosions_affect_ranged_hitrate = mod:get("explosions_affect_ranged_hitrate")
	explosions_affect_melee_hitrate = mod:get("explosions_affect_melee_hitrate")
end

-- ############
-- Check Setting Changes
-- ############
function mod.on_setting_changed(setting_id)
	set_locals_for_settings()
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
	set_locals_for_settings()
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
						local ammo = mod_ammunition[self._override_contexts.ammunition.description]
						-- Get components
						local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
						local wieldable_component = unit_data_extension:read_component("slot_secondary")
						-- Get ammo numbers
						local current_ammo_clip = wieldable_component.current_ammunition_clip[1]
						local max_ammo_clip = wieldable_component.max_ammunition_clip[1]
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
						local pickup = math_ceil(base_pickup_from_source * mod.ammunition_pickup_modifier * max_ammo_reserve)

						local wasted = math_max(pickup - ammo_missing, 0)
						local pickup_pct = 100 * (pickup / max_ammo_combined)
						local wasted_pct = 100 * (wasted / max_ammo_reserve)
						
						-- Small boxes and Big bags
						if ammo == "small_clip" or ammo == "large_clip" then
							scoreboard:update_stat("ammo_percent", account_id, pickup_pct)
							scoreboard:update_stat("ammo_wasted_percent", account_id, wasted_pct)
							if mod:get("ammo_messages") then
								local pickup_text = TextUtilities.apply_color_to_text(mod:localize("message_"..ammo), color)
								local displayed_waste = math_max(1, math_round(wasted_pct))
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
								local text_ammo_taken = TextUtilities.apply_color_to_text(tostring(math_round(pickup_pct)).."%", color)
								-- 		Formatting for Ammo Crate name
								local text_crate = TextUtilities.apply_color_to_text(mod:localize("message_ammo_crate_text"), color)
								local message = ""
								-- Only prints waste message if that's enabled, and if there was actually waste found
								local count_waste_for_crates = setting_is_enabled_and_check_if_havoc_only("track_ammo_crate_waste", is_playing_havoc)
								if count_waste_for_crates and (not (wasted == 0)) then
									local displayed_waste = math_max(1, math_round(wasted_pct))
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
							echo_or_info_message_based_on_debug(uncategorized_ammo_pickup_message)
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
					if not table_array_contains(mod_states_disabled, self._player_state_tracker[account_id].state) and not table_array_contains(mod_states_disabled, player_state) then
						mod.disabled_players[account_id] = nil
					end
					self._player_state_tracker[account_id].state = player_state
					if table_array_contains(mod_states_disabled, player_state) then
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
						if table_array_contains(mod_disablers, breed_or_nil.name) then
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
						mod:replace_row_text("highest_single_hit", account_id, math_floor(damage))
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
					if table_array_contains(mod_melee_attack_types, attack_type) or (table_array_contains(mod_melee_damage_profiles, damage_profile.name) and not table_array_contains(mod_companion_attack_types, attack_type)) then
						self._melee_rate = (self._melee_rate or {})
						self._melee_rate[account_id] = self._melee_rate[account_id] or {}
						self._melee_rate[account_id].hits = self._melee_rate[account_id].hits or 0
						self._melee_rate[account_id].hits = self._melee_rate[account_id].hits +1
						-- Reverting the hit added if it's an explosion and we set that to not happen
						--	I'm pretty sure explosions don't crit so this should be fine
						if need_to_revert_explosion_hitrate(explosions_affect_melee_hitrate, damage_profile.name) then
							self._melee_rate[account_id].hits = self._melee_rate[account_id].hits - 1
						end
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
					elseif table_array_contains(mod_ranged_attack_types, attack_type) or table_array_contains(mod_ranged_damage_profiles, damage_profile.name) then
						self._ranged_rate = self._ranged_rate or {}
						self._ranged_rate[account_id] = self._ranged_rate[account_id] or {}
						self._ranged_rate[account_id].hits = self._ranged_rate[account_id].hits or 0
						self._ranged_rate[account_id].hits = self._ranged_rate[account_id].hits +1
						-- Reverting the hit added if it's an explosion and we set that to not happen
						--	I'm pretty sure explosions don't crit so this should be fine
						if need_to_revert_explosion_hitrate(explosions_affect_ranged_hitrate, damage_profile.name) then
							self._ranged_rate[account_id].hits = self._ranged_rate[account_id].hits - 1
							--mod:echo(damage_profile.name.." is an explosion and hitrate was reverted")
							--mod:echo("weakspot: "..tostring(hit_weakspot))
							--mod:echo("crit: "..tostring(is_critical_strike))
						end
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
					elseif table_array_contains(mod_companion_attack_types, attack_type) or table_array_contains(mod_companion_damage_profiles, damage_profile.name) then
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
					elseif table_array_contains(mod_bleeding_damage_profiles, damage_profile.name) then
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
					elseif table_array_contains(mod_burning_damage_profiles, damage_profile.name) then
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
					elseif table_array_contains(mod_warpfire_damage_profiles, damage_profile.name) then
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
					--	Toxin
					-- ------------
					elseif table_array_contains(mod_toxin_damage_profiles, damage_profile.name) then
						self._toxin_rate = self._toxin_rate or {}
						self._toxin_rate[account_id] = self._toxin_rate[account_id] or {}
						self._toxin_rate[account_id].hits = self._toxin_rate[account_id].hits or 0
						self._toxin_rate[account_id].hits = self._toxin_rate[account_id].hits + 1
						self._toxin_rate[account_id].crits = self._toxin_rate[account_id].crits or 0
						
						scoreboard:update_stat("total_toxin_damage", account_id, actual_damage)
						--if is_critical_strike then
						--	self._toxin_rate[account_id].crits = self._toxin_rate[account_id].crits + 1
						--end
						if attack_result == "died" then
							scoreboard:update_stat("total_toxin_kills", account_id, 1)
						end
						
						--self._toxin_rate[account_id].cr = self._toxin_rate[account_id].crits / self._toxin_rate[account_id].hits * 100
						
						--mod:replace_row_value("toxin_cr", account_id, self._toxin_rate[account_id].cr)
					-- ------------
					-- 	Environmental
					-- ------------
					elseif table_array_contains(mod_environmental_damage_profiles, damage_profile.name) then
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
						echo_or_info_message_based_on_debug(error_string)
					end	

					-- ------------------------
					-- Categorizing which enemy was damaged
					-- TODO maybe this could be a switch
					-- ------------------------
					if table_array_contains(mod_melee_lessers, breed_or_nil.name) then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("melee_lesser_kills", account_id, 1)
						end
					elseif table_array_contains(mod_ranged_lessers, breed_or_nil.name) then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("ranged_lesser_kills", account_id, 1)
						end
					elseif table_array_contains(mod_melee_elites, breed_or_nil.name) then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("melee_elite_kills", account_id, 1)
						end
					elseif table_array_contains(mod_ranged_elites, breed_or_nil.name) then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("ranged_elite_kills", account_id, 1)
						end
					elseif table_array_contains(mod_specials, breed_or_nil.name) then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("damage_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("damage_special_kills", account_id, 1)
						end
					elseif table_array_contains(mod_disablers, breed_or_nil.name) then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("disabler_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("disabler_special_kills", account_id, 1)
						end
					elseif table_array_contains(mod_bosses, breed_or_nil.name) then
						scoreboard:update_stat("total_boss_damage", account_id, actual_damage)
						scoreboard:update_stat("boss_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_boss_kills", account_id, 1)
							scoreboard:update_stat("boss_kills", account_id, 1)
						end
					-- ------------
					-- 	Error Catching
					--	Actually this isn't worth
					-- ------------
					else
						if not (breed_or_nil.name == "chaos_mutator_ritualist") then --"cultist_rituatlist"
							-- Prints name of out of scope enemies
							local error_string = "Breed: "..tostring(breed_or_nil.name)
							echo_or_info_message_based_on_debug(error_string)
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

