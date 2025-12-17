local mod = get_mod("ovenproof_scoreboard_plugin")

-- ###############################################################################################################
-- NOTES FOR TRANSLATIONS
-- ----------------------
-- IF ADDING A NEW LOCALIZATION LANGUAGE, CHECK HERE
-- ###############################################################################################################
local languages = {"en","ru","zh-cn","zh-tw","pt-br",}
-- ###############################################################################################################
-- If your language is already translated:
--      if you have time, please search through this page for "google translate" to correct those
--          I tried to label as many of those as I could, but I didn't pay attention until recently so I'm sure I missed some
--          if that's too tedious, please don't do it. i appreciate the help regardless!
--      for those with missing localizations that I noticed, I put a comment with a blank line for the languages
--          ex: `ru = "",` and `["zh-cn"] = "",
-- Thanks for the help! - Backup158
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
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    error_scoreboard_missing = {
        en = "Scoreboard required! This is an add-on plugin to it!",
		ru = "Требуется табло! Это плагин для него!",
        ["zh-cn"] = "需要记分牌！这是一个附加插件！",
        ["zh-tw"] = "需要記分板！這是它的一個附加插件！",
		["pt-br"] = "Scoreboard mod é necessário! Este é um plugin addon!",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn
    enable_debug_messages = {
        en = "Enable error messages",
		ru = "Включить сообщения об ошибках",
		["zh-cn"] = "启用错误消息",
        ["zh-tw"] = "啟用錯誤訊息",
        ["pt-br"] = "Ativar Mensagens de Erro",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn
    enable_debug_messages_description = {
        en = "Show messages in chat whenever an uncategorized damage type is used. Please report these!",
		ru = "Показывать сообщения в чате при использовании некатегоризированного типа повреждения. Пожалуйста, сообщайте о таких случаях!",
		["zh-cn"] = "当使用未分类的伤害类型时，请在聊天中显示消息。请举报这些情况！",
        ["zh-tw"] = "每當使用未分類的傷害類型時，請在聊天中顯示消息。請報告這些！",
        ["pt-br"] = "Exibir mensagens no chat quando um tipo de dano não categorizado for usado. Por favor, reporte esses casos!",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn
    row_categories_group = {
        en = "Scoreboard Row Categories",
		ru = "Категории строк табло",
		["zh-cn"] = "记分板行类别",
        ["zh-tw"] = "記分板行分類",
        ["pt-br"] = "Categorias de Linhas do scoreboard",
    },
    custom_row_categorization = {
        en = "Select Row Categorization",
		--ru = "",
		--["zh-cn"] = "",
        --["zh-tw"] = "",
        --["pt-br"] = "",
    },
    -- @backup158: I copied some values from the row_total areas. I left them commented out since I don't know if that's appropriate for this context
    categorize_total_melee = {
        en = "Categorize Total Melee",
		--ru = " Всего в Ближнем бою",
		--["zh-cn"] = "总近战",
        --["zh-tw"] = "總近戰",
        --["pt-br"] = " Total Melee",
    },
    categorize_total_ranged = {
        en = "Categorize Total Ranged",
		--ru = " Всего в Дальнем бою",
		--["zh-cn"] = "总远程",
        --["zh-tw"] = "總遠程",
        --["pt-br"] = " Total Distância",
    },
    categorize_total_companion = {
        en = "Categorize Total Companion",
		--ru = " Всего ",
		--["zh-cn"] = "完全伴侣",
        --["zh-tw"] = "完全伴侶",
        --["pt-br"] = " Total ",
    },
    categorize_total_blitz = {
        en = "Categorize Total Blitz",
		--ru = " Всего ",
		--["zh-cn"] = "总",
        --["zh-tw"] = "總閃擊",
        --["pt-br"] = " Total ",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    ammo_tracking_group = {
        en = "Ammo Tracking",
		ru = "Отслеживание боеприпасов",
        ["zh-cn"] = "弹药追踪",
        ["zh-tw"] = "彈藥追蹤",
		["pt-br"] = "Rastreamento de munição",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_ammo_crate_waste = {
        en = "Track Ammo Crate waste",
		ru = "Отходы ящиков с боеприпасами для треков",
        ["zh-cn"] = "弹药箱废弃物",
        ["zh-tw"] = "追蹤彈藥箱浪費",
		["pt-br"] = "Desperdício de caixa de munição",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_ammo_crate_in_percentage = {
        en = "Include Ammo Crates in total percentage of Ammo picked up",
		ru = "Включить ящики с боеприпасами в общий процент подобранных боеприпасов",
        ["zh-cn"] = "将弹药箱计入拾取弹药的总百分比中",
        ["zh-tw"] = "將彈藥箱納入撿取彈藥總百分比", 
		["pt-br"] = "Inclua as caixas de munição na porcentagem total de munição coletada",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    attack_tracking_group = {
        en = "Attack Report Tracking",
		ru = "Отслеживание отчетов об атаках",
        ["zh-cn"] = "攻击报告追踪",
        ["zh-tw"] = "攻擊報告追蹤",
		["pt-br"] = "Relatório de ataque",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    attack_tracking_separate_rows = {
        en = "Use Separate Rows",
		ru = "Использовать отдельные строки",
        ["zh-cn"] = "使用单独的行",
        ["zh-tw"] = "使用獨立行",
		["pt-br"] = "Use linhas separadas",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    attack_tracking_separate_rows_description = {
        en = "ROW VISIBILITY CHANGES WILL NOT TAKE EFFECT UNTIL THE MAP CHANGES (such as by going from Mourningstar to Psykhanium)\nCreates a separate row to track these values.",
		ru = "ИЗМЕНЕНИЯ ВИДИМОСТИ СТРОК НЕ ВСТУПЯТ В СИЛУ, ПОКА КАРТА НЕ ИЗМЕНИТСЯ (например, при переходе от Mourningstar к Psykhanium)\nСоздает отдельную строку для отслеживания этих значений",
        ["zh-cn"] = "行可见性更改只有在地图发生变化时才会生效（例如从哀星到灵能星）\n创建一个单独的行来跟踪这些值",
        ["zh-tw"] = "ROW VISIBILITY 的變更要在地圖更換後才會生效（例如，從Mourningstar到靈能室）\n此選項會建立一個獨立的列，用來追蹤相關的數值。",
		["pt-br"] = "A alteração na visibilidade dos separadores só terá efeito quando o mapa for alterado (por exemplo, ao passar de Mourningstar para Psykhanium).\nCria uma linha separada para rastrear esses valores",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    separate_companion_damage = {
        en = "Companion Damage",
		ru = "Использовать отдельные строки",
        ["zh-cn"] = "Сопутствующий ущерб",
        ["zh-tw"] = "機械戰犬傷害",
		["pt-br"] = "Dano do Companheiro",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    separate_companion_damage_description = {
        en = "Choose which row Companion Damage counts towards. \"Companion\" is its own row, which will be hidden if one of the other options is chosen.",
		ru = "Выберите, в какой строке учитывается урон от компаньонов. «Компаньон» — это отдельная строка, которая будет скрыта, если выбран один из других вариантов.",
        ["zh-cn"] = "选择伙伴伤害计入哪一行。“伙伴”单独占一行，如果选择其他选项，该行将被隐藏。",
        ["zh-tw"] = "選擇「機械戰犬傷害」要計入哪一個列。「機械戰犬」本身是一個獨立的列；若選擇其他選項，該列將會被隱藏。",
		["pt-br"] = "Escolha em qual linha o dano causado pelo companheiro será contabilizado. \"Companheiro\" é uma linha separada, que ficará oculta se uma das outras opções for selecionada.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    warning_companion_blitz = {
        en = "You have set Companion Damage to be tracked under Blitz Damage, but you have not enabled the Blitz Damage row. This means Companion Damage will not be visible! It will still count towards total damage.\nIf that is intentional, you can disable this warning in the Mod Options.",
		ru = "Вы включили отслеживание урона от напарников в разделе «Урон от напарников», но не включили строку «Урон от напарников». Это означает, что урон от напарников не будет отображаться! Он всё равно будет учитываться в общем уроне.\nЕсли это сделано намеренно, вы можете отключить это предупреждение в настройках мода.",
        ["zh-cn"] = "您已将同伴伤害设置为在闪电战伤害下追踪，但您尚未启用闪电战伤害行。这意味着同伴伤害将不可见！但它仍会计入总伤害。\n如果您有意如此，可以在模组选项中禁用此警告。",
        ["zh-tw"] = "您已將機械戰犬傷害設定為統計在爆發傷害（Blitz Damage）中，但您尚未啟用爆發傷害列。這表示機械戰犬傷害將無法顯示！但仍會計入總傷害。\n如果這是您預期的行為，您可以在模組選項中停用此警告。",
		["pt-br"] = "Você configurou o Dano de Companheiro para ser rastreado em Dano de Ataque Relâmpago, mas não habilitou a linha Dano de Ataque Relâmpago. Isso significa que o Dano de Companheiro não será visível! Ele ainda será contabilizado no dano total.\nSe isso for intencional, você pode desativar este aviso nas Opções do Mod.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    enable_companion_blitz_warning = {
        en = "Enable warning for untracked Companion Damage",
		ru = "Включить предупреждение о неотслеживаемом повреждении компаньона",
        ["zh-cn"] = "启用未追踪同伴伤害的警告",
        ["zh-tw"] = "啟用未追蹤機械戰犬傷害的警告",
		["pt-br"] = "Ativar aviso para danos não rastreados em companheiros.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    enable_companion_blitz_warning_description = {
        en = "Shows warning when counting Companion Damage as Blitz Damage if there is no row displayed for Blitz Damage.",
		ru = "Выводит предупреждение при подсчете урона от компаньонов как урона от блица, если для урона от блица не отображается строка.",
        ["zh-cn"] = "如果闪电战伤害没有显示行，则在将同伴伤害计入闪电战伤害时显示警告。",
        ["zh-tw"] = "當機械戰犬傷害被計為爆發傷害、但未顯示爆發傷害列時，顯示警告。",
		["pt-br"] = "Exibe um aviso ao contabilizar o dano de companheiro como dano de ataque relâmpago se não houver uma linha exibida para dano de Blitz.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    separate_companion_damage_hide_regardless = {
        en = "Always Hide Companion Damage Row",
		ru = "Всегда скрывать строку урона компаньона",
        ["zh-cn"] = "始终隐藏同伴伤害行",
        ["zh-tw"] = "永遠隱藏機械戰犬傷害列",
		["pt-br"] = "Sempre oculte a linha de dano do companheiro",
    },
    -- @backup158: idk if these localizations are accurate since I wasn't involved
    option_companion_companion = {
        en = "Companion", 
        ru = "компаньон", 
        ["zh-cn"] = "伴侣", 
        ["zh-tw"] = "機械戰犬", 
        ["pt-br"] = "Companheiro", 
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_blitz_damage = {
        en = "Blitz Damage",
		ru = "Урон от молниеносного удара", 
        ["zh-cn"] = "闪电战伤害",
        ["zh-tw"] = "閃擊傷害",
		["pt-br"] = "Dano Blitz",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_blitz_damage_description = {
        en = "If disabled, Blitz Damage counts as Ranged Damage.",
		ru = "Если отключено, урон от молниеносной атаки считается уроном от дальнего боя.", 
        ["zh-cn"] = "如果禁用，闪电伤害将计为远程伤害。",
        ["zh-tw"] = "若停用，閃擊傷害將被視為遠程傷害。",
		["pt-br"] = "Se desativado, o dano do Blitz conta como dano à distância.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_blitz_wr = {
        en = "Track Blitz Weakspot Rate",
		ru = "Уровень уязвимости Blitz", 
        ["zh-cn"] = "追踪闪电弱点攻击率",
        ["zh-tw"] = "追蹤閃擊弱點命中率",
		["pt-br"] = "Taxa de pontos fracos do Blitz",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_blitz_cr = {
        en = "Track Blitz Critical Strike Rate",
		ru = "Частота критических ударов Blitz", 
        ["zh-cn"] = "追踪闪电战暴击率",
        ["zh-tw"] = "追蹤閃擊暴擊率",
		["pt-br"] = "Taxa de acerto crítico do Blitz",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    attack_tracking_hitrate = {
        en = "Hitrate Calculations",
		ru = "Расчеты хитрейта", 
        ["zh-cn"] = "命中率计算",
        ["zh-tw"] = "命中率計算",
		["pt-br"] = "Cálculos de taxa de acerto",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    explosions_affect_ranged_hitrate = {
        en = "Explosions affect Ranged Hitrate",
		ru = "Взрывы влияют на эффективность дальнего боя", 
        ["zh-cn"] = "爆炸会影响远程命中率",
        ["zh-tw"] = "爆炸影響遠程命中率",
		["pt-br"] = "Explosões afetam a taxa de acerto à distância",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    explosions_affect_melee_hitrate = {
        en = "Explosions affect Melee Hitrate",
		ru = "Взрывы влияют на меткость в ближнем бою", 
        ["zh-cn"] = "爆炸会影响近战命中率",
        ["zh-tw"] = "爆炸影響近戰命中率",
		["pt-br"] = "Explosões afetam a taxa de acerto em combate corpo a corpo",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    defense_tracking_group = {
        en = "Defense Report Tracking",
		ru = "Отслеживание отчетов Министерства обороны", 
        ["zh-cn"] = "防御报告追踪",
        ["zh-tw"] = "防禦報告追蹤",
		["pt-br"] = "Acompanhamento de relatórios de defesa",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    disabled_tracking_group = {
        en = "Track Events as a Disabled State",
		ru = "Отслеживать события в состоянии «отключено»", 
        ["zh-cn"] = "禁用跟踪事件状态",
        ["zh-tw"] = "將事件視為癱瘓狀態",
		["pt-br"] = "Acompanhe eventos como um estado com deficiência",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    disabled_tracking_group_description = {
        en = "When enabled, entering the described state will count as getting Disabled",
		ru = "При включении переход в описанное состояние будет считаться отключением.", 
        ["zh-cn"] = "启用此功能后，进入所述状态将被视为已禁用。",
        ["zh-tw"] = "啟用後，進入描述的狀態將被視為遭受癱瘓。",
		["pt-br"] = "Quando ativado, entrar no estado descrito será considerado como ficar desativado.",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_catapulted = {
        en = "Catapulted by Knockback",
		ru = "Катапультировался отбрасыванием", 
        ["zh-cn"] = "被击退弹射",
        ["zh-tw"] = "被擊退彈飛",
		["pt-br"] = "Catapultado por Repulsão",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_mutant_charged = {
        en = "Charged by a Mutant",
		ru = "Нападение мутанта", 
        ["zh-cn"] = "被变种人攻击",
        ["zh-tw"] = "被變種衝撞",
		["pt-br"] = "Acusado por um mutante",
    },
    -- @backup158: sai google translated these languages: ru, zh-cn, pt-br
    track_warp_grabbed = {
        --en = "Grabbed by a Daemonhost",
        en = "Warp Grabbed",
		ru = "Варп захвачен", 
        ["zh-cn"] = "跃迁抓取",
        ["zh-tw"] = "惡魔抓取",
		["pt-br"] = "Agarrado pelo Warp",
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
    -- @backup158: I split these 2 messages up, as well as the localizations
    --   localizers please verify that I used the correct words
    -- @backup158: sai google translated these languages: ru
    ammo_messages = {
        en = "Messages - Ammo pickups",
		ru = "Сообщения - Подбор боеприпасов",
        ["zh-cn"] = "消息 - 弹药拾取",
        ["zh-tw"] = "訊息 - 彈藥拾取",
        ["pt-br"] = "Mensagens - Coleta de Munição",
    },
    grenade_messages = {
        en = "Messages - Grenade pickups",
		ru = "Сообщения - Подбор гранат",
        ["zh-cn"] = "消息 - 手雷拾取",
        ["zh-tw"] = "訊息 - 手雷拾取",
        ["pt-br"] = "Mensagens - Coleta de Granadas",
    },
    -- ----------------
    -- Reusable labels
    -- ----------------
    -- Settings
    -- @backup158: sai google translated these languages: ru, zh-cn, zh-tw, pt-br
    setting_only_in_havoc = {
        en = "Only when playing Havoc",
		ru = "Только при игре в Havoc",
        ["zh-cn"] = "只有在玩 Havoc 时才会出现",
        ["zh-tw"] = "只有在玩 Havoc 時才會出現",
        ["pt-br"] = "Somente ao jogar Havoc",
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
        -- ru = "",
        ["zh-cn"] = "手雷",
        ["zh-tw"] = "手雷",
        ["pt-br"] = "Granadas",
    },
    message_small_clip = {
        en = "ammo box",
        -- ru = "",
        ["zh-cn"] = "小弹药罐",
        ["zh-tw"] = "小彈藥罐",
        ["pt-br"] = "Caixa de Munição",
    },
    message_large_clip = {
        en = "ammo bag",
        -- ru = "",
        ["zh-cn"] = "大弹药包",
        ["zh-tw"] = "大彈藥包",
        ["pt-br"] = "Saco de Munição",
    },
    message_ammo_no_waste = {
		--en = " picked up %s ammo",
        en = " picked up an %s",
        -- ru = "",
        ["zh-cn"] = "拾取了%s",
        ["zh-tw"] = "拾取了 %s",
        ["pt-br"] = " coletou %s",
    },
    message_ammo_waste = {
		--en = " picked up %s ammo, wasted %s",
        en = " picked up an %s, wasted %s ammo",
        -- ru = "",
        ["zh-cn"] = "拾取了%s，浪费了%s弹药",
        ["zh-tw"] = "拾取了 %s，浪費了 %s 彈藥",
        ["pt-br"] = " coletou %s, desperdiçou %s munição",
    },
    message_ammo_crate = {
        en = " picked up %s ammo from an %s",
        -- ru = "",
        ["zh-cn"] = "拾取了%s弹药，来自%s",
        ["zh-tw"] = "拾取了 %s 彈藥，來自 %s",
        ["pt-br"] = " coletou %s munição de %s",
    },
    message_ammo_crate_waste = {
        en = " picked up %s ammo from an %s, wasting %s",
        -- ru = " ",
        -- ["zh-cn"] = "",
        -- ["zh-tw"] = "",
        -- ["pt-br"] = " ",
    },
    message_ammo_crate_text = {
        en = "ammo crate",
        -- ru = " ",
        ["zh-cn"] = "弹药箱",
        ["zh-tw"] = "彈藥箱",
        ["pt-br"] = "Caixa de Munição",
    },
    message_grenades_body = {
        en = " picked up %s",
        -- ru = " ",
        ["zh-cn"] = "拾取了%s",
        ["zh-tw"] = "拾取了 %s",
        ["pt-br"] = " coletou %s",
    },
    message_grenades_text = {
        en = "grenades",
        -- ru = " ",
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
        -- ru = " ",
        ["zh-cn"] = {left = "总弹药", right = "[ 拾取 | 浪费 ]",},
        ["zh-tw"] = {left = "總彈藥", right = "[ 拾取 | 浪費 ]",},
        ["pt-br"] = {left = "Total Munição", right = "[Coletada | Desperdiçada]",},
    },
    row_ammo_percent = {
        en = "Taken",
        -- ru = " ",
        ["zh-cn"] = "拾取",
        ["zh-tw"] = "拾取",
        ["pt-br"] = "Coletada",
    },
    row_ammo_wasted = {
        en = "Wasted",
        -- ru = " ",
        ["zh-cn"] = "浪费",
        ["zh-tw"] = "浪費",
        ["pt-br"] = "Desperdiçada",
    },
    row_ammo_2 = {
        en = {left = "Total", right = "[ Grenades Taken | Crates Used ]",},
        -- ru = " ",
        ["zh-cn"] = {left = "总", right = "[ 手雷拾取 | 弹药箱使用 ]",},
        ["zh-tw"] = {left = "總", right = "[ 手雷拾取 | 彈藥箱使用 ]",},
        ["pt-br"] = {left = "Total", right = "[Granadas Coletada | Caixas Usadas]",},
    },
    row_ammo_grenades = {
        en = "Grenades Taken",
        -- ru = " ",
        ["zh-cn"] = "手雷拾取",
        ["zh-tw"] = "手雷拾取",
        ["pt-br"] = "Granadas Coletada",
    },
    row_ammo_crates = {
        en = "Crates Used",
        -- ru = " ",
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
        ["zh-tw"] = "閃擊",
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
        ["zh-tw"] = { left = "爆擊率", right = "[ 近戰  |  遠程  |  閃擊 ]",},
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
        ["zh-tw"] = "閃擊",
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
        ["zh-tw"] = { left = "總閃擊", right = right_hand_localizations.kill_damage["zh-tw"],},
        --["pt-br"] = {left = "Total", right = right_hand_localizations.kill_damage["pt-br"]},
    },
    -- @backup158: idk if these localizations are accurate since I wasn't involved
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

localization["option_offense_tier_0"] = localization["offense_tier_0"]
localization["option_offense_tier_1"] = localization["offense_tier_1"]
localization["option_offense_tier_2"] = localization["offense_tier_2"]
localization["option_offense_tier_3"] = localization["offense_tier_3"]

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