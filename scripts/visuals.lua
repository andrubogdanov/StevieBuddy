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
local HOST_WIN = nil -- @HOST (в newyear.lua сюда приходит его окно меню)

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


-- >>> SBUI (копия ui.lua — правь ui.lua и запускай build_visuals.py)
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
