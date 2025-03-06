local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection('cvar'):AddMixin('api', function()
	local CvarAPI = {}

	return CvarAPI
end)
