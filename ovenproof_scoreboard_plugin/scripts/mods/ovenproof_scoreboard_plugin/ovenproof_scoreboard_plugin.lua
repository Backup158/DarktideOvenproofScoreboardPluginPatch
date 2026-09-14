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
local type = type

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
-- local mod_localize = mod:localize() -- @Backup158: Yeah so this just crashes

-- #######
-- Mod Locals
-- #######
mod.version = "1.14.0"
local debug_messages_enabled
local separate_companion_damage = {}
local track_blitz_damage
local track_blitz_wr
local track_blitz_cr
local explosions_affect_ranged_hitrate
local explosions_affect_melee_hitrate
local grenade_messages
local ammo_messages
local expeditions_currency_pickups
local expeditions_loot_pickups
--[[
local categorizable_damage_types = { 
	--melee = mod:get("categorize_total_melee"), 
	--ranged = mod:get("categorize_total_ranged"), 
	--blitz = mod:get("categorize_total_blitz"), 
	--companion = mod:get("categorize_total_companion"), 
	melee = "offense_tier_1",
	ranged = "offense_tier_1",
	blitz = "offense_tier_1",
	companion = "offense_tier_1",
}
]]

local in_match = false
local is_playing_havoc = false
local is_playing_expeditions = false
local scoreboard
-- ammo pickup given as a percentage, such as 0.85
-- @backup158: when not global, it had issues being the correct values when changed by havoc
mod.ammunition_pickup_modifier = 1

-- ########################
-- Data
-- ########################
mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/scoreboard_rows")
mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/data_tables")

local mod_melee_lessers = mod.melee_lessers
local mod_ranged_lessers = mod.ranged_lessers
local mod_melee_elites = mod.melee_elites
local mod_ranged_elites = mod.ranged_elites
local mod_specials = mod.specials
local mod_disablers = mod.disablers
local mod_bosses = mod.bosses
local mod_skip = mod.skip

local mod_melee_attack_types = mod.melee_attack_types
local mod_melee_damage_profiles = mod.melee_damage_profiles
local mod_ranged_attack_types = mod.ranged_attack_types
local mod_ranged_damage_profiles = mod.ranged_damage_profiles
local mod_blitz_attack_types = mod.blitz_attack_types
local mod_blitz_damage_profiles = mod.blitz_damage_profiles
local mod_companion_attack_types = mod.companion_attack_types
local mod_companion_damage_profiles = mod.companion_damage_profiles
local mod_bleeding_damage_profiles = mod.bleeding_damage_profiles
local mod_burning_damage_profiles = mod.burning_damage_profiles
local mod_warpfire_damage_profiles = mod.warpfire_damage_profiles
local mod_electrocution_damage_profiles = mod.electrocution_damage_profiles
local mod_toxin_damage_profiles = mod.toxin_damage_profiles
local mod_environmental_damage_profiles = mod.environmental_damage_profiles

local mod_states_disabled = mod.states_disabled
local mod_optional_states_disabled = mod.optional_states_disabled
-- local mod_forge_material = mod.forge_material
local mod_ammunition = mod.ammunition
local mod_ammunition_percentage = mod.ammunition_percentage
local mod_expeditions_currency = mod.expeditions_currency
local mod_expeditions_loot = mod.expeditions_loot

-- Setup tables for tracking later
-- 		to count ammo wasted
local tracked_current_ammo_for_players = {}
-- 		to see who's interacting
-- local tracked_interaction_units_for_players = {}
--		to see who's disabled (and for when they get freed)
local tracked_disabled_players_for_players = {}

-- ########################
-- Helper Functions
-- ########################
-- ############
-- Echo or Info Message Based on Debug
-- if debug mode is active, display on screen so user can easily report
-- ############
local function echo_or_info_message_based_on_debug(message)
	if debug_messages_enabled then
		mod:echo(message.."\n"..mod:localize("warning_chat_debug_messages"))
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
		mod:replace_key_to_edit("blank_"..i, account_id, "\u{200A}")
	end
	mod:replace_key_to_edit("highest_single_hit", account_id, "\u{200A}0\u{200A}")
	mod:replace_key_to_edit("damage_done_taken_ratio", account_id, "\u{200A}0\u{200A}")
end

-- ############
-- Replace entire value in scoreboard, but not text
-- ############
mod.replace_key_to_edit = function(self, row_name, account_id, value)
	local row = scoreboard:get_scoreboard_row(row_name)
	-- mod:info("Replace key to edit: "..row_name)
	if row then
		-- local validation = row.validation
		if tonumber(value) then
			-- mod:info(">> Value is number: "..value)
			local value = value and math_max(0, value) or 0
			-- mod:info(">> Updated value: "..tostring(value))
			row.data = row.data or {}
			row.data[account_id] = row.data[account_id] or {}			
			row.data[account_id].value = value
			row.data[account_id].score = value
			row.data[account_id].text = nil
		else
			-- mod:info(">> Value is not number: "..tostring(value))
			row.data = row.data or {}
			row.data[account_id] = row.data[account_id] or {}
			row.data[account_id].text = value
			row.data[account_id].value = 0
			row.data[account_id].score = 0
		end
	end
end

-- ############
-- Replace entire value and text in scoreboard
-- ############
mod.replace_row_text_and_value = function(self, row_name, account_id, value)
	local row = scoreboard:get_scoreboard_row(row_name)
	if row then
		-- local validation = row.validation
		local value_as_number = tonumber(value)
		if value_as_number then
			local value = value and math_max(0, value) or 0
			row.data = row.data or {}
			row.data[account_id] = row.data[account_id] or {}			
			row.data[account_id].value = value_as_number
			row.data[account_id].score = value_as_number
			row.data[account_id].text = value
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
mod.get_key_to_edit = function(self, row_name, account_id)
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

