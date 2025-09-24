--========================================================
-- UFO HUB X — FULL (now with Home button + AFK switch)
--========================================================

-------------------- Services --------------------
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CG      = game:GetService("CoreGui")
local Camera  = workspace.CurrentCamera
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-------------------- CONFIG --------------------
local LOGO_ID      = 112676905543996  -- โลโก้
local X_OFFSET     = 18               -- ขยับ UI ใหญ่ไปขวา (+ขวา, -ซ้าย)
local Y_OFFSET     = -40              -- ขยับ UI ใหญ่ขึ้น/ลง (ลบ=ขึ้น, บวก=ลง)
local TOGGLE_GAP   = 60               -- ระยะห่าง ปุ่ม ↔ ขอบซ้าย UI ใหญ่
local TOGGLE_DY    = -70              -- ยกปุ่มขึ้นจากกึ่งกลางแนวตั้ง (ลบ=สูงขึ้น)
local CENTER_TWEEN = true
local CENTER_TIME  = 0.25
local TOGGLE_DOCKED = true            -- เริ่มแบบเกาะซ้าย

-- AFK
local INTERVAL_SEC = 5*60             -- กี่วินาทีต่อหนึ่งครั้งคลิก (5 นาที)

-------------------- Helpers --------------------
local function safeParent(gui)
    local ok=false
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then gui.Parent = CG end
end
local function make(class, props, children)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = o end
    return o
end
local function tweenPos(obj, pos)
    TS:Create(obj, TweenInfo.new(CENTER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = pos}):Play()
end

-------------------- Theme --------------------
local ACCENT = Color3.fromRGB(0,255,140)
local BG     = Color3.fromRGB(12,12,12)
local FG     = Color3.fromRGB(230,230,230)
local SUB    = Color3.fromRGB(22,22,22)
local D_GREY = Color3.fromRGB(16,16,16)
local OFFCOL = Color3.fromRGB(210,60,60)

-------------------- ScreenGuis --------------------
local mainGui   = make("ScreenGui", {Name="UFOHubX_Main", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
local toggleGui = make("ScreenGui", {Name="UFOHubX_Toggle", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
safeParent(mainGui); safeParent(toggleGui)

-------------------- MAIN WINDOW --------------------
local main = make("Frame", {
    Name="Main", Parent=mainGui, Size=UDim2.new(0,620,0,380),
    BackgroundColor3=BG, BorderSizePixel=0, Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,16)}),
    make("UIStroke",{Thickness=2, Color=ACCENT, Transparency=0.08}),
    make("UIGradient",{Rotation=90, Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)),
        ColorSequenceKeypoint.new(1, BG)
    }})
})

-- Top bar ------------------------------------------------
local top = make("Frame", {Parent=main, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1},{})

make("ImageLabel", {
    Parent=top, BackgroundTransparency=1, Image="rbxassetid://"..LOGO_ID,
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,16,0,12)
}, {})

-- ชื่อ 2 สี: UFO (เขียว) + HUB X (ขาว)
local titleFrame = make("Frame", {
    Parent=top, BackgroundTransparency=1, Size=UDim2.new(1,-160,1,0),
    Position=UDim2.new(0,50,0,0)
},{})
make("UIListLayout", {Parent=titleFrame, FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center,
    Padding=UDim.new(0,8)}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="UFO", TextColor3=ACCENT}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="HUB X", TextColor3=Color3.new(1,1,1)}, {})

local underline = make("Frame", {Parent=top, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), BackgroundColor3=ACCENT},{
    make("UIGradient",{Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.7), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,0.7)
    }})
})

local function neonButton(parent, text, xOff)
    return make("TextButton", {
        Parent=parent, Text=text, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=FG,
        BackgroundColor3=SUB, Size=UDim2.new(0,36,0,36), Position=UDim2.new(1,xOff,0,7), AutoButtonColor=false
    },{make("UICorner",{CornerRadius=UDim.new(0,10)}), make("UIStroke",{Color=ACCENT, Transparency=0.75})})
end
local btnMini  = neonButton(top, "–", -88)
local btnClose = neonButton(top, "",  -46)
btnClose.BackgroundColor3 = Color3.fromRGB(210,35,50)
local function mkX(rot)
    local b = Instance.new("Frame")
    b.Parent=btnClose; b.AnchorPoint=Vector2.new(0.5,0.5)
    b.Position=UDim2.new(0.5,0,0.5,0); b.Size=UDim2.new(0,18,0,2)
    b.BackgroundColor3=Color3.new(1,1,1); b.BorderSizePixel=0; b.Rotation=rot
    Instance.new("UICorner", b).CornerRadius=UDim.new(0,1)
