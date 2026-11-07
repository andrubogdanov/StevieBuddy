--[[
    Новогодний DOORS — только у тебя на экране (клиентский скрипт, игру не меняет).
      - снег вокруг тебя
      - мигающие гирлянды на каждой двери (провисают фестончиками)
      - ёлочки в горшках: гирлянда спиралью и золотая звезда на макушке
      - уютный свет: лёгкое свечение огоньков и чуть праздничнее цвета
      - новогодняя шапочка на бадди
      - ключ превращается в карамельную трость (и на полу, и в руке), в инвентаре — картинка трости;
        ПКМ — покрутить / подбросить (по очереди), открыл дверь — трость съедается с хрустом
      - подарки под ёлками, иней на окнах (снег на мебели пока выключен)
      - новогодние обои: красно-зелёные ромбы с золотом и снежинками
      - шапки Санты на монстрах (Rush, Ambush, Figure, Seek...), у Скрича — его родной цилиндр
      - украшения из новогодней версии DOORS (festive_export.lua -> workspace/StevieBuddy/festive):
        игрушки и макушки на ёлочках, настоящие лампочки на дверях, подарки, венки
      - скан текстур комнат -> workspace/StevieBuddy/newyear_scan.txt (и в буфер обмена):
        пришли его, и следующим шагом заменим обои, ковры и т.п. на праздничные

    Можно запускать вместе с treat_buddy.lua. Повторный запуск выключает прошлую копию.
]]

local CONFIG = {
    SNOW = true,
    SNOW_RATE = 60,          -- снежинок в секунду
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
    SNOW_FURNITURE = false,  -- снег сверху на шкафах, комодах, столах (пока сырой — выключен)
    FROST_WINDOWS = true,    -- иней на окнах (стёкла белеют и мерцают)
    MONSTER_HATS = true,     -- шапки Санты на монстрах
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
    SCREECH_TOPHAT = true,   -- Скричу — родной цилиндр вместо шапки Санты
    GLOW = true,             -- свечение огоньков (Bloom) и праздничные цвета
    BUDDY_HAT = true,        -- шапочка на бадди
    CANDY_KEY = true,        -- ключ -> карамельная трость
    CANDY_KEY_SCALE = 1,     -- размер трости относительно ключа
    CANE_ICON = true,        -- своя картинка трости в слоте инвентаря вместо ключа
    CANE_ICON_FILE = "StevieBuddy/textures/candy_key_icon.png",
    CANE_ANIMS = true,       -- ПКМ с тростью: покрутить / подбросить (по очереди)
    CANE_RMB_ORDER = { "spin", "toss" },
    CANE_TOSS_HEIGHT = 2.2,  -- как высоко подбрасывать (studs)
    CANE_EAT = true,         -- открыл дверь — съел трость (вместо того чтобы вставлять в замок)
    -- рука «ко рту» (градусы от позы с предметом): RAISE — поднять вперёд-вверх,
    -- INWARD — к центру лица, ELBOW — согнуть локоть
    CANE_EAT_ARM = { RAISE = 55, INWARD = 30, ELBOW = 60 },
    CANE_SOUND_VOLUME = 0.6,
    ASSETS_URL = "https://raw.githubusercontent.com/andrubogdanov/StevieBuddy/main/", -- откуда докачать картинку и звуки
    SCAN = true,             -- сохранить скан текстур комнат
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

--[[ Собрать модель.
    frame   — где стоит начало модели (её pivot) в мире
    opts.scale  — масштаб (1 = как в игре)
    opts.only   — { [имя детали] = true }: собрать только эти детали (и их свет/частицы)
    opts.colors — { [имя детали] = Color3 }: перекрасить
    opts.weld   — деталь, к которой приварить (для того, что двигается: монстры)
    opts.lights, opts.particles — переносить ли свет и частицы (по умолчанию да)
    Возвращает Model и { [имя детали] = Part } ]]
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
            p.Material = fMat(e.material)
            p.Transparency = e.transparency or 0
            p.Reflectance = e.reflectance or 0
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
    if not CONFIG.SNOW then return end
    -- невидимая плита над головой, из неё падают снежинки; ездит за камерой
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
    snow.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0.08),
    })
    snow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.15),
        NumberSequenceKeypoint.new(0.85, 0.2), NumberSequenceKeypoint.new(1, 1),
    })
    snow.EmissionDirection = Enum.NormalId.Bottom
    snow.Speed = NumberRange.new(2.5, 4)
    snow.SpreadAngle = Vector2.new(15, 15)
    snow.Acceleration = Vector3.new(0.6, 0, 0.3) -- лёгкий ветерок
    snow.Lifetime = NumberRange.new(5, 7)
    snow.Rate = CONFIG.SNOW_RATE
    snow.RotSpeed = NumberRange.new(-60, 60)
    snow.Rotation = NumberRange.new(0, 360)
    snow.Parent = cloud

    connect(RunService.RenderStepped, function()
        local cam = workspace.CurrentCamera
        if cam then
            cloud.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 12, 0))
        end
    end)
