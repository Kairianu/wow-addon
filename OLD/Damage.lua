local addonName, addonTable = ...


local DAMAGE_BUTTON_COLOR = addonTable.Color:GetColor("yellow")


local COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED"



local Damage = {}
addonTable.Damage = Damage



local DamageFrame = CreateFrame("Frame", nil, UIParent)

DamageFrame.damageButtonsFree = {}
DamageFrame.damageButtonsUsed = {}
DamageFrame.units = {}

DamageFrame:Hide()
DamageFrame:SetClampedToScreen(true)
DamageFrame:SetMovable(true)
DamageFrame:SetPoint("TopLeft", 10, -225)
DamageFrame:SetSize(200, 250)

DamageFrame.Background = DamageFrame:CreateTexture("Background")
DamageFrame.Background:SetAllPoints()
DamageFrame.Background:SetColorTexture(0, 0, 0, 0.4)

DamageFrame.TitleButton = CreateFrame("Button", nil, DamageFrame)
DamageFrame.TitleButton:SetPoint("Right")
DamageFrame.TitleButton:SetPoint("TopLeft")
DamageFrame.TitleButton:SetText("_")

DamageFrame.TitleButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 12)
DamageFrame.TitleButton:GetFontString():SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())

hooksecurefunc(DamageFrame.TitleButton, "SetText", function(self)
	self:SetHeight(self:GetFontString():GetHeight())
end)

DamageFrame.TitleButton:SetText("Damage")

DamageFrame.TitleButton:SetScript("OnMouseDown", function(self)
	self:GetParent():StartMoving()
end)

DamageFrame.TitleButton:SetScript("OnMouseUp", function(self)
	self:GetParent():StopMovingOrSizing()
end)

DamageFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, DamageFrame)
DamageFrame.ScrollFrame:SetPoint("BottomRight")
DamageFrame.ScrollFrame:SetPoint("Left")
DamageFrame.ScrollFrame:SetPoint("Top", DamageFrame.TitleButton, "Bottom")

DamageFrame.ScrollFrame:SetScrollChild(CreateFrame("Frame", nil, DamageFrame.ScrollFrame))

DamageFrame.ScrollFrame:SetScript("OnSizeChanged", function(self)
	self:GetScrollChild():SetSize(self:GetSize())
end)

DamageFrame.ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
	local verticalScroll = self:GetVerticalScroll() + (10 * -delta)

	verticalScroll = math.min(math.max(verticalScroll, 0), self:GetVerticalScrollRange())

	self:SetVerticalScroll(verticalScroll)
end)

function DamageFrame:AddAllUnits()
	self.units._blacklist = {}

	self:RegisterEvent(COMBAT_LOG_EVENT_UNFILTERED)
end

function DamageFrame:AddAllPlayerUnits()
	self.units._filter = function(sourceFlags)
		return bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) == COMBATLOG_OBJECT_AFFILIATION_MINE
	end

	self:RegisterEvent(COMBAT_LOG_EVENT_UNFILTERED)
end

function DamageFrame:AddUnit(unitName)
	if not unitName then
		return
	end

	local blacklist = self.units._blacklist

	if blacklist then
		blacklist[unitName] = nil
	end

	if not self.units[unitName] then
		table.insert(self.units, unitName)

		table.sort(self.units)

		self.units[unitName] = {
			damageAmount = 0,
		}

		self:AddDamageButton()
	end

	self:RegisterEvent(COMBAT_LOG_EVENT_UNFILTERED)

	addonTable.C_FrameHide:ShowFrame(self)
end

function DamageFrame:RemoveAllUnits()
	self:UnregisterEvent(COMBAT_LOG_EVENT_UNFILTERED)

	self.units._blacklist = nil

	for _, unitName in ipairs(self.units) do
		self:RemoveUnit(unitName)
	end
end

function DamageFrame:RemoveUnit(unitName)
	local blacklist = self.units._blacklist

	if blacklist then
		blacklist[unitName] = true
	end

	local DamageButton = self.units[unitName].DamageButton

	for unitIndex, savedUnitName in ipairs(self.units) do
		if savedUnitName == unitName then
			table.remove(self.units, unitIndex)

			break
		end
	end

	if #self.units == 0 then
		self:UnregisterEvent(COMBAT_LOG_EVENT_UNFILTERED)
	end

	self.units[unitName] = nil

	self:RemoveDamageButton(DamageButton)
end

function DamageFrame:AddDamageButton()
	local previousDamageButton

	for unitIndex, unitName in ipairs(self.units) do
		local unitInfo = self.units[unitName]

		local DamageButton = unitInfo.DamageButton

		if not DamageButton then
			DamageButton = self:GetDamageButton()

			unitInfo.DamageButton = DamageButton
		end

		DamageButton.FontStringLeft:SetText(unitName)
		DamageButton.FontStringRight:SetText(unitInfo.damageAmount)

		DamageButton:SetHeight(DamageButton.FontStringLeft:GetHeight())

		if previousDamageButton then
			DamageButton:SetPoint("Top", previousDamageButton, "Bottom")
		else
			DamageButton:SetPoint("Top")
		end

		DamageButton:SetScript("OnClick", function(self)
			unitInfo.damageAmount = 0

			self.FontStringRight:SetText(unitInfo.damageAmount)
		end)

		previousDamageButton = DamageButton
	end
