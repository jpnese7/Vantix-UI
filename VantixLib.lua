--[[
    Vantix UI Library - Research Edition (V-ASEF)
    Version: 1.1.0 (SECURE_BOOT)
    Author: jpnese7 (Elite Security Research)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {
        Tabs = {},
        Theme = {
                Main = Color3.fromRGB(20, 20, 25),
                Header = Color3.fromRGB(25, 25, 30),
                Sidebar = Color3.fromRGB(25, 25, 30),
                Accent = Color3.fromRGB(0, 170, 255),
                Text = Color3.fromRGB(255, 255, 255),
                TextMuted = Color3.fromRGB(180, 180, 180),
                Element = Color3.fromRGB(30, 30, 35)
    }
}

function Library:CreateWindow(Title)
        local Vantix = Instance.new("ScreenGui")
        Vantix.Name = "Vantix"
        Vantix.Parent = CoreGui
        Vantix.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local Main = Instance.new("Frame")
        Main.Name = "Main"
        Main.Parent = Vantix
        Main.BackgroundColor3 = Library.Theme.Main
        Main.BorderSizePixel = 0
        Main.Position = UDim2.new(0.5, -300, 0.5, -200)
        Main.Size = UDim2.new(0, 600, 0, 400)
        Main.ClipsDescendants = true

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Main

        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Parent = Main
        Header.BackgroundColor3 = Library.Theme.Header
        Header.BorderSizePixel = 0
        Header.Size = UDim2.new(1, 0, 0, 40)

        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Name = "Title"
        HeaderTitle.Parent = Header
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
        HeaderTitle.Size = UDim2.new(1, -15, 1, 0)
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.Text = Title or "VANTIX | SECURE_BOOT"
        HeaderTitle.TextColor3 = Library.Theme.Text
        HeaderTitle.TextSize = 14
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

        local Sidebar = Instance.new("Frame")
        Sidebar.Name = "Sidebar"
        Sidebar.Parent = Main
        Sidebar.BackgroundColor3 = Library.Theme.Sidebar
        Sidebar.BorderSizePixel = 0
        Sidebar.Position = UDim2.new(0, 0, 0, 40)
        Sidebar.Size = UDim2.new(0, 150, 1, -40)

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = Sidebar
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)

        local UIPadding = Instance.new("UIPadding")
        UIPadding.Parent = Sidebar
        UIPadding.PaddingTop = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 5)
        UIPadding.PaddingRight = UDim.new(0, 5)

        local ContentContainer = Instance.new("Frame")
        ContentContainer.Name = "ContentContainer"
        ContentContainer.Parent = Main
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.Position = UDim2.new(0, 150, 0, 40)
        ContentContainer.Size = UDim2.new(1, -150, 1, -40)

        local Window = {
                FirstTab = nil
    }

        function Window:CreateTab(Name)
                local TabButton = Instance.new("TextButton")
                TabButton.Name = Name .. "Tab"
                TabButton.Parent = Sidebar
                TabButton.BackgroundColor3 = Library.Theme.Element
                TabButton.BorderSizePixel = 0
                TabButton.Size = UDim2.new(1, 0, 0, 30)
                TabButton.Font = Enum.Font.Gotham
                TabButton.Text = Name
                TabButton.TextColor3 = Library.Theme.TextMuted
                TabButton.TextSize = 12

                local TabUICorner = Instance.new("UICorner")
                TabUICorner.CornerRadius = UDim.new(0, 4)
                TabUICorner.Parent = TabButton

                local TabContent = Instance.new("ScrollingFrame")
                TabContent.Name = Name .. "Content"
                TabContent.Parent = ContentContainer"
                TabContent.BackgroundTransparency = 1
                TabContent.BorderSizePixel = 0
                TabContent.Size = UDim2.new(1, 0, 1, 0)
                TabContent.Visible = false
                TabContent.ScrollBarThickness = 2
                TabContent.ScrollBarImageColor3 = Library.Theme.Accent

                local TabList = Instance.new("UIListLayout")
                TabList.Parent = TabContent
                TabList.Padding = UDim.new(0, 8)
                TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local TabPadding = Instance.new("UIPadding")
                TabPadding.Parent = TabContent
                TabPadding.PaddingTop = UDim.new(0, 10)

                TabButton.MouseButton1Click:Connect(function()
                            for _, v in pairs(ContentContainer:GetChildren()) do
                                    v.Visible = false
                end
                            for _, v in pairs(Sidebar:GetChildren()) do
                                    if v:IsA("TextButton") then
                                            v.TextColor3 = Library.Theme.TextMuted
                    end
                end
                            TabContent.Visible = true
                            TabButton.TextColor3 = Library.Theme.Accent
            end)

                if not Window.FirstTab then
                        Window.FirstTab = true
                        TabContent.Visible = true
                        TabButton.TextColor3 = Library.Theme.Accent
        end

                local Tab = {}

                function Tab:CreateButton(Text, Callback)
                        local ButtonFrame = Instance.new("Frame")
                        ButtonFrame.Parent = TabContent
                        ButtonFrame.BackgroundColor3 = Library.Theme.Element
                        ButtonFrame.Size = UDim2.new(0.9, 0, 0, 35)

                        local BCorner = Instance.new("UICorner")
                        BCorner.CornerRadius = UDim.new(0, 6)
                        BCorner.Parent = ButtonFrame

                        local TextBtn = Instance.new("TextButton")
                        TextBtn.Parent = ButtonFrame
                        TextBtn.BackgroundTransparency = 1
                        TextBtn.Size = UDim2.new(1, 0, 1, 0)
                        TextBtn.Font = Enum.Font.Gotham
                        TextBtn.Text = Text
                        TextBtn.TextColor3 = Library.Theme.Text
                        TextBtn.TextSize = 13

                        TextBtn.MouseButton1Click:Connect(function()
                                    Callback()
                end)
        end

                return Tab
    end

        return Window
end

return Library
