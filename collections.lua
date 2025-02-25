local addonName, addonData = ...


-- TODO: Make raw data act like an import

--[[
	CollectionAPI.collections[collectionKey] = {
		collectionKey = collectionKey,
		Mixin = CollectionMixin,

		mixins = {
			[mixinKey] = {
				collectionKey = collectionKey,
				isLoaded = false,
				loadHandler = function()end,
				Mixin = MixinMixin,
				mixinKey = mixinKey,

				imports = {
					[importCollectionKey] = {
						[importMixinKey] = true or {
							preLoad = true,
						},
					},
				},

				loadedImports = {
					[loadedCollectionKey] = {
						[loadedMixinKey] = nil or true
					},
				},
			},
		},
	}
]]



local function getKey(value, ...)
	for _, key in ipairs({...}) do
		if type(value) ~= "table" then
			return
		end

		value = value[key]
	end

	return value
end

local function getOrCreateKeyTable(value, ...)
	for _, key in ipairs({...}) do
		if type(value) ~= "table" then
			return
		end

		if value[key] == nil then
			value[key] = {}
		end

		value = value[key]
	end

	return value
end



local CollectionAPI = {
	collections = {},
	mixinKeys = {},
}

local CollectionMixinMetatable = {}

local ExternalCollectionsAPI = {}

local ImportsAPI = {
	deferedLoadImports = {},
}

local MixinAPI = {}

local RawDataAPI = {
	rawData = {},
}



local function collectionMixinMetatableIndex(self, key)
	local keyValue = rawget(self, key)

	if keyValue == nil then
		keyValue = CollectionMixinMetatable[key]
	end

	return keyValue
end



function CollectionAPI:CreateCollection(collectionKey)
	if collectionKey == nil then
		error("Collection key cannot be nil")
	end

	if self:DoesCollectionExist(collectionKey) then
		error(string.format(
			"Collection already exists: %s",
			collectionKey
		))
	end

	local CollectionMixin = setmetatable({}, {
		__index = collectionMixinMetatableIndex,
	})

	self.collections[collectionKey] = {
		collectionKey = collectionKey,
		Mixin = CollectionMixin,
	}

	local collectionMixinID = self:GetCollectionMixinID(CollectionMixin)

	self.mixinKeys[collectionMixinID] = collectionKey

	return CollectionMixin
end

function CollectionAPI:DoesCollectionExist(collectionKey)
	if self:GetCollectionData(collectionKey) == nil then
		return false
	end

	return true
end

function CollectionAPI:GetCollectionData(collectionKey)
	return self.collections[collectionKey]
end

function CollectionAPI:GetCollectionKeyFromMixin(CollectionMixin)
	return self.mixinKeys[self:GetCollectionMixinID(CollectionMixin)]
end

function CollectionAPI:GetCollectionMixin(collectionKey)
	if self:DoesCollectionExist(collectionKey) then
		return self:GetCollectionData(collectionKey).Mixin
	end
end

function CollectionAPI:GetCollectionMixinID(CollectionMixin)
	return tostring(CollectionMixin)
end



function CollectionMixinMetatable:AddMixin(mixinKey, mixinImports, mixinLoadHandler)
	MixinAPI:AddMixinToCollection(self:GetCollectionKey(), mixinKey, mixinImports, mixinLoadHandler)
end

function CollectionMixinMetatable:AddRawData(rawDataKey, rawDataHandler)
	RawDataAPI:AddRawDataToCollection(self:GetCollectionKey(), rawDataKey, rawDataHandler)
end

function CollectionMixinMetatable:GetCollectionKey()
	return CollectionAPI:GetCollectionKeyFromMixin(self)
end

function CollectionMixinMetatable:GetMixin(mixinKey)
	return MixinAPI:GetMixin(self:GetCollectionKey(), mixinKey)
end

function CollectionMixinMetatable:GetRawData(rawDataKey)
	return RawDataAPI:GetRawDataForCollection(self:GetCollectionKey(), rawDataKey)
end



function ExternalCollectionsAPI:CreateCollection(collectionKey)
	return CollectionAPI:CreateCollection(collectionKey)
end

function ExternalCollectionsAPI:GetCollection(collectionKey)
	return CollectionAPI:GetCollectionMixin(collectionKey)
end



function ImportsAPI:IterateMixinImports(collectionKey, mixinKey, handler)
	if type(handler) ~= 'function' then
		return
	end

	local mixinImports = self:GetMixinImports(collectionKey, mixinKey)

	if type(mixinImports) ~= 'table' then
		return
	end

	for importCollectionKey, importCollectionMixins in pairs(mixinImports) do
		for importMixinKey, importMixinData in pairs(importCollectionMixins) do
			local handlerReturnValue = handler(importCollectionKey, importMixinKey, importMixinData)

			if handlerReturnValue ~= nil then
				return handlerReturnValue
			end
		end
	end
