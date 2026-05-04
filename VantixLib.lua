--[[
    Vantix UI Library - Rayfield Architecture (V-ASEF Premium Edition)
    Version: 4.0.0
    Author: jpnese7 / Elite Security Research
    Description: The absolute pinnacle of UI engineering. Features Live Theme Engine,
                 Cinematic Loading Sequences, Notification Systems, and advanced rendering.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local Library = {
    Themes = {
        ["Deep Space"] = {
            Background = Color3.fromRGB(15, 15, 18),
            Sidebar = Color3.fromRGB(20, 20, 24),
            Header = Color3.fromRGB(15, 15, 18),
            Element = Color3.fromRGB(26, 26, 32),
            ElementHover = Color3.fromRGB(32, 32, 38),
            Accent = Color3.fromRGB(0, 140, 255),
            Text = Color3.fromRGB(240, 240, 240),
            TextMuted = Color3.fromRGB(150, 150, 160),
            Border = Color3.fromRGB(40, 40, 48)
        },
        ["Emerald Stealth"] = {
            Background = Color3.fromRGB(12, 16, 12),
            Sidebar = Color3.fromRGB(16, 22, 16),
            Header = Color3.fromRGB(12, 16, 12),
            Element = Color3.fromRGB(20, 28, 20),
            ElementHover = Color3.fromRGB(28, 38, 28),
            Accent = Color3.fromRGB(0, 255, 120),
            Text = Color3.fromRGB(230, 255, 230),
            TextMuted = Color3.fromRGB(140, 180, 140),
            Border = Color3.fromRGB(35, 48, 35)
        },
        ["Crimson Threat"] = {
            Background = Color3.fromRGB(18, 12, 12),
            Sidebar = Color3.fromRGB(24, 16, 16),
            Header = Color3.fromRGB(18, 12, 12),
            Element = Color3.fromRGB(32, 20, 20),
            ElementHover = Color3.fromRGB(38, 26, 26),
            Accent = Color3.fromRGB(255, 60, 60),
            Text = Color3.fromRGB(255, 230, 230),
            TextMuted = Color3.fromRGB(180, 140, 140),
            Border = Color3.fromRGB(48, 35, 35)
        },
        ["Amethyst Void"] = {
            Background = Color3.fromRGB(16, 12, 20),
            Sidebar = Color3.fromRGB(22, 16, 28),
            Header = Color3.fromRGB(16, 12, 20),
            Element = Color3.fromRGB(30, 22, 38),
            ElementHover = Color3.fromRGB(38, 28, 48),
            Accent = Color3.fromRGB(180, 80, 255),
            Text = Color3.fromRGB(245, 235, 255),
            TextMuted = Color3.fromRGB(170, 150, 190),
            Border = Color3.fromRGB(45, 35, 55)
        }
    },
    CurrentTheme = "Deep Space",
    ThemeRegistry = {},
    NotifyContainer = nil
}

-- Tween Utility
local function Tween(obj, props, duration, style, dir)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    t:Play()
    return t
end

-- Ripple Effect (Optimized)
local function Ripple(obj)
    task.spawn(function()
        local mousePos = UserInputService:GetMouseLocation()
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.ZIndex = 10
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local objPos = obj.AbsolutePosition
        local localX = mousePos.X - objPos.X
        local localY = (mousePos.Y - 36) - objPos.Y
        
        ripple.Position = UDim2.new(0, localX, 0, localY)
        ripple.Parent = obj
        
        local targetSize = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        Tween(ripple, {Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Sine)
        
        task.wait(0.5)
        ripple:Destroy()
    end)
end

-- Dragging Utility
local function MakeDraggable(dragPart, mainFrame)
    local dragging, dragInput, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(mainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

-- Theme Engine
function Library:ApplyTheme(instance, prop, role)
    table.insert(self.ThemeRegistry, {Instance = instance, Property = prop, Role = role})
    instance[prop] = self.Themes[self.CurrentTheme][role]
end

function Library:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.CurrentTheme = themeName
    local theme = self.Themes[themeName]
    for _, item in ipairs(self.ThemeRegistry) do
        if item.Instance and item.Instance.Parent then
            Tween(item.Instance, {[item.Property] = theme[item.Role]}, 0.4)
        end
    end
end

-- Notification System
function Library:Notify(Config)
    Config = Config or {}
    local Title = Config.Title or "Notification"
    local Content = Config.Content or ""
    local Duration = Config.Duration or 3
    
    if not self.NotifyContainer then return end
    
    local NFrame = Instance.new("Frame")
    NFrame.Parent = self.NotifyContainer
    NFrame.Size = UDim2.new(1, 0, 0, 0)
    NFrame.BackgroundTransparency = 1
    NFrame.ClipsDescendants = true
    
    local Inner = Instance.new("Frame")
    Inner.Parent = NFrame
    Inner.Size = UDim2.new(1, 0, 1, -10)
    Inner.Position = UDim2.new(1, 50, 0, 5) -- Start slightly right
    Inner.BackgroundTransparency = 0
    self:ApplyTheme(Inner, "BackgroundColor3", "Element")
    
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 6)
    NCorner.Parent = Inner
    
    local NStroke = Instance.new("UIStroke")
    NStroke.Parent = Inner
    self:ApplyTheme(NStroke, "Color", "Border")
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Parent = Inner
    NTitle.BackgroundTransparency = 1
    NTitle.Position = UDim2.new(0, 15, 0, 5)
    NTitle.Size = UDim2.new(1, -30, 0, 20)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.Text = Title
    NTitle.TextSize = 13
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    self:ApplyTheme(NTitle, "TextColor3", "Accent")
    
    local NText = Instance.new("TextLabel")
    NText.Parent = Inner
    NText.BackgroundTransparency = 1
    NText.Position = UDim2.new(0, 15, 0, 25)
    NText.Size = UDim2.new(1, -30, 0, 20)
    NText.Font = Enum.Font.Gotham
    NText.Text = Content
    NText.TextSize = 12
    NText.TextWrapped = true
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.TextYAlignment = Enum.TextYAlignment.Top
    self:ApplyTheme(NText, "TextColor3", "TextMuted")
    
    -- Auto resize text height
    NText.Size = UDim2.new(1, -30, 0, NText.TextBounds.Y)
    local targetHeight = NText.TextBounds.Y + 40
    
    local Bar = Instance.new("Frame")
    Bar.Parent = Inner
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.BorderSizePixel = 0
    self:ApplyTheme(Bar, "BackgroundColor3", "Accent")
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(1, 0)
    BCorner.Parent = Bar
    
    -- Animate In
    Tween(NFrame, {Size = UDim2.new(1, 0, 0, targetHeight + 10)}, 0.4, Enum.EasingStyle.Back)
    Tween(Inner, {Position = UDim2.new(0, 0, 0, 5)}, 0.4, Enum.EasingStyle.Back)
    
    task.spawn(function()
        Tween(Bar, {Size = UDim2.new(0, 0, 0, 2)}, Duration, Enum.EasingStyle.Linear)
        task.wait(Duration)
        Tween(Inner, {Position = UDim2.new(1, 50, 0, 5), BackgroundTransparency = 1}, 0.3)
        Tween(NTitle, {TextTransparency = 1}, 0.3)
        Tween(NText, {TextTransparency = 1}, 0.3)
        Tween(NStroke, {Transparency = 1}, 0.3)
        task.wait(0.3)
        Tween(NFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        NFrame:Destroy()
    end)
end

function Library:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Name or "Vantix Framework"
    
    local VantixGui = Instance.new("ScreenGui")
    VantixGui.Name = "VantixEngine_" .. tostring(math.random(1000,9999))
    VantixGui.Parent = CoreGui
    VantixGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    VantixGui.ResetOnSpawn = false
    
    -- Notification Container
    self.NotifyContainer = Instance.new("Frame")
    self.NotifyContainer.Name = "NotifyContainer"
    self.NotifyContainer.Parent = VantixGui
    self.NotifyContainer.BackgroundTransparency = 1
    self.NotifyContainer.Position = UDim2.new(1, -320, 1, -400)
    self.NotifyContainer.Size = UDim2.new(0, 300, 0, 380)
    
    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.Parent = self.NotifyContainer
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    
    -- Main Wrapper
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = VantixGui
    Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    Main.Size = UDim2.new(0, 650, 0, 450)
    Main.ClipsDescendants = false
    Main.Visible = not Config.LoadingTitle
    self:ApplyTheme(Main, "BackgroundColor3", "Background")
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1
    MainStroke.Parent = Main
    self:ApplyTheme(MainStroke, "Color", "Border")
    
    -- Cinematic Loading Intro
    if Config.LoadingTitle then
        local Loader = Instance.new("Frame")
        Loader.Parent = VantixGui
        Loader.Position = UDim2.new(0.5, -150, 0.5, -50)
        Loader.Size = UDim2.new(0, 300, 0, 100)
        Loader.BackgroundTransparency = 1
        self:ApplyTheme(Loader, "BackgroundColor3", "Element")
        
        local LCorner = Instance.new("UICorner")
        LCorner.CornerRadius = UDim.new(0, 8)
        LCorner.Parent = Loader
        
        local LStroke = Instance.new("UIStroke")
        LStroke.Transparency = 1
        LStroke.Parent = Loader
        self:ApplyTheme(LStroke, "Color", "Border")
        
        local LTitle = Instance.new("TextLabel")
        LTitle.Parent = Loader
        LTitle.BackgroundTransparency = 1
        LTitle.Position = UDim2.new(0, 0, 0, 25)
        LTitle.Size = UDim2.new(1, 0, 0, 20)
        LTitle.Font = Enum.Font.GothamBold
        LTitle.Text = Config.LoadingTitle
        LTitle.TextSize = 16
        LTitle.TextTransparency = 1
        self:ApplyTheme(LTitle, "TextColor3", "Text")
        
        local LSub = Instance.new("TextLabel")
        LSub.Parent = Loader
        LSub.BackgroundTransparency = 1
        LSub.Position = UDim2.new(0, 0, 0, 50)
        LSub.Size = UDim2.new(1, 0, 0, 15)
        LSub.Font = Enum.Font.Gotham
        LSub.Text = Config.LoadingSubtitle or "Initializing modules..."
        LSub.TextSize = 12
        LSub.TextTransparency = 1
        self:ApplyTheme(LSub, "TextColor3", "Accent")
        
        task.spawn(function()
            -- Fade in loader
            Tween(Loader, {BackgroundTransparency = 0}, 0.5)
            Tween(LStroke, {Transparency = 0}, 0.5)
            Tween(LTitle, {TextTransparency = 0}, 0.5)
            Tween(LSub, {TextTransparency = 0}, 0.5)
            task.wait(1.5)
            
            -- Fade out loader
            Tween(Loader, {BackgroundTransparency = 1}, 0.5)
            Tween(LStroke, {Transparency = 1}, 0.5)
            Tween(LTitle, {TextTransparency = 1}, 0.5)
            Tween(LSub, {TextTransparency = 1}, 0.5)
            task.wait(0.5)
            Loader:Destroy()
            
            -- Show Main
            Main.Visible = true
            Main.Size = UDim2.new(0, 650, 0, 0)
            Main.ClipsDescendants = true
            Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.8, Enum.EasingStyle.Exponential)
            task.wait(0.8)
            Main.ClipsDescendants = false
        end)
    else
        Main.Size = UDim2.new(0, 650, 0, 0)
        Main.ClipsDescendants = true
        Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.8, Enum.EasingStyle.Exponential)
        task.wait(0.8)
        Main.ClipsDescendants = false
    end
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 60, 1, 60)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://601553681"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Main
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    
    MakeDraggable(Header, Main)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Header
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self:ApplyTheme(TitleLabel, "TextColor3", "Text")
    
    -- Divider
    local Divider = Instance.new("Frame")
    Divider.Parent = Header
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    self:ApplyTheme(Divider, "BackgroundColor3", "Border")
    
    -- Window Controls
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -35, 0, 7)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextSize = 14
    self:ApplyTheme(CloseBtn, "TextColor3", "TextMuted")
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = Header
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -65, 0, 7)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextSize = 18
    self:ApplyTheme(MinBtn, "TextColor3", "TextMuted")
    
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {TextColor3 = Library.Themes[Library.CurrentTheme].TextMuted}, 0.2) end)
    
    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {TextColor3 = Library.Themes[Library.CurrentTheme].Text}, 0.2) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {TextColor3 = Library.Themes[Library.CurrentTheme].TextMuted}, 0.2) end)
    
    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Main.ClipsDescendants = true
            Tween(Main, {Size = UDim2.new(0, 650, 0, 45)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            task.delay(0.4, function()
                if not isMinimized then Main.ClipsDescendants = false end
            end)
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Main.ClipsDescendants = true
        Tween(Main, {Size = UDim2.new(0, 650, 0, 0)}, 0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        task.wait(0.4)
        VantixGui:Destroy()
    end)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.Size = UDim2.new(0, 180, 1, -45)
    self:ApplyTheme(Sidebar, "BackgroundColor3", "Sidebar")
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    local SidebarBlock1 = Instance.new("Frame")
    SidebarBlock1.Parent = Sidebar
    SidebarBlock1.BorderSizePixel = 0
    SidebarBlock1.Position = UDim2.new(1, -10, 0, 0)
    SidebarBlock1.Size = UDim2.new(0, 10, 1, 0)
    self:ApplyTheme(SidebarBlock1, "BackgroundColor3", "Sidebar")
    
    local SidebarBlock2 = Instance.new("Frame")
    SidebarBlock2.Parent = Sidebar
    SidebarBlock2.BorderSizePixel = 0
    SidebarBlock2.Position = UDim2.new(0, 0, 0, 0)
    SidebarBlock2.Size = UDim2.new(1, 0, 0, 10)
    self:ApplyTheme(SidebarBlock2, "BackgroundColor3", "Sidebar")
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Parent = Sidebar
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    self:ApplyTheme(SidebarDivider, "BackgroundColor3", "Border")
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Parent = Sidebar
    TabList.Active = true
    TabList.BackgroundTransparency = 1
    TabList.Position = UDim2.new(0, 0, 0, 10)
    TabList.Size = UDim2.new(1, -1, 1, -20)
    TabList.ScrollBarThickness = 0
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabList
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 180, 0, 45)
    Container.Size = UDim2.new(1, -180, 1, -45)
    
    local WindowObj = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    function WindowObj:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabList
        TabBtn.Size = UDim2.new(0.9, 0, 0, 36)
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        Library:ApplyTheme(TabBtn, "BackgroundColor3", "Sidebar")
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "Title"
        TabTitle.Parent = TabBtn
        TabTitle.BackgroundTransparency = 1
        TabTitle.Position = UDim2.new(0, 15, 0, 0)
        TabTitle.Size = UDim2.new(1, -15, 1, 0)
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.Text = Name
        TabTitle.TextSize = 13
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        Library:ApplyTheme(TabTitle, "TextColor3", "TextMuted")
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Parent = Container
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.Visible = false
        Library:ApplyTheme(TabContent, "ScrollBarImageColor3", "Border")
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Parent = TabContent
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Padding = UDim.new(0, 8)
        TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local TabContentPadding = Instance.new("UIPadding")
        TabContentPadding.Parent = TabContent
        TabContentPadding.PaddingTop = UDim.new(0, 15)
        TabContentPadding.PaddingBottom = UDim.new(0, 15)
        
        TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        local function SelectTab()
            if WindowObj.CurrentTab == TabBtn then return end
            if WindowObj.CurrentTab then
                Tween(WindowObj.CurrentTab, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar}, 0.3)
                Tween(WindowObj.CurrentTab:FindFirstChild("Title"), {TextColor3 = Library.Themes[Library.CurrentTheme].TextMuted}, 0.3)
                WindowObj.Tabs[WindowObj.CurrentTab].Visible = false
            end
            WindowObj.CurrentTab = TabBtn
            Tween(TabBtn, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element}, 0.3)
            Tween(TabTitle, {TextColor3 = Library.Themes[Library.CurrentTheme].Accent}, 0.3)
            TabContent.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].ElementHover}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Sidebar}, 0.2)
            end
        end)
        
        WindowObj.Tabs[TabBtn] = TabContent
        if #TabList:GetChildren() == 2 then SelectTab() end
        
        local Elements = {}
        
        function Elements:CreateSection(SectionTitle)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = TabContent
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(0.95, 0, 0, 20)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = string.upper(SectionTitle)
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(SectionLabel, "TextColor3", "Accent")
        end
        
        function Elements:CreateParagraph(TextContent)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Parent = TabContent
            ParaFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Library:ApplyTheme(ParaFrame, "BackgroundColor3", "Element")
            
            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 6)
            PCorner.Parent = ParaFrame
            
            local PStroke = Instance.new("UIStroke")
            PStroke.Parent = ParaFrame
            Library:ApplyTheme(PStroke, "Color", "Border")
            
            local PLabel = Instance.new("TextLabel")
            PLabel.Parent = ParaFrame
            PLabel.BackgroundTransparency = 1
            PLabel.Position = UDim2.new(0, 15, 0, 10)
            PLabel.Size = UDim2.new(1, -30, 1, -20)
            PLabel.Font = Enum.Font.Gotham
            PLabel.Text = TextContent
            PLabel.TextSize = 13
            PLabel.TextWrapped = true
            PLabel.TextXAlignment = Enum.TextXAlignment.Left
            PLabel.TextYAlignment = Enum.TextYAlignment.Top
            Library:ApplyTheme(PLabel, "TextColor3", "TextMuted")
            
            PLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                ParaFrame.Size = UDim2.new(0.95, 0, 0, PLabel.TextBounds.Y + 20)
            end)
        end
        
        function Elements:CreateButton(BtnText, Callback)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Parent = TabContent
            BtnFrame.Size = UDim2.new(0.95, 0, 0, 40)
            BtnFrame.ClipsDescendants = true
            Library:ApplyTheme(BtnFrame, "BackgroundColor3", "Element")
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = BtnFrame
            
            local BStroke = Instance.new("UIStroke")
            BStroke.Parent = BtnFrame
            Library:ApplyTheme(BStroke, "Color", "Border")
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = BtnFrame
            Btn.BackgroundTransparency = 1
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = ""
            
            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Parent = BtnFrame
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Position = UDim2.new(0, 15, 0, 0)
            BtnLabel.Size = UDim2.new(1, -30, 1, 0)
            BtnLabel.Font = Enum.Font.GothamMedium
            BtnLabel.Text = BtnText
            BtnLabel.TextSize = 14
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(BtnLabel, "TextColor3", "Text")
            
            Btn.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].ElementHover}, 0.2) end)
            Btn.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Element}, 0.2) end)
            Btn.MouseButton1Down:Connect(function() Tween(BtnFrame, {Size = UDim2.new(0.92, 0, 0, 36)}, 0.1); Ripple(BtnFrame) end)
            Btn.MouseButton1Up:Connect(function() Tween(BtnFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.1); Callback() end)
        end
        
        function Elements:CreateToggle(TogText, Default, Callback)
            local TogFrame = Instance.new("Frame")
            TogFrame.Parent = TabContent
            TogFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Library:ApplyTheme(TogFrame, "BackgroundColor3", "Element")
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 6)
            TCorner.Parent = TogFrame
            
            local TStroke = Instance.new("UIStroke")
            TStroke.Parent = TogFrame
            Library:ApplyTheme(TStroke, "Color", "Border")
            
            local TogLabel = Instance.new("TextLabel")
            TogLabel.Parent = TogFrame
            TogLabel.BackgroundTransparency = 1
            TogLabel.Position = UDim2.new(0, 15, 0, 0)
            TogLabel.Size = UDim2.new(1, -60, 1, 0)
            TogLabel.Font = Enum.Font.GothamMedium
            TogLabel.Text = TogText
            TogLabel.TextSize = 14
            TogLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(TogLabel, "TextColor3", "Text")
            
            local TogSwitch = Instance.new("Frame")
            TogSwitch.Parent = TogFrame
            TogSwitch.AnchorPoint = Vector2.new(1, 0.5)
            TogSwitch.Position = UDim2.new(1, -15, 0.5, 0)
            TogSwitch.Size = UDim2.new(0, 40, 0, 20)
            Library:ApplyTheme(TogSwitch, "BackgroundColor3", Default and "Accent" or "Border")
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = TogSwitch
            
            local SStroke = Instance.new("UIStroke")
            SStroke.Transparency = Default and 0 or 1
            SStroke.Parent = TogSwitch
            Library:ApplyTheme(SStroke, "Color", "Accent")
            
            local TogKnob = Instance.new("Frame")
            TogKnob.Parent = TogSwitch
            TogKnob.AnchorPoint = Vector2.new(0, 0.5)
            TogKnob.Position = Default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            TogKnob.Size = UDim2.new(0, 16, 0, 16)
            TogKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(1, 0)
            KCorner.Parent = TogKnob
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = TogFrame
            Btn.BackgroundTransparency = 1
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = ""
            
            local State = Default
            Btn.MouseButton1Click:Connect(function()
                State = not State
                if State then
                    Tween(TogSwitch, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Accent}, 0.25)
                    Tween(SStroke, {Transparency = 0}, 0.25)
                    Tween(TogKnob, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                else
                    Tween(TogSwitch, {BackgroundColor3 = Library.Themes[Library.CurrentTheme].Border}, 0.25)
                    Tween(SStroke, {Transparency = 1}, 0.25)
                    Tween(TogKnob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                end
                Callback(State)
            end)
        end
        
        function Elements:CreateSlider(SlText, Min, Max, Default, Callback)
            local SlFrame = Instance.new("Frame")
            SlFrame.Parent = TabContent
            SlFrame.Size = UDim2.new(0.95, 0, 0, 55)
            Library:ApplyTheme(SlFrame, "BackgroundColor3", "Element")
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SlFrame
            
            local SStroke = Instance.new("UIStroke")
            SStroke.Parent = SlFrame
            Library:ApplyTheme(SStroke, "Color", "Border")
            
            local SlLabel = Instance.new("TextLabel")
            SlLabel.Parent = SlFrame
            SlLabel.BackgroundTransparency = 1
            SlLabel.Position = UDim2.new(0, 15, 0, 5)
            SlLabel.Size = UDim2.new(1, -30, 0, 20)
            SlLabel.Font = Enum.Font.GothamMedium
            SlLabel.Text = SlText
            SlLabel.TextSize = 14
            SlLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(SlLabel, "TextColor3", "Text")
            
            local SlValue = Instance.new("TextLabel")
            SlValue.Parent = SlFrame
            SlValue.BackgroundTransparency = 1
            SlValue.Position = UDim2.new(1, -65, 0, 5)
            SlValue.Size = UDim2.new(0, 50, 0, 20)
            SlValue.Font = Enum.Font.GothamBold
            SlValue.Text = tostring(Default)
            SlValue.TextSize = 14
            SlValue.TextXAlignment = Enum.TextXAlignment.Right
            Library:ApplyTheme(SlValue, "TextColor3", "Accent")
            
            local Track = Instance.new("Frame")
            Track.Parent = SlFrame
            Track.Position = UDim2.new(0, 15, 1, -20)
            Track.Size = UDim2.new(1, -30, 0, 6)
            Library:ApplyTheme(Track, "BackgroundColor3", "Border")
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(1, 0)
            TCorner.Parent = Track
            
            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
            Library:ApplyTheme(Fill, "BackgroundColor3", "Accent")
            
            local FCorner = Instance.new("UICorner")
            FCorner.CornerRadius = UDim.new(1, 0)
            FCorner.Parent = Fill
            
            local dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local value = math.floor(Min + (Max - Min) * pos)
                Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                SlValue.Text = tostring(value)
                Callback(value)
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true; UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
            end)
        end
        
        function Elements:CreateDropdown(DropText, Options, Default, Callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Parent = TabContent
            DropFrame.Size = UDim2.new(0.95, 0, 0, 40)
            DropFrame.ClipsDescendants = true
            Library:ApplyTheme(DropFrame, "BackgroundColor3", "Element")
            
            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 6)
            DCorner.Parent = DropFrame
            
            local DStroke = Instance.new("UIStroke")
            DStroke.Parent = DropFrame
            Library:ApplyTheme(DStroke, "Color", "Border")
            
            local TopBar = Instance.new("TextButton")
            TopBar.Parent = DropFrame
            TopBar.BackgroundTransparency = 1
            TopBar.Size = UDim2.new(1, 0, 0, 40)
            TopBar.Text = ""
            
            local DropLabel = Instance.new("TextLabel")
            DropLabel.Parent = TopBar
            DropLabel.BackgroundTransparency = 1
            DropLabel.Position = UDim2.new(0, 15, 0, 0)
            DropLabel.Size = UDim2.new(0.5, 0, 1, 0)
            DropLabel.Font = Enum.Font.GothamMedium
            DropLabel.Text = DropText
            DropLabel.TextSize = 14
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(DropLabel, "TextColor3", "Text")
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Parent = TopBar
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Position = UDim2.new(0.5, -40, 0, 0)
            SelectedLabel.Size = UDim2.new(0.5, 0, 1, 0)
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.Text = Default or "Select..."
            SelectedLabel.TextSize = 13
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            Library:ApplyTheme(SelectedLabel, "TextColor3", "TextMuted")
            
            local Icon = Instance.new("ImageLabel")
            Icon.Parent = TopBar
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(1, -30, 0.5, -8)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Image = "rbxassetid://3926305904"
            Icon.ImageRectOffset = Vector2.new(44, 404)
            Icon.ImageRectSize = Vector2.new(36, 36)
            Library:ApplyTheme(Icon, "ImageColor3", "TextMuted")
            
            local DropList = Instance.new("ScrollingFrame")
            DropList.Parent = DropFrame
            DropList.BackgroundTransparency = 1
            DropList.Position = UDim2.new(0, 0, 0, 40)
            DropList.Size = UDim2.new(1, 0, 1, -40)
            DropList.ScrollBarThickness = 2
            Library:ApplyTheme(DropList, "ScrollBarImageColor3", "Accent")
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            TopBar.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 40 + math.clamp(#Options * 30, 0, 120))}, 0.3)
                    Tween(Icon, {Rotation = 180}, 0.3)
                else
                    Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.3)
                    Tween(Icon, {Rotation = 0}, 0.3)
                end
            end)
            
            local function BuildOptions()
                for _, child in pairs(DropList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, opt in ipairs(Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = DropList
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextSize = 13
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Library:ApplyTheme(OptBtn, "TextColor3", "TextMuted")
                    Library:ApplyTheme(OptBtn, "BackgroundColor3", "ElementHover")
                    
                    OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundTransparency = 0.5, TextColor3 = Library.Themes[Library.CurrentTheme].Text}, 0.2) end)
                    OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Library.Themes[Library.CurrentTheme].TextMuted}, 0.2) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt; isOpen = false
                        Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.3); Tween(Icon, {Rotation = 0}, 0.3)
                        Callback(opt)
                    end)
                end
                DropList.CanvasSize = UDim2.new(0, 0, 0, #Options * 30)
            end
            BuildOptions()
        end
        
        function Elements:CreateInput(InpText, Placeholder, Callback)
            local InpFrame = Instance.new("Frame")
            InpFrame.Parent = TabContent
            InpFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Library:ApplyTheme(InpFrame, "BackgroundColor3", "Element")
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0, 6)
            ICorner.Parent = InpFrame
            
            local IStroke = Instance.new("UIStroke")
            IStroke.Parent = InpFrame
            Library:ApplyTheme(IStroke, "Color", "Border")
            
            local InpLabel = Instance.new("TextLabel")
            InpLabel.Parent = InpFrame
            InpLabel.BackgroundTransparency = 1
            InpLabel.Position = UDim2.new(0, 15, 0, 0)
            InpLabel.Size = UDim2.new(0.5, 0, 1, 0)
            InpLabel.Font = Enum.Font.GothamMedium
            InpLabel.Text = InpText
            InpLabel.TextSize = 14
            InpLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(InpLabel, "TextColor3", "Text")
            
            local TextBox = Instance.new("TextBox")
            TextBox.Parent = InpFrame
            TextBox.AnchorPoint = Vector2.new(1, 0.5)
            TextBox.Position = UDim2.new(1, -10, 0.5, 0)
            TextBox.Size = UDim2.new(0.4, 0, 0, 26)
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = Placeholder
            TextBox.Text = ""
            TextBox.TextSize = 13
            Library:ApplyTheme(TextBox, "BackgroundColor3", "Background")
            Library:ApplyTheme(TextBox, "TextColor3", "Text")
            
            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 4)
            TBCorner.Parent = TextBox
            
            local TBStroke = Instance.new("UIStroke")
            TBStroke.Parent = TextBox
            Library:ApplyTheme(TBStroke, "Color", "Border")
            
            TextBox.Focused:Connect(function()
                Tween(TextBox, {Size = UDim2.new(0.45, 0, 0, 26)}, 0.3)
                Tween(TBStroke, {Color = Library.Themes[Library.CurrentTheme].Accent}, 0.3)
            end)
            TextBox.FocusLost:Connect(function(enter)
                Tween(TextBox, {Size = UDim2.new(0.4, 0, 0, 26)}, 0.3)
                Tween(TBStroke, {Color = Library.Themes[Library.CurrentTheme].Border}, 0.3)
                if enter then Callback(TextBox.Text) end
            end)
        end
        
        function Elements:CreateLabel(TextContent)
            local LblFrame = Instance.new("Frame")
            LblFrame.Parent = TabContent
            LblFrame.Size = UDim2.new(0.95, 0, 0, 30)
            LblFrame.BackgroundTransparency = 1
            
            local LLabel = Instance.new("TextLabel")
            LLabel.Parent = LblFrame
            LLabel.Size = UDim2.new(1, -30, 1, 0)
            LLabel.Position = UDim2.new(0, 15, 0, 0)
            LLabel.BackgroundTransparency = 1
            LLabel.Font = Enum.Font.Gotham
            LLabel.Text = TextContent
            LLabel.TextSize = 13
            LLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(LLabel, "TextColor3", "Text")
            
            local LabelObj = {}
            function LabelObj:SetText(newText)
                LLabel.Text = newText
            end
            return LabelObj
        end
        
        function Elements:CreateKeybind(BindText, DefaultKey, Callback)
            local BindFrame = Instance.new("Frame")
            BindFrame.Parent = TabContent
            BindFrame.Size = UDim2.new(0.95, 0, 0, 40)
            Library:ApplyTheme(BindFrame, "BackgroundColor3", "Element")
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = BindFrame
            
            local BStroke = Instance.new("UIStroke")
            BStroke.Parent = BindFrame
            Library:ApplyTheme(BStroke, "Color", "Border")
            
            local BindLabel = Instance.new("TextLabel")
            BindLabel.Parent = BindFrame
            BindLabel.BackgroundTransparency = 1
            BindLabel.Position = UDim2.new(0, 15, 0, 0)
            BindLabel.Size = UDim2.new(0.5, 0, 1, 0)
            BindLabel.Font = Enum.Font.GothamMedium
            BindLabel.Text = BindText
            BindLabel.TextSize = 14
            BindLabel.TextXAlignment = Enum.TextXAlignment.Left
            Library:ApplyTheme(BindLabel, "TextColor3", "Text")
            
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = BindFrame
            KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
            KeyBtn.Position = UDim2.new(1, -10, 0.5, 0)
            KeyBtn.Size = UDim2.new(0, 100, 0, 26)
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.Text = DefaultKey.Name
            KeyBtn.TextSize = 13
            Library:ApplyTheme(KeyBtn, "BackgroundColor3", "Background")
            Library:ApplyTheme(KeyBtn, "TextColor3", "Accent")
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(0, 4)
            KCorner.Parent = KeyBtn
            
            local KStroke = Instance.new("UIStroke")
            KStroke.Parent = KeyBtn
            Library:ApplyTheme(KStroke, "Color", "Border")
            
            local currentKey = DefaultKey
            local isListening = false
            local connection
            
            KeyBtn.MouseButton1Click:Connect(function()
                if isListening then return end
                isListening = true
                KeyBtn.Text = "..."
                Tween(KStroke, {Color = Library.Themes[Library.CurrentTheme].Accent}, 0.2)
                
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeyBtn.Text = currentKey.Name
                        isListening = false
                        Tween(KStroke, {Color = Library.Themes[Library.CurrentTheme].Border}, 0.2)
                        connection:Disconnect()
                        Callback(currentKey)
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and not isListening and input.KeyCode == currentKey then
                    Callback(currentKey)
                end
            end)
        end
        return Elements
    end
    return WindowObj
end

return Library
