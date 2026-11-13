		if blkOn() then
			if bid == 0 or not ball then
				if tick() - lastPrint > 1 then
					print("[BLOCK] No BID / ball found")
					lastPrint = tick()
				end
			elseif not CreateHitbox or not Interact then
				if tick() - lastPrint > 1 then
					print("[BLOCK] Missing remote(s)")
					lastPrint = tick()
				end
			else
				if tick() - lastPrint > 1 then
					print("[BLOCK] Using BallId:", bid)
					lastPrint = tick()
				end
				local key = "Block" .. math.random(1000000, 9999999)
				pcall(function()
					CreateHitbox:InvokeServer({
						BallId = bid,
						Charge = 1,
						Key = key,
						ClientTimestamp = ts,
						Move = "Block"
					})
				end)
				pcall(function()
					Interact:InvokeServer({
						Charge = 1,
						Move = "Block",
						SpecialCharge = 0,
						TiltDirection = tilt,
						BallId = bid,
						MoveDirection = move,
						Key = key,
						From = "Client",
						LookVector = look,
						Timestamp = ts,
						ClientCanRunSpecial = false,
						CustomClient = {}
					})
				end)
				if UpdateTilt then
					pcall(function()
						UpdateTilt:InvokeServer(tilt)
					end)
				end
			end
		end

		if spikeOn() then
			if bid == 0 or not ball then
				if tick() - lastPrint > 1 then
					print("[SPIKE] No BID / ball found")
					lastPrint = tick()
				end
			elseif not Interact then
				if tick() - lastPrint > 1 then
					print("[SPIKE] Missing Interact remote")
					lastPrint = tick()
				end
			else
				if tick() - lastPrint > 1 then
					print("[SPIKE] Using BallId:", bid)
					lastPrint = tick()
				end
				local realTilt = Vector3.new(look.X, 1, look.Z)
				pcall(function()
					Interact:InvokeServer({
						Charge = 1,
						Move = "Spike",
						SpecialCharge = 0,
						TiltDirection = realTilt,
						LookVector = look,
						MoveDirection = move,
						ClientCanRunSpecial = false,
						From = "Client",
						Timestamp = ts,
						BallId = bid,
						CustomClient = {}
					})
				end)
				if UpdateTilt then
					pcall(function()
						UpdateTilt:InvokeServer(realTilt)
					end)
				end
			end
		end

		if jumpOn() and Jump then
			jumpState = not jumpState
			pcall(function()
				Jump:InvokeServer(jumpState)
			end)
		end

		task.wait(waitT)
	end
end)

local RequestJoin =
	RS.Packages._Index["sleitnick_knit@1.7.0"]
	.knit.Services.GameService.RF.RequestJoin

local ROUND_DELAY = 2
local joined = false

local function tryJoin()
        for pos = 1, 6 do
		if joined then return end
		pcall(function()
			RequestJoin:InvokeServer(1, pos)
		end)
	end
end
