local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ESP Interface",
   LoadingTitle = "ESP Loading...",
   LoadingSubtitle = "by Qwiix21",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ESPConfig",
      FileName = "ESPSettings"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Services
local P = game:GetService("Players")
local LP = P.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local RunService = game:GetService("RunService")

-- Global Variables
getgenv().Toggle = false
getgenv().TC = false
local PlayerName = "Name"
local DB = false
local ESPLoop

-- Settings
local ESPSettings = {
    ShowDistance = true,
    ShowHealth = true,
    ShowItem = true,
    ShowText = true,
    FillTransparency = 0.5,
    ShowOutline = true,
    OutlineTransparency = 0
}

local SkeletonSettings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    Thickness = 1,
    ShowHealth = false,
    ShowItem = false
}

local BoxSettings = {
    Enabled = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    TracerThickness = 1,
    BoxThickness = 1,
    TracerOrigin = "Bottom",
    TracerFollowMouse = false,
    Tracers = true,
    ShowItem = false
}

local TeamCheck = {
    Enabled = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

-- Connections
local SkeletonConnections = {}
local BoxConnections = {}

-- Helper Functions
local function getHeldItemName(character)
    if not character then return "None" end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return "None" end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    if humanoid:FindFirstChildOfClass("Tool") then
        return humanoid:FindFirstChildOfClass("Tool").Name
    end
    local player = P:GetPlayerFromCharacter(character)
    if player then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Enabled then
                    return item.Name
                end
            end
        end
    end
    return "None"
end

local function getHealthInfo(character)
    if not character then return "0/0" end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return "0/0" end
    return math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
end

local function getHealthColor(character)
    if not character then return Color3.fromRGB(255, 255, 255) end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.MaxHealth == 0 then return Color3.fromRGB(255, 255, 255) end
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    if healthPercent > 0.7 then
        return Color3.fromRGB(0, 255, 0)
    elseif healthPercent > 0.3 then
        return Color3.fromRGB(255, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

-- Tabs
local ESPTab = Window:CreateTab("ESP", 4483362458)
local SkeletonTab = Window:CreateTab("Skeleton ESP", 4483362458)
local BoxTab = Window:CreateTab("Box ESP", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ESP Tab Controls
local ESPToggle = ESPTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      getgenv().Toggle = Value
      if Value then
         ESPLoop = spawn(function()
            while getgenv().Toggle do
               if DB then 
                  task.wait()
                  continue
               end
               DB = true

               pcall(function()
                  for i,v in pairs(P:GetChildren()) do
                     if v:IsA("Player") and v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = math.floor((LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude)
                        local heldItem = getHeldItemName(v.Character)
                        local healthInfo = getHealthInfo(v.Character)
                        local healthColor = getHealthColor(v.Character)

                        local shouldShow = not getgenv().TC or (getgenv().TC and v.TeamColor ~= LP.TeamColor)
                        
                        if not v.Character:FindFirstChild("Totally NOT Esp") and not v.Character:FindFirstChild("Icon") and shouldShow then
                           local ESP = Instance.new("Highlight", v.Character)
                           ESP.Name = "Totally NOT Esp"
                           ESP.Adornee = v.Character
                           ESP.Archivable = true
                           ESP.Enabled = true
                           ESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                           ESP.FillColor = v.TeamColor.Color
                           ESP.FillTransparency = ESPSettings.FillTransparency
                           ESP.OutlineColor = Color3.fromRGB(255, 255, 255)
                           ESP.OutlineTransparency = ESPSettings.ShowOutline and ESPSettings.OutlineTransparency or 1

                           if ESPSettings.ShowText then
                              local Icon = Instance.new("BillboardGui", v.Character)
                              local ESPText = Instance.new("TextLabel")
                              Icon.Name = "Icon"
                              Icon.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                              Icon.Active = true
                              Icon.AlwaysOnTop = true
                              Icon.ExtentsOffset = Vector3.new(0, 1, 0)
                              Icon.LightInfluence = 1.000
                              Icon.Size = UDim2.new(0, 800, 0, 50)

                              ESPText.Name = "ESP Text"
                              ESPText.Parent = Icon
                              ESPText.BackgroundColor3 = v.TeamColor.Color
                              ESPText.BackgroundTransparency = 1.000
                              ESPText.Size = UDim2.new(0, 800, 0, 50)
                              ESPText.Font = Enum.Font.SciFi
                              
                              local itemText = ""
                              if ESPSettings.ShowItem and heldItem ~= "None" then
                                 itemText = " | Item: " .. heldItem
                              end
                              
                              local healthText = ""
                              if ESPSettings.ShowHealth then
                                 healthText = " | HP: " .. healthInfo
                              end
                              
                              local distanceText = ""
                              if ESPSettings.ShowDistance then
                                 distanceText = " | Distance: " .. pos
                              end
                              
                              ESPText.Text = v[PlayerName] .. healthText .. distanceText .. itemText
                              ESPText.TextColor3 = healthColor
                              ESPText.TextSize = 10.800
                              ESPText.TextWrapped = true
                           end

                        else
                           if v.Character:FindFirstChild("Totally NOT Esp") and shouldShow then
                              local esp = v.Character:FindFirstChild("Totally NOT Esp")
                              if esp.FillColor ~= v.TeamColor.Color then
                                 esp.FillColor = v.TeamColor.Color
                              end
                              esp.FillTransparency = ESPSettings.FillTransparency
                              esp.OutlineTransparency = ESPSettings.ShowOutline and ESPSettings.OutlineTransparency or 1
                              
                              if v.Character:FindFirstChild("Icon") and ESPSettings.ShowText then
                                 local itemText = ""
                                 if ESPSettings.ShowItem and heldItem ~= "None" then
                                    itemText = " | Item: " .. heldItem
                                 end
                                 
                                 local healthText = ""
                                 if ESPSettings.ShowHealth then
                                    healthText = " | HP: " .. healthInfo
                                 end
                                 
                                 local distanceText = ""
                                 if ESPSettings.ShowDistance then
                                    distanceText = " | Distance: " .. pos
                                 end
                                 
                                 v.Character:FindFirstChild("Icon")["ESP Text"].Text = v[PlayerName] .. healthText .. distanceText .. itemText
                                 v.Character:FindFirstChild("Icon")["ESP Text"].TextColor3 = healthColor
                              elseif v.Character:FindFirstChild("Icon") and not ESPSettings.ShowText then
                                 v.Character:FindFirstChild("Icon")["ESP Text"].Text = ""
                              end
                           elseif v.Character:FindFirstChild("Totally NOT Esp") and not shouldShow then
                              v.Character:FindFirstChild("Totally NOT Esp"):Destroy()
                              if v.Character:FindFirstChild("Icon") then
                                 v.Character:FindFirstChild("Icon"):Destroy()
                              end
                           end
                        end
                     end
                  end
               end)
               task.wait()
               DB = false
            end
         end)
      else
         -- Clean up ESP
         for i,v in pairs(P:GetChildren()) do
            if v:IsA("Player") and v.Character then
               if v.Character:FindFirstChild("Totally NOT Esp") then
                  v.Character:FindFirstChild("Totally NOT Esp"):Destroy()
               end
               if v.Character:FindFirstChild("Icon") then
                  v.Character:FindFirstChild("Icon"):Destroy()
               end
            end
         end
      end
   end,
})

local TeamCheckToggle = ESPTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
      getgenv().TC = Value
   end,
})