-- ############
-- Calculate Damage Done/Taken Ratio
-- ############
mod.calculate_damage_done_taken_ratio = function(self, account_id, row_name_of_shortcut, given_total_value_as_shortcut)
	local new_total_damage_taken
	local new_total_damage_done
	local other_row

	if row_name_of_shortcut == "total_damage" then
		other_row = scoreboard:get_scoreboard_row("total_damage_taken")
		if other_row and other_row.data and other_row.data[account_id] then
			new_total_damage_done = given_total_value_as_shortcut
			new_total_damage_taken = other_row.data[account_id].value
		end
	elseif row_name_of_shortcut == "total_damage_taken" then
		other_row = scoreboard:get_scoreboard_row("total_damage")
		if other_row and other_row.data and other_row.data[account_id] then
			new_total_damage_done = other_row.data[account_id].value
			new_total_damage_taken = given_total_value_as_shortcut
		end
	else
		mod:info("I messed up calling damage done/taken ratio. Called row "..tostring(row_name_of_shortcut))
	end

	if new_total_damage_done and new_total_damage_taken then
		local new_ratio = new_total_damage_done / new_total_damage_taken
		mod:replace_row_text_and_value("damage_done_taken_ratio", account_id, new_ratio)
	end

end

-- ########################
-- Executions on Game States
-- ########################

-- Manage blank rows on update
--	@Backup158: WAIT WHAT THE FUCK THIS RUNS ON EVERY SINGLE GAME TICK???
function mod.update(main_dt)
	mod:manage_blank_rows()
end

-- ############
-- Updating values in the Scoreboard Rows
-- DESCRIPTION: Goes through rows registered by the scoreboard mod, then modifies a certain value
-- ############
local function replace_registered_scoreboard_value(row_name, key_to_edit, function_to_use, other_parameters)
	if not scoreboard then
		mod:info("Scoreboard missing. Attempted to change row: "..row_name)
		return
	end

	-- @backup158: ok anyone reading this is about to be horrified
	-- like why tf am i doing this O(N) when I could use a key access for constant time
	-- scoreboard only runs with arrays for itself and the plugins, and adds the plugins to itself
	-- adding a key messes up the order sorting, so my rows ended up at the bottom every time
	for i = 1, #(scoreboard.registered_scoreboard_rows) do
		local row = scoreboard.registered_scoreboard_rows[i]
		if row.name == row_name then
			function_to_use(row, key_to_edit, other_parameters)
		end
	end
end

local replace_row_with_value = function(row, key_to_edit, value)
	row[key_to_edit] = value
end

local replace_value_within_row_table = function(row, key_to_edit, value, replacing_value)
	for i = 1, #(row[key_to_edit]) do
		if row[key_to_edit][i] == value then 
			row[key_to_edit][i] = replacing_value or nil 
		end
	end
end

