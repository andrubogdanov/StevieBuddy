--[[
    Экспорт новогодних моделей. Запускать в НОВОГОДНЕЙ версии DOORS
    (там же, где запускал festive_scan.lua; лучше в комнате, где видны ёлки и гирлянды).

    Сохраняет выбранные модели целиком: из каких деталей, где каждая стоит, размер,
    цвет, материал, меш, свет, частицы. По этим файлам newyear.lua соберёт такие же
    украшения в обычном DOORS (у тебя на экране).

    Файлы: workspace/StevieBuddy/festive/<имя>.json
    Можно запускать несколько раз в разных местах — уже сохранённые модели не трогает
    (кроме тех, что сохранились неполными).
]]

local TARGETS = {
    -- имя модели/детали = зачем
    ["Potted_Plant-XMAS25"] = "игрушки и макушка для наших ёлочек",
    ["HolidayLight"] = "одна лампочка гирлянды",
    ["HolidayLights"] = "гирлянда целиком (как висит)",
    ["Present"] = "подарок",
    ["Wreath"] = "венок",
    ["CandyCane"] = "большая трость",
    ["Cane"] = "полосатая спираль на колонне",
    ["XmasTree"] = "большая ёлка",
    ["Tophat"] = "цилиндр Скрича",
    ["SnowPile"] = "сугроб",
    ["Snow Particles Tiny"] = "снег в комнате",
    ["Window-XMAS25"] = "новогоднее окно",
    ["CringlePresent"] = "подарок Крингла",
}

local HttpService = game:GetService("HttpService")
local FOLDER = "StevieBuddy/festive"

local function ensureFolder()
    if not makefolder then return end
    if not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
    if not (isfolder and isfolder(FOLDER)) then makefolder(FOLDER) end
end

local function cfArray(cf)
    return { cf:GetComponents() }
end
local function v3(v) return { v.X, v.Y, v.Z } end
local function c3(c) return { c.R, c.G, c.B } end
local function numSeq(s)
    local out = {}
    for _, k in ipairs(s.Keypoints) do table.insert(out, { k.Time, k.Value, k.Envelope }) end
    return out
end
local function colSeq(s)
    local out = {}
    for _, k in ipairs(s.Keypoints) do table.insert(out, { k.Time, k.Value.R, k.Value.G, k.Value.B }) end
    return out
end

-- MeshSize (родной размер меша) нужен, чтобы собрать меш через SpecialMesh;
-- обычным скриптом он не читается, поэтому пробуем по-разному
local function meshSize(p)
    local ok, v = pcall(function() return p.MeshSize end)
    if ok and typeof(v) == "Vector3" then return v3(v) end
    if gethiddenproperty then
        local ok2, v2 = pcall(gethiddenproperty, p, "MeshSize")
        if ok2 and typeof(v2) == "Vector3" then return v3(v2) end
    end
    return nil
end

