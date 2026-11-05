if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local FOLDER, FILE = "ColdBlood", "ColdBlood"
local CFG_PATH = FOLDER .. "/" .. FILE .. ".json"
if isfolder and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end

local saved = {}
pcall(function()
    if isfile and readfile and isfile(CFG_PATH) then
        local data = HttpService:JSONDecode(readfile(CFG_PATH))
        if type(data) == "table" then saved = data end
    end
end)
local function saveCfg()
    pcall(function()
        if writefile then writefile(CFG_PATH, HttpService:JSONEncode(saved)) end
    end)
end

local GREEN = Color3.fromRGB(60, 255, 60)
local WHITE = Color3.fromRGB(245, 245, 245)
local BLACK = Color3.fromRGB(0, 0, 0)
local WIN_W, WIN_H, BAR_H = 330, 400, 42

local UI: any = {
    State = {
        DinoESPAlive = false, DinoESPDead = false,
        Aimbot = false, AimAlways = false, SilentAim = false,
        UpdateDelay = 1, ESPRange = 1500, AimFOV = 200, AimSmooth = 0.4, SilentAngle = 60,
    },
}
local alive = true
local connections = {}
local function track(c) connections[#connections + 1] = c return c end

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = o
end
local function pad(o, p)
    local u = Instance.new("UIPadding")
    u.PaddingTop, u.PaddingBottom = UDim.new(0, p), UDim.new(0, p)
    u.PaddingLeft, u.PaddingRight = UDim.new(0, p), UDim.new(0, p)
    u.Parent = o
end
local function esc(s)
    return ((tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")))
end
local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local gui = Instance.new("ScreenGui")
gui.Name = "ColdBlood"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end) then
    gui.Parent = PlayerGui
end
UI.gui = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(WIN_W, WIN_H)
main.Position = UDim2.new(1, -(WIN_W + 24), 0, 60)
main.BackgroundColor3 = BLACK
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.ClipsDescendants = true
corner(main, 14)
main.Parent = gui

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, BAR_H)
bar.BackgroundColor3 = BLACK
bar.BorderSizePixel = 0
corner(bar, 14)
bar.Parent = main

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(1, 0, 0, 14)
barFill.Position = UDim2.new(0, 0, 1, -14)
barFill.BackgroundColor3 = BLACK
barFill.BorderSizePixel = 0
barFill.Parent = bar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, 0, 0, 26)
titleLbl.Position = UDim2.new(0, 0, 0, 2)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 16
titleLbl.TextColor3 = GREEN
titleLbl.Text = "Cold Blood"
titleLbl.Parent = bar

local creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(1, 0, 0, 12)
creditLbl.Position = UDim2.new(0, 0, 0, 27)
creditLbl.BackgroundTransparency = 1
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 10
creditLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
creditLbl.Text = "made by YourBae"
creditLbl.Parent = bar

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 22, 0, 18)
btnMin.Position = UDim2.new(1, -52, 0, 6)
btnMin.BackgroundColor3 = GREEN
btnMin.BorderSizePixel = 0
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 14
btnMin.TextColor3 = BLACK
btnMin.Text = "_"
corner(btnMin, 6)
btnMin.Parent = bar

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 22, 0, 18)
btnClose.Position = UDim2.new(1, -26, 0, 6)
btnClose.BackgroundColor3 = GREEN
btnClose.BorderSizePixel = 0
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 12
btnClose.TextColor3 = BLACK
btnClose.Text = "X"
corner(btnClose, 6)
btnClose.Parent = bar

