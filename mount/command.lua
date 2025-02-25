local addonName, addonData = ...


local IMPORTS = {
	mount = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("mount"):AddMixin("command", IMPORTS, function()
	-- SLASH_MOUNT_TYPE_IDS1 = "/mounttypeids"
	-- SLASH_MOUNT_TYPE_IDS2 = "/mti"
	-- SlashCmdList["MOUNT_TYPE_IDS"] = function()
	-- 	ShowTableEntries(IMPORTS.mount.api:GetAllMountTypeIDs())
	-- end
end)
