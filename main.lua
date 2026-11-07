-- AUTO VOLLEYBALL V5
-- Block + Spike + JumpSet + GroundSet
-- Priority: GroundSet on ground
-- Air priority: Spike > JumpSet > Block
-- GUI 4 columns + Live Status

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local Config = {
    blockEnabled = true,
    spikeEnabled = true,
    jumpEnabled = true,
    setEnabled = true,

    blockKey = "B",
    spikeKey = "N",
    jumpKey = "J",
    setKey = "M",
    guiKey = "RightShift",

    blockRange = 7,
    spikeRange = 7,
    jumpRange = 7,
    setRange = 7,

    blockLead = 0.15,
    spikeLead = 0.15,
    jumpLead = 0.15,
    setLead = 0.15,

    maxLeadDist = 30,
    cooldown = 0.5,
    hold = 0.25,
}

local FILE = "AutoVolleyball_V5.json"

local function saveConfig()
    if type(writefile) ~= "function" then return end
    local ok, data = pcall(function()
        return HttpService:JSONEncode(Config)
    end)
    if ok then pcall(writefile, FILE, data) end
end

local function loadConfig()
    if type(readfile) ~= "function"
        or type(isfile) ~= "function" then return end

    local ok, data = pcall(function()
        if isfile(FILE) then
            return HttpService:JSONDecode(readfile(FILE))
        end
    end)

    if not ok or type(data) ~= "table" then return end

    for k, v in pairs(Config) do
        if data[k] ~= nil and type(data[k]) == type(v) then
            Config[k] = data[k]
        end
    end
end

loadConfig()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoVolleyballV5"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999

