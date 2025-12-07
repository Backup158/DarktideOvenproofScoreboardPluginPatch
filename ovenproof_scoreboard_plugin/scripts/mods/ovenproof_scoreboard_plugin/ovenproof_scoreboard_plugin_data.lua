local mod = get_mod("ovenproof_scoreboard_plugin")

local data_tables = mod:io_dofile("ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/data_tables")

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

local localizations = {
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
			{	setting_id 		= "ammo_tracking_group",
				type 			= "group",
				sub_widgets		= {
					{	setting_id 		= "ammo_messages",
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
									{text = "option_companion_companion", value = "companion", },
									-- reusing localizations
									{text = "row_melee_weakspot_rate", value = "melee", },
									{text = "row_ranged_weakspot_rate", value = "ranged", },
									{text = "row_blitz_weakspot_rate", value = "blitz", },
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

return localizations