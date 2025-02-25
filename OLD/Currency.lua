local addonName, addonTable = ...


local CurrencySavedVariables = addonTable.CurrencySavedVariables



local CurrencyFrame = CreateFrame("EventFrame", nil, TokenFrame)

function CurrencyFrame:UpdateGameTooltip(BlizzardCurrencyFrame)
	GameTooltip:SetOwner(BlizzardCurrencyFrame, "ANCHOR_BOTTOMRIGHT", 20)
	GameTooltip:SetCurrencyToken(BlizzardCurrencyFrame.index)
end

CurrencyFrame:SetScript("OnShow", function(self)
	self.currencyFrames = { TokenFrame.ScrollBox.ScrollTarget:GetChildren() }
end)

-- CurrencyFrame:SetScript("OnUpdate", function(self, elapsed)
-- 	for i, BlizzardCurrencyFrame in ipairs(self.currencyFrames) do
-- 		if MouseIsOver(BlizzardCurrencyFrame) then
-- 			self.ActiveBlizzardCurrencyFrame = BlizzardCurrencyFrame

-- 			self:UpdateGameTooltip(BlizzardCurrencyFrame)

-- 			return
-- 		end
-- 	end

-- 	if self.ActiveBlizzardCurrencyFrame and not MouseIsOver(self.ActiveBlizzardCurrencyFrame) then
-- 		self.ActiveBlizzardCurrencyFrame = nil

-- 		GameTooltip:Hide()
-- 	end
-- end)



local function AddCurrencyTooltipInfo(currencyName)
	local characterOrder = CurrencySavedVariables:GetCharacterOrder(currencyName)

	if not characterOrder then
		return
	end

	GameTooltip:AddLine("\n")

	local currencyQuantityTotal = 0
	local prefixSpacer = "   "

	for realmIndex, realmName in ipairs(characterOrder) do
		if realmIndex > 1 then
			GameTooltip:AddLine("\n")
		end

		local characterMoneyStrings = {}
		local realmCurrencyTotal = 0

		for _, characterGUID in ipairs(characterOrder[realmName]) do
			local characterCurrencyQuantity = CurrencySavedVariables:GetCharacterCurrencyQuantity(currencyName, characterGUID)

			currencyQuantityTotal = currencyQuantityTotal + characterCurrencyQuantity
			realmCurrencyTotal = realmCurrencyTotal + characterCurrencyQuantity

			local characterColor = addonTable.Character:GetCharacterColor(characterGUID)
			local characterName = addonTable.Character:GetCharacterName(characterGUID)

			local characterCurrencyQuantityString

			if currencyName == "Money" then
				characterCurrencyQuantityString = GetMoneyString(characterCurrencyQuantity)
			else
				characterCurrencyQuantityString = characterCurrencyQuantity
			end

			table.insert(characterMoneyStrings, {
				characterColor:WrapTextInColorCode(prefixSpacer .. characterName),
				addonTable.Color:WrapTextInColor("white", characterCurrencyQuantityString)
			})
		end

		local realmCurrencyTotalString

		if currencyName == "Money" then
			realmCurrencyTotalString = GetMoneyString(realmCurrencyTotal)
		else
			realmCurrencyTotalString = realmCurrencyTotal
		end

		GameTooltip:AddDoubleLine(realmName, realmCurrencyTotalString)

		for _, characterMoneyStringData in ipairs(characterMoneyStrings) do
			GameTooltip:AddDoubleLine(characterMoneyStringData[1], characterMoneyStringData[2])
		end
	end

	local currencyQuantityTotalString

	if currencyName == "Money" then
		currencyQuantityTotalString = GetMoneyString(currencyQuantityTotal)
	else
		currencyQuantityTotalString = currencyQuantityTotal
	end

	GameTooltip:AddLine("\n")
	GameTooltip:AddDoubleLine("Total", addonTable.Color:WrapTextInColor("white", currencyQuantityTotalString))

	GameTooltip:Show()
end


local function SetPlayerMoneyTooltip(owner, anchor)
	GameTooltip:SetOwner(owner, anchor)

	GameTooltip:AddLine("Money")
	GameTooltip:AddLine(addonTable.Color:WrapTextInColor("white", GetMoneyString(GetMoney())))

	AddCurrencyTooltipInfo("Money")
end



local BagMoneyFrame = CreateFrame("Frame", nil, ContainerFrameCombinedBags.MoneyFrame)
BagMoneyFrame:SetAllPoints()

BagMoneyFrame:SetScript("OnHide", function(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide()
	end
end)

BagMoneyFrame:SetScript("OnUpdate", function(self)
	if MouseIsOver(self) then
		if GameTooltip:GetOwner() ~= self then
			SetPlayerMoneyTooltip(self, "ANCHOR_TOPRIGHT")
		end
	else
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end
end)



hooksecurefunc(GameTooltip, "SetBackpackToken", function(self, backpackCurrencyIndex)
	local tokenInfo = BackpackTokenFrame.Tokens[backpackCurrencyIndex]

	if tokenInfo then
		AddCurrencyTooltipInfo(C_CurrencyInfo.GetCurrencyInfo(tokenInfo.currencyID).name)
	end
end)

hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, currencyID)
	AddCurrencyTooltipInfo(C_CurrencyInfo.GetCurrencyInfo(currencyID).name)
end)

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, currencyListIndex)
	AddCurrencyTooltipInfo(C_CurrencyInfo.GetCurrencyListInfo(currencyListIndex).name)
end)



local Currency = CreateFrame("Frame")
addonTable.Currency = Currency

function Currency:UpdatePlayerCurrencyByID(currencyID)
	if not currencyID then
		return
	end

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)

	if not currencyInfo then
		return
	end

	CurrencySavedVariables:SetCharacterCurrencyQuantity(currencyInfo.name, UnitGUID("player"), currencyInfo.quantity)
end

function Currency:UpdatePlayerCurrencies()
	for currencyListIndex = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local currencyInfo = C_CurrencyInfo.GetCurrencyListInfo(currencyListIndex)

		if not currencyInfo.isHeader and currencyInfo.quantity > 0 then
			CurrencySavedVariables:SetCharacterCurrencyQuantity(currencyInfo.name, UnitGUID("player"), currencyInfo.quantity)
		end
	end
end

function Currency:UpdatePlayerMoney()
	CurrencySavedVariables:SetCharacterCurrencyQuantity("Money", UnitGUID("player"), GetMoney())
end

function Currency:UpdateAllPlayerCurrencies()
	self:UpdatePlayerMoney()
	self:UpdatePlayerCurrencies()
end

Currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
Currency:RegisterEvent("PLAYER_ENTERING_WORLD")
Currency:RegisterEvent("PLAYER_MONEY")
Currency:SetScript("OnEvent", function(self, event, arg1)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdatePlayerCurrencyByID(arg1)
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateAllPlayerCurrencies()
	elseif event == "PLAYER_MONEY" then
		self:UpdatePlayerMoney()
	end
end)