end
mkX(45); mkX(-45)

-- Sidebar ------------------------------------------------
local left = make("Frame", {Parent=main, Size=UDim2.new(0,170,1,-60), Position=UDim2.new(0,12,0,55),
    BackgroundColor3=Color3.fromRGB(18,18,18)},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.85})})
make("UIListLayout",{Parent=left, Padding=UDim.new(0,10)})

-- Content ------------------------------------------------
local content = make("Frame", {Parent=main, Size=UDim2.new(1,-210,1,-70), Position=UDim2.new(0,190,0,60),
    BackgroundColor3=D_GREY},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.8})})

local pgHome = make("Frame",{Parent=content, Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1, Visible=true}, {})

-------------------- Toggle Button (dock + drag) --------------------
local btnToggle = make("ImageButton", {
    Parent=toggleGui, Size=UDim2.new(0,64,0,64),
    BackgroundColor3=SUB, AutoButtonColor=false, ClipsDescendants=true,
    Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.1})
})
make("ImageLabel", {
    Parent=btnToggle, BackgroundTransparency=1,
    Size=UDim2.new(1,-6,1,-6), Position=UDim2.new(0,3,0,3),
    Image="rbxassetid://"..LOGO_ID, ScaleType=Enum.ScaleType.Stretch
},{ make("UICorner",{CornerRadius=UDim.new(0,8)}) })

-------------------- Behaviors --------------------
local hidden=false
local function setHidden(s) hidden=s; mainGui.Enabled = not hidden end
btnToggle.MouseButton1Click:Connect(function() setHidden(not hidden) end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then setHidden(not hidden) end end)

-- ย่อ/ขยาย
local collapsed=false
local originalSize = main.Size
btnMini.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        left.Visible=false; content.Visible=false; underline.Visible=false
        TS:Create(main, TweenInfo.new(.2), {Size=UDim2.new(0,620,0,56)}):Play()
        btnMini.Text="▢"
    else
        left.Visible=true; content.Visible=true; underline.Visible=true
        TS:Create(main, TweenInfo.new(.2), {Size=originalSize}):Play()
        btnMini.Text="–"
    end
end)
btnClose.MouseButton1Click:Connect(function() setHidden(true) end)

-------------------- จัดกลาง + dock ปุ่ม --------------------
local function dockToggleToMain()
    local mPos  = main.AbsolutePosition
    local mSize = main.AbsoluteSize
    local tX = math.floor(mPos.X - btnToggle.AbsoluteSize.X - TOGGLE_GAP)
    local tY = math.floor(mPos.Y + (mSize.Y - btnToggle.AbsoluteSize.Y)/2 + TOGGLE_DY)
    btnToggle.Position = UDim2.fromOffset(tX, tY)
end

local function centerMain(animated)
    local vp = Camera.ViewportSize
    local targetMain = UDim2.fromOffset(
        math.floor((vp.X - main.AbsoluteSize.X)/2) + X_OFFSET,
        math.floor((vp.Y - main.AbsoluteSize.Y)/2) + Y_OFFSET
    )
    if animated and CENTER_TWEEN then tweenPos(main, targetMain) else main.Position = targetMain end
    if TOGGLE_DOCKED then dockToggleToMain() end
end

centerMain(false)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() centerMain(false) end)
main.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 and TOGGLE_DOCKED then
        dockToggleToMain()
    end
end)
btnToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TOGGLE_DOCKED = false -- ลากเอง → ปลด dock
    end
end)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F9 then
        TOGGLE_DOCKED = true; centerMain(true)
    elseif i.KeyCode==Enum.KeyCode.F8 then
        TOGGLE_DOCKED = not TOGGLE_DOCKED
        if TOGGLE_DOCKED then dockToggleToMain() end
    end
end)
----------------------------------------------------------------
-- 🔩 REQUIRE: โค้ดนี้สมมติว่าคุณมีตัวแปร/ฟังก์ชันต่อไปนี้จาก UI หลัก:
-- mainGui, content, left, TS (TweenService), ACCENT, SUB, FG
-- ถ้าไม่มี ผมใส่ fallback ไว้ให้ด้านล่างแล้ว
----------------------------------------------------------------
local TS = TS or game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RS = game:GetService("ReplicatedStorage")

local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

