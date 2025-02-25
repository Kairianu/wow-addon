local addonName, addonData = ...

local function IsUnitRare(unitToken)
	local unitClassification = UnitClassification(unitToken)

	if unitClassification == "rare" or unitClassification == "rareelite" then
		return true
	end

	return false
end



local Scanner = CreateFrame("button", nil, UIParent)

Scanner.events = {
	"NAME_PLATE_UNIT_ADDED",
	"UPDATE_MOUSEOVER_UNIT",
}

Scanner:Hide()
Scanner:SetPoint("topleft", 200, -200)
Scanner:SetSize(350, 350)

Scanner:SetText("-")
Scanner:GetFontString():SetFont(addonData.Font:GetDefaultFont())
Scanner:GetFontString():SetPoint("bottomright")
Scanner:GetFontString():SetPoint("left")
Scanner:GetFontString():SetTextColor(addonData.Color:GetColor("yellow"):GetRGB())
Scanner:SetText("")

Scanner.Model = CreateFrame("DressUpModel", nil, Scanner)
Scanner.Model:SetAllPoints()

-- Scanner.Model:SetScript("OnUpdate", function(self, elapsed)
-- 	self:SetFacing(self:GetFacing() + elapsed * 0.1)
-- end)

function Scanner:AddFilter(filter)
	if type(self.filters) ~= "table" then
		self.filters = {}
	end

	table.insert(self.filters, filter)
end

function Scanner:ClearFilters()
	self.filters = nil
end

function Scanner:SetUnitModel(unitToken)
	local text = UnitName(unitToken) or ""

	if self.Model:CanSetUnit(unitToken) then
		self.Model:SetUnit(unitToken)
	else
		local unitGUID = UnitGUID(unitToken)

		if unitGUID then
			if unitGUID:match("^Creature-") then
				local creatureID = select(6, strsplit("-", unitGUID))

				self.Model:SetCreature(creatureID)
			end
		end
	end

	if UnitIsDead(unitToken) then
		text = "* " .. text .. " (Dead)"
	end

	self:SetText(text)
	self:Show()

	return true
end

function Scanner:CheckUnitToken(unitToken)
	local filters = self.filters

	if filters then
		for _, filter in ipairs(filters) do
			if type(filter) == "function" then
				if filter(unitToken) then
					self:SetUnitModel(unitToken)

					return true
				end
			else
				local unitName = UnitName(unitToken)

				if unitName then
					if string.match(string.lower(unitName), string.lower(filter)) then
						self:SetUnitModel(unitToken)

						return true
					end
				end
			end
		end
	end

	return false
end

function Scanner:RegisterEvents()
	if UnitAffectingCombat("player") then
		return
	end

	for _, event in ipairs(self.events) do
		self:RegisterEvent(event)
	end
end

function Scanner:UnregisterEvents()
	for _, event in ipairs(self.events) do
		self:UnregisterEvent(event)
	end
end



Scanner:SetScript("OnClick", function(self)
	self:Hide()
end)

Scanner:RegisterEvent("PLAYER_REGEN_DISABLED")
Scanner:RegisterEvent("PLAYER_REGEN_ENABLED")
Scanner:RegisterEvents()
Scanner:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_REGEN_DISABLED" then
		-- self:UnregisterEvents()
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- self:RegisterEvents()
	else
		if event == "NAME_PLATE_UNIT_ADDED" then
			self:CheckUnitToken(arg1)
		elseif event == "UPDATE_MOUSEOVER_UNIT" then
			self:CheckUnitToken("mouseover")
		end
	end
end)



Scanner:AddFilter(IsUnitRare)



SLASH_SCAN1 = "/scan"
SlashCmdList["SCAN"] = function(filterString)
	if string.match(filterString, "^%s*$") then
		return
	end

	if filterString == "CLEAR" then
		Scanner:ClearFilters()

		return
	end

	local filters = { strsplit(",", filterString) }

	for _, filter in ipairs(filters) do
		filter = strtrim(filter)

		if filter == "RARE" then
			filter = IsUnitRare
		end

		Scanner:AddFilter(filter)
	end
end


--[[
	self.Model:SetUnit("player")
	self.Model:SetDisplayInfo()
	self.Model:SetItem(218357)
	self.Model:SetItemAppearance()
	self.Model:SetItemTransmogInfo()
	self.Model:SetModel()
	self.Model:TransformCameraSpaceToModelSpace()
	self.Model:ZeroCachedCenterXY()
]]
