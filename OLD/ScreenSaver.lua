local addonName, addonTable = ...


local FISHING_CHANNEL_SPELL_ID = 131476


local C_ScreenSaver = {}
addonTable.C_ScreenSaver = C_ScreenSaver

C_ScreenSaver.enabled = true
C_ScreenSaver.moveMethods = {
	MoveViewLeftStart,
	MoveViewRightStart,
}

function C_ScreenSaver:Disable()
	self.enabled = false
end

function C_ScreenSaver:Enable()
	self.enabled = true
end

function C_ScreenSaver:IsEnabled()
	return self.enabled
end

function C_ScreenSaver:Start(speed)
	if not self.enabled then
		return
	end

	local moveMethod = self.moveMethods[math.random(#self.moveMethods)]

	moveMethod(speed or addonTable.Math:Random(0.03, 0.01))
end

function C_ScreenSaver:Stop()
	MoveViewLeftStop()
	MoveViewRightStop()
end

function C_ScreenSaver:ToggleEnabled()
	self.enabled = not self.enabled
end


local EventFrame = CreateFrame("EventFrame")

EventFrame.elapsedTimeout = 60

EventFrame.OnUpdate = function(self, elapsed)
	self.elapsedTotal = (self.elapsedTotal or 0) + elapsed

	if self.elapsedTotal >= self.elapsedTimeout then
		C_ScreenSaver:Start()

		self:SetScript("OnUpdate", nil)
	end
end

EventFrame:RegisterEvent("PLAYER_STARTED_MOVING")
EventFrame:RegisterEvent("PLAYER_STARTED_TURNING")
EventFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
EventFrame:RegisterEvent("PLAYER_STOPPED_TURNING")
EventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
EventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
	if
		event == "PLAYER_STARTED_MOVING"
		or event == "PLAYER_STARTED_TURNING"
		or (event == "UNIT_SPELLCAST_CHANNEL_START" and arg3 == FISHING_CHANNEL_SPELL_ID)
	then
		self:SetScript("OnUpdate", nil)
		C_ScreenSaver:Stop()
	elseif
		event == "PLAYER_STOPPED_MOVING"
		or event == "PLAYER_STOPPED_TURNING"
		or (event == "UNIT_SPELLCAST_CHANNEL_STOP" and arg3 == FISHING_CHANNEL_SPELL_ID)
	then
		self.elapsedTotal = 0
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end)

EventFrame:SetScript("OnUpdate", EventFrame.OnUpdate)



SLASH_SCREENSAVER1 = "/ss"
SlashCmdList["SCREENSAVER"] = function()
	C_ScreenSaver:ToggleEnabled()

	local message

	if C_ScreenSaver:IsEnabled() then
		message = "|cff00ff00Screensaver Enabled|r"
	else
		message = "|cffff0000Screensaver Disabled|r"
	end

	DEFAULT_CHAT_FRAME:AddMessage(message)
end
