--[[
    Сканер новогодних штук. Запускать в НОВОГОДНЕЙ версии DOORS (или любой зимней игре),
    походить по комнатам/лобби, где есть украшения, и запустить (можно несколько раз —
    каждый раз дописывает новое к тому, что уже нашёл).

    Записывает ID того, из чего сделаны украшения: меши (форма), текстуры, картинки,
    звуки/музыка, небо. Объекты из игры в игру не переносятся, но по этим ID
    newyear.lua сможет собрать такие же украшения у тебя на экране.

    Результат: workspace/StevieBuddy/festive_scan.txt (и в буфер обмена).
]]

local CONFIG = {
    -- по этим словам в имени (самого объекта или его родителей) понимаем, что это праздничное
    WORDS = {
        "christmas", "xmas", "holiday", "festive", "winter", "snow", "frost", "icy",
        "gift", "present", "candy", "cane", "wreath", "ornament", "garland", "tinsel",
        "tree", "pine", "santa", "elf", "reindeer", "sleigh", "stocking", "mistletoe",
        "bell", "star", "light", "bulb", "bauble", "ribbon", "bow", "gingerbread",
        "cookie", "snowman", "snowflake", "icicle", "newyear", "new_year", "jingle", "hat",
    },
    MAX_OTHER = 250, -- сколько записать «прочих» мешей (без праздничных слов), чтобы ничего не упустить
}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local function festive(inst)
    local node = inst
    for _ = 1, 6 do
        if not node or node == game or node == workspace then break end
        local n = node.Name:lower()
        for _, w in ipairs(CONFIG.WORDS) do
            if n:find(w, 1, true) then return true end
        end
        node = node.Parent
    end
    return false
end

