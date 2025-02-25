local addonName, addonTable = ...


local TalentSavedVariables = addonTable.TalentSavedVariables


-- C_SpellBook
-- C_SpecializationInfo
-- /tc _G ^GetSpell


local Talent = {}
addonTable.Talent = Talent

function Talent:UpdateTalentTooltips()
	local configID = C_ClassTalents.GetActiveConfigID()

	if not configID then
		return
	end

	local configInfo = C_Traits.GetConfigInfo(configID)

	for _, treeID in ipairs(configInfo.treeIDs) do
		local treeNodes = C_Traits.GetTreeNodes(treeID)

		for _, nodeID in ipairs(treeNodes) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)

			for _, entryID in ipairs(nodeInfo.entryIDs) do
				local entryInfo = C_Traits.GetEntryInfo(configID, entryID)

				if entryInfo and entryInfo.definitionID then
					local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)

					if definitionInfo.spellID then
						TalentSavedVariables:UpdateSpellData(definitionInfo.spellID)
					end
				end
			end
		end
	end
end

C_Timer.After(2, function()
	-- Talent:UpdateTalentTooltips()
end)


local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
EventFrame:RegisterEvent("PLAYER_LEVEL_UP")
function EventFrame:OnEvent(event)
	if event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
		-- Talent:UpdateTalentTooltips()
	end

	self:SetScript("OnEvent", nil)

	C_Timer.After(2, function()
		self:SetScript("OnEvent", self.OnEvent)
	end)
end

EventFrame:SetScript("OnEvent", EventFrame.OnEvent)





EventRegistry:RegisterCallback("TalentDisplay.TooltipCreated", function(ownerID, TalentButton, TooltipFrame)
	local spellDescription, spellDescriptionPvP = TalentSavedVariables:GetSpellDescription(TalentButton:GetSpellID())
	local descriptionHeader
	local descriptionOutput

	if TalentSavedVariables:IsPvPItemLevelActive() then
		if spellDescription then
			descriptionOutput = spellDescription
			descriptionHeader = "Normal"
		end
	else
		if spellDescriptionPvP then
			descriptionHeader = "PvP"
			descriptionOutput = spellDescriptionPvP
		end
	end

	if descriptionOutput then
		TooltipFrame:AddLine("\n")
		TooltipFrame:AddLine(descriptionHeader, 1, 1, 1)
		TooltipFrame:AddLine(descriptionOutput, nil, nil, nil, true)
		TooltipFrame:Show()
	end
end)
