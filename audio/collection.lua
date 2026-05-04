local addonName, addonData = ...


addonData.CollectionsAPI:CreateCollection('audio')













local function GetPercentageString(value)
	-- TODO: [import] use own math rounding method
	local roundedPercentageValue = math.floor((value * 1000) + 0.5) / 10

	-- if roundedPercentageValue % 1 == 0 then
	-- 	roundedPercentageValue = roundedPercentageValue .. '.0'
	-- end

	return roundedPercentageValue .. '%'
end





local AudioAPI = {
	exponentialConstant = 2.5,
}

function AudioAPI:GetLinearVolume(value)
	return math.exp(math.log(value) / self.exponentialConstant)
end

function AudioAPI:GetModifiedVolume(value)
	return value ^ self.exponentialConstant
end





local AudioUI = CreateFrame('Frame', addonName .. '_AudioUI', UIParent)

AudioUI.masterVolumeCVarName = 'Sound_MasterVolume'
AudioUI.onUpdate_fadeTimeout = 0.8
AudioUI.onUpdate_keyInitialTimeout = 0.3
AudioUI.onUpdate_keyRepeatTimeout = 0.08
AudioUI.onUpdate_timeout = 3
AudioUI.volumeOffset = 0.05

-- Delayed registration of CVAR_UPDATE event as to not capture own cvar change.
function AudioUI:DelayRegisterCvarUpdateEvent()
	C_Timer.After(0, function()
		self:RegisterEvent('CVAR_UPDATE')
	end)
end

function AudioUI:OnEvent(eventName, ...)
	if eventName == 'CVAR_UPDATE' then
		self:OnEvent_CVarUpdate(...)
	elseif eventName == 'PLAYER_ENTERING_WORLD' then
		self:OnEvent_PlayerEnteringWorld(...)
	elseif eventName == 'PLAYER_LOGOUT' then
		self:OnEvent_PlayerLogout(...)
	end
end

function AudioUI:OnEvent_CVarUpdate(cvarName, cvarValue)
	if cvarName == self.masterVolumeCVarName then
		local masterVolumeCVarValue = tonumber(cvarValue)

		local volumeDelta = 1

		if masterVolumeCVarValue < self.modifiedMasterVolume then
			volumeDelta = -1
		end

		self:SetMasterVolumeByDelta(volumeDelta)

		self:OnUpdate_Initialize()

		self:SetAlpha(1)

		self:Show()
	end
end

function AudioUI:OnEvent_PlayerEnteringWorld()
	local linearMasterVolume = tonumber(C_CVar.GetCVar(self.masterVolumeCVarName))

	local modifiedMasterVolume = AudioAPI:GetModifiedVolume(linearMasterVolume)

	C_CVar.SetCVar(self.masterVolumeCVarName, modifiedMasterVolume)

	self.modifiedMasterVolume = modifiedMasterVolume

	self:RegisterEvent('PLAYER_LOGOUT')

	self:DelayRegisterCvarUpdateEvent()
end

function AudioUI:OnEvent_PlayerLogout()
	self:UnregisterEvent('CVAR_UPDATE')

	local linearMasterVolume = AudioAPI:GetLinearVolume(self.modifiedMasterVolume)

	C_CVar.SetCVar(self.masterVolumeCVarName, linearMasterVolume)
end

function AudioUI:OnUpdate(elapsed)
	local isMasterVolumeDownKeyPressed = IsKeyDown(self.onUpdate_masterVolumeDownKey)
	local isMasterVolumeUpKeyPressed = IsKeyDown(self.onUpdate_masterVolumeUpKey)

	if isMasterVolumeDownKeyPressed or isMasterVolumeUpKeyPressed then
		self.onUpdate_keyElapsed = self.onUpdate_keyElapsed + elapsed

		if self.onUpdate_keyElapsed >= self.onUpdate_keyTimeout then
			local volumeDelta = 1

			if isMasterVolumeDownKeyPressed then
				volumeDelta = -1
			end

			self:SetMasterVolumeByDelta(volumeDelta)

			self.onUpdate_keyElapsed = 0
			self.onUpdate_keyTimeout = self.onUpdate_keyRepeatTimeout
		end

		return
	end


	self.onUpdate_elapsed = self.onUpdate_elapsed + elapsed

	if self.onUpdate_elapsed < self.onUpdate_timeout then
		return
	end

	self.onUpdate_fadeElapsed = self.onUpdate_fadeElapsed + elapsed

	local alpha = 1 - (self.onUpdate_fadeElapsed / self.onUpdate_fadeTimeout)

	if alpha < 0 then
		alpha = 0
	elseif alpha > 1 then
		alpha = 1
	end

	self:SetAlpha(alpha)

	if alpha == 0 then
		self:Hide()

		self:OnUpdate_Initialize()
	end
end

function AudioUI:OnUpdate_Initialize()
	self.onUpdate_elapsed = 0
	self.onUpdate_fadeElapsed = 0

	self.onUpdate_keyElapsed = 0
	self.onUpdate_keyTimeout = self.onUpdate_keyInitialTimeout
	self.onUpdate_masterVolumeDownKey = GetBindingKey('MASTERVOLUMEDOWN')
	self.onUpdate_masterVolumeUpKey = GetBindingKey('MASTERVOLUMEUP')
end

function AudioUI:SetMasterVolume(linearVolume)
	self:UnregisterEvent('CVAR_UPDATE')

	if linearVolume < 0 then
		linearVolume = 0
	elseif linearVolume > 1 then
		linearVolume = 1
	end

	local modifiedVolume = AudioAPI:GetModifiedVolume(linearVolume)

	C_CVar.SetCVar(self.masterVolumeCVarName, modifiedVolume)

	self.modifiedMasterVolume = modifiedVolume


	local linearVolumePercentageString = GetPercentageString(linearVolume)

	self.VolumeFontString:SetText('Volume: ' .. linearVolumePercentageString)

	self:SetSize(self.VolumeFontString:GetSize())


	self:DelayRegisterCvarUpdateEvent()
end

function AudioUI:SetMasterVolumeByDelta(delta)
	local volumeOffset = self.volumeOffset * delta

	local linearVolume = AudioAPI:GetLinearVolume(self.modifiedMasterVolume)

	local newLinearVolume = linearVolume + volumeOffset

	self:SetMasterVolume(newLinearVolume)
end

function AudioUI:SetupUI()
	self:Hide()
	self:SetPoint('Top', 0, -100)
	self:SetSize(1, 1)

	local AudioPercentageText = self:CreateFontString()
	self.VolumeFontString = AudioPercentageText
	AudioPercentageText:SetPoint('Center')
	AudioPercentageText:SetFont('Fonts/blei00d.ttf', 30, 'OUTLINE')
	AudioPercentageText:SetTextColor(1, 0.82, 0)

	self:SetScript('OnUpdate', self.OnUpdate)
end



AudioUI:SetupUI()

AudioUI:RegisterEvent('PLAYER_ENTERING_WORLD')
AudioUI:SetScript('OnEvent', AudioUI.OnEvent)
