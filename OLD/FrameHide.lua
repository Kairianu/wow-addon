local addonName, addonTable = ...


local function ValidateAlphaNumber(value, default)
	if type(value) ~= "number" then
		return default
	end

	if value < 0 then
		value = 0
	elseif value > 1 then
		value = 1
	end

	return value
end

local function ValidatePositiveNumber(value, default)
	if type(value) == "number" and value >= 0 then
		return value
	end

	return default
end

local function ValidateBoolean(value, default)
	if type(value) ~= "boolean" then
		return default
	end

	return value
end







local AnimationEventFrameMetatable = {
	hiddenAlpha = 0,
	hideDuration = 2,
	hideOnFinish = false,
	hideTimeout = 8,
	OnUpdateHandlers = {},
	showDuration = 0.25,
	shownAlpha = 1,
}

function AnimationEventFrameMetatable:Initialize(visualFrame, options)
	self.shownAlpha = visualFrame:GetAlpha()
	self.visualFrame = visualFrame

	if type(options) == "table" then
		self.hiddenAlpha = ValidateAlphaNumber(options.hiddenAlpha, self.hiddenAlpha)
		self.hideDuration = ValidatePositiveNumber(options.hideDuration, self.hideDuration)
		self.hideOnFinish = ValidateBoolean(options.hideOnFinish, self.hideOnFinish)
		self.hideTimeout = ValidatePositiveNumber(options.hideTimeout, self.hideTimeout)
		self.showDuration = ValidatePositiveNumber(options.showDuration, self.showDuration)
		self.shownAlpha = ValidateAlphaNumber(options.shownAlpha, self.shownAlpha)
	end

	self:SetScript("OnUpdate", self.OnUpdate)

	self:ShowVisualFrame()
end

function AnimationEventFrameMetatable:OnUpdate(elapsed)
	if MouseIsOver(self.visualFrame) then
		self:ShowVisualFrame(self.keepShown)
	end

	if self.animationHandler then
		self.animationHandler(self, elapsed)
	end
end

function AnimationEventFrameMetatable:IsVisualFrameFullyShown()
	if self.visualFrame:GetAlpha() >= self.shownAlpha then
		return true
	end

	return false
end

function AnimationEventFrameMetatable:IsVisualFrameFullyHidden()
	if self.visualFrame:GetAlpha() <= self.hiddenAlpha then
		return true
	end

	return false
end

function AnimationEventFrameMetatable:HideVisualFrame()
	self:SetAnimationHandler(self.Animation_Hide)
end

function AnimationEventFrameMetatable:ShowVisualFrame(keepShown)
	self.keepShown = keepShown

	self:SetAnimationHandler(self.Animation_Show)
end

function AnimationEventFrameMetatable:SetAnimationHandler(handler)
	if handler == self.animationHandler then
		return
	end

	if handler == self.Animation_HideTimeout then
		self.hideTimeoutDuration = 0
	else
		local alphaPercent = self.visualFrame:GetAlpha() / self.shownAlpha

		if handler == self.Animation_Hide then
			self.hideDurationElapsed = self.hideDuration * ( 1 - alphaPercent )
		elseif handler == self.Animation_Show then
			if self.hideOnFinish then
				self.visualFrame:Show()
			end

			self.showDurationElapsed = self.showDuration * alphaPercent
		end
	end

	self.animationHandler = handler
end

function AnimationEventFrameMetatable:Animation_HideTimeout(elapsed)
	self.hideTimeoutDuration = self.hideTimeoutDuration + elapsed

	if self.hideTimeoutDuration >= self.hideTimeout then
		self:HideVisualFrame()
	end
end

function AnimationEventFrameMetatable:Animation_Show(elapsed)
	self.showDurationElapsed = self.showDurationElapsed + elapsed

	if self:IsVisualFrameFullyShown() then
		if self.keepShown then
			self:SetAnimationHandler(nil)
		else
			self:SetAnimationHandler(self.Animation_HideTimeout)
		end
	else
		self:SetVisualFrameAlpha(self.shownAlpha * self.showDurationElapsed / self.showDuration)
	end
end

function AnimationEventFrameMetatable:Animation_Hide(elapsed)
	self.hideDurationElapsed = self.hideDurationElapsed + elapsed

	if self:IsVisualFrameFullyHidden() then
		self:SetAnimationHandler(nil)

		if self.hideOnFinish then
			self.visualFrame:Hide()
		end
	else
		self:SetVisualFrameAlpha(self.shownAlpha * ( 1 - self.hideDurationElapsed / self.hideDuration ))
	end
