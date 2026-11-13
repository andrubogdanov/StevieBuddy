--     Новогодний DOORS — только у тебя на экране (клиентский скрипт, игру не меняет).
--       - снег вокруг тебя
--       - мигающие гирлянды на каждой двери (провисают фестончиками)
--       - ёлочки в горшках: гирлянда спиралью и золотая звезда на макушке
--       - уютный свет: лёгкое свечение огоньков и чуть праздничнее цвета
--       - новогодняя шапочка на бадди
--       - ключ превращается в карамельную трость (и на полу, и в руке), в инвентаре — картинка трости;
--         ПКМ — покрутить и показать / подбросить (по очереди), открыл дверь — трость съедается с хрустом
--       - подарки под ёлками, иней на окнах (снег на мебели пока выключен)
--       - снеговики у ёлок, шоколадные монеты в фольге вместо золота,
--         праздничные свечи (красные/зелёные, остролист у подставки, бантик)
--       - хлопушка у каждой 10-й двери (конфетти, серпантин, хлопок), на 100-й — салют;
--         омела и снежинки-наклейки на дверях, гирлянда-бахрома под потолочными балками,
--         камины: чулки и искорки
--       - 50-я: Фигура в заставке тоже в новогоднем костюме
--       - пасхалка: 5 кликов по логотипу меню
--       - новогодний интерфейс: здоровье — карамельная трость со снегом, шапка Санты на щите,
--         слоты хотбара — ёлочные шарики на гирлянде; окна меню, инвентаря и магазина — золотая рамка,
--         снег, остролист и гирлянда, карточки предметов — как подарки
--       - книжные шкафы в новогодних цветах: без книг и паутины, на полках подарки, трости и шарики,
--         по верху гирлянда; гардеробы — гирлянда и подарки сверху
--       - новогодние обои: красно-зелёные ромбы с золотом и снежинками
--       - шапки Санты на монстрах (Rush, Ambush, Figure, Seek...), у Скрича — его родной цилиндр
--       - украшения из новогодней версии DOORS (festive_export.lua -> workspace/StevieBuddy/festive):
--         игрушки и макушки на ёлочках, настоящие лампочки на дверях, подарки, венки
--       - SCAN = true — для отладки сохраняет сканы (текстуры комнат, двери, ключ, хотбар, шкафы,
--         монстры) в workspace/StevieBuddy/*_scan.txt; по умолчанию выключено
--
--       - меню настроек: RightShift или круглая кнопка слева (снег, ветер, свечение, что украшать);
--         настройки сохраняются в workspace/StevieBuddy/newyear_settings.json
--
--     Можно запускать вместе с treat_buddy.lua. Повторный запуск выключает прошлую копию.

-- сборка: видно в окне «что нового» и в консоли — чтобы понять, что запущена свежая версия
local NEWYEAR_BUILD = "13.11 21:40"

local CONFIG = {
    SNOW = true,
    SNOW_RATE = 60,          -- снежинок в секунду
    SNOW_WIND = 1,           -- сила ветра (0 — падает отвесно, 10 — метель)
    SNOW_WIND_DIR = 30,      -- откуда дует, градусы (0..360)
    SNOW_GUSTS = true,       -- ветер порывами (то сильнее, то слабее)
    SNOW_SPEED = 1,          -- скорость падения (1 — как сейчас)
    SNOW_SIZE = 1,           -- размер снежинок (1 — как сейчас)
    MENU = true,             -- меню настроек: RightShift или круглая кнопка слева
    VISUALS = true,          -- вкладки «Погода и свет», «Следы», «Музыка» (визуалы из Salad, настройки — visuals_settings.json)
    MENU_KEY = "RightShift",
    CHANGELOG = true,         -- при запуске окно «что нового»
    MENU_OPEN_ON_START = true, -- при запуске меню само открывается (значок с логотипом -> окно)
    MENU_W = 680, MENU_H = 440, MENU_SCALE = 1, -- размер окна меню (уголок справа снизу тоже тянет)
    MENU_BG = "#0A0A0B", MENU_ACCENT = "#FFFFFF", MENU_TEXT = "#EEEEF0", -- цвета меню
    MENU_LOGO = "StevieBuddy/logo.png", -- картинка логотипа (если файла нет — буква S)
    GARLANDS = true,
    GARLAND_COLORS = {
        Color3.fromRGB(255, 60, 60),   -- красный
        Color3.fromRGB(60, 220, 90),   -- зелёный
        Color3.fromRGB(255, 200, 60),  -- золотой
        Color3.fromRGB(70, 150, 255),  -- синий
    },
    BLINK = 0.6,             -- секунд между переключениями гирлянды
    BULB_SIZE = 0.32,
    WIRE = true,             -- провод гирлянды (лампочки висят на нём)
    -- ёлочки: гирлянда спиралью и звезда на макушке
    TREES = true,
    TREE_NAMES = { Potted_Plant = true }, -- какие модели считать ёлочками
    TREE_TURNS = 4,          -- витков гирлянды
    TREE_BULBS = 44,         -- лампочек на ёлке
    TREE_BULB_SIZE = 0.2,
    TREE_STAR = true,
    GIFTS = 3,               -- подарков под каждой ёлкой (0 — без подарков)
    SNOWMEN = true,          -- снеговики у ёлок
    SNOWMAN_TREE_CHANCE = 0.4,  -- доля ёлок со снеговиком рядом
    CHOCO_COINS = true,      -- золото -> шоколадные монеты в фольге (забираешь золото — пропадают)
    FESTIVE_CANDLES = true,  -- свечи: красные/зелёные, с остролистом у подставки и бантиком
    TABLE_CLUTTER = true,    -- бумажки на столах — новогодние открытки, брусочки — подарки
    CHEST_GIFTS = true,      -- сундуки — большие подарки (крышка с бантиком открывается как раньше)
    POPPERS = true,          -- хлопушка у каждой POPPER_EVERY-й двери: хлопок, конфетти, серпантин
    POPPER_EVERY = 10,
    POPPER_VOLUME = 1,
    POPPER_CONFETTI = 40,    -- сколько конфетти
    POPPER_FINALE = true,    -- на 100-й двери ещё и салют
    MISTLETOE = true,        -- омела над частью дверей (со стороны, откуда подходишь)
    MISTLETOE_CHANCE = 0.3,
    DOOR_STICKERS = true,    -- бумажные снежинки-наклейки на створках дверей
    DOOR_STICKER_CHANCE = 0.5,
    FRINGE = true,           -- гирлянда-бахрома («сосульки» из огоньков) под потолочными балками
    FRINGE_STEP = 0.75,      -- расстояние между нитями (меньше — гуще)
    FRINGE_ROWS = 1,         -- рядов бахромы на одном карнизе (балки идут по 2-3 рядом)
    FRINGE_LENGTH = 1,       -- длина нитей (множитель)
    FRINGE_BRIGHTNESS = 1,   -- яркость огоньков бахромы (0 — погашена)
    FIREPLACES = true,       -- камины: чулки под полкой, искорки над огнём
    WINDOW_SNOW = true,      -- за окнами идёт снег
    RUSH_FESTIVE = true,     -- Раш голубой, и звенят бубенцы, когда он летит
    RUSH_BELLS_VOLUME = 1,
    AMBUSH_BELLS = true,     -- у Эмбуша тоже звенят бубенцы
    SCREECH_BELL = true,     -- Скрич выпрыгивает под звон колокольчика
    SCREECH_BELL_VOLUME = 1,
    CLOSET_LIGHTS = true,    -- гирлянда внутри шкафов: горит, когда ты в нём прячешься
    HALT_SNOW = true,        -- в коридоре Халта вместо голубых огоньков — снег
    DEATH_SCREEN = true,     -- экран смерти: новогодняя открытка — кто поймал и у какой двери
    -- 100-я комната (детали игры не удаляются, только прячутся — античит на ноуклип не сработает)
    MEAT_FESTIVE = true,     -- мясо Фигуры (FesteringMeat): на стене — венок, на полу — сугробик с шариками
    OIL_BARRELS = "tin",     -- бочки с маслом: "tin" — жестяные банки с бантом, "candy" — в полоску как леденец,
                             -- "gift" — подарки, "off" — как в игре
    CRATE_GIFTS = true,      -- деревянные ящики (WoodenCrate) -> подарки
    BREAKER_CANDY = true,    -- щитки, которые собираешь в 100-й, -> конфеты; на счётчике — конфета и полоска-трость
    CANDY_EAT = true,        -- подобрал конфету — съедаешь: фантик слетает, три укуса с хрустом
    UI_FESTIVE = true,       -- новогодний интерфейс DOORS (только у тебя на экране)
    UI_HEALTH = true,        -- здоровье — карамельная трость со снежной шапкой, шапка Санты на щите
    UI_HOTBAR = true,        -- слоты хотбара — ёлочные шарики на гирлянде
    UI_WINDOWS = true,       -- окна (меню, инвентарь, магазин, админ-панель): золотая рамка, снег, остролист, гирлянда,
                             -- карточки предметов — как подарки с лентой и бантиком
    SNOW_FURNITURE = false,  -- снег сверху на шкафах, комодах, столах (пока сырой — выключен)
    FROST_WINDOWS = true,    -- иней на окнах (стёкла белеют и мерцают)
    MONSTER_HATS = true,     -- шапки Санты на монстрах
    -- погоня Сика
    SEEK_OUTFIT = true,      -- Сик: шарф в красно-белую полоску и гирлянда по телу (шапка — MONSTER_HATS)
    SEEK_SNOW = true,        -- вместо чёрной жижи — снег: сугроб под Сиком, облачко и шлейф снежинок, снежные капли с потолка
    SEEK_CANDY_ARMS = true,  -- руки Сика из стен — в полоску, как леденцовая трость
    CANDY_STRIPES_FILE = "StevieBuddy/textures/candy_stripes.png",
    CHANDELIER_SPARKS = true, -- упала люстра в погоне — праздничные искры и конфетти
    -- обои: заменяем текстуру стен (ID из newyear_scan.txt) на свою картинку
    WALLPAPER = true,
    WALLPAPER_IDS = { "9754267662" },
    WALLPAPER_FILE = "StevieBuddy/textures/newyear_wallpaper.png",
    WALLPAPER_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/textures/newyear_wallpaper.png",
    WALLPAPER_SCALE = 1,     -- больше 1 — ромбы крупнее
    -- украшения из новогодней версии DOORS (файлы от festive_export.lua)
    FESTIVE_FOLDER = "StevieBuddy/festive",
    FESTIVE_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/festive/",
    TREE_STYLE = "ornaments", -- "ornaments" — игрушки из новогодней версии, "garland" — мои лампочки, "both" — всё
    GARLAND_STYLE = "real",  -- "real" — лампочки из новогодней версии, "balls" — мои шарики
    REAL_PRESENTS = true,    -- подарки из новогодней версии (false — мои коробки)
    WREATHS = true,          -- венок над каждой дверью
    WREATH_SCALE = 0.55,
    GARLAND_SIDE = "front",  -- "front" — гирлянда и венок только со стороны, откуда подходишь к двери,
                             -- "back" — только с другой стороны, "both" — с обеих
    TREE_RANDOM = true,      -- у каждой ёлки свои цвета игрушек (и иногда без одной из групп)
    GLOW_ORNAMENTS = true,   -- стеклянные игрушки на ёлках светятся и мягко мерцают
    SHELVES = true,          -- книжные шкафы: без книг и паутины, на полках подарки, трости, шарики
    WARDROBES = true,        -- гардеробы: гирлянда, венок на дверцах, подарки сверху
    HIDE_JUNK = true,        -- убрать мусор: разбросанные доски на полу (Boards) и паутину (Web)
    FALLING_SHELF = true,    -- падающий шкаф (BookshelfObstruction): гирлянда, подарки, мишура; упал — гирлянда бьётся
    FALLING_SHELF_VOLUME = 1, -- громкость звука разбитой гирлянды (звуки из игры: BulbBreak, BulbZap)
    CELLAR = true,           -- подвал: бочки (Cellar_Barrel) заменить на большие подарки
    TINSEL = true,           -- мишура (пушистые блестящие ленты)
    TINSEL_CHANDELIERS = true, -- на люстрах: фестоны по кругу и кисточки
    TINSEL_RAILINGS = true,  -- на перилах лестниц: обмотка спиралью вокруг верхней планки
    TINSEL_LAMPS = true,     -- на настенных лампах (LightStand): фестон под плафонами и кисточки по краям
    TREE_TINSEL = false,     -- на ёлочках в горшках: спиралью вокруг кроны (выключено — там уже игрушки)
    TINSEL_WIDTH = 0.75,     -- толщина мишуры (диаметр пушистой части)
    TINSEL_STYLE = "3d",     -- "3d" — настоящая, из блестящих ниточек; "beam" — плоский эффект-лента
    TINSEL_DENSITY = 42,     -- ниточек на 1 stud длины (меньше — легче для игры, больше — пушистее)
    TINSEL_FILE = "StevieBuddy/textures/tinsel.png",
    PAINTINGS = true,        -- часть картин на стенах заменить на новогодние (textures/paintings)
    PAINTING_CHANCE = 0.5,   -- доля заменённых картин: 0.5 — половина новогодние, половина родные из DOORS
    FURNITURE_PAINT = false, -- перекрасить шкафы и гардеробы в новогодние цвета (выключено — родные цвета)
    FURNITURE_GARLAND = true, -- гирлянда по верху шкафов и гардеробов
    FURNITURE_LIGHT_TILT = 35, -- на сколько градусов лампочки на мебели отклонены наружу (чтобы не уходили в шкаф)
    WARDROBE_WREATHS = false, -- маленькие венки на дверцах гардероба
    FURNITURE_COLORS = {
        body = Color3.fromRGB(238, 232, 220),  -- основное — кремово-белое
        trim = Color3.fromRGB(170, 28, 38),    -- рама, верх, дверцы — красное
        shelf = Color3.fromRGB(40, 110, 65),   -- полки — зелёные
        gold = Color3.fromRGB(215, 175, 70),   -- ручки и мелочи — золото
    },
    SCREECH_TOPHAT = true,   -- Скричу — родной цилиндр вместо шапки Санты
    GIFT_BOOKS = true,       -- 50-я: книги-подсказки -> подарки; в руках подарок открывается, внутри фигура и цифра
    GIFT_BOOK_SCALE = 0.55,  -- размер подарка на полке (1 = как обычный подарок, ~2 studs)
    FIGURE_ANIMS = true,     -- Фигуре — анимации из новогодней версии (только у тебя на экране)
    FIGURE_COSTUME = true,   -- Фигуре — новогодний костюм (рога, мех, мешки; нужен festive/FigureRig.json)
    GLOW = true,             -- свечение огоньков (Bloom) и праздничные цвета
    GLOW_STRENGTH = 0.6,     -- сила свечения
    WARM_COLORS = true,      -- чуть тёплые праздничные цвета
    BUDDY_HAT = true,        -- шапочка на бадди
    CANDY_KEY = true,        -- ключ -> карамельная трость
    CANDY_KEY_SCALE = 1,     -- размер трости относительно ключа
    CANE_ICON = true,        -- своя картинка трости в слоте инвентаря вместо ключа
    CANE_ICON_FILE = "StevieBuddy/textures/candy_key_icon.png",
    CANE_ANIMS = true,       -- ПКМ с тростью: покрутить / подбросить (по очереди)
    CANE_RMB_ORDER = { "spin", "toss" }, -- spin — покрутить и показать (как в Rivals), toss — подбросить
    -- рука при показе трости (градусы от игровой позы): RAISE — поднять, INWARD — к центру экрана,
    -- ELBOW — согнуть локоть (предплечье вертикально)
    CANE_SHOW_ARM = { RAISE = 5, INWARD = 20, ELBOW = 20, LEAN = 8 }, -- LEAN — наклон руки вправо при кручении (если уходит влево — поменяй знак)
    CANE_TOSS_HEIGHT = 2.2,  -- как высоко подбрасывать (studs)
    CANE_EAT = true,         -- открыл дверь — съел трость (вместо того чтобы вставлять в замок)
    -- рука «ко рту» (градусы от позы с предметом): RAISE — поднять вперёд-вверх,
    -- INWARD — к центру лица, ELBOW — согнуть локоть
    CANE_EAT_ARM = { RAISE = 15, INWARD = 30, ELBOW = 30 },
    CANE_SOUND_VOLUME = 0.6,
    CANE_MUTE_GAME = true,   -- глушить игровые звуки ключа (осмотр, замок), пока играет своя анимация
    ASSETS_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/", -- откуда докачать картинку и звуки
    SCAN = false,            -- файлы-сканы для отладки (*_scan.txt в workspace/StevieBuddy); обычно не нужны
    NOTIFY = true,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.__NewYearDoors then
    pcall(env.__NewYearDoors.Destroy)
end

local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local created = {} -- всё, что мы создали (удаляем при выключении)
local function track(inst)
    table.insert(created, inst)
    return inst
end

-- что включилось, а что упало — покажем на экране
local status = {}
local function report(name, ok, err)
    if ok then return end
    table.insert(status, name .. ": " .. tostring(err))
    warn("[NewYear] " .. name .. " не включилось: " .. tostring(err))
end
local doorCount, hatCount, treeCount, caneCount = 0, 0, 0, 0
local giftCount, snowCount, frostCount, monsterHatCount = 0, 0, 0, 0
local wallpaperCount = 0
local shelfCount, shelfHidden = 0, 0

local root = track(Instance.new("Folder"))
root.Name = "NewYearDecor"
root.Parent = workspace

local function decorPart(props)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Massless = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    for k, v in pairs(props) do p[k] = v end
    return p
end

---------------------------------------------------------------- модели из новогодней версии

-- festive_export.lua сохраняет модели в JSON: детали, где стоят (относительно модели), размер,
-- родной размер меша, цвет, материал, свет, частицы. Здесь собираем их обратно:
-- деталь = Part + SpecialMesh(FileMesh) с тем же мешем, масштаб = размер / родной размер меша.
local HttpService = game:GetService("HttpService")

-- Настройки из меню (workspace/StevieBuddy/newyear_settings.json) поверх CONFIG.
-- Что было в CONFIG до этого — запоминаем, чтобы кнопка «Сбросить» вернула как было.
local SETTINGS_FILE = "StevieBuddy/newyear_settings.json"
local CONFIG_DEFAULTS = {}
for k, v in pairs(CONFIG) do
    if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then CONFIG_DEFAULTS[k] = v end
end
pcall(function()
    if not (isfile and isfile(SETTINGS_FILE)) then return end
    local saved = HttpService:JSONDecode(readfile(SETTINGS_FILE))
    for k, v in pairs(saved) do
        if CONFIG_DEFAULTS[k] ~= nil and type(v) == type(CONFIG_DEFAULTS[k]) then CONFIG[k] = v end
    end
end)
local function saveSettings()
    local out = {}
    for k, def in pairs(CONFIG_DEFAULTS) do
        if CONFIG[k] ~= def then out[k] = CONFIG[k] end
    end
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        writefile(SETTINGS_FILE, HttpService:JSONEncode(out))
    end)
end
-- что меню может поменять сразу (задаются ниже в разделах снега и света)
local live = {}

local festiveCache = {}
local function loadFestive(name)
    if festiveCache[name] ~= nil then return festiveCache[name] or nil end
    local file = CONFIG.FESTIVE_FOLDER .. "/" .. name .. ".json"
    local text
    if isfile and readfile and isfile(file) then
        local ok, t = pcall(readfile, file)
        if ok then text = t end
    end
    if not text and CONFIG.FESTIVE_URL ~= "" then
        local ok, t = pcall(game.HttpGet, game, CONFIG.FESTIVE_URL .. name:gsub(" ", "%%20") .. ".json")
        if ok and type(t) == "string" and t:sub(1, 1) == "{" then
            text = t
            pcall(function()
                if makefolder and not isfolder(CONFIG.FESTIVE_FOLDER) then
                    if not isfolder("StevieBuddy") then makefolder("StevieBuddy") end
                    makefolder(CONFIG.FESTIVE_FOLDER)
                end
                writefile(file, t)
            end)
        end
    end
    local data
    if text then
        local ok, d = pcall(HttpService.JSONDecode, HttpService, text)
        if ok and type(d) == "table" and d.items then data = d end
    end
    festiveCache[name] = data or false
    if not data then warn("[NewYear] Нет модели " .. name .. " (" .. file .. ")") end
    return data
end

local function fCF(a) return CFrame.new(table.unpack(a)) end
local function fV3(a) return Vector3.new(a[1], a[2], a[3]) end
local function fC3(a) return Color3.new(a[1], a[2], a[3]) end
local function fMat(name)
    local ok, m = pcall(function() return Enum.Material[name] end)
    return ok and m or Enum.Material.SmoothPlastic
end
local function fEnum(enum, name, default)
    local ok, v = pcall(function() return enum[name] end)
    return ok and v or default
end
local function fNumSeq(a, scale)
    local kps = {}
    for _, k in ipairs(a) do
        table.insert(kps, NumberSequenceKeypoint.new(k[1], k[2] * (scale or 1), (k[3] or 0) * (scale or 1)))
    end
    return NumberSequence.new(kps)
end
local function fColSeq(a)
    local kps = {}
    for _, k in ipairs(a) do table.insert(kps, ColorSequenceKeypoint.new(k[1], Color3.new(k[2], k[3], k[4]))) end
    return ColorSequence.new(kps)
end
-- относительный CFrame с масштабом: позиция растягивается, поворот тот же
local function scaledCF(a, s)
    local cf = fCF(a)
    return CFrame.new(cf.Position * s) * (cf - cf.Position)
end

local function festiveItem(data, name)
    for _, e in ipairs(data.items) do
        if e.name == name and e.cf then return e end
    end
end

--  Собрать модель.
--     frame   — где стоит начало модели (её pivot) в мире
--     opts.scale  — масштаб (1 = как в игре)
--     opts.only   — { [имя детали] = true }: собрать только эти детали (и их свет/частицы)
--     opts.colors — { [имя детали] = Color3 }: перекрасить
--     opts.weld   — деталь, к которой приварить (для того, что двигается: монстры)
--     opts.lights, opts.particles — переносить ли свет и частицы (по умолчанию да)
--     Возвращает Model и { [имя детали] = Part }
local function spawnFestive(data, frame, opts)
    opts = opts or {}
    local s = opts.scale or 1
    local model = Instance.new("Model")
    model.Name = "NewYear_" .. tostring(data.name)
    local made, byName = {}, {}
    for _, e in ipairs(data.items) do
        local parentInst = e.parent and made[e.parent]
        if e.cf and (e.class == "MeshPart" or e.class == "Part" or e.class == "UnionOperation")
            and (e.transparency or 0) < 0.99 and (not opts.only or opts.only[e.name]) then
            local p = Instance.new("Part")
            p.Name = e.name
            p.Size = fV3(e.size) * s
            p.Color = (opts.colors and opts.colors[e.name]) or fC3(e.color)
            p.Material = (opts.materials and opts.materials[e.name]) or fMat(e.material)
            p.Transparency = e.transparency or 0
            p.Reflectance = (opts.reflectance and opts.reflectance[e.name]) or e.reflectance or 0
            p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
            p.CastShadow = false
            p.Massless = true
            p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
            if e.meshId and e.meshId ~= "" and e.meshSize then
                local m = Instance.new("SpecialMesh")
                m.MeshType = Enum.MeshType.FileMesh
                m.MeshId = e.meshId
                if e.textureId and e.textureId ~= "" then m.TextureId = e.textureId end
                local ms = fV3(e.meshSize)
                m.Scale = fV3(e.size) * s / Vector3.new(math.max(ms.X, 1e-3), math.max(ms.Y, 1e-3), math.max(ms.Z, 1e-3))
                m.Parent = p
            elseif e.shape then
                p.Shape = fEnum(Enum.PartType, e.shape, Enum.PartType.Block)
            end
            local world = frame * scaledCF(e.cf, s)
            p.CFrame = world
            if opts.weld then
                p.Anchored = false
                local w = Instance.new("Weld")
                w.Part0 = opts.weld
                w.Part1 = p
                w.C0 = opts.weld.CFrame:ToObjectSpace(world)
                w.Parent = p
            else
                p.Anchored = true
            end
            p.Parent = model
            made[e.i] = p
            byName[e.name] = byName[e.name] or p
        elseif parentInst and e.class == "Attachment" and e.cf then
            local a = Instance.new("Attachment")
            a.Name = e.name
            a.CFrame = scaledCF(e.cf, s)
            a.Parent = parentInst
            made[e.i] = a
        elseif parentInst and opts.lights ~= false
            and (e.class == "PointLight" or e.class == "SpotLight" or e.class == "SurfaceLight") then
            local l = Instance.new(e.class)
            l.Color = fC3(e.color)
            l.Brightness = e.brightness or 1
            l.Range = (e.range or 8) * math.max(s, 0.5)
            l.Shadows = false
            if e.angle then l.Angle = e.angle end
            if e.face and e.class ~= "PointLight" then l.Face = fEnum(Enum.NormalId, e.face, Enum.NormalId.Front) end
            l.Parent = parentInst
            made[e.i] = l
        elseif parentInst and opts.particles ~= false and e.class == "ParticleEmitter" and e.enabled ~= false then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = e.name
            pe.Texture = e.texture or ""
            pe.Rate = e.rate or 5
            pe.Lifetime = NumberRange.new(e.lifetime[1], e.lifetime[2])
            pe.Speed = NumberRange.new(e.speed[1] * s, e.speed[2] * s)
            pe.SpreadAngle = Vector2.new(e.spread[1], e.spread[2])
            pe.Size = fNumSeq(e.sizeSeq, s)
            pe.Transparency = fNumSeq(e.transparencySeq)
            pe.Color = fColSeq(e.colorSeq)
            pe.LightEmission = e.lightEmission or 0
            pe.LightInfluence = e.lightInfluence or 1
            pe.Acceleration = fV3(e.acceleration) * s
            pe.Drag = e.drag or 0
            pe.Rotation = NumberRange.new(e.rotation[1], e.rotation[2])
            pe.RotSpeed = NumberRange.new(e.rotSpeed[1], e.rotSpeed[2])
            pe.EmissionDirection = fEnum(Enum.NormalId, e.emissionDirection, Enum.NormalId.Top)
            pe.Orientation = fEnum(Enum.ParticleOrientation, e.orientation, Enum.ParticleOrientation.FacingCamera)
            pe.LockedToPart = e.lockedToPart or false
            pe.ZOffset = e.zOffset or 0
            pe.Parent = parentInst
            made[e.i] = pe
        end
    end
    return model, byName
end


---------------------------------------------------------------- снег

local okSnow, errSnow = pcall(function()
    -- невидимая плита над головой, из неё падают снежинки; ездит за камерой.
    -- Создаём всегда (выключенный снег просто не идёт) — так меню может включить его на ходу.
    local cloud = decorPart({
        Name = "SnowCloud", Size = Vector3.new(50, 1, 50), Transparency = 1,
    })
    cloud.Parent = root
    local snow = Instance.new("ParticleEmitter")
    snow.Name = "Snow"
    snow.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    snow.Color = ColorSequence.new(Color3.fromRGB(235, 245, 255))
    snow.LightEmission = 0.4
    snow.LightInfluence = 0.6
    snow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.15),
        NumberSequenceKeypoint.new(0.85, 0.2), NumberSequenceKeypoint.new(1, 1),
    })
    snow.EmissionDirection = Enum.NormalId.Bottom
    snow.SpreadAngle = Vector2.new(15, 15)
    snow.RotSpeed = NumberRange.new(-60, 60)
    snow.Rotation = NumberRange.new(0, 360)
    snow.Parent = cloud

    local windDir = Vector3.new(1, 0, 0.5).Unit
    function live.snow()
        local sp = math.max(CONFIG.SNOW_SPEED or 1, 0.1)
        local sz = math.max(CONFIG.SNOW_SIZE or 1, 0.1)
        snow.Enabled = CONFIG.SNOW
        snow.Rate = CONFIG.SNOW_RATE
        snow.Speed = NumberRange.new(2.5 * sp, 4 * sp)
        -- медленнее падает — дольше живёт, чтобы долетать до пола
        snow.Lifetime = NumberRange.new(5 / sp, 7 / sp)
        snow.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.12 * sz), NumberSequenceKeypoint.new(1, 0.08 * sz),
        })
        local a = math.rad(CONFIG.SNOW_WIND_DIR or 0)
        windDir = Vector3.new(math.cos(a), 0, math.sin(a))
        -- сильный ветер — облако шире, чтобы снег задувало в кадр со всех сторон
        local w = CONFIG.SNOW_WIND or 0
        cloud.Size = Vector3.new(50 + w * 6, 1, 50 + w * 6)
    end
    live.snow()

    local t0 = os.clock()
    connect(RunService.RenderStepped, function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local w = CONFIG.SNOW_WIND or 0
        if CONFIG.SNOW_GUSTS and w > 0 then
            local t = os.clock() - t0
            w = w * math.max(0.15, 1 + 0.45 * math.sin(t * 0.6) + 0.25 * math.sin(t * 1.7 + 1.3))
        end
        local push = windDir * (w * 0.8)
        -- ускорение действует сразу на все снежинки — порывы видно
        snow.Acceleration = push
        -- облако чуть против ветра: снег успевает долететь до тебя
        cloud.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 12, 0) - windDir * (CONFIG.SNOW_WIND or 0) * 2)
    end)
end)
report("Snow", okSnow, errSnow)

---------------------------------------------------------------- свет

local okGlow, errGlow = pcall(function()
    local bloom = track(Instance.new("BloomEffect"))
    bloom.Name = "NewYearBloom"
    bloom.Size = 24
    bloom.Threshold = 0.92
    bloom.Parent = Lighting

    local cc = track(Instance.new("ColorCorrectionEffect"))
    cc.Name = "NewYearColor"
    cc.Saturation = 0.12
    cc.Contrast = 0.04
    cc.TintColor = Color3.fromRGB(255, 248, 244) -- чуть тёплый, как от гирлянд
    cc.Parent = Lighting

    function live.glow()
        bloom.Enabled = CONFIG.GLOW
        bloom.Intensity = CONFIG.GLOW_STRENGTH or 0.6
        cc.Enabled = CONFIG.GLOW and CONFIG.WARM_COLORS ~= false
    end
    live.glow()
end)
report("Glow", okGlow, errGlow)

---------------------------------------------------------------- гирлянды

local bulbs = {} -- { part, light?, index }
local brokenBulbs = setmetatable({}, { __mode = "k" }) -- разбитые лампочки: мигание их больше не трогает

-- папка с украшениями комнаты; комната ушла — папка удаляется
local roomFolders = {}
local function roomFolder(room)
    local f = roomFolders[room]
    if f and f.Parent then return f end
    f = Instance.new("Folder")
    f.Name = room.Name
    f.Parent = root
    roomFolders[room] = f
    connect(room.AncestryChanged, function()
        if not room:IsDescendantOf(workspace) then
            f:Destroy()
            roomFolders[room] = nil
        end
    end)
    return f
end

-- лампочка гирлянды (цвет и мигание задаёт общий цикл ниже)
local function addBulb(folder, cf, size, index, lightEvery, lightRange)
    local b = decorPart({
        Name = "Bulb", Shape = Enum.PartType.Ball,
        Size = Vector3.new(size, size, size),
        Material = Enum.Material.Neon,
        CFrame = cf,
    })
    local entry = { part = b, index = index }
    if lightEvery and index % lightEvery == 0 then
        local light = Instance.new("PointLight")
        light.Range = lightRange or 5
        light.Brightness = 0.7
        light.Shadows = false
        light.Parent = b
        entry.light = light
    end
    b.Parent = folder
    table.insert(bulbs, entry)
    return b
end

-- настоящая лампочка из новогодней версии: колпачок, плафон и светящаяся лампа.
-- wirePoint — точка на проводе, лампочка висит под ней. Цвет и мигание — общий цикл ниже.
local function addHolidayLight(folder, wirePoint, rot, index, lightEvery, outward)
    local data = loadFestive("HolidayLight")
    if not data then return false end
    -- outward — куда отклонить лампочку (висит на прищепке под углом, не касаясь мебели)
    local tilt = CFrame.identity
    if outward and outward.Magnitude > 1e-3 then
        local axis = (-Vector3.yAxis):Cross(outward.Unit)
        if axis.Magnitude > 1e-3 then
            tilt = CFrame.fromAxisAngle(axis.Unit, math.rad(CONFIG.FURNITURE_LIGHT_TILT or 35))
        end
    end
    local model, parts = spawnFestive(data, CFrame.new(wirePoint) * tilt * CFrame.new(0, -0.2, 0) * rot)
    model.Parent = folder
    if not parts.Neon then return true end
    local entry = { part = parts.Neon, casing = parts.Casing, index = index, real = true }
    if lightEvery and index % lightEvery == 0 then
        local light = Instance.new("PointLight")
        light.Range = 5
        light.Brightness = 0.8
        light.Shadows = false
        light.Parent = parts.Neon
        entry.light = light
    end
    table.insert(bulbs, entry)
    return true
end

-- провод гирлянды: тонкие трубочки от точки к точке
local WIRE_COLOR = Color3.fromRGB(28, 55, 32)
local REAL_WIRE_COLOR = Color3.fromRGB(27, 42, 53) -- как кабель гирлянд в новогодней версии
local function addWire(folder, points, thickness, color)
    if not CONFIG.WIRE then return end
    for k = 1, #points - 1 do
        local a, b = points[k], points[k + 1]
        local len = (b - a).Magnitude
        if len > 1e-3 then
            local p = decorPart({
                Name = "Wire", Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(len + thickness, thickness, thickness),
                Material = Enum.Material.SmoothPlastic, Color = color or WIRE_COLOR,
                -- ось цилиндра (X) направляем от a к b
                CFrame = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0),
            })
            p.Parent = folder
        end
    end
end

-- Размер двери только по видимым деталям: в модели двери есть невидимые
-- (хитбоксы и т.п.), из-за них гирлянда раньше уезжала в середину проёма
local function visibleBox(model)
    if not model:IsA("Model") then return model.CFrame, model.Size end
    local pivot = model:GetPivot()
    local rot = pivot - pivot.Position
    local minV, maxV
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.95 then
            local h = d.Size / 2
            for _, sx in ipairs({ -1, 1 }) do
                for _, sy in ipairs({ -1, 1 }) do
                    for _, sz in ipairs({ -1, 1 }) do
                        local l = rot:PointToObjectSpace(d.CFrame:PointToWorldSpace(
                            Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)))
                        minV = minV and minV:Min(l) or l
                        maxV = maxV and maxV:Max(l) or l
                    end
                end
            end
        end
    end
    if not minV then return model:GetBoundingBox() end
    return CFrame.new(rot:PointToWorldSpace((minV + maxV) / 2)) * rot, maxV - minV
end

-- один раз сохраняем, из чего сделана дверь (если гирлянда опять встанет криво — по файлу видно почему)
local doorDumped = false
local function dumpDoor(door)
    if not CONFIG.SCAN then return end
    if doorDumped then return end
    doorDumped = true
    local lines = { "Дверь: " .. door:GetFullName() }
    for _, d in ipairs(door:GetDescendants()) do
        local extra = d:IsA("BasePart") and ("  size=" .. tostring(d.Size) .. " transp=" .. d.Transparency) or ""
        table.insert(lines, d:GetFullName() .. " [" .. d.ClassName .. "]" .. extra)
    end
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        writefile("StevieBuddy/door_scan.txt", table.concat(lines, "\n"))
    end)
end

-- Гирлянда по рамке двери: сверху фестончиками, по бокам — до середины высоты.
-- Ставим с обеих сторон проёма. Одна гирлянда = один провод: левый бок снизу вверх,
-- верх слева направо, правый бок сверху вниз.
-- Двойная дверь (50-я, в библиотеку): украшения — ниже, после трости и подарков
local decorateDoubleDoor
-- Мишура по точкам (задаётся ниже, в разделе «мишура»)
local makeTinsel

local function decorateDoor(room, door)
    pcall(dumpDoor, door)
    -- Collision — невидимый блок ровно по проёму (5 x 8 x 1.25), не двигается, когда дверь открыта.
    -- Hidden (2 x 8 x 6) торчит вглубь — его не берём, из-за него гирлянда раньше вставала поперёк.
    local cf, size
    local collision = door:FindFirstChild("Collision")
    local leaf = door:FindFirstChild("Door")
    -- Двойная дверь: две створки «Door» и нет Collision. Проём — обе створки вместе.
    local leaves = {}
    for _, c in ipairs(door:GetChildren()) do
        if c.Name == "Door" and c:IsA("BasePart") then table.insert(leaves, c) end
    end
    local double = #leaves >= 2 and not (collision and collision:IsA("BasePart"))
    if double then
        local pivot = door:GetPivot()
        local mn = Vector3.new(math.huge, math.huge, math.huge)
        local mx = -mn
        for _, lf in ipairs(leaves) do
            local orig = lf:FindFirstChild("OriginalCFrameValue")
            local lcf = (orig and orig:IsA("CFrameValue")) and orig.Value or lf.CFrame
            for _, sx in ipairs({ -0.5, 0.5 }) do
                for _, sy in ipairs({ -0.5, 0.5 }) do
                    for _, sz in ipairs({ -0.5, 0.5 }) do
                        local pt = pivot:PointToObjectSpace(lcf:PointToWorldSpace(lf.Size * Vector3.new(sx, sy, sz)))
                        mn, mx = mn:Min(pt), mx:Max(pt)
                    end
                end
            end
        end
        cf, size = pivot * CFrame.new((mn + mx) / 2), mx - mn
    elseif collision and collision:IsA("BasePart") then
        cf, size = collision.CFrame, collision.Size
    elseif leaf and leaf:IsA("BasePart") then
        -- створка в закрытом положении (если дверь уже открыли)
        local orig = leaf:FindFirstChild("OriginalCFrameValue")
        cf, size = (orig and orig:IsA("CFrameValue")) and orig.Value or leaf.CFrame, leaf.Size
    else
        cf, size = visibleBox(door)
    end
    if not cf then return end

    -- ширина проёма — большая из X/Z, толщина — меньшая
    local width, depth, axisCF = size.X, size.Z, cf
    if size.Z > size.X then
        width, depth = size.Z, size.X
        axisCF = cf * CFrame.Angles(0, math.pi / 2, 0)
    end
    if width < 2 or size.Y < 3 then return end

    local folder = roomFolder(room)
    local real = CONFIG.GARLAND_STYLE == "real" and loadFestive("HolidayLight") ~= nil
    local step = real and 0.7 or 0.45 -- настоящие лампочки крупнее — реже
    local wireLift = CONFIG.BULB_SIZE * 0.45 -- провод чуть выше центра лампочки: она на нём висит
    local rot = axisCF - axisCF.Position
    local i = 0

    local half = width / 2 + 0.15
    local top = size.Y / 2 + 0.2

    -- С какой стороны двери вешать. Дверь комнаты — её выход: подходишь к ней изнутри комнаты,
    -- поэтому «перед» — сторона, где вход в комнату (RoomEntrance) или середина комнаты.
    local sides = { -1, 1 }
    if CONFIG.GARLAND_SIDE ~= "both" then
        local ref = room:FindFirstChild("RoomEntrance")
        local refPos = ref and ref:IsA("BasePart") and ref.Position or nil
        if not refPos and room:IsA("Model") then
            local ok, rcf = pcall(room.GetBoundingBox, room)
            if ok then refPos = rcf.Position end
        end
        if refPos then
            local z = axisCF:PointToObjectSpace(refPos).Z
            if math.abs(z) > 0.5 then
                local front = z > 0 and 1 or -1
                sides = { CONFIG.GARLAND_SIDE == "back" and -front or front }
            end
        end
    end

    for _, side in ipairs(sides) do
        local z = side * (depth / 2 + 0.2)
        local path = {} -- точки по порядку провода
        local m = math.max(4, math.floor((size.Y / 2) / step))
        -- левый бок снизу вверх
        for k = m, 1, -1 do
            table.insert(path, Vector3.new(-half, top - k * (size.Y / 2) / m, z))
        end
        -- верх: 3 фестона, провисают
        local n = math.max(real and 7 or 9, math.floor(width / step))
        for k = 0, n do
            local u = k / n
            local scallop = (u * (width > 7 and 4 or 3)) % 1
            local sag = 0.35 * math.sin(scallop * math.pi)
            table.insert(path, Vector3.new(-half + u * 2 * half, top - sag, z))
        end
        -- правый бок сверху вниз
        for k = 1, m do
            table.insert(path, Vector3.new(half, top - k * (size.Y / 2) / m, z))
        end

        local wire = {}
        for _, lp in ipairs(path) do
            i += 1
            local world = axisCF:PointToWorldSpace(lp)
            if real then
                addHolidayLight(folder, world, rot, i, 4)
                table.insert(wire, world)
            else
                addBulb(folder, CFrame.new(world), CONFIG.BULB_SIZE, i, 5, 5)
                table.insert(wire, world + Vector3.new(0, wireLift, 0))
            end
        end
        addWire(folder, wire, real and 0.07 or 0.05, real and REAL_WIRE_COLOR or nil)
    end

    -- двойная дверь: венки на створках, большие трости и подарки по бокам
    if double then
        local args = { folder, leaves, axisCF, Vector3.new(width, size.Y, depth), sides }
        task.defer(function()
            if decorateDoubleDoor then
                local ok, err = pcall(decorateDoubleDoor, table.unpack(args))
                if not ok then warn("[NewYear] Двойная дверь: " .. tostring(err)) end
            end
        end)
        return -- над такой дверью табличка с номером — общий венок сверху не вешаем
    end

    -- венок над дверью (с тех же сторон, что гирлянда)
    if CONFIG.WREATHS then
        local data = loadFestive("Wreath")
        if data then
            local ws = CONFIG.WREATH_SCALE
            local wsize = data.size and fV3(data.size) or Vector3.new(3.9, 4.1, 1.2)
            for _, side in ipairs(sides) do
                local frame = axisCF * CFrame.new(0, top + 0.25 + wsize.Y * ws / 2, side * (depth / 2 + 0.1 + wsize.Z * ws / 2))
                    * CFrame.Angles(0, side < 0 and math.pi or 0, 0)
                local model = spawnFestive(data, frame, { scale = ws })
                model.Parent = folder
            end
        end
    end
end

-- Ёлочка (Potted_Plant): гирлянда спиралью снизу вверх по кроне, сужается к макушке,
-- наверху золотая звезда
local GOLD = Color3.fromRGB(255, 205, 60)

-- Подарки под ёлкой: коробки с лентой крест-накрест и бантиком.
-- Ставим только туда, где рядом нет стены (проверяем лучом).
local GIFT_STYLES = {
    { box = Color3.fromRGB(200, 30, 40),  ribbon = Color3.fromRGB(255, 210, 70) },
    { box = Color3.fromRGB(30, 140, 70),  ribbon = Color3.fromRGB(240, 240, 240) },
    { box = Color3.fromRGB(40, 90, 200),  ribbon = Color3.fromRGB(255, 210, 70) },
    { box = Color3.fromRGB(245, 245, 240), ribbon = Color3.fromRGB(210, 30, 40) },
    { box = Color3.fromRGB(150, 50, 170), ribbon = Color3.fromRGB(240, 240, 240) },
}
local GIFT_SIZES = {
    Vector3.new(0.7, 0.55, 0.7), Vector3.new(0.5, 0.75, 0.5), Vector3.new(0.85, 0.45, 0.6),
}

local function addGift(folder, baseCF, size, style)
    local function part(props)
        local p = decorPart(props)
        p.Parent = folder
        return p
    end
    local cf = baseCF * CFrame.new(0, size.Y / 2, 0)
    part({ Name = "Gift", Size = size, Color = style.box, Material = Enum.Material.SmoothPlastic, CFrame = cf })
    local r = 0.09
    part({ Name = "Ribbon", Size = Vector3.new(size.X + 0.02, size.Y + 0.02, r),
        Color = style.ribbon, Material = Enum.Material.Fabric, CFrame = cf })
    part({ Name = "Ribbon", Size = Vector3.new(r, size.Y + 0.02, size.Z + 0.02),
        Color = style.ribbon, Material = Enum.Material.Fabric, CFrame = cf })
    -- бантик: две петли и узелок
    local topCF = cf * CFrame.new(0, size.Y / 2 + 0.05, 0)
    for _, sgn in ipairs({ -1, 1 }) do
        part({ Name = "Bow", Size = Vector3.new(0.2, 0.1, 0.07), Color = style.ribbon,
            Material = Enum.Material.Fabric,
            CFrame = topCF * CFrame.new(sgn * 0.09, 0.03, 0) * CFrame.Angles(0, 0, math.rad(sgn * 30)) })
    end
    part({ Name = "Bow", Size = Vector3.new(0.09, 0.09, 0.09), Color = style.ribbon,
        Material = Enum.Material.Fabric, CFrame = topCF })
end

local function addGifts(plant, folder)
    if (CONFIG.GIFTS or 0) <= 0 then return {} end
    local bcf, bsize = plant:GetBoundingBox()
    local pot = plant:FindFirstChild("Pot")
    local center = (pot and pot:IsA("BasePart")) and pot.Position or bcf.Position
    local potR = (pot and pot:IsA("BasePart")) and math.max(pot.Size.X, pot.Size.Z) / 2
        or math.min(bsize.X, bsize.Z) / 2

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { plant, root }
    -- пол под ёлкой
    local down = workspace:Raycast(center, Vector3.new(0, -12, 0), params)
    local floorY = down and down.Position.Y or (bcf.Position.Y - bsize.Y / 2)

    local placed, start = {}, math.random() * math.pi * 2
    for k = 0, 11 do
        if #placed >= CONFIG.GIFTS then break end
        local a = start + k * math.pi * 2 / 12
        local farEnough = true
        for _, other in ipairs(placed) do
            local diff = math.abs((a - other + math.pi) % (math.pi * 2) - math.pi)
            if diff < math.rad(55) then farEnough = false end
        end
        if farEnough then
            local present = CONFIG.REAL_PRESENTS and loadFestive("Present")
            local ps = 0.32 + math.random() * 0.18 -- масштаб настоящего подарка
            local size = present and (present.size and fV3(present.size) or Vector3.new(2, 2.4, 2)) * ps
                or GIFT_SIZES[math.random(#GIFT_SIZES)]
            local dist = potR + 0.2 + math.max(size.X, size.Z) / 2
            local dir = Vector3.new(math.cos(a), 0, math.sin(a))
            local from = Vector3.new(center.X, floorY + 0.35, center.Z)
            -- нет ли там стены или мебели
            if not workspace:Raycast(from, dir * (dist + math.max(size.X, size.Z) / 2 + 0.1), params) then
                local pos = Vector3.new(center.X, floorY, center.Z) + dir * dist
                local baseCF = CFrame.new(pos) * CFrame.Angles(0, math.random() * math.pi * 2, 0)
                local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
                if present then
                    local box = festiveItem(present, "Box")
                    local lift = box and box.size[2] * ps / 2 or size.Y / 2
                    local model = spawnFestive(present, baseCF * CFrame.new(0, lift, 0), {
                        scale = ps,
                        -- Box — коробка, Wrapper — лента крест-накрест, Bow — бантик
                        colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon },
                    })
                    model.Parent = folder
                else
                    addGift(folder, baseCF, size, style)
                end
                table.insert(placed, a)
                giftCount += 1
            end
        end
    end
    return placed
end

---------------------------------------------------------------- снеговики

local SNOWMAN_SNOW = Color3.fromRGB(242, 246, 252)
local COAL = Color3.fromRGB(28, 26, 28)
local SCARF_COLORS = {
    Color3.fromRGB(200, 30, 40), Color3.fromRGB(40, 120, 70), Color3.fromRGB(45, 90, 190), Color3.fromRGB(235, 185, 60),
}
local snowmanCount = 0

-- Снеговик высотой h. base — точка на полу (низ, по центру), лицо смотрит по base.LookVector.
local function buildSnowman(parent, base, h, withHat)
    local m = Instance.new("Model")
    m.Name = "Snowman"
    local function add(props)
        local p = decorPart(props)
        p.Parent = m
        return p
    end
    local function ball(r, cf, color, mat)
        return add({ Name = "Ball", Shape = Enum.PartType.Ball, Size = Vector3.new(r * 2, r * 2, r * 2), CFrame = cf,
            Color = color or SNOWMAN_SNOW, Material = mat or Enum.Material.Snow })
    end
    local function stick(a, b, d, color, mat)
        local dir = b - a
        local x = dir.Unit
        local up = Vector3.yAxis - x * x.Y
        up = up.Magnitude > 1e-3 and up.Unit or Vector3.zAxis
        return add({ Name = "Stick", Shape = Enum.PartType.Cylinder, Size = Vector3.new(dir.Magnitude, d, d),
            CFrame = CFrame.fromMatrix((a + b) / 2, x, up), Color = color, Material = mat })
    end
    -- три кома (в долях высоты), потом подгоняем под h
    local r1, r2, r3 = 0.25, 0.18, 0.13
    local c1 = r1 * 0.95
    local c2 = c1 + (r1 + r2) * 0.78
    local c3 = c2 + (r2 + r3) * 0.8
    local k = h / (c3 + r3 * (withHat and 1.9 or 1))
    r1, r2, r3, c1, c2, c3 = r1 * k, r2 * k, r3 * k, c1 * k, c2 * k, c3 * k
    base = base * CFrame.Angles(math.rad(math.random(-4, 4)), 0, math.rad(math.random(-4, 4)))
    local function at(x, y, z) return base * CFrame.new(x, y, z) end

    -- сугробик под ногами
    add({ Name = "SnowBase", Shape = Enum.PartType.Cylinder, Size = Vector3.new(r1 * 0.22, r1 * 2.7, r1 * 2.7),
        CFrame = at(0, r1 * 0.06, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = SNOWMAN_SNOW, Material = Enum.Material.Snow })
    ball(r1, at(0, c1, 0))
    ball(r2, at(0, c2, 0))
    local head = at(0, c3, 0) * CFrame.Angles(0, math.rad(math.random(-15, 15)), math.rad(math.random(-6, 6)))
    ball(r3, head)
    -- глаза-угольки и улыбка
    for _, sx in ipairs({ -1, 1 }) do
        ball(r3 * 0.11, head * CFrame.new(sx * r3 * 0.36, r3 * 0.22, -r3 * 0.9), COAL, Enum.Material.Slate)
    end
    for i = -2, 2 do
        local a = i * 0.32
        ball(r3 * 0.065, head * CFrame.new(math.sin(a) * r3 * 0.5, -r3 * 0.3 - math.cos(a) * r3 * 0.06 + r3 * 0.06,
            -r3 * 0.88), COAL, Enum.Material.Slate)
    end
    -- нос-морковка
    local nose = add({ Name = "Carrot", Size = Vector3.new(r3 * 0.2, r3 * 0.2, r3 * 0.85),
        Color = Color3.fromRGB(235, 120, 30), Material = Enum.Material.SmoothPlastic,
        CFrame = head * CFrame.new(0, 0, -r3 * 1.18) * CFrame.Angles(math.rad(-8), 0, 0) })
    local nm = Instance.new("SpecialMesh")
    nm.MeshType = Enum.MeshType.Sphere
    nm.Parent = nose
    -- пуговицы-угольки
    for _, y in ipairs({ 0.42, 0.05, -0.32 }) do
        local yy = y * r2
        ball(r2 * 0.09, at(0, c2 + yy, -math.sqrt(math.max(r2 * r2 - yy * yy, 0)) * 0.97), COAL, Enum.Material.Slate)
    end
    -- шарф: кольцо на шее и хвостик
    local scarf = SCARF_COLORS[math.random(#SCARF_COLORS)]
    add({ Name = "Scarf", Shape = Enum.PartType.Cylinder, Size = Vector3.new(r2 * 0.32, r2 * 1.42, r2 * 1.42),
        CFrame = at(0, c2 + r2 * 0.8, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = scarf, Material = Enum.Material.Fabric })
    add({ Name = "ScarfTail", Size = Vector3.new(r2 * 0.34, r2 * 0.95, r2 * 0.08), Color = scarf, Material = Enum.Material.Fabric,
        CFrame = at(r2 * 0.32, c2 + r2 * 0.35, -r2 * 0.72) * CFrame.Angles(math.rad(12), 0, math.rad(10)) })
    -- руки-веточки с сучком
    local wood, woodMat = Color3.fromRGB(92, 62, 40), Enum.Material.Wood
    for _, sx in ipairs({ -1, 1 }) do
        local a = at(sx * r2 * 0.8, c2 + r2 * 0.15, 0).Position
        local dir = base:VectorToWorldSpace(Vector3.new(sx, 0.45 + math.random() * 0.35, -0.15).Unit)
        local b = a + dir * h * 0.3
        stick(a, b, h * 0.032, wood, woodMat)
        local mid = a + dir * h * 0.2
        stick(mid, mid + (dir + Vector3.new(0, 0.9, 0)).Unit * h * 0.08, h * 0.022, wood, woodMat)
    end
    -- цилиндр
    if withHat then
        local hat = head * CFrame.Angles(math.rad(math.random(-8, 4)), 0, math.rad(math.random(-10, 10)))
        local black = Color3.fromRGB(25, 25, 30)
        add({ Name = "HatBrim", Shape = Enum.PartType.Cylinder, Size = Vector3.new(r3 * 0.08, r3 * 1.75, r3 * 1.75),
            CFrame = hat * CFrame.new(0, r3 * 0.8, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = black,
            Material = Enum.Material.SmoothPlastic })
        add({ Name = "HatCrown", Shape = Enum.PartType.Cylinder, Size = Vector3.new(r3 * 0.95, r3 * 1.12, r3 * 1.12),
            CFrame = hat * CFrame.new(0, r3 * 0.8 + r3 * 0.5, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = black,
            Material = Enum.Material.SmoothPlastic })
        add({ Name = "HatBand", Shape = Enum.PartType.Cylinder, Size = Vector3.new(r3 * 0.2, r3 * 1.15, r3 * 1.15),
            CFrame = hat * CFrame.new(0, r3 * 0.8 + r3 * 0.16, 0) * CFrame.Angles(0, 0, math.pi / 2),
            Color = Color3.fromRGB(200, 30, 40), Material = Enum.Material.Fabric })
    end
    m.Parent = parent
    snowmanCount += 1
    return m
end

-- снеговик у ёлки: в стороне, где нет подарков, стены и мебели; смотрит от ёлки
local function addTreeSnowman(plant, folder, placed)
    if not CONFIG.SNOWMEN or math.random() > (CONFIG.SNOWMAN_TREE_CHANCE or 0.4) then return end
    local bcf, bsize = plant:GetBoundingBox()
    local pot = plant:FindFirstChild("Pot")
    local center = (pot and pot:IsA("BasePart")) and pot.Position or bcf.Position
    local potR = (pot and pot:IsA("BasePart")) and math.max(pot.Size.X, pot.Size.Z) / 2
        or math.min(bsize.X, bsize.Z) / 2
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { plant, root }
    local down = workspace:Raycast(center, Vector3.new(0, -12, 0), params)
    local floorY = down and down.Position.Y or (bcf.Position.Y - bsize.Y / 2)
    local h = 1.7 + math.random() * 0.5
    local r = h * 0.28
    local start = math.random() * math.pi * 2
    for k = 0, 11 do
        local a = start + k * math.pi * 2 / 12
        local free = true
        for _, other in ipairs(placed or {}) do
            local diff = math.abs((a - other + math.pi) % (math.pi * 2) - math.pi)
            if diff < math.rad(60) then free = false end
        end
        if free then
            local dir = Vector3.new(math.cos(a), 0, math.sin(a))
            local dist = potR + 0.3 + r
            local reach = dir * (dist + r + 0.2)
            local low = Vector3.new(center.X, floorY + 0.4, center.Z)
            local high = Vector3.new(center.X, floorY + h * 0.75, center.Z)
            if not workspace:Raycast(low, reach, params) and not workspace:Raycast(high, reach, params) then
                local spot = Vector3.new(center.X, floorY, center.Z) + dir * dist
                local floor = workspace:Raycast(spot + Vector3.new(0, 1.5, 0), Vector3.new(0, -4, 0), params)
                if floor and floor.Normal.Y > 0.9 then
                    local pos = floor.Position
                    local face = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, math.rad(math.random(-25, 25)), 0)
                    buildSnowman(folder, face, h, math.random() < 0.6)
                    return
                end
            end
        end
    end
end

-- палитра для игрушек на ёлках
local ORNAMENT_COLORS = {
    Color3.fromRGB(200, 30, 40),   -- красный
    Color3.fromRGB(235, 185, 60),  -- золотой
    Color3.fromRGB(205, 210, 220), -- серебряный
    Color3.fromRGB(45, 95, 210),   -- синий
    Color3.fromRGB(40, 150, 75),   -- зелёный
    Color3.fromRGB(140, 60, 180),  -- фиолетовый
    Color3.fromRGB(235, 110, 160), -- розовый
    Color3.fromRGB(240, 120, 40),  -- оранжевый
    Color3.fromRGB(80, 200, 220),  -- бирюзовый
}

-- стеклянные игрушки (Ornaments2) светятся: неон своего цвета, мягкое мерцание и свет вокруг ёлки
local glowOrnaments = {}
local glowConn
local function applyGlow(e)
    local on = CONFIG.GLOW_ORNAMENTS
    e.part.Material = on and Enum.Material.Neon or e.material
    e.part.Color = e.color
    e.part.Reflectance = on and 0 or e.reflectance
    e.light.Enabled = on
end
local function glowOrnament(part)
    local e = {
        part = part, color = part.Color, material = part.Material, reflectance = part.Reflectance,
        phase = math.random() * math.pi * 2, speed = 1.2 + math.random() * 0.8,
    }
    local l = Instance.new("PointLight")
    l.Name = "OrnamentGlow"
    l.Color = part.Color:Lerp(Color3.new(1, 1, 1), 0.25)
    l.Brightness = 0.9
    l.Range = math.clamp(part.Size.Magnitude * 1.6, 5, 9)
    l.Shadows = false
    l.Parent = part
    e.light = l
    table.insert(glowOrnaments, e)
    applyGlow(e)
    if glowConn then return end
    local acc = 0
    glowConn = connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 0.05 then return end
        acc = 0
        if not CONFIG.GLOW_ORNAMENTS then return end
        local t = os.clock()
        for k = #glowOrnaments, 1, -1 do
            local g = glowOrnaments[k]
            if not g.part.Parent then
                table.remove(glowOrnaments, k)
            else
                local w = (math.sin(t * g.speed + g.phase) + 1) / 2 -- 0..1
                g.part.Color = g.color:Lerp(Color3.new(0, 0, 0), 0.5 - 0.3 * w)
                g.light.Brightness = 0.5 + 0.7 * w
            end
        end
    end)
end
local function refreshGlow()
    for _, e in ipairs(glowOrnaments) do
        if e.part.Parent then applyGlow(e) end
    end
end

local function decorateTree(room, plant)
    local leaves = plant:FindFirstChild("Leaves")
    local cf, size
    if leaves and leaves:IsA("BasePart") then
        cf, size = leaves.CFrame, leaves.Size
    else
        cf, size = plant:GetBoundingBox()
    end
    if size.Y < 1 then return end
    local folder = roomFolder(room)

    -- игрушки и макушка из новогодней версии: та же ёлочка, поэтому ставим их
    -- относительно листьев (Leaves) ровно так, как они стоят там
    local style = CONFIG.TREE_STYLE
    local ornamented = false
    if style ~= "garland" and leaves and leaves:IsA("BasePart") then
        local data = loadFestive("Potted_Plant-XMAS25")
        local xl = data and festiveItem(data, "Leaves")
        if xl then
            local sc = leaves.Size.Y / xl.size[2]
            local frame = leaves.CFrame * scaledCF(xl.cf, sc):Inverse()
            local only = { Tops = true, Ornaments1 = true, Ornaments2 = true, Ornaments3 = true }
            local colors, reflect = nil, nil
            if CONFIG.TREE_RANDOM then
                -- три группы шариков — три разных цвета из палитры, блеск разный;
                -- иногда одной группы нет (но минимум две остаются)
                colors, reflect = {}, {}
                local pal = table.clone(ORNAMENT_COLORS)
                for k = #pal, 2, -1 do
                    local j = math.random(k)
                    pal[k], pal[j] = pal[j], pal[k]
                end
                local skip = math.random() < 0.35 and ("Ornaments" .. math.random(3)) or nil
                for k = 1, 3 do
                    local name = "Ornaments" .. k
                    colors[name] = pal[k]
                    reflect[name] = 0.1 + math.random() * 0.3
                    if name == skip then only[name] = nil end
                end
                colors.Tops = math.random() < 0.7 and Color3.fromRGB(235, 190, 70) or Color3.fromRGB(215, 220, 230)
                reflect.Tops = 0.35
            end
            local model = spawnFestive(data, frame, {
                scale = sc,
                only = only,
                colors = colors,
                reflectance = reflect,
            })
            model.Parent = folder
            local glass = model:FindFirstChild("Ornaments2")
            if glass and glass:IsA("BasePart") then glowOrnament(glass) end
            ornamented = true
        end
    end
    -- мишура спиралью вокруг кроны (чуть снаружи, сужается к макушке)
    if CONFIG.TINSEL and CONFIG.TREE_TINSEL then
        local h = size.Y
        local rBase = math.min(size.X, size.Z) / 2 * 0.95
        local phase = math.random() * math.pi * 2
        local pts = {}
        for k = 0, 70 do
            local u = k / 70
            local a = phase + u * 2.6 * math.pi * 2
            local r = rBase * (1 - 0.78 * u) + 0.12
            table.insert(pts, cf:PointToWorldSpace(Vector3.new(math.cos(a) * r, -h / 2 + h * (0.12 + 0.76 * u), math.sin(a) * r)))
        end
        task.defer(function()
            if makeTinsel then pcall(makeTinsel, folder, pts, nil, CONFIG.TINSEL_WIDTH * 0.8) end
        end)
    end
    if ornamented and style == "ornaments" then
        local okGifts, errGifts = pcall(addGifts, plant, folder)
        if not okGifts then warn("[NewYear] Подарки: " .. tostring(errGifts)) end
        local okSm, errSm = pcall(addTreeSnowman, plant, folder, okGifts and errGifts or nil)
        if not okSm then warn("[NewYear] Снеговик: " .. tostring(errSm)) end
        treeCount += 1
        return
    end

    local h = size.Y
    local rBase = math.min(size.X, size.Z) / 2 * 0.92
    local n = CONFIG.TREE_BULBS
    local phase = math.random() * math.pi * 2
    local function helix(u)
        local y = -h / 2 + h * (0.06 + 0.86 * u)
        -- крона шире внизу и сужается к макушке
        local r = rBase * (1 - 0.8 * u) + 0.06
        local a = phase + u * CONFIG.TREE_TURNS * math.pi * 2
        return cf:PointToWorldSpace(Vector3.new(math.cos(a) * r, y, math.sin(a) * r))
    end
    for k = 0, n - 1 do
        addBulb(folder, CFrame.new(helix(k / (n - 1))), CONFIG.TREE_BULB_SIZE, k + 1, 8, 3.5)
    end
    -- провод: точек вдвое больше, чем лампочек, чтобы спираль была плавной
    local wire, steps = {}, (n - 1) * 2
    local lift = Vector3.new(0, CONFIG.TREE_BULB_SIZE * 0.45, 0)
    for k = 0, steps do
        table.insert(wire, helix(k / steps) + lift)
    end
    addWire(folder, wire, 0.035)

    if CONFIG.TREE_STAR then
        -- звезда: три скрещенных золотых пластинки (видно с любой стороны)
        local top = cf * CFrame.new(0, h / 2 + 0.22, 0)
        local first
        for _, rot in ipairs({
            CFrame.Angles(0, 0, math.rad(45)),
            CFrame.Angles(0, 0, 0),
            CFrame.Angles(0, math.rad(90), math.rad(45)),
        }) do
            local p = decorPart({
                Name = "Star", Size = Vector3.new(0.34, 0.34, 0.06),
                Material = Enum.Material.Neon, Color = GOLD,
                CFrame = top * rot,
            })
            p.Parent = folder
            first = first or p
        end
        local glow = Instance.new("PointLight")
        glow.Color = GOLD
        glow.Range = 4
        glow.Brightness = 1
        glow.Shadows = false
        glow.Parent = first
    end
    local okGifts, errGifts = pcall(addGifts, plant, folder)
    if not okGifts then warn("[NewYear] Подарки: " .. tostring(errGifts)) end
    local okSm, errSm = pcall(addTreeSnowman, plant, folder, okGifts and errGifts or nil)
    if not okSm then warn("[NewYear] Снеговик: " .. tostring(errSm)) end
    treeCount += 1
end

local treesDone = {}   -- [модель ёлки] = true
local treesHooked = {} -- [комната] = true
local function decorateTrees(room)
    if not CONFIG.TREES or treesHooked[room] then return end
    treesHooked[room] = true
    local function try(d)
        if d:IsA("Model") and CONFIG.TREE_NAMES[d.Name] and not treesDone[d] then
            treesDone[d] = true
            -- крона могла подгрузиться не сразу
            task.delay(0.3, function()
                if not d.Parent then return end
                local ok, err = pcall(decorateTree, room, d)
                if not ok then warn("[NewYear] Ёлка " .. d:GetFullName() .. ": " .. tostring(err)) end
            end)
        end
    end
    for _, d in ipairs(room:GetDescendants()) do try(d) end
    connect(room.DescendantAdded, try)
end

local decorated = {}
local function decorateRoom(room, tries)
    if decorated[room] or not room:IsA("Model") then return end
    decorateTrees(room)
    local door = room:FindFirstChild("Door")
    if not door then
        -- дверь могла ещё не подгрузиться
        tries = (tries or 0) + 1
        if tries <= 10 then
            task.delay(1, function() if room.Parent then decorateRoom(room, tries) end end)
        end
        return
    end
    decorated[room] = true
    local ok, err = pcall(decorateDoor, room, door)
    if ok then
        doorCount += 1
    else
        warn("[NewYear] Гирлянда на " .. room.Name .. ": " .. tostring(err))
    end
end

-- мигание: цвета бегут по гирлянде
local blinkStep = 0
task.spawn(function()
    local token = {}
    env.__NewYearBlinkToken = token
    while env.__NewYearBlinkToken == token do
        blinkStep += 1
        local colors = CONFIG.GARLAND_COLORS
        local alive = {}
        for _, e in ipairs(bulbs) do
            if e.part.Parent and not brokenBulbs[e.part] then
                local c = colors[(e.index + blinkStep) % #colors + 1]
                e.part.Color = c
                -- каждая третья лампочка на миг гаснет
                local off = (e.index + blinkStep) % 3 == 0
                e.part.Transparency = off and 0.65 or (e.real and 0.2 or 0)
                if e.casing then e.casing.Color = c:Lerp(Color3.new(0, 0, 0), off and 0.85 or 0.7) end
                if e.light then e.light.Color = c; e.light.Enabled = not off end
                table.insert(alive, e)
            end
        end
        bulbs = alive
        task.wait(CONFIG.BLINK)
    end
end)

local okGarlands, errGarlands = pcall(function()
    if not CONFIG.GARLANDS then return end
    local rooms = workspace:FindFirstChild("CurrentRooms") or workspace:WaitForChild("CurrentRooms", 10)
    if rooms then
        for _, room in ipairs(rooms:GetChildren()) do decorateRoom(room) end
        connect(rooms.ChildAdded, function(room) task.defer(decorateRoom, room) end)
    else
        warn("[NewYear] Не нашёл workspace.CurrentRooms — гирлянды не повешу")
    end
end)
report("Garlands", okGarlands, errGarlands)

---------------------------------------------------------------- шапочка на бадди

local hatFor = {} -- [Tool] = Model

local RED = Color3.fromRGB(200, 25, 35)
local WHITE = Color3.fromRGB(245, 245, 245)

local function weldTo(base, part, offset)
    part.Anchored = false
    part.Massless = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.CFrame = base.CFrame * offset
    local w = Instance.new("Weld")
    w.Part0 = base
    w.Part1 = part
    w.C0 = offset
    w.Parent = part
end

-- Шапка из деталей: белая опушка, красный конус из сужающихся дисков,
-- кончик свисает назад-вбок, на нём белый помпон
local function buildHat(base, topOffset, s)
    s = s or 1
    local hat = Instance.new("Model")
    hat.Name = "NewYearHat"

    local function cyl(diameter, height, color, offset)
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Cylinder
        p.Size = Vector3.new(height * s, diameter * s, diameter * s) -- ось цилиндра — X
        p.Color = color
        p.Material = Enum.Material.Fabric
        p.Parent = hat
        weldTo(base, p, offset * CFrame.Angles(0, 0, math.pi / 2)) -- ось вверх
        return p
    end

    local brim = topOffset
    cyl(0.95, 0.16, WHITE, brim)

    -- конус: 6 дисков, каждый уже и всё сильнее загибается назад и вбок
    local cf = brim * CFrame.new(0, 0.12 * s, 0)
    local diameter = 0.82
    for k = 1, 6 do
        local h = 0.15
        cyl(diameter, h + 0.02, RED, cf)
        cf = cf * CFrame.new(0, h * s, 0) * CFrame.Angles(math.rad(9 + k * 3), 0, math.rad(6))
        diameter *= 0.8
    end
    local ball = Instance.new("Part")
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(0.26, 0.26, 0.26) * s
    ball.Color = WHITE
    ball.Material = Enum.Material.Fabric
    ball.Parent = hat
    weldTo(base, ball, cf * CFrame.new(0, 0.08 * s, 0))
    return hat
end

local function hatBuddy(tool)
    if hatFor[tool] then return end
    -- бадди в плаще: шапка на капюшон (двигается вместе с ним и в анимациях treat_buddy)
    local base = tool:FindFirstChild("Buddy_Hood", true) or tool:FindFirstChild("Buddy_Head", true)
    if not (base and base:IsA("BasePart")) then return end
    local offset
    if base.Name == "Buddy_Hood" then
        offset = CFrame.new(0, base.Size.Y * 0.38, -0.05) * CFrame.Angles(math.rad(10), 0, math.rad(8))
    else
        offset = CFrame.new(0, base.Size.Y * 0.5 + 0.05, 0) * CFrame.Angles(math.rad(10), 0, math.rad(8))
    end
    local hat = buildHat(base, offset)
    hat.Parent = tool
    hatFor[tool] = hat
    hatCount += 1
    track(hat)
end

local function isBuddy(t)
    return t:IsA("Tool") and t:GetAttribute("NameSingular") == "Buddy"
end

local function watchBuddies(container)
    if not container then return end
    for _, t in ipairs(container:GetChildren()) do
        if isBuddy(t) then
            local ok, err = pcall(hatBuddy, t)
            if not ok then warn("[NewYear] Шапка: " .. tostring(err)) end
        end
    end
    connect(container.ChildAdded, function(t)
        if isBuddy(t) then task.defer(function() pcall(hatBuddy, t) end) end
    end)
end

local okHat, errHat = pcall(function()
    if not CONFIG.BUDDY_HAT then return end
    local function onCharacter(char)
        watchBuddies(char)
        watchBuddies(player:WaitForChild("Backpack"))
    end
    if player.Character then task.spawn(onCharacter, player.Character) end
    connect(player.CharacterAdded, onCharacter)
end)
report("Hat", okHat, errHat)

---------------------------------------------------------------- ключ-трость

-- Ключ в DOORS: KeyObtain -> Hitbox -> детали Key, Ring, Tag.
-- Прячем Key/Ring/Tag и привариваем к Key трость в красно-белую полоску.
-- Трость лежит внутри того же объекта, что и ключ, поэтому ездит и исчезает вместе с ним.
local CANE_RED = Color3.fromRGB(215, 20, 35)
local CANE_WHITE = Color3.fromRGB(250, 248, 245)
local CANE_PARTS = { Key = true, Ring = true, Tag = true }
local caneFor = {} -- [деталь Key] = Model

local restoreHidden = {} -- { inst, prop, old } — что вернуть при выключении скрипта
-- Держим свойство в нужном значении: игра может снова показать ключ — прячем обратно
local function keepHidden(inst, prop, value)
    table.insert(restoreHidden, { inst, prop, inst[prop] })
    inst[prop] = value
    connect(inst:GetPropertyChangedSignal(prop), function()
        if inst[prop] ~= value then inst[prop] = value end
    end)
end

local hiddenOwner = {} -- [спрятанная деталь ключа] = трость, которая её заменила
local function hidePart(part, cane)
    if hiddenOwner[part] then return end
    hiddenOwner[part] = cane
    keepHidden(part, "Transparency", 1)
    for _, d in ipairs(part:GetChildren()) do
        if d:IsA("Decal") or d:IsA("Texture") then
            keepHidden(d, "Transparency", 1)
        elseif d:IsA("BasePart") and not d:IsDescendantOf(cane) then
            hidePart(d, cane) -- контур/обводка ключа, если она отдельной деталью
        end
    end
end

-- Подсветка игры (Highlight), которая обводит спрятанный ключ, теперь обводит трость
local watchedHighlights = setmetatable({}, { __mode = "k" })
local function ownerOf(inst)
    while inst do
        if hiddenOwner[inst] then return hiddenOwner[inst] end
        inst = inst.Parent
    end
end
local function fixHighlight(h)
    if not h:IsA("Highlight") then return end
    local function apply()
        local cane = ownerOf(h.Adornee or h.Parent)
        if cane and cane.Parent and h.Adornee ~= cane then h.Adornee = cane end
    end
    apply()
    if not watchedHighlights[h] then
        watchedHighlights[h] = true
        connect(h:GetPropertyChangedSignal("Adornee"), apply)
    end
end
local function watchHighlights(container)
    if not container then return end
    for _, d in ipairs(container:GetDescendants()) do fixHighlight(d) end
    connect(container.DescendantAdded, function(d)
        if d:IsA("Highlight") then task.defer(fixHighlight, d) end
    end)
end

-- Строим трость в своей системе координат: стержень вдоль +Y, крючок наверху загибается в +X.
-- frame переводит эту систему в систему детали Key.
local function buildCane(key, frame, L)
    local cane = Instance.new("Model")
    cane.Name = "NewYearCandyCane"
    local d = math.max(L * 0.1, 0.06)       -- толщина
    local R = L * 0.17                      -- радиус крючка
    local shaft = L * 0.78                  -- длина прямой части
    local yBottom = -(shaft + R) / 2        -- центрируем всю трость на ключе
    local yTop = yBottom + shaft
    local stripe = 0

    local function piece(shape, size, color, localCf)
        local p = Instance.new("Part")
        p.Shape = shape
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.Reflectance = 0.08
        p.Parent = cane
        weldTo(key, p, frame * localCf)
        return p
    end
    local function nextColor()
        stripe += 1
        return (stripe % 2 == 1) and CANE_RED or CANE_WHITE
    end
    -- цилиндр в Roblox лежит вдоль X: поворачиваем X по направлению dir (dir в плоскости XY)
    local function along(pos, dir)
        return CFrame.fromMatrix(pos, dir, Vector3.zAxis:Cross(dir))
    end

    -- стержень полосками
    local seg = d * 1.15
    local n = math.max(3, math.floor(shaft / seg))
    seg = shaft / n
    for i = 0, n - 1 do
        local y = yBottom + seg * (i + 0.5)
        piece(Enum.PartType.Cylinder, Vector3.new(seg + d * 0.05, d, d), nextColor(),
            along(Vector3.new(0, y, 0), Vector3.yAxis))
    end
    piece(Enum.PartType.Ball, Vector3.new(d, d, d), CANE_RED, CFrame.new(0, yBottom, 0))

    -- крючок: дуга чуть больше полукруга, центр дуги в (R, yTop)
    local m = 9
    local total = math.rad(200)
    local function arcPoint(a)
        return Vector3.new(R - R * math.cos(a), yTop + R * math.sin(a), 0)
    end
    for i = 0, m - 1 do
        local a0, a1 = total * i / m, total * (i + 1) / m
        local p0, p1 = arcPoint(a0), arcPoint(a1)
        local color = nextColor()
        piece(Enum.PartType.Cylinder, Vector3.new((p1 - p0).Magnitude + d * 0.1, d, d), color,
            along((p0 + p1) / 2, (p1 - p0).Unit))
        piece(Enum.PartType.Ball, Vector3.new(d, d, d), color, CFrame.new(p1)) -- скругляем стыки
    end
    return cane
end

-- Обводка ключа появляется, только когда на него смотришь (рука и «E»), и живёт не внутри KeyObtain.
-- Поэтому в момент наведения ищем вокруг: подсветку (Highlight) на ключе — переключаем на трость;
-- копии ключа с тем же мешем рядом (контур из клонов) — прячем. Найденное пишем в файл.
local function isMine(inst)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    return (char and inst:IsDescendantOf(char)) or (bp and inst:IsDescendantOf(bp))
end

local hoverLogged = false
local hoverSpots = {} -- контейнеры, где уже находили обводку: дальше проверяем только их
local function hoverScan(obtain, cane, meshIds, full)
    if not (obtain.Parent and cane.Parent) then return end
    local center = cane:GetPivot().Position
    local found = {}
    local function check(d)
        if d:IsA("Highlight") then
            local a = d.Adornee or d.Parent
            if a and (a == obtain or a:IsDescendantOf(obtain)) and a ~= cane and not a:IsDescendantOf(cane) then
                table.insert(found, d:GetFullName() .. " [Highlight] adornee=" .. a:GetFullName())
                d.Adornee = cane
                hoverSpots[d.Parent] = true
            end
        elseif d:IsA("MeshPart") and meshIds[d.MeshId] and d.Transparency < 1
            and not d:IsDescendantOf(obtain) and not isMine(d)
            and (d.Position - center).Magnitude < 8 then
            table.insert(found, d:GetFullName() .. " [MeshPart клон] material=" .. d.Material.Name
                .. " transp=" .. d.Transparency)
            keepHidden(d, "Transparency", 1)
            hoverSpots[d.Parent] = true
        elseif (d:IsA("SelectionBox") or d:IsA("SurfaceSelection")) and d.Adornee
            and d.Adornee:IsDescendantOf(obtain) and not d.Adornee:IsDescendantOf(cane) then
            table.insert(found, d:GetFullName() .. " [" .. d.ClassName .. "]")
            keepHidden(d, "Visible", false)
            hoverSpots[d.Parent] = true
        end
    end
    local roots = { workspace.CurrentCamera, player:FindFirstChild("PlayerGui") }
    if full then
        roots = { workspace, player:FindFirstChild("PlayerGui") }
    else
        for spot in pairs(hoverSpots) do
            if spot.Parent then table.insert(roots, spot) end
        end
    end
    for _, r in ipairs(roots) do
        if r then
            for _, d in ipairs(r:GetDescendants()) do check(d) end
        end
    end
    if full and not hoverLogged then
        hoverLogged = true
        local text = "Обводка ключа при наведении:\n" ..
            (#found > 0 and table.concat(found, "\n") or "ничего не нашёл (ни Highlight, ни клонов меша)")
        print("[NewYear] " .. text)
        pcall(function()
            if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
            writefile("StevieBuddy/key_hover_scan.txt", text)
        end)
    end
end

local function watchHover(obtain, cane)
    local meshIds = {}
    for _, d in ipairs(obtain:GetDescendants()) do
        if d:IsA("MeshPart") and CANE_PARTS[d.Name] and d.MeshId ~= "" then meshIds[d.MeshId] = true end
    end
    local prompt = obtain:FindFirstChildWhichIsA("ProximityPrompt", true)
    local scannedFull = false
    local function onHover(real)
        -- обводка может появиться не сразу — проверяем пару раз;
        -- весь workspace просматриваем один раз, при первом настоящем наведении
        for _, delay in ipairs({ 0.05, 0.3, 0.8 }) do
            task.delay(delay, function()
                local full = CONFIG.SCAN and real and not scannedFull and delay >= 0.3
                if full then scannedFull = true end
                pcall(hoverScan, obtain, cane, meshIds, full)
            end)
        end
    end
    if prompt then connect(prompt.PromptShown, function() onHover(true) end) end
    onHover(false)
end

-- Где у ключа что лежит. Два варианта:
--   на полу:  KeyObtain -> Hitbox -> Key, Ring, Tag (детали рядом друг с другом)
--   в руке:   Tool "Key" -> Handle (это сам ключ) -> Ring -> Tag, табличка Sign в инструменте
-- Возвращает: деталь-ключ, куда положить трость, внутри чего искать кольцо/бирку/надписи
-- Ключ от электрощитовой (100-я, ElectricalKeyObtain) и другие ключи без деталей Key/Ring/Tag:
-- трость ставим по самой большой видимой детали, прячем все видимые детали ключа.
-- Отмычку (Skeleton Key) не трогаем — это отдельный предмет.
local function otherKeyTool(t)
    local n = t.Name
    return n ~= "Key" and n:find("Key$") ~= nil and not n:lower():find("skeleton", 1, true)
end
local function biggestVisible(container)
    local best
    for _, p in ipairs(container:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 0.9 and (not best or p.Size.Magnitude > best.Size.Magnitude) then best = p end
    end
    return best
end
local function keyRig(d)
    if d:IsA("Tool") and d.Name == "Key" then
        local handle = d:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then return handle, d, d end
        return nil
    end
    if d:IsA("Tool") and otherKeyTool(d) then
        local handle = d:FindFirstChild("Handle")
        if not (handle and handle:IsA("BasePart")) then return nil end
        local vis = handle.Transparency < 0.9 and handle or biggestVisible(d)
        if vis then return vis, d, d, true end
        return nil
    end
    if d:IsA("BasePart") and d.Name == "Key" and d.Parent
        and (d.Parent:FindFirstChild("Ring") or d.Parent:FindFirstChild("Tag")) then
        return d, d.Parent, d:FindFirstAncestor("KeyObtain") or d.Parent
    end
    if d:IsA("Model") and d.Name ~= "KeyObtain" and d.Name:sub(-9) == "KeyObtain" and not d:FindFirstChild("Key", true) then
        local vis = biggestVisible(d)
        if vis then return vis, vis.Parent, d, true end
    end
    return nil
end

local onCaneTool -- трость в руке: иконка и анимации (задаётся ниже)
local caneAxes = {} -- [деталь-ключ] = { up (к крючку), side (куда загибается крючок), L } в осях детали

local function caneKey(key, holder, scope, other)
    if caneFor[key] or not key.Parent then return end

    -- длинная ось ключа = стержень трости, вторая по длине = плоскость крючка
    local size = key.Size
    local axes = {
        { v = Vector3.xAxis, len = size.X },
        { v = Vector3.yAxis, len = size.Y },
        { v = Vector3.zAxis, len = size.Z },
    }
    table.sort(axes, function(a, b) return a.len > b.len end)
    local up, side = axes[1].v, axes[2].v
    -- крючок там, где кольцо (у ключа это головка)
    local ring = scope:FindFirstChild("Ring", true)
    if ring and ring:IsA("BasePart") then
        local rel = key.CFrame:PointToObjectSpace(ring.Position)
        if rel:Dot(up) < 0 then up = -up end
    end
    local frame = CFrame.fromMatrix(Vector3.zero, side, up)
    local L = axes[1].len * CONFIG.CANDY_KEY_SCALE
    if other then
        -- незнакомый ключ: длина — по всем видимым деталям, в разумных пределах
        local mx = 0
        for _, d in ipairs(scope:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.9 then mx = math.max(mx, d.Size.X, d.Size.Y, d.Size.Z) end
        end
        L = math.clamp(math.max(L, mx) * CONFIG.CANDY_KEY_SCALE, 0.8, 2.6)
    end

    local cane = buildCane(key, frame, L)
    caneAxes[key] = { up = up, side = side, L = L }
    caneFor[key] = cane
    cane.Parent = holder
    track(cane)
    hidePart(key, cane)
    for _, d in ipairs(scope:GetDescendants()) do
        if d:IsA("BasePart") and (CANE_PARTS[d.Name] or (other and d.Transparency < 0.9))
            and not d:IsDescendantOf(cane) then
            hidePart(d, cane)
        elseif d:IsA("SurfaceGui") then
            keepHidden(d, "Enabled", false) -- номер на бирке («0001»)
        end
    end
    for _, d in ipairs(scope:GetDescendants()) do fixHighlight(d) end
    if scope.Name:sub(-9) == "KeyObtain" then watchHover(scope, cane) end
    if holder:IsA("Tool") and onCaneTool then pcall(onCaneTool, holder, key, cane) end
    caneCount += 1
end

local function tryKey(d)
    local key, holder, scope, other = keyRig(d)
    if key and not caneFor[key] then
        local ok, err = pcall(caneKey, key, holder, scope, other)
        if not ok then warn("[NewYear] Трость: " .. tostring(err)) end
    end
end

local WATCH_NAMES = { Key = true, Ring = true, Tag = true, Handle = true }
local function watchKeys(container)
    if not container then return end
    tryKey(container)
    for _, d in ipairs(container:GetDescendants()) do tryKey(d) end
    connect(container.DescendantAdded, function(d)
        if d:IsA("Model") and d.Name:sub(-9) == "KeyObtain" and d.Name ~= "KeyObtain" then
            task.delay(0.5, function() if d.Parent then tryKey(d) end end)
        end
        if WATCH_NAMES[d.Name] then
            -- детали ключа подгружаются не сразу: ждём чуть-чуть и проверяем ключ целиком
            task.delay(0.2, function()
                if not d.Parent then return end
                tryKey(d)
                tryKey(d.Parent)
                local tool = d:FindFirstAncestorWhichIsA("Tool")
                if tool then tryKey(tool) end
            end)
        end
    end)
end

-- Если ключ в руке так и не стал тростью — сохраним, из чего он сделан, чтобы поправить
local function dumpTool(tool)
    if not CONFIG.SCAN then return end
    local lines = { "Ключ в руке: " .. tool:GetFullName() }
    for _, d in ipairs(tool:GetDescendants()) do
        local extra = d:IsA("BasePart") and ("  size=" .. tostring(d.Size) .. " transp=" .. d.Transparency) or ""
        table.insert(lines, d:GetFullName() .. " [" .. d.ClassName .. "]" .. extra)
    end
    local text = table.concat(lines, "\n")
    print("[NewYear] " .. text)
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        writefile("StevieBuddy/key_tool_scan.txt", text)
    end)
end

local function watchToolBox(container)
    if not container then return end
    watchKeys(container)
    connect(container.ChildAdded, function(t)
        if not t:IsA("Tool") then return end
        task.delay(0.2, function() tryKey(t) end)
        if t.Name:lower():find("key") then
            task.delay(1.5, function()
                for _, d in ipairs(t:GetDescendants()) do
                    if caneFor[d] then return end
                end
                dumpTool(t)
            end)
        end
    end)
end

local okCane, errCane = pcall(function()
    if not CONFIG.CANDY_KEY then return end
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        watchKeys(rooms)
        watchHighlights(rooms)
    end)
    task.spawn(function()
        watchHighlights(player:WaitForChild("PlayerGui", 30))
    end)
    watchHighlights(workspace.CurrentCamera)
    for _, d in ipairs(workspace:GetChildren()) do fixHighlight(d) end
    connect(workspace.ChildAdded, function(d)
        if d:IsA("Highlight") then task.defer(fixHighlight, d) end
    end)
    local function onCharacter(char)
        watchHighlights(char)
        watchToolBox(char)
        watchToolBox(player:WaitForChild("Backpack"))
    end
    if player.Character then task.spawn(onCharacter, player.Character) end
    connect(player.CharacterAdded, onCharacter)
end)
report("CandyKey", okCane, errCane)

---------------------------------------------------------------- двойная дверь (50-я)

-- size: ширина проёма (X), высота (Y), толщина (Z) в осях axisCF; sides — стороны, где украшаем
decorateDoubleDoor = function(folder, leaves, axisCF, size, sides)
    local half, depth, floorY = size.X / 2, size.Z, -size.Y / 2
    local wreath = CONFIG.WREATHS and loadFestive("Wreath")
    local present = CONFIG.REAL_PRESENTS and loadFestive("Present")
    for _, side in ipairs(sides) do
        local outW = axisCF:VectorToWorldSpace(Vector3.new(0, 0, side))
        -- венок на каждой створке: приварен к ней, открывается вместе с ней
        if wreath then
            local ws = CONFIG.WREATH_SCALE
            local wsize = wreath.size and fV3(wreath.size) or Vector3.new(3.9, 4.1, 1.2)
            for _, lf in ipairs(leaves) do
                local thick = math.min(lf.Size.X, lf.Size.Z) / 2
                local pos = lf.Position + axisCF.UpVector * (lf.Size.Y * 0.17) + outW * (thick + wsize.Z * ws / 2)
                local m = spawnFestive(wreath, CFrame.lookAt(pos, pos - outW), { scale = ws, weld = lf })
                m.Parent = folder
            end
        end
        -- большие карамельные трости по бокам, крючком к двери
        local L = 5
        for _, sx in ipairs({ -1, 1 }) do
            local basePos = axisCF:PointToWorldSpace(Vector3.new(sx * (half + 1.0), floorY + 0.475 * L + 0.05,
                side * (depth / 2 + 1.2)))
            local base = Instance.new("Part")
            base.Name = "DoorCaneBase"
            base.Anchored = true
            base.Transparency = 1
            base.CanCollide, base.CanTouch, base.CanQuery = false, false, false
            base.Size = Vector3.new(0.05, 0.05, 0.05)
            base.CFrame = CFrame.fromMatrix(basePos, axisCF.XVector, Vector3.yAxis)
            base.Parent = folder
            local cane = buildCane(base, CFrame.fromMatrix(Vector3.zero, Vector3.xAxis * -sx, Vector3.yAxis), L)
            cane.Parent = folder
            -- кучка подарков у трости
            if present then
                local spots = { { 0.0, 0.0 }, { 0.75, 0.35 }, { -0.4, 0.8 } }
                for k, s in ipairs(spots) do
                    local ps = (k == 1 and 0.5 or 0.38) + math.random() * 0.08
                    local box = festiveItem(present, "Box")
                    local lift = box and box.size[2] * ps / 2 or 0.4
                    local pos = axisCF:PointToWorldSpace(Vector3.new(sx * (half + 1.0 + s[1]), floorY + lift,
                        side * (depth / 2 + 2.0 + s[2])))
                    local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
                    local m = spawnFestive(present, CFrame.new(pos) * CFrame.Angles(0, math.random() * math.pi * 2, 0), {
                        scale = ps,
                        colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon },
                    })
                    m.Parent = folder
                    giftCount += 1
                end
            end
        end
    end
end

local cleanupCane -- выключение иконки и анимаций трости (задаётся ниже)
do
---------------------------------------------------------------- трость: иконка в инвентаре и анимации

-- Файл из workspace (StevieBuddy/...); если его нет — качаем с GitHub. Возвращает ссылку getcustomasset.
local function assetFrom(file, url, check)
    local has = isfile and isfile(file)
    if not has and url and url ~= "" and writefile then
        local ok, data = pcall(game.HttpGet, game, url)
        if ok and type(data) == "string" and #data > 100 and (not check or check(data)) then
            pcall(function()
                local dir = ""
                for part in file:gmatch("([^/]+)/") do
                    dir = dir .. part
                    if makefolder and not (isfolder and isfolder(dir)) then makefolder(dir) end
                    dir = dir .. "/"
                end
                writefile(file, data)
            end)
            has = isfile and isfile(file)
        end
    end
    if not (has and getcustomasset) then return nil end
    local ok, id = pcall(getcustomasset, file)
    return ok and id or nil
end
local function notPage(data)
    return not data:match("^%s*<") and not data:match("^404")
end

local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local caneTools = {}  -- [Tool] = { handle, cane, icon = родная TextureId }
local caneIcon = nil  -- картинка трости (getcustomasset)
local caneAlive = true

-- звуки (синтез, файлы в StevieBuddy/sounds)
local CANE_SOUND_FILES = {
    whoosh = { "cane_whoosh1.mp3", "cane_whoosh2.mp3" },
    catch = { "cane_catch.mp3" },
    crunch = { "cane_crunch1.mp3", "cane_crunch2.mp3", "cane_crunch3.mp3" },
}
local caneSounds = {}
local function playCane(name)
    local list = caneSounds[name]
    if not (list and #list > 0) then return end
    local s = Instance.new("Sound")
    s.Name = "NewYearCane_" .. name
    s.SoundId = list[math.random(#list)]
    s.Volume = CONFIG.CANE_SOUND_VOLUME
    s.PlaybackSpeed = 0.94 + math.random() * 0.12
    s.Parent = game:GetService("SoundService")
    s:Play()
    Debris:AddItem(s, 3)
end

task.spawn(function()
    if CONFIG.CANE_ICON then
        caneIcon = assetFrom(CONFIG.CANE_ICON_FILE, CONFIG.ASSETS_URL .. "textures/candy_key_icon.png",
            function(d) return d:sub(2, 4) == "PNG" end)
        if not caneIcon then warn("[NewYear] Нет картинки " .. CONFIG.CANE_ICON_FILE) end
    end
    if CONFIG.CANE_ANIMS or CONFIG.CANE_EAT then
        for name, files in pairs(CANE_SOUND_FILES) do
            local list = {}
            for _, f in ipairs(files) do
                local id = assetFrom("StevieBuddy/sounds/" .. f, CONFIG.ASSETS_URL .. "sounds/" .. f, notPage)
                if id then table.insert(list, id) end
            end
            caneSounds[name] = list
            if #list == 0 then warn("[NewYear] Нет звука трости: " .. name) end
        end
    end
end)

---------------------------------------------------------------- иконка в хотбаре

-- Хотбар DOORS: MainUI -> Hotbar -> слоты. Картинка слота — либо ImageLabel с TextureId предмета,
-- либо ViewportFrame с 3D-копией предмета. Картинку меняем на свою, в 3D-окошко кладём свою
-- картинку поверх (а саму 3D-копию делаем прозрачной).
local iconPatched = {} -- [ImageLabel] = родная картинка
local viewPatched = {} -- [ViewportFrame] = { overlay, transp }
local hotbarLogged = false

local function isCaneView(vf, meshIds)
    for _, d in ipairs(vf:GetDescendants()) do
        if d.Name == "NewYearCandyCane" then return true end
        if d:IsA("MeshPart") and meshIds[d.MeshId] then return true end
    end
    return false
end

local function dumpHotbar(area)
    hotbarLogged = true
    if not CONFIG.SCAN then return end
    local lines = { "Хотбар: " .. area:GetFullName() }
    for _, d in ipairs(area:GetDescendants()) do
        if #lines > 300 then break end
        local extra = ""
        if d:IsA("ImageLabel") or d:IsA("ImageButton") then extra = " image=" .. d.Image end
        if d:IsA("GuiObject") then extra = extra .. " visible=" .. tostring(d.Visible) end
        if d:IsA("BasePart") then extra = extra .. " size=" .. tostring(d.Size) end
        table.insert(lines, d:GetFullName() .. " [" .. d.ClassName .. "]" .. extra)
    end
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        writefile("StevieBuddy/hotbar_scan.txt", table.concat(lines, "\n"))
    end)
end

local function patchHotbar()
    if not caneIcon then return end
    local origs, meshIds, any = {}, {}, false
    for tool, info in pairs(caneTools) do
        if tool:IsDescendantOf(game) then
            any = true
            if info.icon ~= "" and info.icon ~= caneIcon then origs[info.icon] = true end
            if info.handle:IsA("MeshPart") and info.handle.MeshId ~= "" then meshIds[info.handle.MeshId] = true end
            if tool.TextureId ~= caneIcon then tool.TextureId = caneIcon end
        else
            caneTools[tool] = nil
        end
    end
    for img in pairs(iconPatched) do
        if not img.Parent or img.Image ~= caneIcon then iconPatched[img] = nil end
    end

    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("MainUI")
    if main and any then
        local area = main:FindFirstChild("Hotbar", true) or main
        for _, d in ipairs(area:GetDescendants()) do
            if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and origs[d.Image] then
                iconPatched[d] = d.Image
                d.Image = caneIcon
            elseif d:IsA("ViewportFrame") and not viewPatched[d] and isCaneView(d, meshIds) then
                local ov = Instance.new("ImageLabel")
                ov.Name = "NewYearCaneIcon"
                ov.BackgroundTransparency = 1
                ov.AnchorPoint = Vector2.new(0.5, 0.5)
                ov.Position = UDim2.fromScale(0.5, 0.5)
                ov.Size = UDim2.fromScale(0.9, 0.9)
                ov.ScaleType = Enum.ScaleType.Fit
                ov.Image = caneIcon
                ov.ZIndex = d.ZIndex + 1
                ov.Parent = d
                viewPatched[d] = { overlay = ov, transp = d.ImageTransparency }
                d.ImageTransparency = 1
            end
        end
        if not hotbarLogged then dumpHotbar(area) end
    end
    for vf, p in pairs(viewPatched) do
        if not (any and vf.Parent and isCaneView(vf, meshIds)) then
            if vf.Parent then vf.ImageTransparency = p.transp end
            p.overlay:Destroy()
            viewPatched[vf] = nil
        elseif vf.ImageTransparency ~= 1 then
            vf.ImageTransparency = 1
        end
    end
end

task.spawn(function()
    while caneAlive do
        if CONFIG.CANE_ICON and next(caneTools) then pcall(patchHotbar) end
        task.wait(0.3)
    end
end)

---------------------------------------------------------------- анимации трости

-- Как у бадди (treat_buddy.lua): каждый кадр сами ставим суставам руки (Transform) свою позу
-- поверх игровой. Трость приварена к Handle ключа, поэтому крутим/подбрасываем сам Handle
-- через его сустав в руке. Игровые анимации ключа: inspect (ПКМ) — заменяем своей,
-- use (вставить в замок) — заменяем поеданием.
local rad, sin, TAU = math.rad, math.sin, math.pi * 2
local function D(px, py, pz, rx, ry, rz)
    return CFrame.new(px, py, pz) * CFrame.fromOrientation(rad(rx), rad(ry), rad(rz))
end
local function K(t, keys)
    if t <= keys[1][1] then return keys[1][2] end
    for i = 2, #keys do
        local b = keys[i]
        if t <= b[1] then
            local a = keys[i - 1]
            local x = (t - a[1]) / (b[1] - a[1])
            if b[3] == "out" then
                x = 1 - (1 - x) ^ 3
            elseif b[3] == "linear" then
                x = x
            else
                x = x * x * (3 - 2 * x)
            end
            return a[2] + (b[2] - a[2]) * x
        end
    end
    return keys[#keys][2]
end
local function bump(t, a, b)
    if t <= a or t >= b then return 0 end
    return sin((t - a) / (b - a) * math.pi)
end

-- поза руки с предметом (снята с персонажа DOORS в treat_buddy) — от неё считаем «ко рту»
local HOLD = {
    RightUpperArm = D(0, -0.169, -0.117, 31.8, 15.5, 12.2),
    RightLowerArm = D(0, 0, 0, 37.1, 0, 0),
    RightHand = CFrame.identity,
}
local ARM_JOINTS = { RightUpperArm = "RightShoulder", RightLowerArm = "RightElbow", RightHand = "RightWrist" }

-- сустав: Motor6D / AnimationConstraint (Transform) или Weld (RightGrip, двигаем C0)
local jointBase, jointWritten, weldC0 = {}, {}, {}
local function same(a, b)
    return (a.Position - b.Position).Magnitude < 1e-4
        and (a.XVector - b.XVector).Magnitude < 1e-4 and (a.YVector - b.YVector).Magnitude < 1e-4
end
local function readBase(j)
    if j:IsA("Weld") then return CFrame.identity end
    local cur = j.Transform
    -- игра записала свою позу этого кадра — берём её; не записала — держим прошлую игровую
    if not jointWritten[j] or not same(cur, jointWritten[j]) then jointBase[j] = cur end
    return jointBase[j] or cur
end
local function writeJoint(j, cf)
    if j:IsA("Weld") then
        weldC0[j] = weldC0[j] or j.C0
        j.C0 = weldC0[j] * cf
    else
        j.Transform = cf
        jointWritten[j] = cf
    end
end
local function releaseJoint(j)
    pcall(function()
        if j:IsA("Weld") then
            if weldC0[j] then j.C0 = weldC0[j] end
        elseif jointWritten[j] then
            j.Transform = jointBase[j] or CFrame.identity
        end
    end)
    weldC0[j], jointWritten[j], jointBase[j] = nil, nil, nil
end
local function jointC0(j)
    if j:IsA("AnimationConstraint") then return j.Attachment0 and j.Attachment0.CFrame or CFrame.identity end
    if j:IsA("Weld") then return weldC0[j] or j.C0 end
    return j.C0
end
local function jointC1(j)
    if j:IsA("AnimationConstraint") then return j.Attachment1 and j.Attachment1.CFrame or CFrame.identity end
    return j.C1
end
local function jointPart0(j)
    if j:IsA("AnimationConstraint") then return j.Attachment0 and j.Attachment0.Parent end
    return j.Part0
end

local function findArm(char)
    local out = {}
    for partName, jointName in pairs(ARM_JOINTS) do
        local p = char:FindFirstChild(partName)
        local j = p and p:FindFirstChild(jointName)
        if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then out[partName] = j end
    end
    return out
end

-- сустав, которым Handle ключа держится в руке
local function findGrip(char, handle, tool)
    local function fromBody(p) return p and not p:IsDescendantOf(tool) and p:IsDescendantOf(char) end
    local weld
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") and d.Part1 == handle and fromBody(d.Part0) then return d end
        if d:IsA("AnimationConstraint") and d.Attachment1 and d.Attachment1.Parent == handle
            and fromBody(d.Attachment0 and d.Attachment0.Parent) then return d end
        if d:IsA("Weld") and d.Part1 == handle and fromBody(d.Part0) then weld = d end
    end
    return weld
end

-- Transform для Handle: повернуть трость вокруг её центра на angle (ось — в мире)
-- и сдвинуть на offset (в мире). M — оси сустава при игровой позе.
local function gripMove(g, base, angle, axisWorld, offsetWorld)
    local p0 = jointPart0(g)
    if not p0 then return base end
    local M = p0.CFrame * jointC0(g) * base
    local c = jointC1(g):Inverse().Position -- центр Handle в осях сустава
    local axis = M:VectorToObjectSpace(axisWorld)
    local o = offsetWorld and M:VectorToObjectSpace(offsetWorld) or Vector3.zero
    return base * CFrame.new(o + c) * CFrame.fromAxisAngle(axis, angle) * CFrame.new(-c)
end

local CANE_ANIMS = {}

-- Поза Handle в мире -> Transform его сустава (абсолютно, игровую позу Handle перекрываем)
local function gripTransformFor(g, H)
    local p0 = jointPart0(g)
    if not p0 then return nil end
    return (p0.CFrame * jointC0(g)):Inverse() * H * jointC1(g)
end
-- где Handle был бы при игровой позе
local function handleNatural(g, base)
    local p0 = jointPart0(g)
    return p0.CFrame * jointC0(g) * base * jointC1(g):Inverse()
end

-- покрутить (как осмотр в Rivals, разобрано по кадрам 20 fps):
--   0.0–0.3  рука поднимается к центру экрана, предплечье почти вертикально
--   0.25–1.25 трость встаёт вверх и быстро крутится по часовой ~2 оборота, рука при этом
--            наклоняется вправо; останавливается крючком вверх, стержень свисает влево-вниз
--   1.25–3.0 держим и показываем (лёгкое покачивание), в конце трость чуть отводится назад
--   3.0–3.9  рука уходит вправо-вниз, трость снова крутится ~2 оборота и встаёт как была
--   до 4.4   рука возвращается в обычную позу
local SHOW_TILT = math.rad(28)
CANE_ANIMS.spin = {
    length = 4.4,
    sounds = { { 0.3, "whoosh" }, { 0.75, "whoosh" }, { 3.05, "whoosh" }, { 3.45, "whoosh" } },
    pose = function(t, st)
        local A = CONFIG.CANE_SHOW_ARM
        local up = K(t, { { 0, 0 }, { 0.3, 1, "out" }, { 3.1, 1 }, { 3.6, 0.45 }, { 4.4, 0 } })
        local lean = K(t, { { 0, 0 }, { 0.3, 0.4 }, { 0.8, 1 }, { 1.3, 0 }, { 3.0, 0 }, { 3.35, 1.6 },
            { 3.75, 1.2 }, { 4.4, 0 } })
        local sway = bump(t, 1.2, 3.0)
        local arm = {
            RightUpperArm = D(0, 0, 0, A.RAISE * up + 2 * sway * sin(t * 2.2), A.INWARD * up, A.LEAN * lean),
            RightLowerArm = D(0, 0, 0, A.ELBOW * up, 0, 0),
            RightHand = D(0, 0, 0, 0, 0, 3 * sway * sin(t * 1.7)),
        }
        -- s: 0 — как трость держит игра, 1 — поза показа (крючком вверх к камере)
        local s = K(t, { { 0.22, 0 }, { 0.45, 1 }, { 3.15, 1 }, { 3.9, 0 } })
        -- обороты по часовой (в плоскости экрана); в сумме целые — встаёт ровно как надо
        local spin = K(t, { { 0.25, 0 }, { 1.25, 2 * TAU, "out" } })
            + K(t, { { 3.0, 0 }, { 3.9, 2 * TAU } })
            + K(t, { { 2.4, 0 }, { 3.0, -0.5 }, { 3.3, 0 } }) -- отвод назад перед вторым кручением
        return arm, { custom = function(g, base)
            local info = st.info
            local cam = workspace.CurrentCamera
            local axes = info and info.axes
            if not (cam and axes and jointPart0(g)) then return base end
            local nat = handleNatural(g, base)
            local cf = cam.CFrame
            -- оси трости при показе: «вверх» (к крючку) — вверх-вправо, крючок загибается вправо
            local U = cf.UpVector * math.cos(SHOW_TILT) + cf.RightVector * math.sin(SHOW_TILT)
            local S = cf.RightVector * math.cos(SHOW_TILT) - cf.UpVector * math.sin(SHOW_TILT)
            local disp = CFrame.fromMatrix(Vector3.zero, S, U)
                * CFrame.fromMatrix(Vector3.zero, axes.side, axes.up):Inverse()
            local rot = nat.Rotation:Lerp(disp, s)
            local wobble = math.rad(4) * sway * sin(t * 2.6)
            -- держим за верх: крючок над кулаком, стержень ниже
            local pos = nat.Position - U * (axes.L * 0.22 * s)
            local H = CFrame.new(pos) * CFrame.fromAxisAngle(cf.LookVector, spin + wobble) * rot
            return gripTransformFor(g, H) or base
        end }
    end,
}

-- подбросить: замах вниз, бросок вверх, трость кувыркается два раза и ловится
local TOSS_UP, TOSS_AIR = 0.26, 0.72
CANE_ANIMS.toss = {
    length = 1.3,
    sounds = { { TOSS_UP - 0.02, "whoosh" }, { TOSS_UP + TOSS_AIR, "catch" } },
    pose = function(t, st)
        local arm = {
            RightUpperArm = D(0, 0, 0, K(t, { { 0, 0 }, { 0.16, -10 }, { 0.27, 24, "out" }, { 0.9, 16 },
                { 1.02, -8, "out" }, { 1.3, 0 } }), 0, 0),
            RightLowerArm = D(0, 0, 0, K(t, { { 0, 0 }, { 0.16, 12 }, { 0.27, -14, "out" }, { 0.9, -6 },
                { 1.02, 10, "out" }, { 1.3, 0 } }), 0, 0),
        }
        local x = math.clamp((t - TOSS_UP) / TOSS_AIR, 0, 1)
        local h = 4 * CONFIG.CANE_TOSS_HEIGHT * x * (1 - x)
        local offset = Vector3.yAxis * h + st.fwd * (0.5 * sin(math.pi * x))
        return arm, { angle = 2 * TAU * x, axis = st.right, offset = offset }
    end,
}

-- Еда — в три шага, как открытие замка в DOORS (E нужно держать):
--   eatwait   — начал открывать: рука подносит трость ко рту и ждёт (чуть облизывается)
--   eat       — замок открылся: четыре укуса с хрустом и крошками, рука опускается
--   eatcancel — отпустил E раньше: рука плавно возвращается, трость остаётся целой
local function eatTarget(bite, lick)
    local A = CONFIG.CANE_EAT_ARM
    return {
        RightUpperArm = D(0, 0, 0, A.RAISE + 5 * bite + 2 * lick, A.INWARD, 0) * HOLD.RightUpperArm,
        RightLowerArm = D(0, 0, 0, A.ELBOW + 8 * bite + 3 * lick, 0, 0) * HOLD.RightLowerArm,
        RightHand = D(0, 0, 0, -12 * bite, 0, 0),
    }
end

CANE_ANIMS.eatwait = {
    length = 10, -- дольше не ждём
    absolute = true,
    eat = true,
    pose = function(t, st)
        local lick = math.max(0, sin(t * TAU * 1.6)) * K(t, { { 0.4, 0 }, { 0.7, 1 } })
        return eatTarget(0, lick), nil, K(t, { { 0, st.w0 }, { 0.35, 1 } })
    end,
}

local BITES = { 0.15, 0.55, 0.95, 1.35 }
CANE_ANIMS.eat = {
    length = 1.85,
    absolute = true,
    eat = true,
    pose = function(t, st)
        local bite = 0
        for _, b in ipairs(BITES) do bite = math.max(bite, bump(t, b - 0.08, b + 0.12)) end
        return eatTarget(bite, 0), nil, K(t, { { 0, st.w0 }, { 0.25, 1 }, { 1.45, 1 }, { 1.85, 0 } })
    end,
}

CANE_ANIMS.eatcancel = {
    length = 0.5,
    absolute = true,
    eat = true,
    pose = function(t, st)
        return eatTarget(0, 0), nil, K(t, { { 0, st.w0 }, { 0.5, 0 } })
    end,
}

local function crumbs(pos, color, n)
    for _ = 1, n do
        local c = Instance.new("Part")
        c.Size = Vector3.new(0.07, 0.07, 0.07)
        c.Color = color
        c.Material = Enum.Material.SmoothPlastic
        c.CanCollide, c.CanQuery, c.CanTouch, c.CastShadow = false, false, false, false
        c.Massless = true
        c.CFrame = CFrame.new(pos + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.15)
        c.Parent = root
        c.AssemblyLinearVelocity = Vector3.new((math.random() - 0.5) * 8, 1 + math.random() * 4, (math.random() - 0.5) * 8)
        Debris:AddItem(c, 1.2)
    end
end

-- Копия трости у кисти: настоящая исчезнет вместе с ключом, когда дверь откроется.
-- Живёт через все шаги еды (поднёс -> съел / опустил).
local snack = nil -- { model, parts, hidden, eaten, tool }
local function makeSnack(tool, info, hand)
    local real = info and info.cane
    if not (real and real.Parent and hand) then return end
    local fake = Instance.new("Model")
    fake.Name = "NewYearCaneSnack"
    local sn = { model = fake, parts = {}, hidden = {}, eaten = 0, tool = tool }
    for _, p in ipairs(real:GetChildren()) do
        if p:IsA("BasePart") then
            local c = p:Clone()
            for _, w in ipairs(c:GetChildren()) do
                if w:IsA("JointInstance") then w:Destroy() end
            end
            c.Parent = fake
            weldTo(hand, c, hand.CFrame:ToObjectSpace(p.CFrame))
            table.insert(sn.parts, c)
            table.insert(sn.hidden, { p, p.Transparency })
            p.Transparency = 1
        end
    end
    fake.Parent = root
    -- кусаем с дальнего от кисти конца
    local hp = hand.Position
    table.sort(sn.parts, function(a, b) return (a.Position - hp).Magnitude > (b.Position - hp).Magnitude end)
    snack = sn
end

-- убрать копию; если ключ ещё в руке (дверь не открылась) — вернуть настоящую трость
local function dropSnack()
    local sn = snack
    if not sn then return end
    snack = nil
    pcall(function() sn.model:Destroy() end)
    if sn.tool and sn.tool:IsDescendantOf(game) then
        for _, h in ipairs(sn.hidden) do
            if h[1].Parent then h[1].Transparency = h[2] end
        end
    end
end

local function biteSnack(k)
    playCane("crunch")
    local sn = snack
    if not sn then return end
    local per = math.ceil(#sn.parts / #BITES)
    local last = (k >= #BITES) and #sn.parts or math.min(#sn.parts, sn.eaten + per)
    for i = sn.eaten + 1, last do
        local p = sn.parts[i]
        if p and p.Parent then
            crumbs(p.Position, p.Color, 2)
            p:Destroy()
        end
    end
    sn.eaten = last
end

CANE_ANIMS.eat.tick = function(_, prev, t)
    for k, b in ipairs(BITES) do
        if prev < b and t >= b then biteSnack(k) end
    end
end

local caneAct = nil -- что играет сейчас

-- Игровые звуки ключа во время своих анимаций: глушим то, что игра запустила вместе с
-- анимацией (звук осмотра, щелчки замка), громкость возвращаем, когда звук доиграет.
-- Что заглушили — пишем в workspace/StevieBuddy/cane_sounds_scan.txt
local SOUND_KEEP = { running = true, jumping = true, landing = true, freefalling = true, climbing = true,
    swimming = true, splash = true, gettingup = true, died = true }
local mutedSounds = {} -- [Sound] = громкость
local soundLog = {}
local function muteSound(s, why)
    if mutedSounds[s] or s.Name:find("^NewYearCane_") or s.Name:find("^TreatBuddy_") then return end
    local n = s.Name:lower()
    if SOUND_KEEP[n] or n:find("foot") or n:find("step") then return end
    mutedSounds[s] = s.Volume
    s.Volume = 0
    table.insert(soundLog, ("%s id=%s (%s)"):format(s:GetFullName(), s.SoundId, why))
    task.spawn(function()
        local t0 = os.clock()
        repeat task.wait(0.1) until not s.Parent or os.clock() - t0 > 8 or not (s.IsPlaying or caneAct)
        if mutedSounds[s] then
            pcall(function() s.Volume = mutedSounds[s] end)
            mutedSounds[s] = nil
        end
    end)
end

-- следить за звуками внутри rootInst до момента untilT; filter(s) — какие можно глушить
local function watchSounds(st, rootInst, untilT, filter, already)
    if not rootInst then return end
    local function ok(s)
        return caneAct == st and os.clock() <= untilT and (not filter or filter(s))
    end
    local function hook(s)
        if already and s.IsPlaying and not s.Looped and ok(s) then muteSound(s, st.name .. ", уже играл") end
        table.insert(st.soundConns, s.Played:Connect(function()
            if ok(s) then muteSound(s, st.name) end
        end))
    end
    for _, d in ipairs(rootInst:GetDescendants()) do
        if d:IsA("Sound") then hook(d) end
    end
    table.insert(st.soundConns, rootInst.DescendantAdded:Connect(function(d)
        if not d:IsA("Sound") then return end
        hook(d)
        task.defer(function()
            if d.Parent and d.IsPlaying and ok(d) then muteSound(d, st.name .. ", новый") end
        end)
    end))
end

local lastUnlock = nil -- { door, lock, time } — какой замок открыли
local function nearestLock(char)
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not (rootPart and rooms) then return nil end
    local best, bestD = nil, 12
    for _, room in ipairs(rooms:GetChildren()) do
        local door = room:FindFirstChild("Door")
        local lock = door and door:FindFirstChild("Lock")
        if lock and lock:IsA("BasePart") then
            local d = (lock.Position - rootPart.Position).Magnitude
            if d < bestD then best, bestD = lock, d end
        end
    end
    return best
end

local function muteGameSounds(st)
    if not CONFIG.CANE_MUTE_GAME then return end
    st.soundConns = {}
    local now = os.clock()
    local untilEnd = now + st.anim.length
    -- сам ключ и персонаж — всё время анимации
    watchSounds(st, st.tool, untilEnd, nil, true)
    watchSounds(st, st.char, untilEnd, nil, true)
    -- общие места (звуки интерфейса и 2D-звуки) — только в первые мгновения, когда игра
    -- запускает звук вместе с анимацией (чтобы не заглушить чужое, например монстров)
    local early = now + 0.4
    local function notLooped(s) return not s.Looped end
    watchSounds(st, workspace.CurrentCamera, early, notLooped)
    watchSounds(st, game:GetService("SoundService"), early, notLooped)
    watchSounds(st, player:FindFirstChild("PlayerGui"), early, notLooped)
    if st.anim.eat then
        -- замок двери: щелчки ключа и замка; звук открытия самой двери оставляем
        local lock = lastUnlock and now - lastUnlock.time < 3 and lastUnlock.lock or nearestLock(st.char)
        if lock then
            watchSounds(st, lock, untilEnd, nil, true)
            local door = lock.Parent
            if door then
                watchSounds(st, door, untilEnd, function(s)
                    return s.Name == "Unlock" or s:IsDescendantOf(lock)
                end, true)
            end
        end
    end
end

local function finishCane(keepSnack)
    local st = caneAct
    if not st then return end
    caneAct = nil
    for _, c in ipairs(st.soundConns or {}) do c:Disconnect() end
    if CONFIG.SCAN and #soundLog > 0 then
        local text = "Заглушённые игровые звуки во время анимаций трости:\n" .. table.concat(soundLog, "\n")
        pcall(function()
            if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
            writefile("StevieBuddy/cane_sounds_scan.txt", text)
        end)
    end
    for _, j in pairs(st.arm) do releaseJoint(j) end
    if st.grip then releaseJoint(st.grip) end
    if not keepSnack then dropSnack() end
end

local function startCane(name, tool, info)
    local char = player.Character
    local anim = CANE_ANIMS[name]
    info = info or caneTools[tool]
    if not (char and info and anim) then return end
    local w0 = 0
    if caneAct then
        local prev = caneAct
        if prev.name == "eat" then return end         -- доедаем до конца
        if prev.anim.eat and not anim.eat then return end -- ПКМ во время еды не мешает
        if anim.eat and prev.anim.eat then w0 = prev.lastW or 0 end
        finishCane(anim.eat and prev.anim.eat)
    end
    local cam = workspace.CurrentCamera
    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
    local flat = Vector3.new(look.X, 0, look.Z)
    local st = {
        name = name, anim = anim, start = os.clock(), tool = tool, char = char, info = info,
        arm = findArm(char), lastT = -1, zero = {}, w0 = w0,
        look = look, right = cam and cam.CFrame.RightVector or Vector3.xAxis,
        fwd = flat.Magnitude > 1e-3 and flat.Unit or Vector3.zero,
    }
    if anim.eat then
        if name == "eat" then info.eaten = true end
        if not snack and name ~= "eatcancel" then
            makeSnack(tool, info, char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
        end
    else
        st.grip = findGrip(char, info.handle, tool)
        st.needEquipped = true
    end
    caneAct = st
    pcall(muteGameSounds, st)
end

connect(RunService.Stepped, function()
    local st = caneAct
    if not st then return end
    local t = os.clock() - st.start
    local anim = st.anim
    if t >= anim.length or player.Character ~= st.char
        or (st.needEquipped and st.tool.Parent ~= st.char) then
        finishCane()
        return
    end
    if st.name == "eatwait" then
        if not st.tool:IsDescendantOf(game) then
            startCane("eat", st.tool, st.info) -- ключ пропал — значит, дверь открылась
            return
        elseif st.tool.Parent ~= st.char then
            startCane("eatcancel", st.tool, st.info)
            return
        end
    end
    -- игровые анимации, которые мы заменили, держим невидимыми (но не останавливаем)
    for track in pairs(st.zero) do
        if track.IsPlaying and track.WeightTarget > 0.01 then pcall(track.AdjustWeight, track, 0.0001, 0) end
    end
    for _, e in ipairs(anim.sounds or {}) do
        if st.lastT < e[1] and t >= e[1] then playCane(e[2]) end
    end
    if anim.tick then anim.tick(st, st.lastT, t) end
    st.lastT = t

    local arm, grip, w = anim.pose(t, st)
    st.lastW = w
    for name, j in pairs(st.arm) do
        if j.Parent then
            local base = readBase(j)
            local cf
            if anim.absolute then
                cf = base:Lerp(arm[name] or base, w)
            else
                cf = arm[name] and arm[name] * base or base
            end
            writeJoint(j, cf)
        end
    end
    local g = st.grip
    if grip and g and g.Parent then
        local base = readBase(g)
        if grip.custom then
            writeJoint(g, grip.custom(g, base))
        else
            writeJoint(g, gripMove(g, base, grip.angle, grip.axis, grip.offset))
        end
    end
end)

local function heldCane()
    local char = player.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and caneTools[t] then return t end
    end
    return nil
end

local rmbIndex, lastRmb = 0, 0
local function pressRmb(tool)
    if not CONFIG.CANE_ANIMS or caneAct then return end
    local now = os.clock()
    if now - lastRmb < 0.35 then return end
    lastRmb = now
    local order = CONFIG.CANE_RMB_ORDER
    rmbIndex = rmbIndex % #order + 1
    startCane(CANE_ANIMS[order[rmbIndex]] and order[rmbIndex] or "spin", tool)
end

-- Замок: начал держать E -> к губам; открылся -> съесть; отпустил -> опустить
local lastTriggered = 0
local function onUnlockBegin(tool)
    if not (CONFIG.CANE_EAT and tool) then return end
    local info = caneTools[tool]
    if not info or info.eaten then return end
    if caneAct and caneAct.anim.eat then return end
    startCane("eatwait", tool, info)
end
local function onUnlockDone(tool)
    if not CONFIG.CANE_EAT then return end
    if caneAct and caneAct.name == "eat" then return end
    local waiting = caneAct and caneAct.name == "eatwait" and caneAct or nil
    tool = tool or (waiting and waiting.tool)
    if not tool then return end
    local info = caneTools[tool] or (waiting and waiting.info)
    if not info or info.eaten then return end
    startCane("eat", tool, info)
end
local function onUnlockCancel()
    local st = caneAct
    if st and st.name == "eatwait" then startCane("eatcancel", st.tool, st.info) end
end

-- имя игровой анимации ключа (по папке Animations в инструменте)
local function keyAnimName(tool, track)
    local folder = tool and tool:FindFirstChild("Animations")
    local anim = track.Animation
    if not (folder and anim) then return nil end
    for _, a in ipairs(folder:GetChildren()) do
        if a:IsA("Animation") and a.AnimationId == anim.AnimationId then return a.Name:lower() end
    end
    return nil
end

local EAT_TRACKS = { use = true, usefinish = true, usebreak = true }
local watchedAnimators = setmetatable({}, { __mode = "k" })
local function watchAnimator(animator)
    if watchedAnimators[animator] then return end
    watchedAnimators[animator] = true
    connect(animator.AnimationPlayed, function(track)
        local tool = heldCane()
        local name = tool and keyAnimName(tool, track)
        if not name then return end
        if name == "inspect" and CONFIG.CANE_ANIMS then
            pcall(track.AdjustWeight, track, 0.0001, 0)
            pressRmb(tool)
            if caneAct then caneAct.zero[track] = true end
        elseif EAT_TRACKS[name] and CONFIG.CANE_EAT then
            if name == "use" then
                onUnlockBegin(tool)
            elseif name == "usefinish" then
                onUnlockDone(tool)
            else
                onUnlockCancel()
            end
            if caneAct and caneAct.anim.eat then
                pcall(track.AdjustWeight, track, 0.0001, 0)
                caneAct.zero[track] = true
            end
        end
    end)
end

local function watchCharAnims(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Animator") then watchAnimator(d) end
    end
    connect(char.DescendantAdded, function(d)
        if d:IsA("Animator") then watchAnimator(d) end
    end)
end

local okCaneAnim, errCaneAnim = pcall(function()
    if not (CONFIG.CANDY_KEY and (CONFIG.CANE_ANIMS or CONFIG.CANE_EAT)) then return end
    -- ПКМ — напрямую (если игра на ПКМ с ключом ничего не запускает)
    connect(UserInputService.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if UserInputService:GetFocusedTextBox() then return end
        local tool = heldCane()
        if tool then pressRmb(tool) end
    end)
    -- подсказка замка «держи E» (на случай, если анимации называются иначе)
    local function isUnlock(prompt, who)
        if who ~= player or prompt.Name ~= "UnlockPrompt" then return false end
        local lock = prompt.Parent
        if lock and lock:IsA("BasePart") then lastUnlock = { lock = lock, time = os.clock() } end
        return true
    end
    connect(ProximityPromptService.PromptButtonHoldBegan, function(prompt, who)
        if isUnlock(prompt, who) then onUnlockBegin(heldCane()) end
    end)
    connect(ProximityPromptService.PromptTriggered, function(prompt, who)
        if not isUnlock(prompt, who) then return end
        lastTriggered = os.clock()
        onUnlockDone(heldCane())
    end)
    connect(ProximityPromptService.PromptButtonHoldEnded, function(prompt, who)
        if who ~= player or prompt.Name ~= "UnlockPrompt" then return end
        -- после удачного открытия тоже приходит «отпустил» — проверяем, что открытия не было
        task.delay(0.25, function()
            if os.clock() - lastTriggered > 0.5 then onUnlockCancel() end
        end)
    end)
    if player.Character then watchCharAnims(player.Character) end
    connect(player.CharacterAdded, function(char)
        finishCane()
        watchCharAnims(char)
    end)
end)
report("CaneAnims", okCaneAnim, errCaneAnim)

onCaneTool = function(tool, handle, cane)
    local info = caneTools[tool]
    if not info then
        info = { icon = tool.TextureId }
        caneTools[tool] = info
    end
    info.handle, info.cane, info.axes = handle, cane, caneAxes[handle]
    if CONFIG.CANE_ICON and caneIcon and tool.TextureId ~= caneIcon then tool.TextureId = caneIcon end
end
-- трости, которые появились раньше этого места (ключ уже был в руке при запуске)
for key, cane in pairs(caneFor) do
    local tool = key:FindFirstAncestorWhichIsA("Tool")
    if tool then pcall(onCaneTool, tool, key, cane) end
end

cleanupCane = function()
    caneAlive = false
    finishCane()
    for s, vol in pairs(mutedSounds) do
        pcall(function() s.Volume = vol end)
    end
    for tool, info in pairs(caneTools) do
        if tool.Parent and caneIcon and tool.TextureId == caneIcon then
            pcall(function() tool.TextureId = info.icon end)
        end
    end
    for img, old in pairs(iconPatched) do
        if img.Parent and img.Image == caneIcon then pcall(function() img.Image = old end) end
    end
    for vf, p in pairs(viewPatched) do
        if vf.Parent then vf.ImageTransparency = p.transp end
        pcall(function() p.overlay:Destroy() end)
    end
end
end

---------------------------------------------------------------- снег на мебели и иней на окнах

-- Свойства, которые меняем у деталей игры (окна) — при выключении вернём как было
local restoreProps = {}
local function setLocal(inst, prop, value)
    table.insert(restoreProps, { inst, prop, inst[prop] })
    inst[prop] = value
end

local FURNITURE_WORDS = { "dresser", "bookcase", "bookshelf", "shelf", "desk", "table",
    "cabinet", "wardrobe", "nightstand", "drawer", "fireplace", "counter", "piano" }
local FURNITURE_SKIP = { "bell", "lamp", "light", "chandelier", "candle", "paper", "book_" }
local function isFurniture(m)
    if not m:IsA("Model") then return false end
    local n = m.Name:lower()
    for _, w in ipairs(FURNITURE_SKIP) do if n:find(w, 1, true) then return false end end
    for _, w in ipairs(FURNITURE_WORDS) do if n:find(w, 1, true) then return true end end
    return false
end

local SNOW_COLOR = Color3.fromRGB(246, 249, 255)
local function snowOn(model, folder)
    local cf, size = model:GetBoundingBox()
    -- верх модели должен смотреть вверх, иначе снег ляжет боком
    if cf.UpVector.Y < 0.9 then
        if cf.UpVector.Y < -0.9 then cf = cf * CFrame.Angles(math.pi, 0, 0) else return end
    end
    if size.Y < 1.2 or size.X < 0.8 or size.Z < 0.8 then return end
    local top = cf * CFrame.new(0, size.Y / 2, 0)
    local function slab(sx, sy, sz, ox, oz, lift)
        local p = decorPart({
            Name = "Snow", Size = Vector3.new(sx, sy, sz),
            Material = Enum.Material.Snow, Color = SNOW_COLOR,
            CFrame = top * CFrame.new(ox, lift + sy / 2, oz),
        })
        p.Parent = folder
    end
    slab(size.X * 0.94, 0.12, size.Z * 0.94, 0, 0, 0)
    -- пара сугробиков сверху, чтобы снег был неровный
    for _ = 1, 2 do
        slab(size.X * (0.25 + math.random() * 0.3), 0.08, size.Z * (0.35 + math.random() * 0.3),
            (math.random() - 0.5) * size.X * 0.4, (math.random() - 0.5) * size.Z * 0.3, 0.1)
    end
    snowCount += 1
end

-- окно = плоское стекло (или деталь с Window/Glass в имени)
local function isWindowPane(p)
    if not p:IsA("BasePart") then return false end
    local n = p.Name:lower()
    local s = p.Size
    local thin = math.min(s.X, s.Y, s.Z)
    local big = { s.X, s.Y, s.Z }
    table.sort(big)
    local flat = thin < 0.5 and big[2] > 1.2 and big[3] > 1.2
    if not flat then return false end
    return p.Material == Enum.Material.Glass or n:find("window", 1, true) or n:find("glass", 1, true)
end

local frosted = {}
-- для инея годится и «толстое» стекло: разбитое окно — меш с торчащими осколками, он толще 0.5
local function isGlassLoose(p)
    if not p:IsA("BasePart") or p.Transparency >= 0.98 then return false end
    if isWindowPane(p) then return true end
    local s = p.Size
    local big = { s.X, s.Y, s.Z }
    table.sort(big)
    if not (big[1] < 1.5 and big[2] > 1.2 and big[3] > 1.2) then return false end
    local n = p.Name:lower()
    return p.Material == Enum.Material.Glass or n:find("glass", 1, true) or n:find("window", 1, true)
        or n:find("shatter", 1, true) or n:find("broken", 1, true) or n:find("pane", 1, true)
end

local function frostWindow(p)
    if frosted[p] then return end
    frosted[p] = true
    setLocal(p, "Material", Enum.Material.Ice)
    setLocal(p, "Color", Color3.fromRGB(225, 240, 255))
    setLocal(p, "Transparency", math.clamp(p.Transparency, 0.15, 0.35))
    setLocal(p, "Reflectance", 0.15)
    frostCount += 1
end

local winterDone = {}
local function winterRoom(room)
    if winterDone[room] or not room:IsA("Model") then return end
    winterDone[room] = true
    local folder = roomFolder(room)
    local snowed = {}
    local function try(d)
        if CONFIG.SNOW_FURNITURE and isFurniture(d) and not snowed[d] then
            -- мебель внутри уже засыпанной мебели не трогаем
            for m in pairs(snowed) do if d:IsDescendantOf(m) then return end end
            snowed[d] = true
            task.delay(0.5, function()
                if d.Parent then
                    local ok, err = pcall(snowOn, d, folder)
                    if not ok then warn("[NewYear] Снег на " .. d.Name .. ": " .. tostring(err)) end
                end
            end)
        elseif CONFIG.FROST_WINDOWS and isGlassLoose(d) then
            pcall(frostWindow, d)
        end
    end
    for _, d in ipairs(room:GetDescendants()) do try(d) end
    connect(room.DescendantAdded, try)
end

local okWinter, errWinter = pcall(function()
    if not (CONFIG.SNOW_FURNITURE or CONFIG.FROST_WINDOWS) then return end
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do winterRoom(room) end
        connect(rooms.ChildAdded, function(room) task.delay(0.5, winterRoom, room) end)
    end)
end)
report("Winter", okWinter, errWinter)

---------------------------------------------------------------- книжные шкафы и гардеробы

-- Книжные шкафы (Bookcase): убираем книги, паутину и всё лишнее, перекрашиваем в новогодние
-- цвета, на полки — подарки, трости, ёлочные шарики, по верху спереди — гирлянда.
-- Гардеробы (Wardrobe): перекрашиваем, спереди гирлянда и венок, сверху подарки.
-- Из чего они сделаны — пишем в workspace/StevieBuddy/shelf_scan.txt (чтобы доработать).
do
    local SHELF_WORDS = { "bookcase", "bookshelf", "shelf" }
    local WARDROBE_WORDS = { "wardrobe", "closet" }
    local done = setmetatable({}, { __mode = "k" })
    local logged = { shelf = 0, wardrobe = 0 }
    local scanLog = {}
    local lightIndex = 0

    local function nameHas(inst, words)
        local n = inst.Name:lower()
        for _, w in ipairs(words) do
            if n:find(w, 1, true) then return true end
        end
        return false
    end
    local function kindOf(m)
        if not m:IsA("Model") or m:IsDescendantOf(root) then return nil end
        -- завал в начале погони Сика: падают шкафы, стопки книг, диваны, стол
        if m.Name:sub(1, 15) == "LiveObstruction" then return "falling" end
        if nameHas(m, WARDROBE_WORDS) then return "wardrobe" end
        if nameHas(m, SHELF_WORDS) then return "shelf" end
        return nil
    end

    local function dump(model, kind, note)
        if not CONFIG.SCAN then return end
        if logged[kind] >= 2 then return end
        logged[kind] += 1
        local lines = { ("%s: %s, %s"):format(kind == "shelf" and "Шкаф" or "Гардероб", model:GetFullName(), note) }
        for _, d in ipairs(model:GetDescendants()) do
            if #lines > 160 then break end
            local extra = ""
            if d:IsA("BasePart") then
                extra = (" size=%.2f,%.2f,%.2f transp=%.2f query=%s material=%s color=%d,%d,%d"):format(
                    d.Size.X, d.Size.Y, d.Size.Z, d.Transparency, tostring(d.CanQuery), d.Material.Name,
                    d.Color.R * 255, d.Color.G * 255, d.Color.B * 255)
                if d:IsA("MeshPart") then extra = extra .. " mesh=" .. d.MeshId end
            elseif d:IsA("Decal") or d:IsA("Texture") then
                extra = " texture=" .. d.Texture .. " face=" .. d.Face.Name
            end
            table.insert(lines, "  " .. d:GetFullName():sub(#model:GetFullName() + 2) .. " [" .. d.ClassName .. "]" .. extra)
        end
        table.insert(scanLog, table.concat(lines, "\n"))
        pcall(function()
            if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
            writefile("StevieBuddy/shelf_scan.txt", table.concat(scanLog, "\n\n"))
        end)
    end

    local function hideModelPart(d)
        if d:IsA("BasePart") and d.Transparency < 1 then
            keepHidden(d, "Transparency", 1)
            shelfHidden += 1
        elseif (d:IsA("Decal") or d:IsA("Texture")) and d.Transparency < 1 then
            keepHidden(d, "Transparency", 1)
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("SurfaceGui") then
            keepHidden(d, "Enabled", false)
        end
    end

    ---------------------------------------------------------------- цвета

    local FC = CONFIG.FURNITURE_COLORS
    local function paint(part, style)
        local c = FC[style]
        if not c or part.Transparency >= 0.99 then return end
        setLocal(part, "Color", c)
        if style == "gold" then
            setLocal(part, "Material", Enum.Material.Metal)
            setLocal(part, "Reflectance", 0.15)
        else
            setLocal(part, "Material", Enum.Material.SmoothPlastic)
        end
        if part:IsA("MeshPart") and part.TextureID ~= "" then setLocal(part, "TextureID", "") end
        for _, s in ipairs(part:GetChildren()) do
            if s:IsA("SurfaceAppearance") then setLocal(s, "Parent", nil) end
        end
    end

    -- шкаф: Darker — внешняя рама и верх, Lighter — боковины, Shelves — полки
    local BOOKCASE_STYLE = { Darker = "trim", Lighter = "body", Shelves = "shelf" }
    local function paintFurniture(model, kind)
        if not CONFIG.FURNITURE_PAINT then return end
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.99 then
                local style = BOOKCASE_STYLE[p.Name]
                if not style then
                    local n = p.Name:lower()
                    local big = math.max(p.Size.X, p.Size.Y, p.Size.Z)
                    if big < 0.8 then
                        style = "gold" -- ручки, петли, мелкие детали
                    elseif n:find("door", 1, true) then
                        style = "trim"
                    else
                        style = "body"
                    end
                end
                paint(p, style)
            end
        end
    end

    ---------------------------------------------------------------- где перед

    -- перед мебели — сторона без стены (стену ищем лучами из центра по оси глубины)
    local function frontSign(model, cf, depthLocal, depthHalf, room)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { model, root, player.Character }
        local c = cf.Position
        local dW = cf:VectorToWorldSpace(depthLocal)
        local hp = workspace:Raycast(c, dW * (depthHalf + 2), params)
        local hn = workspace:Raycast(c, -dW * (depthHalf + 2), params)
        if hp and not hn then return -1 end
        if hn and not hp then return 1 end
        if hp and hn then return hp.Distance > hn.Distance and 1 or -1 end
        local ok, rcf = pcall(room.GetBoundingBox, room)
        if ok then return (rcf.Position - c):Dot(dW) >= 0 and 1 or -1 end
        return 1
    end

    -- бантик-крепление: два красных ушка и узелок
    local BOW_RED = Color3.fromRGB(190, 25, 35)
    local function addBow(folder, pos, along)
        for _, s in ipairs({ -1, 1 }) do
            local ear = decorPart({
                Name = "GarlandBow", Shape = Enum.PartType.Ball, Size = Vector3.new(0.14, 0.14, 0.14),
                Color = BOW_RED, Material = Enum.Material.SmoothPlastic,
                CFrame = CFrame.new(pos + along * (0.09 * s) + Vector3.new(0, 0.02, 0)),
            })
            ear.Parent = folder
        end
        local knot = decorPart({
            Name = "GarlandBow", Shape = Enum.PartType.Ball, Size = Vector3.new(0.1, 0.1, 0.1),
            Color = BOW_RED, Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(pos),
        })
        knot.Parent = folder
    end

    -- Гирлянда по точкам крепления (pins): провод прямо у поверхности и провисает между ними,
    -- лампочки висят на проводе и отклонены наружу (outW), на креплениях — бантики
    local function pinGarland(folder, pins, longW, outW, sag)
        local rot = CFrame.fromMatrix(Vector3.zero, longW, Vector3.yAxis)
        local real = CONFIG.GARLAND_STYLE == "real" and loadFestive("HolidayLight") ~= nil
        local step = real and 0.6 or 0.4
        local wire = {}
        for k = 1, #pins - 1 do
            local a, b = pins[k], pins[k + 1]
            local n = math.max(3, math.floor((b - a).Magnitude / step))
            for j = (k == 1 and 0 or 1), n do
                local u = j / n
                local p = a:Lerp(b, u) - Vector3.new(0, sag * math.sin(u * math.pi), 0)
                table.insert(wire, p)
                if j > 0 and j < n then
                    lightIndex += 1
                    if real then
                        addHolidayLight(folder, p, rot, lightIndex, 5, outW)
                    else
                        addBulb(folder, CFrame.new(p - Vector3.new(0, CONFIG.BULB_SIZE * 0.35, 0) + outW * 0.2),
                            CONFIG.BULB_SIZE * 0.8, lightIndex, 6, 4)
                    end
                end
            end
        end
        addWire(folder, wire, real and 0.06 or 0.045, real and REAL_WIRE_COLOR or nil)
        for _, pin in ipairs(pins) do addBow(folder, pin + outW * 0.03, longW) end
    end

    -- Крепления по верхней арке, посчитаны по мешам (лучом по треугольникам модели):
    -- точки в осях опорной детали при её родном размере, перед — по -Z.
    -- Шкаф: опора Lighter (5.163 x 9.081 x 2.376), арка поднимается от углов к середине.
    local BOOKCASE_PINS = {
        ref = "Lighter", size = Vector3.new(5.163, 9.081, 2.376),
        pins = { { -2.85, 3.89, -1.43 }, { -1.5, 4.50, -1.43 }, { 0, 5.00, -1.43 },
            { 1.5, 4.50, -1.43 }, { 2.85, 3.89, -1.43 } },
    }
    -- Гардероб: опора Main (5.96 x 8.789 x 2.349), фронтон над дверцами
    local WARDROBE_PINS = {
        ref = "Main", size = Vector3.new(5.96, 8.789, 2.349),
        pins = { { -2.95, 3.94, -1.35 }, { -1.45, 4.33, -1.35 }, { 0, 4.62, -1.35 },
            { 1.45, 4.33, -1.35 }, { 2.95, 3.94, -1.35 } },
    }
    local function archPins(model, spec)
        local ref = model:FindFirstChild(spec.ref)
        if not (ref and ref:IsA("BasePart")) then return nil end
        local k = ref.Size / spec.size -- если мебель увеличена/уменьшена
        local pins = {}
        for _, p in ipairs(spec.pins) do
            table.insert(pins, ref.CFrame:PointToWorldSpace(Vector3.new(p[1] * k.X, p[2] * k.Y, p[3] * k.Z)))
        end
        return pins, ref.CFrame.XVector, -ref.CFrame.ZVector
    end

    -- Неизвестная мебель: крепления ищем лучом спереди по видимым деталям
    local function edgeGarland(folder, model, cf, size, long, deep, fs, yLocal, scallops, sag)
        local visibleParts = {}
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.9 then table.insert(visibleParts, d) end
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = visibleParts
        local W, Dp = math.abs(size:Dot(long)), math.abs(size:Dot(deep))
        local inward = cf:VectorToWorldSpace(-deep * fs)
        local pins = {}
        for k = 0, scallops do
            local u = (-W / 2 + 0.2) + (W - 0.4) * k / scallops
            local base = long * u + Vector3.new(0, yLocal, 0)
            local from = cf:PointToWorldSpace(base + deep * fs * (Dp / 2 + 1))
            local hit = workspace:Raycast(from, inward * (Dp + 2), params)
            pins[k + 1] = hit and (hit.Position - inward * 0.04)
                or cf:PointToWorldSpace(base + deep * fs * (Dp / 2 + 0.04))
        end
        pinGarland(folder, pins, cf:VectorToWorldSpace(long), -inward, sag)
    end

    ---------------------------------------------------------------- вещи на полки

    local function placePresent(folder, pos, longW, scale)
        local present = CONFIG.REAL_PRESENTS and loadFestive("Present")
        local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
        local yaw = CFrame.lookAt(Vector3.zero, longW) * CFrame.Angles(0, math.rad(math.random(-25, 25)), 0)
        local ps = scale or (0.24 + math.random() * 0.06)
        if present then
            local box = festiveItem(present, "Box")
            local h = box and box.size[2] * ps or 0.4
            local model = spawnFestive(present, CFrame.new(pos + Vector3.new(0, h / 2, 0)) * yaw, {
                scale = ps,
                colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon },
            })
            model.Parent = folder
            return h
        end
        local size = Vector3.new(0.45, 0.36, 0.45) * (ps / 0.25)
        addGift(folder, CFrame.new(pos) * yaw, size, style)
        return size.Y
    end

    -- два подарка стопкой
    local function placeStack(folder, pos, longW)
        local h = placePresent(folder, pos, longW, 0.27 + math.random() * 0.03)
        placePresent(folder, pos + Vector3.new(0, h, 0), longW, 0.17 + math.random() * 0.04)
    end

    local function placeCane(folder, pos, longW)
        -- трость лежит на полке вдоль неё, крючок вбок
        local L = 0.9
        local d = math.max(L * 0.1, 0.06)
        local base = Instance.new("Part")
        base.Name = "ShelfCaneBase"
        base.Anchored = true
        base.Transparency = 1
        base.CanCollide, base.CanTouch, base.CanQuery = false, false, false
        base.Size = Vector3.new(0.05, 0.05, 0.05)
        local flip = math.random() < 0.5 and -1 or 1
        base.CFrame = CFrame.fromMatrix(pos + Vector3.new(0, d / 2 + 0.01, 0), longW * flip, Vector3.yAxis)
        base.Parent = folder
        local cane = buildCane(base, CFrame.fromMatrix(Vector3.zero, Vector3.zAxis, Vector3.xAxis), L)
        cane.Parent = folder
    end

    -- кучка ёлочных шариков с золотыми колпачками
    local function placeBalls(folder, pos, longW)
        local side = Vector3.yAxis:Cross(longW).Unit
        local spots = { { -0.17, 0.05, 0.28 }, { 0.15, -0.08, 0.24 }, { 0.0, 0.14, 0.2 } }
        for _, s in ipairs(spots) do
            local r = s[3]
            local c = pos + longW * s[1] + side * s[2] + Vector3.new(0, r / 2, 0)
            local col = ORNAMENT_COLORS[math.random(#ORNAMENT_COLORS)]
            local ball = decorPart({
                Name = "ShelfBall", Shape = Enum.PartType.Ball, Size = Vector3.new(r, r, r),
                Color = col, Material = Enum.Material.SmoothPlastic, Reflectance = 0.3,
                CFrame = CFrame.new(c),
            })
            ball.Parent = folder
            local cap = decorPart({
                Name = "ShelfBallCap", Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(r * 0.18, r * 0.3, r * 0.3),
                Color = Color3.fromRGB(220, 180, 70), Material = Enum.Material.Metal, Reflectance = 0.2,
                CFrame = CFrame.new(c + Vector3.new(0, r / 2, 0)) * CFrame.Angles(0, 0, math.pi / 2),
            })
            cap.Parent = folder
        end
    end

    local ITEMS = {
        { name = "present", w = 0.62, weight = 4, place = placePresent },
        { name = "stack", w = 0.66, weight = 2, place = placeStack },
        { name = "balls", w = 0.6, weight = 3, place = placeBalls },
        { name = "cane", w = 1.0, weight = 2, place = placeCane },
    }
    local function randomItem()
        local total = 0
        for _, it in ipairs(ITEMS) do total += it.weight end
        local r = math.random() * total
        for _, it in ipairs(ITEMS) do
            r -= it.weight
            if r <= 0 then return it end
        end
        return ITEMS[1]
    end

    ---------------------------------------------------------------- полки

    -- коробка (cf, size) в осях ref: минимум и максимум по каждой оси
    local function boxIn(ref, cf, size)
        local mn = Vector3.new(math.huge, math.huge, math.huge)
        local mx = -mn
        for _, sx in ipairs({ -0.5, 0.5 }) do
            for _, sy in ipairs({ -0.5, 0.5 }) do
                for _, sz in ipairs({ -0.5, 0.5 }) do
                    local p = ref:PointToObjectSpace(cf:PointToWorldSpace(size * Vector3.new(sx, sy, sz)))
                    mn, mx = mn:Min(p), mx:Max(p)
                end
            end
        end
        return mn, mx
    end
    local function addLevel(list, v, tol)
        for _, x in ipairs(list) do
            if math.abs(x - v) < tol then return end
        end
        table.insert(list, v)
    end

    -- Шкаф DOORS — цельные меши (Lighter, Shelves, Darker), внутрь лучом не попасть.
    -- Высоты полок берём по книгам (до того, как их спрятать): ряд книг стоит на полке.
    -- У пустых шкафов — высоты, выученные на других (меш полок у всех один), иначе 6 отделений.
    local learnedLevels = {}
    local function shelfLevels(shelves)
        local ref, size = shelves.CFrame, shelves.Size
        local H = size.Y
        local ys, depthSum, depthN = {}, 0, 0
        local alongX = size.X >= size.Z
        for _, m in ipairs(shelves.Parent:GetDescendants()) do
            if m:IsA("Model") and m.Name == "Books" then
                local ok, bcf, bsize = pcall(m.GetBoundingBox, m)
                if ok then
                    local mn, mx = boxIn(ref, bcf, bsize)
                    addLevel(ys, mn.Y, 0.3)
                    addLevel(learnedLevels, (mn.Y + H / 2) / H, 0.03)
                    depthSum += alongX and (mn.Z + mx.Z) / 2 or (mn.X + mx.X) / 2
                    depthN += 1
                end
            end
        end
        for _, f in ipairs(learnedLevels) do addLevel(ys, f * H - H / 2, 0.3) end
        if #ys == 0 then
            for k = 0, 5 do table.insert(ys, -H / 2 + 0.12 + k * H / 6) end
        end
        table.sort(ys)
        return ys, alongX, depthN > 0 and depthSum / depthN or 0
    end

    -- Меши шкафа DOORS (разобраны по файлам моделей). Перед у всех трёх деталей — по -Z.
    local MESH_SHELVES = "6521313985" -- Shelves: 5 досок, верх досок на этих долях высоты
    local SHELF_TOPS = { -0.346, -0.187, -0.029, 0.129, 0.288 }
    local MESH_LIGHTER = "6521313927" -- Lighter (рама): дно нижнего отделения
    local MESH_DARKER = "6521314026"  -- Darker: карниз сверху, передняя планка под ним
    local MESH_WOOD = "6798353062"    -- гардероб Wood: карниз сверху
    local function meshIs(part, id)
        return part and part:IsA("MeshPart") and part.MeshId:find(id, 1, true) ~= nil
    end

    -- полки шкафа: { ref (деталь), y, half (полуширина), z } — всё в осях своей детали
    -- Большие полки (Modular_Bookshelf): одна деталь BookshelfBase 10 x 13 x 3, перед по -Z,
    -- 5 полок по 1.8 высотой (верх досок на этих долях), сверху спереди — рама
    local MESH_MODULAR = "9830845076"
    local MODULAR_TOPS = { -0.341, -0.182, -0.022, 0.137, 0.297 }

    -- Стеллаж в 100-й (Industrial_Shelf*): Shelves — один полупрозрачный меш с 5 досками-сетками,
    -- столкновение коробкой (лучами доски не найти). Высоты прочитаны из самого меша (shelf_recon):
    -- верх досок на этих долях высоты Shelves, доска во всю ширину (±0.4995) и глубину.
    local MESH_INDUSTRIAL = "7859403284"
    local INDUSTRIAL_TOPS = { -0.4968, -0.2470, 0.0029, 0.2498, 0.4997 }

    local function exactLevels(shelf)
        local ind = shelf:FindFirstChild("Shelves")
        if meshIs(ind, MESH_INDUSTRIAL) then
            local s = ind.Size
            local list = {}
            for _, f in ipairs(INDUSTRIAL_TOPS) do
                table.insert(list, { ref = ind, y = f * s.Y + 0.005, half = 0.4995 * s.X - 0.35, z = 0 })
            end
            return list, "industrial"
        end
        local modular = shelf:FindFirstChild("BookshelfBase")
        if meshIs(modular, MESH_MODULAR) then
            local s = modular.Size
            local list = {}
            for _, f in ipairs(MODULAR_TOPS) do
                table.insert(list, { ref = modular, y = f * s.Y, half = 0.423 * s.X - 0.3, z = -0.1 * s.Z })
            end
            return list, "modular"
        end
        local shelves, lighter = shelf:FindFirstChild("Shelves"), shelf:FindFirstChild("Lighter")
        if not meshIs(shelves, MESH_SHELVES) then return nil end
        local s = shelves.Size
        local list = {}
        if meshIs(lighter, MESH_LIGHTER) then
            local l = lighter.Size
            table.insert(list, { ref = lighter, y = -0.482 * l.Y, half = 0.349 * l.X - 0.25, z = -0.12 * l.Z })
        end
        for _, f in ipairs(SHELF_TOPS) do
            -- доска: от переднего края (-0.5) до задней стенки (+0.317); ставим чуть ближе к переду
            table.insert(list, { ref = shelves, y = f * s.Y, half = 0.5 * s.X - 0.3, z = -0.15 * s.Z })
        end
        return list, "bookcase"
    end

    local function decorateBookcase(room, shelf)
        local shelves = shelf:FindFirstChild("Shelves")
        local hasBooks = shelf:FindFirstChild("Books", true) ~= nil
        local exact, exactKind = exactLevels(shelf)
        local levels, alongX, depth
        if not exact and shelves and shelves:IsA("BasePart") then
            levels, alongX, depth = shelfLevels(shelves)
        end
        -- убираем книги и всё, кроме самого шкафа (рама, полки, верх)
        local keep = {}
        for _, p in ipairs(shelf:GetChildren()) do
            if p:IsA("BasePart") and (BOOKCASE_STYLE[p.Name]
                or (p.Size.Y > 3 and not p.Name:lower():find("web", 1, true))) then
                keep[p] = true
            end
        end
        local WEB_WORDS = { "web", "spider", "skull", "skelet", "bone", "jaw" }
        for _, d in ipairs(shelf:GetDescendants()) do
            local hide = false
            local node = d
            if shelves and shelves:IsA("BasePart") then
                -- обычный шкаф (Lighter/Shelves/Darker): прячем всё, кроме самого шкафа
                hide = true
                while node and node ~= shelf do
                    if keep[node] then hide = false break end
                    node = node.Parent
                end
            else
                -- другие полки (например Modular_Bookshelf): устройство неизвестно —
                -- прячем только книги, паутину и кости по названиям
                while node and node ~= shelf and not hide do
                    local n = node.Name:lower()
                    -- книги: «Books», «Book», «Book1»..., но не сами полки («Bookshelf»)
                    if n == "books" or n:match("^book%d*$") or n:find("^books_") then hide = true end
                    for _, w in ipairs(WEB_WORDS) do
                        if n:find(w, 1, true) then hide = true break end
                    end
                    node = node.Parent
                end
            end
            if hide then hideModelPart(d) end
        end
        dump(shelf, "shelf", ("полок %d, книги были: %s"):format(exact and #exact or levels and #levels or 0,
            tostring(hasBooks)))
        paintFurniture(shelf, "shelf")
        local folder = roomFolder(room)

        -- вещи вдоль полки с промежутками, пока влезают
        local function fillShelf(ref, longL, y, half, offset)
            local longW = ref:VectorToWorldSpace(longL)
            local x = -half
            while true do
                local it = randomItem()
                local gap = 0.15 + math.random() * 0.45
                if x + gap + it.w > half then break end
                local u = x + gap + it.w / 2
                local pos = ref:PointToWorldSpace(longL * u + Vector3.new(0, y, 0) + offset)
                local ok, err = pcall(it.place, folder, pos, longW)
                if not ok then warn("[NewYear] Полка: " .. tostring(err)) end
                x = u + it.w / 2
            end
        end

        if exact and exactKind == "industrial" then
            -- перед — сторона без стены; вещи чуть ближе к переду
            local ind = shelf:FindFirstChild("Shelves")
            local fs = frontSign(shelf, ind.CFrame, Vector3.zAxis, ind.Size.Z / 2, room)
            for _, lv in ipairs(exact) do lv.z = fs * 0.12 * ind.Size.Z end
            exact.fs = fs
        end
        if exact then
            for _, lv in ipairs(exact) do
                fillShelf(lv.ref.CFrame, Vector3.xAxis, lv.y, lv.half, Vector3.new(0, 0, lv.z))
            end
            if CONFIG.FURNITURE_GARLAND and exactKind == "modular" then
                -- большие полки: верх ровный — провод по верхней раме спереди
                local base = shelf:FindFirstChild("BookshelfBase")
                local s = base.Size
                local pins = {}
                for k = 0, 4 do
                    local x = (-0.43 + 0.86 * k / 4) * s.X
                    table.insert(pins, base.CFrame:PointToWorldSpace(Vector3.new(x, 0.47 * s.Y, -(0.417 * s.Z + 0.03))))
                end
                pinGarland(folder, pins, base.CFrame.XVector, -base.CFrame.ZVector, 0.3)
            elseif CONFIG.FURNITURE_GARLAND and exactKind == "industrial" then
                -- стеллаж: прямой провод по передней верхней перекладине (она на 0.07 выше верхней доски)
                local ind = shelf:FindFirstChild("Shelves")
                local s, fs = ind.Size, exact.fs or 1
                local pins = {}
                for k = 0, 4 do
                    local x = (-0.5 + k / 4) * (s.X - 0.2)
                    table.insert(pins, ind.CFrame:PointToWorldSpace(Vector3.new(x, INDUSTRIAL_TOPS[5] * s.Y + 0.05,
                        fs * (0.5 * s.Z + 0.06))))
                end
                pinGarland(folder, pins, ind.CFrame.XVector, ind.CFrame.ZVector * fs, 0.3)
            elseif CONFIG.FURNITURE_GARLAND and meshIs(shelf:FindFirstChild("Darker"), MESH_DARKER) then
                -- шкаф: провод по передней арке под карнизом, лампочки наружу
                local pins, longW, outW = archPins(shelf, BOOKCASE_PINS)
                if pins then pinGarland(folder, pins, longW, outW, 0.28) end
            end
            return
        end
        if not levels then return end

        local ref, size = shelves.CFrame, shelves.Size
        local long = alongX and Vector3.xAxis or Vector3.zAxis
        local deep = alongX and Vector3.zAxis or Vector3.xAxis
        local half = (alongX and size.X or size.Z) / 2 - 0.3
        for _, y in ipairs(levels) do
            fillShelf(ref, long, y, half, deep * depth)
        end

        -- гирлянда по верху спереди, прицеплена к краю шкафа
        if CONFIG.FURNITURE_GARLAND then
            local bok, bcf, bsize = pcall(shelf.GetBoundingBox, shelf)
            if bok then
                local blong = bsize.X >= bsize.Z and Vector3.xAxis or Vector3.zAxis
                local bdeep = bsize.X >= bsize.Z and Vector3.zAxis or Vector3.xAxis
                local fs = frontSign(shelf, bcf, bdeep, math.min(bsize.X, bsize.Z) / 2, room)
                edgeGarland(folder, shelf, bcf, bsize, blong, bdeep, fs, bsize.Y / 2 - 1.0, 3, 0.4)
            end
        end
    end

    ---------------------------------------------------------------- гардеробы

    local function decorateWardrobe(room, wardrobe)
        dump(wardrobe, "wardrobe", "")
        paintFurniture(wardrobe, "wardrobe")
        local ok, cf, size = pcall(wardrobe.GetBoundingBox, wardrobe)
        if not ok or size.Y < 3 then return end
        local folder = roomFolder(room)
        local long = size.X >= size.Z and Vector3.xAxis or Vector3.zAxis
        local deep = size.X >= size.Z and Vector3.zAxis or Vector3.xAxis
        local W, Dp = math.max(size.X, size.Z), math.min(size.X, size.Z)
        -- перед — там, где дверцы; если их нет — сторона без стены
        local fs
        local door1 = wardrobe:FindFirstChild("Door1")
        if door1 and door1:IsA("BasePart") then
            fs = (door1.Position - cf.Position):Dot(cf:VectorToWorldSpace(deep)) >= 0 and 1 or -1
        else
            fs = frontSign(wardrobe, cf, deep, Dp / 2, room)
        end
        local longW = cf:VectorToWorldSpace(long)

        -- гирлянда над дверцами, прицеплена к краю гардероба (дверцы её не задевают)
        if CONFIG.FURNITURE_GARLAND then
            local pins, longW, outW
            if meshIs(wardrobe:FindFirstChild("Wood"), MESH_WOOD) then
                pins, longW, outW = archPins(wardrobe, WARDROBE_PINS)
            end
            if pins then
                pinGarland(folder, pins, longW, outW, 0.25)
            else
                edgeGarland(folder, wardrobe, cf, size, long, deep, fs, size.Y / 2 - 1.0, 3, 0.35)
            end
        end
        -- по маленькому венку на каждой дверце — приварены к ней и открываются вместе с дверцей
        if CONFIG.WARDROBE_WREATHS then
            local data = loadFestive("Wreath")
            local main = wardrobe:FindFirstChild("Main")
            if data then
                local ws = 0.2
                local wsize = data.size and fV3(data.size) or Vector3.new(3.9, 4.1, 1.2)
                for _, dn in ipairs({ "Door1", "Door2" }) do
                    local door = wardrobe:FindFirstChild(dn)
                    if door and door:IsA("BasePart") then
                        -- наружу — ось толщины дверцы, в сторону от середины гардероба
                        local z = door.CFrame.ZVector
                        local ref = (main and main:IsA("BasePart")) and main.Position or cf.Position
                        local outW = (door.Position - ref):Dot(z) >= 0 and z or -z
                        local pos = door.Position + door.CFrame.UpVector * (door.Size.Y * 0.2)
                            + outW * (door.Size.Z / 2 + wsize.Z * ws / 2)
                        local model = spawnFestive(data, CFrame.lookAt(pos, pos - outW), { scale = ws, weld = door })
                        model.Parent = folder
                    end
                end
            end
        end
        -- подарки сверху: ставим на крышу (луч сверху), иначе на верх коробки
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = { wardrobe }
        for _, u in ipairs({ -0.28, 0.05, 0.3 }) do
            if math.random() < 0.75 then
                local top = cf:PointToWorldSpace(long * (u * W) + Vector3.new(0, size.Y / 2 + 1, 0))
                local hit = workspace:Raycast(top, Vector3.new(0, -3, 0), params)
                local pos = hit and hit.Position or (top - Vector3.new(0, 1, 0))
                pcall(placePresent, folder, pos, longW, 0.3 + math.random() * 0.1)
            end
        end
        shelfCount += 1
    end

    ---------------------------------------------------------------- падающий шкаф

    -- BookshelfObstruction: внутри деталь AnimatedBookshelf2 — тот же меш, что у больших полок
    -- (10 x 13 x 3, перед по -Z), падает анимацией. Украшения строим в осях шкафа и каждый кадр,
    -- пока он двигается, переносим вместе с ним. Упал и замер — гирлянда разбивается.
    local function breakGarland(folder, at, withFX)
        local popped = 0
        for _, e in ipairs(bulbs) do
            local p = e.part
            if p.Parent and p:IsDescendantOf(folder) and not brokenBulbs[p] then
                brokenBulbs[p] = true
                if e.light then e.light.Enabled = false end
                if e.casing then e.casing.Color = Color3.fromRGB(28, 26, 24) end
                local col = p.Color
                if withFX and popped < 18 and math.random() < 0.5 then
                    -- лампочка лопнула: осколки разлетаются
                    popped += 1
                    p.Transparency = 1
                    for _ = 1, 3 do
                        local sh = decorPart({
                            Name = "Shard", Color = col, Material = Enum.Material.Glass, Transparency = 0.15,
                            Size = Vector3.new(0.05 + math.random() * 0.08, 0.02, 0.05 + math.random() * 0.08),
                            CFrame = p.CFrame * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6),
                        })
                        sh.Anchored, sh.CanCollide, sh.Massless = false, true, false
                        sh.Parent = folder
                        sh.AssemblyLinearVelocity = Vector3.new(math.random() * 8 - 4, 3 + math.random() * 6, math.random() * 8 - 4)
                        sh.AssemblyAngularVelocity = Vector3.new(math.random() * 20 - 10, math.random() * 20 - 10, math.random() * 20 - 10)
                        game:GetService("Debris"):AddItem(sh, 4 + math.random() * 2)
                    end
                else
                    -- погасла и потемнела
                    p.Color = col:Lerp(Color3.fromRGB(55, 52, 50), 0.75)
                    p.Material = Enum.Material.Glass
                    p.Transparency = 0.25
                end
            end
        end
        if not withFX then return end
        -- звуки из самой игры (лампочка в Архивах): хлопок стекла и треск проводки
        local holder = decorPart({ Name = "ShelfBreakSound", Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2),
            CFrame = CFrame.new(at) })
        holder.Parent = folder
        local misc = game:GetService("ReplicatedStorage"):FindFirstChild("Misc")
        local src = misc and misc:FindFirstChild("ArchivesLight")
        for k, e in ipairs({ { "BulbBreak", "rbxassetid://80520348297037", 0 }, { "BulbZap", "rbxassetid://116266785932124", 0.12 } }) do
            task.delay(e[3], function()
                local orig = src and src:FindFirstChild(e[1], true)
                local snd
                if orig and orig:IsA("Sound") then
                    snd = orig:Clone()
                else
                    snd = Instance.new("Sound")
                    snd.SoundId = e[2]
                end
                snd.Name = "NewYear_" .. e[1]
                snd.Looped = false
                snd.Volume = (k == 1 and 1.2 or 0.7) * CONFIG.FALLING_SHELF_VOLUME
                snd.RollOffMaxDistance = 90
                snd.Parent = holder
                snd:Play()
            end)
        end
        game:GetService("Debris"):AddItem(holder, 10)
    end

    -- Украшения едут за деталью, которую двигает анимация: запоминаем их в осях детали и,
    -- когда она сдвинулась, переносим все разом. onStill(cf) — деталь двигалась и замерла.
    local function followAnimated(part, folder, onStill)
        local parts, offs = {}, {}
        local cf0 = part.CFrame
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("BasePart") then
                table.insert(parts, d)
                table.insert(offs, cf0:ToObjectSpace(d.CFrame))
            end
        end
        local last, moving, still = cf0, false, 0
        local conn
        conn = connect(RunService.Heartbeat, function(dt)
            if not (part.Parent and folder.Parent) then conn:Disconnect() return end
            local cf = part.CFrame
            if (cf.Position - last.Position).Magnitude > 1e-3 or cf.UpVector:Dot(last.UpVector) < 0.99999
                or cf.LookVector:Dot(last.LookVector) < 0.99999 then
                last = cf
                local cfs = table.create(#parts)
                for i, o in ipairs(offs) do cfs[i] = cf * o end
                pcall(function() workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged) end)
                moving, still = true, 0
            elseif moving then
                still += dt
                if still > 0.2 then
                    moving = false
                    if onStill then onStill(cf) end
                end
            end
        end)
    end

    -- Стопка книг в завале (AnimatedBookstack*) — вместо неё подарок такого же размера
    -- (на большой стопке иногда ещё маленький сверху). Падает вместе со стопкой.
    local function bookstackPresent(room, stack)
        hideModelPart(stack)
        local folder = Instance.new("Folder")
        folder.Name = "FallingPresent"
        folder.Parent = roomFolder(room)
        local cf, s = stack.CFrame, stack.Size
        local present = CONFIG.REAL_PRESENTS and loadFestive("Present")
        local box = present and festiveItem(present, "Box")
        local unit = box and math.max(box.size[1], box.size[3]) or 1.8 -- ширина подарка при scale = 1
        local foot = math.min(s.X, s.Z) * (0.75 + math.random() * 0.15)
        local scale = math.clamp(foot / unit, 0.15, 2.5)
        local bottom = cf:PointToWorldSpace(Vector3.new(0, -s.Y / 2, 0))
        local h = placePresent(folder, bottom, cf.XVector, scale) or 0.4
        if foot > 2.4 and math.random() < 0.5 then
            placePresent(folder, bottom + Vector3.new(0, h, 0), cf.ZVector, scale * (0.4 + math.random() * 0.15))
        end
        followAnimated(stack, folder)
    end

    -- Подарок отпускаем в свободное падение: детали сварены с коробкой, коробка твёрдая,
    -- скорость — как у точки шкафа, где он стоял. Улёгся — снова закрепляем (и не мешает ходить).
    local function releasePresent(g, prevCF, cf, dt)
        local root, rootOff = g.root, nil
        if not root.Parent then return end
        for i, p in ipairs(g.parts) do
            if p == root then rootOff = g.offs[i] end
        end
        for _, p in ipairs(g.parts) do
            if p ~= root and p.Parent then
                local w = Instance.new("WeldConstraint")
                w.Part0, w.Part1 = root, p
                w.Parent = p
            end
        end
        for _, p in ipairs(g.parts) do
            if p.Parent then
                p.Anchored = false
                p.CanCollide = p == root
                p.Massless = p ~= root
            end
        end
        local v = ((cf * rootOff).Position - (prevCF * rootOff).Position) / math.max(dt, 1 / 120)
        if v.Magnitude > 25 then v = v.Unit * 25 end
        root.AssemblyLinearVelocity = v + Vector3.new(math.random() * 2 - 1, math.random() * 1.5, math.random() * 2 - 1)
        root.AssemblyAngularVelocity = Vector3.new(math.random() * 8 - 4, math.random() * 6 - 3, math.random() * 8 - 4)
        task.spawn(function()
            local calm, t = 0, 0
            while root.Parent and t < 8 do
                task.wait(0.2)
                t += 0.2
                calm = (root.AssemblyLinearVelocity.Magnitude < 0.4 and root.AssemblyAngularVelocity.Magnitude < 0.6)
                    and calm + 1 or 0
                if calm >= 3 then break end
            end
            if not root.Parent then return end
            for _, p in ipairs(g.parts) do
                if p.Parent then
                    p.Anchored = true
                    p.CanCollide = false
                end
            end
        end)
    end

    -- подарки на крыше шкафа: едут с ним, пока он стоит; наклонился на ~20° — слетают и падают
    local function dropFromShelf(shelf, holder)
        local cf0 = shelf.CFrame
        local gifts = {}
        for _, g in ipairs(holder:GetChildren()) do
            local parts, offs, root = {}, {}, nil
            for _, d in ipairs(g:GetDescendants()) do
                if d:IsA("BasePart") then
                    table.insert(parts, d)
                    table.insert(offs, cf0:ToObjectSpace(d.CFrame))
                    if not root or d.Size.Magnitude > root.Size.Magnitude then root = d end
                end
            end
            if root then table.insert(gifts, { parts = parts, offs = offs, root = root }) end
        end
        if #gifts == 0 then return end
        local last = cf0
        local conn
        conn = connect(RunService.Heartbeat, function(dt)
            if not (shelf.Parent and holder.Parent) then conn:Disconnect() return end
            local cf = shelf.CFrame
            if (cf.Position - last.Position).Magnitude < 1e-3 and cf.UpVector:Dot(last.UpVector) > 0.99999
                and cf.LookVector:Dot(last.LookVector) > 0.99999 then
                return
            end
            local all, cfs = {}, {}
            for _, g in ipairs(gifts) do
                for i, p in ipairs(g.parts) do
                    table.insert(all, p)
                    table.insert(cfs, cf * g.offs[i])
                end
            end
            pcall(function() workspace:BulkMoveTo(all, cfs, Enum.BulkMoveMode.FireCFrameChanged) end)
            if cf.UpVector:Dot(cf0.UpVector) < 0.94 then
                conn:Disconnect()
                for _, g in ipairs(gifts) do pcall(releasePresent, g, last, cf, dt) end
            end
            last = cf
        end)
    end

    local function dressFallingShelf(room, shelf)
        local folder = Instance.new("Folder")
        folder.Name = "FallingShelf"
        folder.Parent = roomFolder(room)
        local cf0, s = shelf.CFrame, shelf.Size
        local upright = cf0.UpVector.Y > 0.7 -- ещё стоит (если комната загрузилась, когда он уже лежит, — без подарков)
        local longW = cf0.XVector
        if upright then
            -- на полках — подарки, шарики, трости (как на обычных больших полках)
            for _, f in ipairs(MODULAR_TOPS) do
                local y, half, z = f * s.Y, 0.423 * s.X - 0.3, -0.1 * s.Z
                local x = -half
                while true do
                    local it = randomItem()
                    local gap = 0.15 + math.random() * 0.45
                    if x + gap + it.w > half then break end
                    local u = x + gap + it.w / 2
                    pcall(it.place, folder, cf0:PointToWorldSpace(Vector3.new(u, y, z)), longW)
                    x = u + it.w / 2
                end
            end
            -- подарки на крыше: отдельно — когда шкаф наклонится, они слетают и падают сами
            local roof = Instance.new("Folder")
            roof.Name = "FallingShelfRoof"
            roof.Parent = roomFolder(room)
            for _, u in ipairs({ -0.3, 0.02, 0.28 }) do
                if math.random() < 0.8 then
                    local one = Instance.new("Folder")
                    one.Name = "RoofPresent"
                    one.Parent = roof
                    pcall(placePresent, one, cf0:PointToWorldSpace(Vector3.new(u * s.X, 0.5 * s.Y, 0)), longW,
                        0.32 + math.random() * 0.12)
                end
            end
            dropFromShelf(shelf, roof)
        end
        -- гирлянда по верхней раме спереди
        local pins = {}
        for k = 0, 4 do
            local x = (-0.43 + 0.86 * k / 4) * s.X
            table.insert(pins, cf0:PointToWorldSpace(Vector3.new(x, 0.47 * s.Y, -(0.417 * s.Z + 0.03))))
        end
        pinGarland(folder, pins, longW, -cf0.ZVector, 0.3)
        -- мишура по передним стойкам, сверху вниз волной
        if CONFIG.TINSEL and makeTinsel then
            for _, side in ipairs({ -1, 1 }) do
                local pts = {}
                for k = 0, 10 do
                    local y = (0.45 - 0.9 * k / 10) * s.Y
                    local wob = math.sin(k * 1.3) * 0.1
                    table.insert(pts, cf0:PointToWorldSpace(Vector3.new(side * (0.465 * s.X + wob), y, -(0.47 * s.Z + 0.1))))
                end
                pcall(makeTinsel, folder, pts, nil, CONFIG.TINSEL_WIDTH * 0.6, (CONFIG.TINSEL_DENSITY or 42) * 0.5)
            end
        end

        -- всё созданное едет за шкафом; замер, сильно наклонившись, — упал, гирлянда бьётся
        local broken = not upright
        if broken then breakGarland(folder, cf0.Position, false) end
        followAnimated(shelf, folder, function(cf)
            if not broken and cf.UpVector:Dot(cf0.UpVector) < 0.5 then
                broken = true
                breakGarland(folder, cf.Position, true)
            end
        end)
        shelfCount += 1
    end

    -- BookshelfObstruction (один шкаф) и завал LiveObstruction* (два шкафа, стопки книг, диваны)
    local function decorateFalling(room, model)
        -- книги прячем (вместо них — подарки)
        for _, d in ipairs(model:GetDescendants()) do
            local node = d
            while node and node ~= model do
                local n = node.Name:lower()
                if n == "books" or n:match("^book%d*$") then hideModelPart(d) break end
                node = node.Parent
            end
        end
        for _, d in ipairs(model:GetDescendants()) do
            if meshIs(d, MESH_MODULAR) then
                local ok, err = pcall(dressFallingShelf, room, d)
                if not ok then warn("[NewYear] Падающий шкаф: " .. tostring(err)) end
            elseif d:IsA("BasePart") and d.Name:sub(1, 17) == "AnimatedBookstack" then
                local ok, err = pcall(bookstackPresent, room, d)
                if not ok then warn("[NewYear] Подарок в завале: " .. tostring(err)) end
            end
        end
    end

    ---------------------------------------------------------------- стеллажи (100-я комната)

    -- Металлические стеллажи в 100-й — не книжный шкаф, раньше полки угадывались (6 равных
    -- отделений), поэтому подарки висели или проваливались, а гирлянда цеплялась лучом за стену.
    -- Теперь: полки — тонкие горизонтальные детали во всю ширину; если стеллаж одним мешем —
    -- ищем доски лучами сверху вниз. У деталей стеллажа CanQuery выключен (поэтому и в Dex кликом
    -- выбирается только стена за ним) — на время разметки включаем, потом возвращаем.
    -- Каждую вещь ставим по лучу ровно на доску под ней; гирлянда — прямо по переднему верхнему краю.
    -- strict — только по доскам-деталям (для полок вне 100-й, чтобы не трогать незнакомое).
    local function decorateRack(room, rack, strict)
        local ok, cf, size = pcall(rack.GetBoundingBox, rack)
        if not ok or cf.UpVector.Y < 0.95 then return false end
        local alongX = size.X >= size.Z
        local long = alongX and Vector3.xAxis or Vector3.zAxis
        local deep = alongX and Vector3.zAxis or Vector3.xAxis
        local W, D = math.abs(size:Dot(long)), math.abs(size:Dot(deep))
        if W < 2 or D < 0.6 or size.Y < 2 then return false end
        local parts = {}
        for _, d in ipairs(rack:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.98 then table.insert(parts, d) end
        end
        if #parts == 0 then return false end

        -- уровни: { y = верх доски, lo/hi — края вдоль, dlo/dhi — края в глубину } в осях стеллажа
        local levels = {}
        local function addLvl(y, lo, hi, dlo, dhi)
            for _, l in ipairs(levels) do
                if math.abs(l.y - y) < 0.3 then
                    l.y = math.max(l.y, y)
                    l.lo, l.hi = math.min(l.lo, lo), math.max(l.hi, hi)
                    l.dlo, l.dhi = math.min(l.dlo, dlo), math.max(l.dhi, dhi)
                    l.n += 1
                    return
                end
            end
            table.insert(levels, { y = y, lo = lo, hi = hi, dlo = dlo, dhi = dhi, n = 1 })
        end
        -- 1) доски — отдельные тонкие детали
        for _, p in ipairs(parts) do
            local mn, mx = boxIn(cf, p.CFrame, p.Size)
            local ext = mx - mn
            if ext.Y < 0.6 and math.abs(ext:Dot(long)) > W * 0.45 and math.abs(ext:Dot(deep)) > D * 0.35 then
                addLvl(mx.Y, mn:Dot(long), mx:Dot(long), mn:Dot(deep), mx:Dot(deep))
            end
        end
        if #levels < 2 and strict then return false end

        -- лучи: на время включаем CanQuery у деталей стеллажа
        local saved = {}
        for _, p in ipairs(parts) do
            if not p.CanQuery then
                saved[p] = true
                pcall(function() p.CanQuery = true end)
            end
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = parts
        -- луч вниз из точки (в осях стеллажа); вернёт высоту поверхности в осях стеллажа
        local function surfaceY(l, d, fromY, len)
            local from = cf:PointToWorldSpace(long * l + deep * d + Vector3.new(0, fromY, 0))
            local hit = workspace:Raycast(from, Vector3.new(0, -len, 0), params)
            if hit and hit.Normal.Y > 0.6 then return cf:PointToObjectSpace(hit.Position).Y end
            return nil
        end

        local okWork, err = pcall(function()
            -- 2) досок-деталей нет — стеллаж одним мешем: лучами сверху вниз в 5 столбцах
            if #levels < 2 then
                levels = {}
                local top, bottom = size.Y / 2 + 0.5, -size.Y / 2
                for k = 0, 4 do
                    local l = (-0.38 + 0.76 * k / 4) * W
                    local y = top
                    for _ = 1, 14 do
                        local hy = surfaceY(l, 0, y, y - bottom + 0.05)
                        if not hy then break end
                        addLvl(hy, -W / 2 + 0.25, W / 2 - 0.25, -D / 2 + 0.2, D / 2 - 0.2)
                        y = hy - 0.12
                    end
                end
                -- доска — если её нашли хотя бы в трёх столбцах
                local keep = {}
                for _, l in ipairs(levels) do
                    if l.n >= 3 then table.insert(keep, l) end
                end
                levels = keep
            end
            if #levels < 2 then return end
            table.sort(levels, function(a, b) return a.y < b.y end)

            dump(rack, "shelf", ("стеллаж: полок %d (%s)"):format(#levels, #levels > 0 and "найдены" or "нет"))
            local folder = roomFolder(room)
            local fs = frontSign(rack, cf, deep, D / 2, room)
            local longW = cf:VectorToWorldSpace(long)
            local rackTop = size.Y / 2
            for i, lv in ipairs(levels) do
                local nextY = levels[i + 1] and levels[i + 1].y or (lv.y + 3)
                local clear = nextY - lv.y
                if lv.y > rackTop - 0.05 then clear = 3 end -- верх стеллажа: над ним свободно
                if clear >= 0.45 then
                    -- чуть ближе к переду
                    local d = (lv.dlo + lv.dhi) / 2 + fs * (lv.dhi - lv.dlo) * 0.12
                    local half = (lv.hi - lv.lo) / 2 - 0.2
                    local mid = (lv.lo + lv.hi) / 2
                    local x = -half
                    for _ = 1, 40 do
                        local it = randomItem()
                        -- по высоте влезает? (стопка ~0.75, подарок ~0.45)
                        if clear < 1.0 and it.name == "stack" then it = ITEMS[1] end
                        if clear < 0.65 and it.name == "present" then it = ITEMS[3] end
                        local gap = 0.15 + math.random() * 0.45
                        if x + gap + it.w > half then break end
                        local u = x + gap + it.w / 2
                        -- ровно на доску: луч сверху вниз в этой точке
                        local y = lv.y
                        local from = lv.y + math.min(clear - 0.05, 0.6)
                        local hy = surfaceY(mid + u, d, from, from - lv.y + 0.3)
                        if hy and math.abs(hy - lv.y) < 0.3 then y = hy end
                        local pos = cf:PointToWorldSpace(long * (mid + u) + deep * d + Vector3.new(0, y + 0.01, 0))
                        local okIt, errIt = pcall(it.place, folder, pos, longW)
                        if not okIt then warn("[NewYear] Стеллаж: " .. tostring(errIt)) end
                        x = u + it.w / 2
                    end
                end
            end
            -- гирлянда: прямой провод по переднему верхнему краю, провисает между креплениями
            if CONFIG.FURNITURE_GARLAND then
                local topY = rackTop - 0.08
                local pins = {}
                for k = 0, 4 do
                    local l = (-0.5 + k / 4) * (W - 0.3)
                    table.insert(pins, cf:PointToWorldSpace(long * l + deep * (fs * (D / 2 + 0.04)) + Vector3.new(0, topY, 0)))
                end
                pinGarland(folder, pins, longW, cf:VectorToWorldSpace(deep * fs), 0.32)
            end
        end)
        for p in pairs(saved) do pcall(function() p.CanQuery = false end) end
        if not okWork then warn("[NewYear] Стеллаж: " .. tostring(err)) return false end
        return #levels >= 2
    end

    ---------------------------------------------------------------- обход комнат

    local function decorate(room, model, kind)
        if done[model] then return end
        done[model] = true
        if model.Name == "BookshelfObstruction" or kind == "falling" then
            if CONFIG.FALLING_SHELF then decorateFalling(room, model) end
        elseif kind == "wardrobe" then
            if CONFIG.WARDROBES then decorateWardrobe(room, model) end
        else
            -- стеллаж (не книжный шкаф): в 100-й — всегда, в других комнатах — только если без книг
            -- и у него нашлись доски-детали
            if not exactLevels(model) and model:FindFirstChild("Books", true) == nil
                and not model:FindFirstChild("Shelves") then
                if decorateRack(room, model, room.Name ~= "100") then
                    shelfCount += 1
                    return
                end
                if room.Name == "100" then return end -- не разобрались — лучше без украшений, чем криво
            end
            decorateBookcase(room, model)
            shelfCount += 1
        end
    end

    local function scanRoom(room)
        local list = {}
        for _, d in ipairs(room:GetDescendants()) do
            local kind = kindOf(d)
            if kind then
                local inner = false
                local a = d.Parent
                while a and a ~= room do
                    if kindOf(a) then inner = true break end
                    a = a.Parent
                end
                if not inner then table.insert(list, { d, kind }) end
            end
        end
        -- шкафы с книгами — первыми: на них учимся, где полки, для пустых
        local function books(e) return e[2] == "shelf" and e[1]:FindFirstChild("Books", true) ~= nil end
        table.sort(list, function(a, b) return books(a) and not books(b) end)
        for _, e in ipairs(list) do
            local ok, err = pcall(decorate, room, e[1], e[2])
            if not ok then warn("[NewYear] Мебель: " .. tostring(err)) end
        end
    end

    local okShelves, errShelves = pcall(function()
        if not CONFIG.SHELVES then return end
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            for _, room in ipairs(rooms:GetChildren()) do scanRoom(room) end
            -- комната подгружается не сразу — ждём и проверяем ещё раз
            connect(rooms.ChildAdded, function(room)
                task.delay(1, scanRoom, room)
                task.delay(4, scanRoom, room)
            end)
        end)
    end)
    report("Shelves", okShelves, errShelves)
end

---------------------------------------------------------------- мусор на полу

-- Разбросанные доски на полу — одна плоская деталь Boards (меш 8680774813) — и паутина
-- (Web, меш 7767322126: в углах, на полках, в подвале). Прячем.
do
    local JUNK_NAMES = { Boards = true, Web = true, Cobweb = true }
    local JUNK_MESHES = { "8680774813", "7767322126" }
    local function isJunk(d)
        if not d:IsA("BasePart") or d.Transparency >= 1 then return false end
        if JUNK_NAMES[d.Name] then return true end
        if d:IsA("MeshPart") then
            for _, id in ipairs(JUNK_MESHES) do
                if d.MeshId:find(id, 1, true) then return true end
            end
        end
        return false
    end
    local function cleanRoom(room)
        for _, d in ipairs(room:GetDescendants()) do
            if isJunk(d) then keepHidden(d, "Transparency", 1) end
        end
    end
    local okJunk, errJunk = pcall(function()
        if not CONFIG.HIDE_JUNK then return end
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            for _, room in ipairs(rooms:GetChildren()) do cleanRoom(room) end
            connect(rooms.ChildAdded, function(room)
                task.delay(1, cleanRoom, room)
                task.delay(4, cleanRoom, room)
            end)
        end)
    end)
    report("Junk", okJunk, errJunk)
end

---------------------------------------------------------------- подвал

-- Бочки в подвале (Cellar_Barrel, обычно пирамидой в BarrelStack) прячем и на место каждой
-- ставим большой подарок примерно того же размера — получается пирамида подарков.
-- Столкновения у бочек остаются, поэтому ходить можно как раньше.
-- Бочка: корпус 4.68 x 4.68 x 5.61 (лежит вдоль Z), подставка Base снизу; шаг в пирамиде
-- 5 studs вбок и 4 вверх. Подарки ставим снизу вверх: каждый садится ровно на верх тех,
-- что под ним (без щелей), все одного размера.
do
    local done = setmetatable({}, { __mode = "k" })

    local function barrelInfo(model)
        local body, base
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Base" then base = p
                elseif not body or p.Size.Magnitude > body.Size.Magnitude then body = p end
            end
        end
        if not body then return nil end
        local bottom = base and (base.Position.Y - base.Size.Y / 2) or (body.Position.Y - body.Size.Y / 2)
        local width = math.min(body.Size.X, body.Size.Y)
        return body, bottom, width
    end

    -- уже поставленные подарки по комнатам: комнату проверяем несколько раз (догружается),
    -- и новые бочки должны ложиться на старые подарки, а на занятое место второй не ставим
    local placedByRoom = setmetatable({}, { __mode = "k" })

    local function decorateCellar(room)
        placedByRoom[room] = placedByRoom[room] or {}
        local placed = placedByRoom[room]
        local barrels = {}
        local function taken(pos)
            for _, o in ipairs(placed) do
                if (o.center - pos).Magnitude < 1.5 then return true end
            end
            for _, b in ipairs(barrels) do
                if (b.body.Position - pos).Magnitude < 1.5 then return true end
            end
            return false
        end
        for _, m in ipairs(room:GetDescendants()) do
            if m:IsA("Model") and m.Name == "Cellar_Barrel" and not done[m] then
                local body, bottom, width = barrelInfo(m)
                if body then
                    done[m] = true
                    -- бочка-двойник на том же месте: прячем, но второй подарок не ставим
                    local dup = taken(body.Position)
                    table.insert(barrels, { model = m, body = body, bottom = bottom, width = width, dup = dup })
                end
            end
        end
        if #barrels == 0 then return end
        local folder = roomFolder(room)
        local present = loadFestive("Present")
        local boxItem = present and festiveItem(present, "Box")
        local useReal = present and boxItem and CONFIG.REAL_PRESENTS
        -- все подарки одного размера, чтобы стопка была ровной
        local minW = math.huge
        for _, b in ipairs(barrels) do minW = math.min(minW, b.width) end
        local W = minW * 0.95                 -- ширина подарка (шаг пирамиды 5 — почти впритык)
        local H = math.min(3.6, W * 0.8)      -- высота коробки
        local ps
        if useReal then
            ps = W / math.max(boxItem.size[1], boxItem.size[3])
            ps = math.min(ps, H / boxItem.size[2])
            H = boxItem.size[2] * ps
        end
        -- ставим снизу вверх: каждый подарок садится ровно на верх тех, что под ним
        table.sort(barrels, function(a, c) return a.body.Position.Y < c.body.Position.Y end)
        for _, b in ipairs(barrels) do
            -- прячем бочку целиком
            for _, d in ipairs(b.model:GetDescendants()) do
                if d:IsA("BasePart") and d.Transparency < 1 then keepHidden(d, "Transparency", 1)
                elseif (d:IsA("Decal") or d:IsA("Texture")) and d.Transparency < 1 then keepHidden(d, "Transparency", 1) end
            end
            if b.dup then continue end
            local center = b.body.Position
            local bottom = b.bottom
            local support = false
            for _, o in ipairs(placed) do
                local dp = o.center - center
                if math.abs(o.center.Y - center.Y) > 1 and Vector3.new(dp.X, 0, dp.Z).Magnitude < W * 0.98 then
                    if not support or o.top > bottom then bottom = o.top end
                    support = true
                end
            end
            -- что-то будет лежать сверху? тогда без бантика (он ушёл бы в верхний подарок)
            local covered = false
            for _, o in ipairs(barrels) do
                local dp = o.body.Position - center
                if o ~= b and dp.Y > 2 and dp.Y < 6 and Vector3.new(dp.X, 0, dp.Z).Magnitude < W then
                    covered = true
                end
            end
            local look = b.body.CFrame.LookVector
            look = Vector3.new(look.X, 0, look.Z)
            if look.Magnitude < 1e-3 then look = Vector3.zAxis end
            -- в стопке почти ровно (чуть-чуть вразнобой, чтобы не как по линейке)
            local yaw = CFrame.lookAt(Vector3.zero, look.Unit) * CFrame.Angles(0, math.rad(math.random(-2, 2)), 0)
            local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
            local pos = Vector3.new(center.X, bottom, center.Z)
            if useReal then
                local only = covered and { Box = true, Wrapper = true } or nil
                local model = spawnFestive(present, CFrame.new(pos + Vector3.new(0, H / 2, 0)) * yaw, {
                    scale = ps, only = only,
                    colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon },
                })
                model.Parent = folder
            else
                addGift(folder, CFrame.new(pos) * yaw, Vector3.new(W, H, W), style)
            end
            table.insert(placed, { center = center, top = bottom + H })
            giftCount += 1
        end
    end

    local okCellar, errCellar = pcall(function()
        if not CONFIG.CELLAR then return end
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            local function try(room)
                local ok, err = pcall(decorateCellar, room)
                if not ok then warn("[NewYear] Подвал: " .. tostring(err)) end
            end
            for _, room in ipairs(rooms:GetChildren()) do try(room) end
            connect(rooms.ChildAdded, function(room)
                task.delay(1, try, room)
                task.delay(4, try, room)
            end)
        end)
    end)
    report("Cellar", okCellar, errCellar)
end

---------------------------------------------------------------- мишура

-- Мишура — ленты Beam с текстурой из сотен ниточек (textures/tinsel.png). Лента всегда
-- повёрнута к камере, поэтому выглядит пушистой с любой стороны и почти не грузит игру.
do
    local TINSEL_COLORS = {
        Color3.fromRGB(240, 195, 75),  -- золото
        Color3.fromRGB(220, 225, 235), -- серебро
        Color3.fromRGB(215, 40, 50),   -- красная
        Color3.fromRGB(50, 175, 85),   -- зелёная
        Color3.fromRGB(80, 140, 235),  -- синяя
    }
    local tex = nil
    local function tinselTexture()
        if tex ~= nil then return tex end
        tex = ""
        local file = CONFIG.TINSEL_FILE
        local has = isfile and isfile(file)
        if not has and writefile then
            local ok, data = pcall(game.HttpGet, game, CONFIG.ASSETS_URL .. "textures/tinsel.png")
            if ok and type(data) == "string" and data:sub(2, 4) == "PNG" then
                pcall(function()
                    if makefolder and not isfolder("StevieBuddy/textures") then
                        if not isfolder("StevieBuddy") then makefolder("StevieBuddy") end
                        makefolder("StevieBuddy/textures")
                    end
                    writefile(file, data)
                end)
                has = isfile and isfile(file)
            end
        end
        if has and getcustomasset then
            local ok, id = pcall(getcustomasset, file)
            if ok then tex = id end
        end
        if tex == "" then warn("[NewYear] Нет текстуры мишуры " .. file) end
        return tex
    end

    -- Объёмная мишура: тонкая верёвочка по точкам и сотни плоских блестящих ниточек,
    -- торчащих во все стороны (как у настоящей). Ниточки чуть разных оттенков, повёрнуты
    -- по-разному — поэтому на свету переливаются.
    local function tinsel3d(folder, points, color, width, densityOverride)
        local model = Instance.new("Model")
        model.Name = "Tinsel"
        local light = color:Lerp(Color3.new(1, 1, 1), 0.4)
        local dark = color:Lerp(Color3.new(0, 0, 0), 0.35)
        local shades = { color, color, color, light, light, dark }
        local strandLen = width / 2
        local density = densityOverride or CONFIG.TINSEL_DENSITY or 42
        local rnd = Random.new()
        local GOLDEN = 2.39996 -- золотой угол: ниточки ровно распределяются по кругу
        local n = 0
        for i = 1, #points - 1 do
            local a, b = points[i], points[i + 1]
            local seg = b - a
            local len = seg.Magnitude
            if len > 1e-3 then
                local dir = seg / len
                local u = dir:Cross(math.abs(dir.Y) < 0.9 and Vector3.yAxis or Vector3.xAxis).Unit
                local w = dir:Cross(u)
                -- верёвочка внутри (её почти не видно, как у настоящей)
                decorPart({
                    Name = "Core", Shape = Enum.PartType.Cylinder,
                    Size = Vector3.new(len + 0.04, width * 0.14, width * 0.14),
                    CFrame = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.rad(90), 0),
                    Color = dark, Material = Enum.Material.Foil, Reflectance = 0.2,
                }).Parent = model
                -- ниточки — пушистым цилиндром во все стороны, чуть свисают вниз
                local count = math.max(3, math.floor(len * density + 0.5))
                for k = 1, count do
                    n += 1
                    local p = a + seg * ((k - rnd:NextNumber()) / count)
                    local ang = n * GOLDEN + rnd:NextNumber(-0.35, 0.35)
                    local radial = u * math.cos(ang) + w * math.sin(ang)
                    local v = (radial + dir * rnd:NextNumber(-0.35, 0.35) - Vector3.yAxis * 0.18).Unit
                    local L = strandLen * (rnd:NextNumber() < 0.3 and rnd:NextNumber(0.5, 0.75) or rnd:NextNumber(0.85, 1.12))
                    local base = p + radial * (width * 0.05)
                    decorPart({
                        Name = "Strand",
                        Size = Vector3.new(rnd:NextNumber(0.06, 0.09), 0.012, L),
                        CFrame = CFrame.lookAt(base + v * (L / 2), base + v * L) * CFrame.Angles(0, 0, rnd:NextNumber(0, math.pi)),
                        Color = shades[rnd:NextInteger(1, #shades)],
                        Material = Enum.Material.Foil,
                        Reflectance = rnd:NextNumber(0.2, 0.45),
                    }).Parent = model
                end
            end
        end
        model.Parent = folder
        return model
    end

    -- points — по порядку, color — nil = случайный из палитры
    makeTinsel = function(folder, points, color, width, density)
        if #points < 2 then return end
        color = color or TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        width = width or CONFIG.TINSEL_WIDTH
        if CONFIG.TINSEL_STYLE ~= "beam" then
            return tinsel3d(folder, points, color, width, density)
        end
        local holder = decorPart({
            Name = "Tinsel", Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1), CFrame = CFrame.new(points[1]),
        })
        holder.Parent = folder
        local t = tinselTexture()
        local prev
        for i, p in ipairs(points) do
            -- сначала в держатель, потом позиция: без родителя WorldPosition считается от нуля
            -- и после вставки точка улетает на координаты держателя
            local a = Instance.new("Attachment")
            a.Parent = holder
            a.Position = holder.CFrame:PointToObjectSpace(p)
            if prev then
                local b = Instance.new("Beam")
                b.Attachment0, b.Attachment1 = prev, a
                b.Texture = t
                b.TextureMode = Enum.TextureMode.Wrap
                b.TextureLength = width * 4 -- текстура 4:1
                b.Width0, b.Width1 = width, width
                b.FaceCamera = true
                b.Segments = 1
                b.Color = ColorSequence.new(color)
                b.LightEmission = 0.35
                b.LightInfluence = 0.6
                b.Brightness = 1.6
                b.Parent = holder
            end
            prev = a
        end
        return holder
    end

    -- Люстра: фестоны мишуры по кругу на уровне рожков и кисточки, свисающие с креплений.
    local done = setmetatable({}, { __mode = "k" })
    local function chandelierRing(model)
        local fixture = model:FindFirstChild("LightFixture", true)
        if fixture and fixture:IsA("BasePart") then
            return fixture.Position, fixture.Size.X / 2 * 0.95
        end
        -- неизвестная люстра: по видимым деталям без цепи (длинные тонкие не считаем)
        local mn = Vector3.new(math.huge, math.huge, math.huge)
        local mx = -mn
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.9 and p.Size.Y < 12 then
                local half = p.Size / 2
                mn = mn:Min(p.Position - half)
                mx = mx:Max(p.Position + half)
            end
        end
        if mn.X == math.huge then return nil end
        local c = (mn + mx) / 2
        return Vector3.new(c.X, mn.Y + (mx.Y - mn.Y) * 0.35, c.Z), math.max(mx.X - mn.X, mx.Z - mn.Z) / 2 * 0.85
    end

    -- Украшения едут за деталью (люстра в погоне падает анимацией): запоминаем их в осях
    -- детали и, когда она сдвинулась, переносим все разом.
    local function followPart(folder, part)
        local parts, offs = {}, {}
        local cf0 = part.CFrame
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("BasePart") then
                table.insert(parts, d)
                table.insert(offs, cf0:ToObjectSpace(d.CFrame))
            end
        end
        if #parts == 0 then return end
        local last = cf0
        local conn
        conn = connect(RunService.Heartbeat, function()
            if not (part.Parent and folder.Parent) then conn:Disconnect() return end
            local cf = part.CFrame
            if (cf.Position - last.Position).Magnitude > 1e-3 or cf.LookVector:Dot(last.LookVector) < 0.99999
                or cf.UpVector:Dot(last.UpVector) < 0.99999 then
                last = cf
                local cfs = table.create(#parts)
                for i, o in ipairs(offs) do cfs[i] = cf * o end
                pcall(function() workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged) end)
            end
        end)
    end

    local function decorateChandelier(room, model)
        if done[model] then return end
        done[model] = true
        local c, r = chandelierRing(model)
        if not c or r < 0.5 then return end
        local folder = roomFolder(room)
        -- падающая люстра (ChandelierObstruction): мишура в своей папке и едет за плафоном
        local fixture = model:FindFirstChild("LightFixture", true)
        local moving = fixture and fixture:IsA("BasePart") and model:FindFirstChildWhichIsA("AnimationController", true)
        if moving then
            folder = Instance.new("Folder")
            folder.Name = "FallingChandelier"
            folder.Parent = roomFolder(room)
        end
        local scallops, per = 6, 8
        local sag = math.min(0.5, r * 0.3)
        local ring = {}
        local phase = math.random() * math.pi * 2
        local main = TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        local accent = TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        for k = 0, scallops * per do
            local th = phase + 2 * math.pi * k / (scallops * per)
            local frac = (k % per) / per
            local p = c + Vector3.new(math.cos(th) * r, -sag * math.sin(frac * math.pi), math.sin(th) * r)
            table.insert(ring, p)
            -- кисточка на каждом креплении
            if k % per == 0 and k < scallops * per then
                local sway = Vector3.new(math.cos(th), 0, math.sin(th)) * 0.12
                makeTinsel(folder, { p, p - Vector3.new(0, 0.35, 0) + sway * 0.5, p - Vector3.new(0, 0.75, 0) + sway },
                    accent, CONFIG.TINSEL_WIDTH * 0.7)
            end
        end
        makeTinsel(folder, ring, main)
        if moving then followPart(folder, fixture) end
    end

    -- Настенная лампа (LightStand — двойная, LightStandSingle — одинарная): на стене пластина Stand,
    -- от неё вперёд торчит LightFixture с плафонами Neon. Фестон висит дугой перед лампой —
    -- от краёв плафонов вниз под корпус и обратно, по краям короткие кисточки.
    local function decorateLamp(room, model)
        if done[model] then return end
        done[model] = true
        local stand = model:FindFirstChild("Stand")
        if not (stand and stand:IsA("BasePart")) then return end
        local neon = model:FindFirstChild("Neon", true)
        local fixture = model:FindFirstChild("LightFixture", true)
        local front = (fixture and fixture:IsA("BasePart") and fixture) or (neon and neon:IsA("BasePart") and neon)
        if not front then return end
        -- оси пластины: самая тонкая — нормаль стены, из остальных горизонтальная — вдоль стены
        local cf, sz = stand.CFrame, stand.Size
        local axes = { { sz.X, cf.RightVector }, { sz.Y, cf.UpVector }, { sz.Z, cf.LookVector } }
        table.sort(axes, function(a, b) return a[1] < b[1] end)
        local n = axes[1][2]
        if n:Dot(front.Position - stand.Position) < 0 then n = -n end
        local r = (math.abs(axes[2][2].Y) < math.abs(axes[3][2].Y)) and axes[2][2] or axes[3][2]
        r = (r - Vector3.yAxis * r.Y).Unit
        local c = stand.Position
        -- насколько лампа выступает вперёд, её ширина вдоль стены и низ/верх плафонов
        local maxFront, halfSpan, bottom, shadeLow = 0, sz.X / 2, 0, nil
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.9 then
                local h = p.Size / 2
                local pc = p.CFrame
                local function ext(dir)
                    return math.abs(pc.RightVector:Dot(dir)) * h.X + math.abs(pc.UpVector:Dot(dir)) * h.Y
                        + math.abs(pc.LookVector:Dot(dir)) * h.Z
                end
                local rel = p.Position - c
                maxFront = math.max(maxFront, rel:Dot(n) + ext(n))
                halfSpan = math.max(halfSpan, math.abs(rel:Dot(r)) + ext(r))
                bottom = math.min(bottom, rel.Y - ext(Vector3.yAxis))
                if p == neon then shadeLow = rel.Y - ext(Vector3.yAxis) end
            end
        end
        if halfSpan > 4 or maxFront > 4 then return end -- что-то не то (не настенная лампа)
        shadeLow = shadeLow or bottom * 0.5
        local folder = roomFolder(room)
        local color = TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        local accent = TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        local width = CONFIG.TINSEL_WIDTH * 0.55
        -- мишура между двумя круглыми держателями спереди корпуса (LightFixture): на каждом
        -- держателе — колечко (как будто привязана), между ними — провисающая дуга под корпусом
        if not (fixture and fixture:IsA("BasePart")) then return end
        local fh = fixture.Size / 2
        local fcf = fixture.CFrame
        local function fext(dir)
            return math.abs(fcf.RightVector:Dot(dir)) * fh.X + math.abs(fcf.UpVector:Dot(dir)) * fh.Y
                + math.abs(fcf.LookVector:Dot(dir)) * fh.Z
        end
        local frel = fixture.Position - c
        local fx, fy = frel:Dot(r), frel.Y
        local fFront = frel:Dot(n) + fext(n)          -- передняя грань корпуса
        local fHalfW, fHalfH = fext(r), fext(Vector3.yAxis)
        local armX = fHalfW * 0.48                     -- держатели — примерно на середине половинок
        local thin = CONFIG.TINSEL_WIDTH * 0.36
        local function at(x, y, d) return c + r * x + Vector3.yAxis * y + n * d end
        local arms = { at(fx - armX, fy, fFront - 0.06), at(fx + armX, fy, fFront - 0.06) }
        -- дуга: от держателя к держателю, провисает чуть ниже корпуса и немного вперёд
        local pts = {}
        for k = 0, 12 do
            local t = -1 + 2 * k / 12
            local sag = 1 - t * t
            table.insert(pts, at(fx + t * armX, fy - (fHalfH + 0.22) * sag, fFront - 0.02 + 0.12 * sag))
        end
        makeTinsel(folder, pts, color, thin, (CONFIG.TINSEL_DENSITY or 42) * 0.9)
        -- колечки вокруг держателей (ось кольца — вдоль стены)
        for _, a in ipairs(arms) do
            local ring = {}
            for k = 0, 10 do
                local th = 2 * math.pi * k / 10
                table.insert(ring, a + (Vector3.yAxis * math.cos(th) + n * math.sin(th)) * 0.13)
            end
            makeTinsel(folder, ring, accent, thin * 0.85, (CONFIG.TINSEL_DENSITY or 42) * 0.8)
        end
    end

    -- Перила: мишура спиралью вокруг планки (как будто обмотали). Планка — деталь-брусок,
    -- длинная ось = направление перил; витки по её сечению, чуть шире самой планки.
    local railLines = setmetatable({}, { __mode = "k" }) -- уже обмотанные планки (по папке комнаты)

    -- эта планка лежит вплотную вдоль уже обмотанной (две детали одних перил)? тогда пропускаем
    local function alreadyWrapped(folder, part)
        local s = part.Size
        local axes = { { s.X, Vector3.xAxis }, { s.Y, Vector3.yAxis }, { s.Z, Vector3.zAxis } }
        table.sort(axes, function(a, b) return a[1] > b[1] end)
        local axis = part.CFrame:VectorToWorldSpace(axes[1][2])
        for _, r in ipairs(railLines[folder] or {}) do
            if math.abs(r.axis:Dot(axis)) > 0.95 then
                local d = part.Position - r.c
                local t = d:Dot(r.axis)
                if math.abs(t) <= r.L / 2 + 0.5 and (d - r.axis * t).Magnitude < 1.3 then return true end
            end
        end
        return false
    end

    local function wrapRail(folder, part, color)
        if alreadyWrapped(folder, part) then return end
        local s = part.Size
        local axes = { { s.X, Vector3.xAxis }, { s.Y, Vector3.yAxis }, { s.Z, Vector3.zAxis } }
        table.sort(axes, function(a, b) return a[1] > b[1] end)
        local L, along = axes[1][1], axes[1][2]
        railLines[folder] = railLines[folder] or {}
        table.insert(railLines[folder], { c = part.Position, axis = part.CFrame:VectorToWorldSpace(along), L = L })
        local pa, pb = axes[2][2], axes[3][2]
        local ra, rb = axes[2][1] / 2 + 0.12, axes[3][1] / 2 + 0.12
        local pitch = 1.5 -- длина одного витка, studs
        local n = math.max(6, math.floor(L / pitch * 14))
        local phase = math.random() * math.pi * 2
        local pts = {}
        for k = 0, n do
            local t = -L / 2 + 0.15 + (L - 0.3) * k / n
            local a = phase + 2 * math.pi * t / pitch
            table.insert(pts, part.CFrame:PointToWorldSpace(along * t + pa * (math.cos(a) * ra) + pb * (math.sin(a) * rb)))
        end
        makeTinsel(folder, pts, color, CONFIG.TINSEL_WIDTH * 0.7, (CONFIG.TINSEL_DENSITY or 42) * 0.6)
    end

    -- лестница DOORS (модель Stairs): верхние планки на боковых стенках — тонкие Wall_Strip
    -- (толщина 0.25): наклонная вдоль ступенек и короткая ровная на площадке
    local function decorateStairs(room, model)
        if done[model] then return end
        done[model] = true
        local folder = roomFolder(room)
        local color = TINSEL_COLORS[math.random(#TINSEL_COLORS)]
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p.Name == "Wall_Strip" and p.Transparency < 0.5 then
                local s = p.Size
                local thin = math.min(s.X, s.Y, s.Z)
                local long = math.max(s.X, s.Y, s.Z)
                -- планка лежит горизонтально или наклонно (не стоймя)
                local up = math.abs(p.CFrame.UpVector.Y)
                if thin <= 0.3 and long >= 1 and up > 0.6 and not done[p] then
                    done[p] = true
                    wrapRail(folder, p, color)
                end
            end
        end
    end

    -- другие перила, если в названии есть rail / banister (на будущее)
    local function isRailName(n)
        n = n:lower()
        return n:find("rail", 1, true) or n:find("banister", 1, true)
    end

    -- Перила любого вида (балконы, галереи, лестницы с балясинами): длинный брус, под которым
    -- стоят столбики. Ищем по форме, а не по названию — у DOORS они называются как попало.
    local function worldExtents(part)
        local cf, sz = part.CFrame, part.Size / 2
        local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
        return Vector3.new(
            math.abs(r.X) * sz.X + math.abs(u.X) * sz.Y + math.abs(l.X) * sz.Z,
            math.abs(r.Y) * sz.X + math.abs(u.Y) * sz.Y + math.abs(l.Y) * sz.Z,
            math.abs(r.Z) * sz.X + math.abs(u.Z) * sz.Y + math.abs(l.Z) * sz.Z)
    end

    -- деталь шкафа, книги, стола и т.п.: книги на полке стоят как «столбики», доска над ними — как
    -- «брус», и полку обматывало мишурой. Такое — не перила.
    local NOT_RAIL = { "book", "shelf", "wardrobe", "drawer", "table", "desk", "candle", "lamp" }
    local function notRailPart(d, room)
        local node = d
        while node and node ~= room do
            local n = node.Name:lower()
            for _, w in ipairs(NOT_RAIL) do
                if n:find(w, 1, true) then return true end
            end
            node = node.Parent
        end
        return false
    end

    local function decorateRailsByPosts(room)
        local parts = {}
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.5 and not notRailPart(d, room) then table.insert(parts, d) end
        end
        -- столбики (балясины): стоят вертикально, высота 1.5–6, тонкие
        local posts = {}
        for _, p in ipairs(parts) do
            local e = worldExtents(p)
            if e.Y * 2 >= 1.5 and e.Y * 2 <= 6 and e.X * 2 <= 1.3 and e.Z * 2 <= 1.3 then
                table.insert(posts, p.Position + Vector3.new(0, e.Y, 0))
            end
        end
        if #posts < 2 then return end
        -- длинные планки первыми: короткая накладка рядом с уже обмотанной пропустится
        local function longest(p) return math.max(p.Size.X, p.Size.Y, p.Size.Z) end
        table.sort(parts, function(a, b) return longest(a) > longest(b) end)
        local folder
        for _, p in ipairs(parts) do
            if not done[p] then
                local sz = p.Size
                local dims = { { sz.X, Vector3.xAxis }, { sz.Y, Vector3.yAxis }, { sz.Z, Vector3.zAxis } }
                table.sort(dims, function(a, b) return a[1] > b[1] end)
                local L, cross = dims[1][1], dims[2][1]
                local axis = p.CFrame:VectorToWorldSpace(dims[1][2])
                -- брус: длинный, в сечении не толще 2.2, лежит ровно или наклонно (не стоймя)
                if L >= 3 and cross <= 2.2 and math.abs(axis.Y) < 0.75 then
                    local c, hits = p.Position, 0
                    for _, top in ipairs(posts) do
                        local dlt = top - c
                        local t = dlt:Dot(axis)
                        if math.abs(t) <= L / 2 then
                            local onAxis = c + axis * t
                            local off = top - onAxis
                            -- верх столбика упирается в брус снизу
                            if off.Magnitude <= cross / 2 + 1 and onAxis.Y >= top.Y - 0.3 then
                                hits += 1
                                if hits >= 2 then break end
                            end
                        end
                    end
                    if hits >= 2 then
                        done[p] = true
                        folder = folder or roomFolder(room)
                        local ok, err = pcall(wrapRail, folder, p, TINSEL_COLORS[math.random(#TINSEL_COLORS)])
                        if not ok then warn("[NewYear] Перила: " .. tostring(err)) end
                    end
                end
            end
        end
    end

    local function scanRoom(room)
        if CONFIG.TINSEL_RAILINGS then
            local ok, err = pcall(function()
                -- сначала лестницы Stairs (их планки без столбиков), потом всё со столбиками
                for _, d in ipairs(room:GetDescendants()) do
                    if d:IsA("Model") and d.Name == "Stairs" and not done[d] then decorateStairs(room, d) end
                end
                decorateRailsByPosts(room)
            end)
            if not ok then warn("[NewYear] Перила: " .. tostring(err)) end
        end
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("Model") and d.Name:lower():find("chandelier", 1, true) and not done[d] then
                if CONFIG.TINSEL_CHANDELIERS then
                    local ok, err = pcall(decorateChandelier, room, d)
                    if not ok then warn("[NewYear] Люстра: " .. tostring(err)) end
                end
            elseif CONFIG.TINSEL_LAMPS and d:IsA("Model") and d.Name:sub(1, 10) == "LightStand" and not done[d] then
                local ok, err = pcall(decorateLamp, room, d)
                if not ok then warn("[NewYear] Лампа: " .. tostring(err)) end
            elseif CONFIG.TINSEL_RAILINGS and d:IsA("Model") and d.Name == "Stairs" and not done[d] then
                local ok, err = pcall(decorateStairs, room, d)
                if not ok then warn("[NewYear] Перила: " .. tostring(err)) end
            elseif CONFIG.TINSEL_RAILINGS and d:IsA("BasePart") and isRailName(d.Name) and not done[d]
                and d.Transparency < 0.5 and math.max(d.Size.X, d.Size.Y, d.Size.Z) >= 2 then
                done[d] = true
                local ok, err = pcall(wrapRail, roomFolder(room), d, TINSEL_COLORS[math.random(#TINSEL_COLORS)])
                if not ok then warn("[NewYear] Перила: " .. tostring(err)) end
            end
        end
    end

    local okTinsel, errTinsel = pcall(function()
        if not (CONFIG.TINSEL and (CONFIG.TINSEL_CHANDELIERS or CONFIG.TINSEL_RAILINGS or CONFIG.TINSEL_LAMPS)) then return end
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            for _, room in ipairs(rooms:GetChildren()) do scanRoom(room) end
            connect(rooms.ChildAdded, function(room)
                task.delay(1, scanRoom, room)
                task.delay(4, scanRoom, room)
            end)
        end)
    end)
    report("Tinsel", okTinsel, errTinsel)
end

---------------------------------------------------------------- новогодние картины

-- Картина в DOORS: модель Painting_* с рамкой (Frame) и холстом (Canvas), на холсте
-- SurfaceGui → ImageLabel с картинкой. Подменяем картинку на свою новогоднюю
-- (textures/paintings/*.png). Горизонтальным холстам — горизонтальные, высоким — высокие;
-- в одной комнате стараемся не повторять.
do
    local LANDSCAPE = { "ny_village", "ny_fireplace", "ny_forest", "ny_snowman" }
    local PORTRAIT = { "ny_tall_tree", "ny_window" }
    local cache = {}
    local function paintingAsset(name)
        if cache[name] ~= nil then return cache[name] end
        cache[name] = ""
        local file = "StevieBuddy/textures/paintings/" .. name .. ".png"
        local has = isfile and isfile(file)
        if not has and writefile then
            local ok, data = pcall(game.HttpGet, game, CONFIG.ASSETS_URL .. "textures/paintings/" .. name .. ".png")
            if ok and type(data) == "string" and data:sub(2, 4) == "PNG" then
                pcall(function()
                    for _, f in ipairs({ "StevieBuddy", "StevieBuddy/textures", "StevieBuddy/textures/paintings" }) do
                        if makefolder and not isfolder(f) then makefolder(f) end
                    end
                    writefile(file, data)
                end)
                has = isfile and isfile(file)
            end
        end
        if has and getcustomasset then
            local ok, id = pcall(getcustomasset, file)
            if ok then cache[name] = id end
        end
        if cache[name] == "" then warn("[NewYear] Нет картины " .. file) end
        return cache[name]
    end

    local done = setmetatable({}, { __mode = "k" })
    local usedInRoom = setmetatable({}, { __mode = "k" })

    local function pick(room, list)
        local used = usedInRoom[room] or {}
        usedInRoom[room] = used
        local free = {}
        for _, n in ipairs(list) do
            if not used[n] then table.insert(free, n) end
        end
        if #free == 0 then free = list end
        local n = free[math.random(#free)]
        used[n] = true
        return n
    end

    local function decoratePainting(room, model)
        if done[model] then return end
        local canvas = model:FindFirstChild("Canvas", true)
        if not (canvas and canvas:IsA("BasePart")) then return end
        local labels = {}
        for _, d in ipairs(canvas:GetDescendants()) do
            if d:IsA("ImageLabel") or d:IsA("Decal") then table.insert(labels, d) end
        end
        if #labels == 0 then return end
        done[model] = true
        -- часть картин оставляем родными, из DOORS
        if math.random() >= (CONFIG.PAINTING_CHANCE or 0.5) then return end
        -- какая сторона холста смотрит в комнату — по SurfaceGui/Decal; размеры этой грани
        local s = canvas.Size
        local w, h = s.X, s.Y
        local face = labels[1]:IsA("Decal") and labels[1].Face
            or (labels[1]:FindFirstAncestorOfClass("SurfaceGui") and labels[1]:FindFirstAncestorOfClass("SurfaceGui").Face)
        if face == Enum.NormalId.Left or face == Enum.NormalId.Right then w, h = s.Z, s.Y
        elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then w, h = s.X, s.Z end
        local id = paintingAsset(pick(room, (w >= h) and LANDSCAPE or PORTRAIT))
        if id == "" then return end
        for _, l in ipairs(labels) do
            -- keepHidden держит своё значение (если игра поменяет — вернёт) и при выключении
            -- скрипта восстановит родную картину
            if l:IsA("ImageLabel") then
                keepHidden(l, "Image", id)
                keepHidden(l, "ScaleType", Enum.ScaleType.Crop)
                keepHidden(l, "ImageColor3", Color3.new(1, 1, 1))
            else
                keepHidden(l, "Texture", id)
            end
        end
    end

    local function scanRoom(room)
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("Model") and d.Name:sub(1, 8) == "Painting" and not done[d] then
                local ok, err = pcall(decoratePainting, room, d)
                if not ok then warn("[NewYear] Картина: " .. tostring(err)) end
            end
        end
    end

    local okPaint, errPaint = pcall(function()
        if not CONFIG.PAINTINGS then return end
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            for _, room in ipairs(rooms:GetChildren()) do scanRoom(room) end
            connect(rooms.ChildAdded, function(room)
                task.delay(1, scanRoom, room)
                task.delay(4, scanRoom, room)
            end)
        end)
    end)
    report("Paintings", okPaint, errPaint)
end

---------------------------------------------------------------- новогодние обои

-- Картинка лежит в workspace/StevieBuddy/textures; если её нет — качаем с GitHub
local function wallpaperAsset()
    local file = CONFIG.WALLPAPER_FILE
    local has = isfile and isfile(file)
    if not has and CONFIG.WALLPAPER_URL ~= "" and writefile then
        local ok, data = pcall(game.HttpGet, game, CONFIG.WALLPAPER_URL)
        if ok and type(data) == "string" and data:sub(2, 4) == "PNG" then
            pcall(function()
                if makefolder and not (isfolder and isfolder("StevieBuddy/textures")) then
                    if not isfolder("StevieBuddy") then makefolder("StevieBuddy") end
                    makefolder("StevieBuddy/textures")
                end
                writefile(file, data)
            end)
            has = isfile and isfile(file)
        end
    end
    if not has then error("нет файла " .. file .. " и не получилось скачать") end
    if not getcustomasset then error("экзекутор не умеет getcustomasset") end
    return getcustomasset(file)
end

local okPaper, errPaper = pcall(function()
    if not CONFIG.WALLPAPER then return end
    local asset = wallpaperAsset()
    local ids = {}
    for _, id in ipairs(CONFIG.WALLPAPER_IDS) do ids[tostring(id)] = true end
    local done = {}
    local function try(d)
        if done[d] or not (d:IsA("Texture") or d:IsA("Decal")) then return end
        local id = d.Texture:match("(%d+)%D*$")
        if not (id and ids[id]) then return end
        done[d] = true
        setLocal(d, "Texture", asset)
        setLocal(d, "Color3", Color3.new(1, 1, 1))
        if d:IsA("Texture") and CONFIG.WALLPAPER_SCALE ~= 1 then
            setLocal(d, "StudsPerTileU", d.StudsPerTileU * CONFIG.WALLPAPER_SCALE)
            setLocal(d, "StudsPerTileV", d.StudsPerTileV * CONFIG.WALLPAPER_SCALE)
        end
        wallpaperCount += 1
    end
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        if not rooms then return end
        for _, d in ipairs(rooms:GetDescendants()) do try(d) end
        connect(rooms.DescendantAdded, function(d) task.defer(try, d) end)
    end)
end)
report("Wallpaper", okPaper, errPaper)

---------------------------------------------------------------- подарки вместо книг (50-я комната)

-- Книги-подсказки в библиотеке (LiveHintBook на полках) превращаем в маленькие подарки.
-- Когда поднимаешь книгу, игра даёт в руки раскрытую книгу HintBook: слева фигура (картинка),
-- справа цифра. Её прячем, а в руках подарок сам открывается, и из него поднимается
-- открытка с той же фигурой и цифрой. Подсказка в панели сверху остаётся как была.
do
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local BOOK_PARTS = { BookBase = true, Pages = true, Bindings = true, Neon = true, Moon = true }
    local HELD_PARTS = { Cover = true, Handle = true, Paper = true, UIHolder = true }
    local seen = setmetatable({}, { __mode = "k" })

    -- 1) подарок на полке вместо книги
    local function giftOnShelf(book)
        if seen[book] then return end
        local base = book:FindFirstChild("Base")
        if not (base and base:IsA("BasePart")) then return end
        local present = loadFestive("Present")
        local boxItem = present and festiveItem(present, "Box")
        if not boxItem then return end
        seen[book] = true
        for _, p in ipairs(book:GetDescendants()) do
            if p:IsA("BasePart") and BOOK_PARTS[p.Name] then keepHidden(p, "Transparency", 1) end
        end
        local s = CONFIG.GIFT_BOOK_SCALE or 0.55
        local bottom = base.Position.Y - base.Size.Y / 2
        local look = base.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude < 1e-3 then look = Vector3.zAxis end
        local yaw = CFrame.lookAt(Vector3.zero, look.Unit) * CFrame.Angles(0, math.rad(math.random(-15, 15)), 0)
        local st = GIFT_STYLES[math.random(#GIFT_STYLES)]
        local m = spawnFestive(present,
            CFrame.new(base.Position.X, bottom + boxItem.size[2] * s / 2, base.Position.Z) * yaw,
            { scale = s, colors = { Box = st.box, Wrapper = st.ribbon, Bow = st.ribbon } })
        m.Name = "NewYearGift"
        m.Parent = book -- подняли книгу — подарок пропадает вместе с ней
        giftCount += 1
    end

    -- 2) в руках: книгу прячем, вместо неё подарок, который сам открывается прямо в руках
    local function hideHeldBook(tool)
        local function hide(d)
            if d:IsA("BasePart") and HELD_PARTS[d.Name] then
                d.Transparency = 1
            elseif d:IsA("SurfaceGui") then
                d.Enabled = false
            end
        end
        for _, d in ipairs(tool:GetDescendants()) do hide(d) end
        connect(tool.DescendantAdded, hide)
    end

    -- фигура и цифра из книги (появляются в ней почти сразу)
    local function readHint(tool)
        local deadline = os.clock() + 1.5
        repeat
            local r, l = tool:FindFirstChild("UIRight", true), tool:FindFirstChild("UILeft", true)
            local txt = r and r:FindFirstChildWhichIsA("TextLabel", true)
            local img = l and l:FindFirstChildWhichIsA("ImageLabel", true)
            if txt and img and txt.Text ~= "" and img.Image ~= "" then return txt.Text, img end
            task.wait(0.05)
        until os.clock() > deadline
    end

    local function easeOutBack(x)
        local c1, c3 = 1.70158, 2.70158
        return 1 + c3 * (x - 1) ^ 3 + c1 * (x - 1) ^ 2
    end
    local function clamp01(x) return math.clamp(x, 0, 1) end

    -- Подарок стоит ровно (вверх — вверх) там, где у книги середина, и смотрит лицом на того,
    -- кто держит (у тебя — на камеру). Трясётся, крышка с бантом слетает, летят искры,
    -- из коробки поднимается открытка с фигурой и цифрой и поворачивается к тебе.
    local function playOpening(tool, owner, digit, img)
        local handle = tool:FindFirstChild("Handle")
        if not (handle and handle:IsA("BasePart")) then return end
        local cover = tool:FindFirstChild("Cover")
        local st = GIFT_STYLES[math.random(#GIFT_STYLES)]
        local model = Instance.new("Model")
        model.Name = "NewYearGiftOpen"
        local W, H, T = 0.85, 0.62, 0.04
        local LW, LH = W + 0.06, 0.16
        local inner = st.box:Lerp(Color3.new(0, 0, 0), 0.55)
        local bodyParts, lidParts, fadeParts = {}, {}, {}
        local function part(list, size, color, rel, mat)
            local p = Instance.new("Part")
            p.Anchored = true
            p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
            p.CastShadow = false
            p.Size = size
            p.Color = color
            p.Material = mat or Enum.Material.SmoothPlastic
            p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
            p.Parent = model
            table.insert(list, { p, rel })
            table.insert(fadeParts, { p, 0 })
            return p
        end
        -- коробка открытая сверху (внутри темно), снаружи ленты
        part(bodyParts, Vector3.new(W, T, W), inner, CFrame.new(0, -H / 2 + T / 2, 0))
        for _, side in ipairs({ -1, 1 }) do
            part(bodyParts, Vector3.new(W, H, T), st.box, CFrame.new(0, 0, side * (W / 2 - T / 2)))
            part(bodyParts, Vector3.new(T, H, W - 2 * T), st.box, CFrame.new(side * (W / 2 - T / 2), 0, 0))
            part(bodyParts, Vector3.new(0.15, H, 0.01), st.ribbon, CFrame.new(0, 0, side * (W / 2 + 0.005)), Enum.Material.Fabric)
            part(bodyParts, Vector3.new(0.01, H, 0.15), st.ribbon, CFrame.new(side * (W / 2 + 0.005), 0, 0), Enum.Material.Fabric)
        end
        -- крышка с лентами и бантом
        part(lidParts, Vector3.new(LW, LH, LW), st.box, CFrame.new())
        part(lidParts, Vector3.new(LW + 0.01, LH + 0.01, 0.15), st.ribbon, CFrame.new(), Enum.Material.Fabric)
        part(lidParts, Vector3.new(0.15, LH + 0.01, LW + 0.01), st.ribbon, CFrame.new(), Enum.Material.Fabric)
        local present = loadFestive("Present")
        if present and festiveItem(present, "Bow") then
            local m = spawnFestive(present, CFrame.new(), { scale = LW / 1.92, only = { Bow = true }, lights = false,
                colors = { Bow = st.ribbon } })
            local bow = m:FindFirstChild("Bow")
            if bow then
                bow.Anchored = true
                bow.Parent = model
                table.insert(lidParts, { bow, CFrame.new(0, LH / 2 + 0.05, 0) })
                table.insert(fadeParts, { bow, 0 })
            end
            m:Destroy()
        end
        -- открытка с фигурой и цифрой (сначала спрятана в коробке)
        local card
        if digit and img then
            card = Instance.new("Part")
            card.Anchored = true
            card.CanCollide, card.CanTouch, card.CanQuery = false, false, false
            card.CastShadow = false
            card.Size = Vector3.new(0.62, 0.8, 0.02)
            card.Color = Color3.fromRGB(255, 248, 235)
            card.Material = Enum.Material.SmoothPlastic
            card.Parent = model
            local sg = Instance.new("SurfaceGui")
            sg.Face = Enum.NormalId.Front
            sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            sg.PixelsPerStud = 320
            sg.LightInfluence = 0.3
            sg.Parent = card
            local band = Instance.new("Frame")
            band.BorderSizePixel = 0
            band.BackgroundColor3 = st.box
            band.Size = UDim2.new(1, 0, 0, 22)
            band.Parent = sg
            local frame = Instance.new("UIStroke") -- рамка цвета подарка
            frame.Thickness = 8
            frame.Color = st.box
            local border = Instance.new("Frame")
            border.BackgroundTransparency = 1
            border.Size = UDim2.fromScale(1, 1)
            border.Parent = sg
            frame.Parent = border
            local shape = Instance.new("ImageLabel")
            shape.BackgroundTransparency = 1
            shape.AnchorPoint = Vector2.new(0.5, 0)
            shape.Position = UDim2.new(0.5, 0, 0, 34)
            shape.Size = UDim2.fromOffset(120, 120)
            shape.Image = img.Image
            shape.ImageRectOffset = img.ImageRectOffset
            shape.ImageRectSize = img.ImageRectSize
            shape.ImageColor3 = Color3.fromRGB(55, 40, 35)
            shape.ScaleType = Enum.ScaleType.Fit
            shape.Parent = sg
            local num = Instance.new("TextLabel")
            num.BackgroundTransparency = 1
            num.AnchorPoint = Vector2.new(0.5, 0)
            num.Position = UDim2.new(0.5, 0, 0, 152)
            num.Size = UDim2.fromOffset(170, 94)
            num.Font = Enum.Font.Oswald
            num.TextScaled = true
            num.Text = digit
            num.TextColor3 = st.box:Lerp(Color3.new(0, 0, 0), 0.2)
            num.Parent = sg
        end
        -- искры
        local sparks = {}
        local SPARK_COLORS = { Color3.fromRGB(255, 220, 110), Color3.fromRGB(255, 255, 255), st.ribbon }
        for k = 1, 14 do
            local p = Instance.new("Part")
            p.Anchored = true
            p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
            p.CastShadow = false
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.one * (0.03 + math.random() * 0.04)
            p.Material = Enum.Material.Neon
            p.Color = SPARK_COLORS[(k % #SPARK_COLORS) + 1]
            p.Transparency = 1
            p.Parent = model
            local a = math.random() * math.pi * 2
            table.insert(sparks, { p = p, v = Vector3.new(math.cos(a) * (0.4 + math.random() * 0.7),
                1.4 + math.random(), math.sin(a) * (0.4 + math.random() * 0.7)) })
        end
        model.Parent = root
        track(model)

        local cam = workspace.CurrentCamera
        local function viewer()
            if owner == lp then return cam.CFrame.Position end
            local head = owner.Character and owner.Character:FindFirstChild("Head")
            return head and head.Position
        end
        local OPEN = 0.75
        local t0, goneAt, lastBase = os.clock(), nil, nil
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local t = os.clock() - t0
            -- где подарок: середина раскрытой книги, пока книга в руках; потом — где был
            local inHand = tool.Parent and handle.Parent
            if inHand then
                local center = handle.Position
                if cover and cover.Parent then center = (center + cover.Position) / 2 end
                local eye = viewer() or (center + Vector3.new(0, 0, -1))
                local d = eye - center
                d = Vector3.new(d.X, 0, d.Z)
                if d.Magnitude < 1e-3 then d = Vector3.zAxis end
                -- лицом (-Z) к смотрящему, вверх — строго вверх
                lastBase = CFrame.lookAt(center, center + d.Unit) * CFrame.new(0, 0.05, 0)
            elseif not goneAt then
                goneAt = t
            end
            if not lastBase then return end
            -- коробка: подпрыгивает при появлении, трясётся всё сильнее
            local pop = easeOutBack(clamp01(t / 0.25))
            local shake = 0
            if t > 0.2 and t < OPEN then
                shake = math.sin(t * 48) * math.rad(3 + 7 * (t - 0.2) / (OPEN - 0.2))
            end
            local bodyCF = lastBase * CFrame.new(0, -0.25 * (1 - pop), 0) * CFrame.Angles(0, math.rad(15), shake)
            for _, e in ipairs(bodyParts) do e[1].CFrame = bodyCF * e[2] end
            -- крышка: улетает вверх-вбок и тает
            local u = clamp01((t - OPEN) / 0.5)
            local lidCF = bodyCF * CFrame.new(0, H / 2 + LH / 2 - 0.01, 0)
            if u > 0 then
                lidCF = lidCF * CFrame.new(0.45 * u, 1.1 * u - 0.45 * u * u, 0.15 * u)
                    * CFrame.Angles(-0.9 * u, 0.5 * u, -1.1 * u)
            end
            local lidFade = clamp01((u - 0.45) * 2)
            for _, e in ipairs(lidParts) do e[1].CFrame = lidCF * e[2] end
            -- искры из коробки
            local sT = t - OPEN
            local top = bodyCF * Vector3.new(0, H / 2, 0)
            for _, s in ipairs(sparks) do
                if sT > 0 and sT < 1.1 then
                    s.p.CFrame = CFrame.new(top + s.v * sT + Vector3.new(0, -2.2, 0) * sT * sT)
                    s.p.Transparency = clamp01(sT / 1.1)
                else
                    s.p.Transparency = 1
                end
            end
            -- открытка: поднимается из коробки и поворачивается к смотрящему
            if card then
                local c = clamp01((t - OPEN - 0.05) / 0.45)
                local rise = -H * 0.35 + (H * 0.35 + 0.62) * easeOutBack(c)
                local pos = bodyCF * Vector3.new(0, rise, 0)
                local eye = viewer() or (pos + lastBase.LookVector)
                local face = CFrame.lookAt(pos, eye) -- передняя сторона (-Z) — к глазам
                local flat = CFrame.lookAt(pos, pos + lastBase.LookVector)
                card.CFrame = flat:Lerp(face, c) * CFrame.Angles(0, 0, math.rad((1 - c) * 10 + math.sin(t * 2.2) * 2))
            end
            -- конец: книга пропала из рук — ещё секунду висит и тает
            local fade = goneAt and clamp01((t - goneAt - 0.9) / 0.35) or 0
            for _, e in ipairs(fadeParts) do
                local isLid = false
                for _, l in ipairs(lidParts) do if l[1] == e[1] then isLid = true break end end
                e[1].Transparency = math.max(fade, isLid and lidFade or 0)
            end
            if card then
                card.Transparency = fade
                for _, g in ipairs(card:GetDescendants()) do
                    if g:IsA("TextLabel") then g.TextTransparency = fade
                    elseif g:IsA("ImageLabel") then g.ImageTransparency = fade
                    elseif g:IsA("Frame") and g.BackgroundTransparency < 1 then g.BackgroundTransparency = fade
                    elseif g:IsA("UIStroke") then g.Transparency = fade end
                end
            end
            if fade >= 1 or t > 12 then
                conn:Disconnect()
                model:Destroy()
            end
        end)
        connect(model.Destroying, function() if conn.Connected then conn:Disconnect() end end)
    end

    local function onTool(tool, owner)
        if not (tool:IsA("Tool") and tool.Name == "HintBook") or seen[tool] then return end
        seen[tool] = true
        task.defer(function()
            local ok, err = pcall(hideHeldBook, tool)
            if not ok then warn("[NewYear] Книга в руках: " .. tostring(err)) end
            local digit, img = readHint(tool)
            local ok2, err2 = pcall(playOpening, tool, owner, digit, img)
            if not ok2 then warn("[NewYear] Открытие подарка: " .. tostring(err2)) end
        end)
    end

    local okBooks, errBooks = pcall(function()
        if not CONFIG.GIFT_BOOKS then return end
        local function watchChar(plr, char)
            for _, c in ipairs(char:GetChildren()) do onTool(c, plr) end
            connect(char.ChildAdded, function(c) onTool(c, plr) end)
        end
        local function watchPlayer(plr)
            if plr.Character then watchChar(plr, plr.Character) end
            connect(plr.CharacterAdded, function(c) watchChar(plr, c) end)
        end
        for _, plr in ipairs(Players:GetPlayers()) do watchPlayer(plr) end
        connect(Players.PlayerAdded, watchPlayer)
        task.spawn(function()
            local rooms = workspace:WaitForChild("CurrentRooms", 30)
            if not rooms then return end
            local function try(d)
                if d:IsA("Model") and d.Name == "LiveHintBook" and not seen[d] then
                    task.delay(0.5, function()
                        if d.Parent then
                            local ok, err = pcall(giftOnShelf, d)
                            if not ok then warn("[NewYear] Подарок на полке: " .. tostring(err)) end
                        end
                    end)
                end
            end
            for _, d in ipairs(rooms:GetDescendants()) do try(d) end
            connect(rooms.DescendantAdded, try)
        end)
    end)
    report("GiftBooks", okBooks, errBooks)
end

---------------------------------------------------------------- шапки Санты на монстрах

local nyAsset -- файл из workspace/StevieBuddy -> ссылка (задаётся в разделе «праздник»)

local MONSTERS = {
    RushMoving = true, AmbushMoving = true, BackdoorRush = true, BackdoorLookman = true,
    Eyes = true, SeekMoving = true, SeekMovingNewClone = true,
    FigureRig = true, FigureRagdoll = true, A60 = true, A120 = true, Screech = true,
    FigureLibrary = true, -- Фигура из заставки 50-й комнаты (Camera.FigureLibrary)
}
local hatted = {}

-- Один раз на каждого монстра сохраняем, из чего он сделан (monster_scan.txt),
-- чтобы подогнать шапку точно, если сядет криво
local monsterDumped, monsterLines = {}, {}
local function dumpMonster(model)
    if not CONFIG.SCAN then return end
    if monsterDumped[model.Name] then return end
    monsterDumped[model.Name] = true
    table.insert(monsterLines, "===== " .. model:GetFullName())
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            table.insert(monsterLines, ("%s [%s] size=%s transp=%.2f"):format(
                d:GetFullName(), d.ClassName, tostring(d.Size), d.Transparency))
        elseif d:IsA("Decal") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            table.insert(monsterLines, d:GetFullName() .. " [" .. d.ClassName .. "]")
        end
    end
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        writefile("StevieBuddy/monster_scan.txt", table.concat(monsterLines, "\n"))
    end)
end

local function visible(p)
    return p:IsA("BasePart") and p.Transparency < 0.9
end

-- Новогодняя Фигура: костюм из новогодней версии DOORS (festive/FigureRig.json —
-- сохраняет festive_export.lua). Тело то же, поверх — рога, мех, манжеты, мешки, сапоги,
-- красные варежки. Каждая новая деталь приваривается к своей части тела, поэтому
-- двигается вместе с Фигурой. Детали, которые в новогодней версии другие (сапоги вместо
-- ступней), — родные прячем, свои ставим на их место; другой цвет (варежки) — перекрашиваем.
local function meshNum(id) return id and tostring(id):match("(%d+)%D*$") end

local function dressFigure(model, data)
    local items, byI = data.items, {}
    for _, e in ipairs(items) do byI[e.i] = e end
    local root = items[1]
    local function pathOf(e)
        local names = {}
        while e and e ~= root do
            table.insert(names, 1, e.name)
            e = e.parent and byI[e.parent]
        end
        return table.concat(names, "/")
    end
    -- живые детали Фигуры по пути от модели (Blister есть на каждой руке — по имени не различить)
    local live = {}
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local names, n = {}, d
            while n and n ~= model do
                table.insert(names, 1, n.Name)
                n = n.Parent
            end
            live[table.concat(names, "/")] = d
        end
    end
    local costume = Instance.new("Model")
    costume.Name = "NewYearCostume"
    local made, matched, count = {}, {}, 0

    local function makePart(e)
        local p = Instance.new("Part")
        p.Name = e.name
        p.Size = fV3(e.size)
        p.Color = fC3(e.color)
        p.Material = fMat(e.material)
        p.Transparency = e.transparency or 0
        p.Reflectance = e.reflectance or 0
        p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
        p.CastShadow = e.castShadow ~= false
        p.Massless = true
        p.Anchored = false
        p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
        if e.meshId and e.meshId ~= "" then
            if not e.meshSize then return nil end -- без родного размера меш не подогнать
            local m = Instance.new("SpecialMesh")
            m.MeshType = Enum.MeshType.FileMesh
            m.MeshId = e.meshId
            if e.textureId and e.textureId ~= "" then m.TextureId = e.textureId end
            local ms = fV3(e.meshSize)
            m.Scale = fV3(e.size) / Vector3.new(math.max(ms.X, 1e-3), math.max(ms.Y, 1e-3), math.max(ms.Z, 1e-3))
            m.Parent = p
        elseif e.shape then
            p.Shape = fEnum(Enum.PartType, e.shape, Enum.PartType.Block)
        end
        return p
    end
    local function attach(p, anchor, c0)
        p.CFrame = anchor.CFrame * c0
        local w = Instance.new("Weld")
        w.Part0, w.Part1, w.C0 = anchor, p, c0
        w.Parent = p
        p.Parent = costume
        count += 1
    end

    -- 1) то, что есть у обычной Фигуры: другой меш — заменить, другой цвет — перекрасить
    for _, e in ipairs(items) do
        if e.cf and e.size and e ~= root then
            local l = live[pathOf(e)]
            if l then
                matched[e.i] = l
                if (e.transparency or 0) < 0.99 and l.Transparency < 0.99 then
                    if l:IsA("MeshPart") and e.meshId and meshNum(e.meshId) ~= meshNum(l.MeshId) then
                        local p = makePart(e)
                        if p then
                            keepHidden(l, "Transparency", 1)
                            attach(p, l, CFrame.identity)
                            made[e.i] = p
                        end
                    else
                        -- BasePart.Color хранится в 0..255 — округляем, чтобы сравнение не дёргалось
                        local c = Color3.fromRGB(math.floor(e.color[1] * 255 + 0.5),
                            math.floor(e.color[2] * 255 + 0.5), math.floor(e.color[3] * 255 + 0.5))
                        if (Vector3.new(c.R, c.G, c.B) - Vector3.new(l.Color.R, l.Color.G, l.Color.B)).Magnitude > 0.06 then
                            keepHidden(l, "Color", c)
                        end
                        local mat = fMat(e.material)
                        if mat ~= l.Material then keepHidden(l, "Material", mat) end
                    end
                end
            end
        end
    end
    -- 2) новые детали (рога, мех, мешки): к ближайшей детали-родителю, как в новогодней версии
    local function exportAnchor(e)
        local a = e.parent and byI[e.parent]
        while a and a ~= root do
            if a.cf and a.size and (matched[a.i] or made[a.i]) then return a end
            a = a.parent and byI[a.parent]
        end
        -- висит прямо на модели (мешки, хвост) — к туловищу (в новогодней версии они на
        -- суставах от него), а если туловища нет — к ближайшей части тела
        for i, l in pairs(matched) do
            if byI[i].name == "Torso" and l.Transparency < 0.99 then return byI[i] end
        end
        local best, bestD
        local pos = fCF(e.cf).Position
        for i, l in pairs(matched) do
            local d = (fCF(byI[i].cf).Position - pos).Magnitude
            if l.Transparency < 0.99 and (not bestD or d < bestD) then best, bestD = byI[i], d end
        end
        return best
    end
    for _, e in ipairs(items) do
        if e.cf and e.size and e ~= root and not matched[e.i] and (e.transparency or 0) < 0.99
            and (e.class == "MeshPart" or e.class == "Part" or e.class == "UnionOperation") then
            local a = exportAnchor(e)
            local anchor = a and (made[a.i] or matched[a.i])
            if anchor then
                local p = makePart(e)
                if p then
                    attach(p, anchor, fCF(a.cf):Inverse() * fCF(e.cf))
                    made[e.i] = p
                end
            end
        end
    end
    costume.Parent = model
    track(costume)
    return count
end

-- Анимации новогодней Фигуры. Сами анимации берём по названию (Walk, Run, Idle, Door...)
-- из festive/FigureRig.json. Когда игра запускает у Фигуры обычную анимацию, у тебя на
-- экране вместо неё играет новогодняя с тем же названием (обычная приглушается до нуля).
local function festiveFigureAnims(model, data)
    if not CONFIG.FIGURE_ANIMS then return end
    local byI, festive = {}, {}
    for _, e in ipairs(data.items) do byI[e.i] = e end
    for _, e in ipairs(data.items) do
        local par = e.parent and byI[e.parent]
        if e.class == "Animation" and e.animationId and e.animationId ~= ""
            and not (par and par.name == "PlayerAnimations") then -- те — для игрока, не трогаем
            festive[e.name] = e.animationId
        end
    end
    if not next(festive) then return end
    local swap = {} -- [номер обычной анимации] = новогодняя Animation
    local function learn(a)
        if not (a:IsA("Animation") and festive[a.Name]) then return end
        if a.Parent and a.Parent.Name == "PlayerAnimations" then return end
        local id, fid = meshNum(a.AnimationId), festive[a.Name]
        if id and id ~= meshNum(fid) and not swap[id] then
            local fa = Instance.new("Animation")
            fa.AnimationId = fid
            swap[id] = fa
        end
    end
    for _, a in ipairs(model:GetDescendants()) do learn(a) end
    connect(model.DescendantAdded, learn)

    local holder = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController")
    local animator = holder and (holder:FindFirstChildOfClass("Animator") or holder:WaitForChild("Animator", 5))
    if not animator then return end
    local ours = setmetatable({}, { __mode = "k" })
    local function onPlayed(track)
        if ours[track] then return end
        local id = meshNum(track.Animation and track.Animation.AnimationId)
        local fa = id and swap[id]
        if not fa then return end
        local ok, mine = pcall(animator.LoadAnimation, animator, fa)
        if not (ok and mine) then return end
        ours[mine] = true
        mine.Priority = track.Priority
        mine.Looped = track.Looped
        mine:Play(0.15, 1, track.Speed)
        pcall(function() mine.TimePosition = math.min(track.TimePosition, math.max(mine.Length - 0.05, 0)) end)
        pcall(function() track:AdjustWeight(0.001, 0.15) end)
        pcall(function()
            connect(track:GetPropertyChangedSignal("Speed"), function() mine:AdjustSpeed(track.Speed) end)
        end)
        track.Stopped:Once(function() mine:Stop(0.15) end)
    end
    connect(animator.AnimationPlayed, onPlayed)
    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do onPlayed(t) end
end

local function hatMonster(model)
    if hatted[model] then return end
    if CONFIG.FIGURE_COSTUME and (model.Name == "FigureRig" or model.Name == "FigureRagdoll"
        or model.Name == "FigureLibrary") then
        local data = loadFestive("FigureRig")
        if data then
            -- голова может лежать глубже (у Фигуры из заставки) — ждём недолго, заставка короткая
            if not model:FindFirstChild("Head", true) then model:WaitForChild("Head", 2) end
            hatted[model] = true
            pcall(dumpMonster, model)
            local okA, errA = pcall(festiveFigureAnims, model, data)
            if not okA then warn("[NewYear] Анимации Фигуры: " .. tostring(errA)) end
            if dressFigure(model, data) > 0 then
                monsterHatCount += 1
                return
            end
            hatted[model] = nil -- не получилось — хотя бы шапку
        end
    end
    pcall(dumpMonster, model)
    -- видимая голова, если есть; иначе самая большая ВИДИМАЯ деталь
    -- (раньше брали любую — у Скрича это невидимый хитбокс, и шапка висела над ним)
    local base = model:FindFirstChild("Head", true)
    if not (base and visible(base)) then
        base = nil
        local best = 0
        for _, d in ipairs(model:GetDescendants()) do
            if visible(d) and not d:IsDescendantOf(root) then
                local v = d.Size.X * d.Size.Y * d.Size.Z
                if v > best then best, base = v, d end
            end
        end
    end
    if not base then return end
    hatted[model] = true
    local size = base.Size
    -- Скрич: его родной цилиндр из новогодней версии
    if CONFIG.SCREECH_TOPHAT and model.Name:find("Screech") then
        local data = loadFestive("Tophat")
        if data then
            local top = model:FindFirstChild("Top", true)
            local anchor = (top and top:IsA("BasePart") and visible(top)) and top or base
            local hs = math.clamp(math.min(anchor.Size.X, anchor.Size.Z) / 1.0, 0.8, 3)
            local hatH = (data.size and data.size[2] or 0.58) * hs
            local frame = anchor.CFrame * CFrame.new(0, anchor.Size.Y * 0.4 + hatH * 0.4, 0)
                * CFrame.Angles(0, 0, math.rad(8))
            local hat = spawnFestive(data, frame, { scale = hs, weld = anchor })
            hat.Parent = model
            track(hat)
            monsterHatCount += 1
            return
        end
    end
    local s = math.clamp(math.min(size.X, size.Z) / 1.1, 0.6, 4)
    -- чуть ниже верхнего края детали, чтобы шапка сидела, а не парила
    local offset = CFrame.new(0, size.Y * 0.38, 0) * CFrame.Angles(math.rad(-8), 0, math.rad(10))
    local hat = buildHat(base, offset, s)
    hat.Parent = model
    track(hat)
    monsterHatCount += 1
end

-- Раш: голубой вместо чёрного и с бубенцами (его родные звуки остаются)
local ICE_DARK, ICE_LIGHT = Color3.fromRGB(30, 95, 215), Color3.fromRGB(205, 238, 255)
local function iceColor(c)
    return ICE_DARK:Lerp(ICE_LIGHT, math.clamp((c.R + c.G + c.B) / 3, 0, 1))
end
local rushDone = setmetatable({}, { __mode = "k" })
local function festiveRush(model, keepColor)
    if rushDone[model] then return end
    if keepColor and not CONFIG.AMBUSH_BELLS then return end
    if not keepColor and not CONFIG.RUSH_FESTIVE then return end
    rushDone[model] = true
    local main
    for _, d in ipairs(model:GetDescendants()) do
        if keepColor then
            if d:IsA("BasePart") and (not main or d.Size.Magnitude > main.Size.Magnitude) then main = d end
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
            local keys = {}
            for _, k in ipairs(d.Color.Keypoints) do
                table.insert(keys, ColorSequenceKeypoint.new(k.Time, iceColor(k.Value)))
            end
            pcall(setLocal, d, "Color", ColorSequence.new(keys))
        elseif d:IsA("Light") then
            pcall(setLocal, d, "Color", Color3.fromRGB(140, 200, 255))
        elseif d:IsA("Decal") or d:IsA("Texture") then
            pcall(setLocal, d, "Color3", Color3.fromRGB(190, 225, 255))
        elseif d:IsA("BasePart") then
            if d.Transparency < 0.95 then pcall(setLocal, d, "Color", iceColor(d.Color)) end
            if not main or d.Size.Magnitude > main.Size.Magnitude then main = d end
        end
    end
    -- бубенцы звенят, пока Раш летит
    task.spawn(function()
        local id
        for _ = 1, 20 do
            id = nyAsset and nyAsset("sounds/ny_sleighbells.mp3")
            if id then break end
            task.wait(0.25)
        end
        if not (id and main and main.Parent) then return end
        local s = Instance.new("Sound")
        s.Name = "NewYearBells"
        s.SoundId = id
        s.Looped = true
        s.Volume = CONFIG.RUSH_BELLS_VOLUME or 1
        s.RollOffMaxDistance = 160
        s.RollOffMinDistance = 12
        s.Parent = main
        track(s)
        s:Play()
    end)
end

local function tryMonster(d)
    if d:IsA("Model") and (d.Name == "RushMoving" or d.Name == "BackdoorRush") and not rushDone[d] then
        task.delay(0.3, function()
            if d.Parent then pcall(festiveRush, d) end
        end)
    end
    if d:IsA("Model") and d.Name == "AmbushMoving" and not rushDone[d] then
        task.delay(0.3, function()
            if d.Parent then pcall(festiveRush, d, true) end
        end)
    end
    if d:IsA("Model") and MONSTERS[d.Name] and not hatted[d] then
        -- даём монстру догрузиться
        task.delay(0.3, function()
            if d.Parent then
                local ok, err = pcall(hatMonster, d)
                if not ok then warn("[NewYear] Шапка на " .. d.Name .. ": " .. tostring(err)) end
            end
        end)
    end
end

local okMonsters, errMonsters = pcall(function()
    if not CONFIG.MONSTER_HATS then return end
    for _, d in ipairs(workspace:GetChildren()) do tryMonster(d) end
    connect(workspace.ChildAdded, tryMonster)
    for _, d in ipairs(workspace.CurrentCamera:GetChildren()) do tryMonster(d) end
    connect(workspace.CurrentCamera.ChildAdded, tryMonster)
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        if not rooms then return end
        for _, d in ipairs(rooms:GetDescendants()) do tryMonster(d) end
        connect(rooms.DescendantAdded, tryMonster)
    end)
end)
report("MonsterHats", okMonsters, errMonsters)

---------------------------------------------------------------- новогодняя погоня Сика

-- Сик бежит в шарфе в красно-белую полоску и с гирляндой по телу (шапку надевает блок выше).
-- Вместо чёрной жижи — снег: лужа под ним (SeekPuddle) — сугроб, у ног — снежное облачко,
-- за ним тянется шлейф снежинок, чёрные капли с тела и с потолка — белые. Руки из стен
-- (Seek_Arm) — в полоску, как леденцовая трость. Падающая люстра (ChandelierObstruction)
-- при ударе об пол — искры и конфетти. Всё только у тебя на экране.
do
    local SNOW_WHITE = Color3.fromRGB(236, 243, 255)
    local CANDY_RED = Color3.fromRGB(205, 28, 40)
    local CANDY_WHITE = Color3.fromRGB(250, 247, 242)
    local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
    local SEEK_NAMES = { SeekMoving = true, SeekMovingNewClone = true }
    local seekDone = setmetatable({}, { __mode = "k" })
    local obstacleDone = setmetatable({}, { __mode = "k" })

    -- тёмные частицы (жижа, капли) — в снег; светлые эффекты не трогаем
    local function snowEmitter(e)
        local c = e.Color.Keypoints[1].Value
        if c.R + c.G + c.B < 0.75 then
            setLocal(e, "Color", ColorSequence.new(SNOW_WHITE))
            setLocal(e, "LightEmission", math.max(e.LightEmission, 0.25))
        end
    end

    -- Шарф: кольцо полосатых кусочков вокруг шеи (приварено к туловищу) и два хвоста сзади,
    -- которые развеваются за Сиком на бегу (их каждый кадр ставим заново)
    local function seekScarf(outfit, rig, torso)
        local head = rig:FindFirstChild("Head", true)
        local neck = rig:FindFirstChild("Neck", true)
        local s = torso.Size
        local base = (neck and neck:IsA("Motor6D") and neck.Part0 == torso) and neck.C0.Position
            or Vector3.new(0, s.Y / 2, 0)
        local hs = (head and head:IsA("BasePart")) and head.Size or Vector3.new(1, 1.2, 1)
        local rx = math.clamp(hs.X * 0.52, 0.35, 1.2)
        local rz = math.clamp(hs.Z * 0.45, 0.3, 1.1)
        local y = base.Y - 0.08
        local N = 14
        local function ringPoint(k)
            local a = 2 * math.pi * k / N
            return Vector3.new(base.X + math.cos(a) * rx, y, base.Z + math.sin(a) * rz)
        end
        for k = 0, N - 1 do
            local a, b = ringPoint(k), ringPoint(k + 1)
            local p = Instance.new("Part")
            p.Name = "Scarf"
            p.Size = Vector3.new((b - a).Magnitude + 0.08, 0.34, 0.2)
            p.Color = (k % 2 == 0) and CANDY_RED or CANDY_WHITE
            p.Material = Enum.Material.Fabric
            p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
            p.Parent = outfit
            weldTo(torso, p, CFrame.fromMatrix((a + b) / 2, (b - a).Unit, Vector3.yAxis))
        end
        -- узел сзади шеи (у туловища +Z — спина)
        local knotLocal = Vector3.new(base.X, y - 0.04, base.Z + rz + 0.06)
        local knot = Instance.new("Part")
        knot.Name = "ScarfKnot"
        knot.Shape = Enum.PartType.Ball
        knot.Size = Vector3.new(0.3, 0.3, 0.3)
        knot.Color = CANDY_RED
        knot.Material = Enum.Material.Fabric
        knot.Parent = outfit
        weldTo(torso, knot, CFrame.new(knotLocal))

        local SEG, COUNT = 0.28, 6
        local tails, all = {}, {}
        for t = 1, 2 do
            local segs = {}
            for i = 1, COUNT do
                local p = decorPart({
                    Name = "ScarfTail", Size = Vector3.new(t == 1 and 0.3 or 0.26, 0.07, SEG + 0.04),
                    Color = (i % 2 == 0) and CANDY_RED or CANDY_WHITE, Material = Enum.Material.Fabric,
                    CFrame = torso.CFrame,
                })
                p.Parent = outfit
                table.insert(segs, p)
                table.insert(all, p)
            end
            tails[t] = segs
        end
        local lastPos, motion, speed = torso.Position, nil, 0
        local t0 = os.clock()
        local conn
        conn = connect(RunService.Heartbeat, function(dt)
            if not (torso.Parent and outfit.Parent) then conn:Disconnect() return end
            local pos = torso.Position
            local v = (pos - lastPos) / math.max(dt, 1e-3)
            lastPos = pos
            local flat = Vector3.new(v.X, 0, v.Z)
            local sp = flat.Magnitude
            if sp > 300 then sp = 0 end -- телепорт (выход из-под пола), не бег
            speed += (sp - speed) * math.min(1, dt * 5)
            if sp > 3 and sp <= 300 then
                motion = motion and (motion + (flat.Unit - motion) * math.min(1, dt * 6)) or flat.Unit
            end
            local back = (motion and motion.Magnitude > 1e-3) and -motion.Unit or Vector3.zero
            local lift = math.clamp(speed / 22, 0, 1) -- быстрее бежит — хвосты горизонтальнее
            local side = back:Cross(Vector3.yAxis)
            side = side.Magnitude > 1e-3 and side.Unit or torso.CFrame.RightVector
            local origin = torso.CFrame:PointToWorldSpace(knotLocal)
            local tm = os.clock() - t0
            local cfs = table.create(#all)
            for ti, segs in ipairs(tails) do
                local p = origin + side * (ti == 1 and 0.1 or -0.1)
                for i = 1, #segs do
                    local w = i / #segs
                    local wave = math.sin(tm * 11 + i * 0.9 + ti * 1.7) * 0.4 * w * (0.3 + lift)
                    local bob = math.cos(tm * 9 + i + ti) * 0.18 * w * lift
                    local dir = back * lift + Vector3.yAxis * (bob - (1 - lift) - 0.2) + side * wave
                    dir = dir.Magnitude > 1e-3 and dir.Unit or -Vector3.yAxis
                    local q = p + dir * SEG
                    -- ширина — вбок, длина — вдоль хвоста
                    local sx = side - dir * side:Dot(dir)
                    sx = sx.Magnitude > 1e-3 and sx.Unit or torso.CFrame.RightVector
                    table.insert(cfs, CFrame.fromMatrix((p + q) / 2, sx, (-dir):Cross(sx)))
                    p = q
                end
            end
            pcall(function() workspace:BulkMoveTo(all, cfs, Enum.BulkMoveMode.FireCFrameChanged) end)
        end)
    end

    -- гирлянда спиралью по туловищу: провод и мигающие лампочки (мигают с остальными гирляндами)
    local function seekGarland(outfit, torso)
        local s = torso.Size
        local turns, n = 1.6, 30
        local phase = math.random() * math.pi * 2
        local pts = {}
        for k = 0, n do
            local t = k / n
            local a = phase + t * turns * 2 * math.pi
            local rx = s.X * 0.5 * (0.66 + 0.2 * t) + 0.04
            local rz = s.Z * 0.5 + 0.07
            table.insert(pts, Vector3.new(math.cos(a) * rx, (-0.42 + 0.66 * t) * s.Y, math.sin(a) * rz))
        end
        for k = 1, #pts - 1 do
            local a, b = pts[k], pts[k + 1]
            local w = Instance.new("Part")
            w.Name = "SeekWire"
            w.Shape = Enum.PartType.Cylinder
            w.Size = Vector3.new((b - a).Magnitude + 0.05, 0.06, 0.06)
            w.Color = WIRE_COLOR
            w.Material = Enum.Material.SmoothPlastic
            w.Parent = outfit
            weldTo(torso, w, CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0))
        end
        for k = 1, #pts, 2 do
            local b = addBulb(outfit, torso.CFrame * CFrame.new(pts[k]), 0.2, (k + 1) // 2, 4, 6)
            if b then weldTo(torso, b, CFrame.new(pts[k])) end
        end
    end

    -- снег вместо жижи у самого Сика
    local function seekSnow(model)
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ParticleEmitter") then
                snowEmitter(d)
            elseif d:IsA("Beam") and d.Name == "StringCheese" then
                keepHidden(d, "Enabled", false) -- чёрные «нити» жижи между телом и лужей
            end
        end
        local puddle = model:FindFirstChild("SeekPuddle", true)
        if not (puddle and puddle:IsA("BasePart")) then return end
        setLocal(puddle, "Color", SNOW_WHITE)
        setLocal(puddle, "Material", Enum.Material.Snow)
        -- снежное облачко вокруг ног
        local puff = Instance.new("ParticleEmitter")
        puff.Name = "NewYearSnowPuff"
        puff.Texture = "rbxasset://textures/particles/smoke_main.dds"
        puff.Color = ColorSequence.new(SNOW_WHITE)
        puff.LightInfluence = 0.8
        puff.LightEmission = 0.15
        puff.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 6.5) })
        puff.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.6), NumberSequenceKeypoint.new(1, 1),
        })
        puff.Lifetime = NumberRange.new(1.4, 2.4)
        puff.Rate = 14
        puff.Speed = NumberRange.new(0.5, 2.5)
        puff.SpreadAngle = Vector2.new(180, 180)
        puff.Acceleration = Vector3.new(0, 1.2, 0)
        puff.RotSpeed = NumberRange.new(-25, 25)
        puff.Rotation = NumberRange.new(0, 360)
        puff.Parent = puddle
        track(puff)
        -- шлейф снежинок: вылетают вверх и медленно оседают позади
        local flakes = Instance.new("ParticleEmitter")
        flakes.Name = "NewYearSnowTrail"
        flakes.Texture = SPARKLE
        flakes.Color = ColorSequence.new(SNOW_WHITE)
        flakes.LightEmission = 0.6
        flakes.LightInfluence = 0.5
        flakes.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.22), NumberSequenceKeypoint.new(1, 0.1) })
        flakes.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.8, 0.25), NumberSequenceKeypoint.new(1, 1),
        })
        flakes.Lifetime = NumberRange.new(2.5, 4)
        flakes.Rate = 55
        flakes.Speed = NumberRange.new(4, 9)
        flakes.EmissionDirection = Enum.NormalId.Top
        flakes.SpreadAngle = Vector2.new(70, 70)
        flakes.Acceleration = Vector3.new(0, -5, 0)
        flakes.Drag = 1.2
        flakes.RotSpeed = NumberRange.new(-90, 90)
        flakes.Rotation = NumberRange.new(0, 360)
        flakes.Parent = puddle
        track(flakes)
    end

    local function dressSeek(m)
        local rig = m:FindFirstChild("SeekRig") or m:WaitForChild("SeekRig", 3) or m
        local torso = rig:FindFirstChild("UpperTorso", true)
        if CONFIG.SEEK_OUTFIT and torso and torso:IsA("BasePart") then
            local outfit = Instance.new("Model")
            outfit.Name = "NewYearSeek"
            local ok, err = pcall(seekGarland, outfit, torso)
            if not ok then warn("[NewYear] Гирлянда на Сике: " .. tostring(err)) end
            outfit.Parent = m
            track(outfit)
            ok, err = pcall(seekScarf, outfit, rig, torso)
            if not ok then warn("[NewYear] Шарф Сика: " .. tostring(err)) end
        end
        if CONFIG.SEEK_SNOW then
            local ok, err = pcall(seekSnow, m)
            if not ok then warn("[NewYear] Снег у Сика: " .. tostring(err)) end
        end
    end

    local function onSeek(m)
        if not (m:IsA("Model") and SEEK_NAMES[m.Name]) or seekDone[m] then return end
        seekDone[m] = true
        task.delay(0.4, function()
            if m.Parent then dressSeek(m) end
        end)
    end

    -- руки из стен: белые с красной диагональной полосой (картинка textures/candy_stripes.png
    -- накладывается на все стороны деталей); нет картинки — просто чередуем белое и красное
    local stripeTex
    local function candyTexture()
        if stripeTex ~= nil then return stripeTex or nil end
        stripeTex = false
        local file = CONFIG.CANDY_STRIPES_FILE
        local has = isfile and isfile(file)
        if not has and writefile then
            -- нет в workspace — докачиваем с GitHub
            local ok, data = pcall(game.HttpGet, game, CONFIG.ASSETS_URL .. "textures/candy_stripes.png")
            if ok and type(data) == "string" and data:sub(2, 4) == "PNG" then
                pcall(function()
                    if makefolder and not isfolder("StevieBuddy") then makefolder("StevieBuddy") end
                    if makefolder and not isfolder("StevieBuddy/textures") then makefolder("StevieBuddy/textures") end
                    writefile(file, data)
                end)
                has = isfile and isfile(file)
            end
        end
        if has and getcustomasset then
            local ok, id = pcall(getcustomasset, file)
            if ok and id then stripeTex = id end
        end
        return stripeTex or nil
    end
    local FACES = Enum.NormalId:GetEnumItems()
    local function candyArm(model)
        local tex = candyTexture()
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.9 then
                local sz = { p.Size.X, p.Size.Y, p.Size.Z }
                table.sort(sz)
                if tex then
                    setLocal(p, "Color", CANDY_WHITE)
                    -- полоса в ширину примерно как толщина детали: на пальцах мельче, на руке крупнее
                    local tile = math.clamp(sz[2] * 0.9, 0.5, 1.6)
                    for _, f in ipairs(FACES) do
                        local t = Instance.new("Texture")
                        t.Name = "NewYearCandy"
                        t.Texture = tex
                        t.Face = f
                        t.StudsPerTileU, t.StudsPerTileV = tile, tile
                        t.Parent = p
                        track(t)
                    end
                else
                    setLocal(p, "Color", p.Name:find("Top", 1, true) and CANDY_RED or CANDY_WHITE)
                end
                setLocal(p, "Material", Enum.Material.SmoothPlastic)
                setLocal(p, "Reflectance", 0.08)
            end
        end
    end

    -- чёрные капли с потолка там, откуда растёт рука или висит люстра (частицы на детали Base)
    local function snowBase(model)
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ParticleEmitter") and d.Parent and d.Parent.Name == "Base" then snowEmitter(d) end
        end
    end

    -- праздничный «бабах»: цветные искры, вспышка и конфетти, которое разлетается и падает на пол
    local function festiveBurst(pos)
        local holder = decorPart({ Name = "NewYearSparks", Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2),
            CFrame = CFrame.new(pos) })
        holder.Parent = root
        local colors = { Color3.fromRGB(255, 205, 80), Color3.fromRGB(255, 70, 70),
            Color3.fromRGB(90, 230, 120), Color3.fromRGB(120, 180, 255) }
        for _, col in ipairs(colors) do
            local e = Instance.new("ParticleEmitter")
            e.Texture = SPARKLE
            e.Color = ColorSequence.new(col)
            e.LightEmission = 1
            pcall(function() e.Brightness = 2 end)
            e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
            e.Lifetime = NumberRange.new(0.6, 1.3)
            e.Speed = NumberRange.new(10, 22)
            e.SpreadAngle = Vector2.new(180, 180)
            e.Acceleration = Vector3.new(0, -30, 0)
            e.Drag = 1.5
            e.Rotation = NumberRange.new(0, 360)
            e.Rate = 0
            e.Parent = holder
            e:Emit(22)
        end
        local light = Instance.new("PointLight")
        light.Color = colors[1]
        light.Brightness = 5
        light.Range = 20
        light.Shadows = false
        light.Parent = holder
        game:GetService("TweenService"):Create(light, TweenInfo.new(0.8), { Brightness = 0 }):Play()
        local rnd = Random.new()
        for _ = 1, 36 do
            local c = decorPart({
                Name = "Confetti", Size = Vector3.new(0.16, 0.02, 0.1),
                Color = colors[rnd:NextInteger(1, #colors)], Material = Enum.Material.SmoothPlastic,
                CFrame = CFrame.new(pos + rnd:NextUnitVector() * 0.6)
                    * CFrame.Angles(rnd:NextNumber(0, 6.3), rnd:NextNumber(0, 6.3), rnd:NextNumber(0, 6.3)),
            })
            c.Anchored, c.CanCollide, c.Massless = false, true, false
            c.Parent = holder
            local dir = rnd:NextUnitVector()
            c.AssemblyLinearVelocity = Vector3.new(dir.X * 12, 6 + math.abs(dir.Y) * 12, dir.Z * 12)
            c.AssemblyAngularVelocity = rnd:NextUnitVector() * 25
            game:GetService("Debris"):AddItem(c, rnd:NextNumber(3, 4.5))
        end
        game:GetService("Debris"):AddItem(holder, 5)
    end

    -- люстра падает анимацией: опустилась больше чем на 3 studs и перестала падать — удар
    local function watchChandelier(model)
        local fixture = model:FindFirstChild("LightFixture", true)
        if not (fixture and fixture:IsA("BasePart")) then return end
        local y0 = fixture.Position.Y
        local lastY = y0
        local conn
        conn = connect(RunService.Heartbeat, function()
            if not fixture.Parent then conn:Disconnect() return end
            local y = fixture.Position.Y
            if y < y0 - 3 and y >= lastY - 0.01 then
                conn:Disconnect()
                festiveBurst(fixture.Position - Vector3.new(0, 0.4, 0))
            end
            lastY = y
        end)
    end

    local function onObstacle(d)
        if not d:IsA("Model") or obstacleDone[d] then return end
        if d.Name == "Seek_Arm" then
            obstacleDone[d] = true
            if CONFIG.SEEK_CANDY_ARMS then
                local ok, err = pcall(candyArm, d)
                if not ok then warn("[NewYear] Рука Сика: " .. tostring(err)) end
            end
            if CONFIG.SEEK_SNOW then pcall(snowBase, d) end
        elseif d.Name == "ChandelierObstruction" then
            obstacleDone[d] = true
            if CONFIG.SEEK_SNOW then pcall(snowBase, d) end
            if CONFIG.CHANDELIER_SPARKS then
                local ok, err = pcall(watchChandelier, d)
                if not ok then warn("[NewYear] Люстра в погоне: " .. tostring(err)) end
            end
        end
    end

    local okSeek, errSeek = pcall(function()
        if CONFIG.SEEK_OUTFIT or CONFIG.SEEK_SNOW then
            for _, d in ipairs(workspace:GetChildren()) do onSeek(d) end
            connect(workspace.ChildAdded, onSeek)
        end
        if CONFIG.SEEK_CANDY_ARMS or CONFIG.SEEK_SNOW or CONFIG.CHANDELIER_SPARKS then
            task.spawn(function()
                local rooms = workspace:WaitForChild("CurrentRooms", 30)
                if not rooms then return end
                for _, d in ipairs(rooms:GetDescendants()) do onObstacle(d) end
                connect(rooms.DescendantAdded, function(d)
                    if d:IsA("Model") and (d.Name == "Seek_Arm" or d.Name == "ChandelierObstruction") then
                        task.delay(0.5, onObstacle, d)
                    end
                end)
            end)
        end
    end)
    report("SeekChase", okSeek, errSeek)
end

---------------------------------------------------------------- шоколадные монеты и свечи

local okTreats, errTreats = pcall(function()
    if not (CONFIG.CHOCO_COINS or CONFIG.FESTIVE_CANDLES or CONFIG.TABLE_CLUTTER or CONFIG.CHEST_GIFTS) then return end
    local TAU = math.pi * 2

    local function roomOf(inst)
        local rooms = workspace:FindFirstChild("CurrentRooms")
        local node = inst
        while node and node.Parent ~= rooms do node = node.Parent end
        return node
    end

    -- оригинал прячем «местной» прозрачностью: игра свою Transparency меняет как хочет, а наше
    -- украшение показываем, только пока оригинал (по мнению игры) виден
    local function shadow(part, parts)
        setLocal(part, "LocalTransparencyModifier", 1)
        connect(part:GetPropertyChangedSignal("LocalTransparencyModifier"), function()
            if part.LocalTransparencyModifier < 1 then part.LocalTransparencyModifier = 1 end
        end)
    end
    local function followVisibility(part, parts)
        local base = {}
        for _, p in ipairs(parts) do base[p] = p.Transparency end
        local function sync()
            local vis = part.Parent ~= nil and part.Transparency < 0.95
            for _, p in ipairs(parts) do
                if p.Parent then p.Transparency = vis and base[p] or 1 end
            end
        end
        connect(part:GetPropertyChangedSignal("Transparency"), sync)
        sync()
    end

    ------------------------------------------------ шоколадные монеты

    -- Золото в DOORS — кучка (GoldVisualHolder) из одной или нескольких деталей-мешей; по размеру
    -- кучки видно, сколько золота: одна монетка, несколько, много или очень много. Под каждую —
    -- своя раскладка шоколадных монет: одна; стопочка и пара рядом; стопки и россыпь; целая горка.
    local FOIL_GOLD = Color3.fromRGB(226, 178, 58)
    local FOIL_SILVER = Color3.fromRGB(206, 209, 216)
    local CHOC = Color3.fromRGB(88, 50, 30)
    local holderDone = setmetatable({}, { __mode = "k" })
    local coinCount = 0
    local tierCount = { 0, 0, 0, 0 }

    local function coinColor()
        local roll = math.random()
        if roll < 0.07 then return CHOC, Enum.Material.SmoothPlastic end -- развёрнутая шоколадка
        if roll < 0.24 then return FOIL_SILVER, Enum.Material.Foil end
        return FOIL_GOLD, Enum.Material.Foil
    end
    -- монета: плоский цилиндр; cf — центр, ось монеты — UpVector
    local function coin(model, parts, cf, d)
        local th = d * 0.13
        local col, mat = coinColor()
        local ccf = cf * CFrame.Angles(0, 0, math.pi / 2)
        local c = decorPart({ Name = "Coin", Shape = Enum.PartType.Cylinder, Size = Vector3.new(th, d, d),
            CFrame = ccf, Color = col, Material = mat, Reflectance = mat == Enum.Material.Foil and 0.12 or 0 })
        c.Parent = model
        table.insert(parts, c)
        if mat == Enum.Material.Foil then
            -- выпуклая середина с обеих сторон, как чеканка
            local face = decorPart({ Name = "CoinFace", Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(th * 1.25, d * 0.72, d * 0.72), CFrame = ccf,
                Color = col:Lerp(Color3.new(0, 0, 0), 0.12), Material = Enum.Material.Foil, Reflectance = 0.2 })
            face.Parent = model
            table.insert(parts, face)
        end
    end
    local function rnd(a, b) return a + math.random() * (b - a) end
    local function flat(frame, x, y, z, tilt)
        tilt = tilt or 6
        return frame * CFrame.new(x, y, z) * CFrame.Angles(0, rnd(0, math.pi * 2), 0)
            * CFrame.Angles(math.rad(rnd(-tilt, tilt)), 0, math.rad(rnd(-tilt, tilt)))
    end
    -- стопка из n монет: чуть разъехавшаяся, сверху может лежать косо
    local function stack(model, parts, frame, x, z, n, d)
        local th = d * 0.13
        for i = 0, n - 1 do
            local jx, jz = rnd(-0.06, 0.06) * d, rnd(-0.06, 0.06) * d
            coin(model, parts, flat(frame, x + jx, th / 2 + i * th * 0.98, z + jz, 3), d)
        end
    end
    -- монета прислонена к чему-то: лежит с наклоном наружу
    local function leaning(model, parts, frame, x, z, d, outward)
        local a = math.atan2(z, x)
        local tilt = math.rad(rnd(18, 32))
        local cf = frame * CFrame.new(x, d * 0.5 * math.sin(tilt) + d * 0.07, z)
            * CFrame.Angles(0, -a + math.pi / 2, 0) * CFrame.Angles(outward and tilt or -tilt, 0, 0)
        coin(model, parts, cf, d)
    end

    local function layoutOne(model, parts, frame, d)
        coin(model, parts, flat(frame, 0, d * 0.065, 0, 8), d)
    end
    local function layoutFew(model, parts, frame, d)
        stack(model, parts, frame, 0, 0, 2, d)
        for k = 1, 2 do
            local a = rnd(0, math.pi * 2) + k * math.pi
            leaning(model, parts, frame, math.cos(a) * d * 0.75, math.sin(a) * d * 0.75, d, true)
        end
    end
    local function layoutMany(model, parts, frame, d, fx, fz)
        stack(model, parts, frame, -fx * 0.18, -fz * 0.1, 4, d)
        stack(model, parts, frame, fx * 0.2, fz * 0.15, 2, d)
        for _ = 1, 4 do
            local x, z = rnd(-0.38, 0.38) * fx, rnd(-0.38, 0.38) * fz
            coin(model, parts, flat(frame, x, d * 0.065, z, 14), d)
        end
        leaning(model, parts, frame, -fx * 0.18 + d * 0.62, -fz * 0.1, d, true)
    end
    local function layoutHeap(model, parts, frame, d, fx, fz, fy)
        -- горка: кольца монет, каждое выше и уже, наклонены наружу, наверху одна плашмя
        local th = d * 0.13
        local rings = { { 9, 0.42, 0.0, 24 }, { 7, 0.3, 0.32, 26 }, { 4, 0.17, 0.62, 22 } }
        local hk = math.max(fy, d * 0.6)
        for _, r in ipairs(rings) do
            local n, rad, h, tilt = r[1], r[2], r[3], r[4]
            local off = rnd(0, math.pi * 2)
            for i = 1, n do
                local a = off + i / n * math.pi * 2
                local x, z = math.cos(a) * rad * fx, math.sin(a) * rad * fz
                local cf = frame * CFrame.new(x, th + h * hk, z) * CFrame.Angles(0, -a + math.pi / 2, 0)
                    * CFrame.Angles(math.rad(tilt + rnd(-6, 6)), 0, math.rad(rnd(-5, 5)))
                coin(model, parts, cf, d)
            end
        end
        coin(model, parts, flat(frame, 0, hk * 0.85, 0, 10), d)
        coin(model, parts, flat(frame, rnd(-0.1, 0.1) * fx, hk * 0.55, rnd(-0.1, 0.1) * fz, 15), d)
        -- рядом высокая стопка и пара скатившихся
        stack(model, parts, frame, fx * 0.5, -fz * 0.35, 5, d)
        for _ = 1, 2 do
            local a = rnd(0, math.pi * 2)
            coin(model, parts, flat(frame, math.cos(a) * fx * 0.62, d * 0.065, math.sin(a) * fz * 0.62, 12), d)
        end
    end

    local function chocolateFor(holder)
        if holderDone[holder] then return end
        local vis = {}
        for _, d in ipairs(holder:GetDescendants()) do
            if d:IsA("BasePart") then table.insert(vis, d) end
        end
        if #vis == 0 then return end
        holderDone[holder] = true
        local room = roomOf(holder)
        if not room then return end
        -- общая рамка всех деталей кучки (в осях мира)
        local lo = Vector3.new(math.huge, math.huge, math.huge)
        local hi = -lo
        for _, p in ipairs(vis) do
            local cf, sz = p.CFrame, p.Size / 2
            local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
            local ext = Vector3.new(
                math.abs(r.X) * sz.X + math.abs(u.X) * sz.Y + math.abs(l.X) * sz.Z,
                math.abs(r.Y) * sz.X + math.abs(u.Y) * sz.Y + math.abs(l.Y) * sz.Z,
                math.abs(r.Z) * sz.X + math.abs(u.Z) * sz.Y + math.abs(l.Z) * sz.Z)
            lo = lo:Min(cf.Position - ext)
            hi = hi:Max(cf.Position + ext)
        end
        local size = hi - lo
        local fx, fy, fz = size.X, size.Y, size.Z
        local main = vis[1]
        local yaw = math.atan2(-main.CFrame.LookVector.X, -main.CFrame.LookVector.Z)
        local frame = CFrame.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2) * CFrame.Angles(0, yaw, 0)
        -- сколько золота: по высоте и площади кучки
        local area = fx * fz
        local tier
        if fy < 0.09 then
            tier = 1
        elseif area < 0.4 then
            tier = 2
        elseif fy < 0.3 then
            tier = 3
        else
            tier = 4
        end
        tierCount[tier] += 1
        local model = Instance.new("Model")
        model.Name = "ChocoCoins"
        local parts = {}
        if tier == 1 then
            layoutOne(model, parts, frame, math.clamp(math.min(fx, fz) * 0.8, 0.22, 0.42))
        elseif tier == 2 then
            layoutFew(model, parts, frame, math.clamp(math.min(fx, fz) * 0.55, 0.2, 0.3))
        elseif tier == 3 then
            layoutMany(model, parts, frame, 0.26, math.max(fx, 0.5), math.max(fz, 0.5))
        else
            layoutHeap(model, parts, frame, 0.26, math.max(fx, 0.6), math.max(fz, 0.6), fy)
        end
        if CONFIG.SCAN then
            print(("[NewYear] Золото %s: %.2f x %.2f x %.2f, деталей %d -> раскладка %d"):format(
                holder:GetFullName(), fx, fy, fz, #vis, tier))
        end
        model.WorldPivot = main.CFrame
        -- оригинал прячем; монеты видны, пока игра показывает хоть одну деталь кучки
        local base = {}
        for _, p in ipairs(parts) do base[p] = p.Transparency end
        local function sync()
            local any = false
            for _, p in ipairs(vis) do
                if p.Parent and p.Transparency < 0.95 then any = true break end
            end
            for _, p in ipairs(parts) do
                if p.Parent then p.Transparency = any and base[p] or 1 end
            end
        end
        for _, p in ipairs(vis) do
            shadow(p)
            connect(p:GetPropertyChangedSignal("Transparency"), sync)
        end
        sync()
        -- кучку двигают (собрал — летит к тебе) — монеты за ней
        connect(main:GetPropertyChangedSignal("CFrame"), function()
            if model.Parent then model:PivotTo(main.CFrame) end
        end)
        connect(holder.AncestryChanged, function()
            if not holder:IsDescendantOf(workspace) then model:Destroy() end
        end)
        model.Parent = roomFolder(room)
        coinCount += 1
    end

    ------------------------------------------------ свечи

    local WAX = { Color3.fromRGB(190, 28, 38), Color3.fromRGB(190, 28, 38), Color3.fromRGB(35, 110, 60),
        Color3.fromRGB(245, 240, 228) }
    local HOLLY = Color3.fromRGB(30, 100, 45)
    local BERRY = Color3.fromRGB(205, 25, 35)
    local RIBBON_GOLD = Color3.fromRGB(235, 185, 60)
    local candleDone = setmetatable({}, { __mode = "k" })
    local roomCenter = {}
    local candleCount = 0

    local function isWax(p)
        local n = p.Name:lower()
        return n:find("stick", 1, true) or n == "candle" or n:find("wax", 1, true)
    end
    local function centerOf(room)
        if not roomCenter[room] then
            local ok, cf = pcall(function() return (room:GetBoundingBox()) end)
            roomCenter[room] = ok and cf.Position or room:GetPivot().Position
        end
        return roomCenter[room]
    end
    local function ellipsoid(props)
        local p = decorPart(props)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Parent = p
        return p
    end

    local function festiveCandle(model)
        if candleDone[model] then return end
        candleDone[model] = true
        local room = roomOf(model)
        if not room then return end
        for _, wax in ipairs(model:GetDescendants()) do
            if wax:IsA("BasePart") and isWax(wax) and wax.Transparency < 0.99 and wax.CFrame.UpVector.Y > 0.8 then
                local col = WAX[math.random(#WAX)]
                setLocal(wax, "Color", col)
                pcall(setLocal, wax, "Material", Enum.Material.SmoothPlastic)
                local ribbon = col == WAX[1] and RIBBON_GOLD or BERRY
                local s = math.max(wax.Size.X, wax.Size.Z) / 0.33
                local waxR = math.max(wax.Size.X, wax.Size.Z) / 2
                local up = Vector3.yAxis
                local bottom = wax.Position - up * wax.Size.Y / 2
                local deco = Instance.new("Model")
                deco.Name = "FestiveCandle"
                local parts = {}
                local function put(p)
                    p.Parent = deco
                    table.insert(parts, p)
                end
                -- остролист у подножия свечи: три листа и гроздь ягод
                local a0 = math.random() * TAU
                for i = 0, 2 do
                    local a = a0 + i * TAU / 3 + (math.random() - 0.5) * 0.4
                    local radial = Vector3.new(math.cos(a), 0, math.sin(a))
                    local pos = bottom + radial * (waxR + 0.1 * s) + up * 0.03 * s
                    put(ellipsoid({ Name = "Holly", Size = Vector3.new(0.12 * s, 0.025 * s, 0.3 * s), Color = HOLLY,
                        Material = Enum.Material.SmoothPlastic, Reflectance = 0.1,
                        CFrame = CFrame.lookAt(pos, pos + radial) * CFrame.Angles(math.rad(18), 0, math.rad(math.random(-15, 15))) }))
                end
                local ba = a0 + TAU / 6
                local bpos = bottom + Vector3.new(math.cos(ba), 0, math.sin(ba)) * (waxR + 0.05 * s) + up * 0.06 * s
                for i = 0, 2 do
                    local off = Vector3.new(math.cos(i * 2.1), 0.3 * (i % 2), math.sin(i * 2.1)) * 0.045 * s
                    put(decorPart({ Name = "Berry", Shape = Enum.PartType.Ball, Size = Vector3.new(0.07, 0.07, 0.07) * s,
                        Color = BERRY, Material = Enum.Material.SmoothPlastic, Reflectance = 0.15, CFrame = CFrame.new(bpos + off) }))
                end
                -- лента вокруг свечи и бантик спереди (к середине комнаты)
                local toC = centerOf(room) - wax.Position
                toC = Vector3.new(toC.X, 0, toC.Z)
                local dir = toC.Magnitude > 0.01 and toC.Unit or Vector3.new(0, 0, -1)
                local bandY = wax.Position.Y - wax.Size.Y * 0.18
                put(decorPart({ Name = "Ribbon", Shape = Enum.PartType.Cylinder,
                    Size = Vector3.new(0.05 * s, waxR * 2.08, waxR * 2.08), Color = ribbon, Material = Enum.Material.Fabric,
                    CFrame = CFrame.new(wax.Position.X, bandY, wax.Position.Z) * CFrame.Angles(0, 0, math.pi / 2) }))
                local bowCF = CFrame.lookAt(Vector3.new(wax.Position.X, bandY, wax.Position.Z) + dir * (waxR + 0.015 * s),
                    Vector3.new(wax.Position.X, bandY, wax.Position.Z) + dir * 2)
                for _, sx in ipairs({ -1, 1 }) do
                    put(ellipsoid({ Name = "BowLoop", Size = Vector3.new(0.13 * s, 0.08 * s, 0.035 * s), Color = ribbon,
                        Material = Enum.Material.Fabric,
                        CFrame = bowCF * CFrame.new(sx * 0.06 * s, 0.01 * s, -0.01 * s) * CFrame.Angles(0, 0, math.rad(sx * 22)) }))
                    put(decorPart({ Name = "BowTail", Size = Vector3.new(0.03 * s, 0.1 * s, 0.01 * s), Color = ribbon,
                        Material = Enum.Material.Fabric,
                        CFrame = bowCF * CFrame.new(sx * 0.025 * s, -0.055 * s, -0.012 * s) * CFrame.Angles(0, 0, math.rad(sx * 18)) }))
                end
                put(decorPart({ Name = "BowKnot", Shape = Enum.PartType.Ball, Size = Vector3.new(0.045, 0.045, 0.045) * s,
                    Color = ribbon, Material = Enum.Material.Fabric, CFrame = bowCF * CFrame.new(0, 0.01 * s, -0.02 * s) }))
                followVisibility(wax, parts)
                deco.Parent = roomFolder(room)
                candleCount += 1
            end
        end
    end

    ------------------------------------------------ мелочи на столах (кучки LootHolder.SpawnPile)

    -- бумажки -> новогодние открытки, брусочки -> подарки с лентой и бантиком
    local clutterDone = setmetatable({}, { __mode = "k" })
    local CARD_TEX = { "textures/card_snow.png", "textures/card_tree.png" }
    local GIFT_WRAP = {
        { Color3.fromRGB(200, 35, 45), Color3.fromRGB(255, 205, 80) },
        { Color3.fromRGB(35, 130, 70), Color3.fromRGB(245, 245, 240) },
        { Color3.fromRGB(45, 95, 200), Color3.fromRGB(255, 205, 80) },
    }
    local function festiveClutter(part)
        if clutterDone[part] or part.Transparency >= 0.95 then return end
        -- загрузчик картинок задаётся ниже по скрипту — если комнату обходим раньше, чуть ждём
        if not nyAsset then
            task.delay(1, function() pcall(festiveClutter, part) end)
            return
        end
        clutterDone[part] = true
        local room = roomOf(part)
        if not room then return end
        local sz = part.Size
        local thin = math.min(sz.X, sz.Y, sz.Z)
        if thin < 0.06 then
            -- бумажка: открытка (картинка на верхней грани)
            local tex = nyAsset(CARD_TEX[math.random(#CARD_TEX)])
            if not tex then return end
            setLocal(part, "Color", Color3.fromRGB(250, 250, 250))
            local face = Enum.NormalId.Top
            if sz.X == thin then face = Enum.NormalId.Right elseif sz.Z == thin then face = Enum.NormalId.Front end
            local d = Instance.new("Decal")
            d.Name = "NewYearCard"
            d.Texture = tex
            d.Face = face
            d.Parent = part
            track(d)
        elseif math.max(sz.X, sz.Y, sz.Z) < 2.5 then
            -- брусок: подарок — обёртка, лента крест-накрест, бантик сверху
            local wrap = GIFT_WRAP[math.random(#GIFT_WRAP)]
            setLocal(part, "Color", wrap[1])
            pcall(setLocal, part, "Material", Enum.Material.SmoothPlastic)
            local cf = part.CFrame
            local folder = roomFolder(room)
            local function piece(size, at)
                local p = decorPart({ Name = "GiftRibbon", Size = size, Color = wrap[2], Material = Enum.Material.Fabric,
                    CFrame = cf * at })
                p.Parent = folder
                return p
            end
            local r = math.min(sz.X, sz.Z) * 0.18
            piece(Vector3.new(sz.X + 0.02, sz.Y + 0.02, r), CFrame.identity)
            piece(Vector3.new(r, sz.Y + 0.02, sz.Z + 0.02), CFrame.identity)
            local b = math.min(sz.X, sz.Z) * 0.32
            for _, sx in ipairs({ -1, 1 }) do
                local loop = piece(Vector3.new(b, b * 0.6, b * 0.35),
                    CFrame.new(sx * b * 0.45, sz.Y / 2 + b * 0.22, 0) * CFrame.Angles(0, 0, math.rad(sx * 25)))
                local m = Instance.new("SpecialMesh")
                m.MeshType = Enum.MeshType.Sphere
                m.Parent = loop
            end
        end
    end

    ------------------------------------------------ сундуки -> большие подарки

    -- Сундук: модель с деталями Main (корпус) и Lid (крышка, её открывает анимация). Красим в обёртку,
    -- ленты крест-накрест приварены к корпусу и к крышке, бантик — на крышке (уезжает вместе с ней).
    local chestDone = setmetatable({}, { __mode = "k" })
    local function festiveChest(model)
        if chestDone[model] then return end
        local main, lid = model:FindFirstChild("Main"), model:FindFirstChild("Lid")
        if not (main and lid and main:IsA("BasePart") and lid:IsA("BasePart")) then return end
        chestDone[model] = true
        local wrap = GIFT_WRAP[math.random(#GIFT_WRAP)]
        for _, part in ipairs({ main, lid }) do
            setLocal(part, "Color", wrap[1])
            pcall(setLocal, part, "Material", Enum.Material.SmoothPlastic)
            if part:IsA("MeshPart") then pcall(setLocal, part, "TextureID", "") end
            for _, t in ipairs(part:GetChildren()) do
                if t:IsA("SurfaceAppearance") then pcall(setLocal, t, "Parent", nil) end
            end
        end
        local function ribbon(base, size, offset)
            local p = decorPart({ Name = "ChestRibbon", Size = size, Color = wrap[2], Material = Enum.Material.Fabric })
            weldTo(base, p, offset)
            p.Parent = root
            track(p)
            return p
        end
        -- лента — тонкие полоски по НАРУЖНЫМ граням (раньше были сплошные бруски и торчали внутри
        -- открытого сундука)
        local function bands(base, withTop)
            local sz = base.Size
            local r = math.min(sz.X, sz.Z) * 0.14
            local t = 0.05
            ribbon(base, Vector3.new(r, sz.Y, t), CFrame.new(0, 0, sz.Z / 2 + t / 2))
            ribbon(base, Vector3.new(r, sz.Y, t), CFrame.new(0, 0, -sz.Z / 2 - t / 2))
            ribbon(base, Vector3.new(t, sz.Y, r), CFrame.new(sz.X / 2 + t / 2, 0, 0))
            ribbon(base, Vector3.new(t, sz.Y, r), CFrame.new(-sz.X / 2 - t / 2, 0, 0))
            if withTop then
                ribbon(base, Vector3.new(sz.X + 2 * t, t, r), CFrame.new(0, sz.Y / 2 + t / 2, 0))
                ribbon(base, Vector3.new(r, t, sz.Z + 2 * t), CFrame.new(0, sz.Y / 2 + t / 2, 0))
            end
        end
        bands(main, false)
        bands(lid, true)
        -- бантик на крышке
        local ls = lid.Size
        local b = math.min(ls.X, ls.Z) * 0.3
        for _, sx in ipairs({ -1, 1 }) do
            local loop = ribbon(lid, Vector3.new(b, b * 0.6, b * 0.35),
                CFrame.new(sx * b * 0.45, ls.Y / 2 + b * 0.22, 0) * CFrame.Angles(0, 0, math.rad(sx * 25)))
            local m = Instance.new("SpecialMesh")
            m.MeshType = Enum.MeshType.Sphere
            m.Parent = loop
        end
        local knot = ribbon(lid, Vector3.new(b * 0.35, b * 0.35, b * 0.35), CFrame.new(0, ls.Y / 2 + b * 0.15, 0))
        knot.Shape = Enum.PartType.Ball
    end

    ------------------------------------------------ обход комнат

    local function consider(d)
        if CONFIG.CHEST_GIFTS and d:IsA("Model") and d:FindFirstChild("Lid") and d:FindFirstChild("Main")
            and d:FindFirstChild("LootHolder") then
            local ok, err = pcall(festiveChest, d)
            if not ok then warn("[NewYear] Сундук: " .. tostring(err)) end
        end
        if CONFIG.TABLE_CLUTTER and d:IsA("BasePart") and d.Parent and d.Parent.Name == "SpawnPile" then
            local ok, err = pcall(festiveClutter, d)
            if not ok then warn("[NewYear] Мелочи на столе: " .. tostring(err)) end
        end
        local holder = CONFIG.CHOCO_COINS and d:IsA("BasePart") and d:FindFirstAncestor("GoldVisualHolder")
        if holder then
            -- детали кучки догружаются по одной — собираем, когда все на месте
            if not holderDone[holder] then
                task.delay(0.25, function()
                    local ok, err = pcall(chocolateFor, holder)
                    if not ok then warn("[NewYear] Монеты: " .. tostring(err)) end
                end)
            end
        elseif d:IsA("Model") then
            local n = d.Name:lower()
            if CONFIG.FESTIVE_CANDLES and n:find("candle", 1, true) and not n:find("chandelier", 1, true) then
                local ok, err = pcall(festiveCandle, d)
                if not ok then warn("[NewYear] Свеча: " .. tostring(err)) end
            end
        end
    end
    local function scanRoom(room)
        for _, d in ipairs(room:GetDescendants()) do consider(d) end
    end
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do scanRoom(room) end
        connect(rooms.ChildAdded, function(room)
            task.delay(1, scanRoom, room)
            task.delay(4, scanRoom, room)
        end)
        -- золото появляется и позже (открыл ящик стола)
        connect(rooms.DescendantAdded, function(d)
            if d:IsA("BasePart") and CONFIG.CHOCO_COINS then
                task.delay(0.3, function()
                    if d.Parent then consider(d) end
                end)
            end
        end)
        task.delay(8, function()
            print(("[NewYear] Монеты: %d (одна %d, несколько %d, много %d, горка %d), свечи: %d, снеговики: %d"):format(
                coinCount, tierCount[1], tierCount[2], tierCount[3], tierCount[4], candleCount, snowmanCount))
        end)
    end)
end)
report("Treats", okTreats, errTreats)

local menuNotify -- уведомления в стиле меню (задаётся в разделе «меню настроек»)

---------------------------------------------------------------- праздник: хлопушки, двери, бахрома, камины, часы

-- файл из workspace/StevieBuddy (нет — докачиваем из ASSETS_URL) -> ссылка getcustomasset
local nyAssetCache = {}
function nyAsset(file)
    if nyAssetCache[file] ~= nil then return nyAssetCache[file] or nil end
    local path = "StevieBuddy/" .. file
    local url = false
    pcall(function()
        if not isfile(path) and CONFIG.ASSETS_URL ~= "" then
            local ok, data = pcall(game.HttpGet, game, CONFIG.ASSETS_URL .. file)
            if ok and type(data) == "string" and #data > 200 and not data:find("<html", 1, true)
                and not data:match("^404") then
                local dir = ""
                for part in path:gmatch("([^/]+)/") do
                    dir = dir .. part
                    if not isfolder(dir) then makefolder(dir) end
                    dir = dir .. "/"
                end
                writefile(path, data)
            end
        end
        if isfile(path) then url = getcustomasset(path) end
    end)
    nyAssetCache[file] = url
    return url or nil
end

local FESTIVE_COLORS = {
    Color3.fromRGB(220, 40, 50), Color3.fromRGB(255, 205, 60), Color3.fromRGB(40, 160, 80),
    Color3.fromRGB(60, 120, 230), Color3.fromRGB(240, 240, 245), Color3.fromRGB(230, 90, 170),
}

local function playNySound(file, volume, at)
    local id = nyAsset(file)
    if not id then return end
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = volume or 0.8
    s.RollOffMaxDistance = 120
    if typeof(at) == "Vector3" then
        local holder = decorPart({ Name = "NySound", Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(at) })
        holder.Parent = root
        s.Parent = holder
        game:GetService("Debris"):AddItem(holder, 8)
    else
        s.Parent = workspace.CurrentCamera or workspace
        game:GetService("Debris"):AddItem(s, 8)
    end
    s:Play()
end

-- Салют на экране (в DOORS кругом потолки — в небе его не видно): ракета взлетает, хлопает
-- и рассыпается искрами с хвостиками, искры падают и гаснут
local function screenFireworks(duration, withSound)
    local gui = Instance.new("ScreenGui")
    gui.Name = "NewYearFireworks"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 50
    pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("Players").LocalPlayer.PlayerGui end)
    if not gui.Parent then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    track(gui)
    local sparks = {}
    local function dot(size, color)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Size = UDim2.fromOffset(size, size)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = f
        f.Parent = gui
        return f
    end
    local function burst(x, y)
        local col = FESTIVE_COLORS[math.random(#FESTIVE_COLORS)]
        local col2 = FESTIVE_COLORS[math.random(#FESTIVE_COLORS)]
        local n = math.random(26, 40)
        local speed = 160 + math.random() * 140
        for i = 1, n do
            local a = i / n * math.pi * 2 + math.random() * 0.2
            local v = speed * (0.75 + math.random() * 0.35)
            table.insert(sparks, { f = dot(math.random(4, 7), math.random() < 0.7 and col or col2), x = x, y = y,
                vx = math.cos(a) * v, vy = math.sin(a) * v, life = 1.4 + math.random() * 0.6, age = 0, twinkle = math.random() < 0.3 })
        end
        local flash = dot(70, Color3.new(1, 1, 1))
        flash.Position = UDim2.fromOffset(x, y)
        flash.BackgroundTransparency = 0.5
        game:GetService("TweenService"):Create(flash, TweenInfo.new(0.35), { Size = UDim2.fromOffset(160, 160), BackgroundTransparency = 1 }):Play()
        game:GetService("Debris"):AddItem(flash, 0.4)
        if withSound then playNySound("sounds/ny_firework.mp3", 0.35) end
    end
    local function rocket()
        local cam = workspace.CurrentCamera
        local vs = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local x = vs.X * (0.15 + math.random() * 0.7)
        local y0, y1 = vs.Y + 10, vs.Y * (0.15 + math.random() * 0.3)
        local r = dot(5, Color3.fromRGB(255, 230, 170))
        table.insert(sparks, { f = r, x = x, y = y0, vx = (math.random() - 0.5) * 40, vy = -(y0 - y1) / 0.75,
            life = 0.75, age = 0, rocket = true })
    end
    local conn
    local t0, nextRocket = os.clock(), 0
    conn = RunService.RenderStepped:Connect(function(dt)
        local now = os.clock() - t0
        if now < duration and now >= nextRocket then
            rocket()
            nextRocket = now + 0.35 + math.random() * 0.5
        end
        for i = #sparks, 1, -1 do
            local s = sparks[i]
            s.age += dt
            if s.rocket then
                s.x += s.vx * dt
                s.y += s.vy * dt
                s.f.Position = UDim2.fromOffset(s.x, s.y)
                -- хвостик
                if math.random() < 0.6 then
                    local tr = dot(3, Color3.fromRGB(255, 200, 120))
                    tr.Position = s.f.Position
                    game:GetService("TweenService"):Create(tr, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                    game:GetService("Debris"):AddItem(tr, 0.45)
                end
                if s.age >= s.life then
                    burst(s.x, s.y)
                    s.f:Destroy()
                    table.remove(sparks, i)
                end
            else
                s.vy += 220 * dt
                s.vx *= (1 - 1.6 * dt)
                s.vy *= (1 - 1.2 * dt)
                s.x += s.vx * dt
                s.y += s.vy * dt
                local k = s.age / s.life
                s.f.Position = UDim2.fromOffset(s.x, s.y)
                local tw = s.twinkle and (math.sin(s.age * 40) > 0 and 0 or 0.6) or 0
                s.f.BackgroundTransparency = math.min(1, k * k + tw)
                if s.age >= s.life then
                    s.f:Destroy()
                    table.remove(sparks, i)
                end
            end
        end
        if now >= duration and #sparks == 0 then
            conn:Disconnect()
            gui:Destroy()
        end
    end)
    table.insert(connections, conn)
end

-- конфетти и серпантин из точки в сторону dir (летят, кувыркаются, падают)
local function confettiBurst(pos, dir, count)
    local Debris = game:GetService("Debris")
    for i = 1, count do
        local streamer = i % 6 == 0
        local p = decorPart({
            Name = "Confetti",
            Size = streamer and Vector3.new(0.05, 0.02, 0.55) or Vector3.new(0.12, 0.02, 0.09),
            Color = FESTIVE_COLORS[math.random(#FESTIVE_COLORS)],
            Material = math.random() < 0.3 and Enum.Material.Foil or Enum.Material.SmoothPlastic,
            CFrame = CFrame.new(pos) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6),
        })
        p.Anchored = false
        p.CanCollide = true
        p.Massless = false
        p.Parent = root
        local spread = Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5) * 1.3
        p.AssemblyLinearVelocity = (dir.Unit + spread).Unit * (8 + math.random() * 10) + Vector3.new(0, 6, 0)
        p.AssemblyAngularVelocity = Vector3.new(math.random() * 30 - 15, math.random() * 30 - 15, math.random() * 30 - 15)
        Debris:AddItem(p, 4 + math.random() * 2.5)
    end
end

local function partySetup()
    local rooms = workspace:WaitForChild("CurrentRooms", 30)
    if not rooms then return end
    local function roomCenterOf(room)
        local ok, cf = pcall(function() return (room:GetBoundingBox()) end)
        return ok and cf.Position or room:GetPivot().Position
    end

    ------------------------------------------------ хлопушки у дверей

    -- Открыл дверь N — игра увеличивает GameData.LatestRoom. Каждая POPPER_EVERY-я — хлопушка у этой
    -- двери: хлопок, конфетти и серпантин с обеих сторон сверху; на 100-й — салют
    local function doorOf(room)
        local door = room and room:FindFirstChild("Door")
        if not door then return nil end
        local collision = door:FindFirstChild("Collision")
        if collision and collision:IsA("BasePart") then return collision.CFrame, collision.Size end
        local leaf = door:FindFirstChild("Door")
        if leaf and leaf:IsA("BasePart") then
            local orig = leaf:FindFirstChild("OriginalCFrameValue")
            return (orig and orig:IsA("CFrameValue")) and orig.Value or leaf.CFrame, leaf.Size
        end
        local ok, cf, size = pcall(door.GetBoundingBox, door)
        if ok then return cf, size end
    end
    local lastPopped = 0
    local function popper(n)
        if not CONFIG.POPPERS or n <= lastPopped then return end
        lastPopped = n
        local every = math.max(1, math.floor(CONFIG.POPPER_EVERY or 10))
        local finale = CONFIG.POPPER_FINALE and n == 100
        if n % every ~= 0 and not finale then return end
        local room = rooms:FindFirstChild(tostring(n - 1))
        local cf, size = doorOf(room)
        local char = game:GetService("Players").LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not cf then
            if not hrp then return end
            cf, size = hrp.CFrame * CFrame.new(0, 2, -4), Vector3.new(5, 8, 1)
        end
        local axis = size.Z > size.X and cf * CFrame.Angles(0, math.pi / 2, 0) or cf
        local width = math.max(size.X, size.Z)
        -- с той стороны двери, где стоишь
        local side = 1
        if hrp then side = axis:PointToObjectSpace(hrp.Position).Z >= 0 and 1 or -1 end
        local inward = axis:VectorToWorldSpace(Vector3.new(0, 0, side))
        local count = math.floor(CONFIG.POPPER_CONFETTI or 40)
        for _, sx in ipairs({ -1, 1 }) do
            local corner = axis:PointToWorldSpace(Vector3.new(sx * width * 0.45, size.Y * 0.45, side * 0.6))
            local dir = inward + axis:VectorToWorldSpace(Vector3.new(-sx * 0.6, 0.5, 0))
            confettiBurst(corner, dir, math.floor(count / 2))
        end
        playNySound("sounds/ny_popper.mp3", 0.9 * (CONFIG.POPPER_VOLUME or 1), axis.Position)
        if finale then
            screenFireworks(10, true)
            if menuNotify then menuNotify("Дверь 100!", "С наступающим Новым годом!", 6) end
        end
    end
    local gameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
    local latest = gameData and gameData:FindFirstChild("LatestRoom")
    if latest and latest:IsA("ValueBase") then
        lastPopped = tonumber(latest.Value) or 0
        connect(latest.Changed, function() popper(tonumber(latest.Value) or 0) end)
    else
        -- запасной путь: появилась новая комната -> открыли дверь перед ней
        local maxSeen = 0
        for _, r in ipairs(rooms:GetChildren()) do maxSeen = math.max(maxSeen, tonumber(r.Name) or 0) end
        lastPopped = maxSeen
        connect(rooms.ChildAdded, function(r)
            local n = tonumber(r.Name)
            if n and n > maxSeen then
                maxSeen = n
                popper(n)
            end
        end)
    end

    ------------------------------------------------ омела и снежинки на дверях

    local MISTLETOE_LEAF = Color3.fromRGB(110, 150, 70)
    local function ellipsoid(props)
        local p = decorPart(props)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Parent = p
        return p
    end
    local function mistletoe(folder, top, facing)
        -- top — точка подвеса (верх проёма), facing — куда смотрит бантик
        local m = Instance.new("Model")
        m.Name = "Mistletoe"
        local function put(p) p.Parent = m return p end
        local hang = 0.55
        local base = CFrame.lookAt(top, top + facing)
        put(decorPart({ Name = "String", Size = Vector3.new(0.025, hang, 0.025), Color = Color3.fromRGB(200, 30, 40),
            Material = Enum.Material.Fabric, CFrame = base * CFrame.new(0, -hang / 2, 0) }))
        local bunch = base * CFrame.new(0, -hang - 0.12, 0)
        -- бантик над пучком
        for _, sx in ipairs({ -1, 1 }) do
            put(ellipsoid({ Name = "BowLoop", Size = Vector3.new(0.2, 0.12, 0.05), Color = Color3.fromRGB(200, 30, 40),
                Material = Enum.Material.Fabric, CFrame = base * CFrame.new(sx * 0.09, -hang + 0.04, -0.03) * CFrame.Angles(0, 0, math.rad(sx * 20)) }))
            put(decorPart({ Name = "BowTail", Size = Vector3.new(0.05, 0.2, 0.015), Color = Color3.fromRGB(200, 30, 40),
                Material = Enum.Material.Fabric, CFrame = base * CFrame.new(sx * 0.05, -hang - 0.06, -0.04) * CFrame.Angles(0, 0, math.rad(sx * 15)) }))
        end
        -- листья веером вниз и в стороны
        for i = 0, 7 do
            local a = i / 8 * math.pi * 2
            local leaf = bunch * CFrame.Angles(0, a, 0) * CFrame.Angles(math.rad(55 + math.random(-10, 10)), 0, 0) * CFrame.new(0, 0, -0.16)
            put(ellipsoid({ Name = "Leaf", Size = Vector3.new(0.12, 0.03, 0.34), Color = MISTLETOE_LEAF:Lerp(Color3.new(0, 0.2, 0), math.random() * 0.3),
                Material = Enum.Material.SmoothPlastic, CFrame = leaf }))
        end
        for i = 1, 7 do
            local off = Vector3.new(math.random() - 0.5, math.random() - 0.7, math.random() - 0.5) * 0.14
            put(decorPart({ Name = "Berry", Shape = Enum.PartType.Ball, Size = Vector3.new(0.065, 0.065, 0.065),
                Color = Color3.fromRGB(245, 245, 232), Material = Enum.Material.SmoothPlastic, Reflectance = 0.2,
                CFrame = bunch * CFrame.new(off) }))
        end
        m.Parent = folder
    end

    local stickerTex
    local function stickers(leaf, count)
        stickerTex = stickerTex or nyAsset("textures/snowflake_sticker.png")
        if not stickerTex then return end
        local sz = leaf.Size
        -- плоскость створки: толщина — меньшая из X/Z
        local thinZ = sz.Z <= sz.X
        local w, t = thinZ and sz.X or sz.Z, thinZ and sz.Z or sz.X
        for _, s in ipairs({ -1, 1 }) do
            local used = {}
            for _ = 1, count do
                local size = 0.45 + math.random() * 0.6
                local x = (math.random() - 0.5) * (w - size - 0.3)
                local y = (math.random() * 0.75 - 0.15) * (sz.Y / 2 - size)
                local ok = true
                for _, u in ipairs(used) do
                    if (u - Vector2.new(x, y)).Magnitude < size * 0.9 then ok = false end
                end
                if ok then
                    table.insert(used, Vector2.new(x, y))
                    local offset
                    if thinZ then
                        offset = CFrame.new(x, y, s * (t / 2 + 0.012)) * (s > 0 and CFrame.Angles(0, math.pi, 0) or CFrame.identity)
                    else
                        offset = CFrame.new(s * (t / 2 + 0.012), y, x) * CFrame.Angles(0, s > 0 and -math.pi / 2 or math.pi / 2, 0)
                    end
                    offset = offset * CFrame.Angles(0, 0, math.random() * math.pi)
                    local p = decorPart({ Name = "SnowflakeSticker", Size = Vector3.new(size, size, 0.02), Transparency = 1 })
                    local d = Instance.new("Decal")
                    d.Texture = stickerTex
                    d.Face = Enum.NormalId.Front
                    d.Color3 = math.random() < 0.3 and Color3.fromRGB(200, 225, 255) or Color3.new(1, 1, 1)
                    d.Transparency = 0.08
                    d.Parent = p
                    weldTo(leaf, p, offset)
                    p.Parent = root
                    connect(leaf.AncestryChanged, function()
                        if not leaf:IsDescendantOf(workspace) then p:Destroy() end
                    end)
                end
            end
        end
    end

    local doorDone = setmetatable({}, { __mode = "k" })
    local function decorateDoorExtras(room)
        local door = room:FindFirstChild("Door")
        if not door or doorDone[door] then return end
        doorDone[door] = true
        local leaves = {}
        for _, c in ipairs(door:GetChildren()) do
            if c.Name == "Door" and c:IsA("BasePart") then table.insert(leaves, c) end
        end
        if CONFIG.DOOR_STICKERS and #leaves > 0 and math.random() < (CONFIG.DOOR_STICKER_CHANCE or 0.5) then
            for _, lf in ipairs(leaves) do pcall(stickers, lf, math.random(2, 3)) end
        end
        if CONFIG.MISTLETOE and #leaves == 1 and math.random() < (CONFIG.MISTLETOE_CHANCE or 0.3) then
            local cf, size = doorOf(room)
            if cf then
                local axis = size.Z > size.X and cf * CFrame.Angles(0, math.pi / 2, 0) or cf
                local depth = math.min(size.X, size.Z)
                -- со стороны, откуда подходишь (вход в комнату / её середина)
                local z = axis:PointToObjectSpace(roomCenterOf(room)).Z
                local side = z >= 0 and 1 or -1
                local top = axis:PointToWorldSpace(Vector3.new(0, size.Y / 2 - 0.1, side * (depth / 2 + 0.45)))
                mistletoe(roomFolder(room), top, axis:VectorToWorldSpace(Vector3.new(0, 0, side)))
            end
        end
    end

    ------------------------------------------------ гирлянда-бахрома под потолком

    local FRINGE_WARM, FRINGE_COOL = Color3.fromRGB(255, 226, 168), Color3.fromRGB(214, 232, 255)
    local fringeBulbs = {}   -- { part = огонёк, color = его цвет при полной яркости }
    local fringeLights = {}
    local fringeFolders = {} -- [комната] = папка бахромы
    local fringeBeams = {}   -- [комната] = сколько балок было, когда строили
    local fringeColor = {}   -- [комната] = тёплый/холодный (чтобы при перестройке не менялся)

    local function bulbColor(c)
        local b = CONFIG.FRINGE_BRIGHTNESS or 1
        return c:Lerp(Color3.new(0, 0, 0), math.clamp(1 - b, 0, 0.9))
    end
    local function applyFringeLight()
        local b = CONFIG.FRINGE_BRIGHTNESS or 1
        for _, e in ipairs(fringeBulbs) do
            if e.part.Parent then e.part.Color = bulbColor(e.color) end
        end
        for _, l in ipairs(fringeLights) do
            if l.Parent then
                l.Brightness = 0.6 * b
                l.Enabled = b > 0.05
            end
        end
    end

    -- балка под потолком: ось, длина, низ, центр
    local function beamInfo(part)
        local s = part.Size
        local cf = part.CFrame
        local axisV, L
        if s.X >= s.Z then axisV, L = cf.RightVector, s.X else axisV, L = cf.LookVector, s.Z end
        if L < 8 or math.abs(axisV.Y) > 0.2 then return nil end
        local hy = math.abs(cf.RightVector.Y) * s.X / 2 + math.abs(cf.UpVector.Y) * s.Y / 2 + math.abs(cf.LookVector.Y) * s.Z / 2
        return { part = part, axis = Vector3.new(axisV.X, 0, axisV.Z).Unit, L = L, bottom = cf.Position.Y - hy - 0.03, c = cf.Position }
    end

    -- Балки в DOORS идут по 2-3 рядом (широкий карниз из нескольких брусьев) — бахрома висела
    -- тройной. Соседние параллельные балки собираем в группу и из каждой берём FRINGE_ROWS нижних.
    local function pickBeams(beams)
        local groups = {}
        for _, b in ipairs(beams) do
            local home
            for _, g in ipairs(groups) do
                local o = g[1]
                if math.abs(o.axis:Dot(b.axis)) > 0.95 then
                    local d = b.c - o.c
                    local along = d:Dot(o.axis)
                    local lat = d - o.axis * along
                    lat = Vector3.new(lat.X, 0, lat.Z).Magnitude
                    if lat < 5 and math.abs(b.bottom - o.bottom) < 6 and math.abs(along) < (o.L + b.L) / 2 then
                        home = g
                        break
                    end
                end
            end
            if home then table.insert(home, b) else table.insert(groups, { b }) end
        end
        local rows = math.clamp(math.floor(CONFIG.FRINGE_ROWS or 1), 1, 3)
        local chosen = {}
        for _, g in ipairs(groups) do
            table.sort(g, function(a, b) return a.bottom < b.bottom end)
            for i = 1, math.min(rows, #g) do table.insert(chosen, g[i]) end
        end
        return chosen
    end

    local function buildFringe(folder, beam, color)
        local step = math.max(0.3, CONFIG.FRINGE_STEP or 0.75)
        local lenK = CONFIG.FRINGE_LENGTH or 1
        local n = math.floor((beam.L - 0.6) / step)
        for k = 0, n do
            local p = beam.c + beam.axis * (-beam.L / 2 + 0.3 + k * step)
            local top = Vector3.new(p.X, beam.bottom, p.Z)
            local len = (0.35 + math.random() * 0.95) * lenK
            local bulbs = math.clamp(math.floor(len / 0.32), 1, 5)
            local thread = decorPart({ Name = "FringeThread", Size = Vector3.new(0.02, len, 0.02), Color = Color3.fromRGB(40, 40, 40),
                Transparency = 0.3, CFrame = CFrame.new(top - Vector3.new(0, len / 2, 0)) })
            thread.Parent = folder
            for b = 1, bulbs do
                local bulb = decorPart({ Name = "FringeBulb", Shape = Enum.PartType.Ball, Size = Vector3.new(0.11, 0.11, 0.11),
                    Color = bulbColor(color), Material = Enum.Material.Neon, CFrame = CFrame.new(top - Vector3.new(0, len * b / bulbs, 0)) })
                bulb.Parent = folder
                table.insert(fringeBulbs, { part = bulb, color = color })
            end
            -- редкий настоящий огонёк, чтобы бахрома подсвечивала потолок
            if k % 8 == 0 then
                local l = Instance.new("PointLight")
                l.Color = color
                l.Brightness = 0.6 * (CONFIG.FRINGE_BRIGHTNESS or 1)
                l.Enabled = (CONFIG.FRINGE_BRIGHTNESS or 1) > 0.05
                l.Range = 7
                l.Shadows = false
                l.Parent = thread
                table.insert(fringeLights, l)
            end
        end
    end

    local function fringeRoom(room)
        if not CONFIG.FRINGE then return end
        local beams = {}
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("BasePart") and d.Name:lower():find("ceiling_detail", 1, true) then
                local info = beamInfo(d)
                if info then table.insert(beams, info) end
            end
        end
        if #beams == 0 then return end
        local old = fringeFolders[room]
        if old and old.Parent and (fringeBeams[room] or 0) >= #beams then return end
        if old then old:Destroy() end -- догрузились ещё балки — перестраиваем комнату целиком
        local folder = Instance.new("Folder")
        folder.Name = "Fringe"
        folder.Parent = roomFolder(room)
        fringeFolders[room], fringeBeams[room] = folder, #beams
        fringeColor[room] = fringeColor[room] or (math.random() < 0.5 and FRINGE_WARM or FRINGE_COOL)
        for _, beam in ipairs(pickBeams(beams)) do buildFringe(folder, beam, fringeColor[room]) end
    end

    -- меню: перестроить (ряды, густота, длина) — с паузой, пока тянешь ползунок; яркость — сразу
    local rebuildToken = 0
    live.fringe = function()
        rebuildToken += 1
        local my = rebuildToken
        task.delay(0.35, function()
            if my ~= rebuildToken then return end
            for _, f in pairs(fringeFolders) do f:Destroy() end
            fringeFolders, fringeBeams, fringeBulbs, fringeLights = {}, {}, {}, {}
            for _, room in ipairs(rooms:GetChildren()) do pcall(fringeRoom, room) end
        end)
    end
    live.fringeLight = applyFringeLight

    -- мерцание: каждые 0.1 с несколько случайных огоньков на миг притухают
    task.spawn(function()
        while root.Parent do
            task.wait(0.1)
            for _ = 1, 4 do
                if #fringeBulbs == 0 then break end
                local i = math.random(#fringeBulbs)
                local b = fringeBulbs[i].part
                if not b.Parent then
                    table.remove(fringeBulbs, i)
                else
                    b.Transparency = 0.55
                    task.delay(0.12 + math.random() * 0.25, function()
                        if b.Parent then b.Transparency = 0 end
                    end)
                end
            end
        end
    end)

    ------------------------------------------------ камины

    local fireDone = setmetatable({}, { __mode = "k" })
    local function stocking(folder, hangAt, front, right, color)
        local m = Instance.new("Model")
        m.Name = "Stocking"
        local function put(p) p.Parent = m return p end
        local base = CFrame.fromMatrix(hangAt, right, Vector3.yAxis, -front) * CFrame.Angles(0, 0, math.rad(math.random(-6, 6)))
        local white = Color3.fromRGB(245, 245, 240)
        put(decorPart({ Name = "Loop", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.03, 0.14, 0.14), Color = white,
            Material = Enum.Material.Fabric, CFrame = base * CFrame.new(0, -0.05, 0) }))
        put(decorPart({ Name = "Cuff", Size = Vector3.new(0.4, 0.17, 0.2), Color = white, Material = Enum.Material.Fabric,
            CFrame = base * CFrame.new(0, -0.2, 0) }))
        put(decorPart({ Name = "Leg", Size = Vector3.new(0.32, 0.6, 0.15), Color = color, Material = Enum.Material.Fabric,
            CFrame = base * CFrame.new(0, -0.58, 0) }))
        for _, y in ipairs({ -0.45, -0.68 }) do
            put(decorPart({ Name = "Stripe", Size = Vector3.new(0.33, 0.05, 0.16), Color = white, Material = Enum.Material.Fabric,
                CFrame = base * CFrame.new(0, y, 0) }))
        end
        put(decorPart({ Name = "Foot", Size = Vector3.new(0.46, 0.22, 0.15), Color = color, Material = Enum.Material.Fabric,
            CFrame = base * CFrame.new(0.1, -0.92, 0) }))
        put(decorPart({ Name = "Toe", Shape = Enum.PartType.Ball, Size = Vector3.new(0.22, 0.22, 0.22), Color = color,
            Material = Enum.Material.Fabric, CFrame = base * CFrame.new(0.32, -0.92, 0) }))
        put(decorPart({ Name = "Heel", Shape = Enum.PartType.Ball, Size = Vector3.new(0.2, 0.2, 0.16), Color = white,
            Material = Enum.Material.Fabric, CFrame = base * CFrame.new(-0.12, -0.93, 0) }))
        m.Parent = folder
    end
    local function evergreen(folder, a, b, up, front)
        -- еловая ветка вдоль края полки: пушистые зелёные «лапы», шишки, ягоды и золотые шарики
        local L = (b - a).Magnitude
        local dir = (b - a).Unit
        local n = math.floor(L / 0.22)
        for k = 0, n do
            local u = k / n
            local sag = 0.12 * math.sin((u * 2 % 1) * math.pi)
            local p = a + dir * (u * L) + up * (0.08 - sag) + front * 0.05
            local branch = ellipsoid({ Name = "Pine", Size = Vector3.new(0.36, 0.2, 0.3),
                Color = Color3.fromRGB(30, 82 + math.random(0, 25), 40), Material = Enum.Material.Grass,
                CFrame = CFrame.new(p) * CFrame.Angles(math.random() * 0.6, math.random() * 6.28, math.random() * 0.6) })
            branch.Parent = folder
            if k % 4 == 2 then
                local roll = math.random()
                local item
                if roll < 0.35 then
                    item = ellipsoid({ Name = "Cone", Size = Vector3.new(0.12, 0.2, 0.12), Color = Color3.fromRGB(110, 70, 40),
                        Material = Enum.Material.Wood, CFrame = CFrame.new(p + front * 0.12) * CFrame.Angles(0.4, 0, 0.3) })
                elseif roll < 0.7 then
                    item = decorPart({ Name = "Ball", Shape = Enum.PartType.Ball, Size = Vector3.new(0.14, 0.14, 0.14),
                        Color = Color3.fromRGB(255, 205, 60), Material = Enum.Material.SmoothPlastic, Reflectance = 0.35,
                        CFrame = CFrame.new(p + front * 0.13) })
                else
                    for j = 0, 2 do
                        local berry = decorPart({ Name = "Berry", Shape = Enum.PartType.Ball, Size = Vector3.new(0.07, 0.07, 0.07),
                            Color = Color3.fromRGB(205, 25, 35), Material = Enum.Material.SmoothPlastic, Reflectance = 0.15,
                            CFrame = CFrame.new(p + front * 0.13 + Vector3.new(math.cos(j * 2.1), 0.4 * (j % 2), math.sin(j * 2.1)) * 0.04) })
                        berry.Parent = folder
                    end
                end
                if item then item.Parent = folder end
            end
        end
    end
    local function decorateFireplace(room, model)
        if fireDone[model] then return end
        fireDone[model] = true
        local folder = roomFolder(room)
        local mcf, msize = model:GetBoundingBox()
        local toC = roomCenterOf(room) - mcf.Position
        toC = Vector3.new(toC.X, 0, toC.Z)
        -- Полку ищем по форме, а не по названию («Shelf» бывает и внутри топки): щупаем камин лучами
        -- спереди на разной высоте — полка это самая выступающая вперёд полоса в верхней части.
        local along = mcf.RightVector
        along = Vector3.new(along.X, 0, along.Z).Unit
        if toC.Magnitude > 0.1 and math.abs(toC.Unit:Dot(along)) > 0.7 then
            along = Vector3.new(mcf.LookVector.X, 0, mcf.LookVector.Z).Unit
        end
        local alongIsX = math.abs(along:Dot(mcf.RightVector)) > 0.7
        local halfW = (alongIsX and msize.X or msize.Z) / 2
        local depth = alongIsX and msize.Z or msize.X
        local front = Vector3.yAxis:Cross(along).Unit
        if toC.Magnitude > 0.1 and front:Dot(toC) < 0 then front = -front end
        local c0 = mcf.Position
        local bottom, H = c0.Y - msize.Y / 2, msize.Y

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = { model }
        local function probe(x, y)
            local from = Vector3.new(c0.X, y, c0.Z) + along * x + front * (depth / 2 + 3)
            local hit = workspace:Raycast(from, -front * (depth + 6), params)
            return hit and (hit.Position - c0):Dot(front) or nil
        end
        local function sampleFront()
            local samples, maxP = {}, nil
            local y = bottom + H * 0.35
            while y <= bottom + H - 0.04 do
                local p = probe(0, y)
                if p then
                    table.insert(samples, { y = y, p = p })
                    maxP = maxP and math.max(maxP, p) or p
                end
                y += 0.1
            end
            return samples, maxP
        end
        local samples, maxP = sampleFront()
        if not maxP then
            -- детали камина не ловятся лучом «только камин» — щупаем всё, кроме своих украшений
            params.FilterType = Enum.RaycastFilterType.Exclude
            local char = game:GetService("Players").LocalPlayer.Character
            params.FilterDescendantsInstances = char and { root, char } or { root }
            samples, maxP = sampleFront()
        end

        local mantelTop, mantelBottom, frontP, left, right
        if maxP then
            -- верхняя полоса, выступающая вперёд почти как самое выступающее место, — это полка
            local topI
            for i = #samples, 1, -1 do
                if samples[i].p >= maxP - 0.08 then topI = i break end
            end
            local lowI = topI
            while lowI > 1 and samples[lowI - 1].p >= maxP - 0.08 do lowI -= 1 end
            mantelTop = samples[topI].y + 0.05
            mantelBottom = samples[lowI].y - 0.05
            frontP = maxP
            -- точный верх полки: луч сверху вниз чуть позади переднего края
            local edge = Vector3.new(c0.X, 0, c0.Z) + front * (frontP - 0.12)
            local dh = workspace:Raycast(Vector3.new(edge.X, mantelTop + 0.5, edge.Z), Vector3.new(0, -1, 0), params)
            if dh then mantelTop = dh.Position.Y end
            -- ширина полки: вдоль неё, пока луч на её высоте упирается так же далеко
            local midY = (mantelTop + mantelBottom) / 2
            local function extent(sign)
                local last, x = 0, 0.25
                while x < halfW + 0.5 do
                    local p = probe(sign * x, midY)
                    if not p or p < frontP - 0.15 then break end
                    last = x
                    x += 0.25
                end
                return last
            end
            left, right = extent(-1), extent(1)
        end
        if not maxP or left + right < 1 then
            mantelTop = mantelTop or (bottom + H)
            mantelBottom = mantelBottom or (mantelTop - 0.3)
            frontP = frontP or depth / 2
            left, right = halfW * 0.8, halfW * 0.8
        end
        local frontPlane = Vector3.new(c0.X, 0, c0.Z) + front * (frontP + 0.02)
        local center = frontPlane + along * ((right - left) / 2)
        local half = (left + right) / 2
        if CONFIG.SCAN then
            print(("[NewYear] Камин %s: полка %.2f..%.2f, выступ %.2f, ширина %.2f"):format(model:GetFullName(),
                mantelBottom, mantelTop, frontP, half * 2))
        end
        -- чулки висят под полкой спереди (если до пола хватает места)
        if mantelBottom - bottom > 1.3 then
            local count = half * 2 > 4 and 3 or 2
            local colors = { Color3.fromRGB(200, 30, 40), Color3.fromRGB(35, 120, 65) }
            for i = 1, count do
                local u = (i - (count + 1) / 2) / count
                local at = center + along * (u * half * 1.6) + front * 0.13 + Vector3.new(0, mantelBottom, 0)
                stocking(folder, at, front, along, colors[(i % 2) + 1])
            end
        end
        -- тёплые искорки над огнём
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ParticleEmitter") and d.Name:lower():find("fire", 1, true) and d.Parent then
                local e = Instance.new("ParticleEmitter")
                e.Name = "NewYearEmbers"
                e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                e.Color = ColorSequence.new(Color3.fromRGB(255, 210, 120), Color3.fromRGB(255, 120, 40))
                e.LightEmission = 1
                e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0) })
                e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
                e.Lifetime = NumberRange.new(1.5, 2.6)
                e.Rate = 4
                e.Speed = NumberRange.new(1.2, 2.4)
                e.SpreadAngle = Vector2.new(25, 25)
                e.Acceleration = Vector3.new(0, 0.6, 0)
                e.EmissionDirection = Enum.NormalId.Top
                e.Parent = d.Parent
                track(e)
                break
            end
        end
    end

    ------------------------------------------------ снегопад за окнами

    local windowDone = setmetatable({}, { __mode = "k" })
    local function windowSnow(room, pane)
        if windowDone[pane] then return end
        windowDone[pane] = true
        local s, cf = pane.Size, pane.CFrame
        -- нормаль окна — самая тонкая ось; «улица» — сторона дальше от середины комнаты
        local axes = { { s.X, cf.RightVector }, { s.Y, cf.UpVector }, { s.Z, cf.LookVector } }
        table.sort(axes, function(a, b) return a[1] < b[1] end)
        local normal = axes[1][2]
        if math.abs(normal.Y) > 0.5 then return end
        if (roomCenterOf(room) - pane.Position):Dot(normal) > 0 then normal = -normal end
        -- только окна на улицу: стеклянные перегородки внутри (SeeThroughGlass и т.п.) — не окна.
        -- Окно на улицу — в модели «Window…», и за ним на 10 шагов нет ни стен, ни мебели
        if pane.Name:lower():find("seethrough", 1, true) then return end
        local winModel = pane:FindFirstAncestorWhichIsA("Model")
        if not (winModel and winModel.Name:lower():find("window", 1, true)) then return end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local char = player.Character
        params.FilterDescendantsInstances = char and { winModel, root, char } or { winModel, root }
        if workspace:Raycast(pane.Position + normal * 0.3, normal * 10, params) then return end
        local vertFirst = math.abs(axes[2][2].Y) > math.abs(axes[3][2].Y)
        local h = vertFirst and axes[2][1] or axes[3][1]
        local w = vertFirst and axes[3][1] or axes[2][1]
        local along = Vector3.yAxis:Cross(normal).Unit
        local emitterPart = decorPart({ Name = "WindowSnow", Transparency = 1, Size = Vector3.new(w + 2, 0.2, 3),
            CFrame = CFrame.fromMatrix(pane.Position + normal * 2 + Vector3.new(0, h / 2 + 0.6, 0), along, Vector3.yAxis) })
        local e = Instance.new("ParticleEmitter")
        e.Texture = nyAsset("textures/snowflake_sticker.png") or "rbxasset://textures/particles/sparkles_main.dds"
        e.Color = ColorSequence.new(Color3.fromRGB(240, 246, 255))
        e.Size = NumberSequence.new(0.12, 0.08)
        e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.85, 0.3),
            NumberSequenceKeypoint.new(1, 1) })
        e.LightEmission = 0.25
        e.LightInfluence = 0.3
        e.Rate = math.clamp(w * 4, 6, 60)
        e.Speed = NumberRange.new(2, 3.5)
        e.Lifetime = NumberRange.new((h + 2) / 2.5, (h + 2) / 2)
        e.EmissionDirection = Enum.NormalId.Bottom
        e.SpreadAngle = Vector2.new(15, 15)
        e.Acceleration = along * 0.6
        e.Rotation = NumberRange.new(0, 360)
        e.RotSpeed = NumberRange.new(-60, 60)
        e.Shape = Enum.ParticleEmitterShape.Box
        e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        e.Parent = emitterPart
        emitterPart.Parent = roomFolder(room)
    end

    ------------------------------------------------ обход комнат

    local function scanRoom(room)
        if CONFIG.WINDOW_SNOW then
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("BasePart") and d.Transparency < 1 and isWindowPane(d) then
                    local ok, err = pcall(windowSnow, room, d)
                    if not ok then warn("[NewYear] Снег за окном: " .. tostring(err)) end
                end
            end
        end
        if CONFIG.MISTLETOE or CONFIG.DOOR_STICKERS then
            local ok, err = pcall(decorateDoorExtras, room)
            if not ok then warn("[NewYear] Омела/снежинки: " .. tostring(err)) end
        end
        local okF, errF = pcall(fringeRoom, room)
        if not okF then warn("[NewYear] Бахрома: " .. tostring(errF)) end
        for _, d in ipairs(room:GetDescendants()) do
            if CONFIG.FIREPLACES and d:IsA("Model") and d.Name:lower():find("fireplace", 1, true) then
                local ok, err = pcall(decorateFireplace, room, d)
                if not ok then warn("[NewYear] Камин: " .. tostring(err)) end
            end
        end
    end
    for _, room in ipairs(rooms:GetChildren()) do task.spawn(scanRoom, room) end
    connect(rooms.ChildAdded, function(room)
        task.delay(1, scanRoom, room)
        task.delay(4, scanRoom, room)
    end)
end
-- комнаты могут появиться не сразу (в лобби их нет) — ждём в фоне, меню не задерживаем
task.spawn(function()
    local okParty, errParty = pcall(partySetup)
    report("Party", okParty, errParty)
end)

-- Пасхалка: 5 кликов по логотипу меню — часы до Нового года; в полночь — салют
local clockGui
local function toggleNewYearClock()
    if clockGui and clockGui.Parent then
        clockGui:Destroy()
        clockGui = nil
        return
    end
    local TweenService = game:GetService("TweenService")
    local gui = Instance.new("ScreenGui")
    gui.Name = "NewYearClock"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 40
    pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("Players").LocalPlayer.PlayerGui end)
    if not gui.Parent then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    track(gui)
    clockGui = gui
    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0)
    card.Position = UDim2.new(0.5, 0, 0, -140)
    card.Size = UDim2.fromOffset(340, 118)
    card.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
    card.BackgroundTransparency = 0.12
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(255, 205, 60)
    stroke.Transparency = 0.35
    stroke.Thickness = 1.5
    local grad = Instance.new("UIGradient", card)
    grad.Rotation = 90
    grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 200, 230))
    local function label(text, y, h, size, color, bold)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = UDim2.fromOffset(0, y)
        l.Size = UDim2.new(1, 0, 0, h)
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = size
        l.TextColor3 = color
        l.Text = text
        l.Parent = card
        return l
    end
    local title = label("❄  До Нового года  ❄", 12, 20, 15, Color3.fromRGB(255, 215, 110), true)
    local digits = label("", 36, 44, 34, Color3.fromRGB(240, 244, 255), true)
    local hint = label("клик по часам — салют, 5 кликов по логотипу — спрятать", 88, 18, 11, Color3.fromRGB(150, 158, 185))
    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = ""
    btn.Parent = card
    btn.MouseButton1Click:Connect(function() screenFireworks(5, true) end)
    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0, 18) }):Play()
    local celebrated = false
    task.spawn(function()
        while gui.Parent do
            local now = os.time()
            local t = os.date("*t", now)
            if t.month == 1 and t.day == 1 then
                digits.Text = "С Новым годом!"
                title.Text = "✨  " .. t.year .. "  ✨"
                if not celebrated then
                    celebrated = true
                    screenFireworks(25, true)
                end
            else
                local target = os.time({ year = t.year + 1, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
                local left = math.max(0, target - now)
                local d = math.floor(left / 86400)
                local h = math.floor(left % 86400 / 3600)
                local m = math.floor(left % 3600 / 60)
                local s = left % 60
                digits.Text = (d > 0 and (d .. " д  ") or "") .. ("%02d:%02d:%02d"):format(h, m, s)
                if left <= 10 and left > 0 then
                    -- последние секунды: цифры подпрыгивают
                    digits.TextSize = 40
                    TweenService:Create(digits, TweenInfo.new(0.5), { TextSize = 34 }):Play()
                end
            end
            -- снежинка в заголовке мерцает
            grad.Offset = Vector2.new(0, math.sin(os.clock() * 1.5) * 0.15)
            task.wait(1)
        end
    end)
end

---------------------------------------------------------------- новогодний интерфейс DOORS

-- Только у тебя на экране: здоровье — карамельная трость со снежной шапкой, на щите — шапка Санты;
-- слоты хотбара — ёлочные шарики (колпачок, блик, свой цвет), выбранный светится и покачивается,
-- колпачки соединены проводом гирлянды с огоньками. Выключил в меню — всё как было в игре.
local uiOrig, uiMade, uiConns = {}, {}, {}
local function uiSet(inst, prop, value)
    for _, e in ipairs(uiOrig) do
        if e[1] == inst and e[2] == prop then
            inst[prop] = value
            return
        end
    end
    table.insert(uiOrig, { inst, prop, inst[prop] })
    inst[prop] = value
end
local function uiMake(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props) do i[k] = v end
    i.Parent = parent
    table.insert(uiMade, i)
    return i
end
local function uiConnect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(uiConns, c)
    return c
end
local function uiRevert()
    for _, c in ipairs(uiConns) do c:Disconnect() end
    uiConns = {}
    for _, i in ipairs(uiMade) do pcall(i.Destroy, i) end
    uiMade = {}
    for k = #uiOrig, 1, -1 do
        local e = uiOrig[k]
        pcall(function() e[1][e[2]] = e[3] end)
    end
    uiOrig = {}
end
table.insert(connections, { Disconnect = function() uiRevert() end })

local ORNAMENT_SLOT_COLORS = {
    Color3.fromRGB(200, 35, 45), Color3.fromRGB(35, 140, 70), Color3.fromRGB(230, 175, 50), Color3.fromRGB(50, 100, 210),
    Color3.fromRGB(170, 60, 180),
}

local function decorateHealth(mainFrame)
    local hb = mainFrame:FindFirstChild("Healthbar")
    if not hb then return end
    local snowTex = nyAsset("textures/snow_cap.png")
    local candyTex = nyAsset("textures/candy_stripes.png")
    local hatTex = nyAsset("textures/santa_hat.png")
    local bar = hb:FindFirstChild("Bar")
    if bar then
        local fill = bar:FindFirstChild("Bar")
        local hurt = bar:FindFirstChild("HurtBar")
        local stroke = bar:FindFirstChildOfClass("UIStroke")
        if fill and fill:IsA("GuiObject") then
            uiSet(fill, "BackgroundColor3", Color3.fromRGB(250, 247, 242))
            if candyTex then
                -- красные косые полоски по белому; полоса «съедается» вместе с заливкой
                local img = uiMake("ImageLabel", { Name = "NY_Candy", BackgroundTransparency = 1, Image = candyTex,
                    ScaleType = Enum.ScaleType.Tile, Size = UDim2.fromScale(1, 1), ZIndex = fill.ZIndex,
                    TileSize = UDim2.fromOffset(32, 32) }, fill)
                local corner = fill:FindFirstChildOfClass("UICorner")
                uiMake("UICorner", { CornerRadius = corner and corner.CornerRadius or UDim.new(0.25, 0) }, img)
                -- блик сверху, как на леденце
                uiMake("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.35, 0.05), NumberSequenceKeypoint.new(1, 0.2) }),
                    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(225, 215, 215)) }, img)
                local function tile()
                    local h = math.max(fill.AbsoluteSize.Y, 8)
                    img.TileSize = UDim2.fromOffset(h * 1.6, h * 1.6)
                end
                tile()
                uiConnect(fill:GetPropertyChangedSignal("AbsoluteSize"), tile)
            end
        end
        if hurt and hurt:IsA("GuiObject") then uiSet(hurt, "BackgroundColor3", Color3.fromRGB(255, 160, 185)) end
        if stroke then uiSet(stroke, "Color", Color3.fromRGB(205, 40, 50)) end
        if snowTex then
            uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex,
                AnchorPoint = Vector2.new(0.5, 0.62), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 22, 0.9, 10),
                ZIndex = 20, ScaleType = Enum.ScaleType.Stretch }, bar)
        end
    end
    -- выносливость: снежная шапка
    local stamina = hb:FindFirstChild("Stamina")
    if stamina and snowTex then
        uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex,
            AnchorPoint = Vector2.new(0.5, 0.62), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 18, 1, 10),
            ZIndex = 20, ScaleType = Enum.ScaleType.Stretch }, stamina)
    end
    -- щит с сердцем (неуязвимость): шапка Санты набекрень
    local effects = hb:FindFirstChild("Effects")
    local shield = effects and effects:FindFirstChild("Invincibility")
    if shield and hatTex then
        uiMake("ImageLabel", { Name = "NY_SantaHat", BackgroundTransparency = 1, Image = hatTex,
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.6, 0.36), Size = UDim2.fromScale(0.62, 0.62),
            Rotation = 16, ZIndex = shield.ZIndex + 1 }, shield)
    end
end

local function decorateHotbar(mainUI, mainFrame)
    local hotbar = mainFrame:FindFirstChild("Hotbar")
    if not hotbar then return end
    local capTex = nyAsset("textures/ornament_cap.png")
    local slots = {}
    local function isSlot(c) return c:IsA("GuiButton") and tonumber(c.Name) ~= nil end
    local function decorateSlot(slot)
        if slots[slot] then return end
        local i = tonumber(slot.Name)
        local color = ORNAMENT_SLOT_COLORS[(i - 1) % #ORNAMENT_SLOT_COLORS + 1]
        uiSet(slot, "BackgroundColor3", color)
        local stroke = slot:FindFirstChildOfClass("UIStroke")
        if stroke then uiSet(stroke, "Color", Color3.fromRGB(255, 214, 120)) end
        -- блик на стекле — только у круглых слотов (шарик); на квадратных он выглядел пятном
        local corner = slot:FindFirstChildOfClass("UICorner")
        if corner and corner.CornerRadius.Scale >= 0.45 then
            local gloss = uiMake("Frame", { Name = "NY_Gloss", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.33, 0.3),
                Size = UDim2.fromScale(0.34, 0.2), Rotation = -38, BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = slot.ZIndex + 1 }, slot)
            uiMake("UICorner", { CornerRadius = UDim.new(1, 0) }, gloss)
            uiMake("UIGradient", { Transparency = NumberSequence.new(0, 0.85) }, gloss)
        end
        -- колпачок с петелькой сверху
        if capTex then
            uiMake("ImageLabel", { Name = "NY_Cap", BackgroundTransparency = 1, Image = capTex,
                AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.08),
                Size = UDim2.fromScale(0.36, 0.36), ZIndex = slot.ZIndex + 40 }, slot)
        end
        -- номер слота: красная плашка с золотой обводкой
        local num = slot:FindFirstChild("SlotNum")
        if num and num:IsA("GuiObject") then
            uiSet(num, "BackgroundColor3", Color3.fromRGB(190, 30, 40))
            uiSet(num, "BackgroundTransparency", 0.05)
            local ns = num:FindFirstChildOfClass("UIStroke")
            if ns then uiSet(ns, "Color", Color3.fromRGB(255, 205, 70)) end
            if num:IsA("TextLabel") then uiSet(num, "TextColor3", Color3.fromRGB(255, 244, 225)) end
        end
        uiSet(slot, "Rotation", 0)
        slots[slot] = { stroke = stroke }
    end
    for _, c in ipairs(hotbar:GetChildren()) do
        if isSlot(c) then pcall(decorateSlot, c) end
    end
    uiConnect(hotbar.ChildAdded, function(c)
        task.defer(function()
            if isSlot(c) then pcall(decorateSlot, c) end
        end)
    end)

    -- гирлянда над шариками: отдельный экран ПОД интерфейсом игры — номера слотов и колпачки
    -- рисуются поверх провода и огоньков, ничего не перекрывается
    local gui = uiMake("ScreenGui", { Name = "NY_HotbarGarland", ResetOnSpawn = false,
        IgnoreGuiInset = mainUI.IgnoreGuiInset, DisplayOrder = mainUI.DisplayOrder - 1 }, mainUI.Parent)
    local holder = uiMake("Frame", { Name = "Holder", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, gui)
    local segs, bulbs = {}, {}
    local function seg(k)
        if not segs[k] then
            segs[k] = Instance.new("Frame")
            segs[k].BackgroundColor3 = Color3.fromRGB(30, 60, 35)
            segs[k].BorderSizePixel = 0
            segs[k].AnchorPoint = Vector2.new(0.5, 0.5)
            segs[k].Parent = holder
        end
        return segs[k]
    end
    local BULB_COLORS = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 210, 80), Color3.fromRGB(90, 220, 120),
        Color3.fromRGB(90, 160, 255) }
    local function bulb(k)
        if not bulbs[k] then
            local b = Instance.new("Frame")
            b.AnchorPoint = Vector2.new(0.5, 0)
            b.BorderSizePixel = 0
            b.BackgroundColor3 = BULB_COLORS[(k - 1) % #BULB_COLORS + 1]
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
            local st = Instance.new("UIStroke", b)
            st.Color = b.BackgroundColor3
            st.Transparency = 0.5
            st.Thickness = 2
            b.Parent = holder
            bulbs[k] = b
        end
        return bulbs[k]
    end
    local t0 = os.clock()
    uiConnect(RunService.RenderStepped, function()
        local now = os.clock() - t0
        gui.Enabled = mainUI.Enabled and mainFrame.Visible and hotbar.Visible
        -- выбранный шарик покачивается
        local list = {}
        for slot, info in pairs(slots) do
            if slot.Parent and slot.Visible then
                table.insert(list, slot)
                local selected = info.stroke and info.stroke.Transparency < 0.35
                slot.Rotation = selected and 5 * math.sin(now * 2.4) or 0
            end
        end
        table.sort(list, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
        local si, bi = 0, 0
        for k = 1, #list - 1 do
            local a, b = list[k], list[k + 1]
            -- координаты в осях своего экрана: у экрана игры и у нашего бывает разный отступ сверху
            local origin = holder.AbsolutePosition
            local pa = a.AbsolutePosition - origin + Vector2.new(a.AbsoluteSize.X / 2, -a.AbsoluteSize.Y * 0.2)
            local pb = b.AbsolutePosition - origin + Vector2.new(b.AbsoluteSize.X / 2, -b.AbsoluteSize.Y * 0.2)
            local sag = (pb - pa).Magnitude * 0.1
            local n = 8
            local prev = pa
            for j = 1, n do
                local u = j / n
                local p = pa:Lerp(pb, u) + Vector2.new(0, math.sin(u * math.pi) * sag)
                si += 1
                local s = seg(si)
                local mid, d = (prev + p) / 2, p - prev
                s.Visible = true
                s.Position = UDim2.fromOffset(mid.X, mid.Y)
                s.Size = UDim2.fromOffset(d.Magnitude + 1, 3)
                s.Rotation = math.deg(math.atan2(d.Y, d.X))
                if j == 3 or j == 6 then
                    bi += 1
                    local bl = bulb(bi)
                    local size = math.max(6, a.AbsoluteSize.Y * 0.09)
                    bl.Visible = true
                    bl.Position = UDim2.fromOffset(p.X, p.Y)
                    bl.Size = UDim2.fromOffset(size, size * 1.3)
                    -- мигают по очереди
                    local on = math.floor(now * 1.6 + bi * 0.5) % 2 == 0
                    bl.BackgroundTransparency = on and 0 or 0.55
                    bl:FindFirstChildOfClass("UIStroke").Transparency = on and 0.35 or 0.9
                end
                prev = p
            end
        end
        for k = si + 1, #segs do segs[k].Visible = false end
        for k = bi + 1, #bulbs do bulbs[k].Visible = false end
    end)
end

-- Окна игры (меню, инвентарь, магазин, подтверждения): золотая рамка, снежная шапка по верху,
-- остролист в верхних углах, мигающая гирлянда под шапкой. Карточки магазина и инвентаря —
-- как подарки: лента крест-накрест и бантик.
local WINDOW_BULBS = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 210, 80), Color3.fromRGB(90, 220, 120),
    Color3.fromRGB(90, 160, 255) }
local GOLD_FRAME = Color3.fromRGB(255, 205, 90)
local windowBulbs = {} -- { frame, phase }

local function padPx(win)
    local p = win:FindFirstChildOfClass("UIPadding")
    local s = win.AbsoluteSize
    if not p then return 0, 0, 0, 0 end
    return p.PaddingLeft.Scale * s.X + p.PaddingLeft.Offset, p.PaddingRight.Scale * s.X + p.PaddingRight.Offset,
        p.PaddingTop.Scale * s.Y + p.PaddingTop.Offset, p.PaddingBottom.Scale * s.Y + p.PaddingBottom.Offset
end

-- прозрачный слой ровно по окну (с поправкой на внутренние отступы окна), украшения — в нём
local function windowOverlay(win)
    local ov = uiMake("Frame", { Name = "NY_Overlay", BackgroundTransparency = 1, ZIndex = win.ZIndex + 1 }, win)
    local function fit()
        local l, r, t, b = padPx(win)
        ov.Position = UDim2.fromOffset(-l, -t)
        ov.Size = UDim2.new(1, l + r, 1, t + b)
    end
    fit()
    uiConnect(win:GetPropertyChangedSignal("AbsoluteSize"), fit)
    return ov
end

local function windowGarland(ov, z, y, big)
    local holder = uiMake("Frame", { Name = "NY_Garland", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = z }, ov)
    local function build()
        for _, c in ipairs(holder:GetChildren()) do c:Destroy() end
        local w = ov.AbsoluteSize.X
        if w < 60 then return end
        local spans = big and math.clamp(math.floor(w / 380), 3, 9) or math.clamp(math.floor(w / 170), 2, 9)
        local bulbSize = big and math.clamp(w / 110, 12, 32) or math.clamp(w / 70, 7, 16)
        local wire = big and math.clamp(w / 900, 2, 5) or 2
        local x0, x1 = w * 0.06, w * 0.94
        local sag = big and math.clamp(w / spans * 0.13, 20, 90) or math.clamp(w / spans * 0.12, 6, 26)
        local k = 0
        for sp = 0, spans - 1 do
            local a, b = x0 + (x1 - x0) * sp / spans, x0 + (x1 - x0) * (sp + 1) / spans
            local prev
            for j = 0, 8 do
                local u = j / 8
                local p = Vector2.new(a + (b - a) * u, y + math.sin(u * math.pi) * sag)
                if prev then
                    local d, mid = p - prev, (p + prev) / 2
                    local seg = Instance.new("Frame")
                    seg.BorderSizePixel = 0
                    seg.BackgroundColor3 = Color3.fromRGB(30, 60, 35)
                    seg.AnchorPoint = Vector2.new(0.5, 0.5)
                    seg.Position = UDim2.fromOffset(mid.X, mid.Y)
                    seg.Size = UDim2.fromOffset(d.Magnitude + 1, wire)
                    seg.Rotation = math.deg(math.atan2(d.Y, d.X))
                    seg.ZIndex = z
                    seg.Parent = holder
                end
                if j == 2 or j == 4 or j == 6 then
                    k += 1
                    local bl = Instance.new("Frame")
                    bl.AnchorPoint = Vector2.new(0.5, 0)
                    bl.BorderSizePixel = 0
                    bl.BackgroundColor3 = WINDOW_BULBS[(k - 1) % #WINDOW_BULBS + 1]
                    bl.Position = UDim2.fromOffset(p.X, p.Y)
                    bl.Size = UDim2.fromOffset(bulbSize, bulbSize * 1.3)
                    bl.ZIndex = z + 1
                    Instance.new("UICorner", bl).CornerRadius = UDim.new(1, 0)
                    local st = Instance.new("UIStroke", bl)
                    st.Color = bl.BackgroundColor3
                    st.Thickness = big and 4 or 2
                    st.Transparency = 0.5
                    bl.Parent = holder
                    table.insert(windowBulbs, { bl, k * 0.5, st })
                end
                prev = p
            end
        end
    end
    build()
    uiConnect(ov:GetPropertyChangedSignal("AbsoluteSize"), function() task.defer(build) end)
end

local windowDone = setmetatable({}, { __mode = "k" })
local function decorateWindow(win, opts)
    if windowDone[win] or not win:IsA("GuiObject") then return end
    windowDone[win] = true
    opts = opts or {}
    local stroke = win:FindFirstChildOfClass("UIStroke")
    if stroke then uiSet(stroke, "Color", GOLD_FRAME) end
    local ov = windowOverlay(win)
    local z = win.ZIndex + 60
    local snowTex, hollyTex = nyAsset("textures/snow_cap.png"), nyAsset("textures/holly.png")
    if snowTex and not opts.noSnow then
        uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex, ZIndex = z + 2,
            AnchorPoint = Vector2.new(0.5, 0.6), Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(1, 24, 0, math.clamp(opts.snowH or 70, 30, 110)) }, ov)
    end
    if hollyTex and not opts.noHolly then
        local hs = opts.hollySize or 110
        uiMake("ImageLabel", { Name = "NY_HollyL", BackgroundTransparency = 1, Image = hollyTex, ZIndex = z + 3,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(6, 4), Size = UDim2.fromOffset(hs, hs),
            Rotation = -20 }, ov)
        uiMake("ImageLabel", { Name = "NY_HollyR", BackgroundTransparency = 1, Image = hollyTex, ZIndex = z + 3,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -6, 0, 4), Size = UDim2.fromOffset(hs, hs),
            Rotation = 20 }, ov)
    end
    if not opts.noGarland then windowGarland(ov, z, opts.garlandY or 14) end
end

-- карточка-подарок: атласная лента с бантиком через верхний угол, золотая рамка, снежок по верху
local cardDone = setmetatable({}, { __mode = "k" })
local CARD_RIBBONS = { Color3.fromRGB(255, 205, 80), Color3.fromRGB(230, 45, 60), Color3.fromRGB(250, 250, 250),
    Color3.fromRGB(80, 200, 120) }
local function decorateCard(card)
    if cardDone[card] or not card:IsA("GuiObject") then return end
    cardDone[card] = true
    local n = 0
    for k = 1, #card.Name do n += card.Name:byte(k) end
    local ribbon = CARD_RIBBONS[n % #CARD_RIBBONS + 1]
    local cornerTex, snowTex = nyAsset("textures/corner_ribbon.png"), nyAsset("textures/snow_cap.png")
    if cornerTex then
        uiMake("ImageLabel", { Name = "NY_CornerRibbon", BackgroundTransparency = 1, Image = cornerTex, ImageColor3 = ribbon,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.4, 0.4),
            ZIndex = card.ZIndex + 30 }, card)
    end
    if snowTex then
        uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex, ZIndex = card.ZIndex + 31,
            AnchorPoint = Vector2.new(0.5, 0.62), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 8, 0.11, 0) }, card)
    end
    local stroke = card:FindFirstChildOfClass("UIStroke")
    if stroke then
        uiSet(stroke, "Color", GOLD_FRAME)
    else
        uiMake("UIStroke", { Name = "NY_Stroke", Color = GOLD_FRAME, Thickness = 3, Transparency = 0.15,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
    end
end

-- снегопад внутри окна (магазин, инвентарь): хлопья медленно падают и покачиваются
local function uiSnowfall(root, z, count)
    local holder = uiMake("Frame", { Name = "NY_Snowfall", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true, ZIndex = z }, root)
    local flakes = {}
    for i = 1, count do
        local f = Instance.new("Frame")
        local size = math.random(3, 9)
        f.Size = UDim2.fromOffset(size, size)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
        f.BackgroundTransparency = 0.15 + math.random() * 0.45
        f.ZIndex = z
        Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
        f.Parent = holder
        flakes[i] = { f = f, x = math.random(), y = math.random(), v = 0.03 + math.random() * 0.05 + size * 0.004,
            sway = math.random() * 6.28, amp = 0.004 + math.random() * 0.01 }
    end
    uiConnect(RunService.Heartbeat, function(dt)
        if not (root.Visible and holder.Parent) then return end
        local t = os.clock()
        for _, fl in ipairs(flakes) do
            fl.y += fl.v * dt
            if fl.y > 1.05 then fl.y, fl.x = -0.05, math.random() end
            fl.f.Position = UDim2.fromScale(fl.x + math.sin(t * 0.8 + fl.sway) * fl.amp, fl.y)
        end
    end)
end

-- зимний фон окна во весь экран: ночная синева сверху, ёлочная зелень снизу
local function winterBackground(root)
    local bg = root:FindFirstChild("Background")
    if not (bg and bg:IsA("GuiObject")) then return end
    uiSet(bg, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
    uiMake("UIGradient", { Name = "NY_Winter", Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 26, 52)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(16, 38, 44)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 46, 30)) }) }, bg)
end

local function decorateWindows(pg)
    -- после выключения/включения в меню оформляем заново
    windowDone = setmetatable({}, { __mode = "k" })
    cardDone = setmetatable({}, { __mode = "k" })
    windowBulbs = {}
    -- мигание огоньков на окнах
    uiConnect(RunService.Heartbeat, function()
        local now = os.clock()
        for i = #windowBulbs, 1, -1 do
            local e = windowBulbs[i]
            if not e[1].Parent then
                table.remove(windowBulbs, i)
            else
                local on = math.floor(now * 1.6 + e[2]) % 2 == 0
                e[1].BackgroundTransparency = on and 0 or 0.55
                e[3].Transparency = on and 0.35 or 0.9
            end
        end
    end)
    local function hookRoot(root, fn)
        if not root then return end
        for _, d in ipairs(root:GetDescendants()) do pcall(fn, d) end
        uiConnect(root.DescendantAdded, function(d) task.defer(function() pcall(fn, d) end) end)
    end
    local mainUI = pg:FindFirstChild("MainUI")
    local settings = mainUI and mainUI:FindFirstChild("Settings")
    if settings then
        decorateWindow(settings, { snowH = 80, hollySize = 120 })
        for _, name in ipairs({ "Inventory", "Journal" }) do
            local b = settings:FindFirstChild(name)
            if b then decorateWindow(b, { noGarland = true, noHolly = true, snowH = 40 }) end
        end
    end
    local global = pg:FindFirstChild("GlobalUI")
    local inv = global and global:FindFirstChild("Inventory")
    local shop = global and global:FindFirstChild("Shop")
    local invFrame = inv and inv:FindFirstChild("InventoryFrame")
    if invFrame then decorateWindow(invFrame, { snowH = 90, hollySize = 150 }) end
    -- диалоги «Вы уверены?» и т.п.
    for _, root in ipairs({ inv, shop }) do
        if root then
            for _, name in ipairs({ "Confirmation", "Equip" }) do
                local d = root:FindFirstChild(name)
                if d then decorateWindow(d, { snowH = 60, hollySize = 90 }) end
            end
        end
    end
    -- магазин и инвентарь во весь экран: зимний фон, снегопад и большая гирлянда по верху экрана
    for _, root in ipairs({ shop, inv }) do
        if root then
            pcall(winterBackground, root)
            uiSnowfall(root, 0, 70)
            local ov = uiMake("Frame", { Name = "NY_Top", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 4 }, root)
            windowGarland(ov, 4, 6, true)
        end
    end
    -- праздничная покраска окна: бежевые кнопки -> красный/зелёный/золото, обводки -> золото,
    -- шапки Санты на заголовках, вкладки-леденцы со снежком
    local function festivize(rootGui)
        if not rootGui then return end
        local function beige(c)
            return math.abs(c.R * 255 - 255) < 2 and math.abs(c.G * 255 - 222) < 2 and math.abs(c.B * 255 - 189) < 2
        end
        -- бежевые кнопки и вкладки -> праздничные цвета по очереди (красный, зелёный, золото)
        local PAL = { Color3.fromRGB(196, 38, 50), Color3.fromRGB(38, 132, 72), Color3.fromRGB(212, 160, 48) }
        local nBg = 0
        local candyTex = nyAsset("textures/candy_stripes.png")
        local snowTex = nyAsset("textures/snow_cap.png")
        local hatTex = nyAsset("textures/santa_hat.png")
        local function goldify(d)
            if d:IsA("UIStroke") and beige(d.Color) then uiSet(d, "Color", GOLD_FRAME) end
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Name == "Title_Store" then
                uiSet(d, "TextColor3", Color3.fromRGB(255, 214, 110))
                -- шапка Санты на заголовке окна
                if hatTex and not d:FindFirstChild("NY_TitleHat") then
                    local hat = uiMake("ImageLabel", { Name = "NY_TitleHat", BackgroundTransparency = 1, Image = hatTex,
                        AnchorPoint = Vector2.new(0.5, 0.85), Position = UDim2.fromScale(0.012, 0.32),
                        Size = UDim2.fromScale(0.5, 0.75), Rotation = -18, ZIndex = d.ZIndex + 2 }, d)
                    uiMake("UIAspectRatioConstraint", { AspectRatio = 1 }, hat)
                end
            end
            -- дорожка тумблера (Toggle, коричнево-розовая) — тоже праздничная, темнее
            local function tan(c)
                return math.abs(c.R * 255 - 204) < 3 and math.abs(c.G * 255 - 147) < 3 and math.abs(c.B * 255 - 121) < 3
            end
            if d:IsA("GuiObject") and (d.Name == "Toggle" or d.Name == "Track") and tan(d.BackgroundColor3) then
                nBg += 1
                local col = PAL[(nBg - 1) % #PAL + 1]:Lerp(Color3.new(0, 0, 0), 0.35)
                uiSet(d, "BackgroundColor3", col)
                uiConnect(d:GetPropertyChangedSignal("BackgroundColor3"), function()
                    if tan(d.BackgroundColor3) then d.BackgroundColor3 = col end
                end)
                return
            end
            if d:IsA("GuiObject") and d.BackgroundTransparency < 0.95 and beige(d.BackgroundColor3) then
                nBg += 1
                local col = PAL[(nBg - 1) % #PAL + 1]
                uiSet(d, "BackgroundColor3", col)
                -- игра красит обратно (нажали тумблер, выбрали кнопку) — возвращаем свой цвет;
                -- другой цвет (выключенный тумблер) не трогаем
                uiConnect(d:GetPropertyChangedSignal("BackgroundColor3"), function()
                    if beige(d.BackgroundColor3) then d.BackgroundColor3 = col end
                end)
                -- вкладки слева — как леденцы: полоски поверх цвета и снежок сверху
                if d.Name == "TabButton" then
                    if candyTex then
                        uiMake("ImageLabel", { Name = "NY_Candy", BackgroundTransparency = 1, Image = candyTex,
                            ImageTransparency = 0.7, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(48, 48),
                            Size = UDim2.fromScale(1, 1), ZIndex = d.ZIndex }, d)
                    end
                    if snowTex then
                        uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex,
                            AnchorPoint = Vector2.new(0.5, 0.3), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(1.1, 0.22),
                            ZIndex = d.ZIndex + 5 }, d)
                    end
                end
            end
        end

        for _, d in ipairs(rootGui:GetDescendants()) do pcall(goldify, d) end
        uiConnect(rootGui.DescendantAdded, function(d) task.defer(function() pcall(goldify, d) end) end)
    end
    -- админ-панель (DoorsAdmin): та же новогодняя рамка, снегопад внутри, золото вместо бежевого
    local adminGui = pg:FindFirstChild("DoorsAdmin")
    local adm = adminGui and adminGui:FindFirstChild("Container")
    if adm then
        decorateWindow(adm, { snowH = 100, hollySize = 150 })
        uiSnowfall(adm, 0, 50)
        local cm = adm:FindFirstChild("Confirm")
        local cmain = cm and cm:FindFirstChild("Main")
        if cmain then decorateWindow(cmain, { snowH = 60, hollySize = 90, noGarland = true }) end
    end
    -- экран смерти игры: окно статистики (OVERVIEW) — как окна инвентаря: золотая рамка, снег,
    -- остролист, гирлянда, снегопад внутри, шапка Санты на заголовке; кнопки внизу (Stats, Spectate,
    -- Play Again, Leave) и кнопки воскрешения — золотая обводка и снежок сверху
    local stats = mainUI and mainUI:FindFirstChild("Statistics")
    if stats then
        decorateWindow(stats, { snowH = 90, hollySize = 140 })
        uiSnowfall(stats, stats.ZIndex, 40)
        local title = stats:FindFirstChild("Title")
        if title and title:IsA("TextLabel") then
            uiSet(title, "TextColor3", Color3.fromRGB(255, 214, 110))
            local hatTex = nyAsset("textures/santa_hat.png")
            if hatTex then
                local hat = uiMake("ImageLabel", { Name = "NY_TitleHat", BackgroundTransparency = 1, Image = hatTex,
                    AnchorPoint = Vector2.new(0.5, 0.85), Position = UDim2.fromScale(0.012, 0.32),
                    Size = UDim2.fromScale(0.5, 0.75), Rotation = -18, ZIndex = title.ZIndex + 2 }, title)
                uiMake("UIAspectRatioConstraint", { AspectRatio = 1 }, hat)
            end
        end
        local death = stats:FindFirstChild("Death")
        if death and death:IsA("TextLabel") then uiSet(death, "TextColor3", Color3.fromRGB(255, 120, 120)) end
    end
    local function deathButtons(holder)
        if not holder then return end
        local snowTex = nyAsset("textures/snow_cap.png")
        local PAL = { Color3.fromRGB(150, 26, 38), Color3.fromRGB(28, 100, 55), Color3.fromRGB(150, 26, 38) }
        local k = 0
        for _, b in ipairs(holder:GetChildren()) do
            if b:IsA("GuiButton") then
                k += 1
                local st = b:FindFirstChildOfClass("UIStroke")
                if st then
                    uiSet(st, "Color", GOLD_FRAME)
                else
                    uiMake("UIStroke", { Name = "NY_Stroke", Color = GOLD_FRAME, Thickness = 3, Transparency = 0.1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
                end
                -- тёмно-коричневые кнопки — в праздничные красный/зелёный (серую «нет воскрешений» не трогаем)
                local c = b.BackgroundColor3
                if c.R > c.G * 1.15 and c.R < 0.45 then
                    uiSet(b, "BackgroundColor3", PAL[(k - 1) % #PAL + 1])
                end
                if snowTex then
                    uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex,
                        AnchorPoint = Vector2.new(0.5, 0.62), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(1, 10, 0.32, 4),
                        ZIndex = b.ZIndex + 5 }, b)
                end
            end
        end
    end
    pcall(deathButtons, mainUI and mainUI:FindFirstChild("DeathPanel"))
    pcall(deathButtons, mainUI and mainUI:FindFirstChild("AfterDeathHolder"))
    festivize(stats)
    festivize(adm)
    festivize(inv)
    festivize(shop)
    festivize(settings)
    -- карточки (у карточек игры есть атрибут SkinPath)
    local function maybeCard(d)
        if d:IsA("GuiButton") and d:GetAttribute("SkinPath") ~= nil and d.Name ~= "_Template" then decorateCard(d) end
    end
    hookRoot(shop, maybeCard)
    hookRoot(inv, maybeCard)
end

local function applyFestiveUI()
    uiRevert()
    if not CONFIG.UI_FESTIVE then return end
    task.spawn(function()
        local pg = player:WaitForChild("PlayerGui")
        local mainUI = pg:WaitForChild("MainUI", 60)
        local mainFrame = mainUI and mainUI:WaitForChild("MainFrame", 30)
        if not mainFrame then return end
        if CONFIG.UI_HEALTH then
            local ok, err = pcall(decorateHealth, mainFrame)
            if not ok then warn("[NewYear] Интерфейс, здоровье: " .. tostring(err)) end
        end
        if CONFIG.UI_HOTBAR then
            local ok, err = pcall(decorateHotbar, mainUI, mainFrame)
            if not ok then warn("[NewYear] Интерфейс, хотбар: " .. tostring(err)) end
        end
        if CONFIG.UI_WINDOWS then
            local ok, err = pcall(decorateWindows, pg)
            if not ok then warn("[NewYear] Интерфейс, окна: " .. tostring(err)) end
        end
        -- игра пересоздала интерфейс (смерть, новый забег) — оформляем заново
        uiConnect(pg.ChildAdded, function(c)
            if c.Name == "MainUI" or c.Name == "GlobalUI" or c.Name == "DoorsAdmin" then task.delay(1, applyFestiveUI) end
        end)
    end)
end
live.ui = applyFestiveUI
local okUI, errUI = pcall(applyFestiveUI)
report("FestiveUI", okUI, errUI)

---------------------------------------------------------------- шкафы, коврики, Скрич, Халт, экран смерти

report("Extras", pcall(function()
    local TweenService = game:GetService("TweenService")
    -- гирлянда внутри шкафа: по верхнему краю изнутри, загорается и мигает, только когда ты в нём прячешься
    local CLOSET_WORDS = { "wardrobe", "locker_large", "closet", "toolshed" }
    local closets = {} -- { model, cf, size, bulbs, light }
    local closetDone = setmetatable({}, { __mode = "k" })
    local function isCloset(m)
        local n = m.Name:lower()
        for _, w in ipairs(CLOSET_WORDS) do if n:find(w, 1, true) then return true end end
        return false
    end
    local function closetGarland(room, m)
        if closetDone[m] then return end
        closetDone[m] = true
        local cf, size = m:GetBoundingBox()
        if size.Y < 4 or size.X > 14 or size.Z > 14 then return end
        local folder = roomFolder(room)
        local hx, hz, y = size.X / 2 - 0.55, size.Z / 2 - 0.55, size.Y / 2 - 0.85
        local corners = { Vector3.new(-hx, y, -hz), Vector3.new(hx, y, -hz), Vector3.new(hx, y, hz), Vector3.new(-hx, y, hz) }
        local bulbs, k = {}, 0
        for i = 1, 4 do
            local a, b = corners[i], corners[i % 4 + 1]
            local len = (b - a).Magnitude
            if len > 0.3 then
                local wire = decorPart({ Name = "ClosetWire", Size = Vector3.new(0.05, 0.05, len), Color = Color3.fromRGB(30, 60, 35),
                    CFrame = cf * CFrame.lookAt((a + b) / 2, b) })
                wire.Parent = folder
                local n = math.max(1, math.floor(len / 0.55))
                for j = 0, n - 1 do
                    local u = (j + 0.5) / n
                    k += 1
                    local bulb = decorPart({ Name = "ClosetBulb", Shape = Enum.PartType.Ball, Size = Vector3.new(0.17, 0.17, 0.17),
                        Material = Enum.Material.SmoothPlastic, Color = FESTIVE_COLORS[k % #FESTIVE_COLORS + 1],
                        CFrame = cf * CFrame.new(a + (b - a) * u - Vector3.new(0, 0.1, 0)) })
                    bulb.Parent = folder
                    table.insert(bulbs, bulb)
                end
            end
        end
        local lp = decorPart({ Name = "ClosetLight", Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2),
            CFrame = cf * CFrame.new(0, y - 0.3, 0) })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 200, 140)
        light.Range = 5
        light.Brightness = 0
        light.Shadows = false
        light.Parent = lp
        lp.Parent = folder
        table.insert(closets, { model = m, cf = cf, size = size, bulbs = bulbs, light = light })
    end
    local litCloset
    local function setCloset(c, on)
        for _, b in ipairs(c.bulbs) do
            if b.Parent then b.Material = on and Enum.Material.Neon or Enum.Material.SmoothPlastic end
        end
        c.light.Brightness = on and 1.1 or 0
    end
    local acc = 0
    connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 0.15 then return end
        acc = 0
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local found
        if CONFIG.CLOSET_LIGHTS and hrp then
            local cam = workspace.CurrentCamera
            local pts = { hrp.Position, cam and cam.CFrame.Position }
            for i = #closets, 1, -1 do
                local c = closets[i]
                if not c.model.Parent then
                    table.remove(closets, i)
                else
                    for _, p in ipairs(pts) do
                        local lp = c.cf:PointToObjectSpace(p)
                        if math.abs(lp.X) < c.size.X / 2 and math.abs(lp.Y) < c.size.Y / 2 and math.abs(lp.Z) < c.size.Z / 2 then
                            found = c
                        end
                    end
                end
                if found then break end
            end
            if not found and char:GetAttribute("Hiding") then
                local best = 7
                for _, c in ipairs(closets) do
                    local d = (c.cf.Position - hrp.Position).Magnitude
                    if d < best then best, found = d, c end
                end
            end
        end
        if found ~= litCloset then
            if litCloset then setCloset(litCloset, false) end
            if found then setCloset(found, true) end
            litCloset = found
        end
        -- мигание: огоньки по очереди чуть гаснут
        if litCloset then
            local t = os.clock()
            for i, b in ipairs(litCloset.bulbs) do
                b.Transparency = (math.sin(t * 3 + i * 0.9) > 0.55) and 0.45 or 0
            end
        end
    end)

    -- Халт: голубые огоньки в коридоре -> снежинки, и сверху сыплет снег
    local SNOW_WHITE = ColorSequence.new(Color3.fromRGB(240, 246, 255))
    local snowedEmitter = setmetatable({}, { __mode = "k" })
    local function snowifyEmitter(e)
        if snowedEmitter[e] then return end
        snowedEmitter[e] = true
        local tex = nyAsset("textures/snowflake_sticker.png")
        if tex then pcall(setLocal, e, "Texture", tex) end
        pcall(setLocal, e, "Color", SNOW_WHITE)
        pcall(setLocal, e, "RotSpeed", NumberRange.new(-60, 60))
    end
    local haltDone = setmetatable({}, { __mode = "k" })
    local function isHaltRoom(room)
        local raw = tostring(room:GetAttribute("RawName") or "") .. " " .. room.Name
        return raw:lower():find("halt", 1, true) ~= nil
    end
    local function haltSnow(room)
        if haltDone[room] then return end
        haltDone[room] = true
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("ParticleEmitter") then snowifyEmitter(d) end
        end
        connect(room.DescendantAdded, function(d)
            if d:IsA("ParticleEmitter") and CONFIG.HALT_SNOW then task.defer(snowifyEmitter, d) end
        end)
        local cf, size = room:GetBoundingBox()
        local ep = decorPart({ Name = "HaltSnow", Transparency = 1, Size = Vector3.new(math.min(size.X, 60), 0.2, math.min(size.Z, 60)),
            CFrame = CFrame.new(cf.Position + Vector3.new(0, math.min(size.Y / 2, 10) - 0.5, 0)) })
        local e = Instance.new("ParticleEmitter")
        e.Texture = nyAsset("textures/snowflake_sticker.png") or "rbxasset://textures/particles/sparkles_main.dds"
        e.Color = SNOW_WHITE
        e.Size = NumberSequence.new(0.14, 0.09)
        e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.85, 0.35),
            NumberSequenceKeypoint.new(1, 1) })
        e.LightEmission = 0.4
        e.Rate = 40
        e.Speed = NumberRange.new(1.5, 2.5)
        e.Lifetime = NumberRange.new(5, 7)
        e.EmissionDirection = Enum.NormalId.Bottom
        e.SpreadAngle = Vector2.new(20, 20)
        e.Rotation = NumberRange.new(0, 360)
        e.RotSpeed = NumberRange.new(-60, 60)
        e.Shape = Enum.ParticleEmitterShape.Box
        e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        e.Parent = ep
        ep.Parent = roomFolder(room)
    end

    local function scanRoom(room)
        if not room.Parent then return end
        if CONFIG.HALT_SNOW and isHaltRoom(room) then
            local ok, err = pcall(haltSnow, room)
            if not ok then warn("[NewYear] Снег у Халта: " .. tostring(err)) end
        end
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("Model") then
                local n = d.Name:lower()
                if CONFIG.CLOSET_LIGHTS and isCloset(d) then
                    local ok, err = pcall(closetGarland, room, d)
                    if not ok then warn("[NewYear] Гирлянда в шкафу: " .. tostring(err)) end
                end
            end
        end
    end
    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 60)
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do task.spawn(scanRoom, room) end
        connect(rooms.ChildAdded, function(room)
            task.delay(1.5, scanRoom, room)
            task.delay(5, scanRoom, room)
        end)
    end)

    -- Скрич: звенит колокольчик, когда он выпрыгивает. Халт (Shade): его огоньки — снежинки
    local function onCameraChild(c)
        if c.Name == "Screech" and CONFIG.SCREECH_BELL then
            task.spawn(playNySound, "sounds/ny_bell.mp3", CONFIG.SCREECH_BELL_VOLUME or 1)
        elseif c.Name == "Shade" and CONFIG.HALT_SNOW then
            task.delay(0.2, function()
                for _, d in ipairs(c:GetDescendants()) do
                    if d:IsA("ParticleEmitter") then snowifyEmitter(d) end
                end
            end)
        end
    end
    local function hookCamera(cam)
        if not cam then return end
        connect(cam.ChildAdded, onCameraChild)
    end
    hookCamera(workspace.CurrentCamera)
    connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function() hookCamera(workspace.CurrentCamera) end)

    -- Экран смерти: новогодняя открытка сверху — кто поймал и у какой двери, по экрану лёгкий снег.
    -- Кто — из GameStats.Player_<ник>.Total.DeathCause (это же читает Путеводный свет); если пусто —
    -- последний монстр, которого видели за 20 секунд до смерти. Дверь — атрибут CurrentRoom у игрока
    -- или GameData.LatestRoom.
    -- кто поймал: { ключ в имени, как зовут, фразы } — фраза каждый раз случайная (не как в прошлый раз)
    local KILLERS = {
        { "rush", "Раш", { "промчался с бубенцами", "не затормозил у ёлки", "развозил подарки и не заметил тебя",
            "пронёсся на санях без остановки", "звенел-звенел — и нашёл" } },
        { "ambush", "Эмбуш", { "вернулся за тобой ещё раз", "забыл подарок и вернулся", "катался туда-сюда, как с горки",
            "передумал уезжать" } },
        { "seek", "Сик", { "догнал в погоне", "оказался быстрее Деда Мороза", "бежал за тобой, как за последним мандарином",
            "смотрел со всех стен сразу" } },
        { "figure", "Фигура", { "услышала тебя", "услышала шуршание фантика", "не любит громкие хлопушки",
            "поймала под омелой" } },
        { "halt", "Халт", { "заморозил коридор", "сказал «стой», а ты не послушал", "устроил метель в коридоре" } },
        { "screech", "Скрич", { "укусил из темноты", "хотел конфету, а укусил тебя", "выпрыгнул из-за ёлки" } },
        { "eyes", "Глаза", { "засмотрелся, как на гирлянду", "слишком ярко светили", "это была не ёлочная игрушка" } },
        { "lookman", "Глаза", { "засмотрелся, как на гирлянду", "это была не ёлочная игрушка" } },
        { "hide", "Хайд", { "выгнал из шкафа", "шкаф — не место для зимней спячки" } },
        { "timothy", "Тимоти", { "выскочил из ящика с подарками", "прятался в ящике вместо подарка" } },
        { "jack", "Джек", { "напугал", "выглянул вместо Деда Мороза" } },
        { "glitch", "Глитч", { "утащил вперёд" } }, { "void", "Пустота", { "забрала", "унесла в метель" } },
        { "dupe", "Дуп", { "не та дверь", "дверь была с сюрпризом" } },
        { "snare", "Капкан", { "захлопнулся", "лежал вместо коврика" } },
        { "haste", "Хэйст", { "время вышло — куранты пробили" } }, { "blitz", "Блиц", { "пронёсся мимо" } },
        { "grumble", "Грамбл", { "проворчал своё" } }, { "giggle", "Гиггл", { "упал сверху, как сосулька" } },
        { "gloom", "Глумбаты", { "налетели стаей" } }, { "fall", "Падение", { "высоко было", "поскользнулся на льду" } },
    }
    local UNKNOWN = { "Кто-то из темноты", { "так и не показался", "оставил только следы на снегу",
        "наверное, это был Крампус" } }
    local TITLES = { "Тебя поймали!", "Ой-ой-ой!", "Праздник прервался!", "Не успел к ёлке!", "Забег окончен!",
        "Подарок не доехал…" }
    local FOOTERS = { "Не грусти — ёлка ждёт. Следующий забег будет удачнее!", "Загадай желание и попробуй ещё раз!",
        "Мандарины подождут — вперёд за реваншем!", "Дед Мороз верит в тебя!", "Следующая дверь точно будет счастливой",
        "Отогрейся у камина — и снова в путь!", "В новом году — новые двери!" }
    local lastPick = {}
    local function pickOne(list, tag)
        if #list == 1 then return list[1] end
        local v
        repeat v = list[math.random(#list)] until v ~= lastPick[tag]
        lastPick[tag] = v
        return v
    end
    local lastSeen = {} -- [ключ из KILLERS] = os.clock()
    local function noteEntity(inst)
        local n = inst.Name:lower()
        for _, k in ipairs(KILLERS) do
            if n:find(k[1], 1, true) then lastSeen[k[1]] = os.clock() return end
        end
        if n == "shade" then lastSeen.halt = os.clock() end
    end
    connect(workspace.ChildAdded, noteEntity)
    local function hookCamEntities(cam)
        if cam then connect(cam.ChildAdded, noteEntity) end
    end
    hookCamEntities(workspace.CurrentCamera)
    connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function() hookCamEntities(workspace.CurrentCamera) end)

    local function killerInfo()
        local cause = ""
        pcall(function()
            local stats = game:GetService("ReplicatedStorage"):FindFirstChild("GameStats")
            local me = stats and stats:FindFirstChild("Player_" .. player.Name)
            local dc = me and me:FindFirstChild("DeathCause", true)
            if dc and dc.Value then cause = tostring(dc.Value) end
        end)
        local low = cause:lower()
        if low ~= "" then
            for _, k in ipairs(KILLERS) do
                if low:find(k[1], 1, true) then return k[2], k[3] end
            end
            return cause, { "" }
        end
        local best, bestT = nil, os.clock() - 20
        for _, k in ipairs(KILLERS) do
            local t = lastSeen[k[1]]
            if t and t > bestT then best, bestT = k, t end
        end
        if best then return best[2], best[3] end
        return UNKNOWN[1], UNKNOWN[2]
    end
    local function doorNumber()
        local n = tonumber(player:GetAttribute("CurrentRoom"))
        if not n then
            local gd = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
            local lr = gd and gd:FindFirstChild("LatestRoom")
            n = lr and tonumber(lr.Value)
        end
        return n
    end

    local deathGui
    local function clearDeath()
        if deathGui then
            local g = deathGui
            deathGui = nil
            for _, d in ipairs(g:GetDescendants()) do
                pcall(function()
                    if d:IsA("ImageLabel") then
                        TweenService:Create(d, TweenInfo.new(0.6), { ImageTransparency = 1 }):Play()
                    elseif d:IsA("TextLabel") or d:IsA("TextButton") then
                        TweenService:Create(d, TweenInfo.new(0.6), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
                    elseif d:IsA("Frame") then
                        TweenService:Create(d, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
                    elseif d:IsA("UIStroke") then
                        TweenService:Create(d, TweenInfo.new(0.6), { Transparency = 1 }):Play()
                    end
                end)
            end
            task.delay(0.7, function() g:Destroy() end)
        end
    end
    local function deathScreen()
        if not CONFIG.DEATH_SCREEN or deathGui then return end
        local pg = player:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "NewYearDeath"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 8
        track(gui)
        deathGui = gui
        local function make(class, props, parent)
            local i = Instance.new(class)
            for k, v in pairs(props) do i[k] = v end
            i.Parent = parent
            return i
        end
        -- снегопад по всему экрану (лёгкий)
        local flakes = {}
        for i = 1, 45 do
            local s = math.random(3, 8)
            local f = make("Frame", { Size = UDim2.fromOffset(s, s), AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(245, 250, 255), BackgroundTransparency = 0.3 + math.random() * 0.4 }, gui)
            make("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
            flakes[i] = { f = f, x = math.random(), y = math.random(), v = 0.03 + math.random() * 0.04 + s * 0.003,
                sway = math.random() * 6.28 }
        end

        -- открытка
        local card = make("Frame", { Name = "Card", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -260),
            Size = UDim2.fromOffset(440, 178), BackgroundColor3 = Color3.fromRGB(150, 22, 34), BorderSizePixel = 0 }, gui)
        make("UICorner", { CornerRadius = UDim.new(0, 16) }, card)
        make("UIStroke", { Color = Color3.fromRGB(255, 205, 80), Thickness = 3 }, card)
        make("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150)) }, card)
        -- полоска-трость по низу открытки
        local candyTex = nyAsset("textures/candy_stripes.png")
        if candyTex then
            local strip = make("ImageLabel", { BackgroundTransparency = 1, Image = candyTex, ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8),
                Size = UDim2.new(1, -36, 0, 9) }, card)
            make("UICorner", { CornerRadius = UDim.new(1, 0) }, strip)
        end
        -- остролист по верхним углам
        local holly = nyAsset("textures/holly.png")
        if holly then
            for _, side in ipairs({ 0, 1 }) do
                make("ImageLabel", { BackgroundTransparency = 1, Image = holly, AnchorPoint = Vector2.new(side, 0),
                    Position = UDim2.new(side, side == 0 and -26 or 26, 0, -30), Size = UDim2.fromOffset(84, 84),
                    Rotation = side == 0 and -18 or 18, ZIndex = 3 }, card)
            end
        end
        -- гирлянда по верхнему краю открытки
        local bulbs = {}
        do
            local n = 11
            for j = 0, n - 1 do
                local u = (j + 0.5) / n
                local sag = math.sin((u * 3 % 1) * math.pi) * 9
                local b = make("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(u, 0, 0, -4 + sag),
                    Size = UDim2.fromOffset(10, 14), BorderSizePixel = 0, ZIndex = 2,
                    BackgroundColor3 = FESTIVE_COLORS[j % #FESTIVE_COLORS + 1] }, card)
                make("UICorner", { CornerRadius = UDim.new(1, 0) }, b)
                make("UIStroke", { Color = b.BackgroundColor3, Thickness = 3, Transparency = 0.55 }, b)
                table.insert(bulbs, b)
            end
        end
        local function label(text, y, h, size, font, color)
            return make("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 24, 0, y), Size = UDim2.new(1, -48, 0, h),
                Text = text, TextSize = size, Font = font, TextColor3 = color or Color3.fromRGB(255, 244, 228), RichText = true,
                TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, ZIndex = 2 }, card)
        end
        local title = label(pickOne(TITLES, "title"), 22, 34, 30, Enum.Font.GothamBlack)
        make("UIStroke", { Color = Color3.fromRGB(90, 10, 18), Thickness = 2 }, title)
        local who = label("", 64, 28, 21, Enum.Font.GothamBold)
        local whereL = label("", 94, 26, 19, Enum.Font.GothamBold)
        local foot = label(pickOne(FOOTERS, "foot"), 126, 22, 14, Enum.Font.Gotham,
            Color3.fromRGB(255, 220, 200))
        foot.TextTransparency = 0.1
        -- фразу выбираем один раз на смерть (при повторном заполнении меняем, только если сменился монстр)
        local shownName, shownVerb
        local function fill()
            local name, verbs = killerInfo()
            if name ~= shownName then
                shownName, shownVerb = name, pickOne(verbs, name)
            end
            local verb = shownVerb or ""
            who.Text = ('<font color="#FFD25A">%s</font>%s'):format(name, verb ~= "" and (" — " .. verb) or "")
            local n = doorNumber()
            whereL.Text = n and ('у двери <font color="#FFD25A">№ %d</font>'):format(n) or ""
        end
        fill()
        -- закрыть
        local close = make("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10),
            Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Color3.fromRGB(255, 205, 80), Text = "×", TextSize = 20,
            Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(120, 18, 28), AutoButtonColor = true, ZIndex = 4 }, card)
        make("UICorner", { CornerRadius = UDim.new(1, 0) }, close)
        close.MouseButton1Click:Connect(function() if deathGui == gui then clearDeath() end end)

        gui.Parent = pg
        -- выезжает сверху, когда пройдёт скример
        task.delay(1.2, function()
            if deathGui ~= gui then return end
            fill()
            TweenService:Create(card, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = UDim2.new(0.5, 0, 0, 46) }):Play()
        end)
        task.delay(3, function() if deathGui == gui then fill() end end) -- причина может прийти с сервера позже
        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if not gui.Parent then conn:Disconnect() return end
            local t = os.clock()
            for _, fl in ipairs(flakes) do
                fl.y += fl.v * dt
                if fl.y > 1.05 then fl.y, fl.x = -0.05, math.random() end
                fl.f.Position = UDim2.fromScale(fl.x + math.sin(t * 0.8 + fl.sway) * 0.008, fl.y)
            end
            if deathGui == gui then
                for i, bl in ipairs(bulbs) do
                    bl.BackgroundTransparency = (math.sin(t * 2.5 + i * 0.9) > 0.55) and 0.55 or 0
                end
                card.Rotation = math.sin(t * 1.3) * 0.8
            end
        end)
        table.insert(connections, conn)
        task.delay(40, function() if deathGui == gui then clearDeath() end end)
    end
    local function hookChar(char)
        clearDeath()
        local hum = char:WaitForChild("Humanoid", 15)
        if hum then connect(hum.Died, deathScreen) end
    end
    if player.Character then task.spawn(hookChar, player.Character) end
    connect(player.CharacterAdded, hookChar)
end))

---------------------------------------------------------------- 100-я комната: мясо, бочки, ящики, щитки-конфеты

-- Всё внутри функции: в главном блоке почти не осталось места под локальные переменные.
-- Детали игры не удаляем и столкновения у них не трогаем — только делаем невидимыми, а поверх
-- ставим своё. (Если мясо со стены удалить, пропадает его столкновение — античит на ноуклип
-- думает, что ты прошёл сквозь стену, и тянет назад. С невидимым мясом такого нет.)
report("Room100", pcall(function()
    local done = setmetatable({}, { __mode = "k" })

    local function hideAll(model)
        local list = model:GetDescendants()
        table.insert(list, model)
        for _, d in ipairs(list) do
            if d:IsA("BasePart") and d.Transparency < 1 then
                keepHidden(d, "Transparency", 1)
            elseif (d:IsA("Decal") or d:IsA("Texture")) and d.Transparency < 1 then
                keepHidden(d, "Transparency", 1)
            elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                keepHidden(d, "Enabled", false)
            end
        end
    end
    local function bbox(inst)
        if inst:IsA("BasePart") then return inst.CFrame, inst.Size end
        local ok, cf, size = pcall(inst.GetBoundingBox, inst)
        if ok then return cf, size end
        return nil
    end
    local function biggestPart(model)
        local best
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") and (not best or d.Size.Magnitude > best.Size.Magnitude) then best = d end
        end
        if not best and model:IsA("BasePart") then best = model end
        return best
    end
    local function flatDir(v, fallback)
        local f = Vector3.new(v.X, 0, v.Z)
        if f.Magnitude < 1e-3 then return fallback or Vector3.zAxis end
        return f.Unit
    end
    local function excludeParams(model)
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = { model, root, player.Character }
        return p
    end
    -- свои детали приварены к детали игры: если она двигается — едут вместе с ней
    local function stick(base, part)
        if base then weldTo(base, part, base.CFrame:ToObjectSpace(part.CFrame)) end
    end

    ---------------------------------------------------------------- мясо Фигуры

    -- FesteringMeat: на стене — венок, на полу — сугробик (оба из новогодней версии DOORS)
    local function festiveMeat(room, m)
        local cf, size = bbox(m)
        if not cf then return end
        local center = cf.Position
        local params = excludeParams(m)
        local big = math.max(size.X, size.Y, size.Z)
        -- стена рядом? (лучи во все стороны по горизонтали)
        local wallHit
        for k = 0, 7 do
            local a = k * math.pi / 4
            local dir = Vector3.new(math.cos(a), 0, math.sin(a))
            local hit = workspace:Raycast(center, dir * (big / 2 + 1.5), params)
            if hit and math.abs(hit.Normal.Y) < 0.4 and (not wallHit or hit.Distance < wallHit.Distance) then
                wallHit = hit
            end
        end
        local floorHit = workspace:Raycast(center, Vector3.new(0, -(size.Y / 2 + 3), 0), params)
        local floorDist = floorHit and floorHit.Distance or math.huge
        local onWall = wallHit ~= nil and floorDist > math.min(size.Y / 2 + 0.6, 1.6)
        local folder = roomFolder(room)
        if onWall then
            local data = loadFestive("Wreath")
            if not data then return end
            hideAll(m)
            local n = flatDir(wallHit.Normal)
            local wsz = data.size and fV3(data.size) or Vector3.new(3.9, 4.1, 1.2)
            local sc = math.clamp(big * 0.95, 1.6, 4.2) / math.max(wsz.X, wsz.Y)
            local pos = Vector3.new(wallHit.Position.X, center.Y, wallHit.Position.Z) + n * (wsz.Z * sc / 2 + 0.03)
            local model = spawnFestive(data, CFrame.lookAt(pos, pos - n), { scale = sc })
            model.Parent = folder
        else
            local data = loadFestive("SnowPile")
            if not data then return end
            hideAll(m)
            local psz = data.size and fV3(data.size) or Vector3.new(14.4, 3.75, 7.46)
            local foot = math.max(size.X, size.Z) * 1.15
            local sc = math.clamp(foot / psz.X, 0.1, 0.45)
            local floorY = floorHit and floorHit.Position.Y or (center.Y - size.Y / 2)
            local look = flatDir(cf.LookVector)
            local pos = Vector3.new(center.X, floorY + psz.Y * sc / 2 - 0.08, center.Z)
            local model = spawnFestive(data, CFrame.lookAt(pos, pos + look) * CFrame.Angles(0, math.random() * 6.28, 0), {
                scale = sc, colors = { SnowPile = Color3.fromRGB(240, 246, 255) } })
            model.Parent = folder
            -- пара ёлочных шариков в сугробе
            for k = 1, 2 do
                local r = 0.28 + math.random() * 0.12
                local a = math.random() * 6.28
                local off = Vector3.new(math.cos(a), 0, math.sin(a)) * (psz.X * sc * 0.18)
                local ball = decorPart({ Name = "PileBall", Shape = Enum.PartType.Ball, Size = Vector3.new(r, r, r),
                    Color = FESTIVE_COLORS[math.random(#FESTIVE_COLORS)], Material = Enum.Material.SmoothPlastic,
                    Reflectance = 0.3, CFrame = CFrame.new(pos + off + Vector3.new(0, psz.Y * sc * 0.3, 0)) })
                ball.Parent = folder
            end
        end
    end

    ---------------------------------------------------------------- бочки с маслом

    local TIN_COLORS = { Color3.fromRGB(185, 25, 38), Color3.fromRGB(28, 120, 62), Color3.fromRGB(35, 75, 170) }
    local GOLD = Color3.fromRGB(225, 180, 70)
    local WHITE = Color3.fromRGB(248, 245, 238)
    local barrelN = 0

    -- цилиндр вдоль axis (мир), центр c, длина len, диаметр dia
    local function cyl(folder, base, c, axis, len, dia, color, mat, refl)
        local up = math.abs(axis.Y) < 0.9 and Vector3.yAxis or Vector3.xAxis
        local p = decorPart({ Name = "BarrelPiece", Shape = Enum.PartType.Cylinder, Size = Vector3.new(len, dia, dia),
            Color = color, Material = mat or Enum.Material.SmoothPlastic, Reflectance = refl or 0,
            CFrame = CFrame.fromMatrix(c, axis, up:Cross(axis).Unit:Cross(axis)) })
        p.Parent = folder
        stick(base, p)
        return p
    end

    local barrelSpots = setmetatable({}, { __mode = "k" }) -- [комната] = { центр бочки, ... }
    local function festiveBarrel(room, m, mode)
        local cf, size = bbox(m)
        if not cf then return end
        -- бочка-двойник на том же месте: прячем, второй раз не украшаем (иначе мерцает полосами)
        barrelSpots[room] = barrelSpots[room] or {}
        for _, c0 in ipairs(barrelSpots[room]) do
            if (c0 - cf.Position).Magnitude < 0.8 then
                hideAll(m)
                return
            end
        end
        table.insert(barrelSpots[room], cf.Position)
        local base = biggestPart(m)
        -- ось бочки: стоит — вверх, лежит — вдоль самой длинной стороны
        local axis, len, dia
        local up = math.abs(cf.UpVector.Y) > 0.9
        if up and size.Y >= math.max(size.X, size.Z) * 0.85 then
            axis, len, dia = Vector3.yAxis, size.Y, math.min(size.X, size.Z)
        else
            local ax = size.X >= size.Z and cf.RightVector or cf.LookVector
            axis, len, dia = ax, math.max(size.X, size.Z), math.min(size.Y, math.min(size.X, size.Z))
        end
        hideAll(m)
        local folder = roomFolder(room)
        local c = cf.Position
        barrelN += 1
        if mode == "gift" then
            local present = loadFestive("Present")
            local boxItem = present and festiveItem(present, "Box")
            local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
            local bottom = c.Y - size.Y / 2
            local W, H = math.min(size.X, size.Z), size.Y
            local look = flatDir(cf.LookVector)
            if present and boxItem then
                local ps = math.min(W / math.max(boxItem.size[1], boxItem.size[3]), H / boxItem.size[2]) * 0.98
                local h = boxItem.size[2] * ps
                local model = spawnFestive(present, CFrame.lookAt(Vector3.new(c.X, bottom + h / 2, c.Z),
                    Vector3.new(c.X, bottom + h / 2, c.Z) + look), {
                    scale = ps, weld = base, colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon } })
                model.Parent = folder
            else
                addGift(folder, CFrame.lookAt(Vector3.new(c.X, bottom, c.Z), Vector3.new(c.X, bottom, c.Z) + look),
                    Vector3.new(W, H * 0.9, W), style)
            end
            return
        end
        local a = axis.Unit
        if mode == "candy" then
            -- леденец: красно-белые кольца, золотые ободки по краям
            local n = 7
            for i = 0, n - 1 do
                local x = -len / 2 + len * (i + 0.5) / n
                cyl(folder, base, c + a * x, a, len / n + 0.01, dia * 0.98, i % 2 == 0 and Color3.fromRGB(205, 25, 40) or WHITE,
                    Enum.Material.SmoothPlastic, 0.12)
            end
            for _, s in ipairs({ -1, 1 }) do
                cyl(folder, base, c + a * (s * (len / 2 - 0.06)), a, 0.14, dia * 1.02, GOLD, Enum.Material.Metal, 0.2)
            end
            return
        end
        -- жестяная банка: цветной корпус, золотые пояски, белая крышка с золотым ободком, сверху бант
        local col = TIN_COLORS[(barrelN - 1) % #TIN_COLORS + 1]
        cyl(folder, base, c, a, len * 0.97, dia * 0.97, col, Enum.Material.SmoothPlastic, 0.1)
        for _, f in ipairs({ -0.3, 0.3 }) do
            cyl(folder, base, c + a * (f * len), a, len * 0.06, dia * 0.995, GOLD, Enum.Material.Metal, 0.2)
        end
        local topSign = (a.Y >= 0) and 1 or -1
        local lidC = c + a * (topSign * (len / 2 - len * 0.045))
        cyl(folder, base, lidC, a, len * 0.09, dia * 1.01, WHITE, Enum.Material.SmoothPlastic, 0.05)
        cyl(folder, base, c - a * (topSign * (len / 2 - 0.05)), a, 0.1, dia * 1.0, GOLD, Enum.Material.Metal, 0.2)
        if math.abs(a.Y) > 0.9 then
            -- бант на крышке
            local top = lidC + Vector3.new(0, len * 0.045 + 0.12, 0)
            local side = flatDir(cf.RightVector, Vector3.xAxis)
            local bowCol = col == TIN_COLORS[1] and GOLD or Color3.fromRGB(205, 25, 40)
            for _, s in ipairs({ -1, 1 }) do
                local p = decorPart({ Name = "TinBow", Size = Vector3.new(dia * 0.28, dia * 0.12, dia * 0.08), Color = bowCol,
                    Material = Enum.Material.Fabric,
                    CFrame = CFrame.lookAt(top + side * (s * dia * 0.12), top + side * (s * dia * 0.12) + Vector3.yAxis:Cross(side))
                        * CFrame.Angles(0, 0, math.rad(s * 25)) })
                p.Parent = folder
                stick(base, p)
            end
            local knot = decorPart({ Name = "TinBow", Shape = Enum.PartType.Ball, Size = Vector3.one * dia * 0.11,
                Color = bowCol, Material = Enum.Material.Fabric, CFrame = CFrame.new(top) })
            knot.Parent = folder
            stick(base, knot)
        end
    end

    ---------------------------------------------------------------- деревянные ящики -> подарки

    -- как в подвале: ставим снизу вверх, стоящий на другом ящике садится на подарок под ним
    local placedByRoom = setmetatable({}, { __mode = "k" })
    local function festiveCrates(room, list)
        placedByRoom[room] = placedByRoom[room] or {}
        local placed = placedByRoom[room]
        local present = loadFestive("Present")
        local boxItem = present and festiveItem(present, "Box")
        local items = {}
        for _, m in ipairs(list) do
            local cf, size = bbox(m)
            if cf then table.insert(items, { m = m, cf = cf, size = size }) end
        end
        table.sort(items, function(a, b) return a.cf.Position.Y < b.cf.Position.Y end)
        local folder = roomFolder(room)
        for _, it in ipairs(items) do
            local cf, size = it.cf, it.size
            local c = cf.Position
            local W, H = math.min(size.X, size.Z), size.Y
            -- ящик-двойник на том же месте (у игры такие бывают): прячем, но второй подарок не ставим —
            -- иначе два подарка разного цвета в одном месте мерцают полосами
            local dup = false
            for _, o in ipairs(placed) do
                if (o.center - c).Magnitude < math.max(0.6, W * 0.35) then dup = true break end
            end
            if dup then
                hideAll(it.m)
                continue
            end
            local bottom = c.Y - H / 2
            for _, o in ipairs(placed) do
                local dp = o.center - c
                if o.center.Y < c.Y - 0.5 and Vector3.new(dp.X, 0, dp.Z).Magnitude < W * 0.9 and o.top > bottom - 0.6 then
                    bottom = math.max(o.top, bottom - 0.6)
                end
            end
            hideAll(it.m)
            local base = biggestPart(it.m)
            local style = GIFT_STYLES[math.random(#GIFT_STYLES)]
            local look = flatDir(cf.LookVector)
            local h
            if present and boxItem and CONFIG.REAL_PRESENTS ~= false then
                local ps = math.min(W / math.max(boxItem.size[1], boxItem.size[3]), H / boxItem.size[2]) * 0.98
                h = boxItem.size[2] * ps
                local at = Vector3.new(c.X, bottom + h / 2, c.Z)
                local model = spawnFestive(present, CFrame.lookAt(at, at + look), {
                    scale = ps, weld = base, colors = { Box = style.box, Wrapper = style.ribbon, Bow = style.ribbon } })
                model.Parent = folder
            else
                h = H * 0.98
                addGift(folder, CFrame.lookAt(Vector3.new(c.X, bottom, c.Z), Vector3.new(c.X, bottom, c.Z) + look),
                    Vector3.new(W * 0.98, h, W * 0.98), style)
            end
            table.insert(placed, { center = c, top = bottom + h })
            giftCount += 1
        end
    end

    ---------------------------------------------------------------- конфета (3D)

    local CANDY_STYLES = {
        { Color3.fromRGB(215, 25, 40), WHITE, Color3.fromRGB(255, 196, 58) },
        { Color3.fromRGB(30, 150, 75), WHITE, Color3.fromRGB(230, 45, 55) },
        { Color3.fromRGB(55, 105, 225), WHITE, Color3.fromRGB(255, 196, 58) },
        { Color3.fromRGB(215, 25, 40), WHITE, Color3.fromRGB(40, 160, 85) },
    }
    -- конфета вдоль X длиной L: тело в полоску, перетяжки, фантики веером.
    -- Возвращает модель и список { p, rel, kind } (kind: body / wrap), rel — от центра конфеты.
    local function buildCandy(L, style, parent)
        local model = Instance.new("Model")
        model.Name = "NewYearCandy"
        local R = L * 0.19
        local bodyL = L * 0.4
        local pieces = {}
        local function add(kind, props, rel, sphere)
            local p = decorPart(props)
            if sphere then
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.Sphere
                mesh.Parent = p
            end
            p.Parent = model
            table.insert(pieces, { p = p, rel = rel, kind = kind })
            return p
        end
        local n = 6
        for i = 0, n - 1 do
            local x = -bodyL / 2 + bodyL * (i + 0.5) / n
            add("body", { Name = "CandyBody", Shape = Enum.PartType.Cylinder, Size = Vector3.new(bodyL / n + 0.004, R * 2, R * 2),
                Color = i % 2 == 0 and style[1] or style[2], Material = Enum.Material.SmoothPlastic, Reflectance = 0.15 },
                CFrame.new(x, 0, 0))
        end
        for _, s in ipairs({ -1, 1 }) do
            add("body", { Name = "CandyEnd", Size = Vector3.new(R * 1.1, R * 2, R * 2), Color = s < 0 and style[2] or style[1],
                Material = Enum.Material.SmoothPlastic, Reflectance = 0.15 }, CFrame.new(s * bodyL / 2, 0, 0), true)
            add("wrap", { Name = "CandyNeck", Shape = Enum.PartType.Cylinder, Size = Vector3.new(R * 0.4, R * 0.62, R * 0.62),
                Color = style[3], Material = Enum.Material.Foil, Reflectance = 0.2 },
                CFrame.new(s * (bodyL / 2 + R * 0.62), 0, 0))
            for k = 0, 2 do
                add("wrap", { Name = "CandyWrap", Size = Vector3.new(L * 0.22, R * 1.9, R * 0.22), Color = style[3],
                    Material = Enum.Material.Foil, Reflectance = 0.25 },
                    CFrame.new(s * (bodyL / 2 + R * 0.7 + L * 0.1), 0, 0) * CFrame.Angles(k * math.pi / 3, 0, 0)
                        * CFrame.Angles(0, 0, 0), true)
            end
        end
        model.Parent = parent
        return model, pieces
    end
    local function placeCandy(pieces, cf)
        for _, e in ipairs(pieces) do
            if e.p.Parent then e.p.CFrame = cf * e.rel end
        end
    end

    ---------------------------------------------------------------- съесть конфету

    -- Конфета перед камерой: поднимается снизу, фантик слетает (шуршит), три укуса с хрустом
    -- и крошками. Только у тебя на экране.
    -- крошки: разлетаются и падают (видны перед камерой)
    local function candyCrumbs(pos, color, n)
        for _ = 1, n do
            local c = decorPart({ Name = "CandyCrumb", Size = Vector3.new(0.05, 0.05, 0.05), Color = color,
                Material = Enum.Material.SmoothPlastic,
                CFrame = CFrame.new(pos + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.1) })
            c.Anchored = false
            c.Parent = root
            c.AssemblyLinearVelocity = Vector3.new((math.random() - 0.5) * 6, 1 + math.random() * 3, (math.random() - 0.5) * 6)
            game:GetService("Debris"):AddItem(c, 1.2)
        end
    end

    local eating = false
    local function eatCandy()
        if not CONFIG.CANDY_EAT or eating then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        eating = true
        local style = CANDY_STYLES[math.random(#CANDY_STYLES)]
        local model, pieces = buildCandy(0.5, style, cam)
        local bodies, wraps = {}, {}
        for _, e in ipairs(pieces) do
            table.insert(e.kind == "body" and bodies or wraps, e)
        end
        -- кусаем с правого конца
        table.sort(bodies, function(a, b) return a.rel.Position.X > b.rel.Position.X end)
        local BITES = { 0.95, 1.2, 1.45 }
        local bitten, unwrapped = 0, false
        local t0 = os.clock()
        local function lerp(a, b, u) return a:Lerp(b, u) end
        local function ease(u) u = math.clamp(u, 0, 1) return 1 - (1 - u) ^ 3 end
        local P0, P1, P2 = Vector3.new(0.45, -0.85, -1.3), Vector3.new(0.1, -0.3, -1.0), Vector3.new(0.02, -0.34, -0.62)
        local name = "NewYearCandyEat"
        local function finish()
            pcall(function() RunService:UnbindFromRenderStep(name) end)
            pcall(function() model:Destroy() end)
            eating = false
        end
        RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, function()
            local ok = pcall(function()
                local t = os.clock() - t0
                local c = workspace.CurrentCamera
                if not c or not model.Parent then error("нет камеры") end
                local pos
                if t < 0.4 then pos = lerp(P0, P1, ease(t / 0.4))
                elseif t < 0.8 then pos = P1 + Vector3.new(0, math.sin((t - 0.4) * 9) * 0.01, 0)
                else pos = lerp(P1, P2, ease((t - 0.8) / 0.18)) end
                local spin = (1 - ease(t / 0.4)) * 2.2
                local cf = c.CFrame * CFrame.new(pos) * CFrame.Angles(0, 0.35 * (1 - ease(t / 0.9)), math.rad(-12) + spin)
                -- фантик слетает
                if t > 0.45 and not unwrapped then
                    unwrapped = true
                    pcall(playNySound, "sounds/treat_rustle.mp3", 0.45)
                end
                for _, e in ipairs(bodies) do
                    if e.p.Parent then e.p.CFrame = cf * e.rel end
                end
                local u = math.clamp((t - 0.45) / 0.35, 0, 1)
                for i, e in ipairs(wraps) do
                    if e.p.Parent then
                        local side = e.rel.Position.X >= 0 and 1 or -1
                        local fly = CFrame.new(side * u * 0.5, -u * u * 0.9, -u * 0.1 * (i % 2 == 0 and 1 or -1))
                            * CFrame.Angles(u * 3 * side, u * 2, 0)
                        e.p.CFrame = cf * fly * e.rel
                        e.p.Transparency = u
                        if u >= 1 then e.p:Destroy() end
                    end
                end
                -- укусы
                for k, b in ipairs(BITES) do
                    if t >= b and bitten < k then
                        bitten = k
                        pcall(playNySound, "sounds/cane_crunch" .. math.random(3) .. ".mp3", CONFIG.CANE_SOUND_VOLUME or 0.6)
                        local per = math.ceil(#bodies / #BITES)
                        for i = (k - 1) * per + 1, math.min(#bodies, k * per) do
                            local e = bodies[i]
                            if e and e.p.Parent then
                                pcall(candyCrumbs, e.p.Position, e.p.Color, 3)
                                e.p:Destroy()
                            end
                        end
                    end
                end
                if t > 1.7 then error("готово") end
            end)
            if not ok then finish() end
        end)
        task.delay(4, function() if eating then finish() end end)
    end

    ---------------------------------------------------------------- щитки -> конфеты

    local lastEat = 0
    local function tryEat()
        if os.clock() - lastEat < 2 then return end
        lastEat = os.clock()
        task.spawn(eatCandy)
    end

    -- LiveBreakerPolePickup (щиток, который подбираешь в 100-й): прячем, на его месте — конфета,
    -- светится своим цветом. Пропал рядом с тобой — значит подобрал: съедаешь.
    local candyN = 0
    local function festivePickup(room, m)
        local cf, size = bbox(m)
        if not cf then return end
        local base = biggestPart(m)
        if not base then return end
        hideAll(m)
        candyN += 1
        local style = CANDY_STYLES[(candyN - 1) % #CANDY_STYLES + 1]
        local L = math.clamp(math.max(size.X, size.Y, size.Z) * 0.9, 1.0, 2.2)
        local model, pieces = buildCandy(L, style, roomFolder(room))
        local along = size.X >= size.Z and cf.RightVector or cf.LookVector
        along = flatDir(along, Vector3.xAxis)
        local candyCF = CFrame.fromMatrix(cf.Position, along, Vector3.yAxis) * CFrame.Angles(math.rad(20), 0, math.rad(8))
        placeCandy(pieces, candyCF)
        local light = Instance.new("PointLight")
        light.Color = style[1]:Lerp(Color3.new(1, 1, 1), 0.3)
        light.Range = 7
        light.Brightness = 0.8
        light.Shadows = false
        light.Parent = pieces[1].p
        -- едет за щитком (если игра его двигает)
        local off = base.CFrame:ToObjectSpace(candyCF)
        local lastCF = base.CFrame
        local conn
        conn = connect(RunService.Heartbeat, function()
            if not model.Parent then conn:Disconnect() return end
            if base.CFrame ~= lastCF then
                lastCF = base.CFrame
                placeCandy(pieces, base.CFrame * off)
            end
        end)
        -- подобрал — конфета пропадает (а если это было рядом с тобой — съедаешь)
        local function gone()
            if m:IsDescendantOf(room) and base:IsDescendantOf(m) then return end
            if not model.Parent then return end
            local pos = model:GetPivot().Position
            model:Destroy()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - pos).Magnitude < 14 then tryEat() end
        end
        connect(m.AncestryChanged, gone)
        connect(base.AncestryChanged, gone)
    end

    -- счётчик щитков в интерфейсе (MainUI ... BreakerPoles): картинка — конфета, полоска — как
    -- здоровье (белая с красными косыми полосками, снежная шапка). Счёт вырос — съел конфету.
    local counterSeen = setmetatable({}, { __mode = "k" })
    local function decorateCounter(img)
        if not (CONFIG.UI_FESTIVE and CONFIG.BREAKER_CANDY) then return end
        if img:FindFirstChild("NY_CandyMark") then return end
        uiMake("Folder", { Name = "NY_CandyMark" }, img)
        local icon = nyAsset("textures/candy_icon.png")
        if icon then uiSet(img, "Image", icon) end
        local candyTex = nyAsset("textures/candy_stripes.png")
        local snowTex = nyAsset("textures/snow_cap.png")
        local dur = img:FindFirstChild("Durability")
        if dur then
            local stroke = dur:FindFirstChildOfClass("UIStroke")
            if stroke then uiSet(stroke, "Color", Color3.fromRGB(205, 40, 50)) end
            local fill = dur:FindFirstChild("Bar")
            if fill and fill:IsA("GuiObject") then
                uiSet(fill, "BackgroundColor3", Color3.fromRGB(250, 247, 242))
                if candyTex then
                    local im = uiMake("ImageLabel", { Name = "NY_Candy", BackgroundTransparency = 1, Image = candyTex,
                        ScaleType = Enum.ScaleType.Tile, Size = UDim2.fromScale(1, 1), ZIndex = fill.ZIndex,
                        TileSize = UDim2.fromOffset(32, 32) }, fill)
                    local corner = fill:FindFirstChildOfClass("UICorner") or dur:FindFirstChildOfClass("UICorner")
                    uiMake("UICorner", { CornerRadius = corner and corner.CornerRadius or UDim.new(0.25, 0) }, im)
                    uiMake("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.35, 0.05), NumberSequenceKeypoint.new(1, 0.2) }),
                        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(225, 215, 215)) }, im)
                    local function tile()
                        local h = math.max(fill.AbsoluteSize.Y, 8)
                        im.TileSize = UDim2.fromOffset(h * 1.6, h * 1.6)
                    end
                    tile()
                    uiConnect(fill:GetPropertyChangedSignal("AbsoluteSize"), tile)
                end
            end
            for _, mk in ipairs(dur:GetChildren()) do
                if mk.Name == "Marker" and mk:IsA("GuiObject") then
                    uiSet(mk, "BackgroundColor3", Color3.fromRGB(190, 30, 40))
                end
            end
            if snowTex then
                uiMake("ImageLabel", { Name = "NY_SnowCap", BackgroundTransparency = 1, Image = snowTex,
                    AnchorPoint = Vector2.new(0.5, 0.62), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 22, 0.9, 10),
                    ZIndex = 20, ScaleType = Enum.ScaleType.Stretch }, dur)
            end
        end
        local num = img:FindFirstChild("DurabilityNumber")
        if num and num:IsA("TextLabel") then
            uiSet(num, "TextColor3", Color3.fromRGB(255, 214, 120))
            local ns = num:FindFirstChildOfClass("UIStroke")
            if ns then uiSet(ns, "Color", Color3.fromRGB(110, 14, 24)) end
        end
    end

    ---------------------------------------------------------------- скан 100-й (для доработки)

    local scanned = false
    local function scan100(room)
        if scanned then return end
        scanned = true
        local lines = { "Комната " .. room:GetFullName() .. "  " .. os.date() }
        local function dumpModel(m, limit)
            local cf, size = bbox(m)
            table.insert(lines, ("== %s [%s] size=%s"):format(m:GetFullName(), m.ClassName,
                size and ("%.2f,%.2f,%.2f"):format(size.X, size.Y, size.Z) or "?"))
            local n = 0
            for _, d in ipairs(m:GetDescendants()) do
                n += 1
                if n > limit then table.insert(lines, "   ...") break end
                local extra = ""
                if d:IsA("BasePart") then
                    local rel = cf and cf:ToObjectSpace(d.CFrame)
                    extra = (" size=%.2f,%.2f,%.2f transp=%.2f query=%s coll=%s anch=%s mat=%s"):format(d.Size.X, d.Size.Y, d.Size.Z,
                        d.Transparency, tostring(d.CanQuery), tostring(d.CanCollide), tostring(d.Anchored), d.Material.Name)
                    if rel then extra ..= (" rel=%.2f,%.2f,%.2f"):format(rel.X, rel.Y, rel.Z) end
                    if d:IsA("MeshPart") then extra ..= " mesh=" .. d.MeshId end
                elseif d:IsA("ProximityPrompt") then
                    extra = (" action=%q object=%q"):format(d.ActionText, d.ObjectText)
                end
                table.insert(lines, "   " .. d:GetFullName():sub(#m:GetFullName() + 2) .. " [" .. d.ClassName .. "]" .. extra)
            end
        end
        local counts, examples = {}, {}
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("Model") then
                counts[d.Name] = (counts[d.Name] or 0) + 1
                if not examples[d.Name] then examples[d.Name] = d end
            end
        end
        local names = {}
        for k in pairs(counts) do table.insert(names, k) end
        table.sort(names)
        table.insert(lines, "Модели:")
        for _, k in ipairs(names) do table.insert(lines, ("  %3d  %s"):format(counts[k], k)) end
        for _, k in ipairs(names) do
            local low = k:lower()
            if low:find("shelf") or low:find("rack") or low:find("breaker") or low:find("meat")
                or low:find("barrel") or low:find("crate") or low:find("key") then
                dumpModel(examples[k], 120)
            end
        end
        pcall(function()
            local pg = player:FindFirstChildOfClass("PlayerGui")
            local main = pg and pg:FindFirstChild("MainUI")
            local bp = main and main:FindFirstChild("BreakerPoles", true)
            table.insert(lines, "Счётчик: " .. (bp and bp:GetFullName() or "не найден"))
        end)
        pcall(function()
            if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
            writefile("StevieBuddy/room100_scan.txt", table.concat(lines, "\n"))
        end)
    end

    ---------------------------------------------------------------- обход комнат

    local function scanRoom(room)
        local crates = {}
        for _, d in ipairs(room:GetDescendants()) do
            if done[d] or d:IsDescendantOf(root) then continue end
            local n = d.Name
            if d:IsA("Model") then
                local low = n:lower()
                if n == "FesteringMeat" and CONFIG.MEAT_FESTIVE then
                    done[d] = true
                    local ok, err = pcall(festiveMeat, room, d)
                    if not ok then warn("[NewYear] Мясо: " .. tostring(err)) end
                elseif n == "OilBarrel" and CONFIG.OIL_BARRELS ~= "off" then
                    done[d] = true
                    local ok, err = pcall(festiveBarrel, room, d, CONFIG.OIL_BARRELS)
                    if not ok then warn("[NewYear] Бочка: " .. tostring(err)) end
                elseif n == "WoodenCrate" and CONFIG.CRATE_GIFTS then
                    done[d] = true
                    table.insert(crates, d)
                elseif low:find("breakerpole", 1, true) and CONFIG.BREAKER_CANDY then
                    done[d] = true
                    local ok, err = pcall(festivePickup, room, d)
                    if not ok then warn("[NewYear] Щиток: " .. tostring(err)) end
                end
            end
        end
        if #crates > 0 then
            local ok, err = pcall(festiveCrates, room, crates)
            if not ok then warn("[NewYear] Ящики: " .. tostring(err)) end
        end
        if room.Name == "100" then task.delay(3, function() pcall(scan100, room) end) end
    end

    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 30)
        if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do scanRoom(room) end
        connect(rooms.ChildAdded, function(room)
            task.delay(1, scanRoom, room)
            task.delay(4, scanRoom, room)
        end)
        -- щитки могут появиться в комнате позже (по ходу задания)
        connect(rooms.DescendantAdded, function(d)
            if d:IsA("Model") and d.Name:lower():find("breakerpole", 1, true) then
                task.delay(0.5, function()
                    for _, room in ipairs(rooms:GetChildren()) do
                        if d:IsDescendantOf(room) then scanRoom(room) end
                    end
                end)
            end
        end)
    end)

    -- счётчик в интерфейсе: проверяем раз в 2 секунды (интерфейс пересоздаётся после смерти,
    -- а выключение/включение новогоднего интерфейса в меню снимает наши изменения)
    task.spawn(function()
        while root.Parent do
            pcall(function()
                -- MainUI.MainFrame.FlashSpecify.BreakerPoles — невидимый шаблон (одноимённый ModuleScript
                -- лежит в MainUI.Initiator — его не трогаем). Подобрал щиток — игра копирует шаблон
                -- в BreakerPolesLive, показывает и убирает. Украшаем шаблон — копии уже с конфетой.
                local pg = player:FindFirstChildOfClass("PlayerGui")
                local main = pg and pg:FindFirstChild("MainUI")
                local frame = main and main:FindFirstChild("MainFrame")
                local fs = frame and frame:FindFirstChild("FlashSpecify")
                if not fs then return end
                local bp = fs:FindFirstChild("BreakerPoles")
                if bp and bp:IsA("ImageLabel") then decorateCounter(bp) end
                if not counterSeen[fs] then
                    counterSeen[fs] = true
                    connect(fs.ChildAdded, function(c)
                        -- съедать здесь нельзя: этот же счётчик игра показывает и когда открываешь щиток
                        -- на стене (не хватает конфет) — едим только когда конфета пропала рядом с тобой
                        if c.Name == "BreakerPolesLive" and c:IsA("ImageLabel") then
                            pcall(decorateCounter, c)
                        end
                    end)
                end
            end)
            task.wait(2)
        end
    end)
end))

---------------------------------------------------------------- скан текстур

-- Что за текстуры в комнатах: какие ID, на каких деталях, сколько раз.
-- По нему следующим шагом подберём, что заменить на новогоднее.
local function scanRooms()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then return end
    local tex = {}   -- [id] = { count, examples = {путь}, class, face }
    local mats = {}  -- [материал+цвет] = count
    local lights = 0
    local names = {} -- [имя модели верхнего уровня в Assets] = count
    for _, room in ipairs(rooms:GetChildren()) do
        local assets = room:FindFirstChild("Assets")
        if assets then
            for _, m in ipairs(assets:GetChildren()) do
                names[m.Name] = (names[m.Name] or 0) + 1
            end
        end
        for _, d in ipairs(room:GetDescendants()) do
            local id, kind
            if d:IsA("Texture") or d:IsA("Decal") then
                id, kind = d.Texture, d.ClassName
            elseif d:IsA("MeshPart") and d.TextureID ~= "" then
                id, kind = d.TextureID, "MeshPart"
            elseif d:IsA("SurfaceAppearance") then
                id, kind = d.ColorMap, "SurfaceAppearance"
            end
            if id and id ~= "" then
                local e = tex[id]
                if not e then
                    e = { count = 0, examples = {}, kind = kind }
                    tex[id] = e
                end
                e.count += 1
                if #e.examples < 3 then
                    local parent = d.Parent
                    table.insert(e.examples, d:GetFullName():gsub("^Workspace%.CurrentRooms%.", "")
                        .. (parent and parent:IsA("BasePart") and ("  [" .. parent.Material.Name .. " "
                        .. ("%.1fx%.1fx%.1f"):format(parent.Size.X, parent.Size.Y, parent.Size.Z) .. "]") or ""))
                end
            end
            if d:IsA("BasePart") and d.Transparency < 1 then
                local key = d.Material.Name .. " " .. d.BrickColor.Name
                mats[key] = (mats[key] or 0) + 1
            end
            if d:IsA("Light") then lights += 1 end
        end
    end

    local out = { "===== ТЕКСТУРЫ (по числу использований) =====" }
    local list = {}
    for id, e in pairs(tex) do table.insert(list, { id = id, e = e }) end
    table.sort(list, function(a, b) return a.e.count > b.e.count end)
    for k, item in ipairs(list) do
        if k > 60 then break end
        table.insert(out, ("%4d  %-18s %s"):format(item.e.count, item.e.kind, item.id))
        for _, ex in ipairs(item.e.examples) do table.insert(out, "        " .. ex) end
    end
    table.insert(out, "===== МАТЕРИАЛЫ ДЕТАЛЕЙ =====")
    local ml = {}
    for k, v in pairs(mats) do table.insert(ml, { k = k, v = v }) end
    table.sort(ml, function(a, b) return a.v > b.v end)
    for k, item in ipairs(ml) do
        if k > 40 then break end
        table.insert(out, ("%5d  %s"):format(item.v, item.k))
    end
    table.insert(out, "===== МОДЕЛИ В Assets =====")
    local nl = {}
    for k, v in pairs(names) do table.insert(nl, { k = k, v = v }) end
    table.sort(nl, function(a, b) return a.v > b.v end)
    for _, item in ipairs(nl) do table.insert(out, ("%4d  %s"):format(item.v, item.k)) end
    table.insert(out, "Источников света: " .. lights)

    local text = table.concat(out, "\n")
    pcall(function()
        if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
        if writefile then writefile("StevieBuddy/newyear_scan.txt", text) end
    end)
    if setclipboard then pcall(setclipboard, text) end
    print(("[NewYear] Скан: %d текстур, сохранено в workspace/StevieBuddy/newyear_scan.txt"):format(#list))
end

if CONFIG.SCAN then
    -- ждём, пока подгрузятся комнаты; сканируем ещё раз, когда пройдёшь подальше
    task.delay(8, function() pcall(scanRooms) end)
end

-- >>> SBUI (копия ui.lua — правь ui.lua и запускай embed_ui.py)
local SBUI = (function()
--  StevieBuddy UI — библиотека меню: тёмное окно, слева панель с логотипом, вкладками и профилем,
--  справа карточки-секции в две колонки, поиск, фон с бегущими линиями, уведомления.
--
--  Без loadstring: код библиотеки вставляется в скрипт целиком
--  (в newyear.lua копия лежит между метками «>>> SBUI» и «<<< SBUI», обновляется embed_ui.py).
--
--  local win = UI.new({ Title = "Новый год", Logo = "S", Key = "RightShift", FreeMouse = true })
--  local tab = win:Tab({ Name = "Снег", Desc = "ветер и снегопад", Icon = "❄" })
--  local sub = tab:Tab({ Name = "Метель", Desc = "вложенная вкладка" })
--  local sec = tab:Section({ Name = "снегопад", Side = "Left" })          -- Side: "Left" / "Right" / не указывать
--  local t = sec:Toggle({ Name = "Снег идёт", Default = true, Callback = function(on) end })
--  t:Settings():Slider({ ... })                                           -- кнопка «•••» с доп. настройками
--  sec:Slider({ Name, Min, Max, Step, Default, Format = "%.1f" | function(v) end, Callback, OnRelease })
--  sec:Button({ Name, Callback })        sec:Label("текст")
--  sec:Dropdown({ Name, Options = {...}, Default, Callback })
--  sec:Keybind({ Name, Default = "RightShift", Callback = function(keyName) end })
--  sec:Input({ Name, Default, Placeholder, Width, Callback = function(text, enter) end })      -- поле ввода
--  sec:ColorPicker({ Name, Default = Color3, Callback = function(color) end, OnRelease })
--  Icon: текст/эмодзи, картинка (rbxassetid://, getcustomasset) или рисованная: "@sun" "@eye" "@garland" "@star" "@gear" "@snow"
--  у каждого элемента: :Set(значение, silent), .Value
--  win:Notify({ Title, Text, Duration })   win:SetOpen(bool)   win:Toggle()   win:SetKey("F")   win:Destroy()
--  win:SetColors(фон, акцент, текст)   win:SetTheme({ Accent = ... })   win:SetSize(w, h)   win:SetScale(1.2)
--  UI.new({ Size = Vector2.new(680, 440), OnResize = function(w, h) end })  — уголок справа снизу тянет размер
--  UI.new({ OnLogoClick = function(clicksInARow) end })                    — клик по логотипу (для пасхалок)
--  UI.new({ Changelog = { Title, Version, Lines = {...}, Button, Duration } }) — окно «что нового» при запуске
--  win:ShowChangelog(cl)   UI.new({ LogoIntro = false }) — открывать без значка-логотипа
--  UI.new({ Opener = false | OpenerY = 0.55 }) — круглая кнопка слева: убрать / поставить ниже (доля высоты экрана)
--  UI.new({ OpenOnStart = true }) — сразу открыть меню при запуске (значок -> окно, потом «что нового»)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

local UI = {}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local THEME_KEYS = { "Accent", "Text", "Background", "Sidebar", "Section", "Element", "Stroke", "Hover", "Track",
    "StrokeLight", "TextIdle", "SubText", "Dim", "Decor" }
local function key3(c)
    return ("%d,%d,%d"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
-- вся палитра из трёх цветов: фон, акцент, текст (карточки и рамки — оттенки фона)
function UI.Derive(base, accent, textColor)
    local s = ((base.R + base.G + base.B) / 3 > 0.5) and -1 or 1 -- светлый фон — карточки темнее
    local function add(n)
        return Color3.fromRGB(math.clamp(base.R * 255 + n * s, 0, 255), math.clamp(base.G * 255 + n * s, 0, 255),
            math.clamp(base.B * 255 + n * s, 0, 255))
    end
    return {
        Background = base, Sidebar = add(3), Section = add(7), Element = add(13), Stroke = add(19), Hover = add(22),
        Track = add(27), StrokeLight = add(38), Accent = accent, Text = textColor,
        TextIdle = base:Lerp(textColor, 0.68), SubText = base:Lerp(textColor, 0.5), Dim = base:Lerp(textColor, 0.3),
        Decor = base:Lerp(textColor, 0.42),
    }
end
UI.Theme = UI.Derive(rgb(10, 10, 11), rgb(255, 255, 255), rgb(238, 238, 240))

-- у каждого ключа темы свой цвет: по цвету new() узнаёт, какой ключ стоит в свойстве, и запоминает —
-- так SetTheme перекрашивает всё на лету. Возвращает { ["r,g,b"] = ключ }.
local function uniq(T)
    local seen = {}
    for _, k in ipairs(THEME_KEYS) do
        local c = T[k]
        local r, g, b = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
        local step = b < 128 and 1 or -1
        local tries = 0
        while seen[("%d,%d,%d"):format(r, g, b)] and tries < 60 do
            b += step
            tries += 1
        end
        T[k] = Color3.fromRGB(r, g, b)
        seen[("%d,%d,%d"):format(r, g, b)] = k
    end
    return seen
end

function UI.ToHex(c)
    return ("#%02X%02X%02X"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function UI.FromHex(str)
    if type(str) ~= "string" then return nil end
    str = str:gsub("#", ""):gsub("%s", "")
    if #str ~= 6 or str:find("[^%x]") then return nil end
    return Color3.fromRGB(tonumber(str:sub(1, 2), 16), tonumber(str:sub(3, 4), 16), tonumber(str:sub(5, 6), 16))
end

local FAMILY = "rbxasset://fonts/families/GothamSSm.json"
local F_REG = Font.new(FAMILY, Enum.FontWeight.Medium)
local F_BOLD = Font.new(FAMILY, Enum.FontWeight.Bold)
local F_LOGO = Font.new(FAMILY, Enum.FontWeight.Heavy, Enum.FontStyle.Italic)

local AUTO_Y = Enum.AutomaticSize.Y
local LEFT = Enum.TextXAlignment.Left
local RIGHT = Enum.TextXAlignment.Right

local REG -- тема окна, которое сейчас строится: { list = {{объект, свойство, ключ}}, byColor = {...} }
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        o[k] = v
        if REG and typeof(v) == "Color3" then
            local key = REG.byColor[key3(v)]
            if key then table.insert(REG.list, { o, k, key }) end
        end
    end
    if parent then o.Parent = parent end
    return o
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, o) end
local function stroke(o, color, th)
    return new("UIStroke", { Color = color, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end
local function pad(o, t, r, b, l)
    return new("UIPadding", { PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r),
        PaddingBottom = UDim.new(0, b), PaddingLeft = UDim.new(0, l) }, o)
end
local function list(o, gap, dir)
    return new("UIListLayout", { Padding = UDim.new(0, gap or 0), SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical }, o)
end
local function tween(o, t, props, style)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function text(props, parent)
    local base = { BackgroundTransparency = 1, FontFace = F_REG, TextSize = 12, TextXAlignment = LEFT,
        TextTruncate = Enum.TextTruncate.AtEnd }
    for k, v in pairs(props) do base[k] = v end
    return new("TextLabel", base, parent)
end
local function isImage(s)
    return type(s) == "string" and (s:find("^rbxassetid://") or s:find("^rbxthumb://") or s:find("^rbxasset://")
        or s:find("^https?://")) ~= nil
end
local function isClick(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- нижний регистр с русскими буквами (string.lower их не трогает) — для поиска
local function lower(s)
    local ok, res = pcall(function()
        local out = {}
        for _, c in utf8.codes(s) do
            if c >= 0x410 and c <= 0x42F then c += 0x20
            elseif c == 0x401 then c = 0x451
            elseif c >= 65 and c <= 90 then c += 32 end
            out[#out + 1] = utf8.char(c)
        end
        return table.concat(out)
    end)
    return ok and res or string.lower(s)
end

-- отрезок из рамки (рисуем им галочку, стрелки, лупу, крестик и линии на фоне)
local function seg(parent, x1, y1, x2, y2, th, color)
    local dx, dy = x2 - x1, y2 - y1
    local l = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
        Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) + th * 0.6, th),
        Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color, BorderSizePixel = 0,
    }, parent)
    corner(l, math.ceil(th))
    return l
end
-- стрелка «v» 12×12; Rotation = 180 — «^»
local function chevron(parent, color)
    local h = new("Frame", { Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1 }, parent)
    seg(h, 2.5, 4.5, 6, 8, 1.6, color)
    seg(h, 6, 8, 9.5, 4.5, 1.6, color)
    return h
end
local function paint(holder, color)
    for _, c in ipairs(holder:GetChildren()) do
        if c:IsA("Frame") then c.BackgroundColor3 = color end
    end
end

local function circle(parent, x, y, d, color, filled, th)
    local c = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(d, d), BackgroundColor3 = color, BackgroundTransparency = filled and 0 or 1,
        BorderSizePixel = 0 }, parent)
    corner(c, math.ceil(d / 2))
    if not filled then stroke(c, color, th or 1.5) end
    return c
end
-- иконки, нарисованные рамками (Icon = "@sun" и т.д.) — не зависят от шрифта
local ICONS = {
    sun = function(h, c)
        circle(h, 9, 9, 6, c, true)
        for k = 0, 7 do
            local a = k * math.pi / 4
            seg(h, 9 + math.cos(a) * 5.6, 9 + math.sin(a) * 5.6, 9 + math.cos(a) * 8.2, 9 + math.sin(a) * 8.2, 1.5, c)
        end
    end,
    eye = function(h, c)
        local e = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(9, 9),
            Size = UDim2.fromOffset(16, 10), BackgroundTransparency = 1, BackgroundColor3 = c }, h)
        corner(e, 5)
        stroke(e, c, 1.5)
        circle(h, 9, 9, 4, c, true)
    end,
    garland = function(h, c)
        local pts = { { 1, 4 }, { 5, 8 }, { 9, 9.5 }, { 13, 8 }, { 17, 4 } }
        for k = 1, #pts - 1 do seg(h, pts[k][1], pts[k][2], pts[k + 1][1], pts[k + 1][2], 1.4, c) end
        circle(h, 5, 12, 3.4, c, true)
        circle(h, 9, 13.6, 3.4, c, true)
        circle(h, 13, 12, 3.4, c, true)
    end,
    star = function(h, c)
        for k = 0, 4 do
            local a1, a2 = -math.pi / 2 + k * 2 * math.pi / 5, -math.pi / 2 + (k + 2) * 2 * math.pi / 5
            seg(h, 9 + math.cos(a1) * 8, 9.5 + math.sin(a1) * 8, 9 + math.cos(a2) * 8, 9.5 + math.sin(a2) * 8, 1.4, c)
        end
    end,
    gear = function(h, c)
        circle(h, 9, 9, 9, c, false, 2)
        for k = 0, 7 do
            local a = k * math.pi / 4
            seg(h, 9 + math.cos(a) * 5.5, 9 + math.sin(a) * 5.5, 9 + math.cos(a) * 8.3, 9 + math.sin(a) * 8.3, 2.4, c)
        end
    end,
    snow = function(h, c)
        for k = 0, 2 do
            local a = k * math.pi / 3 + math.pi / 2
            seg(h, 9 - math.cos(a) * 8, 9 - math.sin(a) * 8, 9 + math.cos(a) * 8, 9 + math.sin(a) * 8, 1.4, c)
        end
        circle(h, 9, 9, 3, c, true)
    end,
}
local function drawIcon(parent, name, color)
    local h = new("Frame", { Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1 }, parent)
    if ICONS[name] then ICONS[name](h, color) end
    return h
end
local function tint(holder, color)
    for _, d in ipairs(holder:GetDescendants()) do
        if d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 = color
        elseif d:IsA("UIStroke") then d.Color = color end
    end
end

local function logoInto(parent, logo, size, color)
    if isImage(logo) then
        return new("ImageLabel", { BackgroundTransparency = 1, Image = logo, ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromOffset(size * 1.05, size * 1.05), ImageColor3 = color }, parent)
    end
    return text({ Text = logo or "S", FontFace = F_LOGO, TextSize = size, TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(size * 1.4, size),
        TextTruncate = Enum.TextTruncate.None }, parent)
end

function UI.new(opts)
    opts = opts or {}
    local T = {}
    for k, v in pairs(UI.Theme) do T[k] = v end
    local reg = { list = {}, byColor = uniq(T) }
    REG = reg
    local refreshers = {} -- перерисовать состояние элементов после смены темы
    local function bindReg(t) -- элементы, созданные позже, тоже попадают в тему этого окна
        for k, f in pairs(t) do
            if type(f) == "function" then t[k] = function(...) REG = reg return f(...) end end
        end
        return t
    end
    local W = math.clamp(opts.Size and opts.Size.X or 680, 540, 1100)
    local H = math.clamp(opts.Size and opts.Size.Y or 440, 340, 760)
    local SB = 176 -- ширина боковой панели
    local userScale = 1

    local Window = { Tabs = {}, Open = false, Theme = T }
    local conns = {}
    local function conn(sig, fn)
        local c = sig:Connect(fn)
        table.insert(conns, c)
        return c
    end

    ------------------------------------------------------------ окно
    local gui = new("ScreenGui", { Name = opts.Name or "SBUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = opts.DisplayOrder or 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    if opts.Parent then
        gui.Parent = opts.Parent
    else
        pcall(function() gui.Parent = gethui and gethui() or game:GetService("CoreGui") end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end
    Window.Gui = gui

    local win = new("CanvasGroup", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.Background, Visible = false }, gui)
    corner(win, 10)
    stroke(win, T.Stroke)
    local winScale = new("UIScale", {}, win)
    local fit = 1
    local function refit()
        local vs = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        fit = math.clamp(math.min(vs.X / (W + 40), vs.Y / (H + 40), userScale), 0.4, 2)
        if Window.Open then winScale.Scale = fit end
    end
    refit()
    if workspace.CurrentCamera then
        conn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), refit)
    end

    -- общие перетаскивания (окно, ползунки, кнопка открытия)
    local drag
    conn(UIS.InputChanged, function(i)
        if drag and isMove(i) then drag.move(i.Position) end
    end)
    conn(UIS.InputEnded, function(i)
        if drag and isClick(i) then
            local d = drag
            drag = nil
            if d.stop then d.stop() end
        end
    end)
    local function dragHandle(handle)
        conn(handle.InputBegan, function(i)
            if not isClick(i) then return end
            local sp, sm = win.Position, i.Position
            drag = { move = function(p)
                local d = p - sm
                win.Position = sp + UDim2.fromOffset(d.X, d.Y)
            end }
        end)
    end

    ------------------------------------------------------------ боковая панель
    local side = new("Frame", { Name = "Sidebar", Size = UDim2.new(0, SB, 1, 0), BackgroundColor3 = T.Sidebar }, win)
    corner(side, 10)
    new("Frame", { Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 10, 1, 0), BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0 }, side)
    new("Frame", { Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = T.Stroke,
        BorderSizePixel = 0 }, side)

    local logoArea = new("Frame", { Size = UDim2.new(1, 0, 0, 92), BackgroundTransparency = 1, Active = true }, side)
    dragHandle(logoArea)
    local logo = logoInto(logoArea, opts.Logo, 54, T.Accent)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.52)
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), rgb(150, 150, 158)) }, logo)
    -- клик по логотипу: он подпрыгивает; opts.OnLogoClick(сколько раз подряд кликнули) — для пасхалок
    do
        local clicks, lastClick, baseSize = 0, 0, logo.Size
        logoArea.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            local now = os.clock()
            clicks = (now - lastClick < 0.6) and clicks + 1 or 1
            lastClick = now
            logo.Size = UDim2.new(baseSize.X.Scale * 0.86, baseSize.X.Offset * 0.86, baseSize.Y.Scale * 0.86,
                baseSize.Y.Offset * 0.86)
            TweenService:Create(logo, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = baseSize }):Play()
            if opts.OnLogoClick then task.spawn(opts.OnLogoClick, clicks) end
        end)
    end

    local showProfile = opts.Profile ~= false
    local tabList = new("ScrollingFrame", { Position = UDim2.fromOffset(0, 96),
        Size = UDim2.new(1, 0, 1, showProfile and -166 or -104), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = AUTO_Y,
        ScrollingDirection = Enum.ScrollingDirection.Y }, side)
    list(tabList, 2)
    pad(tabList, 2, 10, 2, 12)

    if showProfile then
        local card = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -10),
            Size = UDim2.new(1, -20, 0, 52), BackgroundColor3 = T.Element }, side)
        corner(card, 8)
        stroke(card, T.Stroke)
        local av = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0),
            Size = UDim2.fromOffset(34, 34), BackgroundColor3 = T.Hover,
            Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(LocalPlayer.UserId) }, card)
        corner(av, 17)
        text({ Position = UDim2.fromOffset(52, 10), Size = UDim2.new(1, -60, 0, 16), FontFace = F_BOLD,
            TextColor3 = T.Text, Text = LocalPlayer.DisplayName }, card)
        text({ Position = UDim2.fromOffset(52, 27), Size = UDim2.new(1, -60, 0, 14), TextSize = 11,
            TextColor3 = T.SubText, Text = "@" .. LocalPlayer.Name }, card)
    end

    ------------------------------------------------------------ правая часть
    local content = new("Frame", { Name = "Content", Position = UDim2.fromOffset(SB + 1, 0),
        Size = UDim2.new(1, -SB - 1, 1, 0), BackgroundTransparency = 1 }, win)
    local decor = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true,
        ZIndex = 0 }, content)
    local mark = logoInto(decor, opts.Logo, 150, T.Accent)
    mark.AnchorPoint = Vector2.new(1, 1)
    mark.Position = UDim2.new(1, 10, 1, 24)
    mark.Rotation = -8
    if mark:IsA("TextLabel") then mark.TextTransparency = 0.965 else mark.ImageTransparency = 0.965 end

    local top = new("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true }, content)
    dragHandle(top)
    local topTitle = text({ Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -150, 0, 16), FontFace = F_BOLD,
        TextSize = 14, TextColor3 = T.Text, Text = "" }, top)
    local topDesc = text({ Position = UDim2.fromOffset(18, 27), Size = UDim2.new(1, -150, 0, 13), TextSize = 11,
        TextColor3 = T.SubText, Text = "" }, top)

    -- крестик и лупа (нарисованы рамками, чтобы не зависеть от шрифтов)
    local closeBtn = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.fromOffset(28, 28), BackgroundColor3 = T.Hover, BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false }, top)
    corner(closeBtn, 6)
    seg(closeBtn, 9.5, 9.5, 18.5, 18.5, 1.6, T.SubText)
    seg(closeBtn, 18.5, 9.5, 9.5, 18.5, 1.6, T.SubText)
    closeBtn.Visible = false -- закрытие — красной кнопкой справа сверху (кнопки как в macOS)
    local lights = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 17),
        Size = UDim2.fromOffset(53, 14), BackgroundTransparency = 1, ZIndex = 30 }, top)
    local lightBtns = {}
    for i, e in ipairs({ { "close", rgb(255, 95, 87), "×" }, { "min", rgb(254, 188, 46), "–" },
        { "max", rgb(40, 200, 64), "+" } }) do
        local b = new("TextButton", { Position = UDim2.fromOffset((i - 1) * 20, 0), Size = UDim2.fromOffset(13, 13),
            BackgroundColor3 = e[2], Text = "", AutoButtonColor = false, ZIndex = 31 }, lights)
        corner(b, 7)
        local glyph = text({ Size = UDim2.fromScale(1, 1), Text = e[3], TextSize = 12, FontFace = F_BOLD,
            TextColor3 = rgb(80, 30, 20), TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 32 }, b)
        local bsc = new("UIScale", {}, b)
        lightBtns[e[1]] = { b = b, glyph = glyph, s = bsc }
    end
    conn(lights.MouseEnter, function()
        for _, l in pairs(lightBtns) do tween(l.glyph, 0.12, { TextTransparency = 0.1 }) end
    end)
    conn(lights.MouseLeave, function()
        for _, l in pairs(lightBtns) do tween(l.glyph, 0.12, { TextTransparency = 1 }) end
    end)
    for _, l in pairs(lightBtns) do
        conn(l.b.MouseButton1Down, function() tween(l.s, 0.08, { Scale = 0.85 }) end)
        conn(l.b.MouseButton1Up, function() tween(l.s, 0.25, { Scale = 1 }, Enum.EasingStyle.Back) end)
        conn(l.b.MouseLeave, function() tween(l.s, 0.2, { Scale = 1 }) end)
    end
    local searchBtn = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -78, 0, 10),
        Size = UDim2.fromOffset(28, 28), BackgroundColor3 = T.Hover, BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false }, top)
    corner(searchBtn, 6)
    local lens = new("Frame", { Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1 }, searchBtn)
    corner(lens, 6)
    local lensStroke = stroke(lens, T.SubText, 1.6)
    seg(searchBtn, 16.5, 16.5, 21, 21, 1.8, T.SubText)
    for _, b in ipairs({ closeBtn, searchBtn }) do
        conn(b.MouseEnter, function()
            tween(b, 0.15, { BackgroundTransparency = 0 })
            paint(b, T.Text)
            if b == searchBtn then lensStroke.Color = T.Text end
        end)
        conn(b.MouseLeave, function()
            tween(b, 0.15, { BackgroundTransparency = 1 })
            paint(b, T.SubText)
            if b == searchBtn then lensStroke.Color = T.SubText end
        end)
    end

    local searchWrap = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -110, 0, 10),
        Size = UDim2.fromOffset(0, 28), BackgroundColor3 = T.Element, ClipsDescendants = true }, top)
    corner(searchWrap, 6)
    local searchStroke = stroke(searchWrap, T.Stroke)
    searchStroke.Transparency = 1
    local searchBox = new("TextBox", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1, FontFace = F_REG, TextSize = 12, TextColor3 = T.Text,
        PlaceholderText = "поиск...", PlaceholderColor3 = T.Dim, Text = "", TextXAlignment = LEFT,
        ClearTextOnFocus = false }, searchWrap)

    local pages = new("Frame", { Position = UDim2.fromOffset(0, 48), Size = UDim2.new(1, 0, 1, -48),
        BackgroundTransparency = 1, ClipsDescendants = true }, content)

    ------------------------------------------------------------ всплывающие окошки («•••», выпадающие списки)
    local blocker = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Visible = false, ZIndex = 40 }, win)
    local stack = {}
    local function closeTop()
        local p = table.remove(stack)
        if p then
            -- сворачивается обратно туда, откуда вылез
            local ps = p:FindFirstChildOfClass("UIScale")
            if ps then
                tween(ps, 0.12, { Scale = 0.2 }, Enum.EasingStyle.Quad)
                task.delay(0.12, function()
                    if not table.find(stack, p) then p.Visible = false end
                end)
            else
                p.Visible = false
            end
        end
        if #stack > 0 then blocker.ZIndex = 39 + #stack * 2 else blocker.Visible = false end
    end
    local function closeAll() while #stack > 0 do closeTop() end end
    conn(blocker.MouseButton1Click, closeTop)

    local function showPopup(pop, anchor, mode)
        local s = winScale.Scale
        local ap = (anchor.AbsolutePosition - win.AbsolutePosition) / s
        local as = anchor.AbsoluteSize / s
        local w = pop.Size.X.Offset
        local x, y
        if mode == "below" then
            x, y = ap.X + as.X - w, ap.Y + as.Y + 4
        else
            x, y = ap.X + as.X + 10, ap.Y - 8
            if x + w > W - 6 then x = ap.X - w - 10 end
        end
        x = math.clamp(x, 6, W - w - 6)
        table.insert(stack, pop)
        pop.ZIndex = 40 + #stack * 2
        blocker.ZIndex = pop.ZIndex - 1
        blocker.Visible = true
        -- вырастает из кнопки («•••» / выпадающий список): угол окошка — у кнопки
        local fromRight = x + w / 2 < ap.X + as.X / 2
        pop.AnchorPoint = Vector2.new(fromRight and 1 or 0, 0)
        local px = fromRight and x + w or x
        pop.Position = UDim2.fromOffset(px, y)
        pop.Visible = true
        local ps = pop:FindFirstChildOfClass("UIScale")
        ps.Scale = 0.2
        tween(ps, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
        task.spawn(function() -- после раскладки: не вылезать за низ окна
            RunService.RenderStepped:Wait()
            local h = pop.AbsoluteSize.Y / math.max(ps.Scale, 0.2) / s
            if y + h > H - 6 then pop.Position = UDim2.fromOffset(px, math.max(6, H - h - 6)) end
        end)
    end

    local container -- объявлена ниже

    local function makePopup(title, width)
        local pop = new("Frame", { Size = UDim2.fromOffset(width or 210, 0), AutomaticSize = AUTO_Y,
            BackgroundColor3 = T.Section, Visible = false, ZIndex = 42, Active = true }, win)
        corner(pop, 8)
        stroke(pop, T.StrokeLight)
        new("UIScale", {}, pop)
        local y = 0
        if title then
            text({ Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 0, 30), FontFace = F_BOLD,
                TextColor3 = T.Text, Text = title }, pop)
            new("Frame", { Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
                BorderSizePixel = 0 }, pop)
            y = 31
        end
        local body = new("Frame", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = AUTO_Y, BackgroundTransparency = 1 }, pop)
        list(body, 2)
        pad(body, 6, 10, 8, 10)
        return pop, body
    end

    ------------------------------------------------------------ элементы
    local binding = false -- ждём клавишу для Keybind (кнопка меню в это время не срабатывает)

    local function fmtValue(o, v)
        if type(o.Format) == "function" then return o.Format(v) end
        if type(o.Format) == "string" then
            if o.Format:find("%%d") then v = math.floor(v + 0.5) end
            return o.Format:format(v)
        end
        local s
        if (o.Step or 1) >= 1 then
            s = tostring(math.floor(v + 0.5))
        else
            s = (("%.2f"):format(v):gsub("0+$", ""):gsub("%.$", ""))
        end
        return s .. (o.Suffix or "")
    end

    container = function(body, items)
        local api = {}
        local order = 0
        local function nextOrder()
            order += 1
            return order
        end
        local function register(row, name)
            if items then table.insert(items, { row = row, lname = lower(name or "") }) end
        end

        function api:Label(str)
            local l = text({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y, TextWrapped = true,
                TextTruncate = Enum.TextTruncate.None, TextSize = 11, TextColor3 = T.SubText, Text = str,
                LayoutOrder = nextOrder() }, body)
            pad(l, 3, 0, 3, 0)
            register(l, str)
            local el = { Instance = l }
            function el:Set(s) l.Text = s end
            return el
        end

        function api:Toggle(o)
            local el = { Value = o.Default == true }
            local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "",
                AutoButtonColor = false, LayoutOrder = nextOrder() }, body)
            local box = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(16, 16), BackgroundColor3 = T.Element }, row)
            corner(box, 4)
            local boxStroke = stroke(box, T.StrokeLight)
            local check = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, box)
            local checkScale = new("UIScale", {}, check)
            local a = seg(check, 4, 8.3, 6.8, 11.1, 1.8, T.Accent)
            local b = seg(check, 6.8, 11.1, 12.2, 5.2, 1.8, T.Accent)
            local label = text({ Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0),
                TextColor3 = T.SubText, Text = o.Name }, row)
            local dots = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 2, 0.5, 0),
                Size = UDim2.fromOffset(26, 18), BackgroundColor3 = T.Hover, BackgroundTransparency = 1, Text = "",
                AutoButtonColor = false, Visible = false }, row)
            corner(dots, 4)
            for k = 0, 2 do
                local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, (k - 1) * 6, 0.5, 0),
                    Size = UDim2.fromOffset(3, 3), BackgroundColor3 = T.Dim, BorderSizePixel = 0 }, dots)
                corner(d, 2)
            end
            conn(dots.MouseEnter, function() paint(dots, T.Text) end)
            conn(dots.MouseLeave, function() paint(dots, T.Dim) end)

            local hovered = false
            local function refresh(instant)
                local t = instant and 0 or 0.16
                local on = el.Value
                tween(boxStroke, t, { Color = on and T.Accent or T.StrokeLight, Transparency = on and 0.15 or 0 })
                tween(box, t, { BackgroundColor3 = on and T.Hover or T.Element })
                tween(a, t, { BackgroundTransparency = on and 0 or 1 })
                tween(b, t, { BackgroundTransparency = on and 0 or 1 })
                tween(label, t, { TextColor3 = on and T.Text or (hovered and T.TextIdle or T.SubText) })
                label.FontFace = on and F_BOLD or F_REG
                if on and not instant then
                    checkScale.Scale = 0.5
                    tween(checkScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
                end
            end
            function el:Set(v, silent)
                el.Value = v == true
                refresh()
                if not silent and o.Callback then task.spawn(o.Callback, el.Value) end
            end
            conn(row.MouseButton1Click, function() el:Set(not el.Value) end)
            conn(row.MouseEnter, function()
                hovered = true
                if not el.Value then tween(label, 0.12, { TextColor3 = T.TextIdle }) end
            end)
            conn(row.MouseLeave, function()
                hovered = false
                if not el.Value then tween(label, 0.12, { TextColor3 = T.SubText }) end
            end)

            local settingsApi
            function el:Settings(title)
                if settingsApi then return settingsApi end
                dots.Visible = true
                label.Size = UDim2.new(1, -54, 1, 0)
                local pop, pbody = makePopup(title or o.Name, o.SettingsWidth or 220)
                settingsApi = container(pbody, nil)
                conn(dots.MouseButton1Click, function() showPopup(pop, dots) end)
                return settingsApi
            end

            refresh(true)
            table.insert(refreshers, function() refresh(true) end)
            register(row, o.Name)
            el.Instance = row
            return el
        end

        function api:Slider(o)
            local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
            local el = { Value = math.clamp(o.Default or min, min, max) }
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1,
                LayoutOrder = nextOrder() }, body)
            local label = text({ Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, -70, 0, 16),
                TextColor3 = T.SubText, Text = o.Name }, row)
            local val = text({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 3),
                Size = UDim2.fromOffset(70, 16), TextColor3 = T.Text, TextXAlignment = RIGHT, Text = "" }, row)
            local hit = new("TextButton", { Position = UDim2.fromOffset(0, 19), Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, row)
            local track = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = T.Track, BorderSizePixel = 0 }, hit)
            corner(track, 2)
            local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, BackgroundTransparency = 0.12,
                BorderSizePixel = 0 }, track)
            corner(fill, 2)
            local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(10, 10), BackgroundColor3 = T.Accent }, track)
            corner(knob, 6)

            local function refresh(instant)
                local a = (max > min) and math.clamp((el.Value - min) / (max - min), 0, 1) or 0
                local t = instant and 0 or 0.08
                tween(fill, t, { Size = UDim2.fromScale(a, 1) })
                tween(knob, t, { Position = UDim2.fromScale(a, 0.5) })
                val.Text = fmtValue(o, el.Value)
            end
            local function snap(v)
                v = min + math.floor((v - min) / step + 0.5) * step
                v = math.clamp(v, min, max)
                return tonumber(("%.5f"):format(v))
            end
            function el:Set(v, silent)
                v = snap(v)
                if v == el.Value then refresh(); return end
                el.Value = v
                refresh()
                if not silent and o.Callback then task.spawn(o.Callback, v) end
            end
            local function setX(x)
                local abs, size = track.AbsolutePosition.X, math.max(track.AbsoluteSize.X, 1)
                el:Set(min + (max - min) * math.clamp((x - abs) / size, 0, 1))
            end
            conn(hit.InputBegan, function(i)
                if not isClick(i) then return end
                tween(knob, 0.12, { Size = UDim2.fromOffset(13, 13) })
                tween(label, 0.12, { TextColor3 = T.Text })
                setX(i.Position.X)
                drag = {
                    move = function(p) setX(p.X) end,
                    stop = function()
                        tween(knob, 0.12, { Size = UDim2.fromOffset(10, 10) })
                        tween(label, 0.12, { TextColor3 = T.SubText })
                        if o.OnRelease then task.spawn(o.OnRelease, el.Value) end
                    end,
                }
            end)
            refresh(true)
            table.insert(refreshers, function() refresh(true) end)
            register(row, o.Name)
            el.Instance = row
            return el
        end

        function api:Button(o)
            local el = {}
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
                LayoutOrder = nextOrder() }, body)
            local btn = new("TextButton", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = T.Element, AutoButtonColor = false,
                FontFace = F_REG, TextSize = 12, TextColor3 = T.TextIdle, Text = o.Name }, row)
            corner(btn, 6)
            local st = stroke(btn, T.Stroke)
            conn(btn.MouseEnter, function()
                tween(btn, 0.15, { BackgroundColor3 = T.Hover, TextColor3 = T.Text })
            end)
            conn(btn.MouseLeave, function()
                tween(btn, 0.15, { BackgroundColor3 = T.Element, TextColor3 = T.TextIdle })
            end)
            local bs = new("UIScale", {}, btn)
            conn(btn.MouseButton1Click, function()
                st.Color = T.Accent
                tween(st, 0.4, { Color = T.Stroke })
                bs.Scale = 0.93
                tween(bs, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
                if o.Callback then task.spawn(o.Callback) end
            end)
            function el:SetText(s) btn.Text = s end
            register(row, o.Name)
            el.Instance = row
            return el
        end

        -- строка «название слева, коробочка справа» (для списка и бинда)
        local function boxRow(name, boxWidth)
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
                LayoutOrder = nextOrder() }, body)
            local label = text({ Size = UDim2.new(1, -(boxWidth + 8), 1, 0), TextColor3 = T.SubText, Text = name }, row)
            local box = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(boxWidth, 22), BackgroundColor3 = T.Element, AutoButtonColor = false,
                Text = "" }, row)
            corner(box, 5)
            local st = stroke(box, T.Stroke)
            conn(box.MouseEnter, function()
                tween(box, 0.15, { BackgroundColor3 = T.Hover })
                tween(label, 0.15, { TextColor3 = T.TextIdle })
            end)
            conn(box.MouseLeave, function()
                tween(box, 0.15, { BackgroundColor3 = T.Element })
                tween(label, 0.15, { TextColor3 = T.SubText })
            end)
            return row, box, st
        end

        function api:Dropdown(o)
            local options = o.Options or {}
            local el = { Value = o.Default or options[1] }
            local row, box = boxRow(o.Name, o.Width or 104)
            local valText = text({ Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0),
                TextColor3 = T.Text, Text = tostring(el.Value or "—") }, box)
            local chev = chevron(box, T.SubText)
            chev.AnchorPoint = Vector2.new(1, 0.5)
            chev.Position = UDim2.new(1, -6, 0.5, 0)

            local pop, pbody = makePopup(nil, o.ListWidth or 150)
            local optButtons = {}
            local function refresh()
                valText.Text = tostring(el.Value or "—")
                for opt, b in pairs(optButtons) do
                    b.TextColor3 = (opt == el.Value) and T.Text or T.SubText
                    b.FontFace = (opt == el.Value) and F_BOLD or F_REG
                end
            end
            function el:Set(v, silent)
                el.Value = v
                refresh()
                if not silent and o.Callback then task.spawn(o.Callback, v) end
            end
            function el:SetOptions(newOptions)
                for _, b in pairs(optButtons) do b:Destroy() end
                optButtons = {}
                options = newOptions
                for k, opt in ipairs(options) do
                    local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.Hover,
                        BackgroundTransparency = 1, AutoButtonColor = false, FontFace = F_REG, TextSize = 12,
                        TextColor3 = T.SubText, Text = tostring(opt), TextXAlignment = LEFT, LayoutOrder = k }, pbody)
                    corner(b, 5)
                    pad(b, 0, 8, 0, 8)
                    conn(b.MouseEnter, function() tween(b, 0.1, { BackgroundTransparency = 0 }) end)
                    conn(b.MouseLeave, function() tween(b, 0.1, { BackgroundTransparency = 1 }) end)
                    conn(b.MouseButton1Click, function()
                        el:Set(opt)
                        closeTop()
                    end)
                    optButtons[opt] = b
                end
                refresh()
            end
            el:SetOptions(options)
            table.insert(refreshers, refresh)
            conn(box.MouseButton1Click, function()
                chev.Rotation = 180
                showPopup(pop, box, "below")
            end)
            conn(pop:GetPropertyChangedSignal("Visible"), function()
                if not pop.Visible then chev.Rotation = 0 end
            end)
            register(row, o.Name)
            el.Instance = row
            return el
        end

        -- поле ввода: sec:Input({ Name, Default, Placeholder, Width, Callback = function(text, enter) end })
        function api:Input(o)
            local el = { Value = tostring(o.Default or "") }
            local row, box, st = boxRow(o.Name, o.Width or 150)
            local tb = new("TextBox", { Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -14, 1, 0),
                BackgroundTransparency = 1, ClearTextOnFocus = false, FontFace = F_REG, TextSize = 12,
                TextColor3 = T.Text, PlaceholderColor3 = T.Dim, PlaceholderText = o.Placeholder or "",
                Text = el.Value, TextXAlignment = LEFT, TextTruncate = Enum.TextTruncate.AtEnd }, box)
            conn(tb.Focused, function() st.Color = T.Accent end)
            conn(tb.FocusLost, function(enter)
                st.Color = T.Stroke
                el.Value = tb.Text
                if o.Callback then task.spawn(o.Callback, tb.Text, enter) end
            end)
            function el:Set(v, silent)
                tb.Text = tostring(v or "")
                el.Value = tb.Text
                if not silent and o.Callback then task.spawn(o.Callback, el.Value) end
            end
            register(row, o.Name)
            el.Instance = row
            return el
        end

        function api:Keybind(o)
            local el = { Value = o.Default or "None" }
            local row, box, st = boxRow(o.Name, o.Width or 92)
            local keyText = text({ Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
                TextColor3 = T.Text, Text = el.Value }, box)
            local listening = false
            function el:Set(v, silent)
                el.Value = v
                keyText.Text = v
                if not silent and o.Callback then task.spawn(o.Callback, v) end
            end
            conn(box.MouseButton1Click, function()
                if listening then return end
                listening, binding = true, true
                keyText.Text = "..."
                st.Color = T.Accent
            end)
            conn(UIS.InputBegan, function(i)
                if not listening or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                listening = false
                st.Color = T.Stroke
                task.delay(0.15, function() binding = false end)
                if i.KeyCode == Enum.KeyCode.Escape then
                    keyText.Text = el.Value
                else
                    el:Set(i.KeyCode.Name)
                end
            end)
            register(row, o.Name)
            el.Instance = row
            return el
        end

        function api:ColorPicker(o)
            local el = { Value = o.Default or Color3.new(1, 1, 1) }
            local row, box = boxRow(o.Name, 46)
            local sw = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -8, 1, -8), BorderSizePixel = 0 }, box)
            corner(sw, 3)
            local pop, pbody = makePopup(o.Name, 214)
            -- цвета задаём после new(): это не цвета темы, их не надо перекрашивать
            local sv = new("TextButton", { Size = UDim2.new(1, 0, 0, 112), Text = "", AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = 1 }, pbody)
            corner(sv, 5)
            local white = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, sv)
            corner(white, 5)
            new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)
            local black = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, sv)
            corner(black, 5)
            new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, black)
            local svCur = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10),
                BackgroundTransparency = 1 }, sv)
            corner(svCur, 5)
            local svCurStroke = stroke(svCur, Color3.new(0.5, 0.5, 0.5), 2)
            local hueWrap = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 2 }, pbody)
            local hue = new("TextButton", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 10), Text = "", AutoButtonColor = false, BorderSizePixel = 0 }, hueWrap)
            corner(hue, 5)
            local seq = {}
            for k = 0, 6 do seq[#seq + 1] = ColorSequenceKeypoint.new(k / 6, Color3.fromHSV(math.min(k / 6, 0.999), 1, 1)) end
            new("UIGradient", { Color = ColorSequence.new(seq) }, hue)
            local hueCur = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(4, 16),
                BorderSizePixel = 0 }, hue)
            corner(hueCur, 2)
            local hexBox = new("TextBox", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = T.Element,
                FontFace = F_REG, TextSize = 12, TextColor3 = T.Text, Text = "", ClearTextOnFocus = false,
                LayoutOrder = 3 }, pbody)
            corner(hexBox, 5)
            stroke(hexBox, T.Stroke)
            for _, f in ipairs({ white, sv, hue, hueCur }) do f.BackgroundColor3 = Color3.new(1, 1, 1) end
            black.BackgroundColor3 = Color3.new(0, 0, 0)
            svCurStroke.Color = Color3.new(1, 1, 1)

            local h, s, v = el.Value:ToHSV()
            local function show()
                sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                svCur.Position = UDim2.fromScale(s, 1 - v)
                hueCur.Position = UDim2.fromScale(h, 0.5)
                sw.BackgroundColor3 = el.Value
                hexBox.Text = UI.ToHex(el.Value)
            end
            local function commit()
                el.Value = Color3.fromHSV(h, s, v)
                show()
                if o.Callback then task.spawn(o.Callback, el.Value) end
            end
            function el:Set(c, silent)
                el.Value = c
                h, s, v = c:ToHSV()
                show()
                if not silent and o.Callback then task.spawn(o.Callback, c) end
            end
            local function release()
                if o.OnRelease then task.spawn(o.OnRelease, el.Value) end
            end
            -- InputObject.Position по Y — без верхней полосы Roblox, а окно её не учитывает (IgnoreGuiInset)
            local function screenY(p) return p.Y + GuiService:GetGuiInset().Y end
            local function svAt(p)
                local ap, as = sv.AbsolutePosition, sv.AbsoluteSize
                s = math.clamp((p.X - ap.X) / math.max(as.X, 1), 0, 1)
                v = 1 - math.clamp((screenY(p) - ap.Y) / math.max(as.Y, 1), 0, 1)
                commit()
            end
            local function hueAt(p)
                local ap, as = hue.AbsolutePosition, hue.AbsoluteSize
                h = math.clamp((p.X - ap.X) / math.max(as.X, 1), 0, 0.999)
                commit()
            end
            conn(sv.InputBegan, function(i)
                if not isClick(i) then return end
                svAt(i.Position)
                drag = { move = svAt, stop = release }
            end)
            conn(hue.InputBegan, function(i)
                if not isClick(i) then return end
                hueAt(i.Position)
                drag = { move = hueAt, stop = release }
            end)
            conn(hexBox.FocusLost, function()
                local c = UI.FromHex(hexBox.Text)
                if c then
                    el:Set(c)
                    release()
                else
                    show()
                end
            end)
            conn(box.MouseButton1Click, function() showPopup(pop, box) end)
            show()
            register(row, o.Name)
            el.Instance = row
            return el
        end

        return bindReg(api)
    end

    ------------------------------------------------------------ вкладки и секции
    local current
    local searchQuery = ""

    local function applySearch()
        if not current then return end
        local q = searchQuery
        for _, sec in ipairs(current.sections) do
            local secMatch = q ~= "" and sec.lname:find(q, 1, true) ~= nil
            local any = false
            for _, it in ipairs(sec.items) do
                local ok = q == "" or secMatch or it.lname:find(q, 1, true) ~= nil
                it.row.Visible = ok
                any = any or ok
            end
            sec.frame.Visible = q == "" or secMatch or any
            if q ~= "" and any then sec.setOpen(true, true) end
        end
    end

    local function paintTab(tab, instant)
        local sel = tab == current
        local t = instant and 0 or 0.18
        tween(tab.btn, t, { BackgroundTransparency = sel and 0 or 1 })
        tween(tab.ind, t, { BackgroundTransparency = sel and 0 or 1,
            Size = UDim2.fromOffset(3, sel and 16 or 6) })
        tween(tab.nameL, t, { TextColor3 = sel and T.Text or T.TextIdle })
        local ic = sel and T.Text or T.SubText
        if tab.iconL:IsA("ImageLabel") then
            tween(tab.iconL, t, { ImageColor3 = ic })
        elseif tab.iconL:IsA("TextLabel") then
            tween(tab.iconL, t, { TextColor3 = ic })
        else
            tint(tab.iconL, ic)
        end
    end

    local function setExpanded(tab, open)
        tab.expanded = open
        for _, ch in ipairs(tab.children) do ch.btn.Visible = open end
        if tab.chev then tween(tab.chev, 0.2, { Rotation = open and 180 or 0 }) end
    end

    function Window:SelectTab(tab)
        closeAll()
        local prev = current
        if prev == tab then
            if #tab.children > 0 then setExpanded(tab, not tab.expanded) end
            return
        end
        current = tab
        if prev then
            prev.page.Visible = false
            paintTab(prev)
        end
        paintTab(tab)
        tab.page.Visible = true
        -- страница въезжает справа, заголовок опускается и проявляется
        tab.page.Position = UDim2.fromOffset(70, 0)
        tween(tab.page, 0.45, { Position = UDim2.fromOffset(0, 0) })
        topTitle.Text = tab.name
        topDesc.Text = tab.desc or ""
        topTitle.Position = UDim2.fromOffset(18, 2)
        topTitle.TextTransparency = 1
        tween(topTitle, 0.3, { Position = UDim2.fromOffset(18, 10), TextTransparency = 0 })
        topDesc.TextTransparency = 1
        tween(topDesc, 0.45, { TextTransparency = 0 })
        -- карточки секций выпрыгивают по очереди
        local k = 0
        for _, d in ipairs(tab.page:GetDescendants()) do
            if d:IsA("UIScale") and d.Name == "SBPop" then
                k += 1
                d.Scale = 0.9
                task.delay(0.03 * k, function() tween(d, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end)
            end
        end
        if #tab.children > 0 then setExpanded(tab, true) end
        if tab.parent and not tab.parent.expanded then setExpanded(tab.parent, true) end
        applySearch()
    end

    local tabCount = 0
    local function makeTab(o, parent)
        tabCount += 1
        local tab = { name = o.Name or "вкладка", desc = o.Desc, sections = {}, children = {}, parent = parent,
            expanded = false }
        local child = parent ~= nil
        local h = child and 34 or 42
        local order = child and (parent.order + #parent.children + 1) or tabCount * 1000
        tab.order = order

        local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = T.Element,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = order,
            Visible = not child or parent.expanded }, tabList)
        corner(btn, 8)
        local ind = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -9, 0.5, 0),
            Size = UDim2.fromOffset(3, 6), BackgroundColor3 = T.Accent, BackgroundTransparency = 1 }, btn)
        corner(ind, 2)
        local ix = child and 16 or 9
        local iconL
        if type(o.Icon) == "string" and o.Icon:sub(1, 1) == "@" then
            iconL = drawIcon(btn, o.Icon:sub(2), T.SubText)
            if child then new("UIScale", { Scale = 0.85 }, iconL) end
        elseif isImage(o.Icon) then
            iconL = new("ImageLabel", { BackgroundTransparency = 1, Image = o.Icon, ImageColor3 = T.SubText,
                Size = UDim2.fromOffset(16, 16) }, btn)
        else
            iconL = text({ Text = o.Icon or "•", TextSize = child and 13 or 15, TextColor3 = T.SubText,
                TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.None,
                Size = UDim2.fromOffset(18, 18) }, btn)
        end
        iconL.AnchorPoint = Vector2.new(0, 0.5)
        iconL.Position = UDim2.new(0, ix, 0.5, 0)
        local tx = ix + 26
        local nameL = text({ Position = UDim2.new(0, tx, 0, o.Desc and (h / 2 - 13) or 0),
            Size = UDim2.new(1, -tx - 22, 0, o.Desc and 15 or h), FontFace = F_BOLD, TextSize = child and 12 or 13,
            TextColor3 = T.TextIdle, Text = tab.name }, btn)
        if o.Desc then
            text({ Position = UDim2.new(0, tx, 0, h / 2 + 2), Size = UDim2.new(1, -tx - 22, 0, 12),
                TextSize = child and 10 or 11, TextColor3 = T.Dim, Text = o.Desc }, btn)
        end
        tab.btn, tab.ind, tab.iconL, tab.nameL = btn, ind, iconL, nameL
        conn(btn.MouseEnter, function()
            if current ~= tab then tween(btn, 0.15, { BackgroundTransparency = 0.5 }) end
        end)
        conn(btn.MouseLeave, function()
            if current ~= tab then tween(btn, 0.15, { BackgroundTransparency = 1 }) end
        end)
        conn(btn.MouseButton1Click, function() Window:SelectTab(tab) end)

        -- страница: две колонки карточек
        local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.StrokeLight,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = AUTO_Y, ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false }, pages)
        -- отступы — на обёртке: UIPadding прямо в ScrollingFrame не сужает колонки (правая уезжала за край)
        local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y, BackgroundTransparency = 1 }, page)
        pad(wrap, 2, 16, 16, 16)
        local cols = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y, BackgroundTransparency = 1 }, wrap)
        list(cols, 10, Enum.FillDirection.Horizontal)
        local function column(k)
            local c = new("Frame", { Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = AUTO_Y,
                BackgroundTransparency = 1, LayoutOrder = k }, cols)
            list(c, 10)
            return { frame = c, n = 0 }
        end
        local leftCol, rightCol = column(1), column(2)
        tab.page = page

        function tab:Section(so)
            so = so or {}
            local col
            if so.Side == "Right" then col = rightCol
            elseif so.Side == "Left" then col = leftCol
            else col = (leftCol.n <= rightCol.n) and leftCol or rightCol end
            col.n += 1
            local sec = { items = {}, lname = lower(so.Name or ""), open = true }
            local frame
            frame = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y,
                BackgroundColor3 = T.Section, LayoutOrder = col.n }, col.frame)
            corner(frame, 8)
            stroke(frame, T.Stroke)
            new("UIScale", { Name = "SBPop" }, frame) -- «выпрыгивает» при смене вкладки
            local head = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "",
                AutoButtonColor = false }, frame)
            text({ Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -40, 1, 0), FontFace = F_BOLD,
                TextColor3 = T.Text, Text = so.Name or "" }, head)
            local chev = chevron(head, T.SubText)
            chev.AnchorPoint = Vector2.new(1, 0.5)
            chev.Position = UDim2.new(1, -11, 0.5, 0)
            chev.Rotation = 180
            local divider = new("Frame", { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = T.Stroke, BorderSizePixel = 0 }, frame)
            local body = new("Frame", { Position = UDim2.fromOffset(0, 35), Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = AUTO_Y, BackgroundTransparency = 1 }, frame)
            list(body, 1)
            pad(body, 6, 10, 8, 10)
            function sec.setOpen(open, instant)
                sec.open = open
                body.Visible = open
                -- свёрнутое тело — нулевой высоты, чтобы карточка сжалась до шапки
                body.AutomaticSize = open and AUTO_Y or Enum.AutomaticSize.None
                body.Size = UDim2.new(1, 0, 0, 0)
                divider.Visible = open
                tween(chev, instant and 0 or 0.2, { Rotation = open and 180 or 0 })
            end
            conn(head.MouseButton1Click, function() sec.setOpen(not sec.open) end)
            conn(head.MouseEnter, function() paint(chev, T.Text) end)
            conn(head.MouseLeave, function() paint(chev, T.SubText) end)
            if so.Collapsed then sec.setOpen(false, true) end
            sec.frame = frame
            table.insert(tab.sections, sec)
            local api = container(body, sec.items)
            api.Instance = frame
            function api:SetOpen(v) sec.setOpen(v) end
            return api
        end

        function tab:Tab(co)
            local ch = makeTab(co, tab)
            table.insert(tab.children, ch)
            if not tab.chev then
                tab.chev = chevron(btn, T.SubText)
                tab.chev.AnchorPoint = Vector2.new(1, 0.5)
                tab.chev.Position = UDim2.new(1, -8, 0.5, 0)
            end
            return ch
        end
        function tab:Select() Window:SelectTab(tab) end

        paintTab(tab, true)
        table.insert(Window.Tabs, tab)
        if not current and not child then Window:SelectTab(tab) end
        return bindReg(tab)
    end
    function Window:Tab(o) return makeTab(o or {}, nil) end

    ------------------------------------------------------------ поиск
    local searchOpen = false
    local function setSearch(open)
        searchOpen = open
        tween(searchWrap, 0.25, { Size = UDim2.fromOffset(open and 170 or 0, 28) })
        tween(searchStroke, 0.25, { Transparency = open and 0 or 1 })
        if open then
            searchBox:CaptureFocus()
        else
            searchBox.Text = ""
        end
    end
    conn(searchBtn.MouseButton1Click, function() setSearch(not searchOpen) end)
    conn(searchBox.FocusLost, function()
        if searchBox.Text == "" then setSearch(false) end
    end)
    conn(searchBox:GetPropertyChangedSignal("Text"), function()
        searchQuery = lower(searchBox.Text)
        applySearch()
    end)

    ------------------------------------------------------------ фон: точки и линии между ними (или снежинки)
    local bgMode = opts.Background
    if bgMode == nil then bgMode = "network" end
    if bgMode == "network" or bgMode == "snow" then
        local pts, lines = {}, {}
        local N = bgMode == "snow" and 28 or 16
        for i = 1, N do
            local size = bgMode == "snow" and math.random(2, 4) or 2
            local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
                BackgroundColor3 = T.Decor, BackgroundTransparency = bgMode == "snow" and (0.55 + math.random() * 0.35) or 0.55,
                BorderSizePixel = 0 }, decor)
            corner(f, 3)
            pts[i] = { x = math.random(), y = math.random(), vx = (math.random() - 0.5) * 0.03,
                vy = bgMode == "snow" and (0.02 + math.random() * 0.03) or (math.random() - 0.5) * 0.03,
                ph = math.random() * 6.28, f = f }
        end
        if bgMode == "network" then
            for i = 1, 36 do
                lines[i] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = T.Decor,
                    BorderSizePixel = 0, Visible = false }, decor)
            end
        end
        local acc, clock = 0, 0
        local MAXD = 120
        conn(RunService.RenderStepped, function(dt)
            if not Window.Open then return end
            acc += dt
            if acc < 1 / 30 then return end
            dt, acc = acc, 0
            clock += dt
            local s = math.max(winScale.Scale, 0.01)
            local sw, sh = decor.AbsoluteSize.X / s, decor.AbsoluteSize.Y / s
            for _, p in ipairs(pts) do
                if bgMode == "snow" then
                    p.y += p.vy * dt
                    if p.y > 1.05 then p.y, p.x = -0.05, math.random() end
                    p.f.Position = UDim2.fromScale(p.x + math.sin(clock * 0.8 + p.ph) * 0.012, p.y)
                else
                    p.x += p.vx * dt
                    p.y += p.vy * dt
                    if p.x < 0 or p.x > 1 then p.vx = -p.vx; p.x = math.clamp(p.x, 0, 1) end
                    if p.y < 0 or p.y > 1 then p.vy = -p.vy; p.y = math.clamp(p.y, 0, 1) end
                    p.f.Position = UDim2.fromScale(p.x, p.y)
                end
            end
            if bgMode ~= "network" then return end
            local n = 0
            for i = 1, N do
                local a = pts[i]
                for j = i + 1, N do
                    local b = pts[j]
                    local dx, dy = (b.x - a.x) * sw, (b.y - a.y) * sh
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d < MAXD and n < #lines then
                        n += 1
                        local l = lines[n]
                        l.Visible = true
                        l.Position = UDim2.fromOffset((a.x * sw + b.x * sw) / 2, (a.y * sh + b.y * sh) / 2)
                        l.Size = UDim2.fromOffset(d, 1)
                        l.Rotation = math.deg(math.atan2(dy, dx))
                        l.BackgroundTransparency = 0.72 + 0.28 * (d / MAXD)
                    end
                end
            end
            for k = n + 1, #lines do lines[k].Visible = false end
        end)
    end

    ------------------------------------------------------------ уведомления (справа снизу)
    local toasts = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 270, 1, -32), BackgroundTransparency = 1 }, gui)
    local toastLayout = list(toasts, 8)
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    local toastScale = new("UIScale", {}, toasts)
    local toastN = 0
    function Window:Notify(o)
        o = o or {}
        toastN += 1
        toastScale.Scale = math.clamp(fit, 0.6, 1)
        local dur = o.Duration or 5
        local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y, BackgroundTransparency = 1,
            LayoutOrder = toastN }, toasts)
        local card = new("Frame", { Position = UDim2.fromOffset(300, 0), Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = AUTO_Y, BackgroundColor3 = T.Section }, holder)
        corner(card, 8)
        stroke(card, T.StrokeLight)
        local inner = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y,
            BackgroundTransparency = 1 }, card)
        pad(inner, 10, 12, 13, 12)
        list(inner, 3)
        text({ Size = UDim2.new(1, 0, 0, 16), FontFace = F_BOLD, TextSize = 13, TextColor3 = T.Text,
            Text = o.Title or opts.Title or "", LayoutOrder = 1 }, inner)
        if o.Text and o.Text ~= "" then
            text({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTO_Y, TextWrapped = true,
                TextTruncate = Enum.TextTruncate.None, TextColor3 = T.SubText, Text = o.Text, LayoutOrder = 2 }, inner)
        end
        local bar = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -4),
            Size = UDim2.new(1, -16, 0, 2), BackgroundColor3 = T.Accent, BackgroundTransparency = 0.4,
            BorderSizePixel = 0 }, card)
        corner(bar, 1)
        tween(card, 0.35, { Position = UDim2.fromOffset(0, 0) })
        tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(dur, function()
            tween(card, 0.3, { Position = UDim2.fromOffset(300, 0) })
            task.wait(0.32)
            holder:Destroy()
        end)
    end

    ------------------------------------------------------------ тема и размер на лету
    function Window:SetTheme(t)
        for k, v in pairs(t) do
            if T[k] ~= nil and typeof(v) == "Color3" then T[k] = v end
        end
        reg.byColor = uniq(T)
        local alive = {}
        for _, e in ipairs(reg.list) do
            if e[1].Parent then
                pcall(function() e[1][e[2]] = T[e[3]] end)
                table.insert(alive, e)
            end
        end
        reg.list = alive
        for _, tab in ipairs(Window.Tabs) do paintTab(tab, true) end
        for _, f in ipairs(refreshers) do pcall(f) end
    end
    -- фон, акцент, текст (любой можно nil — останется как есть)
    function Window:SetColors(bg, accent, textColor)
        Window:SetTheme(UI.Derive(bg or T.Background, accent or T.Accent, textColor or T.Text))
    end
    function Window:SetSize(w, h)
        W = math.floor(math.clamp(w, 540, 1100))
        H = math.floor(math.clamp(h, 340, 760))
        win.Size = UDim2.fromOffset(W, H)
        refit()
    end
    function Window:GetSize() return W, H end
    function Window:SetScale(s)
        userScale = s
        refit()
    end

    -- уголок справа снизу: потянуть — поменять размер
    local grip = new("TextButton", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5 }, win)
    seg(grip, 5, 13, 13, 5, 1.4, T.Dim)
    seg(grip, 9, 13, 13, 9, 1.4, T.Dim)
    conn(grip.MouseEnter, function() paint(grip, T.Text) end)
    conn(grip.MouseLeave, function() paint(grip, T.Dim) end)
    conn(grip.InputBegan, function(i)
        if not isClick(i) then return end
        local sw, sh, sp, sm = W, H, win.Position, i.Position
        drag = {
            move = function(p)
                local s = winScale.Scale
                local d = p - sm
                Window:SetSize(sw + d.X / s, sh + d.Y / s)
                -- окно по центру якоря — сдвигаем, чтобы левый верхний угол стоял на месте
                win.Position = sp + UDim2.fromOffset((W - sw) * s / 2, (H - sh) * s / 2)
            end,
            stop = function()
                if opts.OnResize then task.spawn(opts.OnResize, W, H) end
            end,
        }
    end)

    ------------------------------------------------------------ открыть / закрыть
    local modal = new("TextButton", { Size = UDim2.fromScale(0, 0), BackgroundTransparency = 1, Text = "",
        Modal = true, Visible = false }, gui)
    local savedMouse
    local renderName = "SBUI_Mouse_" .. gui.Name .. "_" .. tostring(math.random(1, 1e6))
    local opener
    function Window:SetOpen(open)
        if open == Window.Open then return end
        Window.Open = open
        if open then
            savedMouse = { UIS.MouseBehavior, UIS.MouseIconEnabled }
            -- как у Opiumware: по центру появляется скруглённый квадрат с логотипом,
            -- и из него вырастает окно с функциями
            local c = win.AbsolutePosition + win.AbsoluteSize / 2
            if opts.LogoIntro ~= false then
                local tile = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
                    Size = UDim2.fromOffset(104, 104), BackgroundColor3 = T.Section, ZIndex = 250 }, gui)
                corner(tile, 26)
                local tst = stroke(tile, T.StrokeLight)
                local tl = logoInto(tile, opts.Logo, 56, T.Accent)
                tl.AnchorPoint = Vector2.new(0.5, 0.5)
                tl.Position = UDim2.fromScale(0.5, 0.5)
                tl.ZIndex = 251
                local ts = new("UIScale", { Scale = 0.35 }, tile)
                tween(ts, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
                win.Visible = false
                task.delay(0.36, function()
                    if not Window.Open then tile:Destroy() return end
                    -- окно вырастает из значка
                    win.Visible = true
                    win.GroupTransparency = 1
                    tween(win, 0.25, { GroupTransparency = 0 })
                    winScale.Scale = fit * math.clamp(104 / math.max(W, 1), 0.05, 0.6)
                    tween(winScale, 0.45, { Scale = fit }, Enum.EasingStyle.Quint)
                    tween(ts, 0.3, { Scale = 1.6 })
                    tween(tile, 0.3, { BackgroundTransparency = 1 })
                    if tst then tween(tst, 0.3, { Transparency = 1 }) end
                    tween(tl, 0.3, { [tl:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"] = 1 })
                    task.delay(0.32, function() tile:Destroy() end)
                end)
            else
                win.Visible = true
                win.GroupTransparency = 1
                tween(win, 0.25, { GroupTransparency = 0 })
                winScale.Scale = fit * 0.82
                tween(winScale, 0.42, { Scale = fit }, Enum.EasingStyle.Back)
            end
        else
            closeAll()
            if searchBox:IsFocused() then searchBox:ReleaseFocus() end
            if savedMouse then
                pcall(function()
                    UIS.MouseBehavior = savedMouse[1]
                    UIS.MouseIconEnabled = savedMouse[2]
                end)
            end
            -- зеркально открытию: окно сжимается в значок с логотипом (значок проявляется ему навстречу),
            -- потом значок уменьшается и исчезает. Окно прячем ровно в момент, когда оно размером со значок.
            if opts.LogoIntro ~= false then
                local c = win.AbsolutePosition + win.AbsoluteSize / 2
                local tile = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
                    Size = UDim2.fromOffset(104, 104), BackgroundColor3 = T.Section, BackgroundTransparency = 1,
                    ZIndex = 250 }, gui)
                corner(tile, 26)
                local tst = stroke(tile, T.StrokeLight)
                tst.Transparency = 1
                local tl = logoInto(tile, opts.Logo, 56, T.Accent)
                tl.AnchorPoint = Vector2.new(0.5, 0.5)
                tl.Position = UDim2.fromScale(0.5, 0.5)
                tl.ZIndex = 251
                local lprop = tl:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                tl[lprop] = 1
                local ts = new("UIScale", { Scale = 1.6 }, tile)
                -- окно сжимается так, чтобы целиком уместиться ВНУТРИ значка (по большей стороне),
                -- а значок к этому моменту уже непрозрачный и закрывает его — никаких «хвостов»
                local small = fit * math.clamp(90 / math.max(W, H, 1), 0.03, 0.6)
                tween(winScale, 0.22, { Scale = small }, Enum.EasingStyle.Quint)
                tween(win, 0.18, { GroupTransparency = 1 }, Enum.EasingStyle.Quad)
                tween(ts, 0.22, { Scale = 1 })
                tween(tile, 0.1, { BackgroundTransparency = 0 })
                tween(tst, 0.1, { Transparency = 0 })
                tween(tl, 0.14, { [lprop] = 0 })
                task.delay(0.22, function()
                    if not Window.Open then win.Visible = false end
                    -- тёмный квадрат сразу растворяется (иначе он похож на маленькое меню),
                    -- остаётся один логотип: чуть «вздыхает» и исчезает
                    tween(tile, 0.08, { BackgroundTransparency = 1 })
                    tween(tst, 0.08, { Transparency = 1 })
                    tween(ts, 0.1, { Scale = 1.12 })
                    task.delay(0.1, function()
                        tween(ts, 0.18, { Scale = 0.2 }, Enum.EasingStyle.Quad)
                        tween(tl, 0.18, { [lprop] = 1 })
                    end)
                    task.delay(0.3, function() tile:Destroy() end)
                end)
            else
                tween(winScale, 0.18, { Scale = fit * 0.9 })
                tween(win, 0.18, { GroupTransparency = 1 }, Enum.EasingStyle.Quad)
                task.delay(0.18, function()
                    if not Window.Open then win.Visible = false end
                end)
            end
        end
        modal.Visible = open and opts.FreeMouse ~= false
        if opener then tween(opener, 0.2, { BackgroundColor3 = open and T.Hover or T.Section }) end
        if opts.OnToggle then task.spawn(opts.OnToggle, open) end
    end
    function Window:Toggle() Window:SetOpen(not Window.Open) end

    -- Окно «что нового» при запуске (как у Opiumware): по центру появляется значок, раскрывается в
    -- карточку — логотип, название, версия и список изменений; строки проявляются по одной.
    -- opts.Changelog = { Title = "...", Version = "v2.0", Lines = { "...", ... }, Button = "Поехали!" }
    function Window:ShowChangelog(cl)
        cl = cl or opts.Changelog
        if not cl then return end
        local holder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1, ZIndex = 300 }, gui)
        tween(holder, 0.4, { BackgroundTransparency = 0.55 })
        -- 1) значок
        local tile = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(110, 110), BackgroundColor3 = T.Section, ZIndex = 301 }, holder)
        corner(tile, 26)
        stroke(tile, T.StrokeLight)
        local tl = logoInto(tile, opts.Logo, 58, T.Accent)
        tl.AnchorPoint = Vector2.new(0.5, 0.5)
        tl.Position = UDim2.fromScale(0.5, 0.5)
        tl.ZIndex = 302
        local ts = new("UIScale", { Scale = 0.4 }, tile)
        tween(ts, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
        -- 2) карточка
        local lines = cl.Lines or {}
        local cardH = 190 + #lines * 22
        local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(440, cardH), BackgroundColor3 = T.Background, Visible = false, ZIndex = 301 }, holder)
        corner(card, 14)
        stroke(card, T.StrokeLight)
        local cs = new("UIScale", { Scale = 0.85 }, card)
        local big = logoInto(card, opts.Logo, 64, T.Accent)
        big.AnchorPoint = Vector2.new(0.5, 0)
        big.Position = UDim2.new(0.5, 0, 0, 18)
        big.ZIndex = 302
        text({ Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 0, 24), FontFace = F_BOLD, TextSize = 20,
            TextColor3 = T.Text, Text = (cl.Title or opts.Title or "") .. "  ", TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 302 }, card)
        text({ Position = UDim2.fromOffset(0, 120), Size = UDim2.new(1, 0, 0, 16), TextSize = 12, TextColor3 = T.SubText,
            Text = cl.Version or "", TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 302 }, card)
        new("Frame", { Position = UDim2.new(0, 24, 0, 146), Size = UDim2.new(1, -48, 0, 1), BackgroundColor3 = T.Stroke,
            BorderSizePixel = 0, ZIndex = 302 }, card)
        local rows = {}
        for i, line in ipairs(lines) do
            rows[i] = text({ Position = UDim2.fromOffset(40, 154 + (i - 1) * 22), Size = UDim2.new(1, -64, 0, 20),
                TextSize = 13, TextColor3 = T.Text, Text = "•  " .. line, TextTransparency = 1, ZIndex = 302 }, card)
        end
        local btn = new("TextButton", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14),
            Size = UDim2.fromOffset(150, 30), BackgroundColor3 = T.Accent, Text = cl.Button or "Поехали!",
            FontFace = F_BOLD, TextSize = 13, TextColor3 = T.Background, AutoButtonColor = false, ZIndex = 303 }, card)
        corner(btn, 8)
        local closed = false
        local function close()
            if closed then return end
            closed = true
            tween(cs, 0.18, { Scale = 0.85 }, Enum.EasingStyle.Quad)
            tween(holder, 0.25, { BackgroundTransparency = 1 })
            task.delay(0.2, function() card.Visible = false end)
            task.delay(0.26, function() holder:Destroy() end)
        end
        conn(btn.MouseButton1Click, close)
        task.delay(0.55, function()
            if closed then return end
            -- значок «улетает» в логотип карточки, карточка раскрывается
            tween(ts, 0.22, { Scale = 0.6 })
            tween(tile, 0.22, { BackgroundTransparency = 1 })
            tween(tl, 0.22, { [tl:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"] = 1 })
            card.Visible = true
            tween(cs, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
            task.delay(0.25, function() tile:Destroy() end)
            for i, r in ipairs(rows) do
                task.delay(0.25 + i * 0.07, function()
                    if not r.Parent then return end
                    r.Position = r.Position + UDim2.fromOffset(14, 0)
                    tween(r, 0.3, { TextTransparency = 0, Position = r.Position - UDim2.fromOffset(14, 0) })
                end)
            end
        end)
        task.delay(cl.Duration or 14, close)
    end
    task.defer(function()
        if opts.OpenOnStart then
            Window:SetOpen(true)
            task.wait(1)
        end
        if opts.Changelog then Window:ShowChangelog() end
    end)
    conn(closeBtn.MouseButton1Click, function() Window:SetOpen(false) end)
    conn(lightBtns.close.b.MouseButton1Click, function() Window:SetOpen(false) end)
    -- жёлтая: свернуть — окно улетает в круглую кнопку открытия
    conn(lightBtns.min.b.MouseButton1Click, function()
        if not opener then Window:SetOpen(false) return end
        local pos = win.Position
        local tgt = opener.AbsolutePosition + opener.AbsoluteSize / 2
        local saveIntro = opts.LogoIntro
        opts.LogoIntro = false
        tween(win, 0.3, { Position = UDim2.fromOffset(tgt.X, tgt.Y) }, Enum.EasingStyle.Quint)
        Window:SetOpen(false)
        opts.LogoIntro = saveIntro
        task.delay(0.32, function() win.Position = pos end)
    end)
    -- зелёная: на весь экран (с полями, чтобы всё было видно) и обратно
    local maxed
    conn(lightBtns.max.b.MouseButton1Click, function()
        local vs = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        if not maxed then
            maxed = { W = W, H = H, pos = win.Position }
            W = math.floor(vs.X / userScale - 60)
            H = math.floor(vs.Y / userScale - 60)
            tween(win, 0.35, { Position = UDim2.fromScale(0.5, 0.5) })
        else
            W, H = maxed.W, maxed.H
            tween(win, 0.35, { Position = maxed.pos })
            maxed = nil
        end
        fit = math.clamp(math.min(vs.X / (W + 40), vs.Y / (H + 40), userScale), 0.4, 2)
        tween(win, 0.35, { Size = UDim2.fromOffset(W, H) })
        tween(winScale, 0.35, { Scale = fit })
    end)

    local keyCode = Enum.KeyCode.RightShift
    function Window:SetKey(name)
        local ok, kc = pcall(function() return Enum.KeyCode[name] end)
        if ok and kc then keyCode = kc end
    end
    if opts.Key then Window:SetKey(opts.Key) end
    conn(UIS.InputBegan, function(i)
        if binding or i.KeyCode ~= keyCode then return end
        if UIS:GetFocusedTextBox() then return end
        Window:Toggle()
    end)

    -- игры (DOORS тоже) каждый кадр прячут курсор и держат его в центре — пока меню открыто, отпускаем
    if opts.FreeMouse ~= false then
        RunService:BindToRenderStep(renderName, Enum.RenderPriority.Last.Value, function()
            if Window.Open then
                UIS.MouseBehavior = Enum.MouseBehavior.Default
                UIS.MouseIconEnabled = true
            end
        end)
    end

    -- круглая кнопка на экране (для телефона; можно перетащить)
    if opts.Opener ~= false then
        opener = new("TextButton", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, opts.OpenerY or 0.42, 0),
            Size = UDim2.fromOffset(44, 44), BackgroundColor3 = T.Section, Text = "", AutoButtonColor = false }, gui)
        corner(opener, 22)
        stroke(opener, T.StrokeLight)
        local ol = logoInto(opener, opts.Logo, 22, T.Accent)
        ol.AnchorPoint = Vector2.new(0.5, 0.5)
        ol.Position = UDim2.fromScale(0.5, 0.5)
        conn(opener.InputBegan, function(i)
            if not isClick(i) then return end
            local sp, sm, moved = opener.Position, i.Position, false
            drag = {
                move = function(p)
                    local d = p - sm
                    if not moved and Vector2.new(d.X, d.Y).Magnitude > 6 then moved = true end
                    if moved then opener.Position = sp + UDim2.fromOffset(d.X, d.Y) end
                end,
                stop = function()
                    if not moved then Window:Toggle() end
                end,
            }
        end)
    end

    function Window:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        if opts.FreeMouse ~= false then pcall(function() RunService:UnbindFromRenderStep(renderName) end) end
        if Window.Open and savedMouse then
            pcall(function()
                UIS.MouseBehavior = savedMouse[1]
                UIS.MouseIconEnabled = savedMouse[2]
            end)
        end
        Window.Open = false
        pcall(function() gui:Destroy() end)
    end

    if opts.Theme then Window:SetTheme(opts.Theme) end
    bindReg(Window)
    return Window
end

return UI
end)()
-- <<< SBUI

-- >>> VISUALS (собрано build_visuals.py из visuals_src — правь там)
local function NY_Visuals(HOST_WIN, SBUI)
--  visuals.lua — Визуалы: погода, следы за персонажем, круги при прыжке и приземлении, шейдеры,
--  освещение и музыкальный плеер (свои файлы, ссылки, Spotify). Всё видно только тебе.
--
--  Основа — код Salad Visuals (автор сам выложил исходники в своём канале), перенесён под
--  наше меню (ui.lua) и переведён. Картинки эффектов лежат в workspace/StevieBuddy/fx/.
--
--  Меню: RightControl (меняется в настройках меню). Настройки сохраняются в
--  workspace/StevieBuddy/visuals_settings.json. Свои песни: workspace/StevieBuddy/music/*.mp3|ogg
--
--  СОБИРАЕТСЯ из visuals_src/*.lua скриптом build_visuals.py — правь части там, а не этот файл.

local CONFIG = {
    FOLDER = "StevieBuddy",
    FX = "StevieBuddy/fx/",              -- картинки эффектов (частицы, круги, небо, иконки плеера)
    MUSIC = "StevieBuddy/music",         -- свои песни
    SETTINGS = "StevieBuddy/visuals_settings.json",
    MENU_KEY = "RightControl",
    LOGO = "StevieBuddy/logo.png",
    -- чего нет в workspace — докачивается отсюда (fx/…)
    ASSETS_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/",
}
local VISUALS_BUILD = "13.11 21:34"

local env = (getgenv and getgenv()) or _G
if env.__SBVisuals and type(env.__SBVisuals.Destroy) == "function" then pcall(env.__SBVisuals.Destroy) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local GLOBAL = env
GLOBAL.__SBVisualsGen = (tonumber(GLOBAL.__SBVisualsGen) or 0) + 1
local INIT_GENERATION = GLOBAL.__SBVisualsGen
local ALIVE = true
local TAG = "SBVisuals"

------------------------------------------------------------------------ уборка и ошибки
local CLEANUPS = {}
local function onUnload(name, fn)
    CLEANUPS[#CLEANUPS + 1] = { name = name, fn = fn }
    return fn
end
local ERRORS = {}
local function recordError(message)
    if #ERRORS >= 64 then table.remove(ERRORS, 1) end
    ERRORS[#ERRORS + 1] = message
    warn("[Визуалы] " .. tostring(message))
end
local function guard(name, fn)
    if not ALIVE then return false end
    local ok, err = pcall(fn)
    if not ok then recordError(name .. ": " .. tostring(err)) end
    return ok
end

------------------------------------------------------------------------ файлы (вместо их облака)
local Remote = { base = "", manifest = nil }
function Remote.current() return ALIVE and GLOBAL.__SBVisualsGen == INIT_GENERATION end
function Remote.file(rel) return rel end
local idCache = {}
function Remote.id(rel)
    if type(rel) ~= "string" or rel == "" then return nil end
    if rel:find("://", 1, true) then return rel end
    local hit = idCache[rel]
    if hit then return hit end
    local ok, id = pcall(function()
        local path = CONFIG.FX .. rel
        if not isfile(path) and CONFIG.ASSETS_URL ~= "" then
            -- нет у себя — докачать с GitHub (один раз, дальше лежит в workspace)
            local url = CONFIG.ASSETS_URL .. "fx/" .. rel:gsub("[^%w%-%._~/]", function(c)
                return string.format("%%%02X", string.byte(c))
            end)
            local okGet, data = pcall(game.HttpGet, game, url)
            if okGet and type(data) == "string" and #data > 200 and not data:find("<html", 1, true)
                and not data:match("^404") then
                local dir = ""
                for part in path:gmatch("([^/]+)/") do
                    dir = dir .. part
                    if not isfolder(dir) then makefolder(dir) end
                    dir = dir .. "/"
                end
                writefile(path, data)
            end
        end
        if isfile(path) and getcustomasset then return getcustomasset(path) end
        return nil
    end)
    if ok and id then idCache[rel] = id end
    return ok and id or nil
end
Remote.asset = Remote.id
Remote.cachedId = Remote.id
function Remote.have(rel) return Remote.id(rel) ~= nil end
function Remote.under(prefix)
    local out = {}
    pcall(function()
        local dir = CONFIG.FX .. prefix:gsub("/$", "")
        if not (isfolder and isfolder(dir) and listfiles) then return end
        for _, f in ipairs(listfiles(dir)) do
            local name = tostring(f):gsub("\\", "/"):match("([^/]+)$")
            if name and name:find("%.") then out[#out + 1] = prefix .. name end
        end
    end)
    table.sort(out)
    return out
end
function Remote.load() return nil end
local pending = 0
function Remote.invoke(fn, seconds)
    if not Remote.current() then return false, nil, "cancelled" end
    if pending >= 16 then return false, nil, "busy" end
    pending += 1
    local done, abandoned, result = false, false, nil
    task.spawn(function()
        local values = table.pack(pcall(fn))
        pending -= 1
        if not abandoned then result = values; done = true end
    end)
    local deadline = os.clock() + (seconds or 10)
    while not done and Remote.current() and os.clock() < deadline do task.wait(0.03) end
    if not done or not Remote.current() then
        abandoned = true
        return false, nil, Remote.current() and "timeout" or "cancelled"
    end
    return result[1], result[2]
end
Remote.io = function(fn) return Remote.invoke(fn, 3) end
-- всё, что приходит из каталога Roblox, — чужое: выкидываем скрипты и интерфейсы
local UNWANTED = { "LuaSourceContainer", "ScreenGui", "RemoteEvent", "RemoteFunction", "BindableEvent",
    "BindableFunction", "ClickDetector", "ProximityPrompt" }
local function strip(root)
    if typeof(root) ~= "Instance" then return end
    for _, d in ipairs(root:GetDescendants()) do
        for _, c in ipairs(UNWANTED) do
            if d:IsA(c) then pcall(function() d:Destroy() end) break end
        end
    end
end
Remote.strip = strip
function Remote.objects(fn, seconds)
    local ok, roots = Remote.invoke(fn, seconds or 12)
    if ok and type(roots) == "table" then
        for _, r in ipairs(roots) do strip(r) end
    end
    return ok, roots
end
function Remote.download(url)
    local ok, body = Remote.invoke(function() return game:HttpGet(url) end, 20)
    return ok and body or nil
end
Remote.custom = getcustomasset
function Remote.slug(text)
    local s = tostring(text or ""):lower():gsub("[^%w]+", "_"):sub(-60)
    return s ~= "" and s or tostring(math.random(1, 1e9))
end
-- записать файл в кэш и вернуть его как ассет
function Remote.volatile(rel, body)
    local ok, id = pcall(function()
        local path = CONFIG.FOLDER .. "/cache/" .. tostring(rel):gsub("[^%w%._%-]", "_")
        if not isfolder(CONFIG.FOLDER .. "/cache") then makefolder(CONFIG.FOLDER .. "/cache") end
        writefile(path, body)
        return getcustomasset(path)
    end)
    return ok and id or nil
end

------------------------------------------------------------------------ рисование
local Render = {}
function Render.FxDepth(effect, through)
    if effect:IsA("BillboardGui") or effect:IsA("SurfaceGui") then
        effect.AlwaysOnTop = through == true
    elseif effect:IsA("Highlight") then
        effect.DepthMode = through and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    elseif effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
        local offset = through and 100000 or 0
        if effect.ZOffset ~= offset then effect.ZOffset = offset end
    end
end
function Render.DepthTree(root, through)
    Render.FxDepth(root, through)
    for _, e in ipairs(root:GetDescendants()) do Render.FxDepth(e, through) end
end
local function hiddenParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return game:GetService("CoreGui")
end
function Render.gui(label, order)
    local gui = Instance.new("ScreenGui")
    gui.Name = HttpService:GenerateGUID(false)
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = order or 0
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui:SetAttribute(TAG, INIT_GENERATION) end)
    gui.Parent = hiddenParent()
    onUnload("gui:" .. tostring(label), function() pcall(function() gui:Destroy() end) end)
    return gui
end

------------------------------------------------------------------------ сохранение настроек
local SAVED = {}
pcall(function()
    if isfile and isfile(CONFIG.SETTINGS) then
        local t = HttpService:JSONDecode(readfile(CONFIG.SETTINGS))
        if type(t) == "table" then SAVED = t end
    end
end)
local function encodeValue(v)
    if typeof(v) == "Color3" then return { c = v:ToHex() } end
    return v
end
local function decodeValue(v)
    if type(v) == "table" and type(v.c) == "string" then
        local ok, c = pcall(Color3.fromHex, v.c)
        return ok and c or nil
    end
    return v
end
local saveQueued = false
local function saveSoon()
    if saveQueued then return end
    saveQueued = true
    task.delay(1, function()
        saveQueued = false
        pcall(function()
            if not isfolder(CONFIG.FOLDER) then makefolder(CONFIG.FOLDER) end
            writefile(CONFIG.SETTINGS, HttpService:JSONEncode(SAVED))
        end)
    end)
end
local function userFile(name) return CONFIG.FOLDER .. "/" .. name end

------------------------------------------------------------------------ перевод подписей
-- Ключи — английские названия из их кода. Значения в списках переводятся только на экране:
-- в код уходит исходное английское значение.
local RU = {
    -- общее
    Off = "Выкл", On = "Вкл", Self = "Себе", Other = "Другим", All = "Всем", Enabled = "Включить",
    Type = "Тип", Amount = "Количество", Size = "Размер", Color = "Цвет", Options = "Настройки",
    Style = "Стиль", Target = "Кому", Opacity = "Непрозрачность", Brightness = "Яркость",
    Intensity = "Сила", Density = "Плотность", Height = "Высота", Distance = "Ширина области",
    Value = "Значение", Time = "Время", Preset = "Готовый вид", Rainbow = "Радуга",
    ["Custom Color"] = "Свой цвет", ["Custom Colors"] = "Свои цвета", ["Fade Color"] = "Цвет хвоста",
    Spin = "Вращение", Rotation = "Поворот", Glow = "Свечение", Life = "Время жизни", Grow = "Рост",
    ["Through Walls"] = "Сквозь стены", Burst = "Выпустить разом",
    -- погода
    Snow = "Снег", ["Snow Soft"] = "Мягкий снег", Sakura = "Сакура", Rain = "Дождь", Ash = "Пепел",
    Fireflies = "Светлячки", ["Fall Speed"] = "Скорость падения", ["Particle Size"] = "Размер частиц",
    Transparency = "Прозрачность",
    -- следы
    Length = "Длина", Spread = "Разлёт", Drift = "Подъём/спуск", ["Always On"] = "Даже стоя на месте",
    Trails = "Следы", Bloom = "Цветение", Sparkle = "Искры", Stars = "Звёзды", Hearts = "Сердечки",
    Lightning = "Молнии", Crowns = "Короны", Smolder = "Тлеющий дым", Halo = "Ореол", Starfall = "Звездопад",
    Swarm = "Рой", Static = "Помехи", Frost = "Мороз", Bloomburst = "Вспышки", Ribbon = "Лента",
    Comet = "Комета", Smoke = "Дым",
    -- круги
    ["Jump Circle"] = "Круг при прыжке", ["Land Circle"] = "Круг при приземлении", Jump = "Прыжок", Land = "Приземление",
    ["Test Circle"] = "Показать круг",
    -- шейдеры и свет
    Skybox = "Небо", ["Sun / Moon"] = "Солнце / луна", Fog = "Туман", ["Sun Rays"] = "Лучи солнца",
    Blur = "Размытие", ["Color Grade"] = "Цветокоррекция", Saturation = "Насыщенность", Contrast = "Контраст",
    Tint = "Оттенок", Atmosphere = "Атмосфера", Haze = "Дымка", Offset = "Смещение", Threshold = "Порог",
    Fullbright = "Всё светлое", ["Time Change"] = "Своё время суток", Ambient = "Окружающий свет",
    Exposure = "Экспозиция",
    -- музыка
    Provider = "Источник", Local = "Своё (ID и файлы)", Links = "Ссылки на mp3", Spotify = "Spotify",
    ["Now Playing HUD"] = "Плашка «Сейчас играет»", ["Clear Queue"] = "Очистить очередь", Loop = "Повтор",
    Volume = "Громкость", Layout = "Вид", Full = "Полный", Compact = "Компактный", Lyrics = "Текст песни",
    ["Lyrics Height"] = "Высота текста", ["Lyrics Corner"] = "Угол текста", Position = "Где на экране",
    ["Bottom Left"] = "Снизу слева", ["Bottom Right"] = "Снизу справа", ["Top Left"] = "Сверху слева",
    ["Top Right"] = "Сверху справа", ["Bottom Center"] = "Снизу по центру", ["Top Center"] = "Сверху по центру",
    Artwork = "Обложка", Controls = "Кнопки", Progress = "Полоса", Times = "Время трека",
    Visualizer = "Эквалайзер", Scale = "Масштаб", ["Client ID"] = "Client ID", Connect = "Подключить",
    ["Paste Code"] = "Вставь код", ["Test Connection"] = "Проверить", Disconnect = "Отключить",
}
local function tr(s)
    if type(s) ~= "string" then return s end
    return RU[s] or s
end

------------------------------------------------------------------------ меню (прослойка под их API)
local Notification = {}
local win -- окно меню, создаётся ниже
function Notification.new(o)
    if win then pcall(function() win:Notify({ Title = tr(o.Title), Text = tostring(o.Content or ""), Duration = o.Duration or 5 }) end) end
end

local SIGNALS = {}
local Flags = {}   -- [flag] = { Value, SetValue, GetValue }
local pool = {}    -- [flag] = { set = fn }
local APPLY = {}   -- сохранённые значения: применить после того, как всё построено
local NeverLose
NeverLose = {
    RandomString = function() return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 12) end,
    Flags = Flags,
    AccentColor = nil,
    BuiltInRegular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
    BuiltInBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Lib = {
        theme = {
            bg = Color3.fromRGB(12, 12, 14), panel = Color3.fromRGB(20, 20, 23), head = Color3.fromRGB(28, 28, 32),
            line = Color3.fromRGB(44, 44, 50), text = Color3.fromRGB(238, 238, 240), dim = Color3.fromRGB(150, 150, 158),
            glow = Color3.fromRGB(120, 200, 255),
        },
        themeroots = {}, icons = {}, pool = pool,
    },
}
function NeverLose:AddSignal(c)
    SIGNALS[#SIGNALS + 1] = c
    return c
end
function NeverLose:AddPlayerSignal(_, c)
    SIGNALS[#SIGNALS + 1] = c
    return c
end
local function setFlag(flag, value)
    local e = pool[flag]
    if e and e.set then pcall(e.set, value) end
end
local applying = false
local function userPicked() return not applying end

-- запомнить элемент под флагом, вернуть значение по умолчанию с учётом сохранённого
local function flagged(o, kind)
    local flag = o.Flag
    local default = o.Default
    if flag and SAVED[flag] ~= nil then
        local v = decodeValue(SAVED[flag])
        if v ~= nil then
            if kind == "dropdown" and o.Values and not table.find(o.Values, v) then v = default end
            if v ~= default then APPLY[#APPLY + 1] = { o = o, v = v } end
            default = v
        end
    end
    return default
end
local function remember(o, v)
    if o.Flag then
        SAVED[o.Flag] = encodeValue(v)
        saveSoon()
        if Flags[o.Flag] then Flags[o.Flag].Value = v end
    end
end
local function wrapCallback(o)
    return function(v)
        remember(o, v)
        if o.Callback then
            local ok, err = pcall(o.Callback, v)
            if not ok then recordError((o.Flag or "?") .. ": " .. tostring(err)) end
        end
    end
end
local function register(o, el, toUi)
    if not o.Flag then return end
    local entry = { Value = el.Value }
    function entry:SetValue(v) pcall(function() el:Set(toUi and toUi(v) or v) end) end
    function entry:GetValue() return entry.Value end
    Flags[o.Flag] = entry
    pool[o.Flag] = { set = function(v) entry:SetValue(v) end }
end

local wrapContainer
wrapContainer = function(api)
    local W = {}
    function W:AddLabel(name, plain)
        if plain == true then
            api:Label(tr(name))
            return setmetatable({}, { __index = function() return function() return {} end end })
        end
        local L = { count = 0 }
        local label = tr(name)
        local function nm(o, fallback)
            L.count += 1
            if o.Name and o.Name ~= name then return tr(o.Name) end
            return L.count > 1 and fallback or label
        end
        function L:AddToggle(o)
            local def = flagged(o, "toggle") == true
            local el = api:Toggle({ Name = nm(o, label), Default = def, Callback = wrapCallback(o) })
            L.last = el
            register(o, el)
            if o.Flag then Flags[o.Flag].Value = def end
            return el
        end
        function L:AddSlider(o)
            local step = 1
            if type(o.Rounding) == "number" and o.Rounding > 0 then step = 10 ^ -o.Rounding end
            local fmt = o.Type == "%" and "%d%%" or nil
            local def = flagged(o, "slider") or o.Min
            local el = api:Slider({ Name = nm(o, label), Min = o.Min, Max = o.Max, Step = step, Default = def,
                Format = fmt, Callback = wrapCallback(o) })
            register(o, el)
            if o.Flag then Flags[o.Flag].Value = def end
            return el
        end
        function L:AddDropdown(o)
            local values = o.Values or {}
            local shown, back = {}, {}
            for i, v in ipairs(values) do
                local t = tr(v)
                if back[t] then t = t .. " (" .. tostring(v) .. ")" end
                shown[i], back[t] = t, v
            end
            local def = flagged(o, "dropdown")
            local cb = wrapCallback(o)
            local el = api:Dropdown({ Name = nm(o, label), Options = shown, Default = def ~= nil and tr(def) or shown[1],
                Callback = function(t) cb(back[t] or t) end })
            register(o, el, function(v) return tr(v) end)
            if o.Flag then Flags[o.Flag].Value = def end
            local proxy = setmetatable({}, { __index = el })
            function proxy:SetValues(list)
                values = list
                shown, back = {}, {}
                for i, v in ipairs(list) do
                    local t = tr(v)
                    shown[i], back[t] = t, v
                end
                el:SetOptions(shown)
            end
            proxy.Refresh = proxy.SetValues
            return proxy
        end
        function L:AddColorPicker(o)
            local def = flagged(o, "color") or o.Default
            local el = api:ColorPicker({ Name = nm(o, label .. ": цвет"), Default = def, Callback = wrapCallback(o) })
            register(o, el)
            if o.Flag then Flags[o.Flag].Value = def end
            return el
        end
        function L:AddTextInput(o)
            local def = flagged(o, "text") or ""
            local el = api:Input({ Name = nm(o, label), Default = def, Placeholder = tr(o.Placeholder),
                Callback = wrapCallback(o) })
            register(o, el)
            if o.Flag then Flags[o.Flag].Value = def end
            return el
        end
        function L:AddKeybind(o)
            local el = api:Keybind({ Name = nm(o, label), Default = flagged(o, "key") or "None", Callback = wrapCallback(o) })
            register(o, el)
            return el
        end
        function L:AddButton(o) return W:AddButton(o) end
        -- «доп. настройки» строки: у переключателя — его кнопка «•••», иначе — прямо в секции
        function L:AddOption()
            if L.last and L.last.Settings then return wrapContainer(L.last:Settings(label)) end
            return W
        end
        return L
    end
    function W:AddButton(o)
        return api:Button({ Name = tr(o.Name), Callback = function()
            local ok, err = pcall(o.Callback)
            if not ok then recordError(tostring(o.Name) .. ": " .. tostring(err)) end
        end })
    end
    function W:AddToggle(o) return W:AddLabel(o.Name or "?"):AddToggle(o) end
    function W:AddSlider(o) return W:AddLabel(o.Name or "?"):AddSlider(o) end
    function W:AddDropdown(o) return W:AddLabel(o.Name or "?"):AddDropdown(o) end
    -- галерея (у них — сетка с картинками) у нас — просто список
    function W:AddGallery(o)
        local names = {}
        for _, row in ipairs(o.Values or {}) do names[#names + 1] = row.name end
        local dd = W:AddLabel(o.Name or "Style"):AddDropdown({ Default = o.Default, Values = names, Flag = o.Flag,
            Callback = o.Callback })
        local g = {}
        function g:setdata(rows)
            local list = {}
            for _, row in ipairs(rows or {}) do list[#list + 1] = row.name end
            pcall(function() dd:SetValues(list) end)
        end
        return g
    end
    W.Signal = { Connect = function() return { Disconnect = function() end } end }
    function W:SetVisible() end
    return W
end


------------------------------------------------------------------------ окно меню
local logo = "V"
pcall(function()
    if getcustomasset and isfile and isfile(CONFIG.LOGO) then logo = getcustomasset(CONFIG.LOGO) end
end)
print("[Визуалы] Запущена сборка " .. VISUALS_BUILD)
if HOST_WIN then
    win = HOST_WIN -- внутри newyear.lua: вкладки встают в его меню
else
    win = SBUI.new({
        Name = "SBVisualsMenu", Title = "Визуалы", Logo = logo, Key = CONFIG.MENU_KEY, FreeMouse = true,
        OpenerY = 0.55, Size = Vector2.new(720, 470), Background = "network",
    })
end
NeverLose.ScreenGui = win.Gui
NeverLose.AccentColor = nil

local tWorld = win:Tab({ Name = HOST_WIN and "Погода и свет" or "Мир", Desc = "погода, шейдеры, небо, свет", Icon = "@snow" })
local tChar = win:Tab({ Name = HOST_WIN and "Следы" or "Персонаж", Desc = "следы и круги", Icon = "@star" })
local tMusic = win:Tab({ Name = "Музыка", Desc = "плеер и Spotify", Icon = "♪" })
local tMenu = (not HOST_WIN) and win:Tab({ Name = "Меню", Desc = "клавиша, выгрузка", Icon = "@gear" }) or nil

local Sections = {
    Weather = wrapContainer(tWorld:Section({ Name = "погода", Side = "Left" })),
    Lighting = wrapContainer(tWorld:Section({ Name = "освещение", Side = "Left" })),
    Shaders = wrapContainer(tWorld:Section({ Name = "шейдеры", Side = "Right" })),
    Trail = wrapContainer(tChar:Section({ Name = "следы за персонажем", Side = "Left" })),
    Circles = wrapContainer(tChar:Section({ Name = "круги при прыжке и приземлении", Side = "Right" })),
    Music = wrapContainer(tMusic:Section({ Name = "плеер", Side = "Left" })),
    Spotify = wrapContainer(tMusic:Section({ Name = "spotify", Side = "Left" })),
    MusicHud = wrapContainer(tMusic:Section({ Name = "плашка «сейчас играет»", Side = "Right" })),
}
local Visuals = { Trails = Sections.Trail }
local ESP = {}


-- ====================================================================== weather
-- перенесено из Salad Visuals (weather), правки под DOORS и наше меню — в build-заметках
guard("weather", function()
	local SOFT = "rbxasset://textures/particles/smoke_main.dds";
	-- a clean round dot, no smoke haze: our own soft glow, which ships inside
	-- the script. The catalogue id used before (241876428) is a thin streak,
	-- so snow fell as tiny slashes at random angles - too thin to see at its
	-- size, and scratches when made bigger.
	local DOT = "particles/p_glow.png";

	-- an inject that died before finishing leaves its volume in workspace and
	-- nothing to clean it up: two of them means double snow at wrong settings
	for _, leftover in ipairs(workspace:GetChildren()) do
		local owner = leftover:GetAttribute(TAG);
		if owner and owner ~= INIT_GENERATION and leftover:FindFirstChildWhichIsA("ParticleEmitter") then
			leftover:Destroy();
		end;
	end;

	local TYPES = {
		Snow = {
			-- dots rather than the soft smoke puff: reads as snow instead of fog
			texture = DOT,
			color = Color3.fromRGB(226, 240, 255),
			lifetime = NumberRange.new(4, 6),
			speed = NumberRange.new(6, 12),
			acceleration = Vector3.new(2, -6, 1),
			spread = Vector2.new(35, 35),
			spin = NumberRange.new(-40, 40),
			size = 0.32,
			squash = 0,
			emission = 0.15,
			density = 2.2,
			transparency = { 0.1, 0.2 },
			fade = 0.8,
		},
		["Snow Soft"] = {
			-- the reference's own snow: soft smoke puffs, kept next to the dots
			color = Color3.fromRGB(150, 200, 255),
			lifetime = NumberRange.new(4, 6),
			speed = NumberRange.new(6, 12),
			acceleration = Vector3.new(2, -6, 1),
			spread = Vector2.new(35, 35),
			spin = NumberRange.new(-40, 40),
			size = 0.55,
			squash = 0,
			emission = 0.4,
			transparency = { 0.2, 0.3 },
			fade = 0.8,
		},
		Sakura = {
			color = Color3.fromRGB(255, 170, 210),
			lifetime = NumberRange.new(5, 7),
			speed = NumberRange.new(5, 10),
			acceleration = Vector3.new(4, -5, 2),
			spread = Vector2.new(40, 40),
			spin = NumberRange.new(-80, 80),
			size = 0.5,
			squash = 1.4,
			emission = 0.4,
			transparency = { 0.15, 0.25 },
			fade = 0.85,
		},
		Rain = {
			color = Color3.fromRGB(170, 200, 255),
			lifetime = NumberRange.new(1.1, 1.6),
			speed = NumberRange.new(70, 95),
			acceleration = Vector3.new(0, -40, 0),
			-- Rain falls straight down. Each streak stands upright and turns
			-- only about the world's vertical to face you (FacingCameraWorldUp),
			-- so it reads as a vertical line from any angle. VelocityParallel
			-- plus a sideways lean in the acceleration bent the streaks as the
			-- velocity turned, and its quad does not face the camera, so drops
			-- looked slanted, each at its own angle.
			spread = Vector2.new(1, 1),
			spin = NumberRange.new(0, 0),
			size = 0.5,
			squash = 6,
			emission = 0.35,
			density = 4.5,
			transparency = { 0.35, 0.45 },
			fade = 0.9,
			orientation = Enum.ParticleOrientation.FacingCameraWorldUp,
			rotation = NumberRange.new(0, 0),
		},
		Ash = {
			color = Color3.fromRGB(90, 90, 95),
			lifetime = NumberRange.new(6, 9),
			speed = NumberRange.new(3, 7),
			acceleration = Vector3.new(3, -3, 2),
			spread = Vector2.new(45, 45),
			spin = NumberRange.new(-25, 25),
			size = 0.32,
			squash = 0,
			emission = 0.1,
			transparency = { 0.25, 0.4 },
			fade = 0.85,
		},
		Fireflies = {
			color = Color3.fromRGB(255, 220, 120),
			lifetime = NumberRange.new(3, 5),
			speed = NumberRange.new(1, 3),
			acceleration = Vector3.new(0, 0.5, 0),
			spread = Vector2.new(180, 180),
			spin = NumberRange.new(-10, 10),
			size = 0.22,
			squash = 0,
			emission = 1,
			transparency = { 0.1, 0.1 },
			fade = 0.75,
		},
	};

	local W = {
		Kind = "Off",
		Rate = 250,
		Speed = 100,    -- percent of the type's own fall speed
		Size = 100,     -- percent of the type's own particle size
		Fade = 100,     -- percent of the type's own transparency
		Distance = 120, -- how wide the volume is, in studs
		Height = 90,    -- how tall it is, and how far above you it sits
		Color = TYPES.Snow.color,
		ThroughWalls = false,
	};

	local part, emitter, conn, lastPos, lastLook;

	-- Amount is a density, not a raw rate. The volume is a box as wide as
	-- Distance, so the same rate over a 260-stud box left three or four drops
	-- anywhere near the camera: rain and snow looked broken or absent. The
	-- rate now grows with the box's area (and a type's own thickness), so
	-- widening the box never thins it out. Capped for the particle budget.
	local function rateNow()
		local preset = TYPES[W.Kind];
		local area = (W.Distance / 120) ^ 2;
		return math.min(W.Rate * area * ((preset and preset.density) or 1), 4000);
	end;

	-- Color walks to the new one a fifth at a time. Runs in the frame loop
	-- rather than its own thread, which quietly stopped resuming and left the
	-- color stuck on the previous type.
	local colorNow, colorTarget = W.Color, W.Color;

	local function easeColour(target)
		colorTarget = target;
	end;

	local function stepColour()
		if not emitter then return end;

		local dr, dg, db = colorNow.R - colorTarget.R, colorNow.G - colorTarget.G, colorNow.B - colorTarget.B;

		if dr * dr + dg * dg + db * db < 0.00002 then
			if colorNow ~= colorTarget then
				colorNow = colorTarget;
				emitter.Color = ColorSequence.new(colorNow);
			end;

			return;
		end;

		colorNow = colorNow:Lerp(colorTarget, 0.09);
		emitter.Color = ColorSequence.new(colorNow);
	end;

	local function style()
		local preset = TYPES[W.Kind];
		if not (emitter and preset) then return end;

		local scale = W.Speed / 100;

		local texture = preset.texture;
		if texture and not texture:find("://", 1, true) then texture = Remote.asset(texture) end;
		emitter.Texture = texture or SOFT;
		emitter.LightInfluence = 0;
		emitter.LightEmission = preset.emission;
		Render.FxDepth(emitter, W.ThroughWalls);
		emitter.Drag = 0;
		emitter.EmissionDirection = Enum.NormalId.Bottom;
		emitter.Rate = rateNow();
		emitter.Color = ColorSequence.new(colorNow);
		-- Snow and ash should tumble; rain must not. This used to be a flat
		-- 0-360 for every type, which is why the drops pointed everywhere.
		emitter.Rotation = preset.rotation or NumberRange.new(0, 360);
		emitter.RotSpeed = preset.spin;
		emitter.SpreadAngle = preset.spread;

		pcall(function()
			emitter.Orientation = preset.orientation or Enum.ParticleOrientation.FacingCamera;
		end);

		emitter.Speed = NumberRange.new(preset.speed.Min * scale, preset.speed.Max * scale);
		emitter.Acceleration = (preset.acceleration + (preset.lean or Vector3.zero)) * scale;

		-- faster fall, shorter life, or the volume empties out below you
		emitter.Lifetime = NumberRange.new(preset.lifetime.Min / scale, preset.lifetime.Max / scale);
		emitter.Size = NumberSequence.new(preset.size * (W.Size / 100));

		pcall(function() emitter.Squash = NumberSequence.new(preset.squash) end);

		-- 100% keeps the type's own curve; higher values thin the particles out
		local ghost = W.Fade / 100;
		local head = math.clamp(1 - (1 - preset.transparency[1]) / ghost, 0, 1);
		local tail = math.clamp(1 - (1 - preset.transparency[2]) / ghost, 0, 1);

		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, head),
			NumberSequenceKeypoint.new(preset.fade, tail),
			NumberSequenceKeypoint.new(1, 1),
		});
	end;

	local function resize()
		if not part then return end;

		part.Size = Vector3.new(W.Distance, W.Height, W.Distance);
		if emitter then emitter.Rate = rateNow() end; -- a wider box needs more to stay as thick
		lastPos, lastLook = nil, nil; -- force one reposition
	end;

	local function stop()
		if conn then pcall(function() conn:Disconnect() end) conn = nil end;
		if part then pcall(function() part:Destroy() end) part = nil end;

		emitter, lastPos, lastLook = nil, nil, nil;
	end;

	local function ensurePart()
		if part and part.Parent then return end;

		part = Instance.new("Part");
		part.Name = NeverLose.RandomString();
		part.Anchored = true;
		part.CanCollide = false;
		part.CanQuery = false;
		part.CanTouch = false;
		part.CastShadow = false;
		part.Transparency = 1;
		part.Size = Vector3.new(W.Distance, W.Height, W.Distance);
		part:SetAttribute(TAG, INIT_GENERATION); -- so a crashed inject's volume can be found
		part.Parent = workspace;

		emitter = Instance.new("ParticleEmitter");

		pcall(function()
			emitter.Shape = Enum.ParticleEmitterShape.Box;
			emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume;
		end);

		emitter.Parent = part;

		style();
	end;

	local function burst()
		if not emitter then return end;

		emitter:Emit(math.clamp(math.floor(rateNow() * 0.2), 30, 600));
	end;

	local function start()
		ensurePart();

		if conn then return end;

		lastPos, lastLook = nil, nil;

		conn = NeverLose:AddSignal(RunService.RenderStepped:Connect(function()
			if not (part and part.Parent) then return end;

			stepColour();

			local camera = workspace.CurrentCamera;
			if not camera then return end;

			local cf = camera.CFrame;
			local at = cf.Position;
			local look = cf.LookVector;
			local flat = Vector3.new(look.X, 0, look.Z);

			if flat.Magnitude < 0.05 then
				flat = Vector3.new(0, 0, -1);
			else
				flat = flat.Unit;
			end;

			-- only reposition on real movement, not on every frame
			if lastPos and lastLook and (at - lastPos).Magnitude < 10 and flat:Dot(lastLook) > 0.95 then return end;

			lastPos, lastLook = at, flat;
			part.CFrame = CFrame.new(at + flat * (W.Distance * 0.22) + Vector3.new(0, W.Height * 0.5 - 26, 0));
		end));

		burst();
	end;

	ESP.Weather = W;
	ESP.ClearWeather = stop;

	local colorPicker;

	Sections.Weather:AddLabel("Type"):AddDropdown({
		Default = "Off",
		Values = { "Off", "Snow", "Snow Soft", "Sakura", "Rain", "Ash", "Fireflies" },
		Flag = "weather_kind",
		Callback = function(v)
			W.Kind = v;

			if v == "Off" then
				stop();
				return;
			end;

			-- each type has its own colour; Custom Color overrides it
			W.Color = TYPES[v].color;
			easeColour(W.Custom and W.Pick or W.Color);

			start();
			style();
			burst();
		end,
	});

	Sections.Weather:AddLabel("Amount"):AddSlider({
		Min = 20, Max = 800, Default = 250, Rounding = 0, Size = 100,
		Flag = "weather_rate",
		Callback = function(v)
			W.Rate = v;

			if emitter then emitter.Rate = rateNow() end;
		end,
	});

	Sections.Weather:AddLabel("Fall Speed"):AddSlider({
		Min = 10, Max = 400, Default = 100, Type = "%", Size = 100,
		Flag = "weather_speed",
		Callback = function(v) W.Speed = v; style() end,
	});

	Sections.Weather:AddLabel("Particle Size"):AddSlider({
		Min = 10, Max = 500, Default = 100, Type = "%", Size = 100,
		Flag = "weather_size",
		Callback = function(v) W.Size = v; style() end,
	});

	Sections.Weather:AddLabel("Transparency"):AddSlider({
		Min = 20, Max = 400, Default = 100, Type = "%", Size = 100,
		Flag = "weather_fade",
		Callback = function(v) W.Fade = v; style() end,
	});

	Sections.Weather:AddLabel("Distance"):AddSlider({
		Min = 60, Max = 600, Default = 120, Rounding = 0, Size = 100,
		Flag = "weather_distance",
		Callback = function(v) W.Distance = v; resize() end,
	});

	Sections.Weather:AddLabel("Height"):AddSlider({
		Min = 40, Max = 400, Default = 90, Rounding = 0, Size = 100,
		Flag = "weather_height",
		Callback = function(v) W.Height = v; resize() end,
	});

	local custom = Sections.Weather:AddLabel("Custom Color");
	custom:AddToggle({
		Default = false, Flag = "weather_custom",
		Callback = function(v)
			W.Custom = v;
			easeColour(v and W.Pick or W.Color);
		end,
	});
	colorPicker = custom:AddColorPicker({
		Default = W.Color,
		Flag = "weather_color",
		Callback = function(v)
			W.Pick = v;
			if W.Custom then easeColour(v) end;
		end,
	});

	Sections.Weather:AddButton({
		Name = "Burst",
		Callback = burst,
	});
end);

-- ------------------------------------------------------------ crosshair --
-- scriptnew.txt:6415-6800, line for line. Eight Drawing lines - odd indices
-- the arms, even the outline behind them - four angles, a gap, a rotation
-- speed, and the option to take over the cursor. Gun only, which is the
-- reference's rule and why its flag is called "sheriffcros".


-- ====================================================================== lighting
-- перенесено из Salad Visuals (lighting), правки под DOORS и наше меню — в build-заметках
guard("lighting", function()
	local Lighting = game:GetService("Lighting");

	local FB = { On = false };
	local TM = { On = false, Value = 12 };
	local AM = { On = false, Color = Color3.fromRGB(128,128,128) };
	local EX = { On = false, Value = 0 };
	local snapshots, written = {}, {};
	local function applyAll()
		local wanted = table.clone(ESP.ShaderLighting or {});
		-- Roblox darkens any skybox with the time of day. A night preset's
		-- clock turned a skybox the user picked into a black sky (Blue Hour
		-- over Aurora showed a green line at the horizon and nothing else);
		-- under their own skybox the preset keeps its light and colours but
		-- the clock stays in the day. A preset's own sky is left as designed,
		-- and Time Change below still wins.
		local sky = ESP.Sky;
		local clock = tonumber(wanted.ClockTime);
		if clock and (clock < 6.5 or clock > 17.25) and sky and sky.Box ~= "Off" and sky.Box ~= ESP.PresetSky then
			wanted.ClockTime = 14;
		end;
		if FB.On then
			wanted.Brightness, wanted.GlobalShadows = 2, false;
			wanted.OutdoorAmbient, wanted.ClockTime = Color3.fromRGB(128,128,128), 14;
		end;
		if AM.On then wanted.Ambient, wanted.OutdoorAmbient = AM.Color, AM.Color end;
		if TM.On then wanted.ClockTime = TM.Value end;
		if EX.On then wanted.ExposureCompensation = EX.Value end;
		for property, previous in pairs(written) do
			if wanted[property] == nil then
				if Lighting[property] == previous then Lighting[property] = snapshots[property] end;
				snapshots[property], written[property] = nil, nil;
			end;
		end;
		for property, value in pairs(wanted) do
			if written[property] == nil then snapshots[property] = Lighting[property]
			elseif Lighting[property] ~= written[property] then snapshots[property] = Lighting[property] end;
			if Lighting[property] ~= value then Lighting[property] = value end;
			written[property] = Lighting[property];
		end;
	end;
	local applyFullbright, applyAmbient, applyTime, applyExposure = applyAll, applyAll, applyAll, applyAll;
	ESP.RestoreLighting = function()
		ESP.ShaderLighting = nil;
		FB.On, TM.On, AM.On, EX.On = false, false, false, false;
		applyAll();
	end;

	ESP.Lighting = { FB = FB, Time = TM, Ambient = AM, Exposure = EX };
	ESP.ApplyLighting = applyAll;

	-- rounds reset most of Lighting, so nudge what is on; same cadence as fog
	task.spawn(function()
		while ALIVE do
			task.wait(1);
			if not ALIVE then break end;

			if NeverLose.ScreenGui.Parent then
				if ESP.ShaderLighting or FB.On or TM.On or AM.On or EX.On then
					pcall(applyAll);
				end;
			end;
		end;
	end);

	local fullbrightRow = Sections.Lighting:AddLabel("Fullbright");
	fullbrightRow:AddToggle({
		Default = false, Flag = "fullbright",
		Callback = function(v) FB.On = v; applyFullbright() end,
	});

	local timeRow = Sections.Lighting:AddLabel("Time Change");
	timeRow:AddToggle({
		Default = false, Flag = "time_change",
		Callback = function(v) TM.On = v; applyTime() end,
	});

	timeRow:AddOption(1):AddLabel("Time"):AddSlider({
		Min = 0, Max = 24, Default = 12, Rounding = 1, Size = 90,
		Flag = "time_value",
		Callback = function(v) TM.Value = v; applyTime() end,
	});

	local ambientRow = Sections.Lighting:AddLabel("Ambient");
	ambientRow:AddToggle({
		Default = false, Flag = "ambient",
		Callback = function(v) AM.On = v; applyAmbient() end,
	});
	ambientRow:AddColorPicker({
		Default = AM.Color, Flag = "ambient_color",
		Callback = function(v) AM.Color = v; applyAmbient() end,
	});

	local exposureRow = Sections.Lighting:AddLabel("Exposure");
	exposureRow:AddToggle({
		Default = false, Flag = "exposure",
		Callback = function(v) EX.On = v; applyExposure() end,
	});

	exposureRow:AddOption(1):AddLabel("Value"):AddSlider({
		Min = -5, Max = 5, Default = 0, Rounding = 2, Size = 90,
		Flag = "exposure_value",
		Callback = function(v) EX.Value = v; applyExposure() end,
	});
end);

-- --------------------------------------------------------------- aura ----
-- From the reference module (symbol-1.txt:13675): four auras of Attachments
-- and ParticleEmitters with its clearAll / updateColors / refreshAuras /
-- onCharacterAdded lifecycle.
--
-- What was here pulled eight finished models off the asset server and drove
-- the glow with a full-screen BloomEffect, which is why an aura washed out
-- the whole scene. The reference glows per emitter instead.
--
-- Emitters are children of Attachments on the character, so they die with
-- it and clearAll only drops the stale references.
-- ------------------------------------------------------------ game fx ----
-- Auras, trails and cosmetics taken from Nullscape and Evade, worn the way
-- each game puts them on. The catalogue (names, pictures) lives here; each
-- game's instance data is a hosted file fetched the first time one of its
-- effects is switched on, and runs with nothing but value constructors in
-- reach.
--
--   Nullscape: module parts cloned as Aura_<limb>/Trail_<limb> and welded on,
--   an Attachment aura as Torso.AuraAttachment, a Trail between two
--   attachments at +-Width.
--   Evade (RigService.AddCosmetics): a template rig per rig type whose limb
--   contents move into the real limbs, same-named attachments taking the
--   real one's place, welds re-pointed at the real limbs.


-- ====================================================================== shaders
-- перенесено из Salad Visuals (shaders), правки под DOORS и наше меню — в build-заметках
guard("shaders", function()
	local Lighting = game:GetService("Lighting");

	-- A round, and some maps on their own, clear Lighting. These four were
	-- built once and held in a local, so after that the bloom, rays, blur and
	-- grade were gone and only a re-inject brought them back. A destroyed
	-- instance still answers for its properties, so a replacement is copied
	-- off the old one and whatever the menu had set carries over.
	local bloom, rays, blur, grade;
	local keepers = {};

	local function effect(class, props, adopt)
		local inst;

		local function make(old)
			local fresh = Instance.new(class);

			fresh.Name = NeverLose.RandomString();
			fresh.Enabled = false;

			for key, value in pairs(props) do fresh[key] = value end;

			if old then
				for key in pairs(props) do
					pcall(function() fresh[key] = old[key] end);
				end;

				pcall(function() fresh.Enabled = old.Enabled end);
			end;

			fresh.Parent = Lighting;

			return fresh;
		end;

		inst = make(nil);

		keepers[#keepers + 1] = function()
			if inst.Parent ~= Lighting then
				inst = make(inst);

				adopt(inst);
			end;
		end;

		return inst;
	end;

	bloom = effect("BloomEffect", { Intensity = 0.6, Size = 24, Threshold = 0.9 },
		function(v) bloom = v end);
	rays = effect("SunRaysEffect", { Intensity = 0.15, Spread = 0.9 },
		function(v) rays = v end);
	blur = effect("BlurEffect", { Size = 8 },
		function(v) blur = v end);
	grade = effect("ColorCorrectionEffect", { Brightness = 0, Contrast = 0.1, Saturation = 0.2, TintColor = Color3.fromRGB(255, 255, 255) },
		function(v) grade = v end);

	task.spawn(function()
		while ALIVE do
			task.wait(1);

			if not ALIVE then break end;

			for _, keeper in ipairs(keepers) do pcall(keeper) end;
		end;
	end);
	-- Roblox honours exactly one Atmosphere. Parenting a second does nothing,
	-- which is why Atmosphere looked dead in any map that had its own, and why
	-- Fog used to unparent the map's to get legacy FogStart/FogEnd back.
	--
	-- One owner now: take over whatever the map has, remember its values, drive
	-- that. Fog and Atmosphere write the same instance because in this engine
	-- they are the same thing. If the map has none, one is created and owned.
	local AIR = {
		On = false, Density = 0.3, Haze = 0, Glare = 0,
		Color = Color3.fromRGB(199, 199, 199), Decay = Color3.fromRGB(106, 112, 125),
	};

	local airMine, airSaved;

	local function airInstance()
		local found = Lighting:FindFirstChildOfClass("Atmosphere");

		if not found then
			found = Instance.new("Atmosphere");
			found.Name = NeverLose.RandomString();
			found.Parent = Lighting;
			airMine = found;
		end;

		if not airSaved or airSaved.instance ~= found or not found.Parent then
			airSaved = {
				instance = found,
				Density = found.Density, Offset = found.Offset, Haze = found.Haze,
				Glare = found.Glare, Color = found.Color, Decay = found.Decay,
			};
		end;

		return found;
	end;

	-- both feature toggles land here; FOG is filled in further down
	local function applyAir()
		local fog = ESP.Fog;
		local fogOn = fog and fog.On;

        if not (AIR.On or fogOn) then
			-- nothing wants it: put the map's own values back, and remove
			-- the instance entirely if it was ours to begin with
			if airSaved and airSaved.instance and airSaved.instance.Parent then
				local a = airSaved.instance;

				pcall(function()
					a.Density = airSaved.Density;
					a.Offset = airSaved.Offset;
					a.Haze = airSaved.Haze;
					a.Glare = airSaved.Glare;
					a.Color = airSaved.Color;
					a.Decay = airSaved.Decay;
				end);
			end;

			if airMine then pcall(function() airMine:Destroy() end); airMine = nil; airSaved = nil end;

			return;
		end;

		local a = airInstance();

		if not a then return end;

		-- fog owns density and offset, atmosphere owns the scattering
		if fogOn then
			a.Density = math.clamp(fog.Density / 100, 0, 1);
			a.Offset = math.clamp(fog.Offset or 0, -1, 1);
			a.Color = fog.Color;
		elseif AIR.On then
			a.Density = math.clamp(AIR.Density, 0, 1);
			a.Offset = AIR.Offset or (airSaved and airSaved.Offset) or 0;
			a.Color = AIR.Color;
		end;

		if AIR.On then
			-- Haze and Glare are painted over the skybox itself. A preset's air
			-- is tuned for its own sky; under a skybox the user picked, Overcast
			-- or Misty Morning turned it into one flat colour. Depth fog
			-- (Density, Color) stays, the wash over the sky goes.
			local haze, glare = AIR.Haze, AIR.Glare;
			local sky = ESP.Sky;
			if ESP.ShaderLighting and sky and sky.Box ~= "Off" and sky.Box ~= ESP.PresetSky then
				haze, glare = math.min(haze, 0.35), 0;
			end;
			a.Haze = math.clamp(haze, 0, 10);
			a.Glare = math.clamp(glare, 0, 10);
			a.Decay = AIR.Decay;
		elseif airSaved then
			a.Haze = airSaved.Haze;
			a.Glare = airSaved.Glare;
			a.Decay = airSaved.Decay;
		end;
	end;

	ESP.ApplyAir = applyAir;
	ESP.Air = AIR;

	onUnload("atmosphere", function()
		AIR.On = false;

		if ESP.Fog then ESP.Fog.On = false end;

		pcall(applyAir);
	end);

	ESP.Shaders = setmetatable({}, {__index=function(_, key)
		if key == "bloom" then return bloom elseif key == "rays" then return rays elseif key == "blur" then return blur elseif key == "grade" then return grade end;
	end});

	ESP.ClearShaders = function()
		ESP.ShaderLighting = nil;
		if ESP.RestoreFog then pcall(ESP.RestoreFog) end;
		if ESP.RestoreLighting then pcall(ESP.RestoreLighting) end;

		-- the sky helper is defined further down, so go through the table
		if ESP.RestoreSky then pcall(ESP.RestoreSky) end;

		bloom:Destroy();
		rays:Destroy();
		blur:Destroy();
		grade:Destroy();

		-- The Atmosphere is usually the map's own, so it is restored rather than
		-- destroyed. ESP.Fog, not the FOG local - that is declared further down and
		-- would resolve to a nil global here.
		AIR.On = false;

		if ESP.Fog then ESP.Fog.On = false end;

		pcall(applyAir);
	end;

	-- ------------------------------------------------------- presets ----
	-- One row that sets every effect at once. The sliders below still work as
	-- the manual override afterwards.
	local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end;

	-- Each preset is one scene, not a filter: a time of day, the colour of the
	-- sun and of the shade, air that matches them, a grade that finishes it,
	-- and where one fits, a sky. The playable ones keep bloom on what is
	-- already near white and never blur.
	local PRESETS = {
		-- the map as it is, finished: real distance haze, soft shadows,
		-- materials allowed to reflect
		Natural = {
			bloom = { on = true, intensity = 0.2, size = 20, threshold = 1.2 },
			rays = { on = true, intensity = 0.05 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.01, contrast = 0.08, saturation = 0.08, tint = rgb(255, 253, 250) },
			air = { on = true, density = 0.26, offset = 0.08, haze = 0.6, glare = 0, color = rgb(198, 214, 232), decay = rgb(104, 112, 124) },
			lighting = { EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1, ShadowSoftness = 0.2 },
		},
		-- nothing hides anyone: the map's own fog and haze cleared, even light,
		-- no black shadows, no glow
		Competitive = {
			bloom = { on = false, intensity = 0, size = 18, threshold = 1.3 },
			rays = { on = false, intensity = 0 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.03, contrast = 0.1, saturation = 0.12, tint = rgb(255, 255, 255) },
			air = { on = true, density = 0, offset = 0, haze = 0, glare = 0, color = rgb(199, 199, 199) },
			lighting = { ClockTime = 13, Brightness = 2.2, GlobalShadows = false, ExposureCompensation = 0.05,
				Ambient = rgb(135, 135, 138), OutdoorAmbient = rgb(150, 150, 154), FogStart = 100000, FogEnd = 100000 },
		},
		-- high sun, warm light, a clean blue distance
		Summer = {
			bloom = { on = true, intensity = 0.3, size = 22, threshold = 1.15 },
			rays = { on = true, intensity = 0.08 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.02, contrast = 0.12, saturation = 0.2, tint = rgb(255, 250, 240) },
			air = { on = true, density = 0.22, offset = 0.1, haze = 0.4, glare = 0, color = rgb(205, 222, 240), decay = rgb(110, 120, 135) },
			lighting = { ClockTime = 13.5, Brightness = 3, ExposureCompensation = 0, GlobalShadows = true, ShadowSoftness = 0.15,
				Ambient = rgb(115, 112, 108), OutdoorAmbient = rgb(140, 138, 132), ColorShift_Top = rgb(255, 238, 214) },
			sky = "Sunny Sky",
		},
		-- the last hour of sun: long amber light, glare off the horizon
		["Golden Hour"] = {
			bloom = { on = true, intensity = 0.5, size = 26, threshold = 1 },
			rays = { on = true, intensity = 0.14 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.02, contrast = 0.14, saturation = 0.18, tint = rgb(255, 230, 204) },
			air = { on = true, density = 0.28, offset = 0.12, haze = 1.4, glare = 1.2, color = rgb(255, 202, 164), decay = rgb(182, 112, 92) },
			lighting = { ClockTime = 17.6, Brightness = 2.4, ExposureCompensation = 0.2, GlobalShadows = true, ShadowSoftness = 0.3,
				Ambient = rgb(120, 100, 92), OutdoorAmbient = rgb(150, 122, 108), ColorShift_Top = rgb(255, 184, 120) },
			sky = "SettingSunSky",
		},
		-- just after sunset: violet air, lamps starting to glow
		["Blue Hour"] = {
			bloom = { on = true, intensity = 0.45, size = 26, threshold = 1 },
			rays = { on = false, intensity = 0 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.03, contrast = 0.12, saturation = 0.1, tint = rgb(232, 226, 255) },
			air = { on = true, density = 0.3, offset = 0.1, haze = 1.2, glare = 0.3, color = rgb(150, 140, 192), decay = rgb(92, 80, 132) },
			lighting = { ClockTime = 18.5, Brightness = 1.4, ExposureCompensation = 0.35, GlobalShadows = true,
				Ambient = rgb(104, 100, 136), OutdoorAmbient = rgb(124, 116, 160), ColorShift_Top = rgb(206, 158, 255) },
			sky = "sky_sunset",
		},
		-- a night you can play in: dark from the colour, not from crushed
		-- shadows
		Moonlight = {
			bloom = { on = true, intensity = 0.45, size = 24, threshold = 0.95 },
			rays = { on = false, intensity = 0 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.02, contrast = 0.14, saturation = -0.1, tint = rgb(222, 231, 255) },
			air = { on = true, density = 0.2, offset = 0, haze = 0.3, glare = 0, color = rgb(92, 106, 142), decay = rgb(60, 70, 102) },
			lighting = { ClockTime = 0, Brightness = 1.2, ExposureCompensation = 0.35, GlobalShadows = true,
				Ambient = rgb(84, 94, 122), OutdoorAmbient = rgb(102, 114, 146), ColorShift_Top = rgb(172, 192, 255) },
			sky = "Goodnight",
		},
		-- cloud cover: soft light from everywhere, muted colour
		Overcast = {
			bloom = { on = false, intensity = 0, size = 18, threshold = 1.3 },
			rays = { on = false, intensity = 0 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.01, contrast = 0.05, saturation = -0.08, tint = rgb(242, 246, 255) },
			air = { on = true, density = 0.35, offset = 0.05, haze = 2, glare = 0, color = rgb(196, 201, 209), decay = rgb(150, 156, 166) },
			lighting = { ClockTime = 12, Brightness = 1.5, GlobalShadows = true, ShadowSoftness = 1,
				Ambient = rgb(128, 130, 136), OutdoorAmbient = rgb(152, 154, 160), ColorShift_Top = rgb(222, 226, 236) },
			sky = "Overcast",
		},
		-- low pink sun through a mist that lies on the ground
		["Misty Morning"] = {
			bloom = { on = true, intensity = 0.35, size = 28, threshold = 1.05 },
			rays = { on = true, intensity = 0.12 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.02, contrast = 0.05, saturation = 0.05, tint = rgb(255, 244, 238) },
			air = { on = true, density = 0.38, offset = 0.25, haze = 2.5, glare = 0.5, color = rgb(222, 214, 210), decay = rgb(204, 172, 160) },
			lighting = { ClockTime = 7, Brightness = 2, ExposureCompensation = 0.15, GlobalShadows = true, ShadowSoftness = 0.4,
				Ambient = rgb(118, 112, 112), OutdoorAmbient = rgb(146, 138, 138), ColorShift_Top = rgb(255, 214, 190) },
			sky = "Pink Sunrise",
		},
		-- for clips: warm light against cool shade, deeper contrast; keeps the
		-- map's own time and sky
		Cinematic = {
			bloom = { on = true, intensity = 0.4, size = 26, threshold = 1 },
			rays = { on = true, intensity = 0.08 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0, contrast = 0.22, saturation = 0.1, tint = rgb(244, 236, 226) },
			air = { on = true, density = 0.25, offset = 0.1, haze = 0.8, glare = 0.2, color = rgb(178, 198, 214), decay = rgb(112, 120, 134) },
			lighting = { ExposureCompensation = 0.05, Ambient = rgb(96, 108, 122), OutdoorAmbient = rgb(110, 126, 142),
				ColorShift_Top = rgb(255, 226, 192) },
		},
		-- late night under an aurora: everything lit glows
		["Neon Night"] = {
			bloom = { on = true, intensity = 1, size = 32, threshold = 0.8 },
			rays = { on = false, intensity = 0 },
			blur = { on = false, size = 0 },
			grade = { on = true, brightness = 0.02, contrast = 0.18, saturation = 0.35, tint = rgb(246, 236, 255) },
			air = { on = true, density = 0.26, offset = 0.05, haze = 0.6, glare = 0, color = rgb(82, 62, 122), decay = rgb(142, 62, 162) },
			lighting = { ClockTime = 22, Brightness = 0.8, ExposureCompensation = 0.25, GlobalShadows = true,
				Ambient = rgb(68, 60, 98), OutdoorAmbient = rgb(80, 68, 120), ColorShift_Top = rgb(200, 140, 255) },
			sky = "NeonSky2",
		},
	};
	local PRESET_ORDER = { "Off", "Natural", "Competitive", "Summer", "Golden Hour", "Blue Hour", "Moonlight",
		"Overcast", "Misty Morning", "Cinematic", "Neon Night" };

	-- configs saved with the old set still land on their nearest scene
	local RENAMED = { Day = "Summer", Night = "Moonlight", Night2 = "Moonlight", Sunset = "Golden Hour",
		Noir = "Cinematic", Vibrant = "Summer", Dream = "Misty Morning", Horror = "Overcast" };

	ESP.ShaderPresets = PRESETS;
	local function syncShaderFlags(flags)
		local lib = NeverLose.Lib;
		local quiet, applying = lib.quiet, lib.configApplying;
		lib.quiet, lib.configApplying = true, true;
		local ok, err = pcall(function()
			for id, value in pairs(flags) do local entry = lib.pool[id]; if entry then entry.set(value) end end;
		end);
		lib.quiet, lib.configApplying = quiet, applying;
		if not ok then recordError("shader preset: " .. tostring(err)) end;
	end;

	-- A preset's sky goes into the Skybox row like a pick of its own, but only
	-- into an empty sky or in place of the previous preset's. A skybox the user
	-- picked stays put - presets used to swap it out from under them.
	local presetSky;
	local function presetSkyTo(file)
		local label = file and ESP.SkyLabel and ESP.SkyLabel(file);
		local box = ESP.Sky and ESP.Sky.Box or "Off";
		-- box == label: the preset's own sky already up (a config restores both)
		if box ~= "Off" and box ~= presetSky and box ~= label then
			presetSky = nil;
			ESP.PresetSky = nil;
		elseif label then
			presetSky = label;
			ESP.PresetSky = label;
			if box ~= label then ESP.SetSkyBox(label); syncShaderFlags({ sky_box = label }) end;
		elseif presetSky then
			presetSky = nil;
			ESP.PresetSky = nil;
			ESP.SetSkyBox("Off");
			syncShaderFlags({ sky_box = "Off" });
		end;
	end;

	local function applyPreset(name)
		local preset = PRESETS[name];
		if not preset then return end;
		ESP.ShaderLighting = preset.lighting;
		if ESP.ApplyLighting then ESP.ApplyLighting() end;

		bloom.Enabled = preset.bloom.on;
		bloom.Intensity = preset.bloom.intensity;
		bloom.Size = preset.bloom.size;
		bloom.Threshold = preset.bloom.threshold;

		rays.Enabled = preset.rays.on;
		rays.Intensity = preset.rays.intensity;

		blur.Enabled = preset.blur.on;
		blur.Size = preset.blur.size;

		grade.Enabled = preset.grade.on;
		grade.Brightness = preset.grade.brightness;
		grade.Contrast = preset.grade.contrast;
		grade.Saturation = preset.grade.saturation;
		grade.TintColor = preset.grade.tint;

		AIR.Density = preset.air.density;
		AIR.Haze = preset.air.haze;
		AIR.Color = preset.air.color;
		AIR.Glare = preset.air.glare or 0;
		AIR.Decay = preset.air.decay or rgb(106, 112, 125);
		AIR.Offset = preset.air.offset;
		AIR.On = preset.air.on;

		-- the sky first: whose sky ends up showing decides how much haze it gets
		presetSkyTo(preset.sky);
		applyAir();
		syncShaderFlags({
			shader_bloom=preset.bloom.on, shader_bloom_intensity=preset.bloom.intensity*100, shader_bloom_size=preset.bloom.size, shader_bloom_threshold=preset.bloom.threshold*100,
			shader_rays=preset.rays.on, shader_rays_intensity=preset.rays.intensity*100, shader_blur=preset.blur.on, shader_blur_size=preset.blur.size,
			shader_grade=preset.grade.on, shader_grade_brightness=preset.grade.brightness*100, shader_grade_contrast=preset.grade.contrast*100,
			shader_grade_saturation=preset.grade.saturation*100, shader_grade_tint=preset.grade.tint,
			shader_atmosphere=preset.air.on, shader_atmosphere_density=preset.air.density*100, shader_atmosphere_haze=preset.air.haze*10, shader_atmosphere_color=preset.air.color,
		});
	end;

	ESP.ApplyShaderPreset = applyPreset;

	Sections.Shaders:AddLabel("Preset"):AddDropdown({
		Default = "Off",
		Values = PRESET_ORDER,
		Flag = "shader_preset",
		Callback = function(v)
			if RENAMED[v] then v = RENAMED[v]; syncShaderFlags({ shader_preset = v }) end;
			if v == "Off" then
				ESP.ShaderLighting = nil;
				if ESP.ApplyLighting then ESP.ApplyLighting() end;
				syncShaderFlags({shader_bloom=false, shader_rays=false, shader_blur=false, shader_grade=false, shader_atmosphere=false});
				bloom.Enabled = false;
				rays.Enabled = false;
				blur.Enabled = false;
				grade.Enabled = false;
				AIR.On = false;
				AIR.Glare, AIR.Decay, AIR.Offset = 0, rgb(106, 112, 125), nil;

				applyAir();
				presetSkyTo(nil);

				-- A preset overwrites the grade the sliders also drive. Putting the user's
				-- values back is what makes preset -> Off -> grade land where they left it.
				if ESP.ApplyGrade then pcall(ESP.ApplyGrade) end;

				return;
			end;

			applyPreset(v);
		end,
	});

	-- ----------------------------------------------------------- sky ----
	-- Five built from their six faces, three pulled whole out of the catalogue.
	-- The map's Sky is detached, never edited, and put back on Off or unload.
	-- Cloning it was the old mistake - a map with no Sky got a bare default one.
	local SKYBOXES = {
		Jungle = {
			SkyboxBk = "rbxassetid://214399891", SkyboxDn = "rbxassetid://214399887",
			SkyboxFt = "rbxassetid://214399894", SkyboxLf = "rbxassetid://214405668",
			SkyboxRt = "rbxassetid://214399899", SkyboxUp = "rbxassetid://214399889",
		},
		Blossom = {
			SkyboxBk = "rbxassetid://271042516", SkyboxDn = "rbxassetid://271077243",
			SkyboxFt = "rbxassetid://271042556", SkyboxLf = "rbxassetid://271042310",
			SkyboxRt = "rbxassetid://271042467", SkyboxUp = "rbxassetid://271077958",
		},
		["Red Night"] = {
			SkyboxBk = "rbxassetid://401664839", SkyboxDn = "rbxassetid://401664862",
			SkyboxFt = "rbxassetid://401664960", SkyboxLf = "rbxassetid://401664881",
			SkyboxRt = "rbxassetid://401664901", SkyboxUp = "rbxassetid://401664936",
		},
		Purple = {
			SkyboxBk = "rbxassetid://13694952867", SkyboxDn = "rbxassetid://13694968325",
			SkyboxFt = "rbxassetid://13694980654", SkyboxLf = "rbxassetid://13694998113",
			SkyboxRt = "rbxassetid://13695002700", SkyboxUp = "rbxassetid://13695007103",
		},
	};

	local SKY_ASSETS = { Galaxy = 15983996673 };

	local SKY_ORDER = { "Off", "Jungle", "Blossom", "Red Night", "Purple", "Galaxy" };

	-- Six files per sky, <sky>_<face>.png, flat in one folder. This executor's
	-- getcustomasset keys its cache by file name alone, so six folders each
	-- holding an "up.png" all came back as the same texture.
	local SKY_FACES = { up = "SkyboxUp", dn = "SkyboxDn", lf = "SkyboxLf", rt = "SkyboxRt", ft = "SkyboxFt", bk = "SkyboxBk" };
	local function prettySkyName(value)
		local text = tostring(value or ""):gsub("[_%-]+", " "):gsub("(%l)(%u)", "%1 %2")
		text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
		return (text:gsub("(%a)([%w']*)", function(first, rest)
			return first:upper() .. rest:lower()
		end))
	end;

	-- A sky is six 1024 images. Sixty-four of them up front is 38MB for a list
	-- you mostly scroll past, so the catalogue comes from the manifest and the
	-- faces are fetched when one is chosen.
	local function resolveSky(entry)
		if entry.__ready then return entry.__ready end;

		local faces = {};

		for face, property in pairs(SKY_FACES) do
			local rel = entry.files[face];

			if not rel then return nil end;

			local url = Remote.asset(rel);

			if not url then return nil end;

			faces[property] = url;
		end;

		entry.__ready = faces;

		return faces;
	end;

	ESP.ResolveSky = resolveSky;

	if isfile and getcustomasset then
		local groups = {};

		-- the store is flat and hashed, so the manifest is the only place
		-- the real names still exist
		for _, rel in ipairs(Remote.under("skyboxes/")) do
			local file = string.match(rel, "([^/]+)$");
			local name, face = string.match(file or "", "^(.+)_(%a%a)%.[jp][pn]g$");

			if name and SKY_FACES[face] then
				groups[name] = groups[name] or {};
				groups[name][face] = rel;
			end;
		end;

		-- plus everything the host says exists but has not been fetched yet
		local manifest = Remote.manifest or (Remote.base ~= "" and Remote.load()) or nil;

		if manifest and type(manifest.skyboxes) == "table" then
			for name, faces in pairs(manifest.skyboxes) do
				groups[name] = groups[name] or {};

				for _, face in ipairs(faces) do
					if SKY_FACES[face] and not groups[name][face] then
						groups[name][face] = "skyboxes/" .. name .. "_" .. face .. ".jpg";
					end;
				end;
			end;
		end;

		for name in pairs(groups) do
			if string.lower(name):match("cloudy") or string.lower(name):match("foggy") then
				groups[name] = nil;
			end;
		end;

		local names = {};
		for name in pairs(groups) do names[#names + 1] = name end;
		table.sort(names);

		for _, name in ipairs(names) do
			local complete = true;

			-- all six faces have to be accounted for, on disk or on the host
			for face in pairs(SKY_FACES) do
				if not groups[name][face] then complete = false end;
			end;

			if complete then
				-- Normalize filenames such as "sky_universe" into labels that fit
				-- the dropdown while keeping the source asset name unchanged.
				local pretty = prettySkyName(name);
				if SKYBOXES[pretty] or SKY_ASSETS[pretty] or pretty == "Off" then pretty = pretty .. " (Local)" end;
				if SKYBOXES[pretty] then pretty = pretty .. " [" .. name .. "]" end;

				-- a descriptor, not urls: resolveSky fetches and converts the
				-- six faces the first time this sky is actually applied
				SKYBOXES[pretty] = { __sky = name, files = groups[name] };
				SKY_ORDER[#SKY_ORDER + 1] = pretty;
			end;
		end;
	end;

	table.sort(SKY_ORDER, function(a, b)
		if a == "Off" then return b ~= "Off" end;
		if b == "Off" then return false end;
		return a:lower() < b:lower();
	end);

	local SK = { Box = "Off", Body = "Default", Size = 21, Stars = 3000 };

	local mapSky, mapSkyParent, ourSky;
	local skyGeneration=0;

	-- This was a weak table. Nothing else holds the map's Sky once applyBody
	-- returns, so the entry was collected and unload had nothing to restore
	-- from - one pick of Moon left the sun swapped for the session.
	local originals={};
	local bodyProperties={"StarCount","CelestialBodiesShown","SunAngularSize","MoonAngularSize","SunTextureId","MoonTextureId"};
	local function rememberBody(sky)
		if not sky or originals[sky] then return end;
		local values={}; for _,property in ipairs(bodyProperties) do values[property]=sky[property] end;
		originals[sky]=values;
	end;
	local function restoreBody(sky)
		if sky and originals[sky] then
			for property,value in pairs(originals[sky]) do pcall(function() sky[property]=value end) end;
		end;
	end;
	local function forgetBody(sky)
		if sky then originals[sky]=nil end;
	end;

	local function detachMap()
		if mapSky then return end;

		local existing = Lighting:FindFirstChildOfClass("Sky");

		if existing and existing ~= ourSky then
			mapSky, mapSkyParent = existing, existing.Parent;
			pcall(function() existing.Parent = nil end);
		end;
	end;

	local function dropOurs()
		if ourSky then
			forgetBody(ourSky);
			pcall(function() ourSky:Destroy() end);
			ourSky = nil;
		end;
	end;

	local function restoreSky()
		skyGeneration=skyGeneration+1;
		for sky in pairs(originals) do restoreBody(sky) end;
		table.clear(originals);
		dropOurs();

		if mapSky then
			pcall(function() mapSky.Parent = mapSkyParent or Lighting end);
			mapSky, mapSkyParent = nil, nil;
		end;
	end;

	-- the body settings apply to whichever sky is up right now
	local bodySky;

	local function applyBody()
		local sky = ourSky or Lighting:FindFirstChildOfClass("Sky");

		-- No Sky child means the place is on the engine default and every one of
		-- these properties lives on a Sky, so the feature did nothing there. One is
		-- created and owned, same as the Atmosphere, and removed on Default.
		if not sky and SK.Body ~= "Default" then
			sky = Instance.new("Sky");
			sky.Name = NeverLose.RandomString();
			sky.Parent = Lighting;
			bodySky = sky;
		end;

		if not sky then return end;

		if bodySky and sky == bodySky and SK.Body == "Default" then
			forgetBody(bodySky);
			pcall(function() bodySky:Destroy() end);

			bodySky = nil;

			return;
		end;

		rememberBody(sky); restoreBody(sky);

		sky.StarCount = SK.Stars;

		if SK.Body == "Default" then
			sky.CelestialBodiesShown = true;
			return;
		end;

		sky.CelestialBodiesShown = SK.Body ~= "None";

		if SK.Body == "Sun" then
			sky.SunAngularSize = SK.Size;
			sky.MoonAngularSize = 0;
		elseif SK.Body == "Moon" then
			sky.SunAngularSize = 0;
			sky.MoonAngularSize = SK.Size;
		elseif SK.Body == "Eclipse" then
			sky.SunTextureId = "rbxasset://sky/moon.jpg";
			sky.SunAngularSize = SK.Size;
			sky.MoonAngularSize = 0;
		else
			sky.SunAngularSize = 0;
			sky.MoonAngularSize = 0;
		end;
	end;

	-- restoreSky is also reachable by name, but the registry is what guarantees
	-- it runs: a throw later in this guard used to leave the sky modified.
	onUnload("celestial", function()
		if bodySky then forgetBody(bodySky); pcall(function() bodySky:Destroy() end); bodySky = nil end;

		for sky in pairs(originals) do restoreBody(sky) end;

		table.clear(originals);
	end);

	local function applyFaces(faces)
		detachMap();
		dropOurs();

		local sky = Instance.new("Sky");
		sky.Name = NeverLose.RandomString();

		for property, value in pairs(faces) do
			pcall(function() sky[property] = value end);
		end;

		sky.Parent = Lighting;
		ourSky = sky;

		applyBody();
	end;

	-- a catalogue skybox arrives as a model, so it is fetched off the thread
	local function applyAsset(id)
		local picked, epoch = SK.Box, skyGeneration;

		task.spawn(function()
			local ok, objects = Remote.objects(function() return game:GetObjects("rbxassetid://" .. id) end);
			if not ok or type(objects) ~= "table" then return end;

			local found;

			for _, object in ipairs(objects) do
				if object:IsA("Sky") then
					found = object;
					break;
				end;

				local nested = object:FindFirstChildWhichIsA("Sky", true);

				if nested then
					found = nested;
					break;
				end;
			end;

			if not found or not ALIVE or SK.Box ~= picked or skyGeneration ~= epoch then
				for _, object in ipairs(objects) do object:Destroy() end;
				return;
			end;

			detachMap();
			dropOurs();

			found.Name = NeverLose.RandomString();
			found.Parent = Lighting;
			ourSky = found;
			for _, object in ipairs(objects) do if object ~= found then object:Destroy() end end;
			applyBody();
		end);
	end;

	local function applySky()
		skyGeneration=skyGeneration+1;
		-- a different sky can change how much of the preset's haze it takes,
		-- and whether its night clock applies
		pcall(applyAir);
		if ESP.ApplyLighting then pcall(ESP.ApplyLighting) end;
		if SK.Box == "Off" then
			restoreSky();
			return;
		end;

		if SKYBOXES[SK.Box] then
			local entry = SKYBOXES[SK.Box];

			-- a descriptor until the six faces have been fetched; a plain
			-- table of urls once they have
			if entry.files then
				local picked = SK.Box;
				local generation = skyGeneration;

				task.spawn(function()
					local faces = resolveSky(entry);

					-- the user may have picked something else while it
					-- downloaded, so only apply if this is still the choice
					if faces and ALIVE and generation == skyGeneration and SK.Box == picked then applyFaces(faces) end;
				end);
			else
				applyFaces(entry);
			end;
		elseif SKY_ASSETS[SK.Box] then
			applyAsset(SKY_ASSETS[SK.Box]);
		end;
	end;

	ESP.Sky = SK;
	ESP.RestoreSky = restoreSky;

	-- presets name a sky by its file; the row shows a prettier label
	function ESP.SkyLabel(file)
		for label, entry in pairs(SKYBOXES) do
			if type(entry) == "table" and entry.__sky == file then return label end;
		end;
	end;
	function ESP.SetSkyBox(label)
		SK.Box = label;
		applySky();
	end;

	Sections.Shaders:AddLabel("Skybox"):AddDropdown({
		Default = "Off",
		Values = SKY_ORDER,
		Flag = "sky_box",
		Callback = function(v) SK.Box = v; applySky() end,
	});

	local bodyRow = Sections.Shaders:AddLabel("Sun / Moon");
	bodyRow:AddDropdown({
		Default = "Default",
		Values = { "Default", "Sun", "Moon", "Eclipse", "None" },
		Flag = "sky_body",
		Callback = function(v) SK.Body = v; applyBody() end,
	});

	local bodyOptions = bodyRow:AddOption(1);

	bodyOptions:AddLabel("Size"):AddSlider({
		Min = 0, Max = 60, Default = 21, Rounding = 0, Size = 90,
		Flag = "sky_size",
		Callback = function(v) SK.Size = v; applyBody() end,
	});

	bodyOptions:AddLabel("Stars"):AddSlider({
		Min = 0, Max = 12000, Default = 3000, Rounding = 0, Size = 90,
		Flag = "sky_stars",
		Callback = function(v) SK.Stars = v; applyBody() end,
	});

	-- ----------------------------------------------------------- fog ----
	-- Fog as atmosphere, not Lighting.FogStart/FogEnd.
	--
	-- The legacy properties are ignored outright wherever an Atmosphere exists,
	-- and this game has one. The old code unparented the map's so legacy fog
	-- would draw again - that is the flat sheet on the floor with no depth.
	-- Density and Offset sit in the air and thicken with distance.
	local FOG = { On = false, Color = Color3.fromRGB(192, 192, 192), Density = 35, Offset = 0 };

	ESP.Fog = FOG;

	local function applyFog() applyAir() end;

	ESP.ApplyFog = applyFog;
	ESP.RestoreFog = function() FOG.On = false; applyAir() end;

	-- the map resets Lighting on round changes, so whatever is on gets
	-- nudged back once a second rather than per frame
	local elapsed = 0;

	NeverLose:AddSignal(RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt;

		if elapsed < 1 or not ALIVE then return end;

		elapsed = 0;

		if not (FOG.On or AIR.On) then return end;

		local live = Lighting:FindFirstChildOfClass("Atmosphere");

		if not live then applyAir(); return end;

		local wantDensity = FOG.On and math.clamp(FOG.Density / 100, 0, 1) or AIR.Density;

		if math.abs(live.Density - wantDensity) > 0.01 then applyAir() end;
	end));

	local fogRow = Sections.Shaders:AddLabel("Fog");

	fogRow:AddToggle({
		Default = false, Flag = "fog",
		Callback = function(v) FOG.On = v; applyAir() end,
	});

	fogRow:AddColorPicker({
		Default = FOG.Color, Flag = "fog_color",
		Callback = function(v) FOG.Color = v; applyAir() end,
	});

	local fogOptions = fogRow:AddOption(1);

	fogOptions:AddLabel("Density"):AddSlider({
		Min = 0, Max = 100, Default = 35, Rounding = 0, Size = 90,
		Flag = "fog_density",
		Callback = function(v) FOG.Density = v; applyAir() end,
	});

	-- pushes the fog up or down relative to the camera, which is how you
	-- get it hanging in the air rather than pooled at ground level
	fogOptions:AddLabel("Height"):AddSlider({
		Min = -100, Max = 100, Default = 0, Rounding = 0, Size = 90,
		Flag = "fog_offset",
		Callback = function(v) FOG.Offset = v / 100; applyAir() end,
	});

	local bloomRow = Sections.Shaders:AddLabel("Bloom");
	bloomRow:AddToggle({ Default = false, Flag = "shader_bloom", Callback = function(v) bloom.Enabled = v end });

	local bloomOptions = bloomRow:AddOption(1);

	bloomOptions:AddLabel("Intensity"):AddSlider({
		Min = 0, Max = 200, Default = 60, Rounding = 0, Size = 90,
		Flag = "shader_bloom_intensity",
		Callback = function(v) bloom.Intensity = v / 100 end,
	});

	bloomOptions:AddLabel("Size"):AddSlider({
		Min = 1, Max = 56, Default = 24, Rounding = 0, Size = 90,
		Flag = "shader_bloom_size",
		Callback = function(v) bloom.Size = v end,
	});

	bloomOptions:AddLabel("Threshold"):AddSlider({
		Min = 0, Max = 200, Default = 90, Rounding = 0, Size = 90,
		Flag = "shader_bloom_threshold",
		Callback = function(v) bloom.Threshold = v / 100 end,
	});

	local raysRow = Sections.Shaders:AddLabel("Sun Rays");
	raysRow:AddToggle({ Default = false, Flag = "shader_rays", Callback = function(v) rays.Enabled = v end });
	raysRow:AddOption(1):AddLabel("Intensity"):AddSlider({
		Min = 0, Max = 100, Default = 15, Rounding = 0, Size = 90,
		Flag = "shader_rays_intensity",
		Callback = function(v) rays.Intensity = v / 100 end,
	});

	local blurRow = Sections.Shaders:AddLabel("Blur");
	blurRow:AddToggle({ Default = false, Flag = "shader_blur", Callback = function(v) blur.Enabled = v end });
	blurRow:AddSlider({
		Min = 1, Max = 40, Default = 8, Rounding = 0, Size = 90,
		Flag = "shader_blur_size",
		Callback = function(v) blur.Size = v end,
	});

	-- The preset dropdown writes the same ColorCorrectionEffect, so without
	-- somewhere of its own a preset ate whatever you had dialled in and Off
	-- left the preset's numbers behind. GRADE is your copy; the effect is only
	-- ever painted from it.
	local GRADE = {
		On = false,
		Tint = Color3.fromRGB(255, 255, 255),
		Saturation = 0.2,
		Contrast = 0.1,
		Brightness = 0,
	};

	local function paintGrade()
		grade.Enabled = GRADE.On;
		grade.TintColor = GRADE.Tint;
		grade.Saturation = GRADE.Saturation;
		grade.Contrast = GRADE.Contrast;
		grade.Brightness = GRADE.Brightness;
	end;

	-- Reached by the preset's Off branch. On/off cycles are idempotent because
	-- they always restore from GRADE, never from the effect. An apply, not a
	-- teardown, which is why it is not named Restore*.
	ESP.ApplyGrade = paintGrade;

	local gradeRow = Sections.Shaders:AddLabel("Color Grade");
	gradeRow:AddToggle({ Default = false, Flag = "shader_grade", Callback = function(v) GRADE.On = v; paintGrade() end });
	gradeRow:AddColorPicker({
		Default = Color3.fromRGB(255, 255, 255), Flag = "shader_grade_tint",
		Callback = function(v) GRADE.Tint = v; paintGrade() end,
	});

	local gradeOptions = gradeRow:AddOption(1);

	gradeOptions:AddLabel("Saturation"):AddSlider({
		Min = -100, Max = 200, Default = 20, Rounding = 0, Size = 90,
		Flag = "shader_grade_saturation",
		Callback = function(v) GRADE.Saturation = v / 100; paintGrade() end,
	});

	gradeOptions:AddLabel("Contrast"):AddSlider({
		Min = -100, Max = 200, Default = 10, Rounding = 0, Size = 90,
		Flag = "shader_grade_contrast",
		Callback = function(v) GRADE.Contrast = v / 100; paintGrade() end,
	});

	gradeOptions:AddLabel("Brightness"):AddSlider({
		Min = -100, Max = 100, Default = 0, Rounding = 0, Size = 90,
		Flag = "shader_grade_brightness",
		Callback = function(v) GRADE.Brightness = v / 100; paintGrade() end,
	});

	local airRow = Sections.Shaders:AddLabel("Atmosphere");
	airRow:AddToggle({
		Default = false, Flag = "shader_atmosphere",
		Callback = function(v)
			AIR.On = v;

			applyAir();
		end,
	});
	airRow:AddColorPicker({
		Default = Color3.fromRGB(199, 199, 199), Flag = "shader_atmosphere_color",
		Callback = function(v) AIR.Color = v; applyAir() end,
	});

	local airOptions = airRow:AddOption(1);

	airOptions:AddLabel("Density"):AddSlider({
		Min = 0, Max = 100, Default = 30, Rounding = 0, Size = 90,
		Flag = "shader_atmosphere_density",
		Callback = function(v) AIR.Density = v / 100; applyAir() end,
	});

	airOptions:AddLabel("Haze"):AddSlider({
		Min = 0, Max = 100, Default = 0, Rounding = 0, Size = 90,
		Flag = "shader_atmosphere_haze",
		Callback = function(v) AIR.Haze = v / 10; applyAir() end,
	});
end);

-- ----------------------------------------------------------- lighting ----
-- Four more world tweaks that are pure Lighting state: fullbright, clock
-- time, ambient and exposure. All four write through appliers that remember
-- the map's values. The game resets most of Lighting on round change, so
-- whatever is on gets nudged back on a slow tick.


-- ====================================================================== trail
-- перенесено из Salad Visuals (trail), правки под DOORS и наше меню — в build-заметках
guard("trail", function()
	local T = {
		On = false,
		Target = "Self",
		Color = Color3.fromRGB(120, 200, 255),
		Color2 = Color3.fromRGB(255, 120, 220),
		Rainbow = false,
		Tint = false,
		Style = "Bloom",
		Size = 10,
		Life = 0.9,
		Rate = 140,
		Bright = 85,
		Amount = 100,
		Spread = 100,
		Gravity = 100,
		Always = false,
		Speed = 18,
	};

	-- hosted-path prefixes; Remote.file maps a whole path into the flat
	-- store, so the join has to happen before the lookup
	local PARTICLES = "particles/";

	-- Every preset is a real sprite with physics tuned for it, not one emitter
	-- wearing different pictures. size in studs at Size 10, rate per second at
	-- Rate 100, rise in studs/s^2, spread the cone in degrees, own = the sprite
	-- keeps its own colors.
	local STYLES = {
		Bloom = { kind = "particle", sprite = { "p_bloom" }, size = 2.04, rate = 34, life = 1.0,
			speed = { 0.4, 1.4 }, spread = 16, rise = 1.6, drag = 3.5, spin = 20, light = 0.85 },
		Glow = { kind = "particle", sprite = { "p_glow", "p_softglow" }, size = 2.40, rate = 26, life = 1.2,
			speed = { 0.2, 1.0 }, spread = 22, rise = 2.2, drag = 4, spin = 12, light = 1 },
		Sparkle = { kind = "particle", sprite = { "p_sparkle" }, size = 1.20, rate = 46, life = 0.8,
			speed = { 1.0, 3.2 }, spread = 45, rise = -2, drag = 2.2, spin = 180, light = 0.9 },
		Stars = { kind = "particle", sprite = { "p_star", "p_starnew" }, size = 1.32, rate = 34, life = 1.1,
			speed = { 0.8, 2.4 }, spread = 38, rise = -1.5, drag = 2, spin = 140, light = 0.55 },
		Fireflies = { kind = "particle", sprite = { "p_firefly" }, size = 0.96, rate = 30, life = 1.8,
			speed = { 0.3, 1.2 }, spread = 60, rise = 1.2, drag = 5, spin = 30, light = 1 },
		Hearts = { kind = "particle", sprite = { "p_heart" }, size = 1.44, rate = 22, life = 1.3,
			speed = { 0.6, 1.8 }, spread = 30, rise = 2.4, drag = 3, spin = 60, light = 0.35 },
		Snow = { kind = "particle", sprite = { "p_snowflake" }, size = 1.20, rate = 30, life = 1.6,
			speed = { 0.3, 1.1 }, spread = 42, rise = -1.8, drag = 3.5, spin = 90, light = 0.4 },
		Lightning = { kind = "particle", sprite = { "p_lightning" }, size = 1.44, rate = 28, life = 0.6,
			speed = { 1.4, 3.6 }, spread = 30, rise = 0, drag = 1.5, spin = 220, light = 1 },
		Crowns = { kind = "particle", sprite = { "p_crown" }, size = 1.44, rate = 16, life = 1.4,
			speed = { 0.6, 1.6 }, spread = 28, rise = 2.0, drag = 3, spin = 70, light = 0.3 },

		-- Same handful of sprites; the physics is what differs. Rate, lifetime,
		-- spread, rise and drag decide whether a sprite reads as a spark, a plume
		-- or a swarm.
		Smolder = { kind = "particle", sprite = { "p_bloom", "p_softglow" }, size = 3.20,
			rate = 14, life = 2.6, speed = { 0.1, 0.5 }, spread = 70, rise = 1.0, drag = 6, spin = 8, light = 0.45 },
		Halo = { kind = "particle", sprite = { "p_glowboost" }, size = 2.80, rate = 12, life = 1.6,
			speed = { 0.05, 0.3 }, spread = 90, rise = 0.4, drag = 7, spin = 15, light = 1.3 },
		Starfall = { kind = "particle", sprite = { "p_star", "p_starnew", "p_sparkle" }, size = 0.84,
			rate = 60, life = 2.2, speed = { 0.2, 0.9 }, spread = 25, rise = -6, drag = 1.2, spin = 200, light = 0.8 },
		Swarm = { kind = "particle", sprite = { "p_firefly", "p_sparkle" }, size = 0.60, rate = 90,
			life = 1.1, speed = { 1.6, 4.2 }, spread = 120, rise = 0, drag = 2.5, spin = 260, light = 1 },
		Static = { kind = "particle", sprite = { "p_lightning", "p_sparkle" }, size = 0.90, rate = 75,
			life = 0.35, speed = { 2.4, 5.5 }, spread = 75, rise = 0, drag = 0.8, spin = 300, light = 1.2 },
		Frost = { kind = "particle", sprite = { "p_snowflake", "p_sparkle" }, size = 0.78, rate = 55,
			life = 2.4, speed = { 0.2, 0.8 }, spread = 80, rise = -1.0, drag = 5, spin = 60, light = 0.7 },
		Bloomburst = { kind = "particle", sprite = { "p_bloom", "p_glow", "p_glowboost" }, size = 1.10,
			rate = 100, life = 0.5, speed = { 3.0, 7.0 }, spread = 180, rise = 0, drag = 1, spin = 120, light = 1.4 },

		-- ribbons: one continuous band behind the body rather than sprites
		Ribbon = { kind = "ribbon", texture = "", light = 1 },
		Comet = { kind = "ribbon", texture = Remote.file(PARTICLES .. "p_glow.png"), local_file = true, light = 2 },
		Smoke = { kind = "ribbon", texture = "rbxasset://textures/particles/smoke_main.dds", light = 0.4 },
	};

	local order = {
		"Bloom", "Glow", "Sparkle", "Stars", "Fireflies", "Hearts", "Snow",
		"Lightning", "Crowns", "Smolder", "Halo", "Starfall", "Swarm", "Static", "Frost",
		"Bloomburst", "Ribbon", "Comet", "Smoke",
	};

	local function customAsset(path)
		return Remote.id(path) or "";
	end;

	local function textureFor(style)
		if style.sprite then
			return customAsset(Remote.file(PARTICLES .. style.sprite[math.random(1, #style.sprite)] .. ".png"));
		end;

		if not style.local_file then return style.texture end;

		return customAsset(style.texture);
	end;

	local live = {};
	local WHITE = Color3.new(1, 1, 1);

	local function clear(character)
		local entry = live[character];
		if not entry then return end;

		for _, key in ipairs({ "trail", "emitter", "a", "b" }) do
			local part = entry[key];

			if part then pcall(function() part:Destroy() end) end;
		end;

		live[character] = nil;
	end;

	-- another player's own trail stays when ours is rebuilt
	local function clearAll()
		for character, entry in pairs(live) do
			if not entry.cfg or entry.cfg == T then clear(character) end;
		end;
	end;

	-- rainbow walks the wheel; otherwise the two pickers are the ends of the
	-- gradient every particle and every ribbon is drawn with
	local function colors(cfg)
		cfg = cfg or T;

		if cfg.Rainbow then
			local hue = (os.clock() * 0.12) % 1;

			return Color3.fromHSV(hue, 0.85, 1), Color3.fromHSV((hue + 0.22) % 1, 0.85, 1);
		end;

		return cfg.Color, cfg.Color2;
	end;

	local function sequenceFor(style, cfg)
		if style.own then return ColorSequence.new(Color3.new(1, 1, 1)) end;

		local first, second = colors(cfg);

		return ColorSequence.new(first, second);
	end;

	local function sizeFor(style, cfg)
		cfg = cfg or T;
		local base = style.size * (cfg.Size / 10);

		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, base * 0.35),
			NumberSequenceKeypoint.new(0.25, base),
			NumberSequenceKeypoint.new(1, base * 0.1),
		});
	end;

	local function fadeFor(cfg)
		cfg = cfg or T;
		local floor = 1 - math.clamp(cfg.Bright / 100, 0.05, 1);

		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.12, floor),
			NumberSequenceKeypoint.new(0.55, floor + (1 - floor) * 0.35),
			NumberSequenceKeypoint.new(1, 1),
		});
	end;

	local function buildParticles(character, root, style, cfg)
		cfg = cfg or T;
		local attach = Instance.new("Attachment");
		attach.Name = NeverLose.RandomString();
		attach.Position = Vector3.new(0, -0.9, 0);
		attach.Parent = root;

		local emitter = Instance.new("ParticleEmitter");
		emitter.Name = NeverLose.RandomString();
		emitter.Texture = textureFor(style);
		emitter.LightEmission = style.light;
		-- never lit by the world: a night map turned every sprite black
	emitter.LightInfluence = 0;
		emitter.Enabled = false;
		emitter.Rate = style.rate * (cfg.Rate / 100) * (cfg.Amount / 100);
		emitter.Lifetime = NumberRange.new(cfg.Life * 0.65, cfg.Life);
		emitter.Speed = NumberRange.new(style.speed[1], style.speed[2]);
		emitter.SpreadAngle = Vector2.new(style.spread, style.spread) * (cfg.Spread / 100);
		emitter.Acceleration = Vector3.new(0, style.rise * (cfg.Gravity / 100), 0);
		emitter.Drag = style.drag;
		emitter.VelocityInheritance = 0.3;
		emitter.EmissionDirection = Enum.NormalId.Back;
		emitter.Rotation = NumberRange.new(0, 360);
		emitter.RotSpeed = NumberRange.new(-style.spin, style.spin);
		emitter.Color = sequenceFor(style, cfg);
		emitter.Size = sizeFor(style, cfg);
		emitter.Transparency = fadeFor(cfg);
		emitter.Parent = attach;

		live[character] = {
			emitter = emitter, a = attach, root = root, style = style,
			swap = 0, size = cfg.Size, rate = cfg.Rate, amount = cfg.Amount, bright = cfg.Bright,
			enabled = false, life = cfg.Life, cfg = cfg,
		};
	end;

	local function buildRibbon(character, root, style, cfg)
		cfg = cfg or T;
		local a = Instance.new("Attachment");
		a.Name = NeverLose.RandomString();
		a.Position = Vector3.new(0, cfg.Size * 0.09, 0);
		a.Parent = root;

		local b = Instance.new("Attachment");
		b.Name = NeverLose.RandomString();
		b.Position = Vector3.new(0, -cfg.Size * 0.09, 0);
		b.Parent = root;

		local first, second = colors(cfg);

		local trail = Instance.new("Trail");
		trail.Name = NeverLose.RandomString();
		trail.Attachment0, trail.Attachment1 = a, b;
		trail.Lifetime = cfg.Life;
		trail.MinLength = 0.08;
		trail.FaceCamera = true;
		trail.LightEmission = style.light;
		trail.LightInfluence = 0;
		trail.Texture = textureFor(style);
		trail.TextureMode = Enum.TextureMode.Static;
		trail.TextureLength = 4;
		trail.Color = ColorSequence.new(first, second);

		-- taper to a point instead of ending in a blunt slab, which is what
		-- made the old ribbon read as a broken plank behind the player
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.62),
			NumberSequenceKeypoint.new(1, 0),
		});

		local floor = 1 - math.clamp(cfg.Bright / 100, 0.05, 1);

		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, floor),
			NumberSequenceKeypoint.new(0.7, floor + (1 - floor) * 0.5),
			NumberSequenceKeypoint.new(1, 1),
		});

		trail.Parent = root;

		live[character] = {
			trail = trail, a = a, b = b, root = root, style = style, size = cfg.Size,
			life = cfg.Life, first = first, second = second, cfg = cfg,
		};
	end;

	local FX = ESP.GameFX;

	-- players sharing a trail of their own: theirs is drawn, not ours
	local guests = {};

	local function build(character)
		local root = character:FindFirstChild("HumanoidRootPart");
		if not root then return end;

		clear(character);

		local owner = Players:GetPlayerFromCharacter(character);
		local cfg = (owner and guests[owner]) or T;

		-- a game trail picked for yourself is worn by the game fx module
		if cfg == T and T.Game and character == LocalPlayer.Character then return end;

		local style = STYLES[cfg.Style] or STYLES.Bloom;

		if style.kind == "ribbon" then
			buildRibbon(character, root, style, cfg);
		else
			buildParticles(character, root, style, cfg);
		end;
	end;

	local function wants(player)
		if not T.On then return false end;

		local isSelf = player == LocalPlayer;

		return T.Target == "All" or (isSelf and T.Target == "Self") or (not isSelf and T.Target == "Other");
	end;

	local function gameTune()
		if not FX then return end;
		local first, second = colors();
		FX.Tune("trail", {
			glow = T.Bright / 85, rate = T.Rate / 140, size = T.Size / 10, life = T.Life / 0.9,
			amount = T.Amount / 100,
			color = T.Tint and ColorSequence.new(first, second) or nil,
		});
	end;

	local function trailAllowed(id, label)
		local text = (tostring(id) .. " " .. tostring(label or "")):lower();
		for _, blocked in ipairs({
			"pride", "minecraft", "cubic", "block", "cube", "dash",
			"petal", "leaves", "flower", "flame", "bubble", "ember", "bloomfall",
			"confetti", "reicle", "reticle", "relic", "soap", "beam", "chain",
		}) do
			if text:find(blocked, 1, true) then return false end;
		end;
		return true;
	end;

	local function refresh()
		clearAll();
		if T.Game and not trailAllowed(T.Game) then T.Game = nil end;

		if FX then FX.SetGroup("trail", (T.On and T.Game and trailAllowed(T.Game)) and { T.Game } or {}) end;
		gameTune();

		if not T.On then return end;
		if not T.Style and not T.Game then return end;

		for _, player in ipairs(Players:GetPlayers()) do
			if wants(player) and player.Character then build(player.Character) end;
		end;
	end;

	local tuneClock, tuned = 0, nil;
	NeverLose:AddSignal(RunService.RenderStepped:Connect(function(dt)
		if not NeverLose.ScreenGui.Parent then return end;
		-- a recoloured game trail follows the pickers and the rainbow as well
		if T.Game and T.On then
			tuneClock += dt;
			if tuneClock > 0.12 then
				tuneClock = 0;
				local first, second = colors();
				local key = table.concat({ tostring(first), tostring(second), T.Bright, T.Rate, T.Amount, T.Size, T.Life, tostring(T.Rainbow), tostring(T.Tint) }, "|");
				if key ~= tuned then tuned = key; gameTune() end;
			end;
		end;
		if not next(live) then return end;
		local frameFirst, frameSecond = colors();
		local frameSequence = T.Rainbow and ColorSequence.new(frameFirst, frameSecond) or nil;

		for character, entry in pairs(live) do
			local cfg = entry.cfg or T;
			local ownFirst, ownSecond, ownSequence = frameFirst, frameSecond, frameSequence;
			if cfg ~= T then
				ownFirst, ownSecond = colors(cfg);
				ownSequence = cfg.Rainbow and ColorSequence.new(ownFirst, ownSecond) or nil;
			end;
			if not entry.root or not entry.root.Parent then
				clear(character);
			elseif entry.emitter then
				if not entry.emitter.Parent then
					clear(character);
				else
					local velocity = entry.root.AssemblyLinearVelocity;
					local planarSpeed = (velocity * Vector3.new(1, 0, 1)).Magnitude;
					local humanoid = character:FindFirstChildOfClass("Humanoid");
					local intent = humanoid and humanoid.MoveDirection.Magnitude > 0.05;
					local airborne = humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Jumping
						or humanoid:GetState() == Enum.HumanoidStateType.Freefall);
					local moving = cfg.Always or (planarSpeed > 7 and (intent or airborne));
					local style = entry.style;

					if entry.enabled ~= moving then
						entry.enabled = moving;
						entry.emitter.Enabled = moving;
					end;
					local first, second = ownFirst, ownSecond;
					if style.own then first, second = WHITE, WHITE end;
					if entry.first ~= first or entry.second ~= second then
						entry.first, entry.second = first, second;
						entry.emitter.Color = (not style.own and ownSequence) or ColorSequence.new(first, second);
					end;
					if entry.life ~= cfg.Life then
						entry.life = cfg.Life;
						entry.emitter.Lifetime = NumberRange.new(cfg.Life * 0.65, cfg.Life);
					end;

					if entry.size ~= cfg.Size then
						entry.size = cfg.Size;
						entry.emitter.Size = sizeFor(style, cfg);
					end;

					if entry.rate ~= cfg.Rate or entry.amount ~= cfg.Amount then
						entry.rate, entry.amount = cfg.Rate, cfg.Amount;
						entry.emitter.Rate = style.rate * (cfg.Rate / 100) * (cfg.Amount / 100);
					end;

					if entry.bright ~= cfg.Bright then
						entry.bright = cfg.Bright;
						entry.emitter.Transparency = fadeFor(cfg);
					end;

					-- presets built from several frames swap sprite now and
					-- then, so a flame flickers and petals are not all clones
					if style.sprite and #style.sprite > 1 and moving then
						entry.swap = entry.swap + dt;

						if entry.swap > 0.22 then
							entry.swap = 0;
							entry.emitter.Texture = textureFor(style);
						end;
					end;
				end;
			elseif not entry.trail or not entry.trail.Parent then
				clear(character);
			else
				if entry.first ~= ownFirst or entry.second ~= ownSecond then
					entry.first, entry.second = ownFirst, ownSecond;
					entry.trail.Color = ownSequence or ColorSequence.new(ownFirst, ownSecond);
				end;
				if entry.life ~= cfg.Life then
					entry.life = cfg.Life;
					entry.trail.Lifetime = cfg.Life;
				end;

				if entry.size ~= cfg.Size then
					entry.size = cfg.Size;
					entry.a.Position = Vector3.new(0, cfg.Size * 0.09, 0);
					entry.b.Position = Vector3.new(0, -cfg.Size * 0.09, 0);
				end;
			end;
		end;
	end));

	local function watch(player)
		NeverLose:AddPlayerSignal(player, player.CharacterAdded:Connect(function(character)
			if not wants(player) then return end;

			task.delay(1, function()
				if ALIVE and T.On and wants(player) and player.Parent and player.Character == character and character.Parent then build(character) end;
			end);
		end));
	end;

	for _, player in ipairs(Players:GetPlayers()) do watch(player) end;
	NeverLose:AddSignal(Players.PlayerAdded:Connect(watch));

	ESP.Trail = T;

	-- ------------------------------------------------------------ shared --
	-- what the share function sends for this trail, and how another player's
	-- is put on: their style and colours, drawn by the same code as ours
	function T.Worn()
		if not (T.On and T.Style and STYLES[T.Style] and (T.Target == "Self" or T.Target == "All")) then return nil end;
		return {
			s = T.Style, a = T.Color:ToHex(), b = T.Color2:ToHex(), r = T.Rainbow == true, z = T.Size, l = T.Life,
			n = T.Rate, g = T.Bright, m = T.Amount, w = T.Always == true,
		};
	end;

	function T.Dress(player, spec)
		if player == LocalPlayer then return end;
		if type(spec) ~= "table" or not STYLES[tostring(spec.s)] then T.Undress(player); return end;

		local okA, first = pcall(Color3.fromHex, tostring(spec.a));
		local okB, second = pcall(Color3.fromHex, tostring(spec.b));
		local cfg = {
			Style = tostring(spec.s), Color = okA and first or T.Color, Color2 = okB and second or T.Color2,
			Rainbow = spec.r == true, Size = math.clamp(tonumber(spec.z) or 10, 1, 40),
			Life = math.clamp(tonumber(spec.l) or 0.9, 0.1, 5), Rate = math.clamp(tonumber(spec.n) or 140, 1, 600),
			Bright = math.clamp(tonumber(spec.g) or 85, 1, 100), Amount = math.clamp(tonumber(spec.m) or 100, 1, 400),
			Spread = 100, Gravity = 100, Always = spec.w == true,
		};
		cfg.key = table.concat({ cfg.Style, tostring(spec.a), tostring(spec.b), tostring(cfg.Rainbow), cfg.Size, cfg.Life, cfg.Rate, cfg.Bright, cfg.Amount, tostring(cfg.Always) }, "|");

		if guests[player] and guests[player].key == cfg.key then return end;

		guests[player] = cfg;
		if player.Character then pcall(build, player.Character) end;
	end;

	function T.Undress(player)
		if not guests[player] then return end;
		guests[player] = nil;

		local character = player.Character;
		if character and live[character] and live[character].cfg ~= T then clear(character) end;
		-- our own All/Other trail may belong on them again
		if character and T.On and wants(player) then pcall(build, character) end;
	end;

	function T.Guests() return guests end;

	-- a guest who respawned gets their trail back
	task.spawn(function()
		while ALIVE do
			task.wait(1);
			for player, cfg in pairs(guests) do
				if not player.Parent then
					guests[player] = nil;
				else
					local character = player.Character;
					local entry = character and live[character];
					if character and character:FindFirstChild("HumanoidRootPart") and not (entry and entry.cfg == cfg) then
						pcall(build, character);
					end;
				end;
			end;
		end;
	end);
	ESP.TrailStyles = order;
	ESP.ClearTrail = function()
		T.On = false;
		clearAll();
		if FX then pcall(FX.SetGroup, "trail", {}) end;
	end;

	local row = Sections.Trail:AddLabel("Enabled");
	row:AddToggle({ Default = false, Flag = "trail", Callback = function(v) T.On = v; refresh() end });
	row:AddColorPicker({ Default = T.Color, Flag = "trail_color", Callback = function(v)
		T.Color = v;
		if not T.Tint and T.Game and userPicked() then setFlag("trail_tint", true) end;
		refresh(); gameTune();
	end });

	-- one picture grid for the useful styles; blocky/Minecraft, Dash and Pride
	-- variants are deliberately not part of the selectable catalogue.
	local TRAIL_PREVIEW_FALLBACK = "rbxasset://textures/particles/sparkles_main.dds";
	local function trailRows(art)
		local out = {};
		for _, name in ipairs(order) do
			if trailAllowed(name) then
				local fallback = (art and art[name]) or TRAIL_PREVIEW_FALLBACK;
				local image, rect, size = fallback, nil, nil;
				if FX then image, rect, size = FX.Art("builtin/trail/" .. name, fallback) end;
				out[#out + 1] = { name = name, label = name, image = image, rect = rect, rectsize = size };
			end;
		end;
		for _, entry in ipairs(FX and FX.Catalog or {}) do
			if entry.kind == "Trail" and trailAllowed(entry.id, entry.label) then
				local row = FX.Row(entry);
				local image, rect, size = FX.Art(entry.id, nil);
				if image then row.image, row.rect, row.rectsize = image, rect, size end;
				row.image = row.image or TRAIL_PREVIEW_FALLBACK;
				out[#out + 1] = row;
			end;
		end;
		return out;
	end;

	local trailGrid = Visuals.Trails:AddGallery({
		Name = "Trails", Icon = "wand-sparkles", Position = "left", Height = 440, Cell = 74, Reset = true, Smooth = true,
		Thumb = "Asset", Blank = "wand-sparkles", Empty = "No trails", Values = trailRows(),
		Default = "Bloom", Flag = "trail_style",
		Callback = function(v)
			if type(v) ~= "string" or v == "" then
				T.Style, T.Game = nil, nil;
				refresh();
				return;
			end;
			if STYLES[v] and trailAllowed(v) then
				T.Style, T.Game = v, nil;
			elseif FX and FX.ById[v] and trailAllowed(v, FX.ById[v].label) then
				T.Game = v;
			else
				T.Game = nil;
			end;
			refresh();
		end,
	});

	if FX then
		FX.OnThumbs(function() trailGrid:setdata(trailRows()) end);
		Visuals.Trails.Signal:Connect(function(open) if open then FX.LoadThumbs() end end);
	end;

	-- the built styles show their own sprite once the assets are in
	task.delay(4, function()
		if not ALIVE then return end;
		local art = {};
		for _, name in ipairs(order) do
			local style = STYLES[name];
			local ok, texture = pcall(textureFor, style);
			if ok and type(texture) == "string" and texture ~= "" then art[name] = texture end;
			task.wait();
		end;
		if ALIVE then pcall(function() trailGrid:setdata(trailRows(art)) end) end;
	end);

	Sections.Trail:AddLabel("Target"):AddDropdown({
		Default = "Self",
		Values = { "Self", "Other", "All" },
		Flag = "trail_target",
		Callback = function(v) T.Target = v; refresh() end,
	});

	row:AddColorPicker({ Name = "Fade Color", Default = T.Color2, Flag = "trail_color2", Callback = function(v)
		T.Color2 = v;
		if not T.Tint and T.Game and userPicked() then setFlag("trail_tint", true) end;
		refresh(); gameTune();
	end });

	Sections.Trail:AddLabel("Rainbow"):AddToggle({
		Default = false, Flag = "trail_rainbow",
		Callback = function(v) T.Rainbow = v; refresh(); gameTune() end,
	});

	-- the Nullscape and Evade trails keep their own colours unless this is on;
	-- the menu's own styles always wear the pickers
	Sections.Trail:AddLabel("Custom Colors"):AddToggle({ Default = false, Flag = "trail_tint",
		Callback = function(v) T.Tint = v; gameTune() end });
	gameTune();

	local options = Sections.Trail:AddLabel("Options"):AddOption(1);

	options:AddLabel("Size"):AddSlider({
		Min = 2, Max = 40, Default = 10, Rounding = 0, Size = 100,
		Flag = "trail_width",
		Callback = function(v) T.Size = v end,
	});

	options:AddLabel("Length"):AddSlider({
		Min = 2, Max = 40, Default = 9, Rounding = 0, Size = 100,
		Flag = "trail_life",
		Callback = function(v) T.Life = v / 10 end,
	});

	options:AddLabel("Density"):AddSlider({
		Min = 10, Max = 300, Default = 140, Type = "%", Size = 100,
		Flag = "trail_rate",
		Callback = function(v) T.Rate = v end,
	});

	options:AddLabel("Amount"):AddSlider({
		Min = 10, Max = 300, Default = 100, Type = "%", Size = 100,
		Flag = "trail_amount",
		Callback = function(v) T.Amount = v; refresh(); gameTune() end,
	});

	options:AddLabel("Brightness"):AddSlider({
		Min = 5, Max = 100, Default = 85, Type = "%", Size = 100,
		Flag = "trail_bright",
		Callback = function(v) T.Bright = v end,
	});

	options:AddLabel("Spread"):AddSlider({
		Min = 0, Max = 250, Default = 100, Type = "%", Size = 100,
		Flag = "trail_spread",
		Callback = function(v) T.Spread = v; refresh() end,
	});

	options:AddLabel("Drift"):AddSlider({
		Min = 0, Max = 250, Default = 100, Type = "%", Size = 100,
		Flag = "trail_gravity",
		Callback = function(v) T.Gravity = v; refresh() end,
	});

	options:AddLabel("Always On"):AddToggle({
		Default = false, Flag = "trail_always",
		Callback = function(v) T.Always = v; refresh() end,
	});
end);

-- ------------------------------------------------------ world FX math ----
-- Pure trajectory functions; pooled geometry below does not allocate per frame.


-- ====================================================================== circles
-- перенесено из Salad Visuals (circles), правки под DOORS и наше меню — в build-заметках
guard("circles", function()
	local Debris = game:GetService("Debris");
	local ContentProvider = game:GetService("ContentProvider");
	local DEFAULT_STYLE = "Soft Ring";

	local C = {
		Jump = false, Land = false,
		Style = DEFAULT_STYLE,
		Color = Color3.fromRGB(150, 200, 255),
		Size = 4,
		Life = 0.8,
		Target = "Self",
		Bright = 100,
		Grow = 160,
		Spin = 0,
	};

	-- The frames are jpegs and the stills are 24 bit pngs - no alpha, which is
	-- why the black backing showed through a decal. Drawn as particles with
	-- LightEmission 1 instead: additive, so black contributes nothing.
	local styles = {
		["Soft Ring"] = { file = Remote.file("circles/circle.png") },
		Inscription = { file = Remote.file("circles/konchal.png") },
		["Classic Ring"] = { asset = "rbxassetid://7185003058" },
		["Double Ripple"] = { file = Remote.file("circles/ripple.png") },
		["Neon Ring"] = { file = Remote.file("circles/neonring.png") },
		["Triple Swirl"] = { file = Remote.file("circles/swirl.png") },
		["Neon Star"] = { file = Remote.file("circles/neonstar.png") },
		["Halo Ring"] = { file = Remote.file("circles/haloring.png") },
		["Cracked Ground"] = { file = Remote.file("circles/shatter.png") },
		["Rune Crown"] = { file = Remote.file("circles/img.png") },
		["Glyph Ring"] = { file = Remote.file("circles/pentos.png") },
		["Magic Circle"] = { file = Remote.file("circles/imagephotoroom.png") },
		["Blast Ring"] = { file = Remote.file("circles/boom1.png") },
		["Vortex Ring"] = { file = Remote.file("circles/omut3.png") },
		["Radial Burst"] = { file = Remote.file("circles/85362844633530.png") },
		["Mist Ring"] = { file = Remote.file("circles/134160165648626.png") },
		["Star Flash"] = { file = Remote.file("circles/17068400400.png") },
		["Arcane Sigil"] = { file = Remote.file("circles/circle4.png") },
	};

	local order = {
		"Soft Ring", "Inscription", "Classic Ring", "Double Ripple", "Neon Ring", "Triple Swirl",
		"Neon Star", "Halo Ring", "Cracked Ground", "Rune Crown", "Glyph Ring", "Magic Circle",
		"Blast Ring", "Vortex Ring", "Radial Burst", "Mist Ring", "Star Flash", "Arcane Sigil",
	};
	local aliases = {
		Circle = "Soft Ring", Konchal = "Inscription", Ring = "Classic Ring", Ripple = "Double Ripple",
		Neon = "Neon Ring", Swirl = "Triple Swirl", Star = "Neon Star", Halo = "Halo Ring",
		Shatter = "Cracked Ground", Img = "Rune Crown", Pentos = "Glyph Ring",
		["Image Photoroom"] = "Magic Circle", ["Boom 1"] = "Blast Ring", ["Omut 3"] = "Vortex Ring",
		["85362844633530"] = "Radial Burst", ["134160165648626"] = "Mist Ring",
		["17068400400"] = "Star Flash", ["Circle 4"] = "Arcane Sigil",
		Animation1 = "Orbit Rings", Animation2 = "Firework Bloom", Puff = "Smoke Bloom",
	};
	local generatedNames = { animation1 = "Orbit Rings", animation2 = "Firework Bloom", puff = "Smoke Bloom" };

	do
		for _, rel in ipairs(Remote.under("circles/")) do
			local file = string.match(rel, "([^/]+)$");
			local name, cols, rows, frames = string.match(file or "", "^(.+)_(%d+)x(%d+)_(%d+)%.png$");

			if name then
				local pretty = generatedNames[string.lower(name)] or (string.gsub(name, "^%l", string.upper));

				styles[pretty] = {
					file = Remote.file(rel),
					cols = tonumber(cols), rows = tonumber(rows), frames = tonumber(frames),
				};

				order[#order + 1] = pretty;
			end;
		end;
	end;

	local function urlFor(style)
		if style.asset then return style.asset end;
		if style.url ~= nil then return style.url or nil end;
		style.url = Remote.id(style.file) or false;
		return style.url or nil;
	end;
	local function canonicalStyle(name)
		name = aliases[name] or name;
		return styles[name] and name or DEFAULT_STYLE;
	end;
	ESP.CircleStyles = { Order = order, Styles = styles, Aliases = aliases, Default = DEFAULT_STYLE };
	task.spawn(function()
		local urls = {};
		for _, name in ipairs(order) do
			if not ALIVE then return end;
			local url = urlFor(styles[name]);
			if url then urls[#urls + 1] = url end;
			task.wait();
		end;
		if ALIVE and #urls > 0 then Remote.invoke(function() ContentProvider:PreloadAsync(urls) end, 8) end;
	end);
	do
		local G = ESP.GunChams;
		if G then
			local function makeCircle(record, style)
				local part = Instance.new("Part");
				part.Name = "VisualsGunCircle";
				part:SetAttribute(TAG, INIT_GENERATION);
				part:SetAttribute("VisualsGunAura", true);
				part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false;
				part.CastShadow, part.Transparency = false, 1;
				part.Parent = workspace;
				local attach = Instance.new("Attachment"); attach.Parent = part;
				local emitter = Instance.new("ParticleEmitter");
				emitter:SetAttribute("VisualsGunAura", true);
				emitter.Rate, emitter.TimeScale = 0, 0;
				emitter.Lifetime, emitter.Speed = NumberRange.new(20), NumberRange.new(0.01);
				emitter.LightEmission, emitter.LightInfluence, emitter.LockedToPart = 1, 0, true;
				emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular;
				emitter.EmissionDirection = Enum.NormalId.Top;
				emitter.Rotation, emitter.RotSpeed = NumberRange.new(0), NumberRange.new(0);
				emitter.Parent = attach;
				local circle = { Part = part, Emitter = emitter, Style = G.CircleStyle, Clock = 1 };
				record.Circle = circle;
				task.defer(function()
					local url = urlFor(style);
					if not ALIVE or record.Circle ~= circle or not part.Parent or not url then return end;
					emitter.Texture = url;
					local layouts = { [2] = Enum.ParticleFlipbookLayout.Grid2x2,
						[4] = Enum.ParticleFlipbookLayout.Grid4x4, [8] = Enum.ParticleFlipbookLayout.Grid8x8 };
					if style.frames and layouts[style.cols] then
						emitter.FlipbookLayout = layouts[style.cols];
						emitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot;
						emitter.FlipbookStartRandom = false;
						emitter.FlipbookFramerate = NumberRange.new(0);
					end;
					emitter:Emit(1);
					circle.Ready = true;
				end);
				return circle;
			end;
			ESP.StaticGunCircle = function(record, object, gun, dt)
				local style = styles[G.CircleStyle] or styles[DEFAULT_STYLE];
				local circle = record.Circle;
				if not circle or circle.Style ~= G.CircleStyle or not circle.Part.Parent then
					if circle then circle.Part:Destroy() end;
					circle = makeCircle(record, style);
				end;
				circle.Clock += dt;
				if circle.Clock >= 0.1 or circle.Ground ~= G.CircleGround then
					circle.Clock, circle.Ground = 0, G.CircleGround;
					local position, normal = gun.Position - Vector3.new(0, gun.Size.Y * 0.5, 0), Vector3.yAxis;
					if G.CircleGround then
						local params = RaycastParams.new();
						params.FilterType = Enum.RaycastFilterType.Exclude;
						local ignore = { object, circle.Part };
						for _, player in ipairs(Players:GetPlayers()) do if player.Character then ignore[#ignore + 1] = player.Character end end;
						params.FilterDescendantsInstances, params.IgnoreWater = ignore, true;
						local hit = workspace:Raycast(gun.Position, Vector3.new(0, -64, 0), params);
						if hit then position, normal = hit.Position, hit.Normal end;
					end;
					circle.Position, circle.Normal = position, normal;
				end;
				local up = circle.Normal or Vector3.yAxis;
				local reference = math.abs(up.Y) > 0.98 and Vector3.xAxis or Vector3.yAxis;
				local right = up:Cross(reference).Unit;
				circle.Part.CFrame = CFrame.fromMatrix(circle.Position + up * G.CircleHeight, right, up, right:Cross(up).Unit);
				local emitter = circle.Emitter;
				local settings = { G.CircleColor, G.CircleSize, G.CircleOpacity, G.CircleGlow, G.CircleRotation, G.CircleThroughWalls };
				local changed = not circle.Settings;
				for i, value in ipairs(settings) do if not circle.Settings or value ~= circle.Settings[i] then changed = true end end;
				if changed then
					circle.Settings = settings;
					emitter.Color, emitter.Size = ColorSequence.new(G.CircleColor), NumberSequence.new(G.CircleSize);
					emitter.Transparency, emitter.Brightness = NumberSequence.new(1 - G.CircleOpacity), G.CircleGlow;
					emitter.Rotation = NumberRange.new(G.CircleRotation);
					Render.FxDepth(emitter, G.CircleThroughWalls);
					if circle.Ready then emitter:Clear(); emitter:Emit(1) end;
				end;
			end;
			local row = Sections.Guns:AddLabel("Gun Circle");
			row:AddToggle({ Default = false, Flag = "gun_circle", Callback = function(v) G.Circle = v; G.SetTracking() end });
			row:AddColorPicker({ Default = G.CircleColor, Flag = "gun_circle_color", Callback = function(v) G.CircleColor = v end });
			local options = row:AddOption(1);
			options:AddLabel("Style"):AddDropdown({ Default = DEFAULT_STYLE, Values = order, Flag = "gun_circle_style",
				Callback = function(v) G.CircleStyle = canonicalStyle(v) end });
			for _, setting in ipairs({
				{ "Size", "CircleSize", "size", 5, 300, 40, 10 },
				{ "Opacity", "CircleOpacity", "opacity", 0, 100, 100, 100 },
				{ "Glow", "CircleGlow", "glow", 0, 600, 200, 100 },
				{ "Height", "CircleHeight", "height", 0, 200, 6, 100 },
				{ "Rotation", "CircleRotation", "rotation", 0, 360, 0, 1 },
			}) do
				local key, divisor = setting[2], setting[7];
				options:AddLabel(setting[1]):AddSlider({ Min = setting[4], Max = setting[5], Default = setting[6],
					Rounding = 0, Flag = "gun_circle_" .. setting[3], Callback = function(v) G[key] = v / divisor end });
			end;
			options:AddLabel("On Ground"):AddToggle({ Default = true, Flag = "gun_circle_ground", Callback = function(v) G.CircleGround = v end });
		end;
	end;

	local FLIPBOOK = {
		[2] = Enum.ParticleFlipbookLayout.Grid2x2,
		[4] = Enum.ParticleFlipbookLayout.Grid4x4,
		[8] = Enum.ParticleFlipbookLayout.Grid8x8,
	};

	-- Where the feet actually meet the ground, and which way that ground
	-- faces, so the disc lies on a slope instead of floating through it.
	local function groundAt(char, root)
		local params = RaycastParams.new();
		params.FilterType = Enum.RaycastFilterType.Exclude;
		params.FilterDescendantsInstances = { char };
		params.IgnoreWater = true;

		local sum, normal, hits = Vector3.zero, Vector3.zero, 0;

		for _, name in ipairs({ "LeftFoot", "RightFoot", "Left Leg", "Right Leg" }) do
			local foot = char:FindFirstChild(name);

			if foot and foot:IsA("BasePart") then
				local hit = workspace:Raycast(foot.Position + Vector3.new(0, 0.35, 0), Vector3.new(0, -7, 0), params);

				if hit then
					sum = sum + hit.Position;
					normal = normal + hit.Normal;
					hits = hits + 1;
				end;
			end;
		end;

		if hits > 0 then return sum / hits, normal.Unit end;

		local hit = workspace:Raycast(root.Position + Vector3.new(0, 1, 0), Vector3.new(0, -16, 0), params);

		if hit then return hit.Position, hit.Normal end;

		return root.Position - Vector3.new(0, 3, 0), Vector3.yAxis;
	end;

	local circleParts, circleVisuals = {}, {};
	local function clearActiveCircles()
		local stale = {};
		for part in pairs(circleParts) do stale[#stale + 1] = part end;
		for _, part in ipairs(stale) do if part.Parent then part:Destroy() end end;
		table.clear(circleParts);
		table.clear(circleVisuals);
	end;
	local function spawnCircle(position, normal)
		if not ALIVE then return end;
		local style = styles[C.Style] or styles[DEFAULT_STYLE];
		local url = urlFor(style);
		local count, oldest, oldestAt = 0, nil, math.huge;
		for part, visual in pairs(circleVisuals) do
			count += 1;
			if visual.born < oldestAt then oldest, oldestAt = part, visual.born end;
		end;
		if count >= 24 and oldest then oldest:Destroy() end;

		local up = normal or Vector3.yAxis;
		local reference = (math.abs(up.Y) > 0.98) and Vector3.xAxis or Vector3.yAxis;
		local right = up:Cross(reference).Unit;
		local front = right:Cross(up).Unit;

		local part = Instance.new("Part");
		part.Name = "VisualsJumpCircle";
		part:SetAttribute(TAG, INIT_GENERATION);
		part.Anchored = true;
		part.CanCollide = false;
		part.CanQuery = false;
		part.CanTouch = false;
		part.CastShadow = false;
		part.Transparency = 1;
		part.Size = Vector3.new(0.2, 0.2, 0.2);
		part.CFrame = CFrame.fromMatrix(position + up * 0.08, right, up, front);
		circleParts[part] = true;
		part.Destroying:Once(function() circleParts[part] = nil; circleVisuals[part] = nil end);
		part.Parent = workspace;

		-- SurfaceGui ring remains visible when mobile/low-quality particle
		-- rendering is disabled, or an executor cannot load the custom texture.
		local surface = Instance.new("SurfaceGui");
		surface.Face, surface.Adornee = Enum.NormalId.Top, part;
		surface.AlwaysOnTop, surface.LightInfluence = false, 0;
		surface.CanvasSize, surface.Parent = Vector2.new(512, 512), part;
		local ring = Instance.new("Frame");
		ring.BackgroundTransparency, ring.Size = 1, UDim2.fromScale(0.94, 0.94);
		ring.Position, ring.BorderSizePixel, ring.Parent = UDim2.fromScale(0.03, 0.03), 0, surface;
		local corner = Instance.new("UICorner"); corner.CornerRadius, corner.Parent = UDim.new(1, 0), ring;
		local stroke = Instance.new("UIStroke");
		stroke.ApplyStrokeMode, stroke.Thickness = Enum.ApplyStrokeMode.Border, 7;
		stroke.Color, stroke.Parent = C.Color, ring;
		circleVisuals[part] = {
			born = os.clock(), life = C.Life, size = C.Size, grow = C.Grow / 100,
			bright = math.clamp(C.Bright / 100, 0, 1), stroke = stroke,
			base = part.CFrame, spin = math.rad(C.Spin),
		};
		part.Size = Vector3.new(C.Size * 0.35, 0.025, C.Size * 0.35);
		Debris:AddItem(part, C.Life + 0.4);
		if not url then return part end;
		local ok = pcall(function()

		local attach = Instance.new("Attachment");
		attach.Parent = part;

		local opacity = math.clamp(C.Bright / 100, 0, 1);

		local emitter = Instance.new("ParticleEmitter");
		emitter.Texture = url;
		emitter.Color = ColorSequence.new(C.Color);
		emitter.LightEmission = 1;
		emitter.LightInfluence = 0;
		emitter.Rate = 0;
		emitter.Lifetime = NumberRange.new(C.Life);
		emitter.Speed = NumberRange.new(0.01);
		emitter.Drag = 0;
		emitter.Acceleration = Vector3.zero;
		emitter.VelocityInheritance = 0;
		emitter.EmissionDirection = Enum.NormalId.Top;
		emitter.Rotation = NumberRange.new(0);
		emitter.RotSpeed = NumberRange.new(C.Spin);
		emitter.ZOffset = 0;

		-- perpendicular to a straight-up velocity means the quad lies flat
		pcall(function() emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular end);

		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, C.Size * 0.35),
			NumberSequenceKeypoint.new(0.4, C.Size),
			NumberSequenceKeypoint.new(1, C.Size * C.Grow / 100),
		});

		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - opacity),
			NumberSequenceKeypoint.new(0.6, 1 - opacity * 0.55),
			NumberSequenceKeypoint.new(1, 1),
		});

		if style.frames and FLIPBOOK[style.cols] then
			pcall(function()
				emitter.FlipbookLayout = FLIPBOOK[style.cols];
				emitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot;
			end);
		end;

		emitter.Parent = attach;
		emitter:Emit(1);
		-- The SurfaceGui is only a fallback for unavailable custom textures.
		-- Leaving it enabled draws a second generic circle over every style.
		surface.Enabled = false;

		end);
		if not ok then
			for _, child in ipairs(part:GetChildren()) do if child:IsA("Attachment") then child:Destroy() end end;
		end;
		return part;
	end;

	local function wants(player)
		local isSelf = player == LocalPlayer;

		return C.Target == "All" or (isSelf and C.Target == "Self") or (not isSelf and C.Target == "Other");
	end;

	-- State events plus a low-frequency floor/velocity fallback for games
	-- whose custom movement skips Jumping/Landed. One owned record per character.
	local state = {};
	local function rootFor(character, human)
		local root = human.RootPart or character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart;
		return root and root:IsA("BasePart") and root or nil;
	end;
	local function emitFor(record, position, normal)
		local now = os.clock();
		if record.lastCircleAt and now - record.lastCircleAt <= 0.22 and record.lastCirclePosition
			and (position - record.lastCirclePosition).Magnitude <= 5 then return false end;
		record.lastCircleAt, record.lastCirclePosition = now, position;
		spawnCircle(position, normal);
		return true;
	end;
	local function unhook(player)
		local record = state[player];
		if not record then return end;
		state[player] = nil;
		for _, conn in ipairs(record.conns) do conn:Disconnect() end;
		for _, conn in ipairs(record.humanConns or {}) do conn:Disconnect() end;
	end;
	local function takeoff(record, fromFloor)
		local root = rootFor(record.character, record.human);
		if not root then return end;
		if fromFloor and record.jumpDetected then record.air = true; return end;
		record.jumpDetected = true;
		local now = os.clock();
		if C.Jump and wants(record.player) and now - record.lastJump > 0.18 then
			record.lastJump = now;
			local position, normal = groundAt(record.character, root);
			emitFor(record, position, normal);
		end;
		record.air = true;
	end;
	local function landed(record)
		if record.air and C.Land and wants(record.player) then
			local root = rootFor(record.character, record.human);
			if root then
				local position, normal = groundAt(record.character, root);
				emitFor(record, position, normal);
			end;
		end;
		record.air = false;
		record.jumpDetected = false;
	end;
	local function watch(player)
		local function hook(character)
			unhook(player);
			local record = { player = player, character = character, conns = {}, humanConns = {}, lastJump = -math.huge };
			state[player] = record;
			local function attach(human)
				if (record.human and record.human.Parent) or not ALIVE or state[player] ~= record or player.Character ~= character then return end;
				for _, conn in ipairs(record.humanConns) do conn:Disconnect() end;
				table.clear(record.humanConns);
				record.human = human;
				record.air = human.FloorMaterial == Enum.Material.Air;
				record.floorAir = record.air;
				record.humanConns[#record.humanConns + 1] = human.StateChanged:Connect(function(_, new)
					if not ALIVE or state[player] ~= record then return end;
					if new == Enum.HumanoidStateType.Jumping then takeoff(record)
					elseif new == Enum.HumanoidStateType.Freefall then record.air = true
					elseif new == Enum.HumanoidStateType.Landed then landed(record) end;
				end);
				record.humanConns[#record.humanConns + 1] = human.Jumping:Connect(function(active)
					if ALIVE and active and state[player] == record then takeoff(record) end;
				end);
			end;
			record.conns[#record.conns + 1] = character.DescendantAdded:Connect(function(obj)
				if obj:IsA("Humanoid") then attach(obj) end;
			end);
			record.conns[#record.conns + 1] = character.ChildRemoved:Connect(function(obj)
				if obj == record.human then
					for _, conn in ipairs(record.humanConns) do conn:Disconnect() end;
					table.clear(record.humanConns); record.human = nil;
					local human = character:FindFirstChildOfClass("Humanoid");
					if human then attach(human) end;
				end;
			end);
			task.spawn(function()
				local human = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10);
				if human and ALIVE and character.Parent and player.Parent and player.Character == character then attach(human) end;
			end);
		end;
		if player.Character then hook(player.Character) end;
		NeverLose:AddPlayerSignal(player, player.CharacterAdded:Connect(hook));
		NeverLose:AddPlayerSignal(player, player.CharacterRemoving:Connect(function() unhook(player) end));
	end;
	local poll = 0;
	NeverLose:AddSignal(RunService.RenderStepped:Connect(function(dt)
		if not ALIVE then return end;
		local now = os.clock();
		for part, visual in pairs(circleVisuals) do
			local t = (now - visual.born) / visual.life;
			if t >= 1 or not part.Parent then part:Destroy()
			else
				local diameter = visual.size * (t < 0.4 and (0.35 + t / 0.4 * 0.65) or (1 + (visual.grow - 1) * (t - 0.4) / 0.6));
				part.Size = Vector3.new(diameter, 0.025, diameter);
				part.CFrame = visual.base * CFrame.Angles(0, visual.spin * (now - visual.born), 0);
				visual.stroke.Transparency = 1 - visual.bright * (1 - t) ^ 1.4;
			end;
		end;
		if not (C.Jump or C.Land) then return end;
		poll += dt;
		if poll < 0.04 then return end;
		poll = 0;
		for player, record in pairs(state) do
			local human, character = record.human, record.character;
			if human and human.Parent and character.Parent and player.Character == character and wants(player) then
				local root = rootFor(character, human);
				if root then
					local air = human.FloorMaterial == Enum.Material.Air;
					if air and not record.floorAir and root.AssemblyLinearVelocity.Y > 1 then takeoff(record, true)
					elseif not air and record.floorAir then landed(record) end;
					record.floorAir = air;
				end;
			end;
		end;
	end));
	for _, player in ipairs(Players:GetPlayers()) do watch(player) end;
	NeverLose:AddSignal(Players.PlayerAdded:Connect(watch));
	NeverLose:AddSignal(Players.PlayerRemoving:Connect(unhook));

	ESP.Circles = C;
	ESP.SpawnCircle = spawnCircle;

	-- the unload list has always named this; it had never been written
	ESP.ClearCircles = onUnload("circles", function()
		C.Jump, C.Land = false, false;
		clearActiveCircles();
		for player in pairs(state) do unhook(player) end;

		table.clear(state);
	end);

	local jumpRow = Sections.Circles:AddLabel("Jump Circle");
	jumpRow:AddToggle({ Default = false, Flag = "jump_circle", Callback = function(v)
		C.Jump = v;
		if not (C.Jump or C.Land) then clearActiveCircles() end;
	end });
	jumpRow:AddColorPicker({ Default = C.Color, Flag = "circle_color", Callback = function(v) C.Color = v end });

	Sections.Circles:AddLabel("Land Circle"):AddToggle({
		Default = false, Flag = "land_circle",
		Callback = function(v)
			C.Land = v;
			if not (C.Jump or C.Land) then clearActiveCircles() end;
		end,
	});

	Sections.Circles:AddLabel("Style"):AddDropdown({
		Default = DEFAULT_STYLE,
		Values = order,
		Flag = "circle_style",
		Callback = function(v)
			local nextStyle = canonicalStyle(v);
			if C.Style ~= nextStyle then clearActiveCircles() end;
			C.Style = nextStyle;
		end,
	});

	Sections.Circles:AddLabel("Size"):AddSlider({
		Min = 1, Max = 30, Default = 4, Rounding = 1, Size = 100,
		Flag = "circle_size",
		Callback = function(v) C.Size = v end,
	});

	Sections.Circles:AddLabel("Life"):AddSlider({
		Min = 2, Max = 40, Default = 8, Rounding = 0, Size = 100,
		Flag = "circle_life",
		Callback = function(v) C.Life = v / 10 end,
	});

	Sections.Circles:AddLabel("Grow"):AddSlider({
		Min = 100, Max = 400, Default = 220, Type = "%", Size = 100,
		Flag = "circle_grow",
		Callback = function(v) C.Grow = v end,
	});

	Sections.Circles:AddLabel("Brightness"):AddSlider({
		Min = 10, Max = 100, Default = 100, Type = "%", Size = 100,
		Flag = "circle_bright",
		Callback = function(v) C.Bright = v end,
	});

	Sections.Circles:AddLabel("Spin"):AddSlider({
		Min = 0, Max = 180, Default = 0, Rounding = 0, Size = 100,
		Flag = "circle_spin",
		Callback = function(v) C.Spin = v end,
	});

	Sections.Circles:AddLabel("Target"):AddDropdown({
		Default = "Self",
		Values = { "Self", "Other", "All" },
		Flag = "circle_target",
		Callback = function(v) C.Target = v end,
	});

	Sections.Circles:AddButton({
		Name = "Test Circle",
		Callback = function()
			local char = LocalPlayer.Character;
			local root = char and char:FindFirstChild("HumanoidRootPart");

			if root then spawnCircle(groundAt(char, root)) end;
		end,
	});
end);

-- ------------------------------------------------------------- trail ----
-- The dash trail from the Java client, done the Roblox way: a Trail between
-- two attachments, with the same easing as its AnimationUtil - the width
-- walks toward its target rather than snapping.


-- ====================================================================== music
-- перенесено из Salad Visuals (music), правки под DOORS и наше меню — в build-заметках
guard("music", function()
	local HttpService = game:GetService("HttpService");
	local TweenService = game:GetService("TweenService");
	local UserInputService = game:GetService("UserInputService");

	-- Every color comes from the library's theme. The first pass invented a
	-- blue-gray palette and a 12px radius and read as bolted on; these are the
	-- tokens the library gives its own cards.
	local TH = NeverLose.Lib.theme;

	local CONFIG = userFile("spotify.json");
	local AUTH = "https://accounts.spotify.com/authorize";
	local TOKEN = "https://accounts.spotify.com/api/token";
	local API = "https://api.spotify.com/v1";
	local REDIRECT = "http://127.0.0.1:8888/callback";
	local SCOPES = "user-read-playback-state user-modify-playback-state user-read-currently-playing";

	--------------------------------------------------- normalised state ----
	local Playback = {
		title = "Nothing playing",
		artist = "",
		artwork = "",
		duration = 0,
		position = 0,
		playing = false,
		volume = 50,
		canSeek = false,
		canSkipNext = false,
		canSkipPrevious = false,
		shuffle = false,
		loop = false,
		status = "",
	};

	local HUD = {
		On = false,
		Layout = "Full",
		Artwork = true,
		Controls = true,
		Progress = true,
		Times = true,
		Visualizer = true,
		Opacity = 100,
		Scale = 100,
		Lyrics = false,
		LyricsSize = 150,
		LyricsSpot = "Bottom Left",
		LyricsX = 0,
		LyricsY = 0,
		LyricsPlaced = false,
		Spot = "Bottom Left",
		OffsetX = 0,
		OffsetY = 0,
		AccentColor = Color3.fromRGB(120, 200, 255),
		CoverSize = 52,
	};

	ESP.Music = { Playback = Playback, Hud = HUD };

	------------------------------------------------------------- http ----
	local requestFn = (syn and syn.request) or (http and http.request)
		or rawget(GLOBAL, "http_request") or rawget(GLOBAL, "request");

	local function httpJson(method, url, headers, body)
		if type(requestFn) ~= "function" then return nil, 0 end;

		local ok, res = Remote.invoke(function() return requestFn({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body,
			Timeout = 12,
		}) end, 12);

		if not ok or type(res) ~= "table" then return nil, 0 end;

		local code = tonumber(res.StatusCode or res.Status or 0) or 0;

		if type(res.Body) ~= "string" or res.Body == "" then return nil, code, res end;

		local decoded;

		pcall(function() decoded = HttpService:JSONDecode(res.Body) end);

		return decoded, code, res;
	end;

	local function urlencode(value)
		return (string.gsub(tostring(value), "[^%w%-%._~]", function(c)
			return string.format("%%%02X", string.byte(c));
		end));
	end;

	local function form(pairsTable)
		local parts = {};

		for key, value in pairs(pairsTable) do
			parts[#parts + 1] = key .. "=" .. urlencode(value);
		end;

		return table.concat(parts, "&");
	end;

	------------------------------------------------------------- pkce ----
	local SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";

	local function verifier()
		local out = {};

		for index = 1, 64 do
			local pick = math.random(1, #SAFE);

			out[index] = string.sub(SAFE, pick, pick);
		end;

		return table.concat(out);
	end;

	-- crypt.hash returns hex; the challenge is base64url of the raw digest
	local function challengeFor(text)
		local crypt = rawget(GLOBAL, "crypt");

		if not (crypt and crypt.hash and crypt.base64encode) then return nil end;

		local ok, hex = pcall(crypt.hash, text, "sha256");
		if not ok or type(hex) ~= "string" or #hex ~= 64 or hex:find("[^%x]") then return nil end;

		local raw = (string.gsub(hex, "%x%x", function(byte)
			return string.char(tonumber(byte, 16));
		end));

		local fine, encoded = pcall(crypt.base64encode, raw);
		if not fine or type(encoded) ~= "string" then return nil end;

		encoded = string.gsub(encoded, "%+", "-");
		encoded = string.gsub(encoded, "/", "_");
		encoded = string.gsub(encoded, "=", "");

		return encoded;
	end;

	-- ---------------------------------------------------------- covers ----
	-- Spotify hands back an i.scdn.co URL and an ImageLabel cannot load one -
	-- Image takes rbxassetid, rbxthumb, rbxasset or a local file. So the bytes
	-- are fetched once, written to disk and handed to getcustomasset.
	--
	-- Names are the URL's hash because getcustomasset keys on the basename
	-- alone: two covers both called cover.png resolve to whichever loaded
	-- first. Generated rather than hosted, but it goes in the same flat store.
	local covers, coverBusy, coverRetryAfter = {}, {}, {};

	local function coverFor(url)
		if type(url) ~= "string" or url == "" then return "" end;
		if not string.find(url, "^https?://") then return url end;

		local hit = covers[url];

		if hit then return hit end;
		if coverBusy[url] or (coverRetryAfter[url] or 0) > os.clock() then return "" end;

		coverBusy[url] = true;

		task.spawn(function()
			local ok, asset = pcall(function()
				local body = Remote.download(url);
				if type(body) ~= "string" or #body < 32 or #body > 8 * 1024 * 1024 then return nil end;
				local image = body:sub(1, 8) == "\137PNG\13\10\26\10" or body:sub(1, 3) == "\255\216\255"
					or body:sub(1, 3) == "GIF" or (body:sub(1, 4) == "RIFF" and body:sub(9, 12) == "WEBP");
				if not image then return nil end;
				return Remote.volatile("external-cover/" .. Remote.slug(url) .. ".png", body);
			end);
			if Remote.current() and ok and type(asset) == "string" and asset ~= "" then covers[url] = asset
			else coverRetryAfter[url] = os.clock() + 15 end;
			coverBusy[url] = nil;
		end);

		return "";
	end;

	-- ----------------------------------------------------- local player ----
	-- A Sound in the HUD's own gui, same interface the Spotify provider
	-- exposes, so the panel cannot tell them apart.
	local LocalProvider = { name = "Local" };

	do
		local sound = Instance.new("Sound");
		sound:SetAttribute("VisualsOwned", true);
		sound.Name = NeverLose.RandomString();
		sound.Volume = 0.5;
		sound.Looped = false;
		sound.Parent = NeverLose.ScreenGui;

		local queue, cursor = {}, 0;
		local cover = "";

		LocalProvider.sound = sound;

		local function load(index)
			if #queue == 0 then return end;

			cursor = ((index - 1) % #queue) + 1;

			local entry = queue[cursor];

			if entry.file then
				local ok, asset = pcall(getcustomasset, entry.file);
				sound.SoundId = ok and asset or "";
			else
				sound.SoundId = "rbxassetid://" .. tostring(entry.id);
			end;
			sound.TimePosition = 0;
			sound:Play();
		end;

		-- "12345" or "12345 Artist - Title". The name half is optional, but without
		-- it a track is just an id and the lyrics lookup has nothing to match.
		function LocalProvider.add(text)
			local raw = string.match(tostring(text or ""), "^%s*(.-)%s*$");
			-- свой файл: «file:путь» или имя файла из папки music
			local fileName = string.match(raw, "^file:(.+)$");
			if not fileName then
				local low = string.lower(raw);
				if low:match("%.mp3$") or low:match("%.ogg$") or low:match("%.wav$") then fileName = raw end;
			end;
			if fileName then
				local path = (fileName:find("/", 1, true) or fileName:find("\\", 1, true)) and fileName
					or (CONFIG.MUSIC .. "/" .. fileName);
				path = path:gsub("\\", "/");
				if not (isfile and isfile(path)) then return false end;
				local base = (path:match("([^/]+)$") or path):gsub("%.%a+$", "");
				local artist, title = string.match(base, "^(.-)%s+%-%s+(.+)$");
				queue[#queue + 1] = { file = path, title = title or base, artist = title and artist or nil };
				if #queue == 1 then load(1) end;
				return true;
			end;
			local id = string.match(raw, "(%d+)");

			if not id then return false end;

			local rest = string.match(raw, "^%s*%d+%s*(.-)%s*$") or "";
			local artist, title = string.match(rest, "^(.-)%s*%-%s*(.+)$");

			queue[#queue + 1] = {
				id = id,
				title = title or (rest ~= "" and rest) or ("Track " .. id),
				artist = title and artist or nil,
			};

			if #queue == 1 then load(1) end;

			return true;
		end;

		function LocalProvider.clear()
			sound:Stop();

			table.clear(queue);

			cursor = 0;
		end;

		-- the playlist is a setting, not a runtime object: ids and names
		-- only, no Sound, no handles, nothing that cannot be serialised
		function LocalProvider.dump()
			local out = {};

			for _, entry in ipairs(queue) do
				if entry.file then out[#out + 1] = "file:" .. entry.file; continue end;
				out[#out + 1] = entry.id .. (entry.artist and (" " .. entry.artist .. " - " .. entry.title)
					or (entry.title and (" " .. entry.title) or ""));
			end;

			return out;
		end;

		function LocalProvider.restore(list)
			if type(list) ~= "table" then return end;

			LocalProvider.clear();

			for _, text in ipairs(list) do
				if type(text) == "string" then LocalProvider.add(text) end;
			end;

			sound:Stop();
			sound.TimePosition = 0;
		end;

		function LocalProvider.setCover(url) cover = url or "" end;

		function LocalProvider.play() if sound.SoundId ~= "" then sound:Resume() end end;
		function LocalProvider.pause() sound:Pause() end;
		function LocalProvider.stop() sound:Stop(); sound.TimePosition = 0 end;
		function LocalProvider.replay() sound.TimePosition = 0; sound:Play() end;
		function LocalProvider.next() if #queue > 0 then load(cursor + 1) end end;
		function LocalProvider.previous() if #queue > 0 then load(cursor - 1) end end;
		function LocalProvider.setLoop(v) sound.Looped = v and true or false end;
		function LocalProvider.setVolume(v) sound.Volume = math.clamp(v, 0, 100) / 100 end;
		function LocalProvider.seek(fraction)
			if sound.TimeLength > 0 then sound.TimePosition = sound.TimeLength * math.clamp(fraction, 0, 1) end;
		end;

		function LocalProvider.read(into)
			local entry = queue[cursor];

			into.title = entry and entry.title or "No track queued";
			into.artist = (entry and entry.artist)
				or ((#queue > 0) and (cursor .. " / " .. #queue) or "");
			into.album = "";
			into.artwork = cover;
			into.duration = sound.TimeLength or 0;
			into.position = sound.TimePosition or 0;
			into.playing = sound.IsPlaying;
			into.volume = math.floor(sound.Volume * 100 + 0.5);
			into.canSeek = sound.TimeLength > 0;
			into.canSkipNext = #queue > 1;
			into.canSkipPrevious = #queue > 1;
			into.loop = sound.Looped;
			into.status = "";
		end;

		onUnload("music local", function()
			pcall(function() sound:Stop() end);
			pcall(function() sound:Destroy() end);
		end);
	end;

	----------------------------------------------------------- spotify ----
	local Spotify = { name = "Spotify", connected = false };

	do
		local clientId = "";
		local refreshToken = "";
		local pendingVerifier = nil;
		local access, expires = "", 0;
		local backoffUntil = 0;

		-- The verifier is half of the PKCE pair and useless without the code, but
		-- it has to survive between Connect and pasting the code back. In memory
		-- only, a reinject threw the login away with a misleading message.
		local function save()
			if not writefile then return end;

			pcall(function()
				writefile(CONFIG, HttpService:JSONEncode({
					clientId = clientId,
					refreshToken = refreshToken,
					verifier = pendingVerifier or "",
				}));
			end);
		end;

		local function load()
			if not (isfile and readfile and isfile(CONFIG)) then return end;

			pcall(function()
				local blob = HttpService:JSONDecode(readfile(CONFIG));

				clientId = blob.clientId or "";
				refreshToken = blob.refreshToken or "";
				pendingVerifier = (blob.verifier ~= "" and blob.verifier) or nil;
			end);
		end;

		load();

		function Spotify.setClientId(value)
			clientId = tostring(value or ""):gsub("%s", "");

			save();
		end;

		function Spotify.hasClientId() return clientId ~= "" end;

		local function refresh()
			if clientId == "" or refreshToken == "" then return false end;

			local body, code = httpJson("POST", TOKEN,
				{ ["Content-Type"] = "application/x-www-form-urlencoded" },
				form({
					grant_type = "refresh_token",
					refresh_token = refreshToken,
					client_id = clientId,
				}));

			if code == 200 and body and body.access_token then
				access = body.access_token;
				expires = os.clock() + (tonumber(body.expires_in) or 3600) - 60;

				-- Spotify may hand back a rotated refresh token
				if body.refresh_token then refreshToken = body.refresh_token; save() end;

				Spotify.connected = true;

				return true;
			end;

			-- a refused refresh means the grant is gone; do not spin on it
			if code == 400 or code == 401 then
				refreshToken = "";
				Spotify.connected = false;

				save();
			end;

			return false;
		end;

		local function token()
			if access ~= "" and os.clock() < expires then return access end;

			return refresh() and access or nil;
		end;

		function Spotify.begin()
			if clientId == "" then
				Notification.new({ Title = "Spotify", Content = "No Client ID", Duration = 6 });

				return;
			end;

			pendingVerifier = verifier();

			save();

			local challenge = challengeFor(pendingVerifier);

			if not challenge then
				Notification.new({ Title = "Spotify", Content = "Unsupported executor", Duration = 6 });

				return;
			end;

			local url = AUTH .. "?" .. form({
				client_id = clientId,
				response_type = "code",
				redirect_uri = REDIRECT,
				code_challenge_method = "S256",
				code_challenge = challenge,
				scope = SCOPES,
			});

			pcall(setclipboard, url);

			Notification.new({
				Title = "Spotify",
				Content = "Link copied",
				Duration = 10,
			});
		end;

		function Spotify.finish(code)
			local text = tostring(code or "");
			-- accept either the bare code or the whole redirect URL
			local value = string.match(text, "code=([^&%s]+)") or string.match(text, "^%s*(%S+)%s*$");

			if not value then
				Spotify.lastError = "No code found";

				Notification.new({ Title = "Spotify", Content = Spotify.lastError, Duration = 6 });

				return;
			end;

			if not pendingVerifier then
				Spotify.lastError = "Press Connect first";

				Notification.new({ Title = "Spotify", Content = Spotify.lastError, Duration = 7 });

				return;
			end;

			local body, status = httpJson("POST", TOKEN,
				{ ["Content-Type"] = "application/x-www-form-urlencoded" },
				form({
					grant_type = "authorization_code",
					code = value,
					redirect_uri = REDIRECT,
					client_id = clientId,
					code_verifier = pendingVerifier,
				}));

			pendingVerifier = nil;

			save();

			if status == 200 and body and body.access_token then
				access = body.access_token;
				expires = os.clock() + (tonumber(body.expires_in) or 3600) - 60;
				refreshToken = body.refresh_token or "";
				Spotify.connected = true;

				save();

				Notification.new({ Title = "Spotify", Content = "Connected", Duration = 5 });
			else
				Spotify.connected = false;
				Spotify.lastError = ("http %s: %s"):format(
					tostring(status),
					(body and (body.error_description or body.error)) or "No response"
				);

				Notification.new({
					Title = "Spotify",
					Content = Spotify.lastError,
					Duration = 8,
				});
			end;
		end;

		function Spotify.disconnect()
			access, refreshToken, expires = "", "", 0;
			Spotify.connected = false;

			save();
		end;

		local function call(method, path, body)
			local key = token();

			if not key then return nil, 401 end;

			local headers = { ["Authorization"] = "Bearer " .. key };

			if body then headers["Content-Type"] = "application/json" end;

			return httpJson(method, API .. path, headers, body);
		end;

		Spotify.call = call;

		function Spotify.play() call("PUT", "/me/player/play") end;
		function Spotify.pause() call("PUT", "/me/player/pause") end;
		function Spotify.next() call("POST", "/me/player/next") end;
		function Spotify.previous() call("POST", "/me/player/previous") end;
		function Spotify.setVolume(v) call("PUT", "/me/player/volume?volume_percent=" .. math.floor(math.clamp(v, 0, 100))) end;
		function Spotify.seek(fraction)
			if Playback.duration <= 0 then return end;

			call("PUT", "/me/player/seek?position_ms=" .. math.floor(Playback.duration * math.clamp(fraction, 0, 1) * 1000));
		end;
		function Spotify.stop() Spotify.pause() end;
		function Spotify.replay() Spotify.seek(0) end;
		function Spotify.setLoop(v) call("PUT", "/me/player/repeat?state=" .. (v and "track" or "off")) end;

		-- On a timer, never per frame. Every failure lands on the status line
		-- instead of throwing: no client id, no grant, no active device (204),
		-- private session (403), rate limit (429).
		function Spotify.refreshState(into)
			if clientId == "" then
				into.status = "No Client ID";
				into.title = "Spotify not set up";
				into.artist = "";
				into.playing = false;

				return;
			end;

			if refreshToken == "" and access == "" then
				into.status = "not connected";
				into.title = "Spotify not connected";
				into.artist = "";
				into.playing = false;

				return;
			end;

			if os.clock() < backoffUntil then return end;

			local body, code, raw = call("GET", "/me/player");

			if code == 204 then
				into.status = "No active device";
				into.title = "Nothing playing";
				into.artist = "open Spotify on any device";
				into.artwork = "";
				into.playing = false;
				into.duration, into.position = 0, 0;

				return;
			end;

			if code == 429 then
				local wait = 5;

				if raw and raw.Headers then
					wait = tonumber(raw.Headers["retry-after"] or raw.Headers["Retry-After"]) or 5;
				end;

				backoffUntil = os.clock() + wait;
				into.status = "rate limited";

				return;
			end;

			if code == 401 then
				if refresh() then return end;

				into.status = "session expired";
				into.playing = false;

				return;
			end;

			-- 403 is not always a private session - Spotify also returns it when the
			-- app's account has no Premium, which is now required for any Web API read.
			-- Saying "private session" sent the diagnosis the wrong way, so the reason
			-- Spotify gives is what gets shown.
			if code == 403 then
				local reason = raw and type(raw.Body) == "string" and raw.Body or "";

				if string.find(reason, "premium", 1, true) or string.find(reason, "Premium", 1, true) then
					into.status = "needs Spotify Premium on the app owner";
					into.title = "Spotify unavailable";
				elseif reason ~= "" then
					into.status = string.sub(reason, 1, 90);
					into.title = "Spotify unavailable";
				else
					into.status = "private session";
				end;

				into.artist = "";
				into.artwork = "";
				into.playing = false;
				into.duration, into.position = 0, 0;

				return;
			end;

			if not body or type(body.item) ~= "table" then
				into.title, into.artist, into.album, into.artwork = "Nothing playing", "", "", "";
				into.duration, into.position = 0, 0;
				into.canSeek, into.canSkipNext, into.canSkipPrevious, into.loop, into.shuffle = false, false, false, false, false;
				into.status = (code == 200) and "Nothing playing" or ("http " .. tostring(code));
				into.playing = body and body.is_playing or false;

				return;
			end;

			local item = body.item;
			local artists = {};

			for _, artist in ipairs(item.artists or {}) do artists[#artists + 1] = artist.name end;

			local art = "";

			if item.album and type(item.album.images) == "table" then
				-- smallest image that is still big enough for a 52px cover
				local best;

				for _, image in ipairs(item.album.images) do
					if not best or (image.width and image.width >= 160 and image.width < (best.width or 1e9)) then
						best = image;
					end;
				end;

				art = (best and best.url) or (item.album.images[1] and item.album.images[1].url) or "";
			end;

			into.trackId = item.id;
			into.album = (item.album and item.album.name) or "";
			into.title = item.name or "Unknown";
			into.artist = table.concat(artists, ", ");
			into.artwork = art;
			into.duration = (tonumber(item.duration_ms) or 0) / 1000;
			into.position = (tonumber(body.progress_ms) or 0) / 1000;
			into.playing = body.is_playing and true or false;
			into.shuffle = body.shuffle_state and true or false;
			into.loop = (body.repeat_state or "off") ~= "off";
			into.canSeek = true;
			into.canSkipNext = true;
			into.canSkipPrevious = true;
			into.status = "";

			if body.device and body.device.volume_percent then
				into.volume = body.device.volume_percent;
			end;
		end;
	end;

	-- ---------------------------------------------------------- router ----
	-- --------------------------------------------- streamed providers ----
	-- Roblox will not play an http audio URL - SoundId takes an rbxassetid or a
	-- local file. So a SoundCloud or VK track is pulled to disk once and played
	-- from there, the same as the covers above.
	--
	-- Both are reached through their own API when a key is supplied, and both
	-- also take a direct audio URL, which is the only thing that still works
	-- when an API decides not to answer.
	local audioCache = {};
	local audioBytes = 0;

	local function cacheAudio(url)
		if type(url) ~= "string" or url == "" then return nil, "no url" end;

		if audioCache[url] then return audioCache[url] end;

		if type(writefile) ~= "function" or type(Remote.custom) ~= "function" then
			return nil, "executor cannot write files";
		end;

		-- getcustomasset keys its cache on the basename, so the name has to
		-- be unique per URL rather than per track title
		local stamp;

		pcall(function()
			local hasher = rawget(GLOBAL, "crypt");

			stamp = (hasher and hasher.hash) and string.sub(hasher.hash(url, "sha256"), 1, 24) or nil;
		end);

		stamp = stamp or Remote.slug(url);

		local kind = string.match(string.lower(url):match("^[^?#]+") or "", "%.(%a+)$") or "mp3";

		if kind ~= "mp3" and kind ~= "ogg" and kind ~= "wav" then kind = "mp3" end;

		if not url:match("^https?://") then return nil, "unsupported audio URL" end;
		local bytes = Remote.download(url);
		if type(bytes) ~= "string" or #bytes <= 4096 then return nil, "download failed" end;
		local header = bytes:sub(1, 12);
		local first, second = bytes:byte(1, 2);
		local audio = header:sub(1, 4) == "OggS" or (header:sub(1, 4) == "RIFF" and header:sub(9, 12) == "WAVE")
			or header:sub(1, 3) == "ID3" or (first == 255 and second and bit32.band(second, 224) == 224);
		if not Remote.current() or not audio or #bytes > 32 * 1024 * 1024 then return nil, "invalid audio response" end;
		if audioBytes + #bytes > 128 * 1024 * 1024 then return nil, "audio cache limit reached" end;
		local asset = Remote.volatile("external-audio/" .. stamp .. "." .. kind, bytes);
		if type(asset) ~= "string" or asset == "" then return nil, "asset failed" end;
		audioBytes += #bytes;

		audioCache[url] = asset;

		return asset;
	end;

	-- resolve(text) -> { title, artist, artwork, url, duration } or nil, why
	local function streamProvider(name, resolve)
		local P = { name = name };
		local active, selected, epoch, sequence = true, false, 0, 0;

		local sound = Instance.new("Sound");
		sound:SetAttribute("VisualsOwned", true);
		sound.Name = NeverLose.RandomString();
		sound.Volume = 0.5;
		sound.Looped = false;
		sound.Parent = NeverLose.ScreenGui;

		local queue, cursor, note = {}, 0, "";

		P.sound = sound;

		local function load(index, revision)
			if #queue == 0 or not ALIVE or not active or not selected or (revision and revision ~= epoch) then return end;
			sequence += 1;
			local mine, revision = sequence, epoch;

			cursor = ((index - 1) % #queue) + 1;

			local entry = queue[cursor];

			if not entry.asset then
				note = "loading " .. tostring(entry.title);

				local asset, why = cacheAudio(entry.url);
				if not ALIVE or not active or not selected or epoch ~= revision or sequence ~= mine or not sound.Parent then return end;

				if not asset then
					note = tostring(why);

					return;
				end;

				entry.asset = asset;
			end;

			note = "";
			sound.SoundId = entry.asset;
			sound.TimePosition = 0;
			sound:Play();
		end;

		-- resolving is a web call, so it never runs on the caller's thread
		function P.add(text)
			local revision = epoch;
			task.spawn(function()
				if not ALIVE or not active or revision ~= epoch then return end;
				note = "resolving...";

				local ok, track, why = pcall(resolve, text);
				if not ALIVE or not active or revision ~= epoch then return end;

				if not ok then
					note = tostring(track);

					return;
				end;

				if not track then
					note = tostring(why or "Nothing found");

					return;
				end;

				local list = track.tracks or { track };

				for _, one in ipairs(list) do
					if type(one.url) == "string" and one.url ~= "" then
						queue[#queue + 1] = {
							title = one.title or "Unknown",
							artist = one.artist or "",
							artwork = one.artwork or "",
							duration = tonumber(one.duration) or 0,
							url = one.url,
						};
					end;
				end;

				note = "";

				if cursor == 0 and #queue > 0 then load(1) end;
			end);

			return true;
		end;

		function P.clear()
			epoch += 1; sequence += 1;
			sound:Stop();
			sound.SoundId = "";
			table.clear(queue);
			cursor, note = 0, "";
		end;

		function P.activate() selected = true end;
		function P.play() if selected and sound.SoundId ~= "" then sound:Resume() elseif selected and #queue > 0 then task.spawn(load, math.max(1, cursor), epoch) end end;
		function P.pause() sound:Pause() end;
		function P.stop() epoch += 1; sequence += 1; sound:Stop(); sound.TimePosition = 0 end;
		function P.deactivate() selected = false; epoch += 1; sequence += 1; sound:Pause() end;
		function P.replay() if selected then sound.TimePosition = 0; sound:Play() end end;
		function P.next() if selected and #queue > 0 then task.spawn(load, cursor + 1, epoch) end end;
		function P.previous() if selected and #queue > 0 then task.spawn(load, cursor - 1, epoch) end end;
		function P.setLoop(v) sound.Looped = v and true or false end;
		function P.setVolume(v) sound.Volume = math.clamp(v, 0, 100) / 100 end;

		function P.seek(fraction)
			if sound.TimeLength > 0 then
				sound.TimePosition = sound.TimeLength * math.clamp(fraction, 0, 1);
			end;
		end;

		function P.read(into)
			local entry = queue[cursor];

			into.title = entry and entry.title or (name .. ": nothing queued");
			into.artist = entry and entry.artist or "";
			into.album = "";
			into.artwork = entry and coverFor(entry.artwork) or "";
			into.duration = (sound.TimeLength > 0) and sound.TimeLength or (entry and entry.duration or 0);
			into.position = sound.TimePosition or 0;
			into.playing = sound.IsPlaying;
			into.volume = math.floor(sound.Volume * 100 + 0.5);
			into.canSeek = sound.TimeLength > 0;
			into.canSkipNext = #queue > 1;
			into.canSkipPrevious = #queue > 1;
			into.loop = sound.Looped;
			into.status = note;
		end;

		onUnload("music " .. string.lower(name), function()
			active = false; epoch += 1; sequence += 1; table.clear(queue);
			pcall(function() sound:Stop() end);
			pcall(function() sound:Destroy() end);
		end);

		return P;
	end;

	-- ------------------------------------------------------- ссылки ----
	-- Прямая ссылка на mp3/ogg/wav: файл скачивается в кэш и играет здесь, в игре.
	local function linkResolve(text)
		local raw = string.match(tostring(text or ""), "^%s*(.-)%s*$");
		if raw == "" then return nil, "вставь ссылку на mp3" end;
		if not raw:match("^https?://") then return nil, "это не ссылка" end;
		local path = raw:match("^[^?#]+") or raw;
		local name = string.match(path, "([^/]+)%.%a+$") or "Трек";
		name = name:gsub("%%20", " "):gsub("[_+]", " ");
		local artist, title = string.match(name, "^(.-)%s+%-%s+(.+)$");
		return { title = title or name, artist = title and artist or "", url = raw };
	end;

	local Links = streamProvider("Links", linkResolve);
	ESP.Music.Links = Links;

	local providers = { Local = LocalProvider, Spotify = Spotify, Links = Links };
	local current = "Local";
	local providerEpoch = 0;
	local musicSettings = {volume=50, loop=false};

	ESP.Music.Providers = providers;
	ESP.Music.Local = LocalProvider;
	ESP.Music.Spotify = Spotify;

	local function provider() return providers[current] or LocalProvider end;

	local function command(name, ...)
		local p = provider();
		local fn = p[name];

		if type(fn) == "function" then pcall(fn, ...) end;
	end;

	----------------------------------------------------------- the HUD ----
	local gui = Render.gui("music", 40);
	NeverLose.Lib.themeroots[gui] = true;

	local panel = Instance.new("Frame");
	panel.Name = "NowPlaying";
	panel.BackgroundColor3 = TH.panel;
	panel.BorderSizePixel = 0;
	panel.Size = UDim2.fromOffset(304, 96);
	panel.Visible = false;
	panel.Parent = gui;

	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7);

	pcall(function()
		local shade = Instance.new("UIShadow");
		shade.Color = TH.bg;
		shade.BlurRadius = UDim.new(0, 9);
		shade.Parent = panel;
	end);

	local edge = Instance.new("UIStroke", panel);
	edge.Color = TH.line;
	edge.Transparency = 0.45;
	edge.Thickness = 1;

	local scale = Instance.new("UIScale", panel);

	-- rounded album art; an alpha-less cover on an opaque frame is what
	-- leaves a black square, so the frame behind it is transparent
	local art = Instance.new("ImageLabel");
	art.Name = "Art";
	art.BackgroundColor3 = TH.head;
	art.BorderSizePixel = 0;
	art.Position = UDim2.fromOffset(11, 11);
	art.Size = UDim2.fromOffset(56, 56);
	art.ScaleType = Enum.ScaleType.Crop;
	art.Parent = panel;

	Instance.new("UICorner", art).CornerRadius = UDim.new(0, 6);

	local artEdge = Instance.new("UIStroke", art);
	artEdge.Color = TH.line;
	artEdge.Transparency = 0.6;

	local artMark = Instance.new("ImageLabel");
	artMark.Name = "ArtMark";
	artMark.BackgroundTransparency = 1;
	artMark.AnchorPoint = Vector2.new(0.5, 0.5);
	artMark.Position = UDim2.fromScale(0.5, 0.5);
	artMark.Size = UDim2.fromScale(0.42, 0.42);
	artMark.ScaleType = Enum.ScaleType.Fit;
	artMark.ImageColor3 = TH.dim;
	artMark.ImageTransparency = 0.25;
	artMark.Image = "rbxassetid://" .. tostring(NeverLose.Lib.icons["volume-2"] or 0);
	artMark.Parent = art;

	-- the outgoing cover, faded out under the new one on a track change
	local artOld = art:Clone();
	artOld.Name = "ArtOld";
	artOld.ImageTransparency = 1;
	artOld.BackgroundTransparency = 1;
	artOld.Parent = panel;

	local staleMark = artOld:FindFirstChild("ArtMark");

	if staleMark then staleMark:Destroy() end;

	local source = Instance.new("TextLabel");
	source.Name = "Source";
	source.BackgroundTransparency = 1;
	source.Position = UDim2.fromOffset(78, 9);
	source.Size = UDim2.new(1, -90, 0, 11);
	source.FontFace = NeverLose.BuiltInBold;
	source.TextSize = 9;
	source.TextColor3 = HUD.AccentColor;
	source.TextXAlignment = Enum.TextXAlignment.Left;
	source.TextTruncate = Enum.TextTruncate.AtEnd;
	source.Text = "LOCAL";
	source.Parent = panel;

	local title = Instance.new("TextLabel");
	title.Name = "Title";
	title.BackgroundTransparency = 1;
	title.Position = UDim2.fromOffset(78, 22);
	title.Size = UDim2.new(1, -88, 0, 17);
	title.FontFace = NeverLose.BuiltInBold;
	title.TextSize = 13;
	title.TextColor3 = TH.text;
	title.TextXAlignment = Enum.TextXAlignment.Left;
	title.TextTruncate = Enum.TextTruncate.AtEnd;
	title.Text = "Nothing playing";
	title.ClipsDescendants = true;
	title.Parent = panel;

	local artist = Instance.new("TextLabel");
	artist.Name = "Artist";
	artist.BackgroundTransparency = 1;
	artist.Position = UDim2.fromOffset(78, 39);
	artist.Size = UDim2.new(1, -88, 0, 14);
	artist.FontFace = NeverLose.BuiltInRegular;
	artist.TextSize = 11;
	artist.TextColor3 = TH.dim;
	artist.TextXAlignment = Enum.TextXAlignment.Left;
	artist.TextTruncate = Enum.TextTruncate.AtEnd;
	artist.Text = "";
	artist.Parent = panel;

	local track = Instance.new("Frame");
	track.Name = "Track";
	track.BackgroundColor3 = TH.head;
	track.BorderSizePixel = 0;
	track.Position = UDim2.fromOffset(78, 61);
	track.Size = UDim2.new(1, -90, 0, 3);
	track.Parent = panel;

	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0);

	local fill = Instance.new("Frame");
	fill.Name = "Fill";
	fill.BackgroundColor3 = HUD.AccentColor;
	fill.BorderSizePixel = 0;
	fill.Size = UDim2.fromScale(0, 1);
	fill.Parent = track;

	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0);

	-- a small head on the bar reads as a position rather than a level
	local knob = Instance.new("Frame");
	knob.Name = "Knob";
	knob.AnchorPoint = Vector2.new(0.5, 0.5);
	knob.Position = UDim2.new(1, 0, 0.5, 0);
	knob.Size = UDim2.fromOffset(8, 8);
	knob.BorderSizePixel = 0;
	knob.ZIndex = 3;
	knob.Parent = fill;

	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0);

	local seekHit = Instance.new("TextButton");
	seekHit.Name = "Seek";
	seekHit.BackgroundTransparency = 1;
	seekHit.Text = "";
	seekHit.Position = UDim2.fromOffset(0, -6);
	seekHit.Size = UDim2.new(1, 0, 0, 15);
	seekHit.Parent = track;

	local clock = Instance.new("TextLabel");
	clock.Name = "Clock";
	clock.BackgroundTransparency = 1;
	clock.Position = UDim2.fromOffset(78, 69);
	clock.Size = UDim2.fromOffset(58, 12);
	clock.FontFace = NeverLose.BuiltInRegular;
	clock.TextSize = 10;
	clock.TextColor3 = TH.dim;
	clock.TextXAlignment = Enum.TextXAlignment.Left;
	clock.Text = "0:00";
	clock.Parent = panel;

	local totalClock = clock:Clone();
	totalClock.Name = "Duration";
	totalClock.AnchorPoint = Vector2.new(1, 0);
	totalClock.Position = UDim2.new(1, -12, 0, 69);
	totalClock.TextXAlignment = Enum.TextXAlignment.Right;
	totalClock.Text = "0:00";
	totalClock.Parent = panel;

	-- Transport controls. The first pass built these from a rotated
	-- triangle.png, which is a hollow outline, so play rendered as a wireframe.
	-- These are solid glyphs in assets_server/images, tinted at runtime.
	local GLYPH = {};

	for _, name in ipairs({ "play", "pause", "next", "prev", "stop" }) do
		GLYPH[name] = Remote.asset("images/ui_" .. name .. ".png");
	end;

	local controls = Instance.new("Frame");
	controls.Name = "Controls";
	controls.BackgroundTransparency = 1;
	controls.AnchorPoint = Vector2.new(1, 0);
	controls.Position = UDim2.new(1, -10, 0, 68);
	controls.Size = UDim2.fromOffset(84, 24);
	controls.Parent = panel;

	local IDLE, HOVER, DOWN, OFF = 0.28, 0, 0.1, 0.72;

	-- One builder, so all four behave the same: hit area bigger than the glyph,
	-- fade on hover, squash on press, dim when the provider says no.
	local function transport(name, x, size)
		local holder = Instance.new("ImageButton");
		holder.Name = name;
		holder.BackgroundColor3 = TH.glow;
		holder.BackgroundTransparency = 1;
		holder.BorderSizePixel = 0;
		holder.AutoButtonColor = false;
		holder.Image = "";
		holder.Position = UDim2.fromOffset(x, 0);
		holder.Size = UDim2.fromOffset(size, 24);
		holder.Parent = controls;

		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6);

		local glyph = Instance.new("ImageLabel");
		glyph.Name = "Glyph";
		glyph.BackgroundTransparency = 1;
		glyph.AnchorPoint = Vector2.new(0.5, 0.5);
		glyph.Position = UDim2.fromScale(0.5, 0.5);
		glyph.Size = UDim2.fromOffset(size - 10, size - 10);
		glyph.ScaleType = Enum.ScaleType.Fit;
		glyph.ImageColor3 = TH.text;
		glyph.ImageTransparency = IDLE;
		glyph.Parent = holder;

		local pulse = Instance.new("UIScale", holder);

		local item = { button = holder, glyph = glyph, enabled = true, hovered = false };

		local function repaint()
			local target = IDLE;

			if not item.enabled then
				target = OFF;
			elseif item.down then
				target = DOWN;
			elseif item.hovered then
				target = HOVER;
			end;

			TweenService:Create(glyph, TweenInfo.new(0.12), { ImageTransparency = target }):Play();
			TweenService:Create(holder, TweenInfo.new(0.12), {
				BackgroundTransparency = (item.enabled and item.hovered) and 0.9 or 1,
			}):Play();
			TweenService:Create(pulse, TweenInfo.new(0.09), { Scale = item.down and 0.88 or 1 }):Play();
		end;

		holder.MouseEnter:Connect(function() item.hovered = true; repaint() end);
		holder.MouseLeave:Connect(function() item.hovered, item.down = false, false; repaint() end);
		holder.MouseButton1Down:Connect(function() item.down = true; repaint() end);
		holder.MouseButton1Up:Connect(function() item.down = false; repaint() end);

		function item.setEnabled(on)
			if item.enabled == on then return end;

			item.enabled = on;

			repaint();
		end;

		function item.setGlyph(key)
			glyph.Image = GLYPH[key] or "";
		end;

		item.repaint = repaint;

		return item;
	end;

	local prevBtn = transport("Prev", 0, 24);
	local playBtn = transport("Play", 30, 26);
	local nextBtn = transport("Next", 60, 24);

	prevBtn.setGlyph("prev");
	playBtn.setGlyph("play");
	nextBtn.setGlyph("next");

	-- four bars that breathe while something is playing and settle when not
	local bars = {};

	for index = 1, 4 do
		local b = Instance.new("Frame");
		b.Name = "Bar" .. index;
		b.BackgroundColor3 = HUD.AccentColor;
		b.BorderSizePixel = 0;
		b.AnchorPoint = Vector2.new(0, 1);
		b.Position = UDim2.fromOffset(9 + (index - 1) * 5, 61);
		b.Size = UDim2.fromOffset(3, 4);
		b.Visible = false;
		b.Parent = panel;

		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 1);

		bars[index] = b;
	end;

	local SPOTS = {
		["Top Left"] = Vector2.new(0, 0),
		["Top Right"] = Vector2.new(1, 0),
		["Bottom Left"] = Vector2.new(0, 1),
		["Bottom Right"] = Vector2.new(1, 1),
	};

	local PAD = 16;

	local function place()
		local anchor = SPOTS[HUD.Spot] or SPOTS["Bottom Left"];

		-- Dragging already keeps the panel on screen; the sliders and a restored
		-- config went straight to Position and did not, so a large offset parked
		-- the HUD outside the viewport with no way back.
		--
		-- The allowed range depends on which corner is the anchor - the same +1600
		-- that is harmless from the left is off-screen from the right.
		local camera = workspace.CurrentCamera;
		if not camera then return end;
		local screen = camera.ViewportSize;
		local size = panel.AbsoluteSize;

		local function limit(side, offset, extent, span)
			if extent <= 1 or span <= extent then return offset end;

			local base = (side == 0) and PAD or (span - PAD - extent);

			return math.clamp(offset, -base, span - extent - base);
		end;

		HUD.OffsetX = limit(anchor.X, HUD.OffsetX, size.X, screen.X);
		HUD.OffsetY = limit(anchor.Y, HUD.OffsetY, size.Y, screen.Y);

		panel.AnchorPoint = anchor;
		panel.Position = UDim2.new(
			anchor.X,
			(anchor.X == 0 and PAD or -PAD) + HUD.OffsetX,
			anchor.Y,
			(anchor.Y == 0 and PAD or -PAD) + HUD.OffsetY
		);
	end;

	-- ---------------------------------------------------------- dragging ----
	-- Typing two numbers to move a panel is the wrong way round. Drag it by the
	-- body; the controls and the seek bar take their own clicks.
	--
	-- On release the nearest corner becomes the anchor and the offset is
	-- recomputed against it, so the panel keeps its place when the window
	-- resizes. The sliders are written back through the flag registry so the
	-- position is what a config saves.
	local dragging, dragFrom, dragBase = false, nil, nil;

	-- Declared before every caller. The drag release calls it and so does
	-- relayout; with the declaration below both, the name resolved to a nil
	-- global inside the release handler and pushOffsets never ran.
	local placeLyrics;

	local function pushOffsets()
		for flag, value in pairs({ music_x = HUD.OffsetX, music_y = HUD.OffsetY }) do
			local item = NeverLose.Flags[flag];

			if item and item.SetValue then pcall(item.SetValue, item, value) end;
		end;

		local spot = NeverLose.Flags.music_spot;

		if spot and spot.SetValue then pcall(spot.SetValue, spot, HUD.Spot) end;
	end;

	-- AbsolutePosition is reported relative to the GUI inset even on a
	-- ScreenGui that ignores it, while AbsoluteSize is the whole viewport.
	-- Mixing the two put the panel 58px off from where it was dropped.
	local GuiService = game:GetService("GuiService");

	local function screenAt(object)
		return object.AbsolutePosition + GuiService:GetGuiInset();
	end;

	-- which corner is the panel's own center closest to
	local function snapCorner()
		local screen = NeverLose.ScreenGui.AbsoluteSize;

		if screen.X < 8 or screen.Y < 8 then return end;

		local center = screenAt(panel) + panel.AbsoluteSize * 0.5;
		local right = center.X > screen.X * 0.5;
		local bottom = center.Y > screen.Y * 0.5;

		HUD.Spot = (bottom and "Bottom " or "Top ") .. (right and "Right" or "Left");

		-- keep the panel exactly where it was let go: recompute the offset
		-- against the corner it just snapped to
		local anchor = SPOTS[HUD.Spot];
		local at = screenAt(panel) + panel.AbsoluteSize * Vector2.new(anchor.X, anchor.Y);
		local corner = Vector2.new(anchor.X * screen.X, anchor.Y * screen.Y);
		local base = Vector2.new(anchor.X == 0 and PAD or -PAD, anchor.Y == 0 and PAD or -PAD);

		-- Clamp to the screen, not to the slider range. Clamping to an arbitrary
		-- plus or minus 400 made the panel jump back from wherever it was dropped.
		local reachX = math.max(0, screen.X - panel.AbsoluteSize.X);
		local reachY = math.max(0, screen.Y - panel.AbsoluteSize.Y);

		HUD.OffsetX = math.clamp(math.floor(at.X - corner.X - base.X + 0.5), -reachX, reachX);
		HUD.OffsetY = math.clamp(math.floor(at.Y - corner.Y - base.Y + 0.5), -reachY, reachY);
	end;

	panel.Active = true;

	panel.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		dragging = true;
		dragFrom = input.Position;
		dragBase = Vector2.new(HUD.OffsetX, HUD.OffsetY);
	end);

	NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end;

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		local delta = input.Position - dragFrom;

		HUD.OffsetX = dragBase.X + delta.X;
		HUD.OffsetY = dragBase.Y + delta.Y;

		place();

		-- do not let it be dragged off the edge and lost
		local screen = NeverLose.ScreenGui.AbsoluteSize;
		local at = screenAt(panel);
		local size = panel.AbsoluteSize;
		local pushX = math.clamp(at.X, 0, math.max(0, screen.X - size.X)) - at.X;
		local pushY = math.clamp(at.Y, 0, math.max(0, screen.Y - size.Y)) - at.Y;

		if pushX ~= 0 or pushY ~= 0 then
			HUD.OffsetX = HUD.OffsetX + pushX;
			HUD.OffsetY = HUD.OffsetY + pushY;

			place();
		end;
	end));

	NeverLose:AddSignal(UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end;

		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		dragging = false;

		snapCorner();
		place();
		placeLyrics();
		pushOffsets();
	end));

	-- One color, the menu accent. The three-way Theme/Album Art/Custom switch
	-- made the panel change color on its own, which is what looked wrong.
	local function accent()
		return NeverLose.AccentColor or HUD.AccentColor;
	end;

	local function clockText(seconds)
		seconds = math.max(0, math.floor(seconds or 0));

		return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60);
	end;

	local function relayout()
		local compact = HUD.Layout == "Compact";
		local coverOn = HUD.Artwork;
		local size = compact and math.floor(HUD.CoverSize * 0.58) or HUD.CoverSize;
		local pad = compact and 9 or 12;
		local left = coverOn and (size + pad + 12) or 16;

		art.Visible = coverOn;
		artOld.Visible = coverOn;
		art.Position = UDim2.fromOffset(pad, pad);
		artOld.Position = art.Position;
		art.Size = UDim2.fromOffset(size, size);
		artOld.Size = art.Size;

		-- The cover can grow without clipping, while both layouts keep stable
		-- minimum dimensions so text and controls never push the panel around.
		local height = compact and math.max(62, size + pad * 2) or math.max(96, size + 24);

		panel.Size = UDim2.fromOffset(compact and 268 or 304, height);

		local stacked = HUD.Progress or HUD.Times;
		local top = compact and math.floor((height - 31) / 2) or (stacked and 22 or math.floor((height - 32) / 2));
		source.Visible = not compact;
		source.Position = UDim2.fromOffset(left, 9);
		source.Size = UDim2.new(1, -left - 12, 0, 11);

		-- In the full layout the controls sit on the row below, not beside the
		-- text, so reserving room here only truncated titles that had space.
		local reserve = compact and 38 or 14;

		title.Position = UDim2.fromOffset(left, top);
		title.Size = UDim2.new(1, -left - reserve, 0, 17);

		artist.Position = UDim2.fromOffset(left, top + 17);
		artist.Size = UDim2.new(1, -left - reserve, 0, 14);
		artist.Visible = true;

		track.Position = UDim2.fromOffset(left, height - 35);
		track.Size = UDim2.new(1, -left - 12, 0, 3);
		track.Visible = HUD.Progress and not compact;

		clock.Position = UDim2.fromOffset(left, height - 26);
		clock.Size = UDim2.fromOffset(42, 12);
		clock.Visible = HUD.Times and not compact;
		totalClock.Visible = HUD.Times and not compact;
		if HUD.Controls then
			totalClock.AnchorPoint = Vector2.zero;
			totalClock.Position = UDim2.fromOffset(left + 46, height - 26);
			totalClock.Size = UDim2.fromOffset(42, 12);
		else
			totalClock.AnchorPoint = Vector2.new(1, 0);
			totalClock.Position = UDim2.new(1, -12, 0, height - 26);
			totalClock.Size = UDim2.fromOffset(52, 12);
		end;

		controls.Visible = HUD.Controls;
		controls.Position = compact and UDim2.new(1, -9, 0.5, -12) or UDim2.new(1, -10, 0, height - 31);
		controls.Size = UDim2.fromOffset(compact and 26 or 84, 24);

		prevBtn.button.Visible = not compact;
		nextBtn.button.Visible = not compact;
		playBtn.button.Position = UDim2.fromOffset(compact and 0 or 30, 0);

		-- the equalizer sits in the free strip under the text, not on top of
		-- the artwork, so it only shows when there is room for it
		local barsOn = HUD.Visualizer and not compact and not HUD.Progress;

		for index, b in ipairs(bars) do
			b.Visible = barsOn;
			b.Position = UDim2.fromOffset(left + (index - 1) * 6, height - 14);
		end;

		scale.Scale = HUD.Scale / 100;

		local clear = 1 - HUD.Opacity / 100;

		panel.BackgroundTransparency = clear * 0.88 + 0.04;
		edge.Transparency = 0.35 + clear * 0.6;

		place();
		placeLyrics();
	end;


	-- ----------------------------------------------------------- lyrics ----
	-- Its own panel, drawn like the player so the two read as one set. Lines
	-- come once per track from lrclib - free, no key, no account. Spotify does
	-- not expose lyrics through its Web API at all.
	--
	-- Synced lyrics arrive with timestamps: the current line is highlighted and
	-- the panel scrolls itself. Plain text is shown whole and left alone.
	local LYRICS = "https://lrclib.net/api/get";

	local lyricPanel = Instance.new("Frame");
	lyricPanel.Name = "Lyrics";
	lyricPanel.BackgroundColor3 = TH.panel;
	lyricPanel.BorderSizePixel = 0;
	lyricPanel.Size = UDim2.fromOffset(304, 150);
	lyricPanel.Visible = false;
	lyricPanel.ClipsDescendants = true;
	lyricPanel.Parent = gui;

	Instance.new("UICorner", lyricPanel).CornerRadius = UDim.new(0, 7);

	pcall(function()
		local shade = Instance.new("UIShadow");
		shade.Color = TH.bg;
		shade.BlurRadius = UDim.new(0, 9);
		shade.Parent = lyricPanel;
	end);

	local lyricEdge = Instance.new("UIStroke", lyricPanel);
	lyricEdge.Color = TH.line;
	lyricEdge.Transparency = 0.45;

	local lyricScale = Instance.new("UIScale", lyricPanel);

	-- The head is the track: title, then the artist dimmed. A name wider than
	-- the panel slides to its end and back instead of being cut with dots.
	local headClip = Instance.new("Frame");
	headClip.Name = "Head";
	headClip.BackgroundTransparency = 1;
	headClip.ClipsDescendants = true;
	headClip.Position = UDim2.fromOffset(16, 9);
	headClip.Size = UDim2.new(1, -32, 0, 15);
	headClip.Parent = lyricPanel;

	local lyricHead = Instance.new("TextLabel");
	lyricHead.Name = "Track";
	lyricHead.BackgroundTransparency = 1;
	lyricHead.AutomaticSize = Enum.AutomaticSize.X;
	lyricHead.Size = UDim2.new(0, 0, 1, 0);
	lyricHead.FontFace = NeverLose.BuiltInBold;
	lyricHead.TextSize = 12;
	lyricHead.TextColor3 = TH.text;
	lyricHead.TextXAlignment = Enum.TextXAlignment.Left;
	lyricHead.RichText = true;
	lyricHead.Text = "";
	lyricHead.Parent = headClip;

	local headKey = nil;
	local ESCAPE = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&apos;" };
	local function rich(text) return (string.gsub(text, "[&<>\"']", ESCAPE)) end;

	-- the lines scroll inside here; no scrollbar, it follows the song
	local lyricView = Instance.new("Frame");
	lyricView.Name = "View";
	lyricView.BackgroundTransparency = 1;
	lyricView.ClipsDescendants = true;
	lyricView.Position = UDim2.fromOffset(16, 30);
	lyricView.Size = UDim2.new(1, -32, 1, -41);
	lyricView.Parent = lyricPanel;

	local lyricRoll = Instance.new("Frame");
	lyricRoll.Name = "Roll";
	lyricRoll.BackgroundTransparency = 1;
	lyricRoll.AutomaticSize = Enum.AutomaticSize.Y;
	lyricRoll.Size = UDim2.new(1, 0, 0, 0);
	lyricRoll.Parent = lyricView;

	-- a long line wraps onto the next instead of ending in dots, so rows are
	-- as tall as their text and the layout stacks them
	local lyricList = Instance.new("UIListLayout");
	lyricList.SortOrder = Enum.SortOrder.LayoutOrder;
	lyricList.Padding = UDim.new(0, 5);
	lyricList.Parent = lyricRoll;

	-- room above the first line and below the last, the size of the fade, so
	-- neither has to sit in it
	local lyricPad = Instance.new("UIPadding");
	lyricPad.Parent = lyricRoll;

	-- fades the text out at the top and bottom edge instead of cutting it
	local lyricFade = Instance.new("UIGradient", lyricView);
	lyricFade.Rotation = 90;
	lyricFade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 0),
		NumberSequenceKeypoint.new(0.78, 0),
		NumberSequenceKeypoint.new(1, 1),
	});

	local lyricRows = {};
	local lyricShow = 0;

	local function lyricRow(index)
		local row = lyricRows[index];

		if row then return row end;

		row = Instance.new("TextLabel");
		row.Name = "Line" .. index;
		row.BackgroundTransparency = 1;
		row.AutomaticSize = Enum.AutomaticSize.Y;
		row.Size = UDim2.new(1, 0, 0, 0);
		row.LayoutOrder = index;
		row.FontFace = NeverLose.BuiltInRegular;
		row.TextSize = 12;
		row.LineHeight = 1.1;
		row.TextColor3 = TH.dim;
		row.TextXAlignment = Enum.TextXAlignment.Left;
		row.TextWrapped = true;
		row.Text = "";
		row.Parent = lyricRoll;

		lyricRows[index] = row;

		return row;
	end;

	local lyricState = {
		key = nil,
		lines = {},
		synced = false,
		status = "",
		busy = false,
		offset = 0,
	};
	local function resetLyrics(status)
		lyricState.key = nil;
		lyricState.lines = {};
		lyricState.synced = false;
		lyricState.busy = false;
		lyricState.status = status or "";
		lyricState.offset = 0;
		lyricShow = 0;
		lyricPanel.Visible = false;
		lyricHead.Text, headKey = "", nil;
		for _, row in pairs(lyricRows) do row.Text, row.Visible = "", false end;
	end;

	local function parseSynced(text)
		local lines = {};

		for stamp, body in string.gmatch(text, "%[(%d+:%d+%.?%d*)%]([^\n]*)") do
			local m, sec = string.match(stamp, "(%d+):([%d%.]+)");

			if m then
				local at = tonumber(m) * 60 + (tonumber(sec) or 0);
				local clean = string.match(body, "^%s*(.-)%s*$");

				lines[#lines + 1] = { at = at, text = clean };
			end;
		end;

		return lines;
	end;

	local function parsePlain(text)
		local lines = {};

		for body in string.gmatch(text .. "\n", "([^\n]*)\n") do
			lines[#lines + 1] = { at = nil, text = body };
		end;

		return lines;
	end;

	local function lyricName(value)
		local text = string.lower(tostring(value or ""));
		text = string.gsub(text, "%b()", "");
		text = string.gsub(text, "%b[]", "");
		return string.gsub(text, "[%c%p%s]+", "");
	end;

	local function lyricNameMatches(expected, actual)
		local a, b = lyricName(expected), lyricName(actual);
		if a == "" or b == "" then return false end;
		if a == b then return true end;
		local short, long = (#a < #b) and a or b, (#a < #b) and b or a;
		return #short >= 5 and string.find(long, short, 1, true) ~= nil;
	end;

	local function matchingLyrics(results, title, artist)
		if type(results) ~= "table" then return nil end;
		for _, result in ipairs(results) do
			if type(result) == "table" and lyricNameMatches(title, result.trackName)
				and (artist == "" or lyricNameMatches(artist, result.artistName)) then
				return result;
			end;
		end;
	end;

	local function fetchLyrics(title, artist, album, duration)
		local query = LYRICS .. "?" .. form({
			track_name = title,
			artist_name = artist,
			album_name = album or "",
			duration = math.floor(duration or 0),
		});

		local body, code = httpJson("GET", query, { ["Accept"] = "application/json" });

		-- the exact-match endpoint is strict about duration; fall back to
		-- a plain search when it misses
		if code ~= 200 or type(body) ~= "table"
			or (body.trackName and not lyricNameMatches(title, body.trackName))
			or (artist ~= "" and body.artistName and not lyricNameMatches(artist, body.artistName)) then
			local hits = httpJson("GET", "https://lrclib.net/api/search?" .. form({ track_name = title, artist_name = artist }),
				{ ["Accept"] = "application/json" });

			body = matchingLyrics(hits, title, artist);
		end;

		if type(body) ~= "table" then
			return {}, false, "No lyrics";
		end;

		local lines, synced = {}, false;
		if type(body.syncedLyrics) == "string" and body.syncedLyrics ~= "" then
			lines = parseSynced(body.syncedLyrics);
			synced = #lines > 0;
		end;

		if not synced then
			local plain = body.plainLyrics;

			lines = (type(plain) == "string" and plain ~= "") and parsePlain(plain) or {};
		end;

		return lines, synced, (#lines == 0) and "No lyrics" or "";
	end;

	local function wantLyrics()
		if not (HUD.On and HUD.Lyrics) then return end;

		local title = Playback.title or "";
		local artist = Playback.artist or "";

		-- Lyrics need a track name and do not care which provider gave it. Gating
		-- on Playback.status left the panel saying "needs Spotify" while the local
		-- player was the one playing.
		if title == "" then return end;

		local blocked = {
			["Loading..."] = true,
			["Nothing playing"] = true,
			["No track queued"] = true,
			["Spotify unavailable"] = true,
			["Spotify not connected"] = true,
			["Spotify not set up"] = true,
		};

		if blocked[title] then
			resetLyrics("Nothing playing");

			return;
		end;

		local key = title .. "|" .. artist;

		if lyricState.key == key then return end;

		resetLyrics("searching...");
		lyricState.key = key;
		lyricState.busy = true;

		task.spawn(function()
			local mine = key;
			local ok, lines, synced, status = pcall(fetchLyrics, title, artist, Playback.album, Playback.duration);
			if lyricState.key ~= mine then return end;
			lyricState.busy = false;
			if ok then
				lyricState.lines = lines;
				lyricState.synced = synced;
				lyricState.status = status;
			else
				lyricState.lines = {};
				lyricState.synced = false;
				lyricState.status = "Lyrics unavailable";
			end;
		end);
	end;

	function placeLyrics()
		-- The panel used to be welded to the player's corner. It carries its own
		-- spot and offset now, seeded from the player the first time it is shown so
		-- it still appears beside it.
		if not HUD.LyricsPlaced then
			local anchor = SPOTS[HUD.Spot] or SPOTS["Bottom Left"];
			local gapY = (panel.Size.Y.Offset + 8) * (HUD.Scale / 100);

			HUD.LyricsSpot = HUD.Spot;
			HUD.LyricsX = HUD.OffsetX;
			HUD.LyricsY = HUD.OffsetY + (anchor.Y == 1 and -gapY or gapY);
			HUD.LyricsPlaced = true;

			-- push the seed into the flags, or the reconcile below would
			-- read their untouched 0,0 and drop the panel onto the player
			for flag, value in pairs({ music_lyrics_x = HUD.LyricsX, music_lyrics_y = HUD.LyricsY }) do
				local item = NeverLose.Flags[flag];

				if item and item.SetValue then pcall(item.SetValue, item, value) end;
			end;

			local spot = NeverLose.Flags.music_lyrics_spot;

			if spot and spot.SetValue then pcall(spot.SetValue, spot, HUD.LyricsSpot) end;
		end;

		local anchor = SPOTS[HUD.LyricsSpot] or SPOTS["Bottom Left"];

		lyricPanel.AnchorPoint = anchor;
		lyricScale.Scale = HUD.Scale / 100;

		-- transparency belongs to drawLyrics: it fades the panel in and out,
		-- and writing the flat value here would fight that every frame
		lyricPanel.Size = UDim2.fromOffset(panel.Size.X.Offset, HUD.LyricsSize);

		lyricPanel.Position = UDim2.new(
			anchor.X,
			(anchor.X == 0 and PAD or -PAD) + HUD.LyricsX,
			anchor.Y,
			(anchor.Y == 0 and PAD or -PAD) + HUD.LyricsY
		);
	end;

	-- ----------------------------------------------- dragging the lyrics ----
	-- Same as the player: grab the body, drop it, it snaps its anchor to the
	-- nearest corner and stays where it was let go.
	local lyricDrag, lyricFrom, lyricBase = false, nil, nil;

	local function snapLyrics()
		local screen = NeverLose.ScreenGui.AbsoluteSize;

		if screen.X < 8 or screen.Y < 8 then return end;

		local center = screenAt(lyricPanel) + lyricPanel.AbsoluteSize * 0.5;
		local right = center.X > screen.X * 0.5;
		local bottom = center.Y > screen.Y * 0.5;

		HUD.LyricsSpot = (bottom and "Bottom " or "Top ") .. (right and "Right" or "Left");

		local anchor = SPOTS[HUD.LyricsSpot];
		local at = screenAt(lyricPanel) + lyricPanel.AbsoluteSize * Vector2.new(anchor.X, anchor.Y);
		local corner = Vector2.new(anchor.X * screen.X, anchor.Y * screen.Y);
		local base = Vector2.new(anchor.X == 0 and PAD or -PAD, anchor.Y == 0 and PAD or -PAD);
		local reachX = math.max(0, screen.X - lyricPanel.AbsoluteSize.X);
		local reachY = math.max(0, screen.Y - lyricPanel.AbsoluteSize.Y);

		HUD.LyricsX = math.clamp(math.floor(at.X - corner.X - base.X + 0.5), -reachX, reachX);
		HUD.LyricsY = math.clamp(math.floor(at.Y - corner.Y - base.Y + 0.5), -reachY, reachY);
	end;

	lyricPanel.Active = true;

	lyricPanel.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		lyricDrag = true;
		lyricFrom = input.Position;
		lyricBase = Vector2.new(HUD.LyricsX, HUD.LyricsY);
	end);

	NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
		if not lyricDrag then return end;

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		local delta = input.Position - lyricFrom;

		HUD.LyricsX = lyricBase.X + delta.X;
		HUD.LyricsY = lyricBase.Y + delta.Y;

		placeLyrics();

		local screen = NeverLose.ScreenGui.AbsoluteSize;
		local at = screenAt(lyricPanel);
		local size = lyricPanel.AbsoluteSize;
		local pushX = math.clamp(at.X, 0, math.max(0, screen.X - size.X)) - at.X;
		local pushY = math.clamp(at.Y, 0, math.max(0, screen.Y - size.Y)) - at.Y;

		if pushX ~= 0 or pushY ~= 0 then
			HUD.LyricsX = HUD.LyricsX + pushX;
			HUD.LyricsY = HUD.LyricsY + pushY;

			placeLyrics();
		end;
	end));

	NeverLose:AddSignal(UserInputService.InputEnded:Connect(function(input)
		if not lyricDrag then return end;

		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return;
		end;

		lyricDrag = false;

		snapLyrics();
		placeLyrics();

		for flag, value in pairs({ music_lyrics_x = HUD.LyricsX, music_lyrics_y = HUD.LyricsY }) do
			local item = NeverLose.Flags[flag];

			if item and item.SetValue then pcall(item.SetValue, item, value) end;
		end;

		local spot = NeverLose.Flags.music_lyrics_spot;

		if spot and spot.SetValue then pcall(spot.SetValue, spot, HUD.LyricsSpot) end;
	end));

	local function drawLyrics(position, dt)
		-- An empty panel that says "no lyrics" is worse than no panel. It
		-- only appears once there is something to show.
		local lines = lyricState.lines;
		local want = HUD.On and HUD.Lyrics and #lines > 0;

		lyricShow = lyricShow + ((want and 1 or 0) - lyricShow) * math.min(1, dt * 9);

		if lyricShow < 0.01 then
			lyricPanel.Visible = false;

			return;
		end;

		lyricPanel.Visible = true;

		local tone = accent();
		local clear = 1 - HUD.Opacity / 100;

		-- the whole panel fades and lifts in rather than popping
		lyricPanel.BackgroundTransparency = 1 - (1 - (clear * 0.88 + 0.04)) * lyricShow;
		lyricEdge.Transparency = 1 - (1 - (0.4 + clear * 0.55)) * lyricShow;
		-- the panel sits under UIScales; offsets are in its own units
		local unit = lyricPanel.AbsoluteSize.X / math.max(1, lyricPanel.Size.X.Offset);
		-- the frame it appears, the panel has no size yet: nothing can be
		-- measured, and dividing by it would leave the scroll at NaN for good
		if unit < 0.01 then return end;
		if lyricState.offset ~= lyricState.offset then lyricState.offset = 0 end;

		local title, artist = Playback.title or "", Playback.artist or "";
		if headKey ~= title .. "\0" .. artist .. TH.dim:ToHex() then
			headKey = title .. "\0" .. artist .. TH.dim:ToHex();
			lyricHead.Text = rich(title) .. (artist ~= ""
				and ('<font weight="400" color="#' .. TH.dim:ToHex() .. '">  \u{00B7}  ' .. rich(artist) .. "</font>") or "");
		end;
		lyricHead.TextTransparency = 1 - lyricShow;
		lyricHead.TextColor3 = tone;

		-- too wide: slide to the end and back at a reading pace, resting at both
		local over = (lyricHead.AbsoluteSize.X - headClip.AbsoluteSize.X) / unit;
		local slide = 0;
		if over > 1 then
			local speed, rest = 24, 1.4;
			local move = over / speed;
			local t = os.clock() % (2 * (move + rest));
			slide = (t < rest and 0) or (t < rest + move and (t - rest) * speed)
				or (t < 2 * rest + move and over) or (over - (t - 2 * rest - move) * speed);
		end;
		lyricHead.Position = UDim2.fromOffset(-math.floor(slide + 0.5), 0);

		local active = 0;

		if lyricState.synced then
			for index = 1, #lines do
				if (lines[index].at or 0) <= position then active = index else break end;
			end;
		end;

		local viewH = lyricView.AbsoluteSize.Y / unit;
		local pad = math.floor(viewH * 0.22);
		if lyricPad.PaddingTop.Offset ~= pad then
			lyricPad.PaddingTop, lyricPad.PaddingBottom = UDim.new(0, pad), UDim.new(0, pad);
		end;

		-- synced: the sung line is kept in the middle; plain: the text follows
		-- the song's progress, since it has no times of its own
		local fullH = lyricRoll.AbsoluteSize.Y / unit;
		local target = 0;
		local now = active > 0 and lyricRows[active];
		if lyricState.synced and now then
			local top = (now.AbsolutePosition.Y - lyricRoll.AbsolutePosition.Y) / unit;
			target = top + now.AbsoluteSize.Y / unit / 2 - viewH / 2;
		elseif not lyricState.synced and (Playback.duration or 0) > 0 then
			target = (fullH - viewH) * math.clamp(position / Playback.duration, 0, 1);
		end;
		target = math.clamp(target, 0, math.max(0, fullH - viewH));

		-- framerate independent, so the glide is the same at 30 and 240fps
		lyricState.offset = lyricState.offset + (target - lyricState.offset) * math.min(1, dt * 7);

		lyricRoll.Position = UDim2.fromOffset(0, -math.floor(lyricState.offset + 0.5));

		for index = 1, math.max(#lines, #lyricRows) do
			local entry = lines[index];

			if entry then
				local row = lyricRow(index);

				if row.Text ~= entry.text then row.Text = entry.text ~= "" and entry.text or " " end;
				if not row.Visible then row.Visible = true end;

				-- distance from the line being sung drives everything, so
				-- the current line blooms and its neighbours recede
				local away = lyricState.synced and math.abs(index - active) or 0;
				local near = math.clamp(1 - away / 3.2, 0, 1);
				local isNow = lyricState.synced and index == active;

				local wantAlpha = lyricState.synced and (0.62 - near * 0.62) or 0.1;
				local wantColour = TH.dim:Lerp(tone, isNow and 1 or near * 0.28);

				row.TextTransparency = row.TextTransparency + ((1 - (1 - wantAlpha) * lyricShow) - row.TextTransparency) * math.min(1, dt * 10);
				row.TextColor3 = row.TextColor3:Lerp(wantColour, math.min(1, dt * 10));

			else
				local row = lyricRows[index];

				if row and row.Visible then row.Text, row.Visible = "", false end;
			end;
		end;
	end;

	-- ----------------------------------------------------- the polling ----
	-- One timer, not a per-frame API call. Position is walked locally between
	-- polls so the bar moves smoothly.
	local lastSync = os.clock();
	local pollTask, syncBusy, syncQueued;
	local function playbackKey(state)
		return tostring(state.title or "") .. "|" .. tostring(state.artist or "");
	end;
	local function waitForPlayback()
		resetLyrics("Loading");
		Playback.title = "Loading...";
		Playback.artist = "";
		Playback.album = "";
		Playback.artwork = "";
		Playback.duration = 0;
		Playback.position = 0;
		Playback.playing = false;
		Playback.canSeek = false;
		Playback.canSkipNext = false;
		Playback.canSkipPrevious = false;
		Playback.status = "";
		Playback.trackId = nil;
	end;

	local function sync()
		local p = provider();
		local epoch = providerEpoch;
		local previousTrack = playbackKey(Playback);
		local nextState = table.clone(Playback);

		local ok = pcall(function()
			if p.read then
				p.read(nextState);
			elseif p.refreshState then
				p.refreshState(nextState);
			end;
		end);
		if not ok then nextState.status = "Provider unavailable" end;
		if not ALIVE or epoch ~= providerEpoch or provider() ~= p then return end;
		for key, value in pairs(nextState) do Playback[key] = value end;
		for _, key in ipairs({ "position", "duration", "volume" }) do
			local value = tonumber(Playback[key]);
			Playback[key] = value and value == value and math.abs(value) < math.huge and math.max(0, value) or 0;
		end;
		Playback.volume = math.min(Playback.volume, 100);
		Playback.position = Playback.duration > 0 and math.min(Playback.position, Playback.duration) or Playback.position;
		for _, key in ipairs({ "title", "artist", "artwork", "status" }) do Playback[key] = tostring(Playback[key] or "") end;
		for _, key in ipairs({ "playing", "canSeek", "canSkipNext", "canSkipPrevious", "shuffle", "loop" }) do Playback[key] = Playback[key] == true end;
		if playbackKey(Playback) ~= previousTrack then resetLyrics("Track changed") end;

		lastSync = os.clock();
	end;
	local function requestSync()
		if not ALIVE then return end;
		if syncBusy then syncQueued = true; return end;
		syncBusy = true;
		task.spawn(function()
			repeat
				syncQueued = false;
				pcall(sync);
			until not (ALIVE and syncQueued);
			syncBusy = false;
		end);
	end;

	pollTask = task.spawn(function()
		while ALIVE do
			if HUD.On then requestSync() end;

			-- local playback is cheap to read, the web API is not
			task.wait(current == "Spotify" and 2 or 0.5);
		end;
	end);

	local shownArt = "";
	local shownTitle = "";
	local lastFlagReconcile = -math.huge;
	local frame;
	local function renderHud(dt)
		if not (ALIVE and HUD.On) then return end;

		-- interpolate between syncs rather than jumping once per poll
		local position = Playback.position;

		if Playback.playing then
			position = position + (os.clock() - lastSync);
		end;

		if Playback.duration > 0 then position = math.min(position, Playback.duration) end;

		local tone = accent();

		fill.BackgroundColor3 = tone;
		knob.BackgroundColor3 = tone;
		knob.Visible = Playback.duration > 0;
		artMark.Visible = (art.Image == "");
		artMark.ImageColor3 = tone;

		if Playback.duration > 0 then
			fill.Size = UDim2.fromScale(math.clamp(position / Playback.duration, 0, 1), 1);
		else
			fill.Size = UDim2.fromScale(0, 1);
		end;

		clock.Text = clockText(position);
		totalClock.Text = clockText(Playback.duration);

		local heading = Playback.title or "";

		if heading ~= shownTitle then
			shownTitle = heading;
			title.Text = heading;
		end;

		local status = Playback.status or "";
		local artistName = Playback.artist or "";
		artist.Text = artistName ~= "" and artistName or status;
		source.Text = string.upper(current) .. ((status ~= "" and artistName ~= "") and (" / " .. status) or "");
		source.TextColor3 = tone;

		-- cross-fade the cover on a track change
		local wantArt = coverFor(Playback.artwork);

		if wantArt ~= shownArt then
			artOld.Image = art.Image;
			artOld.ImageTransparency = 0;
			shownArt = wantArt;
			art.Image = wantArt;
			art.ImageTransparency = 1;

			TweenService:Create(art, TweenInfo.new(0.35), { ImageTransparency = 0 }):Play();
			TweenService:Create(artOld, TweenInfo.new(0.35), { ImageTransparency = 1 }):Play();
		end;

		playBtn.setGlyph(Playback.playing and "pause" or "play");
		prevBtn.setEnabled(Playback.canSkipPrevious);
		nextBtn.setEnabled(Playback.canSkipNext);
		seekHit.Active = Playback.canSeek;

		-- The menu and the panel each kept their own copy of the position and could
		-- disagree: a config restore writes widget values quietly on purpose, so no
		-- callback fires and HUD.* keeps whatever a drag left. The flags are the
		-- source of truth. Reconcile four times per second instead of reading every
		-- widget at the render rate.
		local reconcileFlags = os.clock() - lastFlagReconcile >= 0.25;
		if reconcileFlags then lastFlagReconcile = os.clock() end;
		if reconcileFlags and not dragging then
			local spotFlag = NeverLose.Flags.music_spot;
			local xFlag = NeverLose.Flags.music_x;
			local yFlag = NeverLose.Flags.music_y;
			local moved = false;

			if spotFlag then
				local value = spotFlag:GetValue();

				if type(value) == "table" then value = value[1] end;

				if type(value) == "string" and SPOTS[value] and value ~= HUD.Spot then
					HUD.Spot = value;
					moved = true;
				end;
			end;

			if xFlag then
				local value = tonumber(xFlag:GetValue());

				if value and value ~= HUD.OffsetX then HUD.OffsetX = value; moved = true end;
			end;

			if yFlag then
				local value = tonumber(yFlag:GetValue());

				if value and value ~= HUD.OffsetY then HUD.OffsetY = value; moved = true end;
			end;

			if moved then place(); placeLyrics() end;
		end;

		if reconcileFlags and not lyricDrag then
			local spotFlag = NeverLose.Flags.music_lyrics_spot;
			local xFlag = NeverLose.Flags.music_lyrics_x;
			local yFlag = NeverLose.Flags.music_lyrics_y;
			local moved = false;

			if spotFlag then
				local value = spotFlag:GetValue();

				if type(value) == "table" then value = value[1] end;

				if type(value) == "string" and SPOTS[value] and value ~= HUD.LyricsSpot then
					HUD.LyricsSpot = value;
					HUD.LyricsPlaced = true;
					moved = true;
				end;
			end;

			if xFlag then
				local value = tonumber(xFlag:GetValue());

				if value and value ~= HUD.LyricsX then HUD.LyricsX = value; HUD.LyricsPlaced = true; moved = true end;
			end;

			if yFlag then
				local value = tonumber(yFlag:GetValue());

				if value and value ~= HUD.LyricsY then HUD.LyricsY = value; HUD.LyricsPlaced = true; moved = true end;
			end;

			if moved then placeLyrics() end;
		end;

		wantLyrics();
		drawLyrics(position, math.min(dt, 0.1));

		if HUD.Visualizer then
			local beat = os.clock() * 6;

			for index, b in ipairs(bars) do
				if b.Visible then
					local height = Playback.playing
						and (5 + math.abs(math.sin(beat + index * 0.9)) * 11)
						or 4;

					b.Size = UDim2.fromOffset(3, height);
					b.BackgroundColor3 = tone;
				end;
			end;
		end;
	end;
	local function setHud(value)
		local opening = value == true and not HUD.On;
		HUD.On = value == true;
		panel.Visible = HUD.On;
		if HUD.On then
			if opening then waitForPlayback() end;
			if not frame then frame = RunService.RenderStepped:Connect(renderHud) end;
			requestSync();
			renderHud(0);
		else
			if frame then frame:Disconnect(); frame = nil end;
			lyricShow = 0;
			lyricPanel.Visible = false;
		end;
	end;

	playBtn.button.MouseButton1Click:Connect(function()
		if Playback.playing then command("pause") else command("play") end;

		task.delay(0.35, function() if HUD.On then requestSync() end end);
	end);

	nextBtn.button.MouseButton1Click:Connect(function()
		command("next");

		task.delay(0.5, function() if HUD.On then requestSync() end end);
	end);

	prevBtn.button.MouseButton1Click:Connect(function()
		command("previous");

		task.delay(0.5, function() if HUD.On then requestSync() end end);
	end);

	seekHit.MouseButton1Click:Connect(function()
		if not Playback.canSeek then return end;

		local mouse = UserInputService:GetMouseLocation();
		local at = track.AbsolutePosition.X;
		local width = math.max(1, track.AbsoluteSize.X);

		command("seek", math.clamp((mouse.X - at) / width, 0, 1));

		task.delay(0.4, function() if HUD.On then requestSync() end end);
	end);

	-- ------------------------------------------------------------- menu ----
	-- Only the chosen provider's panel is on the page. The others are not
	-- collapsed, they are gone.
	local function showPanels(name)
		local cards = {
			Spotify = Sections.Spotify,
		};

		for key, card in pairs(cards) do
			if card and card.SetVisible then pcall(card.SetVisible, card, key == name) end;
		end;
	end;

	Sections.Music:AddLabel("Provider"):AddDropdown({
		Default = "Local",
		Values = { "Local", "Links", "Spotify" },
		Flag = "music_provider",
		Callback = function(v)
			local previous = provider();
			if previous.deactivate then previous.deactivate() elseif previous.pause then pcall(previous.pause) end;
			providerEpoch += 1;
			current = v;
			waitForPlayback();
			command("activate");
			command("setVolume", musicSettings.volume);
			command("setLoop", musicSettings.loop);

			showPanels(v);
			requestSync();
		end,
	});

	showPanels("Local");

	Sections.Music:AddLabel("Now Playing HUD"):AddToggle({
		Name = "Now Playing HUD",
		Default = false,
		Flag = "music_hud",
		Callback = function(v)
			setHud(v);
		end,
	});

	local function saveQueue()
		SAVED.music_local_queue = LocalProvider.dump();
		saveSoon();
	end;

	local pendingAdd = "";
	Sections.Music:AddLabel("ID или файл"):AddTextInput({
		Default = "", Placeholder = "12345 Исполнитель - Песня  или  песня.mp3",
		Callback = function(v) pendingAdd = tostring(v or "") end,
	});
	Sections.Music:AddButton({ Name = "Добавить в очередь", Callback = function()
		if pendingAdd == "" then
			Notification.new({ Title = "Музыка", Content = "Впиши ID звука Roblox или имя файла из папки music", Duration = 5 });
			return;
		end;
		if LocalProvider.add(pendingAdd) then
			saveQueue();
			setFlag("music_provider", "Local");
			requestSync();
			Notification.new({ Title = "Музыка", Content = "Добавил", Duration = 3 });
		else
			Notification.new({ Title = "Музыка", Content = "Не нашёл: нужен ID или файл в " .. CONFIG.MUSIC, Duration = 6 });
		end;
	end });
	Sections.Music:AddButton({ Name = "Загрузить мои песни (папка music)", Callback = function()
		local n = 0;
		pcall(function()
			if not isfolder(CONFIG.MUSIC) then makefolder(CONFIG.MUSIC) end;
			local files = listfiles(CONFIG.MUSIC);
			table.sort(files);
			for _, f in ipairs(files) do
				local path = tostring(f):gsub("\\", "/");
				local low = string.lower(path);
				if low:match("%.mp3$") or low:match("%.ogg$") or low:match("%.wav$") then
					if LocalProvider.add("file:" .. path) then n += 1 end;
				end;
			end;
		end);
		if n > 0 then
			saveQueue();
			setFlag("music_provider", "Local");
			requestSync();
		end;
		Notification.new({ Title = "Музыка", Content = n > 0 and ("В очереди песен: +" .. n)
			or ("Положи mp3/ogg в workspace/" .. CONFIG.MUSIC .. " и нажми ещё раз"), Duration = 6 });
	end });

	local pendingLink = "";
	Sections.Music:AddLabel("Ссылка на mp3"):AddTextInput({
		Default = "", Placeholder = "https://…/песня.mp3",
		Callback = function(v) pendingLink = tostring(v or "") end,
	});
	Sections.Music:AddButton({ Name = "Добавить ссылку", Callback = function()
		if pendingLink == "" then return end;
		setFlag("music_provider", "Links");
		Links.add(pendingLink);
		task.delay(0.5, requestSync);
	end });

	Sections.Music:AddButton({ Name = "Clear Queue", Callback = function()
		LocalProvider.clear(); Links.clear(); saveQueue(); requestSync();
	end });

	Sections.Music:AddLabel("Loop"):AddToggle({
		Name = "Loop",
		Default = false, Flag = "music_loop",
		Callback = function(v) musicSettings.loop = v; command("setLoop", v) end,
	});

	Sections.Music:AddLabel("Volume"):AddSlider({
		Min = 0, Max = 100, Default = 50, Type = "%", Size = 100,
		Flag = "music_volume",
		Callback = function(v) musicSettings.volume = v; command("setVolume", v) end,
	});

	------------------------------------------------------------ hud tab ----
	Sections.MusicHud:AddLabel("Layout"):AddDropdown({
		Default = "Full", Values = { "Full", "Compact" },
		Flag = "music_layout",
		Callback = function(v) HUD.Layout = v; relayout() end,
	});

	for _, entry in ipairs({
		{ "Show Artwork", "Artwork", "music_show_art", true },
		{ "Show Controls", "Controls", "music_show_controls", true },
		{ "Show Progress", "Progress", "music_show_progress", true },
		{ "Show Time", "Times", "music_show_time", true },
		{ "Show Visualizer", "Visualizer", "music_show_vis", true },
	}) do
		local key = entry[2];

		Sections.MusicHud:AddLabel(entry[1]):AddToggle({
			Name = entry[1], Default = entry[4], Flag = entry[3],
			Callback = function(v) HUD[key] = v; relayout() end,
		});
	end;

	Sections.MusicHud:AddLabel("Lyrics"):AddToggle({
		Name = "Lyrics",
		Default = false,
		Flag = "music_lyrics",
		Callback = function(v)
			HUD.Lyrics = v;
			resetLyrics(v and "Loading" or "");

			placeLyrics();
		end,
	});

	Sections.MusicHud:AddLabel("Lyrics Height"):AddSlider({
		Min = 90, Max = 340, Default = 150, Rounding = 0, Size = 100,
		Flag = "music_lyrics_size",
		Callback = function(v) HUD.LyricsSize = v; placeLyrics() end,
	});

	-- the lyrics window has its own corner and offset, so dragging it is
	-- remembered in a profile the same way the player's position is
	Sections.MusicHud:AddLabel("Lyrics Corner"):AddDropdown({
		Default = "Bottom Left",
		Values = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
		Flag = "music_lyrics_spot",
		Callback = function(v) HUD.LyricsSpot = v; HUD.LyricsPlaced = true; placeLyrics() end,
	});

	Sections.MusicHud:AddLabel("Position"):AddDropdown({
		Default = "Bottom Left",
		Values = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
		Flag = "music_spot",
		Callback = function(v) HUD.Spot = v; place() end,
	});

	-- The four offsets have no sliders any more - the panel is dragged and
	-- snaps to a corner - but where you dropped it is still a setting, so they
	-- go straight into the config pool. Saved and restored, just not shown.
	do
		local hidden = {
			{ "music_x", "OffsetX" },
			{ "music_y", "OffsetY" },
			{ "music_lyrics_x", "LyricsX" },
			{ "music_lyrics_y", "LyricsY" },
		};

		for _, entry in ipairs(hidden) do
			local id, key = entry[1], entry[2];

			NeverLose.Lib:hook(id, "number",
				function() return HUD[key] end,
				function(value)
					local number = tonumber(value);

					if number then
						HUD[key] = number;

						if key == "LyricsX" or key == "LyricsY" then HUD.LyricsPlaced = true end;
					end;
				end);

			-- the drag writes back through NeverLose.Flags, so give it the
			-- same shape the widgets have
			NeverLose.Flags[id] = {
				GetValue = function() return HUD[key] end,
				SetValue = function(_, value)
					local number = tonumber(value);

					if number then HUD[key] = number end;
				end,
			};
		end;
	end;

	-- No offset sliders: drag it, and the corner above is what it snaps to. Two
	-- numbers to type were never the way to move a thing you can see.
	for _, entry in ipairs({
		{ "Opacity", "Opacity", "music_opacity", 10, 100, 100 },
		{ "Scale", "Scale", "music_scale", 60, 180, 100 },
		{ "Cover Size", "CoverSize", "music_cover", 32, 96, 52 },
	}) do
		local key = entry[2];

		Sections.MusicHud:AddLabel(entry[1]):AddSlider({
			Min = entry[4], Max = entry[5], Default = entry[6], Rounding = 0, Size = 100,
			Flag = entry[3],
			Callback = function(v) HUD[key] = v; relayout() end,
		});
	end;


	----------------------------------------------------------- spotify ----
	Sections.Spotify:AddLabel("Client ID"):AddTextInput({
		Default = "",
		Placeholder = "Client ID",
		Flag = "spotify_client",
		Callback = function(v) Spotify.setClientId(v) end,
	});

	Sections.Spotify:AddButton({
		Name = "Connect",
		Callback = function() Spotify.begin() end,
	});

	Sections.Spotify:AddLabel("Paste Code"):AddTextInput({
		Default = "",
		Placeholder = "Paste code",
		Flag = "spotify_code",
		Callback = function(v)
			if #tostring(v or "") > 20 then Spotify.finish(v) end;
		end,
	});

	-- The 403 is about the account that owns the app in the dashboard, not the
	-- one that logged in, so "I have Premium" and the error can both be true.
	-- This reports what the API said.
	Sections.Spotify:AddButton({
		Name = "Test Connection",
		Callback = function()
			task.spawn(function()
				if not Spotify.hasClientId() then
					Notification.new({ Title = "Spotify", Content = "No Client ID", Duration = 6 });

					return;
				end;

				local body, code, raw = Spotify.call("GET", "/me");

				if code == 200 and body then
					Notification.new({
						Title = "Spotify",
						Content = ("Connected as %s (%s)"):format(tostring(body.display_name or body.id), tostring(body.product)),
						Duration = 8,
					});

					return;
				end;

				local reason = (raw and type(raw.Body) == "string" and raw.Body ~= "") and raw.Body or "no response body";

				Notification.new({
					Title = "Spotify",
					Content = "Request failed (" .. tostring(code) .. ")",
					Duration = 12,
				});

				warn("[visuals] spotify /me -> " .. tostring(code) .. ": " .. reason);
			end);
		end,
	});

	Sections.Spotify:AddButton({
		Name = "Disconnect",
		Callback = function()
			Spotify.disconnect();

			Notification.new({ Title = "Spotify", Content = "Disconnected", Duration = 4 });
		end,
	});

	-- ссылка на плейлист / альбом / исполнителя / трек -> включить в твоём Spotify
	local function spotifyTarget(text)
		local raw = tostring(text or "");
		local kind, id = string.match(raw, "open%.spotify%.com/[%w%-]*/?(%a+)/([%w]+)");
		if not kind then kind, id = string.match(raw, "spotify:(%a+):([%w]+)") end;
		if not (kind and id) then return nil end;
		if kind == "track" then return { uris = { "spotify:track:" .. id } } end;
		if kind == "playlist" or kind == "album" or kind == "artist" or kind == "show" then
			return { context_uri = "spotify:" .. kind .. ":" .. id };
		end;
		return nil;
	end;
	local pendingSpotify = "";
	Sections.Spotify:AddLabel("Плейлист / альбом / трек"):AddTextInput({
		Default = "", Placeholder = "https://open.spotify.com/playlist/…",
		Flag = "spotify_link",
		Callback = function(v) pendingSpotify = tostring(v or "") end,
	});
	Sections.Spotify:AddButton({ Name = "Включить в Spotify", Callback = function()
		local body = spotifyTarget(pendingSpotify ~= "" and pendingSpotify or (Flags.spotify_link and Flags.spotify_link.Value) or "");
		if not body then
			Notification.new({ Title = "Spotify", Content = "Вставь ссылку open.spotify.com на плейлист, альбом или трек", Duration = 6 });
			return;
		end;
		task.spawn(function()
			setFlag("music_provider", "Spotify");
			local _, code = Spotify.call("PUT", "/me/player/play", HttpService:JSONEncode(body));
			local msg = (code == 204 or code == 200) and "Включил"
				or code == 404 and "Нет активного устройства: открой Spotify на ПК или телефоне и включи любую песню"
				or code == 403 and "Spotify не дал: для управления нужен Premium"
				or code == 401 and "Сначала подключи Spotify (Client ID → Подключить → код)"
				or ("Ошибка " .. tostring(code));
			Notification.new({ Title = "Spotify", Content = msg, Duration = 8 });
			task.delay(1, requestSync);
		end);
	end });

	Sections.Spotify:AddLabel("Redirect URI: " .. REDIRECT, true);

	relayout();

	if type(SAVED.music_local_queue) == "table" then pcall(LocalProvider.restore, SAVED.music_local_queue) end;

	ESP.ClearMusic = onUnload("music", function()
		setHud(false);
		providerEpoch += 1;

		if pollTask then pcall(task.cancel, pollTask) end;

		pcall(function() lyricPanel:Destroy() end);

		pcall(LocalProvider.stop);
		table.clear(audioCache); table.clear(covers); table.clear(coverBusy);
	end);
end);


------------------------------------------------------------------------ вкладка «Меню» (только отдельный скрипт)
if tMenu then
    local sec = tMenu:Section({ Name = "меню", Side = "Left" })
    sec:Keybind({ Name = "Клавиша меню", Default = SAVED.menu_key or CONFIG.MENU_KEY, Callback = function(k)
        SAVED.menu_key = k
        saveSoon()
        pcall(function() win:SetKey(k) end)
    end })
    if SAVED.menu_key then pcall(function() win:SetKey(SAVED.menu_key) end) end
    sec:Label("Картинки эффектов: workspace/" .. CONFIG.FX .. ". Свои песни: workspace/" .. CONFIG.MUSIC .. ".")
    sec:Button({ Name = "Выгрузить визуалы", Callback = function()
        if env.__SBVisuals then env.__SBVisuals.Destroy() end
    end })
    local info = tMenu:Section({ Name = "о скрипте", Side = "Right" })
    info:Label("Сборка " .. VISUALS_BUILD .. ". Основа — Salad Visuals (исходники выложил сам автор), перенесено и переведено под DOORS.")
    info:Label("Всё, что здесь включаешь, видно только тебе.")
end

------------------------------------------------------------------------ сохранённые настройки
-- значения из файла выставляются в меню сразу, а здесь вызываются их обработчики —
-- уже после того, как построены все фичи
task.defer(function()
    applying = true
    for _, a in ipairs(APPLY) do
        if a.o.Callback then
            local ok, err = pcall(a.o.Callback, a.v)
            if not ok then recordError((a.o.Flag or "?") .. " (загрузка): " .. tostring(err)) end
        end
    end
    applying = false
end)

------------------------------------------------------------------------ выгрузка
local function destroy()
    if not ALIVE then return end
    ALIVE = false
    for i = #CLEANUPS, 1, -1 do
        local ok, err = pcall(CLEANUPS[i].fn)
        if not ok then warn("[Визуалы] уборка " .. tostring(CLEANUPS[i].name) .. ": " .. tostring(err)) end
    end
    for _, c in ipairs(SIGNALS) do pcall(function() c:Disconnect() end) end
    for _, fn in ipairs({ ESP.ClearWeather, ESP.ClearTrail, ESP.ClearCircles, ESP.ClearShaders, ESP.RestoreLighting,
        ESP.RestoreSky, ESP.RestoreFog, ESP.ClearMusic }) do
        if type(fn) == "function" then pcall(fn) end
    end
    if not HOST_WIN then pcall(function() win:Destroy() end) end
    if env.__SBVisuals and env.__SBVisuals.Gen == INIT_GENERATION then env.__SBVisuals = nil end
end
env.__SBVisuals = { Destroy = destroy, Gen = INIT_GENERATION, Errors = ERRORS, Saved = SAVED }

task.delay(1.5, function()
    if not ALIVE then return end
    local missing = not Remote.id("particles/p_glow.png")
    if HOST_WIN and not missing then missing = nil end
    if missing ~= nil then win:Notify({ Title = "Визуалы", Text = missing and ("Нет картинок эффектов в workspace/" .. CONFIG.FX .. " — эффекты будут пустыми")
        or ("Готово. Меню — " .. tostring(SAVED.menu_key or CONFIG.MENU_KEY) .. " или кнопка слева"), Duration = 6 }) end
    if #ERRORS > 0 then
        win:Notify({ Title = "Визуалы", Text = "Не загрузилось частей: " .. #ERRORS .. " (подробно — в консоли F9)", Duration = 8 })
    end
end)

return destroy
end
-- <<< VISUALS

---------------------------------------------------------------- меню настроек

-- Открыть/закрыть: RightShift (CONFIG.MENU_KEY) или круглая кнопка слева на экране.
-- Снег и свет меняются сразу. Украшения строятся при запуске — их переключатели
-- применятся при следующем запуске newyear.lua. Всё сохраняется в newyear_settings.json.
-- menuNotify объявлен выше (раздел «праздник») — уведомления в стиле меню
local okMenu, errMenu = pcall(function()
    if not CONFIG.MENU then return end
    local function snowLive() if live.snow then live.snow() end end
    local function glowLive() if live.glow then live.glow() end end
    local NOW = function() end -- меняется сразу, но отдельно делать ничего не надо (мигание читает CONFIG само)

    local logo = "S"
    pcall(function()
        if getcustomasset and isfile and isfile(CONFIG.MENU_LOGO) then logo = getcustomasset(CONFIG.MENU_LOGO)
        else logo = nyAsset("logo.png") or "S" end -- у друга файла нет — докачается с GitHub
    end)
    local win
    print("[NewYear] Запущена сборка " .. NEWYEAR_BUILD)
    win = SBUI.new({
        Name = "NewYearMenu", Title = "Новый год", Logo = logo, Key = CONFIG.MENU_KEY,
        OpenOnStart = CONFIG.MENU_OPEN_ON_START,
        Changelog = CONFIG.CHANGELOG and {
            Title = "Новый год в DOORS", Version = "v2.0 · сборка " .. NEWYEAR_BUILD .. " — что нового",
            Lines = {
                "Новые вкладки: «Погода и свет», «Следы», «Музыка» — погода, шейдеры, небо, следы, круги, плеер",
                "Коврики убраны — странно ложились",
                "Без кика за бездействие (тихо, всегда)",
                "Экран смерти игры — как окна инвентаря: рамка, снег, гирлянда",
                "Открытка смерти: каждый раз новая фраза",
                "Ключ от электрощитовой в 100-й — тоже трость",
                "Подарки-ящики больше не мерцают полосами",
                "100-я: подарки ровно на полках, щитки — конфеты",
            },
            Button = "Поехали!",
        } or nil,
        OnLogoClick = function(n) if n == 5 then pcall(toggleNewYearClock) end end,
        FreeMouse = true, Background = "network", Size = Vector2.new(CONFIG.MENU_W, CONFIG.MENU_H),
        OnResize = function(w, h) if win and win.OnResizeHook then win.OnResizeHook(w, h) end end,
    })
    track(win.Gui)
    table.insert(connections, { Disconnect = function() win:Destroy() end })
    menuNotify = function(title, text, duration) win:Notify({ Title = title, Text = text, Duration = duration }) end

    local bound = {}
    local resetLook -- задаётся ниже, в разделе «вид»
    local hinted = false
    local function restartHint()
        if hinted then return end
        hinted = true
        win:Notify({ Title = "Применится при перезапуске",
            Text = "Украшения и монстры ставятся при запуске — перезапусти newyear.lua, чтобы увидеть.", Duration = 6 })
    end
    -- переключатель, привязанный к CONFIG; liveFn = nil — применится при перезапуске
    local function toggle(sec, key, name, liveFn)
        if CONFIG[key] == nil then return end
        local el = sec:Toggle({ Name = name, Default = CONFIG[key], Callback = function(v)
            CONFIG[key] = v
            if liveFn then pcall(liveFn) else restartHint() end
            saveSettings()
        end })
        table.insert(bound, { key, el })
        return el
    end
    local function slider(sec, key, name, min, max, step, fmt, liveFn, mul)
        if CONFIG[key] == nil then return end
        local el = sec:Slider({ Name = name, Min = min, Max = max, Step = step, Default = CONFIG[key],
            Format = function(v)
                local x = v * (mul or 1)
                if fmt:find("%%d") then x = math.floor(x + 0.5) end
                return fmt:format(x)
            end,
            Callback = function(v)
                CONFIG[key] = v
                if liveFn then pcall(liveFn) end
            end,
            OnRelease = function()
                if not liveFn then restartHint() end
                saveSettings()
            end,
        })
        table.insert(bound, { key, el })
        return el
    end

    -- снег
    local tSnow = win:Tab({ Name = "Снег", Desc = "снегопад и ветер", Icon = "❄" })
    local fall = tSnow:Section({ Name = "снегопад", Side = "Left" })
    local snowT = toggle(fall, "SNOW", "Снег идёт", snowLive)
    slider(fall, "SNOW_RATE", "Сколько падает", 0, 400, 5, "%d/с", snowLive)
    if snowT then
        local more = snowT:Settings("снежинки")
        slider(more, "SNOW_SPEED", "Скорость падения", 0.2, 3, 0.1, "×%.1f", snowLive)
        slider(more, "SNOW_SIZE", "Размер снежинок", 0.4, 3, 0.1, "×%.1f", snowLive)
    end
    local wind = tSnow:Section({ Name = "ветер", Side = "Right" })
    slider(wind, "SNOW_WIND", "Сила ветра", 0, 10, 0.5, "%.1f", snowLive)
    slider(wind, "SNOW_WIND_DIR", "Откуда дует", 0, 355, 5, "%d°", snowLive)
    toggle(wind, "SNOW_GUSTS", "Порывы ветра", snowLive)
    wind:Label("10 — метель. Порывы: ветер то стихает, то задувает сильнее.")

    -- свет
    local tLight = win:Tab({ Name = "Свет", Desc = "свечение и гирлянды", Icon = "@sun" })
    local glow = tLight:Section({ Name = "свечение", Side = "Left" })
    local glowT = toggle(glow, "GLOW", "Свечение огоньков", glowLive)
    if glowT then
        slider(glowT:Settings("свечение"), "GLOW_STRENGTH", "Сила свечения", 0, 2, 0.05, "%.2f", glowLive)
    end
    toggle(glow, "WARM_COLORS", "Тёплые цвета", glowLive)
    local blink = tLight:Section({ Name = "гирлянды", Side = "Right" })
    slider(blink, "BLINK", "Мигание", 0.15, 2, 0.05, "раз в %.2f с", NOW)

    -- украшения (+ вложенная вкладка «Мишура»)
    local tDecor = win:Tab({ Name = "Украшения", Desc = "после перезапуска", Icon = "★" })
    local doors = tDecor:Section({ Name = "двери", Side = "Left" })
    toggle(doors, "GARLANDS", "Гирлянды")
    toggle(doors, "WREATHS", "Венки")
    local spots = tDecor:Section({ Name = "особые места", Side = "Left" })
    toggle(spots, "CELLAR", "Подарки в подвале")
    toggle(spots, "FALLING_SHELF", "Падающий шкаф")
    toggle(spots, "GIFT_BOOKS", "Подарки вместо книг")
    toggle(spots, "HIDE_JUNK", "Убрать доски, паутину")
    local treats = tDecor:Section({ Name = "мелочи", Side = "Left" })
    toggle(treats, "CHOCO_COINS", "Шоколадные монеты вместо золота")
    toggle(treats, "FESTIVE_CANDLES", "Праздничные свечи")
    toggle(treats, "TABLE_CLUTTER", "Открытки и подарки на столах")
    toggle(treats, "CHEST_GIFTS", "Сундуки — подарки")
    local smT = toggle(treats, "SNOWMEN", "Снеговики у ёлок")
    if smT then
        slider(smT:Settings("снеговики"), "SNOWMAN_TREE_CHANCE", "У скольких ёлок", 0, 1, 0.05, "%.0f%%", nil, 100)
    end
    toggle(treats, "FIREPLACES", "Камины: чулки и искорки")
    toggle(treats, "WINDOW_SNOW", "Снег за окнами")
    local function fringeLive() if live.fringe then live.fringe() end end
    local function fringeLightLive() if live.fringeLight then live.fringeLight() end end
    local frT = toggle(treats, "FRINGE", "Бахрома под потолком", fringeLive)
    if frT then
        local fs = frT:Settings("бахрома")
        slider(fs, "FRINGE_ROWS", "Рядов на карнизе", 1, 3, 1, "%d", fringeLive)
        slider(fs, "FRINGE_STEP", "Между нитями", 0.3, 1.5, 0.05, "%.2f", fringeLive)
        slider(fs, "FRINGE_LENGTH", "Длина нитей", 0.4, 2, 0.05, "%.0f%%", fringeLive, 100)
        slider(fs, "FRINGE_BRIGHTNESS", "Яркость", 0, 1, 0.05, "%.0f%%", fringeLightLive, 100)
    end
    local function uiLive() if live.ui then live.ui() end end
    local uiSec = tDecor:Section({ Name = "интерфейс DOORS", Side = "Right" })
    toggle(uiSec, "UI_FESTIVE", "Новогодний интерфейс", uiLive)
    toggle(uiSec, "UI_HEALTH", "Здоровье: трость и снег", uiLive)
    toggle(uiSec, "UI_HOTBAR", "Слоты: шарики на гирлянде", uiLive)
    toggle(uiSec, "UI_WINDOWS", "Окна: меню, инвентарь, магазин, админка", uiLive)
    toggle(uiSec, "DEATH_SCREEN", "Открытка смерти: кто и у какой двери")
    local r100 = tDecor:Section({ Name = "100-я комната", Side = "Left" })
    toggle(r100, "BREAKER_CANDY", "Щитки — конфеты (и на счётчике)")
    toggle(r100, "CANDY_EAT", "Съедать конфету, когда подобрал", NOW)
    toggle(r100, "CRATE_GIFTS", "Ящики — подарки")
    toggle(r100, "MEAT_FESTIVE", "Мясо: венки и сугробы")
    do
        local BARREL_MODES = { { "tin", "банки с бантом" }, { "candy", "леденцы" }, { "gift", "подарки" }, { "off", "как в игре" } }
        local names, cur = {}, nil
        for _, m in ipairs(BARREL_MODES) do
            table.insert(names, m[2])
            if m[1] == CONFIG.OIL_BARRELS then cur = m[2] end
        end
        r100:Dropdown({ Name = "Бочки", Options = names, Default = cur or names[1], Width = 120, Callback = function(v)
            for _, m in ipairs(BARREL_MODES) do
                if m[2] == v then CONFIG.OIL_BARRELS = m[1] end
            end
            saveSettings()
            restartHint()
        end })
    end
    local doorsMore = tDecor:Section({ Name = "двери: ещё", Side = "Right" })
    toggle(doorsMore, "CLOSET_LIGHTS", "Гирлянда в шкафах (когда прячешься)")
    local misT = toggle(doorsMore, "MISTLETOE", "Омела")
    if misT then slider(misT:Settings("омела"), "MISTLETOE_CHANCE", "Над сколькими дверями", 0, 1, 0.05, "%.0f%%", nil, 100) end
    local stT = toggle(doorsMore, "DOOR_STICKERS", "Снежинки на дверях")
    if stT then slider(stT:Settings("снежинки"), "DOOR_STICKER_CHANCE", "На скольких дверях", 0, 1, 0.05, "%.0f%%", nil, 100) end
    local popT = toggle(doorsMore, "POPPERS", "Хлопушки", NOW)
    if popT then
        local ps = popT:Settings("хлопушки")
        slider(ps, "POPPER_EVERY", "Каждая N-я дверь", 1, 25, 1, "%d", NOW)
        slider(ps, "POPPER_CONFETTI", "Конфетти", 10, 120, 5, "%d", NOW)
        slider(ps, "POPPER_VOLUME", "Громкость", 0, 2, 0.05, "%.0f%%", NOW, 100)
        toggle(ps, "POPPER_FINALE", "Салют на 100-й двери", NOW)
    end
    local roomsSec = tDecor:Section({ Name = "комнаты", Side = "Right" })
    local treesT = toggle(roomsSec, "TREES", "Ёлочки")
    if treesT then
        local ts = treesT:Settings("ёлочки")
        slider(ts, "GIFTS", "Подарков под ёлкой", 0, 6, 1, "%d")
        toggle(ts, "GLOW_ORNAMENTS", "Светящиеся стеклянные игрушки", refreshGlow)
    end
    toggle(roomsSec, "SHELVES", "Книжные шкафы")
    toggle(roomsSec, "WARDROBES", "Гардеробы")
    toggle(roomsSec, "WALLPAPER", "Обои")
    toggle(roomsSec, "FROST_WINDOWS", "Иней на окнах")
    local paintT = toggle(roomsSec, "PAINTINGS", "Картины")
    if paintT then
        slider(paintT:Settings("картины"), "PAINTING_CHANCE", "Доля новогодних", 0, 1, 0.05, "%.0f%%", nil, 100)
    end

    local tTinsel = tDecor:Tab({ Name = "Мишура", Desc = "люстры, лампы, перила", Icon = "@garland" })
    local tins = tTinsel:Section({ Name = "мишура", Side = "Left" })
    toggle(tins, "TINSEL", "Мишура")
    toggle(tins, "TINSEL_CHANDELIERS", "На люстрах")
    toggle(tins, "TINSEL_LAMPS", "На настенных лампах")
    toggle(tins, "TINSEL_RAILINGS", "На перилах")
    local fluff = tTinsel:Section({ Name = "вид", Side = "Right" })
    slider(fluff, "TINSEL_DENSITY", "Пушистость", 10, 80, 2, "%d")

    -- монстры и вещи
    local tMon = win:Tab({ Name = "Монстры", Desc = "шапки и костюмы", Icon = "@eye" })
    local mons = tMon:Section({ Name = "монстры", Side = "Left" })
    toggle(mons, "MONSTER_HATS", "Шапки Санты")
    toggle(mons, "SCREECH_TOPHAT", "Цилиндр Скричу")
    local rushT = toggle(mons, "RUSH_FESTIVE", "Раш: голубой, с бубенцами")
    if rushT then slider(rushT:Settings("раш"), "RUSH_BELLS_VOLUME", "Громкость бубенцов", 0, 2, 0.05, "%.0f%%", nil, 100) end
    toggle(mons, "AMBUSH_BELLS", "Эмбуш: с бубенцами")
    local scrT = toggle(mons, "SCREECH_BELL", "Скрич: колокольчик")
    if scrT then slider(scrT:Settings("скрич"), "SCREECH_BELL_VOLUME", "Громкость", 0, 2, 0.05, "%.0f%%", nil, 100) end
    toggle(mons, "HALT_SNOW", "Халт: снег вместо огоньков")
    local figT = toggle(mons, "FIGURE_COSTUME", "Костюм Фигуры")
    if figT then toggle(figT:Settings("фигура"), "FIGURE_ANIMS", "Новогодние анимации") end
    local chase = tMon:Section({ Name = "погоня сика", Side = "Left" })
    toggle(chase, "SEEK_OUTFIT", "Шарф и гирлянда на Сике")
    toggle(chase, "SEEK_SNOW", "Снег вместо жижи")
    toggle(chase, "SEEK_CANDY_ARMS", "Руки-леденцы")
    toggle(chase, "CHANDELIER_SPARKS", "Искры от люстр")
    local things = tMon:Section({ Name = "вещи", Side = "Right" })
    toggle(things, "BUDDY_HAT", "Шапочка бадди")
    toggle(things, "CANDY_KEY", "Ключ-трость")
    toggle(things, "CANE_EAT", "Съедать трость")

    -- визуалы: погода, свет, шейдеры и небо, следы, круги, музыка (модуль из visuals_src)
    if CONFIG.VISUALS and NY_Visuals then
        local okV, visDestroy = pcall(NY_Visuals, win, SBUI)
        if okV and type(visDestroy) == "function" then
            table.insert(connections, { Disconnect = function() pcall(visDestroy) end })
        elseif not okV then
            warn("[NewYear] Визуалы: " .. tostring(visDestroy))
        end
    end

    -- настройки
    local tSet = win:Tab({ Name = "Настройки", Desc = "меню и сброс", Icon = "⚙" })
    local menuSec = tSet:Section({ Name = "меню", Side = "Left" })
    toggle(menuSec, "CHANGELOG", "Окно «что нового» при запуске")
    toggle(menuSec, "MENU_OPEN_ON_START", "Открывать меню при запуске")
    local keyEl = menuSec:Keybind({ Name = "Открыть меню", Default = CONFIG.MENU_KEY, Callback = function(k)
        CONFIG.MENU_KEY = k
        win:SetKey(k)
        saveSettings()
    end })
    toggle(menuSec, "NOTIFY", "Уведомления", NOW)
    local resetSec = tSet:Section({ Name = "сброс", Side = "Right" })
    resetSec:Button({ Name = "Сбросить всё как было", Callback = function()
        for k, v in pairs(CONFIG_DEFAULTS) do CONFIG[k] = v end
        saveSettings()
        for _, b in ipairs(bound) do pcall(function() b[2]:Set(CONFIG[b[1]], true) end) end
        keyEl:Set(CONFIG.MENU_KEY, true)
        win:SetKey(CONFIG.MENU_KEY)
        if resetLook then resetLook() end
        snowLive()
        glowLive()
        win:Notify({ Title = "Сброшено", Text = "Все настройки как в начале.", Duration = 4 })
    end })
    local armed = false
    local offBtn
    offBtn = resetSec:Button({ Name = "Выключить новый год", Callback = function()
        if not armed then
            armed = true
            offBtn:SetText("Точно? Нажми ещё раз")
            task.delay(3, function()
                armed = false
                pcall(function() offBtn:SetText("Выключить новый год") end)
            end)
            return
        end
        if env.__NewYearDoors then env.__NewYearDoors.Destroy() end
    end })
    resetSec:Label("Выключение убирает всё новогоднее до следующего запуска скрипта.")

    -- вид меню: цвета, темы, размер
    local function col(key) return SBUI.FromHex(CONFIG[key]) end
    local function applyColors() win:SetColors(col("MENU_BG"), col("MENU_ACCENT"), col("MENU_TEXT")) end
    local colorQueued = false
    local function applyColorsSoon() -- пока тянешь по палитре — перекрашиваем не чаще 20 раз в секунду
        if colorQueued then return end
        colorQueued = true
        task.delay(0.05, function()
            colorQueued = false
            applyColors()
        end)
    end
    local PRESETS = {
        { "Тёмная", "#0A0A0B", "#FFFFFF", "#EEEEF0" },
        { "Новогодняя", "#0F0809", "#DC323C", "#F5ECE4" },
        { "Ёлочная", "#070C09", "#46BE6E", "#ECF4EC" },
        { "Ледяная", "#080B10", "#82C8FF", "#E8F0FA" },
        { "Золотая", "#0C0A07", "#E8BE5A", "#F4EEE2" },
        { "Фиолетовая", "#0B0910", "#A57CFF", "#EEEAF8" },
    }
    local presetNames = {}
    for _, pr in ipairs(PRESETS) do table.insert(presetNames, pr[1]) end
    local function currentPreset()
        for _, pr in ipairs(PRESETS) do
            if pr[2] == CONFIG.MENU_BG and pr[3] == CONFIG.MENU_ACCENT and pr[4] == CONFIG.MENU_TEXT then return pr[1] end
        end
        return "своя"
    end

    local look = tSet:Section({ Name = "цвета", Side = "Left" })
    local pickers = {}
    local presetEl = look:Dropdown({ Name = "Тема", Options = presetNames, Default = currentPreset(), Width = 120,
        Callback = function(name)
            for _, pr in ipairs(PRESETS) do
                if pr[1] == name then CONFIG.MENU_BG, CONFIG.MENU_ACCENT, CONFIG.MENU_TEXT = pr[2], pr[3], pr[4] end
            end
            for key, el in pairs(pickers) do el:Set(col(key), true) end
            applyColors()
            saveSettings()
        end })
    local function picker(key, name)
        pickers[key] = look:ColorPicker({ Name = name, Default = col(key) or Color3.new(1, 1, 1),
            Callback = function(c)
                CONFIG[key] = SBUI.ToHex(c)
                applyColorsSoon()
            end,
            OnRelease = function()
                presetEl:Set(currentPreset(), true)
                saveSettings()
            end })
    end
    picker("MENU_ACCENT", "Акцент")
    picker("MENU_BG", "Фон")
    picker("MENU_TEXT", "Текст")

    local sizeSec = tSet:Section({ Name = "размер", Side = "Right" })
    local function resize() win:SetSize(CONFIG.MENU_W, CONFIG.MENU_H) end
    slider(sizeSec, "MENU_SCALE", "Масштаб", 0.6, 1.5, 0.05, "×%.2f", function() win:SetScale(CONFIG.MENU_SCALE) end)
    local wEl = slider(sizeSec, "MENU_W", "Ширина", 540, 1100, 10, "%d", resize)
    local hEl = slider(sizeSec, "MENU_H", "Высота", 340, 760, 10, "%d", resize)
    sizeSec:Label("Ещё можно тянуть за уголок окна справа снизу.")
    win.OnResizeHook = function(w, h)
        CONFIG.MENU_W, CONFIG.MENU_H = w, h
        if wEl then wEl:Set(w, true) end
        if hEl then hEl:Set(h, true) end
        saveSettings()
    end
    local function applyLook()
        for key, el in pairs(pickers) do el:Set(col(key), true) end
        presetEl:Set(currentPreset(), true)
        applyColors()
        win:SetScale(CONFIG.MENU_SCALE)
        resize()
    end
    sizeSec:Button({ Name = "Вернуть вид как был", Callback = function()
        for _, k in ipairs({ "MENU_BG", "MENU_ACCENT", "MENU_TEXT", "MENU_W", "MENU_H", "MENU_SCALE" }) do
            CONFIG[k] = CONFIG_DEFAULTS[k]
        end
        for _, b in ipairs(bound) do pcall(function() b[2]:Set(CONFIG[b[1]], true) end) end
        applyLook()
        saveSettings()
    end })
    resetLook = applyLook
    applyLook() -- сохранённые цвета и размер
end)
report("Menu", okMenu, errMenu)

-- без кика за бездействие (20 минут): тихо, всегда, нигде не показывается; общий с admin_plus.lua
pcall(function()
    if env.__SB_AntiAfk then return end
    local vu = game:GetService("VirtualUser")
    env.__SB_AntiAfk = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)

---------------------------------------------------------------- выключение

env.__NewYearDoors = {
    Destroy = function()
        env.__NewYearBlinkToken = nil
        if cleanupCane then pcall(cleanupCane) end
        for _, c in ipairs(connections) do c:Disconnect() end
        for _, inst in ipairs(created) do pcall(function() inst:Destroy() end) end
        for _, r in ipairs(restoreHidden) do
            pcall(function() r[1][r[2]] = r[3] end)
        end
        for _, r in ipairs(restoreProps) do
            pcall(function() r[1][r[2]] = r[3] end)
        end
        env.__NewYearDoors = nil
    end,
    Scan = scanRooms, -- можно вызвать вручную: getgenv().__NewYearDoors.Scan()
    -- для admin_plus.lua: включён ли новогодний вид окон (тогда и его вкладка «Пресеты» новогодняя)
    UIActive = function() return CONFIG.UI_FESTIVE and CONFIG.UI_WINDOWS end,
}

local function notify(title, text, duration)
    if not CONFIG.NOTIFY then return end
    if menuNotify then
        pcall(menuNotify, title, text, duration)
        return
    end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 6,
        })
    end)
end

notify("С Новым годом!", "Новогодний DOORS запущен")
-- через несколько секунд — что получилось (видно и без консоли)
task.delay(4, function()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    local text = ("Гирлянд на дверях: %d, ёлок: %d, подарков: %d, обоев: %d, окон в инее: %d, шапок: %d, тростей: %d, шкафов: %d (спрятано книг и паутины: %d)%s")
        :format(doorCount, treeCount, giftCount, wallpaperCount, frostCount, hatCount + monsterHatCount, caneCount, shelfCount, shelfHidden,
        rooms and "" or ", комнаты не найдены")
    if #status > 0 then text = text .. ". Ошибки: " .. table.concat(status, "; ") end
    notify(#status > 0 and "Новый год: есть ошибки" or "Новый год: всё включено", text, 10)
    print("[NewYear] " .. text)
end)
print("[NewYear] Включено." .. (CONFIG.SCAN and " Через 8 секунд сохраню скан текстур комнат." or ""))
