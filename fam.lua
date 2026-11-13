local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local function getRF(name)
	local ok, rf = pcall(function()
		return RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RF[name]
	end)
	if ok and rf then return rf end

	local ok2, rf2 = pcall(function()
		local packages = RS:FindFirstChild("Packages")
		if not packages then return nil end
		local index = packages:FindFirstChild("_Index")
		if not index then return nil end
		for _, folder in index:GetChildren() do
			if folder.Name:find("knit") then
				local path = folder:FindFirstChild("knit")
				if path then
					local svc = path:FindFirstChild("Services") and path.Services:FindFirstChild("BallService")
					if svc then
						local folderRF = svc:FindFirstChild("RF")
						if folderRF then return folderRF:FindFirstChild(name) end
					end
				end
			end
		end
		return nil
	end)
	return ok2 and rf2 or nil
end

local CreateHitbox = getRF("CreateHitbox")
local Interact = getRF("Interact")
local Jump = getRF("Jump")
local UpdateTilt = getRF("UpdateTilt")

print("[INIT] CreateHitbox:", CreateHitbox and "FOUND" or "MISSING")
print("[INIT] Interact:", Interact and "FOUND" or "MISSING")
print("[INIT] Jump:", Jump and "FOUND" or "MISSING")
print("[INIT] UpdateTilt:", UpdateTilt and "FOUND" or "MISSING")

local ICONS = {
	x = "rbxassetid://110786993356448",
	minimize = "rbxassetid://121304296213645"
}

local sg = Instance.new("ScreenGui")
sg.Name = "NexxWare"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 178, 0, 248)
main.Position = UDim2.new(0.04, 0, 0.28, 0)
main.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
main.BackgroundTransparency = 0.22
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = sg

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(160, 185, 230)
mainStroke.Transparency = 0.62
mainStroke.Thickness = 1.2
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
header.BackgroundTransparency = 0.12
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1, 0, 0, 12)
headerFill.Position = UDim2.new(0, 0, 1, -12)
headerFill.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
headerFill.BackgroundTransparency = 0.12
headerFill.BorderSizePixel = 0
headerFill.Parent = header