end

function ImportsAPI:AreImportsPreloaded(collectionKey, mixinKey)
	local areImportsPreloaded = self:IterateMixinImports(collectionKey, mixinKey, function(importCollectionKey, importMixinKey)
		if self:ShouldImportBePreloaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
			if not self:IsImportLoaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
				return false
			end
		end
	end)

	if areImportsPreloaded ~= nil then
		return areImportsPreloaded
	end

	return true
end

function ImportsAPI:DeferLoadImport(collectionKey, mixinKey, importCollectionKey, importMixinKey)
	local deferedLoadMixinImportsData = getOrCreateKeyTable(self.deferedLoadImports, importCollectionKey, importMixinKey)

	table.insert(deferedLoadMixinImportsData, {
		collectionKey = collectionKey,
		mixinKey = mixinKey,
	})
end

function ImportsAPI:GetMixinImports(collectionKey, mixinKey, ...)
	return MixinAPI:GetMixinData(collectionKey, mixinKey, "imports", ...)
end

function ImportsAPI:GetMixinLoadedImports(collectionKey, mixinKey, ...)
	return MixinAPI:GetMixinData(collectionKey, mixinKey, "loadedImports", ...)
end

function ImportsAPI:IsImportLoaded(collectionKey, mixinKey, importCollectionKey, importMixinKey)
	return not not self:GetMixinLoadedImports(collectionKey, mixinKey, importCollectionKey, importMixinKey)
end

function ImportsAPI:LoadDeferedImports(importCollectionKey, importMixinKey)
	local deferedLoadCollectionData = getKey(self.deferedLoadImports, importCollectionKey)

	if not deferedLoadCollectionData then
		return
	end

	local deferedLoadMixinImportsData = getKey(deferedLoadCollectionData, importMixinKey)

	if not deferedLoadMixinImportsData then
		return
	end

	while #deferedLoadMixinImportsData > 0 do
		local mixinKeyData = table.remove(deferedLoadMixinImportsData)

		local collectionKey = mixinKeyData.collectionKey
		local mixinKey = mixinKeyData.mixinKey

		if not self:IsImportLoaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
			local mixinImports = self:GetMixinImports(collectionKey, mixinKey)

			if mixinImports then
				local importCollectionData = mixinImports[importCollectionKey]

				if type(importCollectionData) == "table" then
					if importCollectionData[importMixinKey] then
						importCollectionData[importMixinKey] = MixinAPI:GetMixin(importCollectionKey, importMixinKey)

						MixinAPI:LoadMixin(collectionKey, mixinKey)
					end
				end
			end
		end
	end

	deferedLoadCollectionData[importMixinKey] = nil

	if next(deferedLoadCollectionData) == nil then
		self.deferedLoadImports[importCollectionKey] = nil
	end
end

function ImportsAPI:LoadImport(collectionKey, mixinKey, importCollectionKey, importMixinKey)
	if self:IsImportLoaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
		return
	end

	if not MixinAPI:IsMixinLoaded(importCollectionKey, importMixinKey) then
		self:DeferLoadImport(collectionKey, mixinKey, importCollectionKey, importMixinKey)

		return
	end

	local mixinData = MixinAPI:GetMixinData(collectionKey, mixinKey)

	if not mixinData then
		return
	end

	local importCollectionData = getOrCreateKeyTable(mixinData, "imports", importCollectionKey)

	if type(importCollectionData) ~= "table" then
		return
	end

	importCollectionData[importMixinKey] = MixinAPI:GetMixin(importCollectionKey, importMixinKey)

	getOrCreateKeyTable(mixinData, "loadedImports", importCollectionKey)[importMixinKey] = true
end

function ImportsAPI:LoadMixinImports(collectionKey, mixinKey)
	self:ValidateImports(collectionKey, mixinKey)

	self:IterateMixinImports(collectionKey, mixinKey, function(importCollectionKey, importMixinKey)
		self:LoadImport(collectionKey, mixinKey, importCollectionKey, importMixinKey)
	end)
end

function ImportsAPI:ShouldImportBePreloaded(collectionKey, mixinKey, importCollectionKey, importMixinKey)
	local importMixinData = self:GetMixinImports(collectionKey, mixinKey, importCollectionKey, importMixinKey)

	if not self:IsImportLoaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
		if type(importMixinData) == "table" then
			return not not importMixinData.preLoad
		end
	end

	return false
end

function ImportsAPI:ValidateImports(collectionKey, mixinKey)
	self:ValidateImportsIncludeSelf(collectionKey, mixinKey)
	self:ValidateImportsCircularImport(collectionKey, mixinKey)
end

