local addonName, addonData = ...


local IMPORTS = {
	persistentData = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("persistentData"):AddMixin("ui", IMPORTS, function()
	local PersistentDataUI = CreateFrame("frame")

	PersistentDataUI:RegisterEvent("PLAYER_LOGOUT")

	PersistentDataUI:SetScript("OnEvent", function()
		IMPORTS.persistentData.api:SavePersistentData()
	end)


	return PersistentDataUI
end)
