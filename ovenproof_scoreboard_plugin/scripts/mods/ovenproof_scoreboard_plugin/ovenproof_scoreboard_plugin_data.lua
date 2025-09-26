local mod = get_mod("ovenproof_scoreboard_plugin")

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

-- Given a specific table to inject into
--local function insert_widget_table_to_subtable(widget_table, table_address)
--	table_address[#table_address + 1] = widget_table
--end

return {
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
					{	setting_id 		= "explosions_affect_ranged_hitrate",
						type 			= "checkbox",
						default_value 	= true,
					},
					{	setting_id 		= "explosions_affect_melee_hitrate",
						type 			= "checkbox",
						default_value 	= true,
					},
				},
			},
		}, -- closes all widgets
	}, -- closes all mod options
}