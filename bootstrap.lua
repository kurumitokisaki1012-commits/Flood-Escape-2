-- Movement panel v1.0
-- Standalone client script. Re-running replaces this panel and its listeners.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local NAME = "MJFMovementPanel"

local old = playerGui:FindFirstChild(NAME)
if old then
    local cleanup = old:FindFirstChild("Cleanup")
    if cleanup and cleanup:IsA("BindableEvent") then cleanup:Fire() end
    old:Destroy()
end

local connections = {}
local characterConnections = {}
local alive = true
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local jumpEnabled, teleportEnabled = false, false
local jumpHeight = 7.2
local spaceHeld = UIS:IsKeyDown(Enum.KeyCode.Space)
local minimized = false
local MAX_DISTANCE = 1500

local gui = Instance.new("ScreenGui")
gui.Name = NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local cleanup = Instance.new("BindableEvent")
cleanup.Name = "Cleanup"
cleanup.Parent = gui

local function stop()
    if not alive then return end
    alive = false
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(characterConnections) do c:Disconnect() end
end
connect(cleanup.Event, stop)
connect(gui.Destroying, stop)

local colors = {
    background = Color3.fromRGB(25, 28, 35),
    sidebar = Color3.fromRGB(19, 22, 29),
    button = Color3.fromRGB(45, 49, 60),
    active = Color3.fromRGB(30, 145, 90),
    selected = Color3.fromRGB(35, 100, 160),
}
local function make(class, parent, properties)
    local object = Instance.new(class)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end
local function round(object)
    make("UICorner", object, {CornerRadius = UDim.new(0, 8)})
end
local panel = make("Frame", gui, {
    Size = UDim2.fromOffset(390, 270),
    Position = UDim2.new(0, 20, 0.5, -135),
    BackgroundColor3 = colors.background,
    BorderSizePixel = 0, ClipsDescendants = true, Active = true,
})
round(panel)

local title = make("TextLabel", panel, {
    Size = UDim2.new(1, -48, 0, 38),
    BackgroundTransparency = 1, Text = "Movement Panel",
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold,
    TextSize = 16, Active = true,
})
local minimize = make("TextButton", panel, {
    Size = UDim2.fromOffset(32, 28),
    Position = UDim2.new(1, -38, 0, 5),
    BackgroundColor3 = colors.button,
    Text = "-", TextSize = 22, TextColor3 = Color3.new(1, 1, 1),
})
round(minimize)

local body = make("Frame", panel, {
    Size = UDim2.new(1, 0, 1, -38),
    Position = UDim2.fromOffset(0, 38), BackgroundTransparency = 1,
})
local sidebar = make("Frame", body, {
    Size = UDim2.new(0, 104, 1, 0),
    BackgroundColor3 = colors.sidebar, BorderSizePixel = 0,
})
local pages = {}
local tabButtons = {}
local function control(class, parent, text, y, height)
    local item = make(class, parent, {
        Size = UDim2.new(1, -20, 0, height),
        Position = UDim2.fromOffset(10, y),
        BackgroundColor3 = colors.button, BorderSizePixel = 0,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamMedium, TextSize = 13, Text = text,
    })
    round(item)
    return item
end
local function label(parent, text, y, height)
    local item = control("TextLabel", parent, text, y, height)
    item.BackgroundTransparency = 1
    item.TextWrapped = true
    return item
end
local function selectTab(name)
    for key, page in pairs(pages) do
        page.Visible = key == name
        tabButtons[key].BackgroundColor3 =
            key == name and colors.selected or colors.button
    end
end
for index, name in ipairs({"Jump", "Teleport"}) do
    pages[name] = make("Frame", body, {
        Size = UDim2.new(1, -104, 1, 0),
        Position = UDim2.fromOffset(104, 0),
        BackgroundTransparency = 1,
    })
    tabButtons[name] = control("TextButton", sidebar, name, 10 + (index - 1) * 44, 34)
    connect(tabButtons[name].Activated, function() selectTab(name) end)
end

local jumpToggle = control("TextButton", pages.Jump, "Infinite Jump: OFF", 10, 34)
label(pages.Jump, "Boost height (studs)", 52, 20)
local heightInput = control("TextBox", pages.Jump, "7.2", 78, 32)
heightInput.ClearTextOnFocus = false
local defaults = label(pages.Jump, "Reading jump settings...", 118, 54)
label(pages.Jump, "Press SPACE once per jump.\nHolding Space does not repeat boosts.", 178, 42)

local tpToggle = control("TextButton", pages.Teleport, "Click Teleport: OFF", 10, 34)
label(pages.Teleport, "Enable, then left-click a solid wall or floor. Empty space is ignored.", 54, 56)
local tpStatus = label(pages.Teleport, "Status: OFF", 118, 40)
label(pages.Teleport, "Wall targets may leave you airborne. Gravity still applies.", 168, 46)
selectTab("Jump")

connect(minimize.Activated, function()
    minimized = not minimized
    body.Visible = not minimized
    panel.Size = UDim2.fromOffset(390, minimized and 38 or 270)
    minimize.Text = minimized and "+" or "-"
end)