local function short(inst)
    -- путь без длинного начала, чтобы читать было легче
    local path = inst:GetFullName()
    return (#path > 110) and ("..." .. path:sub(-107)) or path
end

local function v3(v) return ("%.2f,%.2f,%.2f"):format(v.X, v.Y, v.Z) end
local function rgb(c) return ("%d,%d,%d"):format(c.R * 255, c.G * 255, c.B * 255) end

-- что нашли: [раздел] = { [ключ] = { count, line } }
local found = {}
local otherCount = 0
local function add(section, key, line)
    found[section] = found[section] or {}
    local e = found[section][key]
    if e then
        e.count += 1
    else
        found[section][key] = { count = 1, line = line }
    end
end

local function scanInst(d)
    local fest = festive(d)
    if d:IsA("MeshPart") then
        if d.MeshId ~= "" then
            local line = ("mesh=%s tex=%s size=%s color=%s material=%s  <- %s"):format(
                d.MeshId, d.TextureID ~= "" and d.TextureID or "-", v3(d.Size), rgb(d.Color),
                d.Material.Name, short(d))
            if fest then
                add("Праздничные меши", d.MeshId .. "|" .. d.TextureID, line)
            elseif otherCount < CONFIG.MAX_OTHER and not (found["Прочие меши"] or {})[d.MeshId] then
                otherCount += 1
                add("Прочие меши", d.MeshId, line)
            end
        end
    elseif d:IsA("SpecialMesh") or d:IsA("FileMesh") then
        if d.MeshId ~= "" then
            local part = d.Parent
            local line = ("mesh=%s tex=%s scale=%s partSize=%s  <- %s"):format(
                d.MeshId, d.TextureId ~= "" and d.TextureId or "-", v3(d.Scale),
                part and part:IsA("BasePart") and v3(part.Size) or "-", short(d))
            add(fest and "Праздничные меши" or "Прочие меши", d.MeshId .. "|" .. d.TextureId, line)
        end
    elseif d:IsA("Decal") or d:IsA("Texture") then
        if d.Texture ~= "" then
            local extra = d:IsA("Texture") and (" tile=%.1fx%.1f"):format(d.StudsPerTileU, d.StudsPerTileV) or ""
            add(fest and "Праздничные картинки и текстуры" or "Прочие картинки и текстуры", d.Texture,
                ("%s [%s]%s  <- %s"):format(d.Texture, d.ClassName, extra, short(d)))
        end
    elseif d:IsA("SurfaceAppearance") then
        add(fest and "Праздничные картинки и текстуры" or "Прочие картинки и текстуры", d.ColorMap,
            ("color=%s normal=%s [SurfaceAppearance]  <- %s"):format(d.ColorMap, d.NormalMap, short(d)))
    elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
        if fest and d.Image ~= "" then
            add("Праздничные картинки и текстуры", d.Image, ("%s [%s]  <- %s"):format(d.Image, d.ClassName, short(d)))
        end
    elseif d:IsA("Sound") then
        if d.SoundId ~= "" then
            add(fest and "Праздничные звуки" or "Прочие звуки", d.SoundId,
                ("%s len=%.1fs  <- %s"):format(d.SoundId, d.TimeLength, short(d)))
        end
    elseif d:IsA("ParticleEmitter") then
        add(fest and "Праздничные частицы" or "Прочие частицы", d.Texture,
            ("%s rate=%s  <- %s"):format(d.Texture, tostring(d.Rate), short(d)))
    elseif d:IsA("Sky") then
        add("Небо", d.SkyboxFt, ("bk=%s dn=%s ft=%s lf=%s rt=%s up=%s"):format(
            d.SkyboxBk, d.SkyboxDn, d.SkyboxFt, d.SkyboxLf, d.SkyboxRt, d.SkyboxUp))
    elseif fest and (d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) then
        add("Праздничный свет", rgb(d.Color) .. d.ClassName,
            ("%s color=%s brightness=%.2f range=%.1f  <- %s"):format(
                d.ClassName, rgb(d.Color), d.Brightness, d.Range, short(d)))
    end
end

-- праздничные модели целиком: имя и размер, чтобы понять, что это за штука
local models = {}
local function scanModel(m)
    if m:IsA("Model") and festive(m) and not festive(m.Parent) then
        local ok, _, size = pcall(m.GetBoundingBox, m)
        local key = m.Name
        models[key] = models[key] or { count = 0, line = "" }
        models[key].count += 1
        models[key].line = ("%s size=%s  <- %s"):format(m.Name, ok and v3(size) or "?", short(m))
    end
end

local roots = { workspace, Lighting, game:GetService("ReplicatedStorage"), game:GetService("SoundService") }
local pg = player:FindFirstChild("PlayerGui")
if pg then table.insert(roots, pg) end

local scanned = 0
for _, r in ipairs(roots) do
    for i, d in ipairs(r:GetDescendants()) do
        pcall(scanInst, d)
        pcall(scanModel, d)
        scanned += 1
        if i % 5000 == 0 then task.wait() end -- чтобы игра не подвисала
    end
end

local out = { ("Игра: %s (PlaceId %d), просмотрено объектов: %d"):format(
    game.Name, game.PlaceId, scanned) }

local function dumpSection(title, list)
    local rows = {}
    for _, e in pairs(list) do table.insert(rows, e) end
    if #rows == 0 then return end
    table.sort(rows, function(a, b) return a.count > b.count end)
    table.insert(out, "")
    table.insert(out, ("===== %s (%d) ====="):format(title, #rows))
    for _, e in ipairs(rows) do
        table.insert(out, ("%4d  %s"):format(e.count, e.line))
    end
end

dumpSection("Праздничные модели", models)
for _, title in ipairs({
    "Праздничные меши", "Праздничные картинки и текстуры", "Праздничные звуки",
    "Праздничные частицы", "Праздничный свет", "Небо",
    "Прочие картинки и текстуры", "Прочие звуки", "Прочие частицы", "Прочие меши",
}) do
    if found[title] then dumpSection(title, found[title]) end
end

local text = table.concat(out, "\n")
local file = "StevieBuddy/festive_scan.txt"
pcall(function()
    if makefolder and not (isfolder and isfolder("StevieBuddy")) then makefolder("StevieBuddy") end
    -- если уже сканировал в другом месте — дописываем, а не затираем
    if isfile and isfile(file) and appendfile then
        appendfile(file, "\n\n################ ещё один скан ################\n" .. text)
    else
        writefile(file, text)
    end
end)
if setclipboard then pcall(setclipboard, text) end

local modelCount = 0
for _ in pairs(models) do modelCount += 1 end
local festMeshes = 0
for _ in pairs(found["Праздничные меши"] or {}) do festMeshes += 1 end
local msg = ("Праздничных моделей: %d, мешей: %d. Файл workspace/%s"):format(modelCount, festMeshes, file)
print("[FestiveScan] " .. msg)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Скан готов", Text = msg, Duration = 8,
    })
end)
