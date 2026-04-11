local mod = get_mod("ovenproof_scoreboard_plugin")

-- ########################
-- Variables and Performance
-- ########################
local table = table
local table_clone = table.clone
local data_tables = mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/data_tables")

local offense_tier_options = {
	{text = "offense_tier_0", value = "offense_tier_0", title = "offense_tier_0", },
	{text = "offense_tier_1", value = "offense_tier_1", title = "offense_tier_1", },
	{text = "offense_tier_2", value = "offense_tier_2", title = "offense_tier_2", },
	{text = "offense_tier_3", value = "offense_tier_3", title = "offense_tier_3", },
}

-- ########################
-- Helper Functions
-- ########################
-- Creates a widget with a subwidget to toggle it only for Havoc
local function create_setting_with_havoc_toggle(setting_id_code)
	return
		{	setting_id 		= setting_id_code,
			type 			= "checkbox",
			default_value 	= false,
			sub_widgets 	= {
				{	setting_id 		= setting_id_code.."_only_in_havoc",
					title 			= "setting_only_in_havoc",
					type 			= "checkbox",
					default_value 	= false,
				},
			},
		}
end
-- @backup158: because i'm lazy
local function create_setting_toggle(setting_id_code, truth)
	return
		{	setting_id 		= setting_id_code,
			type 			= "checkbox",
			default_value 	= truth or false, -- Defaults to false to make the logic work out with OR
		}
end

-- Given a specific table to inject into
--local function insert_widget_table_to_subtable(widget_table, table_address)
--	table_address[#table_address + 1] = widget_table
--end

-- Automatically premaking widgets for tracking optional disabled states
local optional_states_disabled_widgets = {}
for _, state in pairs(mod.optional_states_disabled) do
	optional_states_disabled_widgets[#optional_states_disabled_widgets + 1] = create_setting_toggle("track_"..state, false)
end

-- ########################
-- Widgets
-- ########################
local data_and_widgets = {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{	setting_id 		= "enable_debug_messages",
				type 			= "checkbox",
				default_value	= true,
			},
			{	setting_id 		= "row_categories_group",
				type 			= "group",
				sub_widgets		= {
					{	["setting_id"] = "exploration_tier_0",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "defense_tier_0",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "offense_rates",
						["type"] = "checkbox",
						["default_value"] = true,
					},	
					{	["setting_id"] = "offense_tier_0",
						["type"] = "checkbox",
						["default_value"] = true,
					},		
					{	["setting_id"] = "offense_tier_1",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "offense_tier_2",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "offense_tier_3",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "fun_stuff_01",
						["type"] = "checkbox",
						["default_value"] = true,
					},
					{	["setting_id"] = "bottom_padding",
						["type"] = "checkbox",
						["default_value"] = true,
					},
				},
			},
			{	setting_id 		= "custom_row_categorization",
				type 			= "group",
				sub_widgets		= {
					{	["setting_id"] = "categorize_total_melee",
						["type"] = "dropdown",
						["default_value"] = "offense_tier_1",
						["options"] = table_clone(offense_tier_options),
					},
					{	["setting_id"] = "categorize_total_ranged",
						["type"] = "dropdown",
						["default_value"] = "offense_tier_1",
						["options"] = table_clone(offense_tier_options),
					},
					{	["setting_id"] = "categorize_total_blitz",
						["type"] = "dropdown",
						["default_value"] = "offense_tier_1",
						["options"] = table_clone(offense_tier_options),
					},
					{	["setting_id"] = "categorize_total_companion",
						["type"] = "dropdown",
						["default_value"] = "offense_tier_1",
						["options"] = table_clone(offense_tier_options),
					},
				},
			},
			{	setting_id 		= "exploration_tracking_group",
				type 			= "group",
				sub_widgets		= {
					{	setting_id 		= "exploration_tracking_expeditions_pickups",
						type 			= "group",
						sub_widgets = {
							{	["setting_id"] 		= "exploration_track_currency",
								["type"] 			= "dropdown",
								["default_value"] 	= 0,
								["options"] 		= {
									{	["text"]	= "options_exploration_track_option_false",
										["value"]	= 0,
									},
									{	["text"]	= "options_exploration_track_option_alone",
										["value"]	= 1,
									},
									{	["text"]	= "options_exploration_track_option_materials",
										["value"]	= 2,
									},
								},
							},
							create_setting_toggle("exploration_show_currency_only_in_expeditions", false),
							{	["setting_id"] 		= "exploration_track_loot",
								["type"] 			= "dropdown",
								["default_value"] 	= 0,
								["options"] 		= {
									{	["text"]	= "options_exploration_track_option_false",
										["value"]	= 0,
									},
									{	["text"]	= "options_exploration_track_option_alone",
										["value"]	= 1,
									},
									{	["text"]	= "options_exploration_track_option_materials",
										["value"]	= 2,
									},
								},
							},
							create_setting_toggle("exploration_show_loot_only_in_expeditions", false),
							{	["setting_id"] 		= "exploration_player_loot_value",
								["type"] 			= "dropdown",
								["default_value"] 	= 0,
								["options"] 		= {
									{	["text"]	= "exploration_player_loot_value_none",
										["value"]	= 0,
									},
									{	["text"]	= "exploration_player_loot_value_disabler",
										["value"]	= 25,
									},
									{	["text"]	= "exploration_player_loot_value_boss",
										["value"]	= 100,
									},
								},
							},
						},
					},
				},
			},
			{	setting_id 		= "ammo_tracking_group",
				type 			= "group",
				sub_widgets		= {
					{	setting_id 		= "ammo_messages",
						type 			= "checkbox",
						default_value 	= true,
					},
					{	setting_id 		= "grenade_messages",
						type 			= "checkbox",
						default_value 	= true,
					},
					create_setting_with_havoc_toggle("track_ammo_crate_waste"),
					create_setting_with_havoc_toggle("track_ammo_crate_in_percentage"),
				},
			},
			{	setting_id 		= "attack_tracking_group",
				type 			= "group",
				sub_widgets		= {
					{	setting_id 		= "attack_tracking_separate_rows",
						type 			= "group",
						sub_widgets = {
							{	setting_id 		= "separate_companion_damage",
								type 			= "dropdown",
								default_value	= "companion",
								options = {
									-- reusing localizations
									{text = "row_melee_weakspot_rate", value = "melee", },
									{text = "row_ranged_weakspot_rate", value = "ranged", },
									{text = "row_blitz_weakspot_rate", value = "blitz", },
									-- custom local
									{text = "option_companion_companion", value = "companion", },
								},
								sub_widgets = {
									create_setting_toggle("enable_companion_blitz_warning", true),
									create_setting_toggle("separate_companion_damage_hide_regardless", false),
								}
							},
							{	setting_id 		= "track_blitz_damage",
								type 			= "checkbox",
								default_value	= false,
								sub_widgets = {
									create_setting_toggle("track_blitz_wr", false),
									create_setting_toggle("track_blitz_cr", false),
								}
							},
						}
					},
					{	setting_id 		= "attack_tracking_hitrate",
						type 			= "group",
						sub_widgets = {
							create_setting_toggle("explosions_affect_ranged_hitrate", true),
							create_setting_toggle("explosions_affect_melee_hitrate", true),
						}
					},
				},
			},
			{	setting_id 		= "defense_tracking_group",
				type 			= "group",
				sub_widgets		= {
					{	setting_id 		= "disabled_tracking_group",
						type 			= "group",
						sub_widgets		= optional_states_disabled_widgets,
					},
				},
			},
		}, -- closes all widgets
	}, -- closes all mod options
}

return data_and_widgets