end

function AnimationEventFrameMetatable:SetVisualFrameAlpha(alpha)
	if alpha < self.hiddenAlpha then
		alpha = self.hiddenAlpha
	elseif alpha > self.shownAlpha then
		alpha = self.shownAlpha
	end

	self.visualFrame:SetAlpha(alpha)
end




local AnimationEventFrameCreator = {
	frames = {},
}

function AnimationEventFrameCreator:Add(animationEventFrame)
	self.frames[animationEventFrame.visualFrame] = animationEventFrame
end

function AnimationEventFrameCreator:Get(visualFrame)
	return self.frames[visualFrame]
end

function AnimationEventFrameCreator:AddMetatable(frame, metatable)
	local metatable = {
		__index = function(self, key)
			for i, metatable in ipairs(getmetatable(self).metatables) do
				local value = metatable[key]

				if value ~= nil then
					return value
				end
			end
		end,

		metatables = {
			metatable,
			getmetatable(frame).__index,
		},
	}

	setmetatable(frame, metatable)
end

function AnimationEventFrameCreator:New(...)
	local frame = CreateFrame("EventFrame")

	self:AddMetatable(frame, AnimationEventFrameMetatable)

	frame:Initialize(...)

	self:Add(frame)

	return frame
end














local C_FrameHide = {}
addonTable.C_FrameHide = C_FrameHide

function C_FrameHide:SetupFrame(...)
	AnimationEventFrameCreator:New(...)
end

function C_FrameHide:ShowFrame(visualFrame, ...)
	local animationEventFrame = AnimationEventFrameCreator:Get(visualFrame)

	if animationEventFrame then
		animationEventFrame:ShowVisualFrame(...)
	end
end

function C_FrameHide:HideFrame(visualFrame)
	local animationEventFrame = AnimationEventFrameCreator:Get(visualFrame)

	if animationEventFrame then
		animationEventFrame:HideVisualFrame()
	end
end

















local LoadEventFrame = CreateFrame("EventFrame")
LoadEventFrame:RegisterEvent("FIRST_FRAME_RENDERED")

LoadEventFrame:SetScript("OnEvent", function(self, event)
	if event == "FIRST_FRAME_RENDERED" then
		self:SetupActionBars()
		self:SetupBags()
		self:SetupBuffs()
		self:SetupChat()
		self:SetupMinimap()
		self:SetupQuestTracker()
		self:SetupTomTom()
	end
end)

function LoadEventFrame:SetupActionBars()
	local actionBars = {
		MainMenuBar,
		MultiBar5,
		MultiBar6,
		MultiBar7,
		MultiBarBottomLeft,
		MultiBarBottomRight,
		MultiBarLeft,
		MultiBarRight,
		PetActionBar,
	}

	for i=1,10 do
		if _G["StanceButton" .. i]:HasAction() then
			table.insert(actionBars, StanceBar)
			break
		end
	end

	local combatFrames = {
		PlayerFrame,

		unpack(actionBars),
	}

	local CombatEventFrame = CreateFrame("EventFrame")

	for i, combatFrame in ipairs(combatFrames) do
		C_FrameHide:SetupFrame(combatFrame)

		combatFrame:HookScript("OnEnter", function()
			CombatEventFrame:ShowActionBars(AnimationEventFrameCreator:Get(combatFrame).keepShown)
		end)
	end

	function CombatEventFrame:ShowActionBars(...)
		for i, actionBar in ipairs(actionBars) do
			C_FrameHide:ShowFrame(actionBar, ...)
		end
	end

	function CombatEventFrame:ShowCombatFrames(...)
		for i, combatFrame in ipairs(combatFrames) do
			C_FrameHide:ShowFrame(combatFrame, ...)
		end
	end

	CombatEventFrame:RegisterEvent("ADDON_LOADED")
	CombatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	CombatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	CombatEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	CombatEventFrame:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" then
			if arg1 == "Blizzard_ClassTalentUI" then
				ClassTalentFrame:HookScript("OnShow", function()
					self:ShowActionBars(true)
				end)

				ClassTalentFrame:HookScript("OnHide", function()
					self:ShowActionBars()
				end)
			elseif arg1 == "Blizzard_PlayerSpells" then
				PlayerSpellsFrame.SpellBookFrame:HookScript("OnShow", function()
					self:ShowActionBars(true)
				end)

				PlayerSpellsFrame.SpellBookFrame:HookScript("OnHide", function()
					self:ShowActionBars()
				end)
			end
		elseif event == "PLAYER_REGEN_DISABLED" then
			self:ShowCombatFrames(true)
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:ShowCombatFrames()
		elseif event == "PLAYER_TARGET_CHANGED" then
			self:ShowCombatFrames(UnitExists("target"))
		end
	end)

	-- CombatEventFrame:SetScript("OnUpdate", function(self, elapsed)
	-- 	for i, combatFrame in ipairs(combatFrames) do
	-- 		if MouseIsOver(combatFrame) then
	-- 			self:ShowCombatFrames()
	-- 			break
	-- 		end
	-- 	end
	-- end)
