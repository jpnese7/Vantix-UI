--[[
    Vantix UI Library - Rayfield Architecture (V-ASEF Research Edition)
    Version: 3.0.0
    Author: jpnese7 / Elite Security Research
    Description: Completely overhauled framework with premium fluid animations,
                 modular component design, and zero-compromise aesthetics.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local Library = {
    Theme = {
        Background = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(20, 20, 24),
        Header = Color3.fromRGB(15, 15, 18),
        Element = Color3.fromRGB(26, 26, 32),
        ElementHover = Color3.fromRGB(32, 32, 38),
        Accent = Color3.fromRGB(0, 140, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextMuted = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(40, 40, 48),
        Danger = Color3.fromRGB(255, 60, 60),
        Success = Color3.fromRGB(60, 255, 100)
    }
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

-- Ripple Effect
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
        
        -- Local position calculation
        local objPos = obj.AbsolutePosition
        local localX = mousePos.X - objPos.X
        local localY = (mousePos.Y - 36) - objPos.Y -- Adjusting for CoreGui offset
        
        ripple.Position = UDim2.new(0, localX, 0, localY)
        ripple.Parent = obj
        
        local targetSize = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        local t = Tween(ripple, {Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Sine)
        
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(mainFrame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.1)
        end
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
    
    -- Main Wrapper
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = VantixGui
    Main.BackgroundColor3 = Library.Theme.Background
    Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    Main.Size = UDim2.new(0, 650, 0, 450)
    Main.ClipsDescendants = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = Main
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://601553681"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Main
    Header.BackgroundColor3 = Library.Theme.Header
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
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Divider
    local Divider = Instance.new("Frame")
    Divider.Parent = Header
    Divider.BackgroundColor3 = Library.Theme.Border
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Library.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.Size = UDim2.new(0, 180, 1, -45)
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    -- Fix Sidebar Bottom Left / Top Left
    local SidebarBlock1 = Instance.new("Frame")
    SidebarBlock1.Parent = Sidebar
    SidebarBlock1.BackgroundColor3 = Library.Theme.Sidebar
    SidebarBlock1.BorderSizePixel = 0
    SidebarBlock1.Position = UDim2.new(1, -10, 0, 0)
    SidebarBlock1.Size = UDim2.new(0, 10, 1, 0)
    
    local SidebarBlock2 = Instance.new("Frame")
    SidebarBlock2.Parent = Sidebar
    SidebarBlock2.BackgroundColor3 = Library.Theme.Sidebar
    SidebarBlock2.BorderSizePixel = 0
    SidebarBlock2.Position = UDim2.new(0, 0, 0, 0)
    SidebarBlock2.Size = UDim2.new(1, 0, 0, 10)
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Parent = Sidebar
    SidebarDivider.BackgroundColor3 = Library.Theme.Border
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    
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
    
    -- Intro Animation
    Main.Size = UDim2.new(0, 650, 0, 0)
    Main.ClipsDescendants = true
    Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.8, Enum.EasingStyle.Exponential)
    task.wait(0.8)
    Main.ClipsDescendants = false
    
    local WindowObj = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    function WindowObj:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabList
        TabBtn.BackgroundColor3 = Library.Theme.Sidebar
        TabBtn.Size = UDim2.new(0.9, 0, 0, 36)
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        
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
        TabTitle.TextColor3 = Library.Theme.TextMuted
        TabTitle.TextSize = 13
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Parent = Container
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Library.Theme.Border
        TabContent.Visible = false
        
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
                Tween(WindowObj.CurrentTab, {BackgroundColor3 = Library.Theme.Sidebar}, 0.3)
                Tween(WindowObj.CurrentTab:FindFirstChild("Title"), {TextColor3 = Library.Theme.TextMuted}, 0.3)
                WindowObj.Tabs[WindowObj.CurrentTab].Visible = false
            end
            WindowObj.CurrentTab = TabBtn
            Tween(TabBtn, {BackgroundColor3 = Library.Theme.Element}, 0.3)
            Tween(TabTitle, {TextColor3 = Library.Theme.Accent}, 0.3)
            
            TabContent.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Library.Theme.ElementHover}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabBtn then
                Tween(TabBtn, {BackgroundColor3 = Library.Theme.Sidebar}, 0.2)
            end
        end)
        
        WindowObj.Tabs[TabBtn] = TabContent
        
        -- Select first tab automatically
        if #TabList:GetChildren() == 2 then -- Layout + First Tab
            SelectTab()
        end
        
        local Elements = {}
        
        -- Section
        function Elements:CreateSection(SectionTitle)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = TabContent
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(0.95, 0, 0, 20)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = string.upper(SectionTitle)
            SectionLabel.TextColor3 = Library.Theme.Accent
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        -- Paragraph
        function Elements:CreateParagraph(TextContent)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Parent = TabContent
            ParaFrame.BackgroundColor3 = Library.Theme.Element
            ParaFrame.Size = UDim2.new(0.95, 0, 0, 40)
            
            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 6)
            PCorner.Parent = ParaFrame
            
            local PStroke = Instance.new("UIStroke")
            PStroke.Color = Library.Theme.Border
            PStroke.Parent = ParaFrame
            
            local PLabel = Instance.new("TextLabel")
            PLabel.Parent = ParaFrame
            PLabel.BackgroundTransparency = 1
            PLabel.Position = UDim2.new(0, 15, 0, 10)
            PLabel.Size = UDim2.new(1, -30, 1, -20)
            PLabel.Font = Enum.Font.Gotham
            PLabel.Text = TextContent
            PLabel.TextColor3 = Library.Theme.TextMuted
            PLabel.TextSize = 13
            PLabel.TextWrapped = true
            PLabel.TextXAlignment = Enum.TextXAlignment.Left
            PLabel.TextYAlignment = Enum.TextYAlignment.Top
            
            PLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                ParaFrame.Size = UDim2.new(0.95, 0, 0, PLabel.TextBounds.Y + 20)
            end)
        end
        
        -- Button
        function Elements:CreateButton(BtnText, Callback)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Parent = TabContent
            BtnFrame.BackgroundColor3 = Library.Theme.Element
            BtnFrame.Size = UDim2.new(0.95, 0, 0, 40)
            BtnFrame.ClipsDescendants = true
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = BtnFrame
            
            local BStroke = Instance.new("UIStroke")
            BStroke.Color = Library.Theme.Border
            BStroke.Parent = BtnFrame
            
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
            BtnLabel.TextColor3 = Library.Theme.Text
            BtnLabel.TextSize = 14
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local Icon = Instance.new("ImageLabel")
            Icon.Parent = BtnFrame
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(1, -30, 0.5, -8)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Image = "rbxassetid://3944680095"
            Icon.ImageRectOffset = Vector2.new(572, 804)
            Icon.ImageRectSize = Vector2.new(36, 36)
            Icon.ImageColor3 = Library.Theme.TextMuted
            
            Btn.MouseEnter:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Library.Theme.ElementHover}, 0.2)
            end)
            
            Btn.MouseLeave:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Element}, 0.2)
            end)
            
            Btn.MouseButton1Down:Connect(function()
                Tween(BtnFrame, {Size = UDim2.new(0.92, 0, 0, 36)}, 0.1)
                Ripple(BtnFrame)
            end)
            
            Btn.MouseButton1Up:Connect(function()
                Tween(BtnFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.1)
                Callback()
            end)
        end
        
        -- Toggle
        function Elements:CreateToggle(TogText, Default, Callback)
            local TogFrame = Instance.new("Frame")
            TogFrame.Parent = TabContent
            TogFrame.BackgroundColor3 = Library.Theme.Element
            TogFrame.Size = UDim2.new(0.95, 0, 0, 40)
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 6)
            TCorner.Parent = TogFrame
            
            local TStroke = Instance.new("UIStroke")
            TStroke.Color = Library.Theme.Border
            TStroke.Parent = TogFrame
            
            local TogLabel = Instance.new("TextLabel")
            TogLabel.Parent = TogFrame
            TogLabel.BackgroundTransparency = 1
            TogLabel.Position = UDim2.new(0, 15, 0, 0)
            TogLabel.Size = UDim2.new(1, -60, 1, 0)
            TogLabel.Font = Enum.Font.GothamMedium
            TogLabel.Text = TogText
            TogLabel.TextColor3 = Library.Theme.Text
            TogLabel.TextSize = 14
            TogLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local TogSwitch = Instance.new("Frame")
            TogSwitch.Parent = TogFrame
            TogSwitch.AnchorPoint = Vector2.new(1, 0.5)
            TogSwitch.Position = UDim2.new(1, -15, 0.5, 0)
            TogSwitch.Size = UDim2.new(0, 40, 0, 20)
            TogSwitch.BackgroundColor3 = Default and Library.Theme.Accent or Library.Theme.Border
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = TogSwitch
            
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
                    Tween(TogSwitch, {BackgroundColor3 = Library.Theme.Accent}, 0.25)
                    Tween(TogKnob, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                else
                    Tween(TogSwitch, {BackgroundColor3 = Library.Theme.Border}, 0.25)
                    Tween(TogKnob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                end
                Callback(State)
            end)
        end
        
        -- Slider
        function Elements:CreateSlider(SlText, Min, Max, Default, Callback)
            local SlFrame = Instance.new("Frame")
            SlFrame.Parent = TabContent
            SlFrame.BackgroundColor3 = Library.Theme.Element
            SlFrame.Size = UDim2.new(0.95, 0, 0, 55)
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SlFrame
            
            local SStroke = Instance.new("UIStroke")
            SStroke.Color = Library.Theme.Border
            SStroke.Parent = SlFrame
            
            local SlLabel = Instance.new("TextLabel")
            SlLabel.Parent = SlFrame
            SlLabel.BackgroundTransparency = 1
            SlLabel.Position = UDim2.new(0, 15, 0, 5)
            SlLabel.Size = UDim2.new(1, -30, 0, 20)
            SlLabel.Font = Enum.Font.GothamMedium
            SlLabel.Text = SlText
            SlLabel.TextColor3 = Library.Theme.Text
            SlLabel.TextSize = 14
            SlLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SlValue = Instance.new("TextLabel")
            SlValue.Parent = SlFrame
            SlValue.BackgroundTransparency = 1
            SlValue.Position = UDim2.new(1, -65, 0, 5)
            SlValue.Size = UDim2.new(0, 50, 0, 20)
            SlValue.Font = Enum.Font.GothamBold
            SlValue.Text = tostring(Default)
            SlValue.TextColor3 = Library.Theme.Accent
            SlValue.TextSize = 14
            SlValue.TextXAlignment = Enum.TextXAlignment.Right
            
            local Track = Instance.new("Frame")
            Track.Parent = SlFrame
            Track.BackgroundColor3 = Library.Theme.Border
            Track.Position = UDim2.new(0, 15, 1, -20)
            Track.Size = UDim2.new(1, -30, 0, 6)
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(1, 0)
            TCorner.Parent = Track
            
            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.BackgroundColor3 = Library.Theme.Accent
            Fill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
            
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
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
        end
        
        -- Dropdown
        function Elements:CreateDropdown(DropText, Options, Default, Callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Parent = TabContent
            DropFrame.BackgroundColor3 = Library.Theme.Element
            DropFrame.Size = UDim2.new(0.95, 0, 0, 40)
            DropFrame.ClipsDescendants = true
            
            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 6)
            DCorner.Parent = DropFrame
            
            local DStroke = Instance.new("UIStroke")
            DStroke.Color = Library.Theme.Border
            DStroke.Parent = DropFrame
            
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
            DropLabel.TextColor3 = Library.Theme.Text
            DropLabel.TextSize = 14
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Parent = TopBar
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Position = UDim2.new(0.5, -40, 0, 0)
            SelectedLabel.Size = UDim2.new(0.5, 0, 1, 0)
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.Text = Default or "Select..."
            SelectedLabel.TextColor3 = Library.Theme.TextMuted
            SelectedLabel.TextSize = 13
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local Icon = Instance.new("ImageLabel")
            Icon.Parent = TopBar
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(1, -30, 0.5, -8)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Image = "rbxassetid://3926305904"
            Icon.ImageRectOffset = Vector2.new(44, 404)
            Icon.ImageRectSize = Vector2.new(36, 36)
            Icon.ImageColor3 = Library.Theme.TextMuted
            
            local DropList = Instance.new("ScrollingFrame")
            DropList.Parent = DropFrame
            DropList.BackgroundTransparency = 1
            DropList.Position = UDim2.new(0, 0, 0, 40)
            DropList.Size = UDim2.new(1, 0, 1, -40)
            DropList.ScrollBarThickness = 2
            DropList.ScrollBarImageColor3 = Library.Theme.Accent
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = DropList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            
            TopBar.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local targetSize = 40 + math.clamp(#Options * 30, 0, 120)
                    Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, targetSize)}, 0.3)
                    Tween(Icon, {Rotation = 180}, 0.3)
                else
                    Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.3)
                    Tween(Icon, {Rotation = 0}, 0.3)
                end
            end)
            
            local function BuildOptions()
                for _, child in pairs(DropList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for i, opt in ipairs(Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = DropList
                    OptBtn.BackgroundColor3 = Library.Theme.Element
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextColor3 = Library.Theme.TextMuted
                    OptBtn.TextSize = 13
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, {BackgroundTransparency = 0.5, TextColor3 = Library.Theme.Text}, 0.2)
                    end)
                    
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Library.Theme.TextMuted}, 0.2)
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        isOpen = false
                        Tween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 40)}, 0.3)
                        Tween(Icon, {Rotation = 0}, 0.3)
                        Callback(opt)
                    end)
                end
                DropList.CanvasSize = UDim2.new(0, 0, 0, #Options * 30)
            end
            
            BuildOptions()
        end
        
        -- Input
        function Elements:CreateInput(InpText, Placeholder, Callback)
            local InpFrame = Instance.new("Frame")
            InpFrame.Parent = TabContent
            InpFrame.BackgroundColor3 = Library.Theme.Element
            InpFrame.Size = UDim2.new(0.95, 0, 0, 40)
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0, 6)
            ICorner.Parent = InpFrame
            
            local IStroke = Instance.new("UIStroke")
            IStroke.Color = Library.Theme.Border
            IStroke.Parent = InpFrame
            
            local InpLabel = Instance.new("TextLabel")
            InpLabel.Parent = InpFrame
            InpLabel.BackgroundTransparency = 1
            InpLabel.Position = UDim2.new(0, 15, 0, 0)
            InpLabel.Size = UDim2.new(0.5, 0, 1, 0)
            InpLabel.Font = Enum.Font.GothamMedium
            InpLabel.Text = InpText
            InpLabel.TextColor3 = Library.Theme.Text
            InpLabel.TextSize = 14
            InpLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local TextBox = Instance.new("TextBox")
            TextBox.Parent = InpFrame
            TextBox.BackgroundColor3 = Library.Theme.Background
            TextBox.AnchorPoint = Vector2.new(1, 0.5)
            TextBox.Position = UDim2.new(1, -10, 0.5, 0)
            TextBox.Size = UDim2.new(0.4, 0, 0, 26)
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = Placeholder
            TextBox.Text = ""
            TextBox.TextColor3 = Library.Theme.Text
            TextBox.TextSize = 13
            
            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 4)
            TBCorner.Parent = TextBox
            
            local TBStroke = Instance.new("UIStroke")
            TBStroke.Color = Library.Theme.Border
            TBStroke.Parent = TextBox
            
            TextBox.Focused:Connect(function()
                Tween(TBStroke, {Color = Library.Theme.Accent}, 0.3)
            end)
            
            TextBox.FocusLost:Connect(function(enter)
                Tween(TBStroke, {Color = Library.Theme.Border}, 0.3)
                if enter then
                    Callback(TextBox.Text)
                end
            end)
        end
        
        return Elements
    end
    
    return WindowObj
end

return Library