end)
report("Snow", okSnow, errSnow)

---------------------------------------------------------------- свет

local okGlow, errGlow = pcall(function()
    if not CONFIG.GLOW then return end
    local bloom = track(Instance.new("BloomEffect"))
    bloom.Name = "NewYearBloom"
    bloom.Intensity = 0.6
    bloom.Size = 24
    bloom.Threshold = 0.92
    bloom.Parent = Lighting

    local cc = track(Instance.new("ColorCorrectionEffect"))
    cc.Name = "NewYearColor"
    cc.Saturation = 0.12
    cc.Contrast = 0.04
    cc.TintColor = Color3.fromRGB(255, 248, 244) -- чуть тёплый, как от гирлянд
    cc.Parent = Lighting
end)
report("Glow", okGlow, errGlow)

---------------------------------------------------------------- гирлянды

local bulbs = {} -- { part, light?, index }

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
end

-- настоящая лампочка из новогодней версии: колпачок, плафон и светящаяся лампа.
-- wirePoint — точка на проводе, лампочка висит под ней. Цвет и мигание — общий цикл ниже.
local function addHolidayLight(folder, wirePoint, rot, index, lightEvery)
    local data = loadFestive("HolidayLight")
    if not data then return false end
    local model, parts = spawnFestive(data, CFrame.new(wirePoint - Vector3.new(0, 0.2, 0)) * rot)
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
local function decorateDoor(room, door)
    pcall(dumpDoor, door)
    -- Collision — невидимый блок ровно по проёму (5 x 8 x 1.25), не двигается, когда дверь открыта.
    -- Hidden (2 x 8 x 6) торчит вглубь — его не берём, из-за него гирлянда раньше вставала поперёк.
    local cf, size
    local collision = door:FindFirstChild("Collision")
    local leaf = door:FindFirstChild("Door")
    if collision and collision:IsA("BasePart") then
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
    for _, side in ipairs({ -1, 1 }) do
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
            local scallop = (u * 3) % 1
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

    -- венок над дверью с обеих сторон
    if CONFIG.WREATHS then
        local data = loadFestive("Wreath")
        if data then
            local ws = CONFIG.WREATH_SCALE
            local wsize = data.size and fV3(data.size) or Vector3.new(3.9, 4.1, 1.2)
            for _, side in ipairs({ -1, 1 }) do
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
    if (CONFIG.GIFTS or 0) <= 0 then return end
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
            local model = spawnFestive(data, frame, {
                scale = sc,
                only = { Tops = true, Ornaments1 = true, Ornaments2 = true, Ornaments3 = true },
            })
            model.Parent = folder
            ornamented = true
        end
    end
    if ornamented and style == "ornaments" then
        local okGifts, errGifts = pcall(addGifts, plant, folder)
        if not okGifts then warn("[NewYear] Подарки: " .. tostring(errGifts)) end
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
            if e.part.Parent then
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
                local full = real and not scannedFull and delay >= 0.3
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
local function keyRig(d)
    if d:IsA("Tool") and d.Name == "Key" then
        local handle = d:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then return handle, d, d end
        return nil
    end
    if d:IsA("BasePart") and d.Name == "Key" and d.Parent
        and (d.Parent:FindFirstChild("Ring") or d.Parent:FindFirstChild("Tag")) then
        return d, d.Parent, d:FindFirstAncestor("KeyObtain") or d.Parent
    end
    return nil
end

local onCaneTool -- трость в руке: иконка и анимации (задаётся ниже)