local PlayerNameDropdown = ESPTab:CreateDropdown({
   Name = "Player Name Display",
   Options = {"Name", "DisplayName"},
   CurrentOption = "Name",
   MultipleOptions = false,
   Flag = "PlayerName",
   Callback = function(Option)
      PlayerName = Option
   end,
})

local ShowTextToggle = ESPTab:CreateToggle({
   Name = "Show Text Info",
   CurrentValue = true,
   Flag = "ShowText",
   Callback = function(Value)
      ESPSettings.ShowText = Value
   end,
})

local ShowDistanceToggle = ESPTab:CreateToggle({
   Name = "Show Distance",
   CurrentValue = true,
   Flag = "ShowDistance",
   Callback = function(Value)
      ESPSettings.ShowDistance = Value
   end,
})

local ShowHealthToggle = ESPTab:CreateToggle({
   Name = "Show Health",
   CurrentValue = true,
   Flag = "ShowHealth",
   Callback = function(Value)
      ESPSettings.ShowHealth = Value
   end,
})

local ShowItemToggle = ESPTab:CreateToggle({
   Name = "Show Item",
   CurrentValue = true,
   Flag = "ShowItem",
   Callback = function(Value)
      ESPSettings.ShowItem = Value
   end,
})

local TransparencySlider = ESPTab:CreateSlider({
   Name = "Fill Transparency",
   Range = {0, 1},
   Increment = 0.01,
   CurrentValue = 0.5,
   Flag = "Transparency",
   Callback = function(Value)
      ESPSettings.FillTransparency = Value
      for i,v in pairs(P:GetChildren()) do
         if v:IsA("Player") and v.Character and v.Character:FindFirstChild("Totally NOT Esp") then
            v.Character:FindFirstChild("Totally NOT Esp").FillTransparency = Value
         end
      end
   end,
})

