local addonName, addonData = ...


local IMPORTS = {
	auction = {
		api = true,
		persistentData = true,
	},

	color = {
		api = true,
	},

	table = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("auction"):AddMixin("ui", IMPORTS, function()
	local REPLICATE_ITEMS_ON_UPDATE_ELAPSED = 0
	local REPLICATE_ITEMS_ON_UPDATE_TIMEOUT = 3
	local REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT = 0



	local function createFullScanButton()
		local FullScanButton = CreateFrame("Button", nil, AuctionHouseFrame, "UIPanelButtonTemplate")

		FullScanButton.cannotScanText = "Cannot Scan Yet"
		FullScanButton.checkingText = "Checking..."
		FullScanButton.clickTimeout = REPLICATE_ITEMS_ON_UPDATE_TIMEOUT
		FullScanButton.defaultText = "Full Scan"

		FullScanButton:SetPoint("Bottom", 0, 5)
		FullScanButton:SetPoint("Left", AuctionHouseFrame.MoneyFrameInset, "Right")

		hooksecurefunc(FullScanButton, "SetText", function(self)
			self:FitToText()
		end)

		FullScanButton:SetScript("OnClick", function(self)
			self.clickedTime = time()

			AuctionAPI:StartFullScan()
		end)

		FullScanButton:SetScript("OnUpdate", function(self, elapsed)
			if self.textTimeout then
				self.textTimeoutElapsed = (self.textTimeoutElapsed or 0) + elapsed

				if self.textTimeoutElapsed < self.textTimeout then
					return
				end

				self.textTimeout = nil
				self.textTimeoutElapsed = 0
			end

			local text

			if AuctionAPI:IsFullScanRunning() then
				local numReplicateItems = C_AuctionHouse.GetNumReplicateItems()
				local numReplicateItemsLastScan = AuctionAPI:GetNumReplicateItemsLastScan()

				if numReplicateItems < numReplicateItemsLastScan then
					text = string.format("%s%%", math.floor(numReplicateItems / numReplicateItemsLastScan * 100))
				else
					text = string.format("Items Scanned: %s", numReplicateItems)
				end
			else
				local secondsUntilNextScan = AuctionAPI:GetFullScanSecondsUntilNextPossibleScan()

				if secondsUntilNextScan > 0 then
					local minutes = math.floor(secondsUntilNextScan / 60)
					local seconds = tostring(secondsUntilNextScan % 60)

					if string.len(seconds) == 1 then
						seconds = "0" .. seconds
					end

					text = string.format("Next Scan Available: %s:%s", minutes, seconds)
				else
					if self.clickedTime then
						if time() - self.clickedTime >= self.clickTimeout then
							self.clickedTime = nil
							self.textTimeout = 3
							text = self.cannotScanText
						else
							text = self.checkingText
						end
					end
				end
			end

			if not text then
				text = self.defaultText
			end

			self:SetText(text)
		end)
	end



	local TooltipInfo = {}

	function TooltipInfo:GetProcessMethods()
		return {
			GetBagItem = self.ProcessBagItemTooltip,
			GetRecipeResultItem = self.ProcessRecipeTooltip,
		}
	end

	function TooltipInfo:GetCategoryToEnchantNames()
		return {
			["Boot Enchantments"] = "Boots",
			["Bracer Enchantments"] = "Bracer",
			["Cloak Enchantments"] = "Cloak",

			-- [""] = "Chest",
			-- [""] = "Shield",
			-- [""] = "2H Weapon",
			-- [""] = "Gloves",
			-- [""] = "Ring",
		}
	end

	function TooltipInfo:ProcessRecipeTooltip(TooltipFrame, tooltipInfo)
		local tooltipData = tooltipInfo.tooltipData

		if not tooltipData then
			return
		end

		local itemOrRecipeID = tooltipData.id

		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(itemOrRecipeID)

		if not recipeInfo then
			return
		end

		local auctionItemKey
		local categoryID = recipeInfo.categoryID

		if categoryID and categoryID > 0 then
			if not recipeInfo.name then
				return
			end

			local categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryID)

			if not categoryInfo then
				return
			end

			local enchantSlotName = self:GetCategoryToEnchantNames()[categoryInfo.name]

			if not enchantSlotName then
				local message = "Enchant Slot Name Missing: " .. categoryInfo.name

				-- message = ColorAPI:WrapTextInColor("red", message)

				DEFAULT_CHAT_FRAME:AddMessage(message)

				return
			end

			auctionItemKey = "Enchant " .. enchantSlotName .. " - " .. recipeInfo.name
		else
		end

		self:AddTooltipAuctionData(TooltipFrame, auctionItemKey)
	end

	function TooltipInfo:AddTooltipAuctionData(TooltipFrame, itemKey)
		local auctionItemData = AuctionPersistentData:GetItemData(itemKey)

		if not auctionItemData then
			return
		end

		local buyoutPrice = auctionItemData.buyoutPrice

		if not buyoutPrice then
			return
		end

		local auctionAmountString = "Auction:      " .. GetMoneyString(buyoutPrice)

		-- auctionAmountString = ColorAPI:WrapTextInColor("white", auctionAmountString)

		local timeUpdatedString

		if auctionItemData.timeUpdated then
			timeUpdatedString = "(" .. addonTable.Time:GetHumanReadableDHMS(time() - auctionItemData.timeUpdated) .. ")"

			-- timeUpdatedString = ColorAPI:WrapTextInColor("gray", timeUpdatedString)
		end

		TooltipFrame:AddLine("\n")

		if timeUpdatedString then
			if type(TooltipFrame.AddDoubleLine) == "function" then
				TooltipFrame:AddDoubleLine(auctionAmountString, timeUpdatedString)
			else
				TooltipFrame:AddLine(auctionAmountString .. "    " .. timeUpdatedString)
			end
		else
			TooltipFrame:AddLine(auctionAmountString)
		end

		TooltipFrame:Show()
	end

	function TooltipInfo:ProcessBagItemTooltip(TooltipFrame, tooltipInfo)
		-- local getterArgs = TableAPI:GetKey(tooltipInfo, "getterArgs")

		if not tooltipInfo then
			return
		end

		local getterArgs = tooltipInfo.getterArgs

		if not getterArgs then
			return
		end

		-- local battlePetName = TableAPI:GetKey(tooltipInfo, "tooltipData", "battlePetName")

		local tooltipData = tooltipInfo.tooltipData

		if not tooltipData then
			return
		end

		local battlePetName = tooltipData.battlePetName

		if battlePetName then
			TooltipFrame = BattlePetTooltip
		end

		local containerItemInfo = C_Container.GetContainerItemInfo(unpack(getterArgs))

		if containerItemInfo then
			self:AddTooltipAuctionData(TooltipFrame, containerItemInfo.itemID)
		end
	end

	function TooltipInfo:ProcessTooltipInfo(TooltipFrame, tooltipInfo)
		local tooltipProcessMethod = self:GetProcessMethods()[tooltipInfo.getterName]

		if tooltipProcessMethod then
			tooltipProcessMethod(TooltipFrame, tooltipInfo)
		end
	end

	function TooltipInfo:Hook()
		hooksecurefunc(GameTooltip, "ProcessInfo", function(...)
			self:ProcessTooltipInfo(...)
		end)
	end






	local AuctionUI = CreateFrame("frame")

	function AuctionUI:OnUpdate(elapsed)
		if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
			return
		end

		AuctionAPI:ProcessReplicateItems()

		local numReplicateItems = C_AuctionHouse.GetNumReplicateItems()

		if numReplicateItems == 0 then
			AuctionAPI:SetFullScanRunning(false)

			return
		end

		if REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT == 0 then
			AuctionPersistentData:UpdateReplicateItemsPreviousTimeRan()
		end

		if numReplicateItems < REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT then
			REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT = 0

			AuctionPersistentData:UpdateReplicateItemsPreviousTimeRan()
		end

		if numReplicateItems == REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT then
			REPLICATE_ITEMS_ON_UPDATE_ELAPSED = REPLICATE_ITEMS_ON_UPDATE_ELAPSED + elapsed

			if REPLICATE_ITEMS_ON_UPDATE_ELAPSED >= REPLICATE_ITEMS_ON_UPDATE_TIMEOUT then
				AuctionAPI:SetFullScanRunning(false)

				return
			end
		else
			REPLICATE_ITEMS_PREVIOUS_SCAN_COUNT = numReplicateItems
			REPLICATE_ITEMS_ON_UPDATE_ELAPSED = 0
		end

		AuctionAPI:SetFullScanRunning(true)
	end

	function AuctionUI:ReadSearchResultInfo(options)
		local itemID = options.itemID
		local searchResultBuyoutKey = options.searchResultBuyoutKey
		local searchResultInfoMethod = options.searchResultInfoMethod
		local searchResultMethodsArg1 = options.searchResultMethodsArg1
		local searchResultsQuantityMethod = options.searchResultsQuantityMethod

		local buyoutPrice

		for searchResultIndex = 1, searchResultsQuantityMethod(searchResultMethodsArg1) do
			local searchResultInfo = searchResultInfoMethod(searchResultMethodsArg1, searchResultIndex)

			if searchResultInfo then
				local searchResultBuyoutPrice = searchResultInfo[searchResultBuyoutKey]

				if buyoutPrice then
					buyoutPrice = math.min(buyoutPrice, searchResultBuyoutPrice)
				else
					buyoutPrice = searchResultBuyoutPrice
				end
			end
		end

		if buyoutPrice then
			AuctionPersistentData:UpdateItemData(itemID, {
				buyoutPrice = buyoutPrice,
			})
		end
	end

	-- AuctionUI:RegisterEvent("AUCTION_HOUSE_NEW_RESULTS_RECEIVED")
	-- AuctionUI:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
	AuctionUI:RegisterEvent("ADDON_LOADED")
	AuctionUI:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
	AuctionUI:RegisterEvent("FIRST_FRAME_RENDERED")
	AuctionUI:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
	AuctionUI:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" then
			if arg1 == "Blizzard_AuctionHouseUI" then
				self:SetScript("OnUpdate", self.OnUpdate)

				createFullScanButton()
			end
		elseif event == "FIRST_FRAME_RENDERED" then
			TooltipInfo:Hook()
		elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
			self:ReadSearchResultInfo({
				itemID = arg1,
				searchResultBuyoutKey = "unitPrice",
				searchResultInfoMethod = C_AuctionHouse.GetCommoditySearchResultInfo,
				searchResultMethodsArg1 = arg1,
				searchResultsQuantityMethod = C_AuctionHouse.GetCommoditySearchResultsQuantity,
			})
		elseif event == "ITEM_SEARCH_RESULTS_UPDATED" then
			self:ReadSearchResultInfo({
				itemID = arg1.itemID,
				searchResultBuyoutKey = "buyoutAmount",
				searchResultInfoMethod = C_AuctionHouse.GetItemSearchResultInfo,
				searchResultMethodsArg1 = arg1,
				searchResultsQuantityMethod = C_AuctionHouse.GetItemSearchResultsQuantity,
			})
		end
	end)


	return AuctionUI
end)