local function serialize(root)
    local pivot = root:IsA("Model") and root:GetPivot() or root.CFrame
    local items, index = {}, {}
    local list = { root }
    for _, d in ipairs(root:GetDescendants()) do table.insert(list, d) end

    for i, d in ipairs(list) do index[d] = i end
    for i, d in ipairs(list) do
        local e = { i = i, class = d.ClassName, name = d.Name, parent = d ~= root and index[d.Parent] or nil }
        local ok = pcall(function()
            if d:IsA("BasePart") then
                e.cf = cfArray(pivot:ToObjectSpace(d.CFrame))
                e.size = v3(d.Size)
                e.color = c3(d.Color)
                e.material = d.Material.Name
                e.transparency = d.Transparency
                e.reflectance = d.Reflectance
                e.castShadow = d.CastShadow
                if d:IsA("MeshPart") then
                    e.meshId = d.MeshId
                    e.textureId = d.TextureID
                    e.meshSize = meshSize(d)
                elseif d:IsA("Part") then
                    e.shape = d.Shape.Name
                end
            elseif d:IsA("SpecialMesh") then
                e.meshType = d.MeshType.Name
                e.meshId = d.MeshId
                e.textureId = d.TextureId
                e.scale = v3(d.Scale)
                e.offset = v3(d.Offset)
                e.vertexColor = v3(d.VertexColor)
            elseif d:IsA("Decal") or d:IsA("Texture") then
                e.texture = d.Texture
                e.face = d.Face.Name
                e.color3 = c3(d.Color3)
                e.transparency = d.Transparency
                if d:IsA("Texture") then
                    e.tile = { d.StudsPerTileU, d.StudsPerTileV, d.OffsetStudsU, d.OffsetStudsV }
                end
            elseif d:IsA("SurfaceAppearance") then
                -- сами карты обычным скриптом не назначить, но запомним
                e.colorMap = d.ColorMap
            elseif d:IsA("Attachment") then
                e.cf = cfArray(d.CFrame)
            elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                e.color = c3(d.Color)
                e.brightness = d.Brightness
                e.range = d.Range
                e.shadows = d.Shadows
                if not d:IsA("PointLight") then
                    e.angle = d.Angle
                    e.face = d.Face.Name
                end
            elseif d:IsA("ParticleEmitter") then
                e.texture = d.Texture
                e.rate = d.Rate
                e.lifetime = { d.Lifetime.Min, d.Lifetime.Max }
                e.speed = { d.Speed.Min, d.Speed.Max }
                e.spread = v3(Vector3.new(d.SpreadAngle.X, d.SpreadAngle.Y, 0))
                e.sizeSeq = numSeq(d.Size)
                e.transparencySeq = numSeq(d.Transparency)
                e.colorSeq = colSeq(d.Color)
                e.lightEmission = d.LightEmission
                e.lightInfluence = d.LightInfluence
                e.acceleration = v3(d.Acceleration)
                e.drag = d.Drag
                e.rotation = { d.Rotation.Min, d.Rotation.Max }
                e.rotSpeed = { d.RotSpeed.Min, d.RotSpeed.Max }
                e.emissionDirection = d.EmissionDirection.Name
                e.orientation = d.Orientation.Name
                e.lockedToPart = d.LockedToPart
                e.zOffset = d.ZOffset
                e.shape = d.Shape.Name
                e.shapeStyle = d.ShapeStyle.Name
                e.enabled = d.Enabled
            elseif d:IsA("Beam") then
                e.texture = d.Texture
                e.width = { d.Width0, d.Width1 }
                e.colorSeq = colSeq(d.Color)
            end
        end)
        if not ok then e.error = true end
        table.insert(items, e)
    end

    local _, size = pcall(function()
        if root:IsA("Model") then
            local _, s = root:GetBoundingBox()
            return s
        end
        return root.Size
    end)
    return {
        name = root.Name,
        source = root:GetFullName(),
        place = game.PlaceId,
        size = typeof(size) == "Vector3" and v3(size) or nil,
        items = items,
    }
end

-- ищем по первому найденному экземпляру; в комнатах — предпочитаем видимые в workspace
local found = {}
local function look(container)
    if not container then return end
    for _, d in ipairs(container:GetDescendants()) do
        if TARGETS[d.Name] and not found[d.Name] and (d:IsA("Model") or d:IsA("BasePart")) then
            found[d.Name] = d
        end
    end
end
look(workspace:FindFirstChild("CurrentRooms"))
look(workspace)
look(game:GetService("ReplicatedStorage"))

ensureFolder()
local saved, skipped, missing = {}, {}, {}
for name, why in pairs(TARGETS) do
    local inst = found[name]
    local file = FOLDER .. "/" .. name .. ".json"
    if not inst then
        table.insert(missing, name)
    elseif isfile and isfile(file) then
        table.insert(skipped, name)
    else
        local ok, data = pcall(serialize, inst)
        if ok then
            local okJson, json = pcall(HttpService.JSONEncode, HttpService, data)
            if okJson then
                pcall(writefile, file, json)
                table.insert(saved, ("%s (%d деталей) — %s"):format(name, #data.items, why))
            else
                warn("[FestiveExport] JSON для " .. name .. ": " .. tostring(json))
            end
        else
            warn("[FestiveExport] " .. name .. ": " .. tostring(data))
        end
    end
end

local report = {
    "Сохранено: " .. (#saved > 0 and ("\n  " .. table.concat(saved, "\n  ")) or "ничего"),
    "Уже было: " .. (#skipped > 0 and table.concat(skipped, ", ") or "-"),
    "Не нашёл здесь: " .. (#missing > 0 and table.concat(missing, ", ") or "-"),
}
local text = table.concat(report, "\n")
print("[FestiveExport]\n" .. text)
pcall(writefile, FOLDER .. "/_report.txt", text)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Экспорт готов",
        Text = ("Сохранено: %d, не нашёл: %d. Папка workspace/%s"):format(#saved, #missing, FOLDER),
        Duration = 8,
    })
end)