local placed = false
if type(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and typeof(h) == "Instance" then
        gui.Parent = h
        placed = true
    end
end

if not placed then
    placed = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
end

if not placed then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(570, 350)
panel.Position = UDim2.new(0, 155, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(20,20,27)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(80,160,255)
stroke.Thickness = 2

-- ACTIONS
local actions = {
    {id="block", title="BLOCK", x=12,
        enabled="blockEnabled", key="blockKey",
        range="blockRange", lead="blockLead"},

    {id="spike", title="SPIKE", x=150,
        enabled="spikeEnabled", key="spikeKey",
        range="spikeRange", lead="spikeLead"},

    {id="jump", title="JUMP SET", x=288,
        enabled="jumpEnabled", key="jumpKey",
        range="jumpRange", lead="jumpLead"},

    {id="set", title="GROUND SET", x=426,
        enabled="setEnabled", key="setKey",
        range="setRange", lead="setLead"},
}

-- LIVE STATUS
local statusStrip = Instance.new("Frame")
statusStrip.Name = "LiveStatus"
statusStrip.Size = UDim2.fromOffset(120,180)
statusStrip.Position = UDim2.new(0,15,0.2,0)
statusStrip.BackgroundColor3 = Color3.fromRGB(20,20,27)
statusStrip.BorderSizePixel = 0
statusStrip.Parent = gui

Instance.new("UICorner",statusStrip).CornerRadius = UDim.new(0,10)

local stripStroke = Instance.new("UIStroke",statusStrip)
stripStroke.Color = Color3.fromRGB(80,160,255)
stripStroke.Thickness = 2

local function statusText(txt,x,y,w,h,size)
    local obj = Instance.new("TextLabel")
    obj.BackgroundTransparency = 1
    obj.Position = UDim2.fromOffset(x,y)
    obj.Size = UDim2.fromOffset(w,h)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = size
    obj.TextColor3 = Color3.fromRGB(240,240,245)
    obj.Text = txt
    obj.Parent = statusStrip
    return obj
end

statusText("LIVE STATUS",5,8,110,22,13)

local indicators = {}

for i,a in ipairs(actions) do
    statusText(a.title,7,35+(i-1)*35,70,25,10)

    local indicator = Instance.new("TextLabel")
    indicator.Size = UDim2.fromOffset(42,23)
    indicator.Position = UDim2.fromOffset(74,35+(i-1)*35)
    indicator.BackgroundColor3 = Color3.fromRGB(205,45,55)
    indicator.TextColor3 = Color3.new(1,1,1)
    indicator.Font = Enum.Font.GothamBold
    indicator.TextSize = 10
    indicator.Text = "OFF"
    indicator.Parent = statusStrip

    Instance.new("UICorner",indicator).CornerRadius = UDim.new(0,5)
    indicators[a.id] = indicator
end

local function updateStatus()
    for _,a in ipairs(actions) do
        local enabled = Config[a.enabled]
        indicators[a.id].Text = enabled and "ON" or "OFF"
        indicators[a.id].BackgroundColor3 = enabled
            and Color3.fromRGB(35,190,85)
            or Color3.fromRGB(205,45,55)
    end
end

panel:GetPropertyChangedSignal("Position"):Connect(function()
    statusStrip.Position = UDim2.new(
        panel.Position.X.Scale,
        panel.Position.X.Offset-135,
        panel.Position.Y.Scale,
        panel.Position.Y.Offset
    )
end)

-- GUI HELPERS
local function label(txt,x,y,w,size,color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.fromOffset(x,y)
    l.Size = UDim2.fromOffset(w,size+5)
    l.Font = Enum.Font.GothamBold
    l.TextSize = size
    l.TextColor3 = color or Color3.fromRGB(240,240,245)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = txt
    l.Parent = panel
    return l
end

local function button(txt,x,y,w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(w,27)
    b.Position = UDim2.fromOffset(x,y)
    b.BackgroundColor3 = Color3.fromRGB(45,45,57)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Text = txt
    b.Parent = panel
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
    return b
end

label("AUTO VOLLEYBALL V5",12,8,400,16,
    Color3.fromRGB(120,190,255))

label("RANGE",12,125,80,10,Color3.fromRGB(140,170,210))
label("LEAD TIME",12,163,100,10,Color3.fromRGB(140,170,210))

local controls = {}

for _,a in ipairs(actions) do
    label(a.title,a.x,38,130,12,
        Color3.fromRGB(180,200,230))

    controls[a.id] = {
        toggle=button("",a.x,60,125),
        key=button("",a.x,94,125),
        rangeMinus=button("-",a.x,145,27),
        rangeText=label("",a.x+31,151,65,10),
        rangePlus=button("+",a.x+98,145,27),
        leadMinus=button("-",a.x,181,27),
        leadText=label("",a.x+31,187,65,10),
        leadPlus=button("+",a.x+98,181,27),
    }
end

local hideBtn = button("HIDE GUI",12,230,125)
local saveBtn = button("SAVE CONFIG",150,230,125)
local loadBtn = button("LOAD CONFIG",288,230,125)

local live = label("Waiting...",12,270,540,12,
    Color3.fromRGB(150,230,170))
live.Font = Enum.Font.Code

local status = label("Ready",12,300,540,11,
    Color3.fromRGB(190,190,205))
status.Size = UDim2.fromOffset(540,35)
status.Font = Enum.Font.Code
status.TextWrapped = true

local function log(msg)
    status.Text = tostring(msg)
end

local function updateGUI()
    for _,a in ipairs(actions) do
        local c = controls[a.id]
        c.toggle.Text = Config[a.enabled] and "ON" or "OFF"
        c.key.Text = "KEY: "..Config[a.key]
        c.rangeText.Text = tostring(Config[a.range]).." stud"
        c.leadText.Text = math.floor(Config[a.lead]*1000+0.5).."ms"
    end
    updateStatus()
end

updateGUI()

-- KEYBINDS
local listening = nil

for _,a in ipairs(actions) do
    controls[a.id].key.MouseButton1Click:Connect(function()
        listening = a.key
        controls[a.id].key.Text = "PRESS KEY..."
    end)

    controls[a.id].toggle.MouseButton1Click:Connect(function()
        Config[a.enabled] = not Config[a.enabled]
        updateGUI()
        saveConfig()
    end)
end

UserInputService.InputBegan:Connect(function(input,processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local key = input.KeyCode.Name

    if listening then
        if key == Config.guiKey then
            listening = nil
            updateGUI()
            log("Key reserved for GUI")
            return
        end

        for _,a in ipairs(actions) do
            if a.key ~= listening and Config[a.key] == key then
                listening = nil
                updateGUI()
                log("Key already used!")
                return
            end
        end

        Config[listening] = key
        listening = nil
        updateGUI()
        saveConfig()
        log("Keybind saved: "..key)
        return
    end

    if processed then return end

    if key == Config.guiKey then
        panel.Visible = not panel.Visible
        return
    end

    for _,a in ipairs(actions) do
        if key == Config[a.key] then
            Config[a.enabled] = not Config[a.enabled]
            updateGUI()
            saveConfig()
            log(a.title..(Config[a.enabled] and " ON" or " OFF"))
            return
        end
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

saveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    log("Config saved")
end)

loadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    updateGUI()
    log("Config loaded")
end)

local function change(key,amount,min,max)
    Config[key] = math.clamp(Config[key]+amount,min,max)
    updateGUI()
    saveConfig()
end

for _,a in ipairs(actions) do
    local c = controls[a.id]

    c.rangeMinus.MouseButton1Click:Connect(function()
        change(a.range,-1,2,30)
    end)
    c.rangePlus.MouseButton1Click:Connect(function()
        change(a.range,1,2,30)
    end)
    c.leadMinus.MouseButton1Click:Connect(function()
        change(a.lead,-0.025,0,0.6)
    end)
    c.leadPlus.MouseButton1Click:Connect(function()
        change(a.lead,0.025,0,0.6)
    end)
end

-- GAME CONTROLLER
local controller

do
    local prev
    if setthreadidentity then
        if getthreadidentity then prev=getthreadidentity() end
        pcall(setthreadidentity,2)
    end

    local ok,c = pcall(function()
        return require(ReplicatedStorage.Packages.Knit)
            .GetController("GameController")
    end)

    if setthreadidentity and prev then
        pcall(setthreadidentity,prev)
    end

    if ok and type(c)=="table"
        and type(c.DoMove)=="function" then
        controller=c
        log("GameController loaded")
    else
        log("GameController error: "..tostring(c))
    end
end

local function sendInput(action,state)
    if not controller then return false end
    local ok,err = pcall(function()
        controller:DoMove({
            ActionName=action,
            InputState=state
        })
    end)
    if not ok then log("DoMove error: "..tostring(err)) end
    return ok
end

-- BALL DETECTION
local netCache
local netCacheT = 0

local function getNet()
    if netCache and netCache.Parent then return netCache end
    if os.clock()-netCacheT<2 then return nil end
    netCacheT=os.clock()
    netCache=Workspace:FindFirstChild("Volleyball Net",true)
    return netCache
end

local function getNetPlane()
    local net=getNet()
    if not net then return nil end
    local ok,cf,size=pcall(function()
        return net:GetBoundingBox()
    end)
    if not ok then return nil end

    local normal=(size.X<size.Z) and cf.RightVector or cf.LookVector
    normal=Vector3.new(normal.X,0,normal.Z)
    if normal.Magnitude<0.01 then return nil end
    return cf.Position,normal.Unit
end

local tracks=setmetatable({},{__mode="k"})

local function ballPart(model)
    for _,part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name~="Ball.001" then
            return part
        end
    end
end

local function getHRP()
    local char=LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function scanBalls(hrp,dt)
    local netPos,normal=getNetPlane()
    local mySide
    if netPos then
        mySide=(hrp.Position-netPos):Dot(normal)>=0
    end

    local bestD=math.huge
    local bestV=0
    local bestT=math.huge
    local bestName
    local total=0

    for _,model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local part=ballPart(model)
            if part then
                total+=1
                local tr=tracks[part]

                if not tr then
                    tr={pos=part.Position,vel=Vector3.zero}
                    tracks[part]=tr
                elseif dt>0 then
                    local raw=(part.Position-tr.pos)/dt
                    tr.vel=tr.vel:Lerp(raw,0.6)
                    tr.pos=part.Position
                end

                local sameSide=true
                if netPos then
                    sameSide=((part.Position-netPos):Dot(normal)>=0)==mySide
                end

                if sameSide then
                    local to=hrp.Position-part.Position
                    local d=to.Magnitude
                    local closing=d>0.01 and tr.vel:Dot(to.Unit) or 0
                    local ttc=closing>1 and d/closing or math.huge

                    if d<bestD then
                        bestD=d
                        bestV=closing
                        bestT=ttc
                        bestName=model.Name
                    end
                end
            end
        end
    end

    return bestD,bestV,bestT,bestName,total
end

-- ACTION SYSTEM
local lastAction=0
local lastUi=0

local function canTrigger(range,lead,d,ttc)
    local byRange=d<=range
    local byLead=lead>0 and d<=Config.maxLeadDist and ttc<=lead
    return byRange or byLead
end

local function executeAction(action,name,d,ttc)
    if os.clock()-lastAction<Config.cooldown then return end
    lastAction=os.clock()

    local began=sendInput(action,Enum.UserInputState.Begin)

    log(string.format("%s | %s | d=%.1f | t=%.2f",
        string.upper(action),tostring(name),d,
        ttc==math.huge and 9 or ttc))

    if began then
        task.delay(Config.hold,function()
            sendInput(action,Enum.UserInputState.End)
        end)
    end
end

-- GROUND SET M1
local vim
pcall(function()
    vim=game:GetService("VirtualInputManager")
end)

local function executeGroundSet(name,d,ttc)
    if os.clock()-lastAction<Config.cooldown then return end
    if not vim then
        log("VirtualInputManager unavailable")
        return
    end

    lastAction=os.clock()

    local mouse=UserInputService:GetMouseLocation()
    local ok,err=pcall(function()
        vim:SendMouseButtonEvent(mouse.X,mouse.Y,0,true,game,0)
    end)

    if not ok then
        log("M1 error: "..tostring(err))
        return
    end

    task.delay(Config.hold,function()
        pcall(function()
            vim:SendMouseButtonEvent(mouse.X,mouse.Y,0,false,game,0)
        end)
    end)

    log(string.format("GROUND SET M1 | %s | d=%.1f",
        tostring(name),d))
end

-- MAIN LOOP
RunService.Heartbeat:Connect(function(dt)
    local char=LP.Character
    local hrp=getHRP()
    local hum=char and char:FindFirstChildOfClass("Humanoid")

    if not (hrp and hum) or hum.Health<=0 then return end

    local d,v,ttc,name,total=scanBalls(hrp,dt)

    if os.clock()-lastUi>0.1 then
        lastUi=os.clock()
        if d==math.huge then
            live.Text="Balls: "..total.." | No ball on your side"
        else
            live.Text=string.format("Balls: %d | D: %.1f | V: %.0f | T: %s",
                total,d,v,ttc==math.huge and "--" or string.format("%.2fs",ttc))
        end
    end

    if d==math.huge then return end

    -- GROUND SET ONLY ON GROUND
    if hum.FloorMaterial~=Enum.Material.Air then
        if Config.setEnabled and canTrigger(Config.setRange,Config.setLead,d,ttc) then
            executeGroundSet(name,d,ttc)
        end
        return
    end

    -- AIR PRIORITY: SPIKE > JUMP SET > BLOCK
    if not controller then return end
    if os.clock()-lastAction<Config.cooldown then return end

    local spikeReady=Config.spikeEnabled
        and canTrigger(Config.spikeRange,Config.spikeLead,d,ttc)

    local jumpReady=Config.jumpEnabled
        and canTrigger(Config.jumpRange,Config.jumpLead,d,ttc)

    local blockReady=Config.blockEnabled
        and canTrigger(Config.blockRange,Config.blockLead,d,ttc)

    if spikeReady then
        executeAction("Spike",name,d,ttc)
    elseif jumpReady then
        executeAction("JumpSet",name,d,ttc)
    elseif blockReady then
        executeAction("Block",name,d,ttc)
    end
end)

log("Auto Volleyball V5 Ready")
