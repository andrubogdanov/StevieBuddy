--[[
    Visual Buddy (client-side) — видишь только ты.

    Режим "reskin": если у тебя есть настоящий бадди из DOORS, скрипт прячет
    его модель и цепляет вместо неё Стиви. Круглый слот, цифра, родные
    анимации (whack / inspect / equip) — всё остаётся от игры.

    Режим "tool": если бадди нет, создаётся свой Tool с теми же атрибутами,
    что у настоящего бадди (InspectOnly, CannotDrop, ToolColor...), чтобы
    хотбар показал его в круглом слоте.

    ЛКМ  — прыжок к камере
    ПКМ  — по кругу: взгляд вправо -> взгляд влево -> разворот спиной
    Лица берутся из с й модели (папка Faces), экран иногда "моргает".
]]

local CONFIG = {
    MODE = "auto",                  -- "auto" | "reskin" | "tool"
    NAME = "Buddy",

    -- Ассеты (иконка и звуки) скачиваются в workspace/ASSET_FOLDER при первом запуске.
    -- ASSETS_URL — ссылка на папку с файлами (raw GitHub), "" = не скачивать,
    -- брать то, что уже лежит в workspace/ASSET_FOLDER.
    ASSET_FOLDER = "StevieBuddy",
    ASSETS_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/",
    REDOWNLOAD = false,             -- true = перекачать файлы, даже если уже есть

    -- Иконка в хотбаре. Можно указать:
    --   "stevie_icon.png"  — файл из ASSET_FOLDER (через getcustomasset)
    --   123456789          — ID картинки/декали на Roblox
    --   "rbxassetid://..." / "rbxthumb://..." — готовая ссылка
    -- Если файла нет — берётся ICON_FALLBACK.
    ICON = "stevie_icon.png",
    ICON_FALLBACK = "rbxthumb://type=Asset&id=92609387571141&w=150&h=150",

    -- Звуки: тот же формат (файл .mp3/.ogg в workspace, ID или ссылка). "" = не менять.
    -- Можно дать список — каждый раз играет случайный.
    -- equip / inspect / inspectleft — подменяют звуки настоящего бадди,
    -- jump (ЛКМ), look_right / look_left / turn (ПКМ по кругу) — мои анимации.
    SOUNDS = {
        equip = "sounds/stevie_equip.ogg",
        -- осмотр настоящего бадди: звук выбирается по кнопке мыши, а звуки тыквы глушатся
        click_lmb = "sounds/stevie_inspect2.ogg", -- ЛКМ: его гладят, мурчит
        click_rmb = "sounds/stevie_inspect1.ogg", -- ПКМ: помехи
        jump = "sounds/stevie_inspect1.ogg",
        look_right = "sounds/stevie_face_right.ogg",
        look_left = "sounds/stevie_face_left.ogg",
        turn = "sounds/stevie_inspect2.ogg",
        -- риг: звуки на метках смены лица в idle
        face_left = "sounds/stevie_face_left.ogg",
        face_right = "sounds/stevie_face_right.ogg",
        face_default = "sounds/stevie_face_default.ogg",
    },
    FACE_SOUNDS = true,             -- риг: звук при смене лица в idle
    SOUND_VOLUME = 0.8,
    MUTE_ORIGINAL_SOUNDS = true,    -- глушить звуки тыквы, для которых нет замены

    -- 0 = собрать бадди из деталей прямо в скрипте
    -- Файл модели в ASSET_FOLDER (скачивается как иконка); "" = не использовать.
    -- stevie_tool.rbxm — предмет Buddy_Stevie с суставами и кадрами анимаций (AnimSaves).
    MODEL_FILE = "stevie_tool.rbxm",
    -- Риг: Стиви собирается прямо в предмете со своими суставами, и вместо анимаций
    -- тыквы играют его анимации из файла (регистрируются локально). false = как раньше.
    RIG_MODE = true,
    MODEL_ASSET_ID = 92609387571141, -- запасной вариант: Stevie Buddy (Doors the Archives) по ID
    MODEL_SCALE = 1,
    MODEL_ROTATION = CFrame.Angles(0, 0, 0), -- если смотрит не туда: CFrame.Angles(0, math.pi, 0)
    SIZE = 1.6,                     -- диаметр самодельного бадди (studs)

    -- Экран Стиви в модели неоновый: в темноте он светится так, что лицо и помехи
    -- не видно. false = делаем его матовым светлым, как в DOORS.
    SCREEN_NEON = false,
    SCREEN_COLOR = Color3.fromRGB(225, 225, 230),

    -- reskin: к чему цепляем Стиви у настоящего бадди.
    --   "Handle" — к ручке предмета: двигается вместе с рукой, как настоящий бадди
    --   "Head"   — к голове тыквы: повторяет и личные движения тыквы
    RESKIN_ANCHOR = "Handle",
    -- Стиви ставится своим Handle на Handle тыквы, поэтому смещение обычно не нужно
    RESKIN_OFFSET = CFrame.new(0, 0, 0),

    -- reskin: анимации игры, которые глушим (по именам из папки Animations бадди).
    -- Осмотр (ЛКМ = inspectleft, ПКМ = inspect) двигает руку — его лучше не трогать.
    BLOCK_GAME_ANIMS = {},

    -- reskin: лица во время игровых анимаций. { секунда от начала, лицо }, nil = пустой экран.
    GAME_ANIM_FACES = {
        inspect = {       -- ПКМ
            { 0, "Default" }, { 0.35, nil }, { 0.5, "Blush" }, { 2.85, nil }, { 3.0, "Default" },
        },
        inspectleft = {   -- ЛКМ
            { 0, "Default" }, { 0.3, nil }, { 0.45, "LookLeft" }, { 1.3, nil },
            { 1.45, "Annoyed" }, { 2.8, nil }, { 2.95, "Default" },
        },
        equip = {
            { 0, nil }, { 0.25, "Default" },
        },
    },
    -- tool: позиция относительно HumanoidRootPart
    HOLD_OFFSET = CFrame.new(0, 0.4, -1.7) * CFrame.Angles(0, math.pi, 0),
    SHOULDER_OFFSET = CFrame.new(1.4, 2.2, 0.2) * CFrame.Angles(0, math.pi, 0),
    SIT_ON_SHOULDER = true,         -- false = когда убран, бадди исчезает

    CUSTOM_ANIMS = true,            -- tool: свои анимации на ЛКМ/ПКМ и при взятии в руки
}