end

function DamageFrame:CreateDamageButton()
	local DamageButton = CreateFrame("Button", nil, self.ScrollFrame:GetScrollChild())
	DamageButton:SetHeight(1)
	DamageButton:SetPoint("Left")
	DamageButton:SetPoint("Right")
	DamageButton:SetText("_")

	DamageButton.FontStringLeft = DamageButton:GetFontString()
	DamageButton.FontStringLeft:ClearAllPoints()
	DamageButton.FontStringLeft:SetFont(addonTable.Font:GetDefaultFontFamily(), 11)
	DamageButton.FontStringLeft:SetJustifyH("Left")
	DamageButton.FontStringLeft:SetPoint("Left")
	DamageButton.FontStringLeft:SetTextColor(DAMAGE_BUTTON_COLOR:GetRGB())

	DamageButton:SetText("")

	DamageButton.FontStringRight = DamageButton:CreateFontString()
	DamageButton.FontStringRight:SetFont(DamageButton.FontStringLeft:GetFont())
	DamageButton.FontStringRight:SetJustifyH("Right")
	DamageButton.FontStringRight:SetPoint("Bottom")
	DamageButton.FontStringRight:SetPoint("TopRight")
	DamageButton.FontStringRight:SetTextColor(DAMAGE_BUTTON_COLOR:GetRGB())

	return DamageButton
end

function DamageFrame:GetDamageButton()
	local DamageButton = table.remove(self.damageButtonsFree)

	if not DamageButton then
		DamageButton = self:CreateDamageButton()
	end

	table.insert(self.damageButtonsUsed, DamageButton)

	DamageButton:Show()

	return DamageButton
end

function DamageFrame:RemoveDamageButton(DamageButton)
	if not DamageButton then
		return
	end

	DamageButton:Hide()

	for damageButtonIndex, UsedDamageButton in ipairs(self.damageButtonsUsed) do
		if UsedDamageButton == DamageButton then
			table.remove(self.damageButtonsUsed, damageButtonIndex)

			break
		end
	end

	table.insert(self.damageButtonsFree, DamageButton)
end

DamageFrame:SetScript("OnEvent", function(self)
	local combatTimestamp, combatEvent, hiddenSourceUnit, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destinationGUID, destinationName, destinationFlags, destinationRaidFlags = CombatLogGetCurrentEventInfo()

	local autoAddUnit = false
	local blacklist = self.units._blacklist
	local filter = self.units._filter
	local unitInfo = self.units[sourceName]

	if filter then
		if filter(sourceFlags) then
			autoAddUnit = true
		else
			return
		end
	elseif blacklist then
		if blacklist[unitName] then
			return
		end

		if not unitInfo then
			autoAddUnit = true
		end
	end

	if not autoAddUnit and not unitInfo then
		return
	end

	local totalDamageAmount = 0

	if unitInfo then
		totalDamageAmount = totalDamageAmount + unitInfo.damageAmount
	end

	if combatEvent:find("_DAMAGE$") then
		local spellID, spellName, spellSchool, damageAmount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

		if combatEvent:find("^SWING_") then
			damageAmount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
		elseif combatEvent:find("^RANGE_") or combatEvent:find("^SPELL_") then
			spellID, spellName, spellSchool, damageAmount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
		end

		totalDamageAmount = totalDamageAmount + damageAmount
	end

	if autoAddUnit and totalDamageAmount > 0 then
		self:AddUnit(sourceName)

		unitInfo = self.units[sourceName]
	end

	if unitInfo then
		unitInfo.damageAmount = totalDamageAmount

		local DamageButton = unitInfo.DamageButton

		if DamageButton then
			DamageButton.FontStringRight:SetText(unitInfo.damageAmount)
		end
	end

	self:Show()

	addonTable.C_FrameHide:ShowFrame(self)
end)


addonTable.C_FrameHide:SetupFrame(DamageFrame)



SLASH_ADD_UNIT_DAMAGE1 = "/damage"
SLASH_ADD_UNIT_DAMAGE2 = "/dmg"
SlashCmdList["ADD_UNIT_DAMAGE"] = function(argString)
	local args = {}

	for arg in string.gmatch(argString, "[^%s]+") do
		table.insert(args, arg)
	end

	local command = args[1]
	local unitName = args[2]

	if command == "p" or command == "player" then
		DamageFrame:AddAllPlayerUnits()
	elseif command == "r" or command == "remove" then
		if not unitName then
			DamageFrame:RemoveAllUnits()
		else
			DamageFrame:RemoveUnit(unitName)
		end
	else
		unitName = command

		if not unitName then
			DamageFrame:AddAllUnits()
		else
			DamageFrame:AddUnit(unitName)
		end
	end
end
