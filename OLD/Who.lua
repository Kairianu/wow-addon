local addonName, addonTable = ...


local FOUND_PLAYERS = {
	GetName = function()
		return "FOUND_PLAYERS"
	end,
}


local WhoSearchButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
WhoSearchButton:SetAlpha(0.2)
WhoSearchButton:SetPoint("TopLeft")
WhoSearchButton:SetText("Search")

WhoSearchButton:SetWidth(WhoSearchButton:GetFontString():GetWidth() + 15)

WhoSearchButton:SetScript("OnClick", function(self)
	C_FriendList.SendWho("")
end)

WhoSearchButton:RegisterEvent("WHO_LIST_UPDATE")
WhoSearchButton:SetScript("OnEvent", function()
	for i = 1, C_FriendList.GetNumWhoResults() do
		local whoInfo = C_FriendList.GetWhoInfo(i)

		FOUND_PLAYERS[whoInfo.fullName] = whoInfo
	end

	local size = 0

	for _, _ in pairs(FOUND_PLAYERS) do
		size = size + 1
	end

	FOUND_PLAYERS._size = size
end)

local WhoShowButton = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
WhoShowButton:SetAlpha(0.2)
WhoShowButton:SetPoint("TopLeft", WhoSearchButton, "BottomLeft")
WhoShowButton:SetText("Show")

WhoShowButton:SetWidth(WhoShowButton:GetFontString():GetWidth() + 15)

WhoShowButton:SetScript("OnClick", function()
	addonTable.C_Debug:ShowTableEntries(FOUND_PLAYERS)
end)
