local addonName, addonTable = ...


local DragonridingRaceTimerFrame = CreateFrame("Button", nil, EncounterBar)
DragonridingRaceTimerFrame:SetPoint("Bottom", EncounterBar, "Top")
DragonridingRaceTimerFrame:SetSize(100, 25)

DragonridingRaceTimerFrame.Text = DragonridingRaceTimerFrame:CreateFontString()
DragonridingRaceTimerFrame.Text.defaultText = "0.000"
DragonridingRaceTimerFrame.Text:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(1.2), "Outline")
DragonridingRaceTimerFrame.Text:SetPoint("Bottom", 0, 10)
DragonridingRaceTimerFrame.Text:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

DragonridingRaceTimerFrame.onUpdateElapsed = 0
DragonridingRaceTimerFrame.onUpdateTimeout = 0.1
function DragonridingRaceTimerFrame:OnUpdate(elapsed)
	self.onUpdateElapsed = self.onUpdateElapsed + elapsed

	if self.onUpdateElapsed < self.onUpdateTimeout then
		return
	end

	self.onUpdateElapsed = 0

	self:SetRaceTimeText()
end

function DragonridingRaceTimerFrame:SetRaceTimeText()
	if not self.raceStartTime then
		return
	end

	local raceTime = math.floor((GetTimePreciseSec() - self.raceStartTime) * 1000) / 1000

	local raceTimeText = tostring(raceTime)

	local raceTimeTextLength = string.len(raceTimeText)
	local raceTimeTextMinLength = 5

	if raceTimeTextLength < raceTimeTextMinLength then
		raceTimeText = raceTimeText .. string.rep("0", raceTimeTextMinLength - raceTimeTextLength)
	end

	self.Text:SetText(raceTimeText)
end

function DragonridingRaceTimerFrame:CheckAuras(auraUpdateInfo)
	if auraUpdateInfo.addedAuras then
		for i, auraData in ipairs(auraUpdateInfo.addedAuras) do
			if auraData.name == "Race Starting" then
				self.raceStartingAuraInstanceID = auraData.auraInstanceID
				self.raceStartTime = nil

				self:SetScript("OnUpdate", nil)

				self.Text:SetText(self.Text.defaultText)
			elseif auraData.spellId == 369968 then
				self.racingAuraInstanceID = auraData.auraInstanceID
			end
		end
	end

	if self.raceStartingAuraInstanceID or self.racingAuraInstanceID then
		if auraUpdateInfo.removedAuraInstanceIDs then
			for i, auraInstanceID in ipairs(auraUpdateInfo.removedAuraInstanceIDs) do
				if auraInstanceID == self.raceStartingAuraInstanceID then
					self.raceStartingAuraInstanceID = nil
					self.raceStartTime = GetTimePreciseSec()

					self:Show()

					self:SetScript("OnUpdate", self.OnUpdate)
				elseif auraInstanceID == self.racingAuraInstanceID then
					self.racingAuraInstanceID = nil

					self:SetScript("OnUpdate", nil)

					self:SetRaceTimeText()

					self.raceStartTime = nil
				end
			end
		end
	end
end

DragonridingRaceTimerFrame:SetScript("OnClick", function(self)
	if not self.raceStartingAuraInstanceID and not self.raceStartTime then
		self:Hide()
	end
end)

-- DragonridingRaceTimerFrame:RegisterEvent("FIRST_FRAME_RENDERED")
DragonridingRaceTimerFrame:RegisterEvent("UNIT_AURA")
DragonridingRaceTimerFrame:SetScript("OnEvent", function(self, event, unitToken, auraUpdateInfo)
	if event == "UNIT_AURA" then
		if unitToken == "player" then
			self:CheckAuras(auraUpdateInfo)
		end
	end
end)
