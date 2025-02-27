local addonName, addonData = ...


local accessKeys = {}
local globalPersistentData



local function getSavedVariablesKey()
	return addonName .. '_SavedVariables'
end

local function getPersistentData()
	if globalPersistentData == nil then
		local isAddonLoaded = select(2, C_AddOns.IsAddOnLoaded(addonName))

		if isAddonLoaded then
			globalPersistentData = _G[getSavedVariablesKey()]

			if type(globalPersistentData) ~= 'table' then
				globalPersistentData = {}
			end
		else
			error(string.format(
				'Addon %s not yet loaded, persistent data not ready',
				addonName
			))
		end
	end

	return globalPersistentData
end

local function getNewAccessKey()
	local keyLength = 8
	local keyStart = math.pow(10, keyLength - 1)
	local keyEnd = keyStart * 10 - 1

	local accessKey

	repeat
		accessKey = math.random(keyStart, keyEnd)
	until accessKeys[accessKey] == nil

	return accessKey
end



local IMPORTS = {
	persistentData = {
		ui = true,
	},
}


addonData.CollectionsAPI:GetCollection("persistentData"):AddMixin("api", IMPORTS, function()
	local AccessTableMetatable = {}
	local PersistentDataAPI = {}


	function AccessTableMetatable:GetData()
		return PersistentDataAPI:GetAccessKeyData(self.accessKey, self.initialData)
	end


	function PersistentDataAPI:CreateAccessTable(persistentDataKey, initialData)
		local accessKey = self:CreateAccessKey(persistentDataKey)

		local AccessTable = {
			accessKey = accessKey,
			initialData = initialData,
		}

		setmetatable(AccessTable, {
			__index = AccessTableMetatable,
		})

		return AccessTable
	end

	function PersistentDataAPI:CreateAccessKey(persistentDataKey)
		if accessKeys[persistentDataKey] ~= nil then
			error("Access key already exists for " .. persistentDataKey)
		end

		local accessKey = getNewAccessKey()

		accessKeys[persistentDataKey] = accessKey

		return accessKey
	end

	function PersistentDataAPI:GetAccessKeyData(accessKey, accessKeyDataDefault)
		local persistentData = getPersistentData()

		local accessKeyData = persistentData[accessKey]

		if accessKeyData == nil then
			if type(accessKeyDataDefault) == "table" then
				accessKeyData = accessKeyDataDefault
			else
				accessKeyData = {}
			end

			persistentData[accessKey] = accessKeyData
		end

		return accessKeyData
	end

	function PersistentDataAPI:SavePersistentData()
		_G[getSavedVariablesKey()] = getPersistentData()
	end

	function PersistentDataAPI:ClearPersistentData()
		IMPORTS.persistentData.ui:UnregisterAllEvents()

		_G[getSavedVariablesKey()] = nil

		ReloadUI()
	end


	return PersistentDataAPI
end)