-- ตัวช่วยสร้างอินสแตนซ์
local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end
----------------------------------------------------------------
-- 🏠 HOME BUTTON (ยาวขึ้น + ขอบเขียวคม)
----------------------------------------------------------------
do
    -- ลบของเก่าถ้ามี
    local old = left:FindFirstChild("UFOX_HomeBtn")
    if old then old:Destroy() end

    -- ปุ่ม: ยาวแทบเต็มกรอบ (เหลือขอบซ้ายขวา 2px)
    local btnHome = make("TextButton",{
        Name="UFOX_HomeBtn", Parent=left, AutoButtonColor=false,
        Size=UDim2.new(1,-4,0,48),      -- ✅ ยาวขึ้น
        Position=UDim2.fromOffset(2,10),-- ✅ ลงล่างนิด/ชิดซ้ายนิด
        BackgroundColor3=SUB, Font=Enum.Font.GothamBold,
        TextSize=16, TextColor3=FG, Text="", ClipsDescendants=true
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{                 -- ✅ ขอบเขียวกลับมาและคมชัด
            Color=ACCENT, Thickness=2, Transparency=0,
            ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        })
    })

    -- ไอคอน + ข้อความภายในปุ่ม
    local row = make("Frame",{
        Parent=btnHome, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
    },{
        make("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            VerticalAlignment=Enum.VerticalAlignment.Center
        })
    })
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
        Font=Enum.Font.GothamBold, TextSize=16, Text="👽", TextColor3=FG})
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
        Font=Enum.Font.GothamBold, TextSize=16, Text="หน้าหลัก",
        TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG})

    -- เอฟเฟกต์ hover เล็ก ๆ
    btnHome.MouseEnter:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
    end)
    btnHome.MouseLeave:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.12), {BackgroundColor3 = SUB}):Play()
    end)

    -- คลิกเปิดหน้า Home (ถ้ามีฟังก์ชันภายนอก)
    btnHome.MouseButton1Click:Connect(function()
        if typeof(_G.UFO_OpenHomePage)=="function" then
            pcall(_G.UFO_OpenHomePage)
        else
            -- กะพริบ content แจ้งผู้ใช้
            TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(24,24,24)}):Play()
            task.delay(0.12, function()
                TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(16,16,16)}):Play()
            end)
        end
    end)
end
----------------------------------------------------------------
-- 🔁 AFK AUTO-CLICK (anti-kick) + DARK OVERLAY (Roblox Image ID)
-- - กันเตะ: VirtualUser + VirtualInputManager + Idled hook
-- - ขณะ ON: ซ่อน UI เกม + โชว์จอมืดจากรูป Roblox (ยังเห็น UFO HUB X)
-- - วางบล็อกนี้ต่อจากที่ประกาศ 'content' และ 'mainGui' แล้ว
----------------------------------------------------------------

-------------------- CONFIG --------------------
local INTERVAL_KEEPALIVE = 55      -- keepalive ทุก 55 วิ (< 60)
local INTERVAL_BIGCLICK  = 300     -- คลิกใหญ่ทุก 5 นาที
local SAFE_JUMP_EVERY    = 300     -- กด space ทุก 5 นาที
local ENABLE_SAFE_JUMP   = true

local IMAGE_ASSET_ID     = 84174878502255  -- ✅ รูปใน Roblox ที่คุณให้มา

-------------------- SERVICES --------------------
local TS  = TS or game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LP  = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local CoreGui    = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")

-- สีธีม fallback (ถ้ายังไม่ประกาศ)
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

-- ต้องมี content (พื้นที่วางปุ่มของ UI คุณ) และ mainGui (UFO HUB X)
local content = content
local mainGui = mainGui or CoreGui:FindFirstChild("UFOHubX_Main")

-------------------- Small helpers --------------------
local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end

