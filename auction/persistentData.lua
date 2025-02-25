local addonName, addonData = ...


local IMPORTS = {
	character = {
		api = true,
	},

	persistentData = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("auction"):AddMixin("persistentData", IMPORTS, function()
	local AuctionPersistentData = {}

	function AuctionPersistentData:GetData()
		-- local PersistentDataAccess = IMPORTS.persistentData.api:CreateAccessTable(collectionName)

		return {}
	end

	function AuctionPersistentData:GetRealmData()
		local persistentData = self:GetData()

		-- local playerRealm = IMPORTS.character.api:GetCharacterRealmName(UnitGUID("player"))
		local playerRealm = "PlayerRealm"

		if not persistentData[playerRealm] then
			persistentData[playerRealm] = {}
		end

		return persistentData[playerRealm]
	end

	function AuctionPersistentData:GetItemsData()
		local realmPersistentData = self:GetRealmData()

		if not realmPersistentData.items then
			realmPersistentData.items = {}
		end

		return realmPersistentData.items
	end

	function AuctionPersistentData:GetReplicateItemsPreviousTimeRan()
		return self:GetRealmData().replicateItemsPreviousTimeRan
	end

	function AuctionPersistentData:GetItemDataByName(itemSearchName)
		for itemID, itemData in pairs(self:GetItemsData()) do
			local itemName = GetItemInfo(itemID)

			if itemSearchName == itemName then
				return itemData
			end
		end
	end

	function AuctionPersistentData:GetItemDataByID(itemID)
		return self:GetItemsData()[itemID]
	end

	function AuctionPersistentData:UpdateItemData(itemID, updatedItemData)
		local itemData = self:GetItemDataByID(itemID)

		if not itemData then
			itemData = {}
		end

		if type(updatedItemData) == "table" then
			for key, value in pairs(updatedItemData) do
				itemData[key] = value
			end
		end

		itemData.timeUpdated = time()

		self:GetItemsData()[itemID] = itemData
	end

	function AuctionPersistentData:GetNumReplicateItemsLastScan()
		local realmPersistentData = self:GetRealmData()

		local numReplicateItemsLastScan = realmPersistentData.numReplicateItemsLastScan

		if not numReplicateItemsLastScan then
			numReplicateItemsLastScan = 0

			realmPersistentData.numReplicateItemsLastScan = numReplicateItemsLastScan
		end

		return numReplicateItemsLastScan
	end

	function AuctionPersistentData:UpdateNumReplicateItemsLastScan()
		self:GetRealmData().numReplicateItemsLastScan = C_AuctionHouse.GetNumReplicateItems()
	end

	function AuctionPersistentData:UpdateReplicateItemsPreviousTimeRan()
		self:GetRealmData().replicateItemsPreviousTimeRan = time()
	end


	return AuctionPersistentData
end)
