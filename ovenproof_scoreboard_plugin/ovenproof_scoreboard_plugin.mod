return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ovenproof_scoreboard_plugin` encountered an error loading the Darktide Mod Framework.")

		new_mod("ovenproof_scoreboard_plugin", {
			mod_script       = "ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/ovenproof_scoreboard_plugin",
			mod_data         = "ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/ovenproof_scoreboard_plugin_data",
			mod_localization = "ovenproof_scoreboard_plugin/scripts/mods/ovenproof_scoreboard_plugin/ovenproof_scoreboard_plugin_localization",
		})
	end,

	require = {
		"scoreboard"
	},
	version = "1.9.0",

	packages = {},
}