local body = Instance.new("ScrollingFrame")
body.Position = UDim2.new(0, 0, 0, BAR_H)
body.Size = UDim2.new(1, 0, 1, -BAR_H)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 4
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.CanvasSize = UDim2.new()
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = main
pad(body, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = body

local orderN = 0
local function nextOrder() orderN = orderN + 1 return orderN end
UI.nextOrder = nextOrder

function UI.paragraph(title, content)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    lbl.BackgroundTransparency = 0.4
    lbl.BorderSizePixel = 0
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.RichText = true
    lbl.LayoutOrder = nextOrder()
    pad(lbl, 6)
    corner(lbl, 8)
    lbl.Parent = body
    local obj = {}
    function obj:Set(t)
        local ttl = t.Title or ""
        local col = ttl:find("Hunting", 1, true) and "#FF4040" or "#3CFF3C"
        lbl.Text = '<font color="' .. col .. '"><b>' .. esc(ttl) .. "</b></font>\n" .. esc(t.Content or "")
    end
    obj:Set({Title = title, Content = content})
    return obj
end

function UI.group()
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder()
    f.Parent = body
    local g = Instance.new("UIGridLayout")
    g.CellSize = UDim2.new(0.5, -3, 0, 24)
    g.CellPadding = UDim2.fromOffset(5, 5)
    g.SortOrder = Enum.SortOrder.LayoutOrder
    g.Parent = f
    return f
end

local function makeBtn(parent, text)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = WHITE
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = BLACK
    b.TextWrapped = true
    b.Text = text
    b.LayoutOrder = nextOrder()
    if parent == body then b.Size = UDim2.new(1, 0, 0, 24) end
    corner(b, 8)
    b.Parent = parent
    return b
end

function UI.button(parent, name, order, cb)
    local b = makeBtn(parent, name)
    b.LayoutOrder = order
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end

function UI.toggle(parent, name, flag, cb, onColor, default)
    local on = saved[flag]
    if on == nil then on = (default == true) end
    local b = makeBtn(parent, name)
    local function render() b.BackgroundColor3 = on and (onColor or GREEN) or WHITE end
    b.MouseButton1Click:Connect(function()
        on = not on
        saved[flag] = on
        saveCfg()
        render()
        pcall(cb, on)
    end)
    render()
    pcall(cb, on)
    return b
end

function UI.slider(name, flag, min, max, inc, default, suffix, cb)
    local value = math.clamp(tonumber(saved[flag]) or default, min, max)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.LayoutOrder = nextOrder()
    frame.Parent = body
    corner(frame, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Position = UDim2.new(0, 8, 0, 2)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = WHITE
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local trackF = Instance.new("Frame")
    trackF.Size = UDim2.new(1, -16, 0, 8)
    trackF.Position = UDim2.new(0, 8, 0, 21)
    trackF.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    trackF.BorderSizePixel = 0
    trackF.Parent = frame
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = GREEN
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = trackF
    corner(trackF, 6)
    corner(fill, 6)

    local function render()
        local txt = inc < 1 and string.format("%.1f", value) or tostring(value)
        label.Text = name .. ": " .. txt .. " " .. suffix
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    end
    local function setFromX(x)
        local rel = math.clamp((x - trackF.AbsolutePosition.X) / math.max(trackF.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor((min + (max - min) * rel) / inc + 0.5) * inc
        v = math.clamp(v, min, max)
        if v ~= value then
            value = v
            saved[flag] = v
            render()
            pcall(cb, v)
        end
    end
    local dragging = false
    trackF.InputBegan:Connect(function(i)
        if isPress(i) then dragging = true setFromX(i.Position.X) end
    end)
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if dragging and isPress(i) then dragging = false saveCfg() end
    end))
    render()
    pcall(cb, value)
end

local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local State             = UI.State

local function safe(tag, fn, ...)
    return (xpcall(fn, function(e) return e end, ...))
end

UI.DinoInfo = UI.paragraph("Cold Blood", "Waiting for dinos...")
UI.toggles  = UI.group()

local function onToggle(flag)
    return function(v)
        UI.State[flag] = v
        if UI.onToggle then pcall(UI.onToggle, flag, v) end
    end
end

UI.toggle(UI.toggles, "Dino ESP (Alive)", "DinoESPAlive", onToggle("DinoESPAlive"))
UI.toggle(UI.toggles, "Dino ESP (Dead)",  "DinoESPDead",  onToggle("DinoESPDead"))
UI.toggle(UI.toggles, "Auto Aim", "SilentAim", function(v)
    onToggle("SilentAim")(v)
    onToggle("Aimbot")(v)
end)
UI.toggle(UI.toggles, "Wall Check (visible targets only)", "WallCheck", onToggle("WallCheck"), nil, true)
UI.toggle(UI.toggles, "Hide Grass/Bushes", "HideGrass", onToggle("HideGrass"))

UI.slider("Update Delay", "UpdateDelay", 0.5, 5, 0.5, 1, "sec", function(v) UI.State.UpdateDelay = v end)
UI.slider("ESP Range",    "ESPRange",    100, 3000, 100, 1500, "st", function(v) UI.State.ESPRange = v end)
UI.slider("Near ESP (hide far ones)", "NearRadius", 50, 1000, 50, 300, "st", function(v) UI.State.NearRadius = v end)
UI.slider("Aim FOV",      "AimFOV",      50, 600, 10, 200, "px",  function(v) UI.State.AimFOV = v end)
UI.slider("Aim Smooth",   "AimSmooth",   0.1, 1, 0.1, 0.4, "(1 = instant)", function(v) UI.State.AimSmooth = v end)
UI.slider("Auto Aim Max Angle", "SilentAngle", 5, 180, 5, 60, "deg", function(v) UI.State.SilentAngle = v end)

local ALIVE_COL, DEAD_COL = Color3.fromRGB(60, 255, 60), Color3.fromRGB(255, 70, 70)
local HEAD_PARTS = {"Head", "Brain", "EyeR", "EyeL", "Cheek", "Snout"}
local BODY_PARTS = {"Heart", "LowerLungs", "UpperLungs", "Chest", "Neck", "Spine", "Liver", "Brisket", "Pelvis", "Belly", "Haunch"}
local DEAD_MARK_TTL = 600

local deadIds, deadMarks, speciesOf = {}, {}, {}
local gameAiming, silentTarget, silentName, fireCount = false, nil, nil, 0
local aimHold = false
local claimedIds = {}
local mineIds = {}
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP"
espFolder.Parent = gui
local entries = {}

local function cam() return Workspace.CurrentCamera end
local function dinoFolder() return Workspace:FindFirstChild("Dinos") end
local EXTRA_PAT = {"pter", "flock", "bird", "flying", "fly", "ambient", "fauna", "wildlife", "creature", "animal"}
local function nameHas(n, pats)
    n = n:lower()
    for _, p in ipairs(pats) do
        if n:find(p, 1, true) then return true end
    end
    return false
end
local extraList, extraT = {}, 0
local scanFliers
local function scanContainer(list, c, depth)
    for _, ch in ipairs(c:GetChildren()) do
        if ch.Name == "Dinos" or ch.Name == "Terrain" or ch.Name == "DinoVisuals" or ch.Name == "PQ_Fliers" or ch.Name == "PQ_Birds" or ch == cam() then
        elseif (ch:IsA("Model") and ch:GetAttribute("SpeciesId") ~= nil) then
            list[#list + 1] = ch
        elseif nameHas(ch.Name, EXTRA_PAT) then
            if ch:IsA("Folder") or (ch:IsA("Model") and not ch.PrimaryPart and #ch:GetChildren() > 0 and ch:FindFirstChildWhichIsA("Model")) then
                for _, k in ipairs(ch:GetChildren()) do
                    if k:IsA("Model") or k:IsA("BasePart") then list[#list + 1] = k end
                end
            elseif ch:IsA("Model") or ch:IsA("BasePart") then
                list[#list + 1] = ch
            end
        elseif depth < 2 and (ch:IsA("Folder") or ch:IsA("Model")) then
            scanContainer(list, ch, depth + 1)
        end
    end
end
local function scanExtras()
    local list = {}
    scanContainer(list, Workspace, 0)
    pcall(scanFliers, list)
    return list
end
local flierSet = setmetatable({}, {__mode = "k"})
local flierUid, flierN = setmetatable({}, {__mode = "k"}), 0
local function collectFlier(list, c, depth)
    if c:IsA("BasePart") then
        list[#list + 1] = c
    elseif c:IsA("Model") or c:IsA("Folder") then
        local hasSub = false
        for _, k in ipairs(c:GetChildren()) do
            if k:IsA("Model") and k:FindFirstChildWhichIsA("BasePart", true) then hasSub = true break end
        end
        if hasSub and depth < 3 then
            for _, k in ipairs(c:GetChildren()) do
                if k:IsA("Model") or k:IsA("BasePart") then collectFlier(list, k, depth + 1) end
            end
        elseif c:IsA("Model") and c:FindFirstChildWhichIsA("BasePart", true) then
            list[#list + 1] = c
        end
    end
end
function scanFliers(list)
    local f = Workspace:FindFirstChild("PQ_Fliers")
    if not f then return end
    local tmp = {}
    for _, c in ipairs(f:GetChildren()) do collectFlier(tmp, c, 0) end
    for _, m in ipairs(tmp) do flierSet[m] = true list[#list + 1] = m end
end

local modelsCache, modelsT = {}, 0
local function allDinoModels()
    local now = os.clock()
    if now - modelsT < 0.2 then return modelsCache end
    modelsT = now
    if now - extraT > 5 then
        extraT = now
        extraList = scanExtras()
    end
    local out = {}
    local f = dinoFolder()
    if f then
        for _, m in ipairs(f:GetChildren()) do
            if m:IsA("Model") then out[#out + 1] = m end
        end
    end
    for _, m in ipairs(extraList) do
        if m.Parent then out[#out + 1] = m end
    end
    modelsCache = out
    return out
end
local function keyOf(model)
    if flierSet[model] then
        local id = flierUid[model]
        if not id then flierN = flierN + 1 id = "fly:" .. flierN flierUid[model] = id end
        return id
    end
    local p = model.Parent
    if p and p.Name ~= "Dinos" then return model.Name .. ":" .. p.Name end
    return model.Name
end
local function speciesOfModel(model)
    local sp = model:GetAttribute("SpeciesId")
    if sp then speciesOf[model.Name] = sp end
    return sp or speciesOf[model.Name] or model.Name
end

local function rootOf(model)
    if model:IsA("BasePart") then return model end
    return model.PrimaryPart or model:FindFirstChild("Pelvis") or model:FindFirstChildWhichIsA("BasePart", true)
end
local DEAD_FLAGS = {"Dead", "IsDead", "Died", "Carcass", "Corpse", "Killed"}
local DEAD_STRS = {"State", "Pose", "Gait"}
local function deadReason(model)
    if deadIds[model.Name] then return "remote Death event (deadIds)" end
    if model:GetAttribute("Alive") == false then return "attr Alive=false" end
    if model:GetAttribute("Claimable") == true then return "attr Claimable=true" end
    for _, a in ipairs(DEAD_FLAGS) do
        if model:GetAttribute(a) == true then return "attr " .. a .. "=true" end
    end
    for _, a in ipairs(DEAD_STRS) do
        local st = model:GetAttribute(a)
        if type(st) == "string" then
            local l = st:lower()
            if l:find("dead") or l:find("carcass") or l:find("corpse") or l:find("ragdoll") then
                return "attr " .. a .. "=" .. st
            end
        end
    end
    local hp = model:GetAttribute("Health")
    if type(hp) == "number" and hp <= 0 then return "attr Health<=0" end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return "Humanoid Health<=0" end
    return nil
end
local function isDead(model)
    return deadReason(model) ~= nil
end

task.spawn(function()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
    if not remotes then return end
    local dr = remotes:WaitForChild("DinoReplicate", 30)
    if dr then
        track(dr.OnClientEvent:Connect(function(a)
            if type(a) ~= "table" or not a.dinoId then return end
            if a.speciesId then speciesOf[a.dinoId] = a.speciesId end
            if a.event == "Death" then
                deadIds[a.dinoId] = true
                if typeof(a.position) == "Vector3" then deadMarks[a.dinoId] = {pos = a.position, t = os.clock()} end
            end
        end))
    end
    local he = remotes:WaitForChild("HuntEvent", 30)
    if he then
        track(he.OnClientEvent:Connect(function(a)
            if type(a) ~= "table" then return end
            if a.dinoId and tostring(a.type):lower():find("claim") then
                claimedIds[a.dinoId] = true
                deadMarks[a.dinoId] = nil
                if UI.removeESP then UI.removeESP(a.dinoId) end
            end
        end))
    end
end)

local function removeEntry(key)
    local e = entries[key]
    if not e then return end
    pcall(function() e.bb:Destroy() end)
    if e.marker then pcall(function() e.marker:Destroy() end) end
    entries[key] = nil
end
UI.removeESP = function(id) removeEntry(id) removeEntry("m" .. id) end
local function ensureEntry(key, root, marker)
    local e = entries[key]
    if e and e.root == root then return e end
    removeEntry(key)
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(170, 34)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.Adornee = root
    bb.Parent = espFolder
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextStrokeTransparency = 0.3
    lbl.Parent = bb
    e = {bb = bb, label = lbl, root = root, marker = marker}
    entries[key] = e
    return e
end

local lastPos, folderConn, hookedFolder = {}, nil, nil
local function hookFolder(f)
    if hookedFolder == f then return end
    hookedFolder = f
    if folderConn then pcall(function() folderConn:Disconnect() end) end
    folderConn = track(f.ChildRemoved:Connect(function(m)
        local id = m.Name
        local lp = lastPos[id]
        local c = cam()
        local wasDead = deadIds[id] or select(2, pcall(isDead, m)) == true
        if not wasDead then return end
        local d = (lp and c) and (lp - c.CFrame.Position).Magnitude or -1
        if lp and c and d < 120 then
            claimedIds[id] = true
            deadMarks[id] = nil
            UI.removeESP(id)
        end
    end))
end

local lastInfo
local function refresh()
    local seen, alive_n, dead_n, mine_n = {}, 0, 0, 0
    local folder = dinoFolder()
    if folder then hookFolder(folder) end
    do
        for _, model in ipairs(allDinoModels()) do
            if not claimedIds[model.Name] then
                local reason = deadReason(model)
                local dead = reason ~= nil
                local mine = true
                if dead then
                    dead_n += 1
                    mine = model:GetAttribute("ClaimOwner") == LP.UserId
                    if mine then
                        mine_n += 1
                        mineIds[model.Name] = true
                    end
                else
                    alive_n += 1
                end
                if model.Parent == folder then
                    local r0 = rootOf(model)
                    if r0 then lastPos[model.Name] = r0.Position end
                end
                local hideIt = dead and not mine
                if not hideIt and ((dead and State.DinoESPDead) or (not dead and State.DinoESPAlive)) then
                    local root = rootOf(model)
                    if root then
                        if model.Parent == folder then lastPos[model.Name] = root.Position end
                        local key = keyOf(model)
                        local e = ensureEntry(key, root)
                        e.dead, e.species = dead, speciesOfModel(model)
                        e.fly = flierSet[model] == true
                        e.label.TextColor3 = dead and DEAD_COL or ALIVE_COL
                        seen[key] = true
                    end
                end
            end
        end
    end
    for id, m in pairs(deadMarks) do
        if os.clock() - m.t > DEAD_MARK_TTL then
            deadMarks[id] = nil
        elseif claimedIds[id] then
            deadMarks[id] = nil
        elseif State.DinoESPDead and mineIds[id] and not (folder and folder:FindFirstChild(id)) then
            local key = "m" .. id
            local e = entries[key]
            if not e then
                local part = Instance.new("Part")
                part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
                part.Transparency = 1
                part.Size = Vector3.one
                part.Position = m.pos
                part.Parent = cam()
                e = ensureEntry(key, part, part)
            end
            e.dead, e.species = true, speciesOf[id] or id
            e.label.TextColor3 = DEAD_COL
            seen[key] = true
        end
    end
    for key in pairs(entries) do
        if not seen[key] then removeEntry(key) end
    end
    local info = string.format("Alive: %d   Dead: %d (yours: %d)", alive_n, dead_n, mine_n)
    if info ~= lastInfo then
        lastInfo = info
        UI.DinoInfo:Set({Title = "Cold Blood", Content = info})
    end
end

local function updateLabels()
    local c = cam()
    if not c then return end
    local cp = c.CFrame.Position
    local nearAlive, nearDead = false, false
    for _, e in pairs(entries) do
        if e.root and e.root.Parent then
            e.dist = (e.root.Position - cp).Magnitude
            if e.dist <= State.NearRadius then
                if e.dead then nearDead = true else nearAlive = true end
            end
        end
    end
    for _, e in pairs(entries) do
        if e.root and e.root.Parent and e.dist then
            local hasNear = e.dead and nearDead or ((not e.dead) and nearAlive)
            local show
            local rng = State.ESPRange
            show = e.dist <= rng and ((not hasNear) or e.dist <= State.NearRadius)
            if e.bb.Enabled ~= show then e.bb.Enabled = show end
            if show then
                local txt = string.format("%s [%s]\n%d st", tostring(e.species), e.dead and "DEAD - CLAIM" or "ALIVE", math.floor(e.dist))
                if e.label.Text ~= txt then e.label.Text = txt end
            end
        end
    end
end

task.spawn(function()
    local last = 0
    while alive do
        if os.clock() - last >= State.UpdateDelay then
            last = os.clock()
            safe("refresh", refresh)
        end
        safe("labels", updateLabels)
        task.wait(0.25)
    end
end)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local stats = {}

local GRASS_PAT = {"grass", "fern", "bush", "shrub", "thicket", "foliage", "weed", "reed", "undergrowth", "flower"}
local hiddenParts, hiddenDecals, hiddenRoots = {}, {}, {}
local grassApplied, grassConn, terrainDeco = false, nil, nil

local function matchName(n)
    n = n:lower()
    for _, p in ipairs(GRASS_PAT) do
        if n:find(p, 1, true) then return true end
    end
    return false
end
local function hideOne(i)
    if i:IsA("BasePart") then
        hiddenParts[i] = true
        i.LocalTransparencyModifier = 1
    elseif i:IsA("Decal") or i:IsA("Texture") then
        if hiddenDecals[i] == nil then hiddenDecals[i] = i.Transparency end
        i.Transparency = 1
    end
end
local function hideTree(root)
    hiddenRoots[#hiddenRoots + 1] = root
    hideOne(root)
    for _, d in ipairs(root:GetDescendants()) do hideOne(d) end
end
local function inGrass(d, stop)
    local a = d.Parent
    while a and a ~= stop do
        if matchName(a.Name) then return true end
        a = a.Parent
    end
    return false
end

local function applyGrass()
    pcall(function()
        local t = Workspace.Terrain
        if terrainDeco == nil then
            terrainDeco = (gethiddenproperty and gethiddenproperty(t, "Decoration")) or t.Decoration
        end
        if sethiddenproperty then sethiddenproperty(t, "Decoration", false) else t.Decoration = false end
    end)
    local regions = Workspace:FindFirstChild("Regions")
    if not regions then return end
    grassConn = regions.DescendantAdded:Connect(function(d)
        if not grassApplied then return end
        if matchName(d.Name) then hideTree(d) elseif inGrass(d, regions) then hideOne(d) end
    end)
    local n, hidden = 0, 0
    for _, d in ipairs(regions:GetDescendants()) do
        if not grassApplied then return end
        n += 1
        if n % 400 == 0 then task.wait() end
        if matchName(d.Name) and not inGrass(d, regions) then hideTree(d) hidden += 1 end
    end
end

local function restoreGrass()
    if grassConn then grassConn:Disconnect() grassConn = nil end
    for p in pairs(hiddenParts) do pcall(function() p.LocalTransparencyModifier = 0 end) end
    for d, tr in pairs(hiddenDecals) do pcall(function() d.Transparency = tr end) end
    hiddenParts, hiddenDecals, hiddenRoots = {}, {}, {}
    pcall(function()
        if terrainDeco ~= nil then
            if sethiddenproperty then sethiddenproperty(Workspace.Terrain, "Decoration", terrainDeco)
            else Workspace.Terrain.Decoration = terrainDeco end
        end
    end)
end

local lastCam, lastChar
local function rebuildFilter()
    local c, ch = cam(), LP.Character
    if c == lastCam and ch == lastChar then return end
    lastCam, lastChar = c, ch
    rayParams.FilterDescendantsInstances = {c, ch}
end

task.spawn(function()
    while alive do
        if State.HideGrass and not grassApplied then
            grassApplied = true
            task.spawn(function() safe("applyGrass", applyGrass) end)
        elseif (not State.HideGrass) and grassApplied then
            grassApplied = false
            safe("restoreGrass", restoreGrass)
        end
        safe("rayFilter", rebuildFilter)
        task.wait(0.5)
    end
end)


local function visible(c, part, model)
    if not State.WallCheck then return true end
    local origin = c.CFrame.Position
    local r = Workspace:Raycast(origin, part.Position - origin, rayParams)
    return (not r) or r.Instance:IsDescendantOf(model)
end

local function pickPart(c, model, names, center)
    local why = "none"
    local found = false
    local function try(p, label)
        local v, on = c:WorldToViewportPoint(p.Position)
        if not on then why = "off"
        elseif (p.Position - c.CFrame.Position).Magnitude > State.ESPRange then why = "range"
        else
            local d = (Vector2.new(v.X, v.Y) - center).Magnitude
            if d > State.AimFOV and not flierSet[model] then why = "fov"
            elseif not visible(c, p, model) then why = "blocked"
            else return p.Position, d, label end
        end
        return nil
    end
    for _, n in ipairs(names) do
        local p = model:IsA("BasePart") and model or model:FindFirstChild(n)
        if p and p:IsA("BasePart") then
            found = true
            local pos, d, lb = try(p, p.Name)
            if pos then return pos, d, lb end
        end
    end
    if not found and names == BODY_PARTS then
        local r = rootOf(model)
        if r then
            local pos, d, lb = try(r, r.Name)
            if pos then return pos, d, lb end
        end
    end
    return nil, nil, why
end

local function getTarget()
    stats = {total = 0, dead = 0, nopart = 0, off = 0, range = 0, fov = 0, blocked = 0, none = 0, best = "-"}
    local c = cam()
    if not c then stats.best = "no camera" return nil end
    local center = c.ViewportSize / 2
    local hPos, hD, hName, hModel, bPos, bD, bName, bModel
    local fPos, fDist, fName
    local camPos, maxRange = c.CFrame.Position, State.ESPRange + 60
    for _, model in ipairs(allDinoModels()) do
        stats.total += 1
        local r0 = rootOf(model)
        if r0 and (r0.Position - camPos).Magnitude > maxRange then
            stats.range += 1
        elseif claimedIds[model.Name] or isDead(model) then
            stats.dead += 1
        elseif flierSet[model] then
            local fp, _, fn = pickPart(c, model, BODY_PARTS, center)
            if fp then
                local dist = (fp - c.CFrame.Position).Magnitude
                if not fDist or dist < fDist then fPos, fDist, fName = fp, dist, model.Name .. "." .. fn .. "(FLY)" end
            else
                stats[fn] = (stats[fn] or 0) + 1
            end
        else
            local pos, d, nm = pickPart(c, model, HEAD_PARTS, center)
            if pos then
                if not hD or d < hD then hPos, hD, hName, hModel = pos, d, model.Name .. "." .. nm .. "(HEAD)", model end
            elseif not hPos then
                local bp, bd, bn = pickPart(c, model, BODY_PARTS, center)
                if bp then
                    if not bD or bd < bD then bPos, bD, bName, bModel = bp, bd, model.Name .. "." .. bn .. "(BODY)", model end
                else
                    stats[bn] = (stats[bn] or 0) + 1
                end
            end
        end
    end
    local pos, name = hPos or bPos or fPos, hName or bName or fName
    stats.best = name or "none"
    return pos, name
end

local aimBtn = Instance.new("TextButton")
aimBtn.Name = "AimHold"
aimBtn.Size = UDim2.fromOffset(58, 58)
aimBtn.Position = UDim2.new(1, -88, 1, -230)
aimBtn.BackgroundColor3 = BLACK
aimBtn.BackgroundTransparency = 0.35
aimBtn.AutoButtonColor = false
aimBtn.Font = Enum.Font.GothamBold
aimBtn.TextSize = 14
aimBtn.TextColor3 = GREEN
aimBtn.Text = "AIM"
aimBtn.Visible = false
corner(aimBtn, 29)
aimBtn.Parent = gui
track(aimBtn.InputBegan:Connect(function(i)
    if isPress(i) then
        aimHold = true
        aimBtn.BackgroundColor3 = GREEN
        aimBtn.TextColor3 = BLACK
        local conn
        conn = i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                aimHold = false
                aimBtn.BackgroundColor3 = BLACK
                aimBtn.TextColor3 = GREEN
                conn:Disconnect()
            end
        end)
    end
end))

local aimRot
local cachedPos, cachedName, lastScan = nil, nil, 0
local function aimStep()
    local mouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local active = State.Aimbot and (aimHold or gameAiming or mouseDown)
    if aimBtn.Visible ~= State.Aimbot then aimBtn.Visible = State.Aimbot end
    if not (active or State.SilentAim) then
        cachedPos, cachedName = nil, nil
        silentTarget, silentName = nil, nil
        aimRot = nil
        return
    end
    local now = os.clock()
    if now - lastScan >= (active and 0.06 or 0.12) then
        lastScan = now
        cachedPos, cachedName = getTarget()
    end
    local pos, name = cachedPos, cachedName
    silentTarget = State.SilentAim and pos or nil
    silentName = State.SilentAim and name or nil
    if not active then aimRot = nil return end
    local c = cam()
    if not (c and pos) then aimRot = nil return end
    local sm = math.clamp(State.AimSmooth, 0.05, 1)
    local want = CFrame.lookAt(c.CFrame.Position, pos).Rotation
    aimRot = (aimRot or c.CFrame.Rotation):Lerp(want, sm)
    c.CFrame = CFrame.new(c.CFrame.Position) * aimRot
end
pcall(function() RunService:UnbindFromRenderStep("ColdBloodAim") end)
RunService:BindToRenderStep("ColdBloodAim", Enum.RenderPriority.Last.Value, function()
    if alive then safe("aimStep", aimStep) end
end)

local function handleFire(self, ...)
    if typeof(self) ~= "Instance" then return end
    local nm = self.Name
    local n = select("#", ...)
    local args = {...}
    if nm == "PlayerState" then
        if type(args[1]) == "table" then gameAiming = args[1].aiming == true end
        return
    elseif nm == "FireWeapon" then
        local a = args[1]
        if State.SilentAim and type(a) == "table" and typeof(a.origin) == "Vector3"
            and typeof(a.direction) == "Vector3" and silentTarget then
            local d0 = a.direction.Unit
            local d1 = (silentTarget - a.origin).Unit
            local dot = math.clamp(d0.X * d1.X + d0.Y * d1.Y + d0.Z * d1.Z, -1, 1)
            local ang, maxA = math.acos(dot), math.rad(State.SilentAngle)
            local dir = d1
            if ang > maxA and ang > 1e-4 then
                local t = maxA / ang
                dir = (d0 * (1 - t) + d1 * t).Unit
            end
            local na = table.clone(a)
            na.direction = dir
            args[1] = na
            return n, args
        end
    end
    return nil
end

local hooked = false
if hookmetamethod and getnamecallmethod then
    local old
    local wrap = newcclosure or function(f) return f end
    local ok, err = pcall(function()
        old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
            local method = getnamecallmethod()
            if alive and method == "FireServer" then
                local ok2, n, args = pcall(handleFire, self, ...)
                if setnamecallmethod then setnamecallmethod(method) end
                if ok2 and args then return old(self, table.unpack(args, 1, n)) end
            end
            if setnamecallmethod then setnamecallmethod(method) end
            return old(self, ...)
        end))
    end)
    hooked = ok
end
if not hooked then
    UI.DinoInfo:Set({Title = "Cold Blood", Content = "Hook unavailable: Silent Aim part of Auto Aim is disabled."})
end

UI.onClose = function()
    grassApplied = false
    pcall(restoreGrass)
    pcall(function() RunService:UnbindFromRenderStep("ColdBloodAim") end)
    for key in pairs(entries) do removeEntry(key) end
    pcall(function() espFolder:Destroy() end)
end

local collapsed = false
btnMin.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    body.Visible = not collapsed
    barFill.Visible = not collapsed
    main.Size = collapsed and UDim2.fromOffset(WIN_W, BAR_H) or UDim2.fromOffset(WIN_W, WIN_H)
end)

track(UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.LeftAlt then main.Visible = not main.Visible end
end))

do
    local dragStart, startPos
    bar.InputBegan:Connect(function(i)
        if isPress(i) then dragStart, startPos = i.Position, main.Position end
    end)
    track(UserInputService.InputChanged:Connect(function(i)
        if dragStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if isPress(i) then dragStart = nil end
    end))
end

function UI.destroy() pcall(function() gui:Destroy() end) end

btnClose.MouseButton1Click:Connect(function()
    alive = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    if UI.onClose then pcall(UI.onClose) end
    UI.destroy()
end)

function UI.isAlive() return alive end

return UI
