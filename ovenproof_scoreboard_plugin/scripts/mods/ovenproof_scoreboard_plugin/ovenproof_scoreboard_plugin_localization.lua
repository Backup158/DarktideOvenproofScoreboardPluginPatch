local mod = get_mod("ovenproof_scoreboard_plugin")

-- ###############################################################################################################
-- IF ADDING A NEW LOCALIZATION LANGUAGE, CHECK HERE
-- ###############################################################################################################
local languages = {"en","ru","zh-cn","zh-tw","pt-br",}
-- ###############################################################################################################

-- ########################
-- Data
-- ########################
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local ui_renderer_instance = Managers.ui:ui_constant_elements():ui_renderer()

-- ############
-- Performance
-- ############
local table = table
local table_clone = table.clone

-- ########################
-- Helper Functions
-- ########################
-- @backup158: I don't know why this needs the self reference nor why these are globals
--  but on the very off chance that some other mod uses these globals, I'll just make the local reference below 
mod.get_text_size = function(self, input_text)
    return UIRenderer.text_size(ui_renderer_instance, input_text, "proxima_nova_bold", 0.1)
end
local get_text_size = mod.get_text_size
local max_length = get_text_size(self, "AAAAAAAAAAAAAAAAAAAAAAAAAA  \u{200A}A")

mod.create_string = function(string_left, string_right)
    local spacer_symbol = "\u{200A}"
    local temp_string = ""
    local padding_string = ""
    local tab_string = ""
    local total_length = 0

    if get_text_size(self, string_left.."\t "..string_right) < max_length then
        tab_string = "\t "
    end

    while total_length < max_length do
        padding_string = padding_string..spacer_symbol
        temp_string = string_left..tab_string..padding_string..string_right
        total_length = get_text_size(self, temp_string)
    end

    return string_left..tab_string..padding_string..string_right
end
local create_string = mod.create_string