local ShowOutlineToggle = ESPTab:CreateToggle({
   Name = "Show Outline",
   CurrentValue = true,
   Flag = "ShowOutline",
   Callback = function(Value)
      ESPSettings.ShowOutline = Value
      for i,v in pairs(P:GetChildren()) do
         if v:IsA("Player") and v.Character and v.Character:FindFirstChild("Totally NOT Esp") then
            v.Character:FindFirstChild("Totally NOT Esp").OutlineTransparency = Value and ESPSettings.OutlineTransparency or 1
         end
      end
   end,
})

local OutlineTransparencySlider = ESPTab:CreateSlider({
   Name = "Outline Transparency",
   Range = {0, 1},
   Increment = 0.01,
   CurrentValue = 0,
   Flag = "OutlineTransparency",
   Callback = function(Value)
      ESPSettings.OutlineTransparency = Value
      if ESPSettings.ShowOutline then
         for i,v in pairs(P:GetChildren()) do
            if v:IsA("Player") and v.Character and v.Character:FindFirstChild("Totally NOT Esp") then
               v.Character:FindFirstChild("Totally NOT Esp").OutlineTransparency = Value
            end
         end
      end
   end,
})

-- Skeleton ESP Functions
local function DrawLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = SkeletonSettings.Color
    l.Thickness = SkeletonSettings.Thickness
    l.Transparency = 1
    return l
end

local function DrawText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Text = ""
    t.Size = 13
    t.Color = Color3.fromRGB(255, 255, 255)
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.Font = 2
    return t
end