end

function LoadEventFrame:SetupBags()
	C_FrameHide:SetupFrame(BagsBar)
	C_FrameHide:SetupFrame(MicroMenu)

	C_FrameHide:SetupFrame(QueueStatusButton, {
		hiddenAlpha = 0.4,
	})
end

function LoadEventFrame:SetupBuffs()
	C_FrameHide:SetupFrame(BuffFrame)

	local BuffEventFrame = CreateFrame("EventFrame")
	BuffEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	BuffEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	BuffEventFrame:RegisterEvent("UNIT_AURA")

	BuffEventFrame.auraEventKeys = {
		"addedAuras",
		"removedAuraInstanceIDs",
		"updatedAuraInstanceIDs",
	}

	BuffEventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
		if event == "PLAYER_REGEN_DISABLED" then
			C_FrameHide:ShowFrame(BuffFrame, true)
		elseif event == "PLAYER_REGEN_ENABLED" then
			C_FrameHide:ShowFrame(BuffFrame)
		elseif event == "UNIT_AURA" then
			if arg1 == "player" then
				if UnitAffectingCombat(arg1) then
					return
				end

				for i, auraEventKey in ipairs(self.auraEventKeys) do
					if arg2[auraEventKey] then
						C_FrameHide:ShowFrame(BuffFrame)
						break
					end
				end
			end
		end
	end)
end

function LoadEventFrame:SetupChat()
	C_FrameHide:SetupFrame(ChatFrame1, {
		hideTimeout = 15,
	})

	C_FrameHide:SetupFrame(ChatFrame1ButtonFrame)
	C_FrameHide:SetupFrame(ChatFrame1EditBox)
	C_FrameHide:SetupFrame(GeneralDockManager)
	C_FrameHide:SetupFrame(QuickJoinToastButton)

	hooksecurefunc(DEFAULT_CHAT_FRAME, "AddMessage", function()
		C_FrameHide:ShowFrame(ChatFrame1)
	end)

	ChatFrame1EditBox:HookScript("OnEditFocusGained", function(self)
		C_FrameHide:ShowFrame(self, true)
	end)

	ChatFrame1EditBox:HookScript("OnEditFocusLost", function(self)
		C_FrameHide:ShowFrame(self)
	end)
end

function LoadEventFrame:SetupMinimap()
	C_FrameHide:SetupFrame(MinimapCluster, {
		hideOnFinish = true,
	})

	local MinimapEventFrame = CreateFrame("EventFrame")

	MinimapEventFrame.onUpdateElapsed = 0
	MinimapEventFrame.onUpdateInterval = 0.25

	MinimapEventFrame:SetScript("OnUpdate", function(self, elapsed)
		self.onUpdateElapsed = self.onUpdateElapsed + elapsed

		if self.onUpdateElapsed < self.onUpdateInterval then
			return
		else
			self.onUpdateElapsed = 0
		end

		if IsPlayerMoving() or C_PlayerInfo.GetGlidingInfo() then
			C_FrameHide:ShowFrame(MinimapCluster, true)
		else
			C_FrameHide:ShowFrame(MinimapCluster)
		end
	end)
end

function LoadEventFrame:SetupQuestTracker()
	C_FrameHide:SetupFrame(ObjectiveTrackerFrame, {
		hiddenAlpha = 0.4,
	})
end

function LoadEventFrame:SetupTomTom()
	if TomTomBlock then
		C_FrameHide:SetupFrame(TomTomBlock)

		local TomTomEventFrame = CreateFrame("EventFrame")
		TomTomEventFrame:RegisterEvent("PLAYER_STARTED_MOVING")
		TomTomEventFrame:RegisterEvent("PLAYER_STOPPED_MOVING")

		TomTomEventFrame:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_STARTED_MOVING" then
				C_FrameHide:ShowFrame(TomTomBlock, true)
			elseif event == "PLAYER_STOPPED_MOVING" then
				C_FrameHide:ShowFrame(TomTomBlock)
			end
		end)
	end
end