function ImportsAPI:ValidateImportsCircularImport(collectionKey, mixinKey)
	self:IterateMixinImports(collectionKey, mixinKey, function(importCollectionKey, importMixinKey)
		if self:ShouldImportBePreloaded(collectionKey, mixinKey, importCollectionKey, importMixinKey) then
			if self:ShouldImportBePreloaded(importCollectionKey, importMixinKey, collectionKey, mixinKey) then
				error(string.format(
					"Collection mixin has circular import: %s.%s & %s.%s",
					collectionKey,
					mixinKey,
					importCollectionKey,
					importMixinKey
				))
			end
		end
	end)
end

function ImportsAPI:ValidateImportsIncludeSelf(collectionKey, mixinKey)
	if self:ShouldImportBePreloaded(collectionKey, mixinKey, collectionKey, mixinKey) then
		error(string.format(
			"Collection mixin imports includes itself: %s.%s",
			collectionKey,
			mixinKey
		))
	end
end



function MixinAPI:AddMixinToCollection(collectionKey, mixinKey, mixinImports, mixinLoadHandler)
	if mixinKey == nil then
		error(string.format(
			"Collection mixin key cannot be nil: %s",
			collectionKey
		))
	end

	if not CollectionAPI:DoesCollectionExist(collectionKey) then
		error(string.format(
			"Collection does not exist: %s",
			collectionKey
		))
	end

	local collectionData = CollectionAPI:GetCollectionData(collectionKey)

	local collectionMixinsData = getOrCreateKeyTable(collectionData, "mixins")

	if collectionMixinsData[mixinKey] then
		error(string.format(
			"Collection mixin already exists: %s.%s",
			collectionKey,
			mixinKey
		))
	end

	if mixinLoadHandler == nil and type(mixinImports) == "function" then
		mixinLoadHandler = mixinImports
		mixinImports = nil
	end

	collectionMixinsData[mixinKey] = {
		collectionKey = collectionKey,
		imports = mixinImports,
		loadHandler = mixinLoadHandler,
		mixinKey = mixinKey,
	}

	ImportsAPI:LoadMixinImports(collectionKey, mixinKey)

	self:LoadMixin(collectionKey, mixinKey)
end

function MixinAPI:DoesMixinExist(collectionKey, mixinKey)
	return not not self:GetMixinData(collectionKey, mixinKey)
end

function MixinAPI:GetMixin(collectionKey, mixinKey)
	return self:GetMixinData(collectionKey, mixinKey, "Mixin")
end

function MixinAPI:GetMixinData(collectionKey, mixinKey, ...)
	local collectionData = CollectionAPI:GetCollectionData(collectionKey)

	return getKey(collectionData, "mixins", mixinKey, ...)
end

function MixinAPI:IsMixinLoaded(collectionKey, mixinKey)
	return self:GetMixinData(collectionKey, mixinKey, "isLoaded")
end

function MixinAPI:LoadMixin(collectionKey, mixinKey)
	if self:IsMixinLoaded(collectionKey, mixinKey) then
		return
	end

	if not self:ShouldLoadMixin(collectionKey, mixinKey) then
		return
	end

	local mixinData = self:GetMixinData(collectionKey, mixinKey)

	local mixinLoadHandler = mixinData.loadHandler

	if type(mixinLoadHandler) == "function" then
		local collection = ExternalCollectionsAPI:GetCollection(collectionKey)

		mixinData.Mixin = mixinLoadHandler(collection, collectionKey, mixinKey)
	else
		mixinData.Mixin = mixinLoadHandler
	end

	mixinData.isLoaded = true

	ImportsAPI:LoadDeferedImports(collectionKey, mixinKey)
end

function MixinAPI:ShouldLoadMixin(collectionKey, mixinKey)
	return ImportsAPI:AreImportsPreloaded(collectionKey, mixinKey)
end



function RawDataAPI:AddRawDataToCollection(collectionKey, rawDataKey, rawDataHandler)
	if rawDataKey == nil then
		error(string.format(
			'Raw data key cannot be nil: %s',
			collectionKey
		))
	end

	local collectionRawData = getOrCreateKeyTable(self.rawData, collectionKey)

	if collectionRawData[rawDataKey] then
		error(string.format(
			'Raw data key already exists: %s.%s',
			collectionKey,
			rawDataKey
		))
	end

	local rawDataInfo = {}

	if type(rawDataHandler) == 'function' then
		rawDataInfo.handler = rawDataHandler
	else
		rawDataInfo.data = rawDataHandler
	end

	collectionRawData[rawDataKey] = rawDataInfo
end

function RawDataAPI:GetRawDataForCollection(collectionKey, rawDataKey)
	local rawDataInfo = getKey(self.rawData, collectionKey, rawDataKey)

	if not rawDataInfo then
		return
	end

	if rawDataInfo.data == nil then
		local rawDataHandler = rawDataInfo.handler

		if type(rawDataHandler) == 'function' then
			rawDataInfo.data = rawDataHandler()
		end
	end

	return rawDataInfo.data
end



addonData.CollectionsAPI = ExternalCollectionsAPI