-- ########################
-- Localizations
-- ########################
local right_hand_localizations = {
    kill_damage = {
        en = "[ Kills | Damage ]",
        ru = "[Убийств/Урона]",
        ["zh-cn"] = "[ 击杀 | 伤害 ]",
        ["zh-tw"] = "[ 擊殺 | 傷害 ]",
        ["pt-br"] = "[Abates | Dano]",
    },
}
local localization = {
    -- ----------------
    -- Core
    -- ----------------
    mod_title = {
        en = "OvenProof's Scoreboard",
        ru = "Таблица результатов - плагин OvenProof'а",
        ["zh-cn"] = "OvenProof 的记分板",
        ["zh-tw"] = "OvenProof 的記分板",
        ["pt-br"] = "scoreboard do OvenProof",
    },
    mod_description = {
        en = "OvenProof's custom scoreboard",
        ru = "Ovenproof's Scoreboard Plugin - Плагин для Таблицы результатов с более подробными данными.",
        ["zh-cn"] = "OvenProof 的自定义记分板",
        ["zh-tw"] = "OvenProof 的自訂記分板",
        ["pt-br"] = "scoreboard Personalizado do OvenProof",
    },
    -- ----------------
    -- Groups
    -- ----------------
    group_1 = {
        en = "Group 1",
        ru = "Группа 1",
        ["zh-cn"] = "分组 1",
        ["zh-tw"] = "分組 1",
        ["pt-br"] = "Grupo 1",
    },
    row_group_1_score = {
        en = "Score",
        ru = "Счёт",
        ["zh-cn"] = "分数",
        ["zh-tw"] = "分數",
        ["pt-br"] = "Pontuação",
    },
    -- ----------------
    -- Settings
    -- ----------------
    error_scoreboard_missing = {
        en = "Scoreboard required! This is an add-on plugin to it!",
    },
    enable_debug_messages = {
        en = "Enable error messages",
        ["pt-br"] = "Ativar Mensagens de Erro",
    },
    enable_debug_messages_description = {
        en = "Show messages in chat whenever an uncategorized damage type is used. Please report these!",
        ["pt-br"] = "Exibir mensagens no chat quando um tipo de dano não categorizado for usado. Por favor, reporte esses casos!",
    },
    row_categories_group = {
        en = "Scoreboard Row Categories",
        ["pt-br"] = "Categorias de Linhas do scoreboard",
    },
    ammo_tracking_group = {
        en = "Ammo Tracking",
    },
    track_ammo_crate_waste = {
        en = "Track Ammo Crate waste",
    },
    track_ammo_crate_waste = {
        en = "Track Ammo Crate waste",
    },
    track_ammo_crate_in_percentage = {
        en = "Include Ammo Crates in total percentage of Ammo picked up",
    },
    attack_tracking_group = {
        en = "Attack Report Tracking",
    },
    attack_tracking_separate_rows = {
        en = "Use Separate Rows",
    },
    attack_tracking_separate_rows_description = {
        en = "ROW VISIBILITY CHANGES WILL NOT TAKE EFFECT UNTIL THE MAP CHANGES (such as by going from Mourningstar to Psykhanium)\nCreates a separate row to track these values.",
    },
    separate_companion_damage = {
        en = "Companion Damage",
    },
    separate_companion_damage_description = {
        en = "Choose which row Companion Damage counts towards. \"Companion\" is its own row, which will be hidden if one of the other options is chosen.",
    },
    warning_companion_blitz = {
        en = "You have set Companion Damage to be tracked under Blitz Damage, but you have not enabled the Blitz Damage row. This means Companion Damage will not be visible! It will still count towards total damage.\nIf that is intentional, you can disable this warning in the Mod Options.",
    },
    enable_companion_blitz_warning = {
        en = "Enable warning for untracked Companion Damage"
    },
    enable_companion_blitz_warning_description = {
        en = "Shows warning when counting Companion Damage as Blitz Damage if there is no row displayed for Blitz Damage."
    },
    separate_companion_damage_hide_regardless = {
        en = "Always Hide Companion Damage Row",
    },
    -- @backup158: idk if these localizations are accurate
    option_companion_companion = {
        en = "Companion", 
        ru = "компаньон", 
        ["zh-cn"] = "伴侣", 
        ["zh-tw"] = "伴侶", 
        ["pt-br"] = "Companheiro", 
    },
    track_blitz_damage = {
        en = "Blitz Damage",
    },
    track_blitz_damage_description = {
        en = "If disabled, Blitz Damage counts as Ranged Damage.",
    },
    track_blitz_wr = {
        en = "Track Blitz Weakspot Rate",
    },
    track_blitz_cr = {
        en = "Track Blitz Critical Strike Rate",
    },
    attack_tracking_hitrate = {
        en = "Hitrate Calculations",
    },
    explosions_affect_ranged_hitrate = {
        en = "Explosions affect Ranged Hitrate",
    },
    explosions_affect_melee_hitrate = {
        en = "Explosions affect Melee Hitrate",
    },
    defense_tracking_group = {
        en = "Defense Report Tracking",
    },
    disabled_tracking_group = {
        en = "Track Events as a Disabled State",
    },
    disabled_tracking_group_description = {
        en = "When enabled, entering the described state will count as getting Disabled",
    },
    track_catapulted = {
        en = "Catapulted by Knockback",
    },
    track_mutant_charged = {
        en = "Charged by a Mutant",
    },
    track_warp_grabbed = {
        --en = "Grabbed by a Daemonhost",
        en = "Warp Grabbed",
    },
    exploration_tier_0 = {
        en = "Exploration",
        ru = "Исследование",
        ["zh-cn"] = "探索",
        ["zh-tw"] = "探索",
        ["pt-br"] = "Exploração",
    },
    defense_tier_0 = {
        en = "Defense",
        ru = "Защита",
        ["zh-cn"] = "防御",
        ["zh-tw"] = "防禦",
        ["pt-br"] = "Defesa",
    },
    offense_rates = {
        en = "Weakspot and critical rates",
        ru = "Уязвимые места и критические показатели",
        ["zh-cn"] = "弱点和暴击率",
        ["zh-tw"] = "弱點與爆擊率",
        ["pt-br"] = "Taxas de Pontos Fracos e Críticos",
    },
    offense_tier_0 = {
        en = "Offense (Tier 0)",
        ru = "Нападение (ряд 0)",
        ["zh-cn"] = "进攻（T0）",
        ["zh-tw"] = "進攻 (T0)",
        ["pt-br"] = "Ofensiva (Nível 0)",
    },
    offense_tier_1 = {
        en = "Offense (Tier 1)",
        ru = "Нападение (ряд 1)",
        ["zh-cn"] = "进攻（T1）",
        ["zh-tw"] = "進攻 (T1)",
        ["pt-br"] = "Ofensiva (Nível 1)",
    },
    offense_tier_2 = {
        en = "Offense (Tier 2)",
        ru = "Нападение (ряд 2)",
        ["zh-cn"] = "进攻（T2）",
        ["zh-tw"] = "進攻 (T2)",
        ["pt-br"] = "Ofensiva (Nível 2)",
    },
    offense_tier_3 = {
        en = "Offense (Tier 3)",
        ru = "Нападение (ряд 3)",
        ["zh-cn"] = "进攻（T3）",
        ["zh-tw"] = "進攻 (T3)",
        ["pt-br"] = "Ofensiva (Nível 3)",
    },
    fun_stuff_01 = {
        en = "Fun stuff",
        ru = "Интересные счётчики",
        ["zh-cn"] = "娱乐数据",
        ["zh-tw"] = "趣味數據",
        ["pt-br"] = "Estatísticas Divertidas",
    },
    bottom_padding = {
        en = "Bottom padding",
        ru = "Нижний отступ",
        ["zh-cn"] = "底部间距",
        ["zh-tw"] = "底部邊距",
        ["pt-br"] = "Margem Inferior",
    },
    ammo_messages = {
        en = "Messages - Ammo/grenade pickups",
        ["zh-cn"] = "消息 - 弹药/手雷拾取",
        ["zh-tw"] = "訊息 - 彈藥/手雷拾取",
        ["pt-br"] = "Mensagens - Coleta de Munição/Granadas",
    },
    -- ----------------
    -- Reusable labels
    -- ----------------
    -- Settings
    setting_only_in_havoc = {
        en = "Only when playing Havoc",
    },
    -- Scoreboard Row Text
    row_kills = {
        en = "Kills",
        ru = "Убийств",
        ["zh-cn"] = "击杀",
        ["zh-tw"] = "擊殺",
        ["pt-br"] = "Abates",
    },
    row_damage = {
        en = "Damage",
        ru = "Урона",
        ["zh-cn"] = "伤害",
        ["zh-tw"] = "傷害",
        ["pt-br"] = "Dano",
    },
    -- Ammo messages
    message_grenades = {
        en = "grenades",
        ["zh-cn"] = "手雷",
        ["zh-tw"] = "手雷",
        ["pt-br"] = "Granadas",
    },
    message_small_clip = {
        en = "ammo box",
        ["zh-cn"] = "小弹药罐",
        ["zh-tw"] = "小彈藥罐",
        ["pt-br"] = "Caixa de Munição",
    },
    message_large_clip = {
        en = "ammo bag",
        ["zh-cn"] = "大弹药包",
        ["zh-tw"] = "大彈藥包",
        ["pt-br"] = "Saco de Munição",
    },
    message_ammo_no_waste = {
		--en = " picked up %s ammo",
        en = " picked up an %s",
        ["zh-cn"] = "拾取了%s",
        ["zh-tw"] = "拾取了 %s",
        ["pt-br"] = " coletou %s",
    },
    message_ammo_waste = {
		--en = " picked up %s ammo, wasted %s",
        en = " picked up an %s, wasted %s ammo",
        ["zh-cn"] = "拾取了%s，浪费了%s弹药",
        ["zh-tw"] = "拾取了 %s，浪費了 %s 彈藥",
        ["pt-br"] = " coletou %s, desperdiçou %s munição",
    },
    message_ammo_crate = {
        en = " picked up %s ammo from an %s",
        ["zh-cn"] = "拾取了%s弹药，来自%s",
        ["zh-tw"] = "拾取了 %s 彈藥，來自 %s",
        ["pt-br"] = " coletou %s munição de %s",
    },
    message_ammo_crate_waste = {
        en = " picked up %s ammo from an %s, wasting %s",
    },
    message_ammo_crate_text = {
        en = "ammo crate",
        ["zh-cn"] = "弹药箱",
        ["zh-tw"] = "彈藥箱",
        ["pt-br"] = "Caixa de Munição",
    },
    message_grenades_body = {
        en = " picked up %s",
        ["zh-cn"] = "拾取了%s",
        ["zh-tw"] = "拾取了 %s",
        ["pt-br"] = " coletou %s",
    },
    message_grenades_text = {
        en = "grenades",
        ["zh-cn"] = "手雷",
        ["zh-tw"] = "手雷",
        ["pt-br"] = "Granadas",
    },
    -- ----------------
    -- Rows: exploration_tier_0
    -- ----------------
    row_total_material_pickups = {
        en = "Total Material Pickups",
        ru = "Всего поднято Ресурсов",
        ["zh-cn"] = "总材料拾取",
        ["zh-tw"] = "總材料拾取",
        ["pt-br"] = "Total de Materiais Coletados",
    },
    row_ammo_1 = {
        en = {left = "Total Ammo", right = "[ Taken | Wasted ]",},
        ["zh-cn"] = {left = "总弹药", right = "[ 拾取 | 浪费 ]",},
        ["zh-tw"] = {left = "總彈藥", right = "[ 拾取 | 浪費 ]",},
        ["pt-br"] = {left = "Total Munição", right = "[Coletada | Desperdiçada]",},
    },
    row_ammo_percent = {
        en = "Taken",
        ["zh-cn"] = "拾取",
        ["zh-tw"] = "拾取",
        ["pt-br"] = "Coletada",
    },
    row_ammo_wasted = {
        en = "Wasted",
        ["zh-cn"] = "浪费",
        ["zh-tw"] = "浪費",
        ["pt-br"] = "Desperdiçada",
    },
    row_ammo_2 = {
        en = {left = "Total", right = "[ Grenades Taken | Crates Used ]",},
        ["zh-cn"] = {left = "总", right = "[ 手雷拾取 | 弹药箱使用 ]",},
        ["zh-tw"] = {left = "總", right = "[ 手雷拾取 | 彈藥箱使用 ]",},
        ["pt-br"] = {left = "Total", right = "[Granadas Coletada | Caixas Usadas]",},
    },
    row_ammo_grenades = {
        en = "Grenades Taken",
        ["zh-cn"] = "手雷拾取",
        ["zh-tw"] = "手雷拾取",
        ["pt-br"] = "Granadas Coletada",
    },
    row_ammo_crates = {
        en = "Crates Used",
        ["zh-cn"] = "弹药箱使用",
        ["zh-tw"] = "彈藥箱使用",
        ["pt-br"] = "Caixas Usadas",
    },
    -- ----------------
    -- Rows: defense_tier_0
    -- ----------------
    row_total_health = {
        en = {left = "Total", right = "[ Damage Taken | HP Stations Used ]",},
        ru = {left = "Всего", right = "[Урона получено/Исп.медстанций]",},
        ["zh-cn"] = {left = "总数", right = "[ 受到伤害 | 使用医疗站 ]",},
        ["zh-tw"] = { left = "總數", right = "[ 受到傷害 | 使用醫療站 ]",},
        ["pt-br"] = {left = "Total", right = "[Dano Sofrido | Estações HP Usadas]",},
    },
    row_total_damage_taken = {
        en = "Damage Taken",
        ru = "Урона получено",
        ["zh-cn"] = "受到伤害",
        ["zh-tw"] = "受到傷害",
        ["pt-br"] = "Dano Sofrido",
    },
    row_total_health_stations = {
        en = "HP Stations Used",
        ru = "Исп.медстанций",
        ["zh-cn"] = "使用医疗站",
        ["zh-tw"] = "使用醫療站",
        ["pt-br"] = "Estações HP Usadas",
    },
    row_total_friendly = {
        en = {left = "Total Friendly", right = "[ Damage | Shots Blocked ]",},
        ru = {left = "Всего друж.", right = "[Урона/Выстрелов заблок.]",},
        ["zh-cn"] = {left = "总友军", right = "[ 伤害 | 阻挡射击次数 ]",},
        ["zh-tw"] = { left = "總友軍", right = "[ 傷害 | 阻擋射擊次數 ]",},
        ["pt-br"] = {left = "Total Aliados", right = "[Dano | Tiros Bloqueados]",},
    },
    row_friendly_damage = {
        en = "Damage",
        ru = "Урона",
        ["zh-cn"] = "伤害",
        ["zh-tw"] = "傷害",
        ["pt-br"] = "Dano",
    },
    row_friendly_shots_blocked = {
        en = "Shots Blocked",
        ru = "Выстрелов заблок.",
        ["zh-cn"] = "阻挡射击次数",
        ["zh-tw"] = "阻擋射擊次數",
        ["pt-br"] = "Tiros Bloqueados",
    },
    row_total_disabled_helped = {
        en = {left = "Total", right = "[ Times Disabled | Players Helped ]",},
        ru = {left = "Всего", right = "[Cхвачен врагами/Помог игрокам]",},
        ["zh-cn"] = {left = "总", right = "[ 被控次数 | 帮助玩家数 ]",},
        ["zh-tw"] = { left = "總", right = "[ 被控次數 | 幫助玩家數 ]",},
        ["pt-br"] = {left = "Total", right = "[Vezes Preso | Aliados Ajudados]",},
    },
    row_total_times_disabled = {
        en = "Times Disabled",
        ru = "Cхвачен врагами",
        ["zh-cn"] = "被控次数",
        ["zh-tw"] = "被控次數",
        ["pt-br"] = "Vezes Preso",
    },
    row_total_operatives_helped = {
        en = "Players Helped",
        ru = "Помог игрокам",
        ["zh-cn"] = "帮助玩家数",
        ["zh-tw"] = "幫助玩家數",
        ["pt-br"] = "Aliados Ajudados",
    },
    row_total_downed_revived = {
        en = {left = "Total", right = "[ Times Downed | Players Revived ]",},
        ru = {left = "Всего", right = "[Сбит с ног/Поднял игроков]",},
        ["zh-cn"] = {left = "总", right = "[ 倒地次数 | 复苏玩家数 ]",},
        ["zh-tw"] = { left = "總", right = "[ 倒地次數 | 復甦玩家數 ]",},
        ["pt-br"] = {left = "Total", right = "[Vezes Caído | Aliados Revividos]",},
    },
    row_total_times_downed = {
        en = "Times Downed",
        ru = "Сбит с ног",
        ["zh-cn"] = "倒地次数",
        ["zh-tw"] = "倒地次數",
        ["pt-br"] = "Vezes Caído",
    },
    row_total_operatives_revived = {
        en = "Players Revived",
        ru = "Поднял игроков",
        ["zh-cn"] = "复苏玩家数",
        ["zh-tw"] = "復甦玩家數",
        ["pt-br"] = "Aliados Revividos",
    },
    row_total_killed_rescued = {
        en = {left = "Total", right = "[ Times Killed | Players Rescued ]",},
        ru = {left = "Всего", right = "[Убит/Возродил игроков]",},
        ["zh-cn"] = {left = "总", right = "[ 死亡次数 | 营救玩家数 ]",},
        ["zh-tw"] = { left = "總", right = "[ 死亡次數 | 營救玩家數 ]",},
        ["pt-br"] = {left = "Total", right = "[Vezes Morto | Aliados Resgatados]",},
    },
    row_total_times_killed = {
        en = "Times Killed",
        ru = "Убит",
        ["zh-cn"] = "死亡次数",
        ["zh-tw"] = "死亡次數",
        ["pt-br"] = "Vezes Morto",
    },
    row_total_operatives_rescued = {
        en = "Players Rescued",
        ru = "Возродил игроков",
        ["zh-cn"] = "营救玩家数",
        ["zh-tw"] = "營救玩家數",
        ["pt-br"] = "Aliados Resgatados",
    },
    -- ----------------
    -- Rows: offense_rates
    -- ----------------
    row_total_weakspot_rates = {
        en = {left = "Weakspot Rate", right = "[ Melee | Ranged ]",},
        ru = {left = "Уязвимые места", right = "[Ближний/Дальний]",},
        ["zh-cn"] = {left = "弱点命中率", right = "[ 近战 | 远程 ]",},
        ["zh-tw"] = { left = "弱點命中率", right = "[ 近戰 | 遠程 ]",},
        ["pt-br"] = {left = "Ponto Fracos", right = "[Corpo a Corpo | Distância]",},
    },
    row_total_weakspot_rates_with_blitz = {
        en = {left = "Weakspot Rate", right = "[ Melee | Ranged | Blitz ]",},
        --ru = {left = "Уязвимые места", right = "[Ближний/Дальний/]",},
        --["zh-cn"] = {left = "弱点命中率", right = "[ 近战 | 远程 | ]",},
        --["zh-tw"] = { left = "弱點命中率", right = "[ 近戰 | 遠程 | ]",},
        --["pt-br"] = {left = "Ponto Fracos", right = "[Corpo a Corpo | Distância | ]",},
    },
    row_melee_weakspot_rate = {
        en = "Melee",
        ru = "Ближний",
        ["zh-cn"] = "近战",
        ["zh-tw"] = "近戰",
        ["pt-br"] = "Corpo a Corpo",
    },
    row_ranged_weakspot_rate = {
        en = "Ranged",
        ru = "Дальний",
        ["zh-cn"] = "远程",
        ["zh-tw"] = "遠程",
        ["pt-br"] = "Distância",
    },
    row_blitz_weakspot_rate = {
        en = "Blitz",
        --ru = "",
        --["zh-cn"] = "",
        --["zh-tw"] = "",
        --["pt-br"] = "",
    },
    --[[
    row_companion_weakspot_rate = {
        en = "Companion",
    },
    ]]
    row_total_critical_rates = {
        en = {left = "Critical Rate", right = "[ Melee | Ranged ]",},
        ru = {left = "Крит. удары", right = "[Ближний/Дальний]",},
        ["zh-cn"] = {left = "暴击率", right = "[ 近战 | 远程 ]",},
        ["zh-tw"] = { left = "爆擊率", right = "[ 近戰 | 遠程 ]",},
        ["pt-br"] = {left = "Taxa Crítica", right = "[Corpo a Corpo | Distância]",},
    },
    row_total_critical_rates_with_blitz = {
        en = {left = "Critical Rate", right = "[ Melee | Ranged | Blitz ]",},
        -- ru = {left = "Крит. удары", right = "[Ближний/Дальний/]",},
        -- ["zh-cn"] = {left = "暴击率", right = "[ 近战 | 远程 | ]",},
        -- ["zh-tw"] = { left = "爆擊率", right = "[ 近戰 | 遠程 | ]",},
        -- ["pt-br"] = {left = "Taxa Crítica", right = "[Corpo a Corpo | Distância | ]",},
    },
    row_melee_critical_rate = {
        en = "Melee",
        ru = "Ближний",
        ["zh-cn"] = "近战",
        ["zh-tw"] = "近戰",
        ["pt-br"] = "Corpo a Corpo",
    },
    row_ranged_critical_rate = {
        en = "Ranged",
        ru = "Дальний",
        ["zh-cn"] = "远程",
        ["zh-tw"] = "遠程",
        ["pt-br"] = "Distância",
    },
    row_blitz_critical_rate = {
        en = "Blitz",
        --ru = "",
        --["zh-cn"] = "",
        --["zh-tw"] = "",
        --["pt-br"] = "",
    },
    -- @backup158: do toxins even crit? i dont think i need to count this
    --  I'm pretty sure dogs don't crit so I skipped them
    row_total_dot_rates_1 = {
        en = {left = "Critical Rate", right = "[ Bleeding | Burning ]",},
        ru = {left = "Крит. удары", right = "[Кровотечение/Горение]",},
        ["zh-cn"] = {left = "暴击率", right = "[ 流血 | 燃烧 ]",},
        ["zh-tw"] = { left = "爆擊率", right = "[ 流血 | 燃燒 ]",},
        ["pt-br"] = {left = "Taxa Crítica", right = "[Sangramento | Queima]",},
    },
    row_bleeding_critical_rate = {
        en = "Bleeding",
        ru = "Кровотечение",
        ["zh-cn"] = "流血",
        ["zh-tw"] = "流血",
        ["pt-br"] = "Sangramento",
    },
    row_burning_critical_rate = {
        en = "Burning",
        ru = "Горение",
        ["zh-cn"] = "燃烧",
        ["zh-tw"] = "燃燒",
        ["pt-br"] = "Queima",
    },
    row_total_dot_rates_2 = {
        en = {left = "Critical Rate", right = "[ Warpfire | Environment ]",},
        ru = {left = "Крит. удары", right = "[Варпогонь/Окружение]",},
        ["zh-cn"] = {left = "暴击率", right = "[ 灵魂之火 | 环境 ]",},
        ["zh-tw"] = { left = "爆擊率", right = "[ 靈魂之火 | 環境 ]",},
        ["pt-br"] = {left = "Taxa Crítica", right = "[Warpfire | Ambiente]",},
    },
    row_warpfire_critical_rate = {
        en = "Warpfire",
        ru = "Варпогонь",
        ["zh-cn"] = "灵魂之火",
        ["zh-tw"] = "靈魂之火",
        ["pt-br"] = "Warpfire",
    },
    row_environmental_critical_rate = {
        en = "Environment",
        ru = "Окружение",
        ["zh-cn"] = "环境",
        ["zh-tw"] = "環境",
        ["pt-br"] = "Ambiente",
    },
    -- ----------------
    -- Rows: offense_tier_0
    -- ----------------
    row_total = {
        en = {left = "Total", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总数", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總數", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- ----------------
    -- Rows: offense_tier_1
    -- ----------------
    row_total_melee = {
        en = {left = "Total Melee", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего в Ближнем бою", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总近战", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總近戰", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Melee", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_ranged = {
        en = {left = "Total Ranged", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего в Дальнем бою", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总远程", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總遠程", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Distância", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_blitz = {
        en = {left = "Total Blitz", right = right_hand_localizations.kill_damage["en"],},
        --ru = {left = "Всего", right = right_hand_localizations.kill_damage["ru"],},
        --["zh-cn"] = {left = "总", right = right_hand_localizations.kill_damage["zh-cn"],},
        --["zh-tw"] = { left = "總", right = right_hand_localizations.kill_damage["zh-tw"],},
        --["pt-br"] = {left = "Total", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- @backup158: idk if these localizations are accurate
    row_total_companion = {
        en = {left = "Total Companion", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Полный компаньон", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "完全伴侣", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "完全伴侶", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Companheiro", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_bleeding = {
        en = {left = "Total Bleeding", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего от Кровотечения", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总流血", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總流血", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Sangramento", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_burning = {
        en = {left = "Total Burning", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего от Горения", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总燃烧", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總燃燒", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Queima", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_warpfire = {
        en = {left = "Total Warpfire", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего от Варпогня", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总灵魂之火", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總靈魂之火", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Warpfire", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- @backup158: localizers, please verify these. i copied them from dictionary translations lol
    row_total_toxin = {
        en = {left = "Total Toxin", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего от Токсин", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总毒素", right = right_hand_localizations.kill_damage["zh-cn"],},
        --["zh-tw"] = { left = "總燃燒", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Toxina", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_environmental = {
        en = {left = "Total Environmental", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего от Окружения", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总环境", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總環境", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Ambiental", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- ----------------
    -- Rows: offense_tier_2
    -- ----------------
    row_total_lesser = { 
        en = {left = "Total Lesser", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего Слабые враги", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总普通敌人", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總普通敵人", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Inimigos Normal", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_elite = {
        en = {left = "Total Elite", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего Элитные враги", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总精英", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總精英", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Elites", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_special = {
        en = {left = "Total Special", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего Специалисты", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总专家", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "總專家", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Especiais", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_total_boss = {
        en = {left = "Total Boss", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Всего Боссы", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "总 Boss", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "全部的 Boss", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Total Chefes", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- ----------------
    -- Rows: offense_tier_3
    -- ----------------
    row_melee_lesser = {
        en = {left = "Melee Lesser", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Слабые - Ближний бой", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "近战类普通敌人", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "近戰類普通敵人", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Inimigos Normal Melee", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_ranged_lesser = {
        en = {left = "Ranged Lesser", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Слабые - Дальний бой", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "远程类普通敌人", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "遠程類普通敵人", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Inimigos Normal Distância", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_melee_elite = {
        en = {left = "Melee Elite", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Элита - Ближний бой", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "近战类精英", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "近戰類精英", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Elites Melee", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_ranged_elite = {
        en = {left = "Ranged Elite", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Элита - Дальний бой", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "远程类精英", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "遠程類精英", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Elites Distância", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_damage_special = {
        en = {left = "DPS Special", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Специалисты-урон", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "输出型专家", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "輸出型專家", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "DPS Especiais", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_disabler_special = {
        en = {left = "Disabler Special", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Специалисты-хвататели", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "控制型专家", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "控制型專家", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Especiais Incapacitadores", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    row_boss = {
        en = {left = "Boss", right = right_hand_localizations.kill_damage["en"],},
        ru = {left = "Боссы", right = right_hand_localizations.kill_damage["ru"],},
        ["zh-cn"] = {left = "Boss", right = right_hand_localizations.kill_damage["zh-cn"],},
        ["zh-tw"] = { left = "Boss", right = right_hand_localizations.kill_damage["zh-tw"],},
        ["pt-br"] = {left = "Chefes", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- ----------------
    -- Rows: fun_stuff_01
    -- ----------------
    row_one_shots = {
        en = "Number of one shots",
        ru = "Убийств одним ударом",
        ["zh-cn"] = "秒杀次数",
        ["zh-tw"] = "秒殺次數",
        ["pt-br"] = "Número de Abates em Um Golpe",
    },
    row_highest_single_hit = {
        en = "Highest single hit damage",
        ru = "Сильнейший одиночный удар",
        ["zh-cn"] = "最高单次伤害",
        ["zh-tw"] = "最高單次傷害",
        ["pt-br"] = "Maior Dano de Um Único Golpe",
    },
    -- Rows: Blank
    --  @backup158: btw you don't need to add localizations to these. it defaults to english if you don't have one (and they're all the same so it's fine)
    row_blank = {
        en = " ",
        ru = " ",
        ["zh-cn"] = " ",
        ["zh-tw"] = " ",
		["pt-br"] = "",
    },
}

for k_loc, v_loc in pairs(localization) do
    for k_lang, v_lang in pairs(languages) do
        if v_loc[v_lang] then
            if v_loc[v_lang].left and v_loc[v_lang].right then
                v_loc[v_lang] = create_string(v_loc[v_lang].left, v_loc[v_lang].right)
            end
        end
    end
end

return localization