-------------------- Row: AFK Switch --------------------
local oldRow = content and content:FindFirstChild("UFOX_RowAFK"); if oldRow then oldRow:Destroy() end
local rowAFK = make("Frame",{
    Name="UFOX_RowAFK", Parent=content, BackgroundColor3=Color3.fromRGB(18,18,18),
    Size=UDim2.new(1,-20,0,44), Position=UDim2.fromOffset(10,10)
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
})
local lbAFK = make("TextLabel",{
    Parent=rowAFK, BackgroundTransparency=1, Text="AFK (OFF)",
    Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG, TextXAlignment=Enum.TextXAlignment.Left,
    Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-150,1,0)
},{})
local swAFK = make("TextButton",{
    Parent=rowAFK, AutoButtonColor=false, Text="", AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-12,0.5,0), Size=UDim2.fromOffset(60,24), BackgroundColor3=SUB
},{
    make("UICorner",{CornerRadius=UDim.new(1,0)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
})
local knob = make("Frame",{
    Parent=swAFK, Size=UDim2.fromOffset(20,20), Position=UDim2.new(0,2,0,2),
    BackgroundColor3=Color3.fromRGB(210,60,60), BorderSizePixel=0
},{ make("UICorner",{CornerRadius=UDim.new(1,0)}) })

-------------------- DARK OVERLAY (ใต้ UFO HUB X) --------------------
-- ตัวแก้: ถ้า IMAGE_ASSET_ID เป็น Decal → ดึง Texture id มาใช้กับ ImageLabel ให้เอง
local function resolveImageAssetId(idNumber, timeout)
    timeout = timeout or 3
    -- ลอง preload โดยตรงก่อน
    local img = Instance.new("ImageLabel")
    img.Image = "rbxassetid://"..tostring(idNumber)
    local ok = pcall(function() ContentProvider:PreloadAsync({img}) end)
    if ok then return "rbxassetid://"..tostring(idNumber) end
    -- ไม่ผ่าน → ใช้ Decal เพื่อขุด TextureId
    local d = Instance.new("Decal")
    d.Texture = "rbxassetid://"..tostring(idNumber)
    local t0 = os.clock()
    while d.Texture == "" and os.clock()-t0 < timeout do task.wait(0.05) end
    local tex = d.Texture or ""
    d:Destroy()
    local realId = tex:match("(%d+)")
    if realId then
        img.Image = "rbxassetid://"..realId
        ok = pcall(function() ContentProvider:PreloadAsync({img}) end)
        if ok then return "rbxassetid://"..realId end
    end
    return nil
end

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "UFOX_DarkOverlay"
overlayGui.IgnoreGuiInset = true
overlayGui.ResetOnSpawn = false
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
overlayGui.Enabled = false
overlayGui.Parent  = CoreGui

-- วางใต้ UFO HUB X
local baseDO = (mainGui and mainGui.DisplayOrder) or 100
overlayGui.DisplayOrder = baseDO - 1

local blackout
local resolved = resolveImageAssetId(IMAGE_ASSET_ID, 3)
if resolved then
    blackout = Instance.new("ImageLabel")
    blackout.Image = resolved
    blackout.ScaleType = Enum.ScaleType.Crop
    blackout.BackgroundTransparency = 1
    blackout.ImageTransparency = 0
else
    -- fallback สีดำทึบ (กรณีโหลดรูปไม่ได้จริง ๆ)
    blackout = Instance.new("Frame")
    blackout.BackgroundColor3 = Color3.new(0,0,0)
    blackout.BackgroundTransparency = 0
end
blackout.Name = "Layer"
blackout.Size = UDim2.fromScale(1,1)
blackout.Position = UDim2.fromOffset(0,0)
blackout.ZIndex = 0
blackout.Active = true   -- บล็อกคลิก/โฟกัส UI เกม
blackout.Parent = overlayGui

-- ซ่อน CoreGui เกมตอน AFK ON
local coreBackup = {}
local function hideCoreGui()
    coreBackup = {
        Topbar    = true,
        PlayerList= StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList),
        Chat      = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat),
        Backpack  = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack),
        Emotes    = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu),
        Health    = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health),
    }
    pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,      false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,  false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu,false) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,    false) end)
end
local function showCoreGui()
    pcall(function() StarterGui:SetCore("TopbarEnabled", coreBackup.Topbar) end)
    local map = {
        [Enum.CoreGuiType.PlayerList]=coreBackup.PlayerList,
        [Enum.CoreGuiType.Chat]=coreBackup.Chat,
        [Enum.CoreGuiType.Backpack]=coreBackup.Backpack,
        [Enum.CoreGuiType.EmotesMenu]=coreBackup.Emotes,
        [Enum.CoreGuiType.Health]=coreBackup.Health,
    }
    for t,v in pairs(map) do
        if v ~= nil then pcall(function() StarterGui:SetCoreGuiEnabled(t,v) end) end
    end
    coreBackup = {}
end

-------------------- Anti-idle Engines --------------------
local AFK_ON=false
local idleConn, keepaliveThread, bigClickThread
local lastBig, lastJump = 0,0

local function camXY()
    local cam = workspace.CurrentCamera
    if not cam then return 400,300 end
    local v=cam.ViewportSize
    return math.floor(v.X/2), math.floor(v.Y/2)
end
local function tinyMouse()
    local x,y = camXY()
    pcall(function()
        VIM:SendMouseMoveEvent(x+1,y,game,0); task.wait(0.02)
        VIM:SendMouseMoveEvent(x,  y,game,0)
    end)
end
local function vuKick()
    pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end)
end
local function softSpace()
    if not ENABLE_SAFE_JUMP then return end
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.03)
        VIM:SendKeyEvent(false,Enum.KeyCode.Space, false, game)
    end)
end

