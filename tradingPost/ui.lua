local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection("tradingPost"):AddMixin("ui", function()
	local TradingPostUI = CreateFrame("Frame")

	TradingPostUI:RegisterEvent("ADDON_LOADED")
	TradingPostUI:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" then
			if arg1 == "Blizzard_PerksProgram" then
				EventRegistry:RegisterCallback("PerksProgramFrame.PerksProductSelected", function(...)
					C_Timer.After(0, function()
						local attackAnimationButton = PerksProgramFrame.FooterFrame.ToggleAttackAnimation

						if attackAnimationButton:IsShown() then
							if attackAnimationButton:GetChecked() then
								attackAnimationButton:Click()
							end
						end

						local mountSpecialButton = PerksProgramFrame.FooterFrame.ToggleMountSpecial

						if mountSpecialButton:IsShown() then
							if mountSpecialButton:GetChecked() then
								mountSpecialButton:Click()
							end
						end
					end)
				end)
			end
		end
	end)
end)
