--[[
    Vantix UI Library
    Version: 1.0.0
    A premium, smooth, and animated Roblox UI Library inspired by Rayfield.
    Developed by Vantix AI.
]]

local Library = {
    Theme = {
        MainColor = Color3.fromRGB(20, 20, 25),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(180, 180, 180),
        CornerRadius = UDim.new(0, 10),
    },
    Elements = {},
    Signals = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Utility: Smooth Tweening
local function Tween(obj, duration, props)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Utility: Dragging
local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Name or "Vantix UI"
    local LoadingTitle = Config.LoadingTitle or "Loading Vantix..."
    local LoadingSubtitle = Config.LoadingSubtitle or "by Vantix AI"

    -- Main UI Structure
    local Vantix = Instance.new("ScreenGui")
    Vantix.Name = "Vantix_" .. math.random(1000, 9999)
    Vantix.Parent = CoreGui
    Vantix.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = Vantix
    Main.BackgroundColor3 = Library.Theme.MainColor
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.ClipsDescendants = true
    Main.Visible = false -- Will show after loading

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = Library.Theme.CornerRadius
    UICorner.Parent = Main

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(40, 40, 50)
    UIStroke.Thickness = 1
    UIStroke.Parent = Main

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Main
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Header.Size = UDim2.new(1, 0, 0, 40)
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = Library.Theme.CornerRadius
    HeaderCorner.Parent = Header
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Name = "Title"
    HeaderLabel.Parent = Header
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Position = UDim2.new(0, 15, 0, 0)
    HeaderLabel.Size = UDim2.new(1, -15, 1, 0)
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.Text = Title
    HeaderLabel.TextColor3 = Library.Theme.TextColor
    HeaderLabel.TextSize = 16
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

    MakeDraggable(Header, Main)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 160, 1, -40)

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = Library.Theme.CornerRadius
    SidebarCorner.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 170, 0, 50)
    Container.Size = UDim2.new(1, -180, 1, -60)

    -- Loading Animation
    local Loading = Instance.new("Frame")
    Loading.Name = "Loading"
    Loading.Parent = Vantix
    Loading.BackgroundColor3 = Library.Theme.MainColor
    Loading.Position = UDim2.new(0.5, -150, 0.5, -100)
    Loading.Size = UDim2.new(0, 300, 0, 200)
    
    local LCorner = Instance.new("UICorner")
    LCorner.Parent = Loading
    
    local LTitle = Instance.new("TextLabel")
    LTitle.Parent = Loading
    LTitle.Text = LoadingTitle
    LTitle.Size = UDim2.new(1, 0, 0, 50)
    LTitle.TextColor3 = Library.Theme.TextColor
    LTitle.Font = Enum.Font.GothamBold
    LTitle.TextSize = 20
    LTitle.BackgroundTransparency = 1
    
    -- Show UI logic
    task.spawn(function()
        task.wait(1)
        Tween(Loading, 0.5, {BackgroundTransparency = 1})
        Tween(LTitle, 0.5, {TextTransparency = 1})
        task.wait(0.5)
        Loading:Destroy()
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Tween(Main, 0.6, {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200)})
    end)

    local Window = {}

    function Window:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = Sidebar
        TabButton.Size = UDim2.new(1, -20, 0, 35)
        TabButton.Position = UDim2.new(0, 10, 0, 10 + (#Sidebar:GetChildren() - 2) * 40)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.Text = name
        TabButton.TextColor3 = Library.Theme.SecondaryTextColor
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        
        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(0, 6)
        TBCorner.Parent = TabButton

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Parent = Container
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 2
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local TabList = Instance.new("UIListLayout")
        TabList.Parent = TabFrame
        TabList.Padding = UDim.new(0, 8)
        TabList.SortOrder = Enum.SortOrder.LayoutOrder

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Library.Theme.SecondaryTextColor})
                end
            end
            TabFrame.Visible = true
            Tween(TabButton, 0.3, {BackgroundColor3 = Library.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
        end)

        -- Default Tab
        if #Sidebar:GetChildren() == 3 then -- First tab added
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Library.Theme.AccentColor
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Elements = {}

        function Elements:CreateButton(text, callback)
            local Button = Instance.new("Frame")
            Button.Parent = TabFrame
            Button.Size = UDim2.new(1, -10, 0, 40)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            
            local BCorner = Instance.new("UICorner")
            BCorner.Parent = Button
            
            local BText = Instance.new("TextLabel")
            BText.Parent = Button
            BText.Text = text
            BText.Size = UDim2.new(1, 0, 1, 0)
            BText.TextColor3 = Library.Theme.TextColor
            BText.Font = Enum.Font.Gotham
            BText.TextSize = 14
            BText.BackgroundTransparency = 1
            
            local Click = Instance.new("TextButton")
            Click.Parent = Button
            Click.Size = UDim2.new(1, 0, 1, 0)
            Click.BackgroundTransparency = 1
            Click.Text = ""
            
            Click.MouseButton1Click:Connect(function()
                Tween(Button, 0.1, {BackgroundColor3 = Library.Theme.AccentColor})
                task.wait(0.1)
                Tween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
                callback()
            end)
        end

        function Elements:CreateToggle(text, default, callback)
            local Toggle = Instance.new("Frame")
            Toggle.Parent = TabFrame
            Toggle.Size = UDim2.new(1, -10, 0, 40)
            Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            
            local TCorner = Instance.new("UICorner")
            TCorner.Parent = Toggle
            
            local TText = Instance.new("TextLabel")
            TText.Parent = Toggle
            TText.Text = text
            TText.Position = UDim2.new(0, 10, 0, 0)
            TText.Size = UDim2.new(1, -60, 1, 0)
            TText.TextColor3 = Library.Theme.TextColor
            TText.Font = Enum.Font.Gotham
            TText.TextSize = 14
            TText.BackgroundTransparency = 1
            TText.TextXAlignment = Enum.TextXAlignment.Left
            
            local Switch = Instance.new("Frame")
            Switch.Parent = Toggle
            Switch.Position = UDim2.new(1, -45, 0.5, -10)
            Switch.Size = UDim2.new(0, 35, 0, 20)
            Switch.BackgroundColor3 = default and Library.Theme.AccentColor or Color3.fromRGB(45, 45, 50)
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Knob = Instance.new("Frame")
            Knob.Parent = Switch
            Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(1, 0)
            KCorner.Parent = Knob
            
            local state = default
            local Click = Instance.new("TextButton")
            Click.Parent = Toggle
            Click.Size = UDim2.new(1, 0, 1, 0)
            Click.BackgroundTransparency = 1
            Click.Text = ""
            
            Click.MouseButton1Click:Connect(function()
                state = not state
                Tween(Switch, 0.3, {BackgroundColor3 = state and Library.Theme.AccentColor or Color3.fromRGB(45, 45, 50)})
                Tween(Knob, 0.3, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                callback(state)
            end)
        end

        return Elements
    end

    return Window
end

return Library