local dragging, dragInput, dragStart, startPosition
connect(title.InputBegan, function(input)
    if dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragInput = true, input
        dragStart, startPosition = input.Position, panel.Position
    end
end)
connect(UIS.InputChanged, function(input)
    if not dragging then return end
    local isMouse = dragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if isMouse or input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
connect(UIS.InputEnded, function(input)
    if input == dragInput then dragging, dragInput = false, nil end
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
end)
connect(UIS.WindowFocusReleased, function() dragging, dragInput = false, nil end)
connect(UIS.WindowFocused, function()
    spaceHeld = UIS:IsKeyDown(Enum.KeyCode.Space)
end)

connect(jumpToggle.Activated, function()
    jumpEnabled = not jumpEnabled
    jumpToggle.Text = jumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
    jumpToggle.BackgroundColor3 = jumpEnabled and colors.active or colors.button
end)
connect(tpToggle.Activated, function()
    teleportEnabled = not teleportEnabled
    tpToggle.Text = teleportEnabled and "Click Teleport: ON" or "Click Teleport: OFF"
    tpToggle.BackgroundColor3 = teleportEnabled and colors.active or colors.button
    tpStatus.Text = teleportEnabled and "Status: Click a solid surface" or "Status: OFF"
end)
connect(heightInput.FocusLost, function()
    local value = tonumber(heightInput.Text)
    if value and value == value and math.abs(value) < math.huge then
        jumpHeight = math.clamp(value, 1, 200)
    end
    heightInput.Text = tostring(jumpHeight)
end)

local function parts()
    local character = player.Character
    return character,
        character and character:FindFirstChildOfClass("Humanoid"),
        character and character:FindFirstChild("HumanoidRootPart")
end
local function bindCharacter(character)
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    table.clear(characterConnections)
    spaceHeld = UIS:IsKeyDown(Enum.KeyCode.Space)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not alive or not humanoid or character ~= player.Character then return end
    local function refresh()
        defaults.Text = string.format(
            "JumpPower: %.1f | JumpHeight: %.1f\nActive: %s",
            humanoid.JumpPower, humanoid.JumpHeight,
            humanoid.UseJumpPower and "JumpPower" or "JumpHeight")
    end
    for _, property in ipairs({"JumpPower", "JumpHeight", "UseJumpPower"}) do
        table.insert(characterConnections,
            humanoid:GetPropertyChangedSignal(property):Connect(refresh))
    end
    refresh()
end
connect(player.CharacterAdded, bindCharacter)
if player.Character then task.spawn(bindCharacter, player.Character) end

local function jump()
    local _, humanoid, root = parts()
    if not humanoid or not root or humanoid.Health <= 0 then return end
    if root.Anchored or humanoid.Sit or humanoid.PlatformStand then return end
    if humanoid.FloorMaterial ~= Enum.Material.Air then return end
    local state = humanoid:GetState()
    if state ~= Enum.HumanoidStateType.Freefall
        and state ~= Enum.HumanoidStateType.Jumping then return end
    local velocity = root.AssemblyLinearVelocity
    local speed = math.sqrt(2 * math.max(workspace.Gravity, 0) * jumpHeight)
    if velocity.Y >= speed then return end
    root.AssemblyLinearVelocity = Vector3.new(velocity.X, speed, velocity.Z)
end

local function clickTeleport()
    local character, humanoid, root = parts()
    if not humanoid or not root or humanoid.Health <= 0 then return end
    if root.Anchored or humanoid.Sit then
        tpStatus.Text = "Status: Stand up before teleporting"
        return
    end
    local exclusions = {character}
    for _, other in ipairs(Players:GetPlayers()) do
        if other.Character then table.insert(exclusions, other.Character) end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = exclusions
    params.RespectCanCollide = true
    params.IgnoreWater = true
    params.CollisionGroup = root.CollisionGroup

    local ray = mouse.UnitRay
    local hit = workspace:Raycast(ray.Origin, ray.Direction * MAX_DISTANCE, params)
    if not hit then
        tpStatus.Text = "Status: No solid surface under cursor"
        return
    end

    -- Offset the character's entire bounding box from the hit plane.
    local box, size = character:GetBoundingBox()
    local normal = hit.Normal
    local clearance =
        math.abs(normal:Dot(box.RightVector)) * size.X / 2
        + math.abs(normal:Dot(box.UpVector)) * size.Y / 2
        + math.abs(normal:Dot(box.LookVector)) * size.Z / 2
    local center = hit.Position + normal * (clearance + 0.5)
    local destinationBox = CFrame.new(center) * box.Rotation

    -- Conservative check against nearby solid parts.
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = {character}
    overlap.RespectCanCollide = true
    overlap.CollisionGroup = root.CollisionGroup
    if #workspace:GetPartBoundsInBox(destinationBox, size, overlap) > 0 then
        tpStatus.Text = "Status: Destination obstructed; try another point"
        return
    end
    local offset = center - box.Position
    if root.Position.Y + offset.Y - size.Y / 2 <= workspace.FallenPartsDestroyHeight + 5 then
        tpStatus.Text = "Status: Destination below map safety limit"
        return
    end

    character:PivotTo(character:GetPivot() + offset)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    tpStatus.Text = "Status: Teleported beside surface"
end

connect(UIS.InputBegan, function(input, processed)
    if input.KeyCode == Enum.KeyCode.Space then
        if spaceHeld then return end
        spaceHeld = true
        if jumpEnabled and not processed and not UIS:GetFocusedTextBox() then jump() end
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not teleportEnabled or processed or UIS:GetFocusedTextBox() then return end
    -- GUI clicks must never trigger world teleports.
    local pointer = UIS:GetMouseLocation()
    for _, object in ipairs(playerGui:GetGuiObjectsAtPosition(pointer.X, pointer.Y)) do
        if object:IsDescendantOf(gui) then return end
    end
    clickTeleport()
end)