local add_value_within_row_table = function(row, key_to_edit, value)
	local table_to_edit = row[key_to_edit]
	if not table_array_contains(table_to_edit, value) then
		table_to_edit[#table_to_edit + 1] = value
	end
end

local function change_scoreboard_row_visibility(row_name, truth)
	replace_registered_scoreboard_value(row_name, "visible", replace_row_with_value, truth)
end

local function kill_damage_change_scoreboard_row_visibility(row_name, truth)
	change_scoreboard_row_visibility(row_name, truth)
	change_scoreboard_row_visibility(row_name.."_kills", truth)
	change_scoreboard_row_visibility(row_name.."_damage", truth)
end

local function update_all_scoreboard_row_visibilities()
	-- ------------
	-- Blitz
	-- ------------
	kill_damage_change_scoreboard_row_visibility("total_blitz", mod:get("track_blitz_damage"))
	local blitz_wr = mod:get("track_blitz_wr")
	local blitz_cr = mod:get("track_blitz_cr")
	change_scoreboard_row_visibility("blitz_wr", blitz_wr)
	change_scoreboard_row_visibility("blitz_cr", blitz_cr)
	--[[
	change_scoreboard_row_visibility("total_weakspot_rates", not blitz_wr)
	change_scoreboard_row_visibility("total_weakspot_rates_with_blitz", blitz_wr)
	change_scoreboard_row_visibility("total_critical_rates", not blitz_cr)
	change_scoreboard_row_visibility("total_critical_rates_with_blitz", blitz_cr)
	]]
	-- @backup158: TODO figure out how to change the kerning. right now the invisible column is still accounted for in terms of spacing, so it gets off center
	--		Can't just remove and readd, since that messes up the order
	if not blitz_wr then
		replace_registered_scoreboard_value("total_weakspot_rates", "text", replace_row_with_value, "row_total_weakspot_rates")
		replace_registered_scoreboard_value("total_weakspot_rates", "summary", replace_value_within_row_table, "blitz_wr")
	else
		replace_registered_scoreboard_value("total_weakspot_rates", "text", replace_row_with_value, "row_total_weakspot_rates_with_blitz")
		replace_registered_scoreboard_value("total_weakspot_rates", "summary", add_value_within_row_table, "blitz_wr")
	end
	if not blitz_cr then
		replace_registered_scoreboard_value("total_critical_rates", "text", replace_row_with_value, "row_total_critical_rates")
		replace_registered_scoreboard_value("total_critical_rates", "summary", replace_value_within_row_table, "blitz_cr")
	else
		replace_registered_scoreboard_value("total_critical_rates", "text", replace_row_with_value, "row_total_critical_rates_with_blitz")
		replace_registered_scoreboard_value("total_critical_rates", "summary", add_value_within_row_table, "blitz_cr")
	end

	-- ------------
	-- Companion
	-- ------------
	local separate_companion_damage = mod:get("separate_companion_damage")
	if separate_companion_damage == "companion" and not mod:get("separate_companion_damage_hide_regardless") then
		change_scoreboard_row_visibility("total_companion", true)
	else
		change_scoreboard_row_visibility("total_companion", false)
	end

	-- ------------
	-- Offense Grouping
	-- @backup158: This *should* be working, but it's not
	--	from dumping the tables (which causes a deadlock since it's so chunky lol), i can see the summary values changed
	--  	however, the changes do not appear in game
	--  everything is supposed to be in group_1, so not that
	--  Trying to replace directly here without mod:get, still nope
	--  Replacing with mod:get in scoreboard_rows.lua: Nope
	--  Replacing directly in scoreboard_rows.lua: NOPE???? HOW????
	-- ------------
	--[[
	for damage_type, categorization in pairs(categorizable_damage_types) do
		local new_categorization = mod:get("categorize_total_"..damage_type)
		mod:info("for "..damage_type.." from "..categorization.." to "..new_categorization)
		if not (categorization == new_categorization) then
			local total_x = "total_"..damage_type
			local total_x_kills = total_x.."_kills"
			local total_x_damage = total_x.."_damage"
			mod:echo("changing category for "..total_x)
			-- Getting the last character of the category
			--	substring -1 to do that
			--local new_group = "group_"..string_sub(new_categorization, -1)
			
			replace_registered_scoreboard_value(total_x, "setting", replace_row_with_value, new_categorization)
			replace_registered_scoreboard_value(total_x_kills, "setting", replace_row_with_value, new_categorization)
			replace_registered_scoreboard_value(total_x_damage, "setting", replace_row_with_value, new_categorization)
			--replace_registered_scoreboard_value(total_x, "group", replace_row_with_value, new_group)
			--replace_registered_scoreboard_value(total_x_kills, "group", replace_row_with_value, new_group)
			--replace_registered_scoreboard_value(total_x_damage, "group", replace_row_with_value, new_group)
			categorizable_damage_types[damage_type] = new_categorization
		end
	end]]
	--replace_registered_scoreboard_value("total_melee", "setting", replace_row_with_value, "offense_tier_3")
	--replace_registered_scoreboard_value("total_melee_damage", "setting", replace_row_with_value, "offense_tier_3")
	--replace_registered_scoreboard_value("total_melee_kills", "setting", replace_row_with_value, "offense_tier_3")

	-- ------------
	-- Defense
	-- ------------
	-- Hiding friendly fire damage
	if mod:get("option_hide_friendly_fire") then
		change_scoreboard_row_visibility("total_friendly", false)
		change_scoreboard_row_visibility("friendly_damage", false)
		change_scoreboard_row_visibility("friendly_shots_blocked", false)
	else
		-- this is the default, but I need this here to work without a restart/reload
		change_scoreboard_row_visibility("total_friendly", true)
		change_scoreboard_row_visibility("friendly_damage", true)
		change_scoreboard_row_visibility("friendly_shots_blocked", true)
	end

	-- ------------
	-- Fun Stuff
	-- ------------
	-- Hiding damage done/taken ratio
	if mod:get("option_hide_damage_done_taken_ratio") then
		-- this is the default, but I need this here to work without a restart/reload
		change_scoreboard_row_visibility("damage_done_taken_ratio", false)
	else
		change_scoreboard_row_visibility("damage_done_taken_ratio", true)
	end

	-- ------------
	-- Expeditions Pickup Classification
	-- ------------
	local currency_only_in_expeditions = mod:get("exploration_show_currency_only_in_expeditions")
	-- @Backup158: Technically this misses the case where you track as materials, and someone picks up Salvage while not in Expeditions. Since that's impossible AFAIK, this will be good enough.
	if (not (expeditions_currency_pickups == 1)) or 
		(currency_only_in_expeditions and (not is_playing_expeditions))
	then
		change_scoreboard_row_visibility("total_expeditions_currency_pickups", false)
	else
		change_scoreboard_row_visibility("total_expeditions_currency_pickups", true)
	end
	local loot_only_in_expeditions = mod:get("exploration_show_loot_only_in_expeditions")
	if (not (expeditions_loot_pickups == 1)) or
		(loot_only_in_expeditions and (not is_playing_expeditions))
	then
		change_scoreboard_row_visibility("total_expeditions_loot_pickups", false)
	else
		change_scoreboard_row_visibility("total_expeditions_loot_pickups", true)
	end
end

local function set_locals_for_settings()
	debug_messages_enabled = mod:get("enable_debug_messages")
	explosions_affect_ranged_hitrate = mod:get("explosions_affect_ranged_hitrate")
	explosions_affect_melee_hitrate = mod:get("explosions_affect_melee_hitrate")
	track_blitz_damage = mod:get("track_blitz_damage")
	track_blitz_wr = mod:get("track_blitz_wr")
	track_blitz_cr = mod:get("track_blitz_cr")
	separate_companion_damage.base = mod:get("separate_companion_damage")
	separate_companion_damage.kills = "total_"..separate_companion_damage.base.."_kills"
	separate_companion_damage.damage = "total_"..separate_companion_damage.base.."_damage"
	grenade_messages = mod:get("grenade_messages")
	ammo_messages = mod:get("ammo_messages")
	expeditions_currency_pickups = mod:get("exploration_track_currency")
	expeditions_loot_pickups = mod:get("exploration_track_loot")

	-- Error check for companion damage row
	if mod:get("enable_companion_blitz_warning")
	and (separate_companion_damage.base == "blitz")
	and not track_blitz_damage
	then
		mod:warning(mod:localize("warning_companion_blitz"))
	end
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
	-- @Backup158: Ugly manual check for data tables.
	if setting_id == "exploration_player_loot_value" then
		mod.expeditions_loot["loc_expeditions_pickup_loot_player_drop"]["amount"] = mod:get(setting_id)
		-- Refresh cache
		mod_expeditions_loot = mod.expeditions_loot
	end
end

-- ############
-- ** Mod Startup **
-- ############
function mod.on_all_mods_loaded()
	scoreboard = get_mod("scoreboard")
	if not scoreboard then
		mod:error(mod:localize("error_scoreboard_missing"))
		return
	end

	set_locals_for_settings()
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
		mod:add_damage_done_taken_ratio()
		--mod:echo("IF YOU SEE THIS YELL AT ME: tactical overlay widgets")
		func(self, dt, t, input_service, ui_renderer, render_settings, ...)
		-- base mod hooks onto this first, but executes after the original function
	end)
	-- ######
	-- Before game end
	-- ######
	mod:hook(CLASS.EndView, "on_enter", function(func, self)
		mod:add_damage_done_taken_ratio()
		--mod:echo("IF YOU SEE THIS YELL AT ME: entering end view")
		func(self)
		-- base mod hooks onto this first, but executes after the original function
	end)
	]]

	-- ############
	-- Interactions Started?
	-- ############
	mod:hook(CLASS.InteracteeExtension, "started", function(func, self, interactor_unit, ...)
		-- @Backup158: Wait I never see this get used?
		-- tracked_interaction_units_for_players[self._unit] = interactor_unit

		-- Ammunition
		local unit_data_extension = ScriptUnit.extension(interactor_unit, "unit_data_system")
		local wieldable_component = unit_data_extension:read_component("slot_secondary")
		tracked_current_ammo_for_players[interactor_unit] = wieldable_component.current_ammunition_reserve

		func(self, interactor_unit, ...)
	end)

	-- ############
	-- Exploration: Equipment Use and Pickups
	--	Track materials picked up, health stations used, and ammo picked up
	--	Interactions stopped
	-- ############
	mod:hook(CLASS.InteracteeExtension, "stopped", function(func, self, result, ...)
		if result == interaction_results.success then
			local interaction_type = self:interaction_type() or ""
			local unit = self._interactor_unit
			if unit then
				local player = Managers.player:player_by_unit(unit)
				local profile = player:profile()
				if player then
					local account_id = player:account_id() or player:name()
					local color = Color.citadel_casandora_yellow(255, true)
					if interaction_type == "forge_material" then
						scoreboard:update_stat("total_material_pickups", account_id, 1)
					elseif interaction_type == "health_station" then
						scoreboard:update_stat("total_health_stations", account_id, 1)
					elseif interaction_type == "grenade" then
						scoreboard:update_stat("ammo_grenades", account_id, 1)
						if grenade_messages then
							local text = TextUtilities.apply_color_to_text(mod:localize("message_grenades_text"), color)
							local message = mod:localize("message_grenades_body", text)
							Managers.event:trigger("event_combat_feed_kill", unit, message)
						end
					elseif interaction_type == "ammunition" then
						local ammo = mod_ammunition[self._override_contexts.ammunition.description]

						-- Expedition purchasables
						--	rockets and stuff that we buy with Salvage
						--  These get specifically counted as "ammunition" interactions instead of crate pickups I guess
						--  So this check is to avoid unnecessarily calculating current ammo amounts
						if ammo == "expedition_pocketable" then
							-- nyaaa
						else
							-- Get components
							local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
							local wieldable_component = unit_data_extension:read_component("slot_secondary")
							-- Get ammo numbers
							local current_ammo_clip = wieldable_component.current_ammunition_clip[1]
							local max_ammo_clip = wieldable_component.max_ammunition_clip[1]
							--[[
							if type(current_ammo_clip) == "table" then
								mod:echo("uwu current_ammo_clip is a table")
								table.dump(current_ammo_clip, "uwu current_ammo_clip", 20)
							else
								mod:echo("uwu current_ammo_clip: "..tostring(current_ammo_clip))
							end
							if type(max_ammo_clip) == "table" then
								mod:echo("uwu max ammo clip is a table")
								table.dump(max_ammo_clip, "uwu MAX AMMO CLIP", 20)
							else
								mod:echo("uwu max ammo clip: "..tostring(max_ammo_clip))
							end
							]]
							local current_ammo_reserve = tracked_current_ammo_for_players[unit]
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
								if ammo_messages then
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
								if ammo_messages then
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
								local uncategorized_ammo_pickup_message = "Uncategorized ammo pickup! It is: "..tostring(ammo.."\nName: "..tostring(self._override_contexts.ammunition.description))
								echo_or_info_message_based_on_debug(uncategorized_ammo_pickup_message)
							end -- Close If chain: ammo identification
						end -- Close If: ammo is expedition pocketable
					-- Expeditions Salvage
					elseif interaction_type == "expeditions_currency" then
						-- @Backup158: Hey, it's the magic numbers I've been taught to not use!
						-- This was a lazy way to allow a dropdown without checking string values, or creating tables all willy nilly
						if mod:get("exploration_track_currency") > 0 then
							local currency_description = self._override_contexts.expeditions_currency.description
							local currency_table = mod_expeditions_currency[currency_description]
							local currency_amount = 0
							if currency_table then 
								currency_amount = currency_table.amount or 0
							end

							scoreboard:update_stat("total_expeditions_currency_pickups", account_id, currency_amount)
							if mod:get("exploration_track_currency") == 2 then
								-- This will be inaccurate if you toggle it midgame, but if you do that then uh... go fuck yourself
								scoreboard:update_stat("total_material_pickups", account_id, 1)
							end
						end
					-- Expeditions Tech-Remnants
					elseif interaction_type == "expeditions_loot" then
						if mod:get("exploration_track_loot") > 0 then
							local loot_description = self._override_contexts.expeditions_loot.description
							-- if loot_description == "loc_expeditions_pickup_loot_player_drop" then mod:echo("meow. player drop pickup! :3c") end
							local loot_table = mod_expeditions_loot[loot_description]
							local loot_amount = 0
							if loot_table then
								loot_amount = loot_table.amount or 0
							else
								echo_or_info_message_based_on_debug("Picked up: "..loot_description)
							end

							scoreboard:update_stat("total_expeditions_loot_pickups", account_id, loot_amount)
							if mod:get("exploration_track_loot") == 2 then
								scoreboard:update_stat("total_material_pickups", account_id, 1)
							end
						end
					else
						-- mod:echo("InteracteeExtension stopped: "..interaction_type)
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
		-- local Breed = scoreboard:original_require("scripts/utilities/breed")
		if unit then
			local player = Managers.player:player_by_unit(unit)
			if player then		
				local account_id = player:account_id() or player:name()			
				local player_state = self._character_state_read_component.state_name
				if self._damage and self._damage > 0 then
					scoreboard:update_stat("total_damage_taken", account_id, self._damage)
					mod:calculate_damage_done_taken_ratio(account_id, "total_damage_taken", self._damage)
				end
				
				local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
				local disabled_character_state_component = unit_data_extension:read_component("disabled_character_state")
				if disabled_character_state_component then
					local is_disabled = disabled_character_state_component.is_disabled
					-- local is_pounced = is_disabled and disabled_character_state_component.disabling_type == "pounced"
					local disabling_unit = disabled_character_state_component.disabling_unit
					
					if is_disabled and disabling_unit then
						tracked_disabled_players_for_players[account_id] = disabling_unit
					end
				end

				self._player_state_tracker = self._player_state_tracker or {}
				self._player_state_tracker[account_id] = self._player_state_tracker[account_id] or {}
				self._player_state_tracker[account_id].state = self._player_state_tracker[account_id].state or {}
				
				if self._player_state_tracker[account_id].state ~= player_state then
					if 	(	not mod_states_disabled[self._player_state_tracker[account_id].state] 
							and not mod_states_disabled[player_state] 
						) and
						(	not mod_optional_states_disabled[self._player_state_tracker[account_id].state]
							and not mod_optional_states_disabled[player_state] 
						)
					then
						tracked_disabled_players_for_players[account_id] = nil
					end
					self._player_state_tracker[account_id].state = player_state
					if mod_states_disabled[player_state] then
						-- mod:echo("uwu Typical disabled state: "..player_state.." caught account: "..account_id.." ("..tostring(player:name())..")")
						scoreboard:update_stat("total_times_disabled", account_id, 1)
					-- optionally tracks these disabled states, if enabled
					elseif mod_optional_states_disabled[player_state] then
						-- mod:echo("uwu Optional state: "..player_state.." caught account: "..account_id.." ("..tostring(player:name())..")")
						if mod:get("track_"..player_state) then
							-- mod:echo(">> Tracking that optional state: "..player_state)
							scoreboard:update_stat("total_times_disabled", account_id, 1)
						end
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
					local account_id = player:account_id() or player:name()
					if type == "pull_up" or type == "remove_net" then
						scoreboard:update_stat("total_operatives_helped", account_id, 1)
					elseif type == "revive" then
						-- mod:echo(">> reviver's account_id (from interaction): "..tostring(account_id))
						scoreboard:update_stat("total_operatives_revived", account_id, 1)
					elseif type == "rescue" then
						scoreboard:update_stat("total_operatives_rescued", account_id, 1)
					end
				end
			end
		end
		func(self, result, ...)
	end)

	-- ######
	-- Defense: Helping Allies
	-- 	Tracks Servo Skull revives
	-- ######
	-- lol no
	--[[
	mod:hook(CLASS.CompanionServoSkullAbility, "start_inject_ally_ability", function(companion_unit, target_finder_component, position_finder_component, ability_extension, is_server, ...)
		mod:echo("injecting ally")
	end)
	]]
	--  never played
	--[[
	mod:hook_require("scripts/extension_systems/behavior/nodes/actions/bt_inject_syringe", function(instance)
		mod:hook(instance, "_revive_ally_if_needed", function(self, owner_player, target_ally, scratchpad, t, ...)
			mod:echo("injecting ally 3")
			if owner_player then
				mod:echo(">> owner_player: "..tostring(owner_player))
			end
			if target_ally then
				mod:echo(">> target_ally: "..tostring(target_ally))
			end
		end)
	end)
	mod:hook_require("scripts/extension_systems/interaction/interactions/revive_interaction", function(instance)
		mod:hook_safe(instance, "stop", function(self, world, interactor_unit, unit_data_component, t, result, interactor_is_server, ...)
			mod:echo("ally revive direct")
			if result == interaction_results.success then
				local target_unit = unit_data_component.target_unit
				if interactor_unit then
					mod:echo(">> interactor_unit: "..tostring(interactor_unit))
				end
				if target_unit then
					mod:echo(">> target_unit: "..tostring(target_unit))
				end
				
			end
		end)
	end)
	mod:hook_require("scripts/extension_systems/interaction/interactions/assist_base_interaction", function(instance)
		mod:hook(instance, "_record_stats_and_telemetry", function(self, interactor_unit, target_unit, stat_id, from_state_name, ...)
			mod:echo("ally revived")
			local player_unit_spawn_manager = Managers.state.player_unit_spawn
			local interactor_player = player_unit_spawn_manager:owner(interactor_unit)
			local target_player = player_unit_spawn_manager:owner(target_unit)
			if interactor_player then
				mod:echo(">> interactor_player: "..tostring(interactor_player))
			end
			if target_player then
				mod:echo(">> target_player: "..tostring(target_player))
			end
		end)
	end)
	-- Only tells you one of the players
	mod:hook_require("scripts/foundation/managers/player/player_manager", function(instance)
		mod:hook(instance, "rpc_player_assisted", function(self, channel_id, peer_id, assist_type_lookup, ...)
			local assist_type = NetworkLookup.assist_type_lookup[assist_type_lookup]
			if reviver_player then
				mod:echo(">> reviver_player: "..tostring(reviver_player))
			end
			if revivee_player then
				mod:echo(">> revivee_player: "..tostring(revivee_player))
			end
		end)
	end)
	-- Server only
	mod:hook_require("scripts/utilities/player_assist_notifications", function(instance)
		mod:hook(instance, "show_notification", function(assisted_unit, assisting_unit, assist_type, ...)
			mod:echo("(notifications) Ally was saved")

			if assisted_unit and assisting_unit then
				local assisting_player = Managers.state.player_unit_spawn:owner(assisting_unit)
				if not assisting_player then return end

				local assisting_player_id = assisting_player:peer_id()
				local assisted_player = Managers.state.player_unit_spawn:owner(assisted_unit)
				if assisted_player then
					-- bots dont have id
					local assisted_player_id = assisted_player:channel_id()
				end

				mod:echo(">> "..tostring(assisting_player_id).." saved "..tostring(assisted_player_id))
			end
		end)
	end)
	]]

	-- Only worked for player, not allies
	--[[
	-- ty Wobin
	mod:hook_require("scripts/utilities/companion/companion_servo_skull_ability", function(instance)
		mod:hook(instance, "start_inject_ally_ability", function(companion_unit, target_finder_component, position_finder_component, ability_extension, is_server, ...)
			mod:echo("Injecting ally: start_inject_ally_ability")
			mod:echo("target_finder_component is a "..type(target_finder_component))
			if target_finder_component.target_unit_1 then
				mod:echo("target_finder_component.target_unit_1 is a "..type(target_finder_component.target_unit_1))
			end
			local ally = target_finder_component
			if not ally then
				mod:echo("No target")
				return
			end

			local companion_injecting = companion_unit
			if not companion_injecting then
				mod:echo("Nobody wants to inject :(")
				return
			end
			
			local all_players = Managers.player:players()
			for _, player in pairs(all_players) do
				local player_unit = player.player_unit
				if player_unit and ALIVE[player_unit] then
					local spawner_ext = ScriptUnit.has_extension(player_unit, "companion_spawner_system")
					if spawner_ext then
						-- Identify companions
						local companions = {}
						if spawner_ext._spawned_units then
							for _, u in ipairs(spawner_ext._spawned_units) do
								table.insert(companions, u)
							end
						end
						local SpecialRules = require("scripts/settings/ability/special_rules_settings").special_rules
						if SpecialRules and spawner_ext.spawned_unit_lookup then
							local rules = {
								"cryptic_servo_skull",
								"cryptic_servo_skull_lasgun",
								"cryptic_servo_skull_flamethrower",
								"cryptic_servo_skull_hack",
								"cryptic_servo_skull_inject_ally"
							}
							for _, rule_name in ipairs(rules) do
								local success, rule = pcall(function() return SpecialRules[rule_name] end)
								if success and rule then
									local u = spawner_ext:spawned_unit_lookup(rule)
									if u then table.insert(companions, u) end
								end
							end
						end
						for _, spawned_unit in ipairs(companions) do
							if spawned_unit == companion_injecting then
								if type(player) == "table" then
									table.dump(table, "Player with companion owo", 10)
								end
								mod:echo("player with companion injecting xddd "..tostring(player))
							end
						end

						table.dump(companions, "All companions owo", 10)
					end
				end
			end
			
			--local unit = self._interactor_unit
			--if unit then
			--	local player = Managers.player:player_by_unit(unit)
			--	if player then
			--		local account_id = player:account_id() or player:name()
			--		if type == "pull_up" or type == "remove_net" then
			--			scoreboard:update_stat("total_operatives_helped", account_id, 1)
			--		elseif type == "revive" then
			--			mod:echo(">> reviver's account_id (from interaction): "..tostring(account_id))
			--			scoreboard:update_stat("total_operatives_revived", account_id, 1)
			--		elseif type == "rescue" then
			--			scoreboard:update_stat("total_operatives_rescued", account_id, 1)
			--		end
			--	end
			--end
		end)
	end)
	]]

	-- Works for skull. would have to replace the other one
	-- Seems to mainly work when it's the player doing it. and is inconsistent in online matches
	--[[
	mod:hook_require("scripts/managers/telemetry/telemetry_events", function(instance)
		mod:hook(instance, "player_revived_ally", function(self, reviver_player, revivee_player, reviver_position, revivee_position, state_name, revived_by_servo_skull, ...)
			mod:echo("ally revived from telemetry")

			if reviver_player then
				mod:echo(">> reviver_player: "..tostring(reviver_player))
			end
			if revivee_player then
				mod:echo(">> revivee_player: "..tostring(revivee_player))
			end
		end)
	end)
	]]

	-- ######
	-- Defense: Helping Allies
	-- 	Tracks VoC revives
	-- ######
	-- didn't work
	--[[
	mod:hook_require("scripts/utilities/shout_ability", function(instance)
		-- This is a local function in that file
		mod:hook(instance, "_handle_allied_targets", function(t, radius, target_settings, player_unit, locomotion_component, player_side, player_buff_extension, backup_position, backup_rotation, external_power_modifier, ...)
			mod:echo("voc targetted ally ally")

			if revive_allies and talent_extension then
				mod:echo("voc variables exist")
			end
		end)
	end)
	]]
	--[[
	function mod.veteran_shout_handle_allies_copy(t, radius, target_settings, player_unit, locomotion_component, player_side, player_buff_extension, backup_position, backup_rotation, external_power_modifier)
		if not target_settings then
			return
		end

		if not player_side then
			return
		end

		local player_position = locomotion_component and locomotion_component.position or backup_position
		local player_stat_buffs = player_buff_extension:stat_buffs()
		local buff_to_add = target_settings.buff_to_add
		local talent_extension = ScriptUnit.has_extension(player_unit, "talent_system")
		local shout_restores_toughness = talent_extension:has_special_rule(special_rules.shout_restores_toughness) or target_settings.shout_restores_toughness

		if buff_to_add or shout_restores_toughness then
			local coherency_extension = ScriptUnit.has_extension(player_unit, "coherency_system")
			local in_coherence_units = coherency_extension:in_coherence_units()

			for unit, _ in pairs(in_coherence_units) do
				if ALIVE[unit] then
					if buff_to_add then
						local buff_extension = ScriptUnit.extension(unit, "buff_system")

						if buff_extension then
							buff_extension:add_internally_controlled_buff(buff_to_add, t, "owner_unit", player_unit)
						end
					end

					if shout_restores_toughness then
						local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
						local breed = unit_data_extension and unit_data_extension:breed()

						if Breed.is_player(breed) then
							local recover_toughness_effect = target_settings.recover_toughness_effect

							if recover_toughness_effect then
								local fx_extension = ScriptUnit.extension(unit, "fx_system")

								fx_extension:spawn_exclusive_particle(recover_toughness_effect, Vector3(0, 0, 1))
							end

							local toughness_percent = target_settings.toughness_replenish_percent or 1

							Toughness.replenish_percentage(unit, toughness_percent, nil, "ability_shout")
						end
					end
				end
			end
		end

		local revive_allies = target_settings.revive_allies

		if revive_allies and talent_extension then
			local allied_side_names = player_side:relation_side_names("allied")
			local broadphase_system = Managers.state.extension:system("broadphase_system")
			local broadphase = broadphase_system.broadphase
			local radius_modifier = player_stat_buffs.shout_radius_modifier or 1
			local radius_to_use = radius * radius_modifier

			table.clear(broadphase_results)

			local num_hits = broadphase.query(broadphase, player_position, radius_to_use, broadphase_results, allied_side_names, PLAYER_BREED_TYPE)

			for ii = 1, num_hits do
				local unit = broadphase_results[ii]
				local revive_special_rule = special_rules.shout_revives_allies
				local has_special_rule = talent_extension:has_special_rule(revive_special_rule)

				if has_special_rule then
					local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
					local character_state_component = unit_data_extension and unit_data_extension:read_component("character_state")

					if character_state_component and PlayerUnitStatus.is_knocked_down(character_state_component) then
						local assisted_state_input_component = unit_data_extension:write_component("assisted_state_input")

						assisted_state_input_component.force_assist = true

						if ALIVE[unit] then
							PlayerAssistNotifications.show_notification(unit, player_unit, "saved")
						end
					end
				end
			end
		end
	end
	]]

	-- ############
	-- Offense
	--	Damage, kills, and crit/weakspot rate
	--	Attack reports
	-- ############
	mod:hook(CLASS.AttackReportManager, "add_attack_result", function(func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike, ...)
		local player = attacking_unit and player_from_unit(attacking_unit)
		-- Only check damage if done by a player. @Backup158: Could there be a check for companion that can be associated with the player?
		if player then
			local target_is_player = attacked_unit and player_from_unit(attacked_unit)
			
			if damage > 0 then			
				local Breed = scoreboard:original_require("scripts/utilities/breed")
				local actual_damage
				local account_id = player:account_id() or player:name()

				local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
				local breed_or_nil = unit_data_extension and unit_data_extension:breed()
				local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)

				-- Updates stats depending on what the target type
				-- 	Minion is effectively enemies, since friendly minions can't get damaged by you
				--  Player is player
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
						if mod_disablers[breed_or_nil.name] then
							for k,v in pairs(tracked_disabled_players_for_players) do
								if v == attacked_unit then
									scoreboard:update_stat("total_operatives_helped", account_id, 1)
									tracked_disabled_players_for_players[k] = nil
								end
							end
						end

					else
						actual_damage = damage
					end
					
					scoreboard:update_stat("total_damage", account_id, actual_damage)
					mod:calculate_damage_done_taken_ratio(account_id, "total_damage", actual_damage)
					
					-- ------------------------
					-- Updating Fun Stuff
					-- ------------------------
					self._attack_report_tracker = self._attack_report_tracker or {}
					self._attack_report_tracker[account_id] = self._attack_report_tracker[account_id] or {}
					self._attack_report_tracker[account_id].highest_single_hit = self._attack_report_tracker[account_id].highest_single_hit or 0
					self._attack_report_tracker[account_id].one_shots = self._attack_report_tracker[account_id].one_shots or 0

					if actual_damage > self._attack_report_tracker[account_id].highest_single_hit then
						self._attack_report_tracker[account_id].highest_single_hit = actual_damage
						-- @Backup158: actual_damage is the same as damage
						mod:replace_row_text_and_value("highest_single_hit", account_id, math_floor(damage))
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
					if mod_melee_attack_types[attack_type] or (mod_melee_damage_profiles[damage_profile.name] and not mod_companion_attack_types[attack_type]) then
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
						
						mod:replace_key_to_edit("melee_cr", account_id, self._melee_rate[account_id].cr)
						mod:replace_key_to_edit("melee_wr", account_id, self._melee_rate[account_id].wr)
					-- ------------
					--	Blitz
					-- 	Blitzes overlap with ranged damage, so this check must be done first
					--  Tracks Crit and Weakspot because of Assail and such
					-- ------------
					elseif track_blitz_damage 
					and (mod_blitz_attack_types[attack_type] 
						or mod_blitz_damage_profiles[damage_profile.name]
				 		) 
					then
						self._blitz_rate = self._blitz_rate or {}
						self._blitz_rate[account_id] = self._blitz_rate[account_id] or {}
						self._blitz_rate[account_id].hits = self._blitz_rate[account_id].hits or 0
						self._blitz_rate[account_id].hits = self._blitz_rate[account_id].hits +1
						
						scoreboard:update_stat("total_blitz_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_blitz_kills", account_id, 1)
						end

						if track_blitz_wr then
							self._blitz_rate[account_id].weakspots = self._blitz_rate[account_id].weakspots or 0
							if hit_weakspot then
								self._blitz_rate[account_id].weakspots = self._blitz_rate[account_id].weakspots + 1
							end
							self._blitz_rate[account_id].wr = self._blitz_rate[account_id].weakspots / self._blitz_rate[account_id].hits * 100
							mod:replace_key_to_edit("blitz_wr", account_id, self._blitz_rate[account_id].wr)
						end
						
						if track_blitz_cr then
							self._blitz_rate[account_id].crits = self._blitz_rate[account_id].crits or 0
							if is_critical_strike then
								self._blitz_rate[account_id].crits = self._blitz_rate[account_id].crits + 1
							end
							self._blitz_rate[account_id].cr = self._blitz_rate[account_id].crits / self._blitz_rate[account_id].hits * 100
							mod:replace_key_to_edit("blitz_cr", account_id, self._blitz_rate[account_id].cr)
						end
					-- ------------
					--	Companion
					--  After Skitarii released, companion overlaps with ranged too
					-- ------------
					elseif mod_companion_attack_types[attack_type] or mod_companion_damage_profiles[damage_profile.name] then
						-- Crit and Weakspot rates don't matter
		
						-- By default, uses its own companion row, which reads: total_companion_damage and total_companion_kills
						scoreboard:update_stat(separate_companion_damage.damage, account_id, actual_damage)

						if attack_result == "died" then
							scoreboard:update_stat(separate_companion_damage.kills, account_id, 1)
						end
					-- ------------
					--	Ranged
					-- ------------
					elseif mod_ranged_attack_types[attack_type] or mod_ranged_damage_profiles[damage_profile.name] then
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
						
						mod:replace_key_to_edit("ranged_cr", account_id, self._ranged_rate[account_id].cr)
						mod:replace_key_to_edit("ranged_wr", account_id, self._ranged_rate[account_id].wr)
					-- ------------
					--	Bleed
					-- ------------
					elseif mod_bleeding_damage_profiles[damage_profile.name] then
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
						
						--mod:replace_key_to_edit("bleeding_cr", account_id, self._bleeding_rate[account_id].cr)
					-- ------------
					--	Burning
					-- ------------
					elseif mod_burning_damage_profiles[damage_profile.name] then
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
						
						--mod:replace_key_to_edit("burning_cr", account_id, self._burning_rate[account_id].cr)
					-- ------------
					--	Warp
					-- ------------
					elseif mod_warpfire_damage_profiles[damage_profile.name] then
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
						
						--mod:replace_key_to_edit("warpfire_cr", account_id, self._warpfire_rate[account_id].cr)
					-- ------------
					--	Toxin
					-- ------------
					elseif mod_toxin_damage_profiles[damage_profile.name] then
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
						
						--mod:replace_key_to_edit("toxin_cr", account_id, self._toxin_rate[account_id].cr)
					-- ------------
					-- 	Environmental
					-- ------------
					elseif mod_environmental_damage_profiles[damage_profile.name] then
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
						
						--mod:replace_key_to_edit("environmental_cr", account_id, self._environmental_rate[account_id].cr)
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
					-- ------------------------
					if mod_melee_lessers[breed_or_nil.name] then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("melee_lesser_kills", account_id, 1)
						end
					elseif mod_ranged_lessers[breed_or_nil.name] then
						scoreboard:update_stat("total_lesser_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_lesser_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_lesser_kills", account_id, 1)
							scoreboard:update_stat("ranged_lesser_kills", account_id, 1)
						end
					elseif mod_melee_elites[breed_or_nil.name] then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("melee_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("melee_elite_kills", account_id, 1)
						end
					elseif mod_ranged_elites[breed_or_nil.name] then
						scoreboard:update_stat("total_elite_damage", account_id, actual_damage)
						scoreboard:update_stat("ranged_elite_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_elite_kills", account_id, 1)
							scoreboard:update_stat("ranged_elite_kills", account_id, 1)
						end
					elseif mod_specials[breed_or_nil.name] then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("damage_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("damage_special_kills", account_id, 1)
						end
					elseif mod_disablers[breed_or_nil.name] then
						scoreboard:update_stat("total_special_damage", account_id, actual_damage)
						scoreboard:update_stat("disabler_special_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_special_kills", account_id, 1)
							scoreboard:update_stat("disabler_special_kills", account_id, 1)
						end
					elseif mod_bosses[breed_or_nil.name] then
						scoreboard:update_stat("total_boss_damage", account_id, actual_damage)
						scoreboard:update_stat("boss_damage", account_id, actual_damage)
						if attack_result == "died" then
							scoreboard:update_stat("total_boss_kills", account_id, 1)
							scoreboard:update_stat("boss_kills", account_id, 1)
						end
					-- ------------
					-- 	Error Catching
					-- ------------
					elseif mod_skip[breed_or_nil.name] then
						-- do nothing
						-- this is so ugly but idc :D
					else
						-- Prints name of out of scope enemies
						local error_string = "Breed: "..tostring(breed_or_nil.name)
						echo_or_info_message_based_on_debug(error_string)
					end
				elseif target_is_player then
					scoreboard:update_stat("friendly_damage", account_id, damage)
				end
			end
			
			-- Friendly fire typically has 0 damage done
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
	-- @Backup158: think this means "entering gameplay" from "hub"
	if state_name == "GameplayStateRun" and status == "enter" and Managers.state.mission:mission().name ~= "hub_ship" then
		in_match = true

		-- Check if match is Havoc
		-- Needed to set the ammunition pickup modifier
		-- 1. In a normal match, it is 1
		-- 2. In a Havoc match...
		--		When there's an actual modifier, it's an actual value [0.85, 0.4]
		-- 		At lower ranks, the modifier is 1 but it's not actually written as the modifier value
		local havoc_extension = Managers.state.game_mode:game_mode():extension("havoc")
		-- is_playing_havoc = Managers.state.difficulty:get_parsed_havoc_data() -- No longer works
		if havoc_extension then
			is_playing_havoc = true
			-- Fallback for low ranks
			mod.ammunition_pickup_modifier = havoc_extension:get_modifier_value("ammo_pickup_modifier") or 1
			mod:info("Havoc ammo modifier: "..tostring(mod.ammunition_pickup_modifier))
		else
			mod.ammunition_pickup_modifier = 1 
		end
		
		-- local expeditions_extension = Managers.state.game_mode:game_mode():extension("expedition") -- does not work
		-- local Expedition = class("Expedition") -- happens every time
		-- @Backup158: It seems this game mode check doesn't work for Havoc, since the game code still uses the old way (shown above)
		local game_mode_name = Managers.state.game_mode:game_mode_name()
		if game_mode_name == "expedition" then
			-- mod:echo("playing EXPEDITIONS!")
			is_playing_expeditions = true
		else
			is_playing_expeditions = false
		end
	else
		in_match = false
		is_playing_havoc = false
		is_playing_expeditions = false
	end

	update_all_scoreboard_row_visibilities()
end

