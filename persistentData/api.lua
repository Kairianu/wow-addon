local addonName, addonData = ...


local function getNewAccessKey()
	local characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	local keyLength = 12

	local accessKey = ''

	for _ = 1, keyLength do
		local characterIndex = math.random(#characters)

		local character = characters:sub(characterIndex, characterIndex)

		accessKey = accessKey .. character
	end

	return accessKey
end



addonData.CollectionsAPI:GetCollection('persistentData'):AddMixin('api', function()
	local accessKeyModules = {}
	local moduleAccessKeys = {}


	local PersistentDataAPI = {}

	function PersistentDataAPI:CreateAccessKey(moduleKey)
		if type(moduleKey) ~= 'string' or moduleKey == '' then
			error('Argument <moduleKey> must be a non-empty string.')
		end

		if moduleAccessKeys[moduleKey] ~= nil then
			error(string.format(
				'Access key already exists for "%s"',
				moduleKey
			))
		end

		local accessKey = getNewAccessKey()

		accessKeyModules[accessKey] = moduleKey
		moduleAccessKeys[moduleKey] = accessKey

		return accessKey
	end

	function PersistentDataAPI:IsAccessKeyValid(accessKey)
		if accessKeyModules[accessKey] ~= nil then
			return true
		end

		return false
	end

	function PersistentDataAPI:GetModulePersistentData(accessKey)
		local isValidAccessKey = self:IsAccessKeyValid(accessKey)

		if not isValidAccessKey then
			error('Argument <accessKey> is invalid.')
		end

		local addonPersistentData = self:GetAddonPersistentData()

		local moduleKey = accessKeyModules[accessKey]

		local modulePersistentData = addonPersistentData[moduleKey]

		if modulePersistentData == nil then
			modulePersistentData = {}

			addonPersistentData[moduleKey] = modulePersistentData
		end

		return modulePersistentData
	end

	function PersistentDataAPI:GetSavedVariablesKey()
		return addonName .. '_SavedVariables'
	end

	function PersistentDataAPI:GetAddonPersistentData()
		local isAddonLoaded = select(2, C_AddOns.IsAddOnLoaded(addonName))

		if not isAddonLoaded then
			error(string.format(
				'Addon "%s" not yet loaded, persistent data not ready.',
				addonName
			))
		end

		local savedVariablesKey = self:GetSavedVariablesKey()

		local addonPersistentData = _G[savedVariablesKey]

		if type(addonPersistentData) ~= 'table' then
			addonPersistentData = {}

			_G[savedVariablesKey] = addonPersistentData
		end

		return addonPersistentData
	end

	function PersistentDataAPI:ClearPersistentData(reloadUI)
		local savedVariablesKey = self:GetSavedVariablesKey()

		_G[savedVariablesKey] = nil

		if reloadUI then
			ReloadUI()
		end
	end



	return PersistentDataAPI
end)
