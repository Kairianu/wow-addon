local addonName, addonData = ...


local IMPORTS = {
	mount = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection('mount'):AddMixin('ui', IMPORTS, function()
	local MountUIEventFrame = CreateFrame('frame')

	MountUIEventFrame:RegisterEvent('GROUP_FORMED')
	MountUIEventFrame:RegisterEvent('GROUP_LEFT')
	MountUIEventFrame:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')

	MountUIEventFrame:SetScript('onEvent', function(self, event)
		IMPORTS.mount.api:UpdateMountMacro()

		C_Timer.After(0, function()
			IMPORTS.mount.api:UpdateSwimmingMountMacro()
		end)
	end)
end)