local function DrawSkeletonESP(plr)
    if SkeletonConnections[plr] then return end
    
    repeat wait() until plr.Character and plr.Character:FindFirstChild("Humanoid")
    
    local limbs = {}
    local texts = {}
    
    texts.health = DrawText()
    texts.item = DrawText()
    
    for i = 1, 15 do
        limbs[i] = DrawLine()
    end

    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state and SkeletonSettings.Enabled
        end
    end

    local function Colorize(color)
        for i, v in pairs(limbs) do
            v.Color = color
        end
    end

    local function Updater()
        local connection = RunService.RenderStepped:Connect(function()
            if not SkeletonSettings.Enabled then
                Visibility(false)
                texts.health.Visible = false
                texts.item.Visible = false
                return
            end
            
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    local head = plr.Character:FindFirstChild("Head")
                    if not head then return end
                    local H = Camera:WorldToViewportPoint(head.Position)
                    
                    pcall(function()
                        local R15 = plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
                        
                        if R15 then
                            local connections = {
                                {"Head", "UpperTorso", 1},
                                {"UpperTorso", "LowerTorso", 2},
                                {"UpperTorso", "LeftUpperArm", 3},
                                {"LeftUpperArm", "LeftLowerArm", 4},
                                {"LeftLowerArm", "LeftHand", 5},
                                {"UpperTorso", "RightUpperArm", 6},
                                {"RightUpperArm", "RightLowerArm", 7},
                                {"RightLowerArm", "RightHand", 8},
                                {"LowerTorso", "LeftUpperLeg", 9},
                                {"LeftUpperLeg", "LeftLowerLeg", 10},
                                {"LeftLowerLeg", "LeftFoot", 11},
                                {"LowerTorso", "RightUpperLeg", 12},
                                {"RightUpperLeg", "RightLowerLeg", 13},
                                {"RightLowerLeg", "RightFoot", 14}
                            }
                            
                            for _, connection in ipairs(connections) do
                                local part1 = plr.Character:FindFirstChild(connection[1])
                                local part2 = plr.Character:FindFirstChild(connection[2])
                                if part1 and part2 then
                                    local pos1 = connection[1] == "Head" and H or Camera:WorldToViewportPoint(part1.Position)
                                    local pos2 = Camera:WorldToViewportPoint(part2.Position)
                                    limbs[connection[3]].From = Vector2.new(pos1.X, pos1.Y)
                                    limbs[connection[3]].To = Vector2.new(pos2.X, pos2.Y)
                                end
                            end
                        else
                            local torso = plr.Character:FindFirstChild("Torso")
                            local leftArm = plr.Character:FindFirstChild("Left Arm")
                            local rightArm = plr.Character:FindFirstChild("Right Arm")
                            local leftLeg = plr.Character:FindFirstChild("Left Leg")
                            local rightLeg = plr.Character:FindFirstChild("Right Leg")
                            
                            if torso then
                                local torsoPos = Camera:WorldToViewportPoint(torso.Position)
                                limbs[1].From = Vector2.new(H.X, H.Y)
                                limbs[1].To = Vector2.new(torsoPos.X, torsoPos.Y)
                                
                                if leftArm then
                                    local armPos = Camera:WorldToViewportPoint(leftArm.Position)
                                    limbs[2].From = Vector2.new(torsoPos.X, torsoPos.Y)
                                    limbs[2].To = Vector2.new(armPos.X, armPos.Y)
                                end
                                
                                if rightArm then
                                    local armPos = Camera:WorldToViewportPoint(rightArm.Position)
                                    limbs[3].From = Vector2.new(torsoPos.X, torsoPos.Y)
                                    limbs[3].To = Vector2.new(armPos.X, armPos.Y)
                                end
                                
                                if leftLeg then
                                    local legPos = Camera:WorldToViewportPoint(leftLeg.Position)
                                    limbs[4].From = Vector2.new(torsoPos.X, torsoPos.Y)
                                    limbs[4].To = Vector2.new(legPos.X, legPos.Y)
                                end
                                
                                if rightLeg then
                                    local legPos = Camera:WorldToViewportPoint(rightLeg.Position)
                                    limbs[5].From = Vector2.new(torsoPos.X, torsoPos.Y)
                                    limbs[5].To = Vector2.new(legPos.X, legPos.Y)
                                end
                            end
                        end
                    end)

                    local heldItem = getHeldItemName(plr.Character)
                    local healthInfo = getHealthInfo(plr.Character)
                    local healthColor = getHealthColor(plr.Character)
                    
                    if SkeletonSettings.ShowItem then
                        texts.item.Position = Vector2.new(H.X, H.Y - 20)
                        local itemText = ""
                        if heldItem ~= "None" then
                            itemText = "Item: " .. heldItem
                        end
                        texts.item.Text = itemText
                        texts.item.Visible = true
                    else
                        texts.item.Visible = false
                    end
                    
                    if SkeletonSettings.ShowHealth then
                        texts.health.Position = Vector2.new(H.X, H.Y + 40)
                        texts.health.Text = "HP: " .. healthInfo
                        texts.health.Color = healthColor
                        texts.health.Visible = true
                    else
                        texts.health.Visible = false
                    end
                    
                    if TeamCheck.Enabled then
                        Colorize(plr.TeamColor.Color)
                    else
                        Colorize(SkeletonSettings.Color)
                    end

                    Visibility(true)
                else 
                    Visibility(false)
                    texts.health.Visible = false
                    texts.item.Visible = false
                end
            else 
                Visibility(false)
                texts.health.Visible = false
                texts.item.Visible = false
                if not game.Players:FindFirstChild(plr.Name) then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    for i, v in pairs(texts) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
        return connection
    end

    local connection = Updater()
    SkeletonConnections[plr] = {connection = connection, limbs = limbs, texts = texts, colorize = Colorize}
end

-- Skeleton ESP Tab
local SkeletonToggle = SkeletonTab:CreateToggle({
   Name = "Enable Skeleton ESP",
   CurrentValue = false,
   Flag = "SkeletonToggle",
   Callback = function(Value)
      SkeletonSettings.Enabled = Value
      if Value then
         for i, v in pairs(P:GetPlayers()) do
            if v ~= LP then
               coroutine.wrap(DrawSkeletonESP)(v)
            end
         end
      else
         for plr, data in pairs(SkeletonConnections) do
            if data.connection then data.connection:Disconnect() end
            for _, limb in pairs(data.limbs) do limb:Remove() end
            for _, text in pairs(data.texts) do text:Remove() end
         end
         SkeletonConnections = {}
      end
   end,
})

local SkeletonColorPicker = SkeletonTab:CreateColorPicker({
   Name = "Skeleton Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "SkeletonColor",
   Callback = function(Value)
      SkeletonSettings.Color = Value
      for plr, data in pairs(SkeletonConnections) do
         data.colorize(Value)
      end
   end
})

local SkeletonThicknessSlider = SkeletonTab:CreateSlider({
   Name = "Line Thickness",
   Range = {1, 5},
   Increment = 1,
   CurrentValue = 1,
   Flag = "SkeletonThickness",
   Callback = function(Value)
      SkeletonSettings.Thickness = Value
      for plr, data in pairs(SkeletonConnections) do
         for _, limb in pairs(data.limbs) do
            limb.Thickness = Value
         end
      end
   end,
})

local SkeletonShowHealth = SkeletonTab:CreateToggle({
   Name = "Show Health",
   CurrentValue = false,
   Flag = "SkeletonShowHealth",
   Callback = function(Value)
      SkeletonSettings.ShowHealth = Value
   end,
})

local SkeletonShowItem = SkeletonTab:CreateToggle({
   Name = "Show Item",
   CurrentValue = false,
   Flag = "SkeletonShowItem",
   Callback = function(Value)
      SkeletonSettings.ShowItem = Value
   end,
})

local SkeletonTeamCheck = SkeletonTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "SkeletonTeamCheck",
   Callback = function(Value)
      TeamCheck.Enabled = Value
   end,
})

