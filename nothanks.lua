local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckRemote = ReplicatedStorage:WaitForChild("Check")
local CheckChildExists = ReplicatedStorage:WaitForChild("CheckChildExists")
local GetKey = ReplicatedStorage:WaitForChild("GetKey")
local AntiCheat = ReplicatedStorage:WaitForChild("AntiCheat")

local restrictedNames = {
    FrameRateManager = true,
    DeviceFeatureLevel = true,
    DeviceShadingLanguage = true,
    AverageQualityLevel = true,
    AutoQuality = true,
    NumberOfSettles = true,
    AverageSwitches = true,
    FramebufferWidth = true,
    FramebufferHeight = true,
    Batches = true,
    Indices = true,
    MaterialChanges = true,
    VideoMemoryInMB = true,
    AverageFPS = true,
    FrameTimeVariance = true,
    FrameSpikeCount = true,
    RenderAverage = true,
    PrepareAverage = true,
    PerformAverage = true,
    AveragePresent = true,
    AverageGPU = true,
    RenderThreadAverage = true,
    TotalFrameWallAverage = true,
    PerformVariance = true,
    PresentVariance = true,
    GpuVariance = true,
    MsFrame0 = true,
    MsFrame1 = true,
    MsFrame2 = true,
    MsFrame3 = true,
    MsFrame4 = true,
    MsFrame5 = true,
    MsFrame6 = true,
    MsFrame7 = true,
    MsFrame8 = true,
    MsFrame9 = true,
    MsFrame10 = true,
    MsFrame11 = true,
    Render = true,
    Memory = true,
    Video = true,
    CursorImage = true,
    LanguageService = true,
}

CheckRemote.OnClientInvoke = function()
    local expectedKey = GetKey:InvokeServer()
    return { key = expectedKey, valid = true }
end

-- Get parent hierarchy
local function getParentHierarchy(instance)
    local hierarchy = {}
    local parent = instance.Parent
    while parent and parent ~= game do
        table.insert(hierarchy, parent)
        parent = parent.Parent
    end
    return hierarchy
end

local function validateInstance(instance, expectedKey)
    if restrictedNames[instance.Name] then
        return true
    end

    local keyInstance = instance:FindFirstChild("Key")
    if keyInstance and keyInstance.Value == expectedKey then
        return true
    end

    for _, parent in ipairs(getParentHierarchy(instance)) do
        if parent.Name == "ReplicatedStorage" then
            AntiCheat:FireServer(instance.Name, "Attempted to create instance in ReplicatedStorage")
            return false
        end
        local parentKey = parent:FindFirstChild("Key")
        if parentKey and parentKey.Value == expectedKey then
            return true
        end
    end

    return false
end

game.DescendantAdded:Connect(function(instance)
    local expectedKey = GetKey:InvokeServer()
    if not expectedKey then
        AntiCheat:FireServer(instance.Name, "Failed to retrieve server key")
        return
    end

    if not validateInstance(instance, expectedKey) then
        AntiCheat:FireServer(instance.Name, "Invalid or missing key in instance hierarchy")
        return
    end

    if instance.Name == "Key" and instance.Value ~= expectedKey then
        AntiCheat:FireServer(instance.Name, "Mismatched key value")
    end
end)
