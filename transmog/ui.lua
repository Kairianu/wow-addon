local addonName, addonData = ...


-- TODO: Make a window to scroll through all appearance ids

-- This function takes the current collections appearances set and uses the
-- Dressing Room to try on other appearances that are next to it by appearance ID.
-- A lot of similar sets with different colors are next to each other by appearance ID.
-- Try negative and positive values starting from 1 for appearanceIDModifier.
function TryOnOffsetWardrobeSet(appearanceIDModifier)
	if not WardrobeCollectionFrame then
		return
	end

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor()

	if not playerActor then
		return
	end

	appearanceIDModifier = tonumber(appearanceIDModifier) or 0

	local transmogInfoList = WardrobeCollectionFrame.SetsCollectionFrame.Model:GetItemTransmogInfoList()

	playerActor:Undress()

	for i, transmogInfo in ipairs(transmogInfoList) do
		local appearanceID = transmogInfo.appearanceID

		if appearanceID ~= 0 then
			playerActor:TryOn(appearanceID + appearanceIDModifier)
		end
	end
end
