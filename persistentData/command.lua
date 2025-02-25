local addonName, addonData = ...


local IMPORTS = {
	persistentData = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("persistentData"):AddMixin("command", IMPORTS, function()
	SLASH_CLEAR_PERSISTENT_DATA1 = "/clearpersistentdata"
	SlashCmdList["CLEAR_PERSISTENT_DATA"] = function()
		IMPORTS.persistentData.api:ClearPersistentData()
	end
end)