-- Box ESP Functions
local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color 
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function BoxESP(plr)
    if BoxConnections[plr] then return end
    
    local black = Color3.fromRGB(0, 0, 0)
    local library = {
        blacktracer = NewLine(BoxSettings.TracerThickness*2, black),
        tracer = NewLine(BoxSettings.TracerThickness, BoxSettings.TracerColor),
        black = NewQuad(BoxSettings.BoxThickness*2, black),
        box = NewQuad(BoxSettings.BoxThickness, BoxSettings.BoxColor),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black)
    }

    local itemText
    if BoxSettings.ShowItem then
        itemText = Drawing.new("Text")
        itemText.Visible = false
        itemText.Text = ""
        itemText.Size = 13
        itemText.Color = Color3.fromRGB(255, 255, 255)
        itemText.Center = true
        itemText.Outline = true
        itemText.OutlineColor = Color3.fromRGB(0, 0, 0)
        itemText.Font = 2
        library.itemText = itemText
    end

    local function Visibility(state, lib)
        for u, x in pairs(lib) do
            x.Visible = state and BoxSettings.Enabled
        end
    end

    local function Colorize(color)
        for u, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black and x ~= library.itemText then
                x.Color = color
            end
        end
    end

    local connection = RunService.RenderStepped:Connect(function()
        if not BoxSettings.Enabled then
            Visibility(false, library)
            return
        end
        
        if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") then
            local HumPos, OnScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if OnScreen then
                local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
                
                local function Size(item)
                    item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
                    item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
                    item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
                    item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
                end
                Size(library.box)
                Size(library.black)

                if BoxSettings.Tracers then
                    if BoxSettings.TracerOrigin == "Middle" then
                        library.tracer.From = Camera.ViewportSize*0.5
                        library.blacktracer.From = Camera.ViewportSize*0.5
                    elseif BoxSettings.TracerOrigin == "Bottom" then
                        library.tracer.From = Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y) 
                        library.blacktracer.From = Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y)
                    end
                    if BoxSettings.TracerFollowMouse then
                        library.tracer.From = Vector2.new(Mouse.X, Mouse.Y+36)
                        library.blacktracer.From = Vector2.new(Mouse.X, Mouse.Y+36)
                    end
                    library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                    library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                else 
                    library.tracer.From = Vector2.new(0, 0)
                    library.blacktracer.From = Vector2.new(0, 0)
                    library.tracer.To = Vector2.new(0, 0)
                    library.blacktracer.To = Vector2.new(0, 0)
                end

                local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
                local healthoffset = plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth * d

                library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)
                library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)
                
                local green = Color3.fromRGB(0, 255, 0)
                local red = Color3.fromRGB(255, 0, 0)
                library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth)

                if library.itemText then
                    local heldItem = getHeldItemName(plr.Character)
                    library.itemText.Position = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2 - 15)
                    local itemText = ""
                    if heldItem ~= "None" then
                        itemText = "Item: " .. heldItem
                    end
                    library.itemText.Text = itemText
                end

                if TeamCheck.Enabled then
                    library.tracer.Color = plr.TeamColor.Color
                    library.box.Color = plr.TeamColor.Color
                else 
                    library.tracer.Color = BoxSettings.TracerColor
                    library.box.Color = BoxSettings.BoxColor
                end
                
                Visibility(true, library)
            else 
                Visibility(false, library)
            end
        else 
            Visibility(false, library)
            if not game.Players:FindFirstChild(plr.Name) then
                connection:Disconnect()
            end
        end
    end)
    
    BoxConnections[plr] = {connection = connection, library = library}
