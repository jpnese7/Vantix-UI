# Vantix UI

**Vantix UI** is a premium, high-performance Roblox UI Library designed for security researchers and developers who demand a polished, modern aesthetic with smooth animations.

## Features

- **Butter-Smooth Animations**: Powered by custom TweenService implementations for premium easing.
- **Modern Glassmorphism Design**: Sleek, dark-themed interface with high readability.
- **Extensive Component Library**: Includes Windows, Tabs, Buttons, Toggles, Sliders, Dropdowns, and more.
- **Draggable & Responsive**: Optimized for various screen sizes and user interactions.
- **Zero-Budget Friendly**: Fully hosted on GitHub and easy to integrate into any script.

## Quick Start

To use Vantix UI in your script, simply copy and paste the following loadstring:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jpnese7/Vantix-UI/main/VantixLib.lua"))()

local Window = Library:CreateWindow({
    Name = "Vantix UI Hub",
        LoadingTitle = "Vantix UI",
            LoadingSubtitle = "by jpnese7"
            })

            local Tab = Window:CreateTab("Main")

            Tab:CreateButton("Click Me", function()
                print("Vantix UI is active!")
                end)

                Tab:CreateToggle("Infinite Jump", false, function(Value)
                    print("Infinite Jump is now: " .. tostring(Value))
                    end)
                    ```

                    ## Documentation

                    Visit our [Web Documentation & Preview](https://jpnese7.github.io/Vantix-UI/preview/index.html) to see the library in action and explore the full API.

                    ## License

                    This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
                    
