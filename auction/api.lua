local addonName, addonData = ...


local IMPORTS = {
	auction = {
		persistentData = true,
	},
}


addonData.CollectionsAPI:GetCollection("auction"):AddMixin("api", IMPORTS, function()
	local IS_FULL_SCAN_RUNNING = false
	local REPLICATE_ITEMS_FULL_SCAN_TIMEOUT = 900
	local REPLICATE_ITEMS_INDEX_START = 0

	-- local TEMP_encahntGracefulAvoidanceData = {}



	local AuctionAPI = {}

	function AuctionAPI:SetFullScanRunning(value)
		IS_FULL_SCAN_RUNNING = not not value
	end

	function AuctionAPI:IsFullScanRunning()
		return IS_FULL_SCAN_RUNNING
	end

	function AuctionAPI:GetNumReplicateItemsLastScan()
		return AuctionPersistentData:GetNumReplicateItemsLastScan()
	end

	function AuctionAPI:ProcessReplicateItems()
		local numReplicateItems = C_AuctionHouse.GetNumReplicateItems()

		if numReplicateItems == 0 then
			return
		end

		if REPLICATE_ITEMS_INDEX_START > numReplicateItems + 1 then
			REPLICATE_ITEMS_INDEX_START = 0
		elseif REPLICATE_ITEMS_INDEX_START > numReplicateItems then
			return
		end

		for replicateItemIndex = REPLICATE_ITEMS_INDEX_START, numReplicateItems do
			local
				replicateItemName,
				replicateItemTexture,
				replicateItemCount,
				replicateItemQualityID,
				replicateItemUsable,
				replicateItemLevel,
				replicateItemLevelType,
				replicateItemMinBid,
				replicateItemMinIncrement,
				replicateItemBuyoutPrice,
				replicateItemBidAmount,
				replicateItemHighBidder,
				replicateItemBidderFullName,
				replicateItemOwner,
				replicateItemOwnerFullName,
				replicateItemSaleStatus,
				replicateItemItemID,
				replicateItemHasAllInfo
			= C_AuctionHouse.GetReplicateItemInfo(replicateItemIndex)

			local itemData = {
				bidAmount = replicateItemBidAmount,
				bidderFullName = replicateItemBidderFullName,
				buyoutPrice = replicateItemBuyoutPrice,
				count = replicateItemCount,
				hasAllInfo = replicateItemHasAllInfo,
				highBidder = replicateItemHighBidder,
				icon = replicateItemTexture,
				level = replicateItemLevel,
				levelType = replicateItemLevelType,
				minBid = replicateItemMinBid,
				minIncrement = replicateItemMinIncrement,
				name = replicateItemName,
				owner = replicateItemOwner,
				ownerFullName = replicateItemOwnerFullName,
				qualityID = replicateItemQualityID,
				saleStatus = replicateItemSaleStatus,
				usable = replicateItemUsable,
			}

			-- if replicateItemItemID == 199947 or replicateItemItemID == 199989 or replicateItemItemID == 200031 then
			-- 	local hl = select(2, GetItemInfo(replicateItemItemID))

			-- 	table.insert(TEMP_encahntGracefulAvoidanceData, replicateItemItemID .. "    " .. hl)

			-- 	STE(TEMP_encahntGracefulAvoidanceData)
			-- end

			AuctionPersistentData:UpdateItemData(replicateItemItemID, itemData)
		end

		AuctionPersistentData:UpdateNumReplicateItemsLastScan()

		REPLICATE_ITEMS_INDEX_START = numReplicateItems + 1
	end

	function AuctionAPI:StartFullScan()
		C_AuctionHouse.ReplicateItems()
	end

	function AuctionAPI:GetFullScanSecondsUntilNextPossibleScan()
		local replicateItemsPreviousTimeRan = AuctionPersistentData:GetReplicateItemsPreviousTimeRan()

		if replicateItemsPreviousTimeRan then
			local timeDifference = time() - replicateItemsPreviousTimeRan

			if timeDifference < REPLICATE_ITEMS_FULL_SCAN_TIMEOUT then
				return REPLICATE_ITEMS_FULL_SCAN_TIMEOUT - timeDifference
			end
		end

		return 0
	end



	return AuctionAPI
end)