-- Атрибуты настоящего бадди (сняты inspect.lua)
local BUDDY_ATTRIBUTES = {
    NameSingular = "Buddy",
    NamePlural = "Buddies",
    InspectOnly = true,
    Interactable = true,
    CannotDrop = true,
    CannotTransport = true,
    Hallucination = true,
    NoAdmin = true,
    ActuallyNoAdmin = true,
    _Translated = true,
    _LastsThroughoutFloor = true,
    ToolColor = Color3.new(0.572549, 0.262745, 0.74902),
    ToolOffset = Vector3.new(0, 0.4, -0.15),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Повторный запуск скрипта убирает старый экземпляр
local env = (getgenv and getgenv()) or _G
if env.__VisualBuddy then
    pcall(env.__VisualBuddy.Destroy)
end

local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

---------------------------------------------------------------- ассеты

local function isLocalFile(value)
    return type(value) == "string" and value ~= ""
        and not value:match("^%d+$") and not value:match("^rbx") and not value:match("^https?://")
end

local function fileExists(path)
    return isfile ~= nil and select(2, pcall(isfile, path)) == true
end

-- Создаёт workspace/ASSET_FOLDER (с подпапками) и докачивает недостающие файлы
local function downloadAssets()
    if not (makefolder and writefile) then
        warn("[Buddy] Экзекутор не умеет makefolder/writefile — ассеты не скачать")
        return
    end

    local files = { CONFIG.ICON, CONFIG.MODEL_FILE }
    for _, value in pairs(CONFIG.SOUNDS) do
        for _, v in ipairs(type(value) == "table" and value or { value }) do
            table.insert(files, v)
        end
    end

    local seen = {}
    for _, file in ipairs(files) do
        if isLocalFile(file) and not seen[file] then
            seen[file] = true
            local path = CONFIG.ASSET_FOLDER .. "/" .. file

            -- папки по пути: StevieBuddy, StevieBuddy/sounds, ...
            local dir = ""
            for part in path:gmatch("([^/]+)/") do
                dir = dir .. part
                if not (isfolder and isfolder(dir)) then pcall(makefolder, dir) end
                dir = dir .. "/"
            end

            if CONFIG.ASSETS_URL ~= "" and (CONFIG.REDOWNLOAD or not fileExists(path)) then
                local ok, data = pcall(game.HttpGet, game, CONFIG.ASSETS_URL .. file)
                if ok and data and #data > 0 and not data:match("^404") then
                    writefile(path, data)
                    print("[Buddy] Скачан " .. path)
                else
                    warn("[Buddy] Не удалось скачать " .. CONFIG.ASSETS_URL .. file)
                end
            end
        end
    end
end

downloadAssets()

-- Число -> rbxassetid, имя файла -> getcustomasset, ссылка -> как есть
local function resolveAsset(value)
    if value == nil or value == "" or value == 0 then return nil end
    if type(value) == "number" or tostring(value):match("^%d+$") then
        return "rbxassetid://" .. value
    end
    if not isLocalFile(value) then
        return value
    end
    local path = CONFIG.ASSET_FOLDER .. "/" .. value
    if fileExists(path) and getcustomasset then
        local ok, url = pcall(getcustomasset, path)
        if ok then return url end
    end
    return nil
end

local ICON = resolveAsset(CONFIG.ICON) or resolveAsset(CONFIG.ICON_FALLBACK) or ""
-- SOUND_IDS[name] = список готовых ссылок (может быть пустым)
local SOUND_IDS = {}
for name, value in pairs(CONFIG.SOUNDS) do
    local list = {}
    for _, v in ipairs(type(value) == "table" and value or { value }) do
        local id = resolveAsset(v)
        if id then
            table.insert(list, id)
        else
            warn("[Buddy] Звук не найден: " .. tostring(v))
        end
    end
    if #list > 0 then SOUND_IDS[name] = list end
end

local function randomSound(name)
    local list = SOUND_IDS[name]
    return list and list[math.random(#list)]
end

---------------------------------------------------------------- модель

local function newPart(parent, props)
    local p = Instance.new("Part")
    p.Anchored = false
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.CastShadow = false
    p.Material = Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    for k, v in pairs(props) do
        p[k] = v
    end
    p.Parent = parent
    return p
end

local function weldTo(root, part)
    local w = Instance.new("WeldConstraint")
    w.Part0 = root
    w.Part1 = part
    w.Parent = part
end

-- CFrame детали, лежащей на поверхности сферы радиуса r и смотрящей наружу
local function onSphere(r, x, y, lift, roll)
    local z = -math.sqrt(math.max(r * r - x * x - y * y, 0))
    local normal = Vector3.new(x, y, z).Unit
    local pos = normal * (r + (lift or 0))
    return CFrame.lookAt(pos, pos + normal) * CFrame.Angles(0, 0, roll or 0)
end

local BLACK = Color3.fromRGB(15, 10, 18)
local PINK = Color3.fromRGB(190, 40, 160)
local LIGHT = Color3.fromRGB(255, 215, 255)
local TONGUE = Color3.fromRGB(240, 100, 140)

local function buildBuddy(s)
    local model = Instance.new("Model")
    model.Name = CONFIG.NAME
    local r = s / 2

    local root = newPart(model, {
        Name = "Body",
        Shape = Enum.PartType.Ball,
        Size = Vector3.new(s, s, s),
        Color = BLACK,
        CFrame = CFrame.new(),
    })
    model.PrimaryPart = root

    local function add(props)
        local p = newPart(model, props)
        weldTo(root, p)
        return p
    end

    -- розовые пятна
    for _, spot in ipairs({ { -0.32, 0.28, 0.22 }, { 0.38, -0.05, 0.16 }, { -0.4, -0.1, 0.12 } }) do
        add({
            Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(0.02, s * spot[3], s * spot[3]),
            Color = PINK,
            CFrame = onSphere(r, s * spot[1], s * spot[2], 0) * CFrame.Angles(0, math.pi / 2, 0),
        })
    end

    -- глаз: розовое кольцо + светлый центр
    local eyeCF = onSphere(r, s * 0.05, s * 0.24, 0)
    add({
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(0.03, s * 0.34, s * 0.34),
        Color = PINK,
        CFrame = eyeCF * CFrame.Angles(0, math.pi / 2, 0),
    })
    add({
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(0.05, s * 0.24, s * 0.24),
        Color = LIGHT,
        Material = Enum.Material.Neon,
        CFrame = eyeCF * CFrame.new(0, 0, -0.02) * CFrame.Angles(0, math.pi / 2, 0),
    })

    -- рот-зигзаг
    local segments = 7
    local segLen = s * 0.17
    for i = 0, segments - 1 do
        local x = (-0.42 + i * (0.84 / (segments - 1))) * s
        local roll = (i % 2 == 0) and math.rad(30) or math.rad(-30)
        add({
            Size = Vector3.new(segLen, s * 0.12, 0.04),
            Color = PINK,
            CFrame = onSphere(r, x, -s * 0.08, 0, roll),
        })
        add({
            Size = Vector3.new(segLen * 0.9, s * 0.07, 0.06),
            Color = LIGHT,
            CFrame = onSphere(r, x, -s * 0.08, 0.01, roll),
        })
    end

    -- язык, свисает слева
    local tongueBase = onSphere(r, -s * 0.42, -s * 0.1, 0)
    for i = 0, 2 do
        add({
            Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(s * 0.14, s * 0.1, s * 0.1),
            Color = TONGUE,
            CFrame = tongueBase
                * CFrame.new(-s * 0.06 * i, -s * 0.09 * i, -s * 0.04)
                * CFrame.Angles(0, 0, math.rad(-35 - i * 25)),
        })
    end

    -- завиток на макушке
    for i = 0, 5 do
        local a = i * math.rad(55)
        add({
            Size = Vector3.new(s * 0.06, s * 0.1, s * 0.06),
            Color = PINK,
            CFrame = CFrame.new(s * 0.18, r + s * 0.02, s * 0.1)
                * CFrame.new(math.cos(a) * s * 0.07, i * s * 0.025, math.sin(a) * s * 0.07)
                * CFrame.Angles(0, -a, math.rad(25)),
        })
    end

    return model
end

-- Из файла с предметом Buddy_Stevie достаём: шаблон рига (Handle со всеми деталями)
-- и кадры анимаций из AnimSaves. Анимации узнаём по содержимому, имена в файле одинаковые.
local STEVIE_RIG = nil     -- Handle предмета Стиви (нетронутый шаблон)
local STEVIE_KFS = {}      -- [idle/equip/inspect/inspectleft] = KeyframeSequence

local function unpackStevieTool(src)
    if not src then return src end
    local toolObj = src:IsA("Tool") and src or src:FindFirstChildWhichIsA("Tool", true)
    local handle = toolObj and toolObj:FindFirstChild("Handle")
    if not (handle and handle:IsA("BasePart")) then return src end

    local actions = {}
    for _, d in ipairs(src:GetDescendants()) do
        if d:IsA("KeyframeSequence") then
            local length = 0
            for _, kf in ipairs(d:GetKeyframes()) do
                length = math.max(length, kf.Time)
            end
            if d.Loop and not STEVIE_KFS.idle then
                STEVIE_KFS.idle = d
            elseif d:FindFirstChild("Buddy-Face-Blush", true) and not STEVIE_KFS.inspectleft then
                STEVIE_KFS.inspectleft = d -- единственная с довольным лицом
            else
                table.insert(actions, { kfs = d, length = length })
            end
        end
    end
    table.sort(actions, function(a, b) return a.length < b.length end)
    STEVIE_KFS.equip = actions[1] and actions[1].kfs        -- самая короткая
    STEVIE_KFS.inspect = actions[#actions] and actions[#actions].kfs

    STEVIE_RIG = handle:Clone()
    return handle:Clone() -- для модели на плече
end

-- Сначала пробуем локальный .rbxm из ASSET_FOLDER, потом ассет по ID
local function fetchModelSource()
    if CONFIG.MODEL_FILE ~= "" and getcustomasset then
        local path = CONFIG.ASSET_FOLDER .. "/" .. CONFIG.MODEL_FILE
        if fileExists(path) then
            local ok, objects = pcall(function()
                return game:GetObjects(getcustomasset(path))
            end)
            if ok and objects and objects[1] then
                print("[Buddy] Модель загружена из файла " .. path)
                return objects[1]
            end
            warn("[Buddy] Не удалось открыть " .. path .. ", пробую ассет по ID")
        end
    end
    if CONFIG.MODEL_ASSET_ID ~= 0 then
        local ok, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. CONFIG.MODEL_ASSET_ID)
        end)
        if ok and objects and objects[1] then
            print("[Buddy] Модель загружена по ID " .. CONFIG.MODEL_ASSET_ID)
            return objects[1]
        end
    end
end

local function loadModel()
    if CONFIG.MODEL_FILE ~= "" or CONFIG.MODEL_ASSET_ID ~= 0 then
        local src = unpackStevieTool(fetchModelSource())
        if src and src:FindFirstChildWhichIsA("BasePart", true) or (src and src:IsA("BasePart")) then
            -- Ассет может быть Tool / Accessory / Folder / Part — перекладываем всё в Model
            local m = Instance.new("Model")
            m.Name = CONFIG.NAME
            if src:IsA("Model") then
                m = src
                m.Name = CONFIG.NAME
            else
                src.Parent = m
            end

            -- Детали (особенно лица) стоят на местах благодаря суставам Motor6D/Weld.
            -- Сначала ставим каждую деталь туда, куда её ставит сустав, и только
            -- потом удаляем суставы — иначе лица остаются внутри корпуса.
            local joints = {}
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("JointInstance") and d.Part0 and d.Part1 then
                    table.insert(joints, d)
                end
            end
            for _ = 1, 4 do -- несколько проходов, чтобы цепочки суставов тоже встали
                for _, j in ipairs(joints) do
                    j.Part1.CFrame = j.Part0.CFrame * j.C0 * j.C1:Inverse()
                end
            end

            -- Лица переключаются сдвигом: видимое стоит на экране, остальные спрятаны
            -- в корпусе. Их суставы заменяем на Weld, чтобы потом двигать C0.
            local faceJoints = {}
            for _, j in ipairs(joints) do
                local faceName = j.Part1.Name:match("^Buddy%-Face%-(.+)$")
                if faceName then
                    table.insert(faceJoints, { name = faceName, p0 = j.Part0, p1 = j.Part1, c0 = j.C0, c1 = j.C1 })
                end
            end

            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("LuaSourceContainer") or d:IsA("JointInstance") or d:IsA("WeldConstraint")
                    or d:IsA("Sound") or d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
                    d:Destroy()
                elseif d:IsA("Decal") and d.Name == "ToolIcon" then
                    -- иконка предмета висит на невидимом Handle прямо перед экраном
                    d.Transparency = 1
                elseif d:IsA("BasePart") and d.Name == "Screen" and not CONFIG.SCREEN_NEON
                    and d.Material == Enum.Material.Neon then
                    d.Material = Enum.Material.SmoothPlastic
                    d.Color = CONFIG.SCREEN_COLOR
                end
            end

            local isFacePart = {}
            for _, f in ipairs(faceJoints) do
                local w = Instance.new("Weld")
                w.Name = "FaceWeld_" .. f.name
                w.Part0, w.Part1, w.C0, w.C1 = f.p0, f.p1, f.c0, f.c1
                w.Parent = f.p1
                isFacePart[f.p1] = true
            end

            -- невидимая опорная деталь: на месте Handle модели (так Стиви встаёт в руку
            -- ровно как задумано), а если Handle нет — в центре модели
            local handle = m:FindFirstChild("Handle", true)
            local cf = (handle and handle:IsA("BasePart")) and handle.CFrame or m:GetBoundingBox()
            local root = newPart(m, {
                Name = "BuddyRoot",
                Transparency = 1,
                Size = Vector3.new(0.2, 0.2, 0.2),
                CFrame = cf * CONFIG.MODEL_ROTATION,
            })
            for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("BasePart") and d ~= root then
                    d.Anchored = false
                    d.CanCollide = false
                    d.CanTouch = false
                    d.CanQuery = false
                    d.Massless = true
                    if not isFacePart[d] then weldTo(root, d) end
                end
            end
            m.PrimaryPart = root
            if CONFIG.MODEL_SCALE ~= 1 then
                m:ScaleTo(CONFIG.MODEL_SCALE)
            end
            return m
        end
        warn("[Buddy] Не удалось загрузить модель ни из файла, ни по ID — собираю свою")
    end
    return buildBuddy(CONFIG.SIZE)
end

local buddy = loadModel()
local baseScale = buddy:GetScale()

---------------------------------------------------------------- лица и помехи

-- В модели Стиви лица лежат в папке Faces: Buddy-Face-Default / LookLeft /
-- LookRight / Annoyed / Blush, у каждой детали Decal с картинкой лица.
local faceDecals = {} -- [имя] = { Decal, ... }
for _, d in ipairs(buddy:GetDescendants()) do
    if d:IsA("Decal") and d.Parent then
        local name = d.Parent.Name:match("^Buddy%-Face%-(.+)$")
        if name then
            faceDecals[name] = faceDecals[name] or {}
            table.insert(faceDecals[name], d)
        end
    end
end

-- Как в DOORS: видимое лицо выдвигаем на экран (позиция Default), остальные
-- прячем в корпус (их исходная позиция). Позиции запоминаем при текущем масштабе.
local faceWelds = {}  -- [имя] = Weld
local faceBack = {}   -- [имя] = C0 "спрятано"
local faceFront       -- C0 "на экране"
local faceScale = buddy:GetScale()
for _, d in ipairs(buddy:GetDescendants()) do
    if d:IsA("Weld") then
        local name = d.Name:match("^FaceWeld_(.+)$")
        if name then faceWelds[name] = d end
    end
end
if faceWelds.Default then
    faceFront = faceWelds.Default.C0
    for name, w in pairs(faceWelds) do
        if name ~= "Default" then
            faceBack[name] = w.C0
            faceBack.Default = faceBack.Default or w.C0
        end
    end
end

local function scaledCFrame(cf, s)
    return CFrame.new(cf.Position * s) * cf.Rotation
end

local currentFace
-- name = "Default" / "LookLeft" / ... ; nil = пустой экран (только помехи)
local function setFace(name)
    if name == currentFace then return end
    currentFace = name
    for faceName, list in pairs(faceDecals) do
        for _, decal in ipairs(list) do
            decal.Transparency = (faceName == name) and 0 or 1
        end
    end
    if faceFront then
        local s = buddy:GetScale() / faceScale
        for faceName, w in pairs(faceWelds) do
            local target = (faceName == name) and faceFront or faceBack[faceName]
            if target then w.C0 = scaledCFrame(target, s) end
        end
    end
end
local hasFaces = next(faceDecals) ~= nil
if hasFaces then setFace("Default") end

do
    local names = {}
    for name in pairs(faceDecals) do table.insert(names, name) end
    table.sort(names)
    print(("[Buddy] Лиц найдено: %d (%s)"):format(#names, table.concat(names, ", ")))
end

-- Помехи на экране: в модели их двигал скрипт StaticMove, мы его удалили — двигаем сами
local staticTextures = {}
for _, d in ipairs(buddy:GetDescendants()) do
    if d:IsA("Texture") and d.Name == "StaticTexture" then
        table.insert(staticTextures, d)
    end
end
print("[Buddy] Текстур помех: " .. #staticTextures)

-- Риг: свой проигрыватель кадров. RegisterKeyframeSequence работает только в Studio,
-- поэтому сами считаем положение каждого сустава между кадрами и ставим Motor6D.Transform.

-- Направления сглаживания в позах Roblox перевёрнуты относительно TweenService
local POSE_DIRECTION = { In = Enum.EasingDirection.Out, Out = Enum.EasingDirection.In, InOut = Enum.EasingDirection.InOut }

local function compileKfs(kfs)
    local frames = kfs:GetKeyframes()
    table.sort(frames, function(a, b) return a.Time < b.Time end)
    local tracks = {}  -- [имя позы] = { parent = имя родительской позы, keys = { {t, cf, style, dir} } }
    local markers = {} -- { {t, name} }
    local length = 0
    for _, kf in ipairs(frames) do
        length = math.max(length, kf.Time)
        for _, d in ipairs(kf:GetDescendants()) do
            if d:IsA("Pose") and d.Weight > 0 then
                local tr = tracks[d.Name]
                if not tr then
                    tr = { parent = d.Parent:IsA("Pose") and d.Parent.Name or nil, keys = {} }
                    tracks[d.Name] = tr
                end
                table.insert(tr.keys, {
                    t = kf.Time,
                    cf = d.CFrame,
                    constant = d.EasingStyle.Name == "Constant",
                    style = Enum.EasingStyle[d.EasingStyle.Name == "CubicV2" and "Cubic" or d.EasingStyle.Name]
                        or Enum.EasingStyle.Linear,
                    dir = POSE_DIRECTION[d.EasingDirection.Name] or Enum.EasingDirection.Out,
                })
            elseif d:IsA("KeyframeMarker") then
                table.insert(markers, { t = kf.Time, name = d.Name })
            end
        end
    end
    return { tracks = tracks, markers = markers, length = math.max(length, 0.01) }
end

-- Положение сустава в момент t: между соседними кадрами со сглаживанием
local function sampleKeys(keys, t)
    local n = #keys
    if n == 1 or t <= keys[1].t then return keys[1].cf end
    if t >= keys[n].t then return keys[n].cf end
    local lo, hi = 1, n
    while hi - lo > 1 do
        local mid = (lo + hi) // 2
        if keys[mid].t <= t then lo = mid else hi = mid end
    end
    local a, b = keys[lo], keys[hi]
    if a.constant then return a.cf end
    local alpha = (t - a.t) / (b.t - a.t)
    return a.cf:Lerp(b.cf, TweenService:GetValue(alpha, a.style, a.dir))
end

local stevieClips = {} -- [idle/equip/inspect/inspectleft] = скомпилированная анимация
if CONFIG.RIG_MODE and STEVIE_RIG then
    for name, kfs in pairs(STEVIE_KFS) do
        local ok, clip = pcall(compileKfs, kfs)
        if ok then
            stevieClips[name] = clip
        else
            warn("[Buddy] Не удалось прочитать анимацию " .. name .. ": " .. tostring(clip))
        end
    end
end
local rigMode = stevieClips.idle ~= nil
do
    local names = {}
    for name, clip in pairs(stevieClips) do
        table.insert(names, ("%s %.1fс"):format(name, clip.length))
    end
    table.sort(names)
    print(rigMode and ("[Buddy] Риг Стиви: анимации " .. table.concat(names, ", "))
        or "[Buddy] Риг выключен: анимации Стиви не найдены в файле, будут движения тыквы")
end

-- свои звуки — в SoundService, чтобы играли сразу, даже пока модель ещё не в мире
local buddySounds = {}
for name in pairs(SOUND_IDS) do
    local s = Instance.new("Sound")
    s.Name = "BuddySound_" .. name
    s.Volume = CONFIG.SOUND_VOLUME
    s.Parent = game:GetService("SoundService")
    buddySounds[name] = s
end

local function playSound(name)
    local s = buddySounds[name]
    if s then
        s.SoundId = randomSound(name)
        s.TimePosition = 0
        s:Play()
    end
end

-- Звук осмотра настоящего бадди: по последней кнопке мыши (ЛКМ — мурчание, ПКМ — помехи).
-- Если клика не было (геймпад, телефон), выбираем по анимации.
local lastClick = { button = nil, time = 0 }
local lastClickSound = 0
local function playClickSound(animName)
    local now = os.clock()
    if now - lastClickSound < 0.3 then return end -- игра иногда запускает трек дважды
    lastClickSound = now
    local button = lastClick.button
    if not button or now - lastClick.time > 0.6 then
        button = (animName == "inspectleft") and "lmb" or "rmb"
    end
    playSound("click_" .. button)
end

---------------------------------------------------------------- состояние

local equipped = false
local anim = nil -- { kind = "jump" | "look_right" | "look_left" | "turn", start = clock }
local gameFace = nil -- reskin: { timeline, start, track } — лица под игровую анимацию
local rigParts = {}  -- риг: детали Стиви, перенесённые в Handle предмета
local rigOwned = {}  -- риг: все наши объекты в предмете (их не прятать)
local rigStatic = {} -- риг: текстуры помех на экране
local rigAnim = {}   -- риг: { idle = состояние, action = состояние } проигрывателя
local rigFaces = {}  -- риг: { joint, name } — суставы лиц (по ним видно, какое лицо выдвинуто)
local rigFaceTex = {} -- риг: [имя лица] = { tex, color }
local rigFaceMain = {} -- риг: декали лица Default — единственные видимые, в них подставляем картинку
local rigFaceShown = nil
local rigFaceBlinkUntil = 0

-- анимации тыквы -> анимации Стиви
local RIG_ANIM_MAP = { idle = "idle", equip = "equip", equip2 = "equip", inspect = "inspect", inspectleft = "inspectleft" }
local FACE_MARKERS = { FaceLeft = "face_left", FaceRight = "face_right", FaceDefault = "face_default" }
local pumpkinJoint = nil -- reskin: BuddyJoint настоящего бадди (покачивание корпуса в idle)
local ANIM_LENGTH = { equip = 0.55, jump = 0.75, look_right = 1.0, look_left = 1.0, turn = 1.6 }
-- какое лицо показывать во время анимации
local ANIM_FACE = { jump = "Blush", look_right = "LookRight", look_left = "LookLeft", turn = "Annoyed" }

-- Покой (как на записи): лицо, пустой экран, взгляд вправо, пусто, влево, пусто...
-- { лицо (nil = только помехи), мин. секунд, макс. секунд }
local IDLE_FACES = {
    { "Default", 3.5, 5.5 },
    { nil, 0.2, 0.3 },
    { "LookRight", 1.1, 1.5 },
    { nil, 0.2, 0.3 },
    { "LookLeft", 0.9, 1.3 },
    { nil, 0.2, 0.3 },
}
-- ПКМ по кругу: вправо -> влево -> разворот
local RMB_CYCLE = { "look_right", "look_left", "turn" }
local rmbIndex = 0

local weld = Instance.new("Weld")
weld.Part1 = buddy.PrimaryPart
weld.Parent = buddy.PrimaryPart

local tool          -- предмет, к которому привязан бадди (настоящий или свой)
local isReskin = false
local ownTool       -- свой Tool, если создавали
local toolConns = {}
local hiddenParts = {} -- [instance] = исходная прозрачность
local originalIcon

local originalSounds = {} -- [Sound] = { SoundId, Volume }

local function playAnim(kind)
    if not (equipped and CONFIG.CUSTOM_ANIMS) then return end
    anim = { kind = kind, start = os.clock() }
    playSound(kind)
end

-- Звуки настоящего бадди называются sound_equip / sound_inspect / ...
local function swapSound(s)
    if not s:IsA("Sound") or originalSounds[s] then return end
    local name = s.Name:match("^sound_(.+)$")
    if not name then return end
    originalSounds[s] = { s.SoundId, s.Volume }
    if SOUND_IDS[name] then
        s.SoundId = randomSound(name)
        s.Volume = CONFIG.SOUND_VOLUME
        -- игра играет один и тот же Sound — после каждого проигрывания берём следующий случайный
        if #SOUND_IDS[name] > 1 then
            table.insert(toolConns, s:GetPropertyChangedSignal("Playing"):Connect(function()
                if not s.Playing then s.SoundId = randomSound(name) end
            end))
        end
    elseif CONFIG.MUTE_ORIGINAL_SOUNDS then
        s.Volume = 0
    end
end

local function restoreSounds()
    for s, orig in pairs(originalSounds) do
        if s.Parent then
            s.SoundId, s.Volume = orig[1], orig[2]
        end
    end
    originalSounds = {}
end

local function isRealBuddy(t)
    return t:IsA("Tool") and t ~= ownTool
        and t:GetAttribute("NameSingular") == "Buddy"
        and t:FindFirstChild("ToolHandlerServer") ~= nil
end

local function findRealBuddy()
    for _, c in ipairs({ player:FindFirstChild("Backpack"), player.Character }) do
        if c then
            for _, t in ipairs(c:GetChildren()) do
                if isRealBuddy(t) then return t end
            end
        end
    end
end

---------------------------------------------------------------- reskin

local function hide(inst)
    if hiddenParts[inst] ~= nil or rigOwned[inst] then return end
    if inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
        hiddenParts[inst] = inst.Transparency
        inst.Transparency = 1
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
        hiddenParts[inst] = inst.Enabled
        inst.Enabled = false
    end
end

local function restoreHidden()
    for inst, value in pairs(hiddenParts) do
        if inst.Parent then
            if typeof(value) == "boolean" then
                inst.Enabled = value
            else
                inst.Transparency = value
            end
        end
    end
    hiddenParts = {}
end

-- Детали, которые соединяет сустав. В DOORS руки персонажа держатся не на Motor6D,
-- а на AnimationConstraint (детали — через Attachment0/Attachment1); у обоих есть Transform.
local function jointParts(d)
    if d:IsA("Motor6D") then
        return d.Part0, d.Part1
    elseif d:IsA("AnimationConstraint") then
        local a0, a1 = d.Attachment0, d.Attachment1
        return a0 and a0.Parent, a1 and a1.Parent
    end
end

local reportedClips = {}

-- Привязка поз анимации к суставам: поза = имя детали Part1, её родитель = имя Part0
local function bindClip(clip, clipName)
    local byPart1 = {}
    for _, root in ipairs({ player.Character, tool }) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                local p0, p1 = jointParts(d)
                if p1 then
                    local list = byPart1[p1.Name]
                    if not list then
                        list = {}
                        byPart1[p1.Name] = list
                    end
                    table.insert(list, { joint = d, parentName = p0 and p0.Name })
                end
            end
        end
    end
    local binding = {} -- { {joint, keys} }
    local found, missing = {}, {}
    for name, tr in pairs(clip.tracks) do
        local list = byPart1[name]
        if list then
            local pick = list[1]
            for _, entry in ipairs(list) do
                if tr.parent and entry.parentName == tr.parent then pick = entry end
            end
            table.insert(binding, { joint = pick.joint, keys = tr.keys })
            table.insert(found, name .. "(" .. pick.joint.ClassName .. ")")
        else
            table.insert(missing, name)
        end
    end
    -- один раз на анимацию пишем в консоль, что нашлось, а что нет
    if not reportedClips[clipName] then
        reportedClips[clipName] = true
        table.sort(found)
        table.sort(missing)
        print(("[Buddy] Анимация %s: суставов найдено %d, нет %d"):format(clipName, #found, #missing))
        print("[Buddy]   найдены: " .. table.concat(found, ", "))
        if #missing > 0 then print("[Buddy]   нет: " .. table.concat(missing, ", ")) end
    end
    return binding
end

local function startRigAnim(name)
    local clip = stevieClips[name]
    if not clip then return end
    local state = { name = name, clip = clip, binding = bindClip(clip, name), start = os.clock(), lastT = 0 }
    if name == "idle" then
        rigAnim.idle = state
    else
        rigAnim.action = state
    end
end

local function stopRigAnims()
    rigAnim = {}
    for _, p in ipairs(rigParts) do
        for _, d in ipairs(p:GetDescendants()) do
            if d:IsA("Motor6D") then d.Transform = CFrame.identity end
        end
    end
end

local ACTION_FADE = 0.12 -- секунды плавного перехода idle <-> действие

-- Каждый кадр после анимаций игры (Stepped) ставим суставы по своим анимациям
connect(RunService.Stepped, function()
    if not (equipped and isReskin and #rigParts > 0) then return end
    local now = os.clock()
    if not rigAnim.idle then startRigAnim("idle") end

    local result = {} -- [joint] = CFrame

    local idle = rigAnim.idle
    if idle then
        local t = (now - idle.start) % idle.clip.length
        for _, b in ipairs(idle.binding) do
            result[b.joint] = sampleKeys(b.keys, t)
        end
        -- звуки на метках смены лица (с учётом перехода через конец цикла)
        if CONFIG.FACE_SOUNDS then
            for _, m in ipairs(idle.clip.markers) do
                local crossed = (t >= idle.lastT and m.t > idle.lastT and m.t <= t)
                    or (t < idle.lastT and (m.t > idle.lastT or m.t <= t))
                if crossed and FACE_MARKERS[m.name] then playSound(FACE_MARKERS[m.name]) end
            end
        end
        idle.lastT = t
    end

    local action = rigAnim.action
    if action then
        local t = now - action.start
        local length = action.clip.length
        if t >= length then
            rigAnim.action = nil
        else
            local w = math.clamp(math.min(t, length - t) / ACTION_FADE, 0, 1)
            for _, b in ipairs(action.binding) do
                local cf = sampleKeys(b.keys, t)
                local base = result[b.joint]
                result[b.joint] = base and base:Lerp(cf, w) or cf
            end
        end
    end

    for joint, cf in pairs(result) do
        if joint.Parent then joint.Transform = cf end
    end

    -- Лица (кроме Default) лежат за экраном с помехами, и анимация выдвигает их
    -- недостаточно — их не видно. Как в скрипте самой модели: видна только декаль
    -- Default, в неё подставляем картинку того лица, которое анимация выдвинула вперёд.
    if #rigFaces > 0 then
        local show, best = "Default", -0.2
        for _, f in ipairs(rigFaces) do
            local cf = result[f.joint]
            if f.name ~= "Default" and cf and cf.Position.Z < best then
                show, best = f.name, cf.Position.Z
            end
            f.joint.Transform = CFrame.identity -- само лицо не двигаем, Default всегда перед экраном
        end
        if show ~= rigFaceShown then
            -- между лицами на миг только помехи, как в оригинале
            if rigFaceShown then rigFaceBlinkUntil = now + 0.12 end
            rigFaceShown = show
        end
        local target = rigFaceTex[show] or rigFaceTex.Default
        local hidden = now < rigFaceBlinkUntil
        for _, d in ipairs(rigFaceMain) do
            if target and d.Texture ~= target.tex then
                d.Texture = target.tex
                d.Color3 = target.color
            end
            d.Transparency = hidden and 1 or 0
        end
    end
end)

-- Переносим детали Стиви в Handle настоящего бадди; его суставы цепляем к этому Handle
local function buildRig(t)
    local handle = t:FindFirstChild("Handle")
    if not (handle and STEVIE_RIG) then return false end
    local clone = STEVIE_RIG:Clone()
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("LuaSourceContainer") or d:IsA("Sound") or (d:IsA("Decal") and d.Name == "ToolIcon") then
            d:Destroy()
        end
    end
    for _, d in ipairs(clone:GetDescendants()) do
        rigOwned[d] = true
        if d:IsA("BasePart") then
            d.Anchored = false
            d.CanCollide = false
            d.CanTouch = false
            d.CanQuery = false
            d.Massless = true
            d.CastShadow = false
            if d.Name == "Screen" and not CONFIG.SCREEN_NEON and d.Material == Enum.Material.Neon then
                d.Material = Enum.Material.SmoothPlastic
                d.Color = CONFIG.SCREEN_COLOR
            end
        elseif d:IsA("Texture") and d.Name == "StaticTexture" then
            table.insert(rigStatic, d)
        elseif d:IsA("JointInstance") then
            if d.Part0 == clone then d.Part0 = handle end
            if d.Part1 == clone then d.Part1 = handle end
            local faceName = d.Part1 and d.Part1.Name:match("^Buddy%-Face%-(.+)$")
            if faceName then
                for _, x in ipairs(d.Part1:GetDescendants()) do
                    if x:IsA("Decal") then
                        rigFaceTex[faceName] = rigFaceTex[faceName] or { tex = x.Texture, color = x.Color3 }
                        if faceName == "Default" then
                            table.insert(rigFaceMain, x)
                        else
                            x.Transparency = 1
                        end
                    end
                end
                table.insert(rigFaces, { joint = d, name = faceName })
            end
            -- у тыквы свой BuddyJoint, не путаем
            if d.Name == "BuddyJoint" then d.Name = "StevieBuddyJoint" end
        end
    end
    for _, child in ipairs(clone:GetChildren()) do
        child.Parent = handle
        table.insert(rigParts, child)
    end
    clone:Destroy()
    return true
end

local function destroyRig()
    rigAnim = {}
    for _, p in ipairs(rigParts) do p:Destroy() end
    rigParts, rigOwned, rigStatic = {}, {}, {}
    rigFaces, rigFaceTex, rigFaceMain, rigFaceShown, rigFaceBlinkUntil = {}, {}, {}, nil, 0
end

local function unbindTool()
    for _, c in ipairs(toolConns) do c:Disconnect() end
    toolConns = {}
    destroyRig()
    restoreHidden()
    restoreSounds()
    if tool and isReskin and originalIcon then
        tool.TextureId = originalIcon
    end
    tool, isReskin, originalIcon = nil, false, nil
    gameFace, pumpkinJoint = nil, nil
    equipped = false
    anim = nil
end

local function bindTool(t, reskin)
    unbindTool()
    tool, isReskin = t, reskin
    equipped = t.Parent == player.Character

    local equipTime = equipped and 0 or os.clock()
    table.insert(toolConns, t.Equipped:Connect(function()
        equipped = true
        equipTime = os.clock()
        anim = nil
        -- у настоящего бадди влёт в руки и звук делает сама игра
        if not reskin then
            if CONFIG.CUSTOM_ANIMS then anim = { kind = "equip", start = os.clock() } end
            playSound("equip")
        end
    end))
    table.insert(toolConns, t.Unequipped:Connect(function()
        equipped = false
        anim = nil
        gameFace = nil
        stopRigAnims()
    end))
    table.insert(toolConns, t.AncestryChanged:Connect(function()
        if not t:IsDescendantOf(game) then unbindTool() end
    end))

    if reskin then
        originalIcon = t.TextureId
        if ICON ~= "" then t.TextureId = ICON end
        for _, d in ipairs(t:GetDescendants()) do
            hide(d)
            swapSound(d)
        end
        table.insert(toolConns, t.DescendantAdded:Connect(function(d)
            hide(d)
            swapSound(d)
        end))

        pumpkinJoint = t:FindFirstChild("BuddyJoint", true)
        local rigActive = rigMode and buildRig(t)

        -- Следим за игровыми анимациями бадди (имена — из папки Animations предмета):
        -- лишние глушим, на остальные включаем лица из GAME_ANIM_FACES
        local animNames = {} -- [AnimationId] = имя
        local animFolder = t:FindFirstChild("Animations")
        if animFolder then
            for _, a in ipairs(animFolder:GetChildren()) do
                if a:IsA("Animation") then animNames[a.AnimationId] = a.Name end
            end
        end
        local function watchAnimator(animator)
            table.insert(toolConns, animator.AnimationPlayed:Connect(function(track)
                local name = track.Animation and animNames[track.Animation.AnimationId]
                if not name then return end
                local stevieName = RIG_ANIM_MAP[name]
                local isInspect = stevieName == "inspect" or stevieName == "inspectleft"
                if isInspect and equipped and os.clock() - equipTime > 0.4 then
                    playClickSound(stevieName)
                end
                if rigActive and stevieName and stevieClips[stevieName]
                    and isInspect and equipped and os.clock() - equipTime > 0.4 then
                    -- осмотр по клику: запускаем сразу (игра иногда сама мгновенно
                    -- обрывает свой трек осмотра, и проверка ниже его бы пропустила)
                    track:Stop(0)
                    startRigAnim(stevieName)
                elseif rigActive and stevieName and stevieClips[stevieName] then
                    -- Игра при экипировке на миг запускает все анимации (подгрузка),
                    -- поэтому подменяем только те, что реально продолжают играть
                    task.delay(0.05, function()
                        if equipped and track.IsPlaying and track.WeightTarget > 0.01 then
                            track:Stop(0)
                            startRigAnim(stevieName)
                        end
                    end)
                elseif CONFIG.BLOCK_GAME_ANIMS[name] then
                    track:Stop(0)
                elseif CONFIG.GAME_ANIM_FACES[name] and equipped then
                    gameFace = { timeline = CONFIG.GAME_ANIM_FACES[name], start = os.clock(), track = track }
                end
            end))
        end
        if player.Character then
            for _, d in ipairs(player.Character:GetDescendants()) do
                if d:IsA("Animator") then watchAnimator(d) end
            end
        end
        for _, d in ipairs(t:GetDescendants()) do
            if d:IsA("Animator") then watchAnimator(d) end
        end

        -- скрипт запустили, когда бадди уже в руках: подменяем то, что уже играет
        if rigActive and equipped and player.Character then
            for _, d in ipairs(player.Character:GetDescendants()) do
                if d:IsA("Animator") then
                    for _, track in ipairs(d:GetPlayingAnimationTracks()) do
                        local name = track.Animation and animNames[track.Animation.AnimationId]
                        local stevieName = name and RIG_ANIM_MAP[name]
                        if stevieName and stevieClips[stevieName] then
                            track:Stop(0)
                            if stevieName ~= "idle" then startRigAnim(stevieName) end
                        end
                    end
                end
            end
        end
        -- игра может вернуть прозрачность (например, при экипировке) — прячем снова
        for inst in pairs(hiddenParts) do
            if inst:IsA("BasePart") or inst:IsA("Decal") then
                table.insert(toolConns, inst:GetPropertyChangedSignal("Transparency"):Connect(function()
                    if inst.Transparency ~= 1 then inst.Transparency = 1 end
                end))
            end
        end
    end
end

---------------------------------------------------------------- свой предмет

local function makeOwnTool()
    if ownTool then ownTool:Destroy() end
    ownTool = Instance.new("Tool")
    ownTool.Name = CONFIG.NAME
    ownTool.TextureId = ICON
    ownTool.RequiresHandle = false     -- модель держим сами через weld
    ownTool.CanBeDropped = false
    -- атрибуты ставим ДО того, как хотбар увидит предмет
    for k, v in pairs(BUDDY_ATTRIBUTES) do
        ownTool:SetAttribute(k, v)
    end
    ownTool:SetAttribute("_OriginalOwner", player.UserId)
    ownTool.Parent = player:WaitForChild("Backpack")
    bindTool(ownTool, false)
end

local function setup()
    local real = CONFIG.MODE ~= "tool" and findRealBuddy()
    if real then
        if ownTool then ownTool:Destroy(); ownTool = nil end
        bindTool(real, true)
        print("[Buddy] Режим reskin: переодел настоящего бадди")
    elseif CONFIG.MODE ~= "reskin" then
        makeOwnTool()
        print("[Buddy] Режим tool: создан свой предмет")
    else
        unbindTool()
        warn("[Buddy] Настоящий бадди не найден, жду его появления")
    end
end

-- настоящий бадди может появиться позже (выдача в начале забега)
local function watchContainer(c)
    connect(c.ChildAdded, function(child)
        if not isReskin and CONFIG.MODE ~= "tool" and isRealBuddy(child) then
            task.defer(setup)
        end
    end)
end

local function onCharacter(character)
    character:WaitForChild("HumanoidRootPart", 10)
    watchContainer(character)
    watchContainer(player:WaitForChild("Backpack"))
    task.wait(0.5) -- даём игре выдать предметы
    setup()
end

---------------------------------------------------------------- иконка в хотбаре

-- Хотбар DOORS мог закэшировать старую картинку — подменяем её прямо в слотах
local function patchHotbarIcon()
    if not (isReskin and originalIcon and ICON ~= "") then return end
    local mainUI = player.PlayerGui:FindFirstChild("MainUI")
    local hotbar = mainUI and mainUI:FindFirstChild("Hotbar", true)
    if not hotbar then return end
    for _, slot in ipairs(hotbar:GetChildren()) do
        local icon = slot:FindFirstChild("Tool")
        if icon and icon:IsA("ImageLabel") and icon.Image == originalIcon then
            icon.Image = ICON
        end
    end
end

local runToken = {}
env.__VisualBuddyToken = runToken

task.spawn(function()
    while env.__VisualBuddyToken == runToken do
        pcall(patchHotbarIcon)
        task.wait(0.3)
    end
end)

---------------------------------------------------------------- ввод

connect(UserInputService.InputBegan, function(input, processed)
    -- запоминаем кнопку до проверки processed: игра может ловить клики через свои действия
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        lastClick = { button = "lmb", time = os.clock() }
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        lastClick = { button = "rmb", time = os.clock() }
    end
    if processed then return end
    -- В reskin клики обрабатывает сама игра (осмотр), лица включаются по её анимациям.
    -- tool.Activated в DOORS не срабатывает, поэтому ЛКМ ловим здесь.
    if isReskin or not equipped then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        playAnim("jump")
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        rmbIndex = rmbIndex % #RMB_CYCLE + 1
        playAnim(RMB_CYCLE[rmbIndex])
    end
end)

---------------------------------------------------------------- анимация

local function easeInOut(t)
    return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2
end

-- 0 -> 1 -> 1 -> 0: быстро в позу, держим, плавно назад
local function holdCurve(p, inEnd, outStart)
    if p < inEnd then return easeInOut(p / inEnd) end
    if p < outStart then return 1 end
    return 1 - easeInOut((p - outStart) / (1 - outStart))
end

local idleStep = 1
local idleStepEnd = 0
local nextStatic = 0

local function idleFace(t)
    if t >= idleStepEnd then
        -- первый шаг после анимации — снова с обычного лица
        idleStep = (idleStepEnd == 0) and 1 or (idleStep % #IDLE_FACES + 1)
        local step = IDLE_FACES[idleStep]
        idleStepEnd = t + step[2] + math.random() * (step[3] - step[2])
    end
    return IDLE_FACES[idleStep][1]
end

-- Куда цепляем бадди в этом кадре: деталь + смещение
local function getAnchor()
    if equipped and isReskin and tool then
        local anchor = CONFIG.RESKIN_ANCHOR == "Head" and tool:FindFirstChild("Buddy-Head", true)
            or tool:FindFirstChild("Handle")
        if anchor then return anchor, CONFIG.RESKIN_OFFSET end
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if equipped then return hrp, CONFIG.HOLD_OFFSET end
    if CONFIG.SIT_ON_SHOULDER then return hrp, CONFIG.SHOULDER_OFFSET end
    return nil
end

local currentBase = CFrame.new()
local currentScale = 1

connect(RunService.RenderStepped, function(dt)
    local t = os.clock()

    -- помехи: сдвигаем текстуру на случайное место ~20 раз в секунду
    if t >= nextStatic then
        nextStatic = t + 0.05
        for _, list in ipairs({ staticTextures, rigStatic }) do
            for _, tex in ipairs(list) do
                tex.OffsetStudsU = math.random() * tex.StudsPerTileU
                tex.OffsetStudsV = math.random() * tex.StudsPerTileV
            end
        end
    end

    -- риг в руках: Стиви — часть предмета, его двигают анимации; модель на плече не нужна
    if equipped and isReskin and #rigParts > 0 then
        buddy.Parent = nil
        return
    end

    local part0, target = getAnchor()

    if not (tool and part0) then
        buddy.Parent = nil
        return
    end
    buddy.Parent = workspace -- не в персонаже, чтобы не скрывался в 1-м лице

    if weld.Part0 ~= part0 then
        -- в reskin руки/плечо — разные детали, поэтому переход без плавности
        local fromShoulder = weld.Part0 and weld.Part0.Name == "HumanoidRootPart" and part0.Name == "HumanoidRootPart"
        weld.Part0 = part0
        if not fromShoulder then currentBase = target end
    end
    currentBase = currentBase:Lerp(target, math.min(dt * 12, 1))

    local offset = CFrame.new()
    if isReskin and equipped then
        -- корпус качается так же, как у настоящего бадди (сустав BuddyJoint из его idle);
        -- при привязке к голове тыквы это уже есть в её движении
        if CONFIG.RESKIN_ANCHOR ~= "Head" and pumpkinJoint and pumpkinJoint.Parent then
            offset = pumpkinJoint.Transform
        end
    else
        -- своё idle-покачивание
        offset = CFrame.new(0, math.sin(t * 2.2) * 0.07, 0)
            * CFrame.Angles(math.sin(t * 1.7) * 0.06, 0, math.sin(t * 1.3) * 0.05)
    end
    local scale = 1

    local face = "Default"

    if anim then
        local p = (t - anim.start) / ANIM_LENGTH[anim.kind]
        if p >= 1 then
            anim = nil
        elseif anim.kind == "equip" then
            -- старт: выше и ближе к камере, днищем к тебе, с креном; опускается на место
            local e = 1 - (1 - p) ^ 3 -- быстрый старт, мягкая посадка
            local r = 1 - e
            offset = offset
                * CFrame.new(0.15 * r, 1.1 * r, -0.9 * r)
                * CFrame.Angles(1.2 * r, 0, -0.45 * r)
            scale = 1 + 0.15 * r
        elseif anim.kind == "jump" then
            -- присед, прыжок вверх к камере (видно днище), приземление с пружинкой
            local squash, hop = 0, 0
            if p < 0.15 then
                squash = math.sin(p / 0.15 * math.pi / 2)
            elseif p < 0.8 then
                hop = math.sin((p - 0.15) / 0.65 * math.pi)
            else
                squash = math.sin((p - 0.8) / 0.2 * math.pi) * 0.6
            end
            offset = offset
                * CFrame.new(0, 1.6 * hop - 0.12 * squash, -0.5 * hop)
                * CFrame.Angles(0.9 * hop, 0, 0)
            scale = 1 - 0.1 * squash
            face = p > 0.15 and p < 0.85 and ANIM_FACE.jump or "Default"
        elseif anim.kind == "look_right" or anim.kind == "look_left" then
            -- поворот корпуса в сторону взгляда и обратно
            local dir = anim.kind == "look_right" and -1 or 1
            local k = holdCurve(p, 0.2, 0.75)
            offset = offset * CFrame.Angles(0, dir * 0.45 * k, dir * 0.08 * k)
            face = k > 0.3 and ANIM_FACE[anim.kind] or "Default"
        elseif anim.kind == "turn" then
            -- разворот спиной, пауза, обратно — с недовольным лицом
            local k = holdCurve(p, 0.35, 0.6)
            offset = offset * CFrame.Angles(0, math.pi * k, 0) * CFrame.new(0, 0.15 * math.sin(p * math.pi), 0)
            face = p > 0.55 and ANIM_FACE.turn or "Default"
        end
    end

    -- reskin: лица по таймлайну игровой анимации (пока трек играет)
    local gameFaceActive = false
    if gameFace then
        local elapsed = t - gameFace.start
        local track = gameFace.track
        local length = (track and track.Length > 0) and track.Length or 3
        -- не смотрим на IsPlaying: игра иногда мгновенно обрывает свой трек осмотра,
        -- и тогда лица осмотра сменялись циклом idle поверх движения
        if elapsed > length then
            gameFace = nil
        else
            gameFaceActive = true
            for _, key in ipairs(gameFace.timeline) do
                if elapsed >= key[1] then face = key[2] end
            end
        end
    end

    -- в покое лицо идёт по циклу IDLE_FACES; анимация его прерывает и сбрасывает
    if anim or gameFaceActive then
        idleStepEnd = 0
    else
        face = idleFace(t)
    end

    if hasFaces then setFace(face) end

    weld.C0 = currentBase * offset

    if math.abs(scale - currentScale) > 0.005 then
        currentScale = scale
        buddy:ScaleTo(baseScale * scale)
    end
end)

---------------------------------------------------------------- старт / очистка

if player.Character then
    task.spawn(onCharacter, player.Character)
end
connect(player.CharacterAdded, onCharacter)

env.__VisualBuddy = {
    Destroy = function()
        if env.__VisualBuddyToken == runToken then env.__VisualBuddyToken = nil end
        for _, c in ipairs(connections) do
            c:Disconnect()
        end
        unbindTool()
        if ownTool then ownTool:Destroy() end
        buddy:Destroy()
        for _, s in pairs(buddySounds) do s:Destroy() end
    end,
}