local function caneKey(key, holder, scope)
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

    local cane = buildCane(key, frame, L)
    caneFor[key] = cane
    cane.Parent = holder
    track(cane)
    hidePart(key, cane)
    for _, d in ipairs(scope:GetDescendants()) do
        if d:IsA("BasePart") and CANE_PARTS[d.Name] and not d:IsDescendantOf(cane) then
            hidePart(d, cane)
        elseif d:IsA("SurfaceGui") then
            keepHidden(d, "Enabled", false) -- номер на бирке («0001»)
        end
    end
    for _, d in ipairs(scope:GetDescendants()) do fixHighlight(d) end
    if scope.Name == "KeyObtain" then watchHover(scope, cane) end
    if holder:IsA("Tool") and onCaneTool then pcall(onCaneTool, holder, key, cane) end
    caneCount += 1
end

local function tryKey(d)
    local key, holder, scope = keyRig(d)
    if key and not caneFor[key] then
        local ok, err = pcall(caneKey, key, holder, scope)
        if not ok then warn("[NewYear] Трость: " .. tostring(err)) end
    end
end

local WATCH_NAMES = { Key = true, Ring = true, Tag = true, Handle = true }
local function watchKeys(container)
    if not container then return end
    tryKey(container)
    for _, d in ipairs(container:GetDescendants()) do tryKey(d) end
    connect(container.DescendantAdded, function(d)
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

-- покрутить: трость делает два оборота «пропеллером» перед тобой, рука чуть приподнята
CANE_ANIMS.spin = {
    length = 1.05,
    sounds = { { 0.12, "whoosh" }, { 0.5, "whoosh" } },
    pose = function(t, st)
        local w = bump(t, 0.05, 1.0)
        local arm = {
            RightUpperArm = D(0, 0, 0, K(t, { { 0, 0 }, { 0.15, 14 }, { 0.85, 14 }, { 1.05, 0 } }), 0, 0),
            RightLowerArm = D(0, 0, 0, K(t, { { 0, 0 }, { 0.15, -10 }, { 0.85, -10 }, { 1.05, 0 } }), 0, 0),
            -- кисть описывает маленький круг — крутит
            RightHand = D(0, 0, 0, 9 * w * sin(t * TAU * 2), 0, 9 * w * math.cos(t * TAU * 2)),
        }
        return arm, { angle = K(t, { { 0.06, 0 }, { 0.95, 2 * TAU } }), axis = st.look }
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

-- съесть: рука несёт трость ко рту, четыре укуса с хрустом и крошками, рука возвращается
local BITES = { 0.62, 1.07, 1.52, 1.97 }
CANE_ANIMS.eat = {
    length = 2.5,
    absolute = true,
    pose = function(t)
        local bite = 0
        for _, b in ipairs(BITES) do bite = math.max(bite, bump(t, b - 0.08, b + 0.12)) end
        local A = CONFIG.CANE_EAT_ARM
        local target = {
            RightUpperArm = D(0, 0, 0, A.RAISE + 5 * bite, A.INWARD, 0) * HOLD.RightUpperArm,
            RightLowerArm = D(0, 0, 0, A.ELBOW + 8 * bite, 0, 0) * HOLD.RightLowerArm,
            RightHand = D(0, 0, 0, -12 * bite, 0, 0),
        }
        return target, nil, K(t, { { 0, 0 }, { 0.4, 1 }, { 2.05, 1 }, { 2.5, 0 } })
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

-- Копия трости у кисти: настоящая исчезнет вместе с ключом, когда дверь откроется
local function snackCane(st, info, hand)
    local real = info.cane
    if not (real and real.Parent and hand) then return end
    local fake = Instance.new("Model")
    fake.Name = "NewYearCaneSnack"
    st.parts, st.hidden, st.eaten = {}, {}, 0
    for _, p in ipairs(real:GetChildren()) do
        if p:IsA("BasePart") then
            local c = p:Clone()
            for _, w in ipairs(c:GetChildren()) do
                if w:IsA("JointInstance") then w:Destroy() end
            end
            c.Parent = fake
            weldTo(hand, c, hand.CFrame:ToObjectSpace(p.CFrame))
            table.insert(st.parts, c)
            table.insert(st.hidden, { p, p.Transparency })
            p.Transparency = 1
        end
    end
    fake.Parent = root
    st.snack = fake
    -- кусаем с дальнего от кисти конца
    local hp = hand.Position
    table.sort(st.parts, function(a, b) return (a.Position - hp).Magnitude > (b.Position - hp).Magnitude end)
end

local function biteSnack(st, k)
    if not st.parts then return end
    playCane("crunch")
    local per = math.ceil(#st.parts / #BITES)
    local last = (k >= #BITES) and #st.parts or math.min(#st.parts, st.eaten + per)
    for i = st.eaten + 1, last do
        local p = st.parts[i]
        if p and p.Parent then
            crumbs(p.Position, p.Color, 2)
            p:Destroy()
        end
    end
    st.eaten = last
end

CANE_ANIMS.eat.tick = function(st, prev, t)
    for k, b in ipairs(BITES) do
        if prev < b and t >= b then biteSnack(st, k) end
    end
end

local caneAct = nil -- что играет сейчас
local function finishCane()
    local st = caneAct
    if not st then return end
    caneAct = nil
    for _, j in pairs(st.arm) do releaseJoint(j) end
    if st.grip then releaseJoint(st.grip) end
    if st.snack then st.snack:Destroy() end
    -- ключ так и остался в руке (дверь не открылась) — возвращаем трость
    if st.hidden and st.tool and st.tool:IsDescendantOf(game) then
        for _, h in ipairs(st.hidden) do
            if h[1].Parent then h[1].Transparency = h[2] end
        end
    end
end

local function startCane(name, tool)
    local char = player.Character
    local info = caneTools[tool]
    if not (char and info) then return end
    if caneAct then
        if caneAct.name == "eat" then return end
        finishCane()
    end
    local cam = workspace.CurrentCamera
    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
    local flat = Vector3.new(look.X, 0, look.Z)
    local st = {
        name = name, anim = CANE_ANIMS[name], start = os.clock(), tool = tool, char = char,
        arm = findArm(char), lastT = -1, zero = {},
        look = look, right = cam and cam.CFrame.RightVector or Vector3.xAxis,
        fwd = flat.Magnitude > 1e-3 and flat.Unit or Vector3.zero,
    }
    if name == "eat" then
        info.eaten = true
        snackCane(st, info, char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
    else
        st.grip = findGrip(char, info.handle, tool)
        st.needEquipped = true
    end
    caneAct = st
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
        writeJoint(g, gripMove(g, base, grip.angle, grip.axis, grip.offset))
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

local function startEat(tool)
    local info = caneTools[tool]
    if not (CONFIG.CANE_EAT and info) or info.eaten then return end
    if caneAct and caneAct.name == "eat" then return end
    startCane("eat", tool)
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
            if name == "use" then startEat(tool) end
            if caneAct and caneAct.name == "eat" then
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
    -- открыл замок (на случай, если анимация use называется иначе)
    connect(ProximityPromptService.PromptTriggered, function(prompt, who)
        if who ~= player or prompt.Name ~= "UnlockPrompt" then return end
        task.delay(0.15, function()
            local tool = heldCane()
            if tool then startEat(tool) end
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
    info.handle, info.cane = handle, cane
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
        elseif CONFIG.FROST_WINDOWS and isWindowPane(d) then
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

---------------------------------------------------------------- шапки Санты на монстрах

local MONSTERS = {
    RushMoving = true, AmbushMoving = true, BackdoorRush = true, BackdoorLookman = true,
    Eyes = true, SeekMoving = true, SeekMovingNewClone = true,
    FigureRig = true, FigureRagdoll = true, A60 = true, A120 = true, Screech = true,
}
local hatted = {}

-- Один раз на каждого монстра сохраняем, из чего он сделан (monster_scan.txt),
-- чтобы подогнать шапку точно, если сядет криво
local monsterDumped, monsterLines = {}, {}
local function dumpMonster(model)
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

local function hatMonster(model)
    if hatted[model] then return end
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

local function tryMonster(d)
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
    end,
    Scan = scanRooms, -- можно вызвать вручную: getgenv().__NewYearDoors.Scan()
}

local function notify(title, text, duration)
    if not CONFIG.NOTIFY then return end
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
    local text = ("Гирлянд на дверях: %d, ёлок: %d, подарков: %d, обоев: %d, окон в инее: %d, шапок: %d, тростей: %d%s")
        :format(doorCount, treeCount, giftCount, wallpaperCount, frostCount, hatCount + monsterHatCount, caneCount,
        rooms and "" or ", комнаты не найдены")
    if #status > 0 then text = text .. ". Ошибки: " .. table.concat(status, "; ") end
    notify(#status > 0 and "Новый год: есть ошибки" or "Новый год: всё включено", text, 10)
    print("[NewYear] " .. text)
end)
print("[NewYear] Включено. Через 8 секунд сохраню скан текстур комнат.")
