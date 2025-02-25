local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection("dressingRoom"):AddMixin("ui", function()
	local UndressButton = CreateFrame("Button", nil, DressUpFrame, "UIPanelButtonTemplate")
	UndressButton:SetPoint("Bottom", DressUpFrame.LinkButton)
	UndressButton:SetPoint("TopLeft", DressUpFrame.LinkButton, "TopRight")
	UndressButton:SetText("Undress")
	UndressButton:SetWidth(80)

	UndressButton:SetScript("OnClick", function()
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor()

		if playerActor then
			playerActor:Undress()
		end
	end)
end)