local function keepAlive() tinyMouse(); vuKick() end
local function bigClick()
    local x,y = camXY()
    pcall(function()
        VIM:SendMouseButtonEvent(x,y,0,true,game,0); task.wait(0.05)
        VIM:SendMouseButtonEvent(x,y,0,false,game,0)
    end)
end

local function setAFKUI(on)
    if on then
        lbAFK.Text = "AFK (ON)"
        TS:Create(swAFK, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(28,60,40)}):Play()
        TS:Create(knob , TweenInfo.new(0.12), {Position=UDim2.new(1,-22,0,2), BackgroundColor3=ACCENT}):Play()
    else
        lbAFK.Text = "AFK (OFF)"
        TS:Create(swAFK, TweenInfo.new(0.12), {BackgroundColor3=SUB}):Play()
        TS:Create(knob , TweenInfo.new(0.12), {Position=UDim2.new(0,2,0,2),  BackgroundColor3=Color3.fromRGB(210,60,60)}):Play()
    end
end

-------------------- Start / Stop --------------------
local function startAFK()
    if AFK_ON then return end
    AFK_ON=true; setAFKUI(true)

    overlayGui.Enabled = true
    -- ให้ overlay ต่ำกว่า UFO HUB X เสมอ
    overlayGui.DisplayOrder = ((mainGui and mainGui.DisplayOrder) or 100) - 1
    hideCoreGui()

    if idleConn then idleConn:Disconnect() end
    idleConn = LP.Idled:Connect(function()
        keepAlive(); softSpace()
    end)

    keepaliveThread = task.spawn(function()
        while AFK_ON do keepAlive(); task.wait(INTERVAL_KEEPALIVE) end
    end)
    bigClickThread = task.spawn(function()
        while AFK_ON do
            local now=os.clock()
            if now-lastBig >= INTERVAL_BIGCLICK then bigClick(); lastBig=now end
            if ENABLE_SAFE_JUMP and (now-lastJump >= SAFE_JUMP_EVERY) then softSpace(); lastJump=now end
            task.wait(1)
        end
    end)
end

local function stopAFK()
    if not AFK_ON then return end
    AFK_ON=false; setAFKUI(false)
    overlayGui.Enabled = false
    showCoreGui()
    if idleConn then idleConn:Disconnect(); idleConn=nil end
end

swAFK.MouseButton1Click:Connect(function()
    if AFK_ON then stopAFK() else startAFK() end
end)

-- ให้เรียกจากสคริปต์อื่นได้
_G.UFO_AFK_IsOn  = function() return AFK_ON end
_G.UFO_AFK_Start = startAFK
_G.UFO_AFK_Stop  = stopAFK
_G.UFO_AFK_Set   = function(b) if b then startAFK() else stopAFK() end end

-- ค่าเริ่มต้น
setAFKUI(false)
----------------------------------------------------------------
-- 💰 AUTO-CLAIM (ทุก 5 วิ ยิง Claim ทุก Pet)
----------------------------------------------------------------
local function buildAutoClaimRow(y)
    local row = make("Frame",{
        Name="UFOX_RowClaim", Parent=content, BackgroundColor3=Color3.fromRGB(18,18,18),
        Size=UDim2.new(1,-20,0,44), Position=UDim2.fromOffset(10,y)
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
    })

    local lb = make("TextLabel",{
        Parent=row, BackgroundTransparency=1, Text="Auto-Claim (OFF)",
        Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG,
        TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-150,1,0)
    },{})

    local sw = make("TextButton",{
        Parent=row, AutoButtonColor=false, Text="",
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(60,24), BackgroundColor3=SUB
    },{
        make("UICorner",{CornerRadius=UDim.new(1,0)}),
        make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
    })
    local knob = make("Frame",{
        Parent=sw, Size=UDim2.fromOffset(20,20), Position=UDim2.new(0,2,0,2),
        BackgroundColor3=Color3.fromRGB(210,60,60), BorderSizePixel=0
    },{
        make("UICorner",{CornerRadius=UDim.new(1,0)})
    })

    ----------------------------------------------------------------
    -- Engine
    ----------------------------------------------------------------
    local ON=false
    local INTERVAL=5
    local loop

    local function setUI(state)
        if state then
            lb.Text="เก็บเงินอัตโนมัติ (เปิด)"
            TS:Create(sw,   TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(28,60,40)}):Play()
            TS:Create(knob, TweenInfo.new(0.12), {Position=UDim2.new(1,-22,0,2), BackgroundColor3=ACCENT}):Play()
        else
            lb.Text="เก็บเงินอัตโนมัติ (ปิด)"
            TS:Create(sw,   TweenInfo.new(0.12), {BackgroundColor3=SUB}):Play()
            TS:Create(knob, TweenInfo.new(0.12), {Position=UDim2.new(0,2,0,2), BackgroundColor3=Color3.fromRGB(210,60,60)}):Play()
        end
    end

    local function claimAllPets()
        local petsFolder = workspace:FindFirstChild("Pets")
        if not petsFolder then return end

        for _,pet in ipairs(petsFolder:GetChildren()) do
            local root = pet:FindFirstChild("RootPart")
            if root then
                local re = root:FindFirstChild("RE")
                if re and re:IsA("RemoteEvent") then
                    pcall(function()
                        re:FireServer("Claim")
                    end)
                end
            end
        end
    end

    local function startLoop()
        if loop then return end
        loop = task.spawn(function()
            while ON do
                claimAllPets()
                for _=1, INTERVAL*10 do
                    if not ON then break end
                    task.wait(0.1)
                end
            end
            loop=nil
        end)
    end

    sw.MouseButton1Click:Connect(function()
        ON = not ON
        setUI(ON)
        if ON then startLoop() end
    end)

    setUI(false)