end

-- Box ESP Tab
local BoxToggle = BoxTab:CreateToggle({
   Name = "Enable Box ESP",
   CurrentValue = false,
   Flag = "BoxToggle",
   Callback = function(Value)
      BoxSettings.Enabled = Value
      if Value then
         for i, v in pairs(P:GetPlayers()) do
            if v ~= LP then
               coroutine.wrap(BoxESP)(v)
            end
         end
      else
         for plr, data in pairs(BoxConnections) do
            if data.connection then data.connection:Disconnect() end
            for _, item in pairs(data.library) do item:Remove() end
         end
         BoxConnections = {}
      end
   end,
})

local BoxColorPicker = BoxTab:CreateColorPicker({
   Name = "Box Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "BoxColor",
   Callback = function(Value)
      BoxSettings.BoxColor = Value
   end
})

local TracerToggle = BoxTab:CreateToggle({
   Name = "Enable Tracers",
   CurrentValue = true,
   Flag = "TracerToggle",
   Callback = function(Value)
      BoxSettings.Tracers = Value
   end,
})

local TracerColorPicker = BoxTab:CreateColorPicker({
   Name = "Tracer Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "TracerColor",
   Callback = function(Value)
      BoxSettings.TracerColor = Value
   end
})

local TracerOriginDropdown = BoxTab:CreateDropdown({
   Name = "Tracer Origin",
   Options = {"Bottom", "Middle"},
   CurrentOption = "Bottom",
   MultipleOptions = false,
   Flag = "TracerOrigin",
   Callback = function(Option)
      BoxSettings.TracerOrigin = Option
   end,
})

