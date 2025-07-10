local mod = get_mod("ovenproof_scoreboard_plugin")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local ui_renderer_instance = Managers.ui:ui_constant_elements():ui_renderer()
local languages = {"en","ru","zh-cn"}

mod.get_text_size = function(self, input_text)

return UIRenderer.text_size(ui_renderer_instance, input_text, "proxima_nova_bold", 0.1)

end
local max_length = mod:get_text_size("AAAAAAAAAAAAAAAAAAAAAAAAAA  \u{200A}A")

mod.create_string = function(string_left, string_right)
local spacer_symbol = "\u{200A}"
local temp_string = ""
local padding_string = ""
local tab_string = ""
local total_length = 0

if mod:get_text_size(string_left.."\t "..string_right) < max_length then
	tab_string = "\t "
end

while total_length < max_length do
padding_string = padding_string..spacer_symbol
temp_string = string_left..tab_string..padding_string..string_right
total_length = mod:get_text_size(temp_string)
end

return string_left..tab_string..padding_string..string_right
end

local localization = {
-- Core
	mod_title = {
		en = "OvenProof's scoreboard",
		ru = "Таблица результатов - плагин OvenProof'а",
		["zh-cn"] = "OvenProof 的记分板",
	},
	mod_description = {
		en = "OvenProof's custom scoreboard",
		ru = "Ovenproof's Scoreboard Plugin - Плагин для Таблицы результатов с более подробными данными.",
		["zh-cn"] = "OvenProof 的自定义记分板",
	},
--Groups
	group_1 = {
		en = "Group 1",
		ru = "Группа 1",
		["zh-cn"] = "分组 1",
	},
	row_group_1_score = {
		en = "Score",
		ru = "Счёт",
		["zh-cn"] = "分数",
	},
--Settings
	exploration_tier_0 = {
		en = "Exploration",
		ru = "Исследование",
		["zh-cn"] = "探索",
	},
	defense_tier_0 = {
		en = "Defense",
		ru = "Защита",
		["zh-cn"] = "防御",
	},
	offense_rates = {
		en = "Weakspot and critical rates",
		ru = "Уязвимые места и критические показатели",
		["zh-cn"] = "弱点和暴击率",
	},
	offense_tier_0 = {
		en = "Offense (tier 0)",
		ru = "Нападение (ряд 0)",
		["zh-cn"] = "进攻（T0）",
	},
	offense_tier_1 = {
		en = "Offense (tier 1)",
		ru = "Нападение (ряд 1)",
		["zh-cn"] = "进攻（T1）",
	},
	offense_tier_2 = {
		en = "Offense (tier 2)",
		ru = "Нападение (ряд 2)",
		["zh-cn"] = "进攻（T2）",
	},
	offense_tier_3 = {
		en = "Offense (tier 3)",
		ru = "Нападение (ряд 3)",
		["zh-cn"] = "进攻（T3）",
	},
	fun_stuff_01 = {
		en = "Fun stuff",
		ru = "Интересные счётчики",
		["zh-cn"] = "娱乐数据",
	},
	bottom_padding = {
		en = "Bottom padding",
		ru = "Нижний отступ",
		["zh-cn"] = "底部间距",
	},
	ammo_messages = {
		en = "Messages - Ammo/grenade pickups",
		["zh-cn"] = "消息 - 弹药/手雷拾取",
	},
--Reusable labels
	row_kills = {
		en = "Kills",
		ru = "Убийств",
		["zh-cn"] = "击杀",
	},
	row_damage = {
		en = "Damage",
		ru = "Урона",
		["zh-cn"] = "伤害",
	},
--Ammo messages
	message_grenades = {
		en = "grenades",
		["zh-cn"] = "手雷"
	},
	message_small_clip = {
		en = "ammo box",
		["zh-cn"] = "小弹药罐"
	},
	message_large_clip = {
		en = "ammo bag",
		["zh-cn"] = "大弹药包"
	},
	message_ammo_no_waste = {
		--en = " picked up %s ammo",
		en = " picked up an %s",
		["zh-cn"] = "拾取了%s"
	},
	message_ammo_waste = {
		--en = " picked up %s ammo, wasted %s",
		en = " picked up an %s, wasted %s ammo",
		["zh-cn"] = "拾取了%s，浪费了%s弹药"
	},
	message_ammo_crate = {
		en = " picked up %s ammo from an %s",
		["zh-cn"] = "拾取了%s弹药，来自%s"
	},
	message_ammo_crate_text = {
		en = "ammo crate",
		["zh-cn"] = "弹药箱"
	},
	message_grenades_body = {
		en = " picked up %s",
		["zh-cn"] = "拾取了%s"
	},
	message_grenades_text = {
		en = "grenades",
		["zh-cn"] = "手雷"
	},
--Rows exploration_tier_0
	row_total_material_pickups = {
		en = "Total Material Pickups",
		ru = "Всего поднято Ресурсов",
		["zh-cn"] = "总材料拾取",
	},
	row_ammo_1 = {
		en = {left = "Total Ammo", right = "[ Taken | Wasted ]",},
		["zh-cn"] = {left = "总弹药", right = "[ 拾取 | 浪费 ]",},
	},
	row_ammo_percent = {
		en = "Taken",
		["zh-cn"] = "拾取"
	},
	row_ammo_wasted = {
		en = "Wasted",
		["zh-cn"] = "浪费"
	},
	row_ammo_2 = {
		en = {left = "Total", right = "[ Grenades Taken | Crates Used ]",},
		["zh-cn"] = {left = "总", right = "[ 手雷拾取 | 弹药箱使用 ]",},
	},
	row_ammo_grenades = {
		en = "Grenades Taken",
		["zh-cn"] = "手雷拾取"
	},
	row_ammo_crates = {
		en = "Crates Used",
		["zh-cn"] = "弹药箱使用"
	},
--Rows defense_tier_0
	row_total_health = {
		en = {left = "Total", right = "[ Damage Taken | HP Stations Used ]",},
		ru = {left = "Всего", right = "[Урона получено/Исп.медстанций]",},
		["zh-cn"] = {left = "总数", right = "[ 受到伤害 | 使用医疗站 ]",},
	},
	row_total_damage_taken = {
		en = "Damage Taken",
		ru = "Урона получено",
		["zh-cn"] = "受到伤害",
	},
	row_total_health_stations = {
		en = "HP Stations Used",
		ru = "Исп.медстанций",
		["zh-cn"] = "使用医疗站",
	},
	row_total_friendly = {
		en = {left = "Total Friendly", right = "[ Damage | Shots Blocked ]",},
		ru = {left = "Всего друж.", right = "[Урона/Выстрелов заблок.]",},
		["zh-cn"] = {left = "总友军", right = "[ 伤害 | 阻挡射击次数 ]",},
	},
	row_friendly_damage = {
		en = "Damage",
		ru = "Урона",
		["zh-cn"] = "伤害",
	},
	row_friendly_shots_blocked = {
		en = "Shots Blocked",
		ru = "Выстрелов заблок.",
		["zh-cn"] = "阻挡射击次数",
	},
	row_total_disabled_helped = {
		en = {left = "Total", right = "[ Times Disabled | Players Helped ]",},
		ru = {left = "Всего", right = "[Cхвачен врагами/Помог игрокам]",},
		["zh-cn"] = {left = "总", right = "[ 被控次数 | 帮助玩家数 ]",},
	},
	row_total_times_disabled = {
		en = "Times Disabled",
		ru = "Cхвачен врагами",
		["zh-cn"] = "被控次数",
	},
	row_total_operatives_helped = {
		en = "Players Helped",
		ru = "Помог игрокам",
		["zh-cn"] = "帮助玩家数",
	},
	row_total_downed_revived = {
		en = {left = "Total", right = "[ Times Downed | Players Revived ]",},
		ru = {left = "Всего", right = "[Сбит с ног/Поднял игроков]",},
		["zh-cn"] = {left = "总", right = "[ 倒地次数 | 复苏玩家数 ]",},
	},
	row_total_times_downed = {
		en = "Times Downed",
		ru = "Сбит с ног",
		["zh-cn"] = "倒地次数",
	},
	row_total_operatives_revived = {
		en = "Players Revived",
		ru = "Поднял игроков",
		["zh-cn"] = "复苏玩家数",
	},
	row_total_killed_rescued = {
		en = {left = "Total", right = "[ Times Killed | Players Rescued ]",},
		ru = {left = "Всего", right = "[Убит/Возродил игроков]",},
		["zh-cn"] = {left = "总", right = "[ 死亡次数 | 营救玩家数 ]",},
	},
	row_total_times_killed = {
		en = "Times Killed",
		ru = "Убит",
		["zh-cn"] = "死亡次数",
	},
	row_total_operatives_rescued = {
		en = "Players Rescued",
		ru = "Возродил игроков",
		["zh-cn"] = "营救玩家数",
	},
--Rows offense_rates
	row_total_weakspot_rates = {
		en = {left = "Weakspot Rate", right = "[ Melee | Ranged ]",},
		ru = {left = "Уязвимые места", right = "[Ближний/Дальний]",},
		["zh-cn"] = {left = "弱点命中率", right = "[ 近战 | 远程 ]",},
	},
	row_melee_weakspot_rate = {
		en = "Melee",
		ru = "Ближний",
		["zh-cn"] = "近战",
	},	
	row_ranged_weakspot_rate = {
		en = "Ranged",
		ru = "Дальний",
		["zh-cn"] = "远程",
	},
	row_total_critical_rates = {
		en = {left = "Critical Rate", right = "[ Melee | Ranged ]",},
		ru = {left = "Крит. удары", right = "[Ближний/Дальний]",},
		["zh-cn"] = {left = "暴击率", right = "[ 近战 | 远程 ]",},
	},	
	row_melee_critical_rate = {
		en = "Melee",
		ru = "Ближний",
		["zh-cn"] = "近战",
	},	
	row_ranged_critical_rate = {
		en = "Ranged",
		ru = "Дальний",
		["zh-cn"] = "远程",
	},	
	row_total_dot_rates_1 = {
		en = {left = "Critical Rate", right = "[ Bleeding | Burning ]",},
		ru = {left = "Крит. удары", right = "[Кровотечение/Горение]",},
		["zh-cn"] = {left = "暴击率", right = "[ 流血 | 燃烧 ]",},
	},	
	row_bleeding_critical_rate = {
		en = "Bleeding",
		ru = "Кровотечение",
		["zh-cn"] = "流血",
	},
	row_burning_critical_rate = {
		en = "Burning",
		ru = "Горение",
		["zh-cn"] = "燃烧",
	},
	row_total_dot_rates_2 = {
		en = {left = "Critical Rate", right = "[ Warpfire | Environment ]",},
		ru = {left = "Крит. удары", right = "[Варпогонь/Окружение]",},
		["zh-cn"] = {left = "暴击率", right = "[ 灵魂之火 | 环境 ]",},
	},
	row_warpfire_critical_rate = {
		en = "Warpfire",
		ru = "Варпогонь",
		["zh-cn"] = "灵魂之火",
	},
	row_environmental_critical_rate = {
		en = "Environment",
		ru = "Окружение",
		["zh-cn"] = "环境",
	},
--Rows offense_tier_0
	row_total = {
	en = {left = "Total", right = "[ Kills | Damage ]",},
	ru = {left = "Всего", right = "[Убийств/Урона]",},
	["zh-cn"] = {left = "总数", right = "[ 击杀 | 伤害 ]",},
	},
--Rows offense_tier_1
	row_total_melee = {
		en = {left = "Total Melee", right = "[ Kills | Damage ]",},
		ru = {left = "Всего в Ближнем бою", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总近战", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_ranged = {
		en = {left = "Total Ranged", right = "[ Kills | Damage ]",},
		ru = {left = "Всего в Дальнем бою", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总远程", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_bleeding = {
		en = {left = "Total Bleeding", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от Кровотечения", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总流血", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_burning = {
		en = {left = "Total Burning", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от Горения", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总燃烧", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_warpfire = {
		en = {left = "Total Warpfire", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от Варпогня", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总灵魂之火", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_shocking = {
		en = {left = "Total Shocking", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от Шокирующий", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "电力总计", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_companion = {
		en = {left = "Total Companion", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от компаньон", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "同伴总计", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_environmental = {
		en = {left = "Total Environmental", right = "[ Kills | Damage ]",},
		ru = {left = "Всего от Окружения", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总环境", right = "[ 击杀 | 伤害 ]",},
	},
--Rows offense_tier_2
	row_total_lesser = {
		en = {left = "Total Lesser", right = "[ Kills | Damage ]",},
		ru = {left = "Всего Слабые враги", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总普通敌人", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_elite = {
		en = {left = "Total Elite", right = "[ Kills | Damage ]",},
		ru = {left = "Всего Элитные враги", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总精英", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_special = {
		en = {left = "Total Special", right = "[ Kills | Damage ]",},
		ru = {left = "Всего Специалисты", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总专家", right = "[ 击杀 | 伤害 ]",},
	},
	row_total_boss = {
		en = {left = "Total Boss", right = "[ Kills | Damage ]",},
		ru = {left = "Всего Боссы", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "总 Boss", right = "[ 击杀 | 伤害 ]",},
	},
--Rows offense_tier_3
	row_melee_lesser = {
		en = {left = "Melee Lesser", right = "[ Kills | Damage ]",},
		ru = {left = "Слабые - Ближний бой", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "近战类普通敌人", right = "[ 击杀 | 伤害 ]",},
	},
	row_ranged_lesser = {
		en = {left = "Ranged Lesser", right = "[ Kills | Damage ]",},
		ru = {left = "Слабые - Дальний бой", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "远程类普通敌人", right = "[ 击杀 | 伤害 ]",},
	},
	row_melee_elite = {
		en = {left = "Melee Elite", right = "[ Kills | Damage ]",},
		ru = {left = "Элита - Ближний бой", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "近战类精英", right = "[ 击杀 | 伤害 ]",},
	},
	row_ranged_elite = {
		en = {left = "Ranged Elite", right = "[ Kills | Damage ]",},
		ru = {left = "Элита - Дальний бой", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "远程类精英", right = "[ 击杀 | 伤害 ]",},
	},
	row_damage_special = {
		en = {left = "DPS Special", right = "[ Kills | Damage ]",},
		ru = {left = "Специалисты-урон", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "输出型专家", right = "[ 击杀 | 伤害 ]",},
	},
	row_disabler_special = {
		en = {left = "Disabler Special", right = "[ Kills | Damage ]",},
		ru = {left = "Специалисты-хвататели", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "控制型专家", right = "[ 击杀 | 伤害 ]",},
	},
	row_boss = {
		en = {left = "Boss", right = "[ Kills | Damage ]",},
		ru = {left = "Боссы", right = "[Убийств/Урона]",},
		["zh-cn"] = {left = "Boss", right = "[ 击杀 | 伤害 ]",},
	},
--Rows fun_stuff_01
	row_one_shots = {
		en = "Number of one shots",
		ru = "Убийств одним ударом",
		["zh-cn"] = "秒杀次数",
	},	
	row_highest_single_hit = {
		en = "Highest single hit damage",
		ru = "Сильнейший одиночный удар",
		["zh-cn"] = "最高单次伤害",
	},
--Rows blank
	row_blank = {
		en = " ",
		ru = " ",
		["zh-cn"] = " ",
	},
}

for k_loc, v_loc in pairs(localization) do
	for k_lang, v_lang in pairs(languages) do
		if v_loc[v_lang] then
			if v_loc[v_lang].left and v_loc[v_lang].right then
				v_loc[v_lang] = mod.create_string(v_loc[v_lang].left, v_loc[v_lang].right)
			end
		end
	end
end

return localization