end

-- เรียกสร้าง Auto-Claim Row ใต้ AFK
local y = rowAFK and (rowAFK.Position.Y.Offset + rowAFK.Size.Y.Offset + 8) or 10
buildAutoClaimRow(y)
----------------------------------------------------------------
-- 🥚 AUTO-HATCH (force press like a finger) + fix one-egg bug
-- ทำงาน: เปิด 2 วิ (กวาดกด Hatch ทุกฟอง) -> พัก 2 วิ -> วน
-- ใช้ fireproximityprompt ถ้ามี; fallback ยิง RF:InvokeServer("Hatch")
----------------------------------------------------------------
local TweenFast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- หา Y วางต่อท้าย
local function nextRowY(pad)
    pad = pad or 8
    local y = 10
    for _,c in ipairs(content:GetChildren()) do
        if c:IsA("Frame") and c.Visible and c.AbsoluteSize.Y > 0 then
            local yo = c.Position.Y.Offset + c.Size.Y.Offset
            if yo + pad > y then y = yo + pad end
        end
    end
    return y
end

-- ลบของเก่า (กันซ้ำ)
do local old = content:FindFirstChild("RowAutoHatch"); if old then old:Destroy() end end

-- กล่องแถว + UI
local row = Instance.new("Frame")
row.Name = "RowAutoHatch"
row.Parent = content
row.BackgroundColor3 = Color3.fromRGB(18,18,18)
row.Size = UDim2.new(1,-20,0,44)
row.Position = UDim2.fromOffset(10, nextRowY(8))
Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
local st = Instance.new("UIStroke", row); st.Color = ACCENT; st.Thickness = 2; st.Transparency = 0.05

local lb = Instance.new("TextLabel")
lb.Parent = row
lb.BackgroundTransparency = 1
lb.Font = Enum.Font.GothamBold
lb.TextSize = 15
lb.TextXAlignment = Enum.TextXAlignment.Left
lb.TextColor3 = FG
lb.Text = "Auto-Hatch (OFF)"
lb.Position = UDim2.new(0,12,0,0)
lb.Size = UDim2.new(1,-150,1,0)

local sw = Instance.new("TextButton")
sw.Parent = row
sw.AutoButtonColor = false
sw.Text = ""
sw.AnchorPoint = Vector2.new(1,0.5)
sw.Position = UDim2.new(1,-12,0.5,0)
sw.Size = UDim2.fromOffset(60,24)
sw.BackgroundColor3 = SUB
Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
local st2 = Instance.new("UIStroke", sw); st2.Color = ACCENT; st2.Thickness = 2; st2.Transparency = 0.05

local knob = Instance.new("Frame")
knob.Parent = sw
knob.Size = UDim2.fromOffset(20,20)
knob.Position = UDim2.new(0,2,0,2)
knob.BackgroundColor3 = Color3.fromRGB(210,60,60)
knob.BorderSizePixel = 0
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

----------------------------------------------------------------
-- Engine
----------------------------------------------------------------
local ON = false
local runToken = 0  -- เพิ่ม token กันลูปค้าง/ซ้อน

local hasFire = (typeof(fireproximityprompt)=="function")