local TracerFollowMouse = BoxTab:CreateToggle({
   Name = "Tracer Follow Mouse",
   CurrentValue = false,
   Flag = "TracerFollowMouse",
   Callback = function(Value)
      BoxSettings.TracerFollowMouse = Value
   end,
})

local BoxThickness = BoxTab:CreateSlider({
   Name = "Box Thickness",
   Range = {1, 5},
   Increment = 1,
   CurrentValue = 1,
   Flag = "BoxThickness",
   Callback = function(Value)
      BoxSettings.BoxThickness = Value
   end,
})

local TracerThickness = BoxTab:CreateSlider({
   Name = "Tracer Thickness",
   Range = {1, 5},
   Increment = 1,
   CurrentValue = 1,
   Flag = "TracerThickness",
   Callback = function(Value)
      BoxSettings.TracerThickness = Value
   end,
})

local BoxTeamCheck = BoxTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "BoxTeamCheck",
   Callback = function(Value)
      TeamCheck.Enabled = Value
   end,
})

local BoxShowItem = BoxTab:CreateToggle({
   Name = "Show Item",
   CurrentValue = false,
   Flag = "BoxShowItem",
   Callback = function(Value)
      BoxSettings.ShowItem = Value
      -- Restart box ESP to apply changes
      if BoxSettings.Enabled then
         for plr, data in pairs(BoxConnections) do
            if data.connection then data.connection:Disconnect() end
            for _, item in pairs(data.library) do item:Remove() end
         end
         BoxConnections = {}
         for i, v in pairs(P:GetPlayers()) do
            if v ~= LP then
               coroutine.wrap(BoxESP)(v)
            end
         end
      end
   end,
})

-- Player Events
P.PlayerAdded:Connect(function(newplr)
    if newplr ~= LP then
        if SkeletonSettings.Enabled then
            coroutine.wrap(DrawSkeletonESP)(newplr)
        end
        if BoxSettings.Enabled then
            coroutine.wrap(BoxESP)(newplr)
        end
    end
end)

P.PlayerRemoving:Connect(function(plr)
    if SkeletonConnections[plr] then
        if SkeletonConnections[plr].connection then
            SkeletonConnections[plr].connection:Disconnect()
        end
        for _, limb in pairs(SkeletonConnections[plr].limbs) do
            limb:Remove()
        end
        for _, text in pairs(SkeletonConnections[plr].texts) do
            text:Remove()
        end
        SkeletonConnections[plr] = nil
    end
    
    if BoxConnections[plr] then
        if BoxConnections[plr].connection then
            BoxConnections[plr].connection:Disconnect()
        end
        for _, item in pairs(BoxConnections[plr].library) do
            item:Remove()
        end
        BoxConnections[plr] = nil
    end
end)

-- Info Tab
local InfoLabel = InfoTab:CreateLabel("ESP Interface by Qwiix21")

local RepoButton = InfoTab:CreateButton({
   Name = "Open GitHub Repository",
   Callback = function()
      setclipboard("https://github.com/qwiix21/Roblox-ESP-script")
      Rayfield:Notify({
         Title = "Repository Link",
         Content = "GitHub link copied to clipboard!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local VersionLabel = InfoTab:CreateLabel("Version: 2.0 - Enhanced")
local FeaturesLabel = InfoTab:CreateLabel("Features: Highlight ESP, Skeleton ESP, Box ESP")
local OptimizedLabel = InfoTab:CreateLabel("Optimized for performance and compatibility")

Rayfield:Notify({
   Title = "ESP Interface",
   Content = "ESP Interface loaded successfully!",
   Duration = 3,
   Image = 4483362458,
})