-- utility: พยายาม “กด” ProximityPrompt ให้เหมือนนิ้วกด
local function pressPrompt(pp)
    if not pp or not pp:IsA("ProximityPrompt") then return false end
    -- ปรับระยะ/สายตาให้กดได้จากไกล (local เท่านั้น)
    pcall(function()
        pp.RequiresLineOfSight = false
        pp.MaxActivationDistance = math.max(pp.MaxActivationDistance or 0, 1e6)
        pp.HoldDuration = math.min(pp.HoldDuration or 0.1, 0.2)
    end)

    if hasFire then
        local ok = pcall(function() fireproximityprompt(pp, 0.2) end)
        if ok then return true end
    end

    -- fallback: ยิง RF ของ object นั้นโดยตรง (ถ้ามี)
    local tgt = pp.Parent
    local rf = tgt and tgt:FindFirstChild("RF")
    if rf and rf:IsA("RemoteFunction") then
        local ok = pcall(function() rf:InvokeServer("Hatch") end)
        if ok then return true end
    end
    return false
end

-- กวาดทุกฟองที่ “พร้อม Hatch”:
-- 1) ใช้ shared.LocalHatchProximity ก่อน (ถ้ามี)
-- 2) แล้วสแกน workspace หา ProximityPrompt ที่ Enabled และ ActionText ดูคล้าย "Hatch"
local function tryHatchAllOnce()
    local fired = 0

    -- (A) ตัวที่ UI โฟกัสอยู่
    if shared.LocalHatchProximity and shared.LocalHatchProximity:IsA("ProximityPrompt") then
        if shared.LocalHatchProximity.Enabled ~= false then
            if pressPrompt(shared.LocalHatchProximity) then
                fired += 1
                task.wait(0.05)
            end
        end
    end

    -- (B) กวาดทั้งแมพ
    for _,pp in ipairs(workspace:GetDescendants()) do
        if not ON then break end
        if pp:IsA("ProximityPrompt") and (pp.Enabled ~= false) then
            -- เลี่ยง “Skip Wait” ด้วยการกรองข้อความให้มีคำว่า Hatch (บางเกมแปลภาษา → ใส่เงื่อนไขกว้าง)
            local at = tostring(pp.ActionText or ""):lower()
            if at:find("hatch") or at:find("孵化") or at:find("ไข่") or at=="" then
                -- ถ้ามี RF อยู่ใต้วัตถุ ถือว่าใช่จุดไข่
                local isEgg = (pp.Parent and pp.Parent:FindFirstChild("RF") ~= nil)
                if isEgg then
                    if pressPrompt(pp) then
                        fired += 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end

    return fired
end

local function setUI(state)
    if state then
        lb.Text = "เปิดไข่อัตโนมัติ (เปิด)"
        TS:Create(sw, TweenFast, {BackgroundColor3 = Color3.fromRGB(28,60,40)}):Play()
        TS:Create(knob, TweenFast, {Position=UDim2.new(1,-22,0,2), BackgroundColor3=ACCENT}):Play()
    else
        lb.Text = "เปิดไข่อัตโนมัติ (ปิด)"
        TS:Create(sw, TweenFast, {BackgroundColor3 = SUB}):Play()
        TS:Create(knob, TweenFast, {Position=UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(210,60,60)}):Play()
    end
end

local function startLoop()
    if ON then return end
    ON = true
    setUI(true)
    runToken += 1
    local myToken = runToken

    task.spawn(function()
        while ON and myToken == runToken do
            -- เปิด 2 วิ: ยิงกวาดทุก 0.2 วิ
            local t0 = os.clock()
            while ON and myToken == runToken and (os.clock()-t0) < 2 do
                tryHatchAllOnce()
                task.wait(0.2)
            end
            -- พัก 2 วิ
            local t1 = os.clock()
            while ON and myToken == runToken and (os.clock()-t1) < 2 do
                task.wait(0.1)
            end
        end
    end)
end

local function stopLoop()
    if not ON then return end
    ON = false
    runToken += 1  -- ยกเลิกลูปรอบเก่าแน่นอน
    setUI(false)
end

sw.MouseButton1Click:Connect(function()
    if ON then stopLoop() else startLoop() end
end)

-- ให้สคริปต์อื่นเรียกได้
_G.UFO_HATCH_IsOn  = function() return ON end
_G.UFO_HATCH_Start = startLoop
_G.UFO_HATCH_Stop  = stopLoop
_G.UFO_HATCH_Set   = function(b) if b then startLoop() else stopLoop() end end

setUI(false)
----------------------------------------------------------------
-- 🛒 Shop Tab (Side button + content page + tab switching)
-- ต้องมีตัวแปร: left, content, TS, ACCENT, SUB, FG (มี fallback ให้)
----------------------------------------------------------------
local TS = TS or game:GetService("TweenService")
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end

-- หา/สร้างหน้า Home ถ้าไม่มี
local pgHome = content:FindFirstChild("pgHome")
if not pgHome then
    pgHome = make("Frame", {
        Name="pgHome", Parent=content, BackgroundTransparency=1,
        Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10), Visible=true
    },{})
end

-- สร้างหน้า Shop (ถ้ายังไม่มี)
local pgShop = content:FindFirstChild("pgShop")
if pgShop then pgShop:Destroy() end
pgShop = make("Frame", {
    Name="pgShop", Parent=content, BackgroundTransparency=1,
    Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10), Visible=false
},{})
-- ตัวอย่างเนื้อหาในหน้า Shop (วางอะไรก็ได้เพิ่มเติมทีหลัง)
make("TextLabel",{
    Parent=pgShop, BackgroundTransparency=1, Size=UDim2.new(1,0,0,28),
    Position=UDim2.new(0,0,0,0), Font=Enum.Font.GothamBold, TextSize=20,
    Text="🛒 Shop", TextColor3=FG, TextXAlignment=Enum.TextXAlignment.Left
},{})

-- ===== ปุ่ม Shop (แยกจาก Home) =====
-- จัด Layout ด้านซ้ายให้แน่นอนก่อน
local list = left:FindFirstChildOfClass("UIListLayout")
if not list then
    make("UIListLayout", {Parent=left, Padding=UDim.new(0,10)},{})
end

-- หา Home ปุ่มเดิม (ถ้ามี) เพื่อจัดลำดับใต้กัน
local btnHome = left:FindFirstChild("UFOX_HomeBtn")

-- ลบ Shop เก่า
local oldShop = left:FindFirstChild("UFOX_ShopBtn")
if oldShop then oldShop:Destroy() end

local btnShop = make("TextButton",{
    Name="UFOX_ShopBtn", Parent=left, AutoButtonColor=false, Text="",
    Size=UDim2.new(1,-16,0,38), BackgroundColor3=SUB, ClipsDescendants=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.15})
})

-- ลำดับ: ให้ Shop ต่ำกว่า Home
if btnHome then
    btnHome.LayoutOrder = 1
    btnShop.LayoutOrder = 2
else
    btnShop.LayoutOrder = 1
end

-- เนื้อหาภายในปุ่ม
local row = make("Frame",{
    Parent=btnShop, BackgroundTransparency=1,
    Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
},{
    make("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
        HorizontalAlignment=Enum.HorizontalAlignment.Left,
        VerticalAlignment=Enum.VerticalAlignment.Center
    })
})
make("TextLabel",{
    Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
    Font=Enum.Font.GothamBold, TextSize=16, Text="🛒", TextColor3=FG
},{})
make("TextLabel",{
    Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
    Font=Enum.Font.GothamBold, TextSize=15, Text="Shop",
    TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG
},{})

-- สไตล์ปุ่มเวลา Active/Inactive
local function setBtnActive(btn, active)
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if active then
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
        if stroke then stroke.Transparency = 0 end
    else
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = SUB}):Play()
        if stroke then stroke.Transparency = 0.15 end
    end
end

-- ฟังก์ชันสลับหน้า
local function ShowPage(name)
    local isShop = (name=="Shop")
    pgHome.Visible = not isShop
    pgShop.Visible = isShop

    if btnHome then setBtnActive(btnHome, not isShop) end
    setBtnActive(btnShop, isShop)

    -- ถ้าไม่มีหน้าอื่น ให้ใส่เอฟเฟกต์กระพริบ content ตอนเปลี่ยนหน้า
    TS:Create(content, TweenInfo.new(0.08), {BackgroundTransparency = 0.02}):Play()
    task.delay(0.1, function()
        TS:Create(content, TweenInfo.new(0.10), {BackgroundTransparency = 0}):Play()
    end)
end

-- กดปุ่ม Shop → เปิดหน้า Shop
btnShop.MouseButton1Click:Connect(function()
    ShowPage("Shop")
    if typeof(_G.UFO_OpenShopPage)=="function" then
        -- ถ้ามี logic พิเศษของเกม ให้เรียกได้ตรงนี้ด้วย
        pcall(_G.UFO_OpenShopPage)
    end
end)

-- ถ้ามีปุ่ม Home เดิมอยู่ ให้ผูกให้เปิดหน้า Home ด้วย
if btnHome and not btnHome:GetAttribute("HookedForTab") then
    btnHome:SetAttribute("HookedForTab", true)
    local oldConn
    btnHome.MouseButton1Click:Connect(function()
        -- ถ้ามีฟังก์ชันเดิม ก็เรียกด้วย
        if typeof(_G.UFO_OpenHomePage)=="function" then pcall(_G.UFO_OpenHomePage) end
        ShowPage("Home")
    end)
end

-- เริ่มต้นที่หน้า Home
ShowPage("Home")
