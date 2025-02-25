local addonName, addonData = ...



-- TODO: Make a window to scroll through all appearance ids


addonData.CollectionsAPI:GetCollection("transmog"):AddMixin("ui", function()
	local TransmogUI = CreateFrame("frame")

	TransmogUI:RegisterEvent("ADDON_LOADED")

	TransmogUI:SetScript("onEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" then
			if arg1 == "Blizzard_Collections" then
				WardrobeFrame:HookScript("onShow", function()
					local modelSceneCamera = WardrobeTransmogFrame.ModelScene:GetActiveCamera()

					if modelSceneCamera then
						modelSceneCamera:SetMaxZoomDistance(modelSceneCamera:GetMaxZoomDistance() + 1.5)
					end
				end)

				C_Timer.After(0, function()
					local scaleOffset = 0.95 - UIParent:GetScale()
					local widthOffset = 400

					WardrobeFrame:ClearAllPoints()
					WardrobeFrame:SetPoint('center', -50, 0)

					WardrobeFrame:SetScale(WardrobeFrame:GetScale() + scaleOffset)
					WardrobeFrame:SetWidth(WardrobeFrame:GetWidth() + widthOffset)

					WardrobeTransmogFrame:SetWidth(WardrobeTransmogFrame:GetWidth() + widthOffset)
					WardrobeTransmogFrame.Inset.BG:SetAllPoints()
					WardrobeTransmogFrame.Inset.BG:SetColorTexture(0, 0, 0)

					WardrobeTransmogFrame.ModelScene:ClearAllPoints()
					WardrobeTransmogFrame.ModelScene:SetPoint('topLeft', 3, -3)
					WardrobeTransmogFrame.ModelScene:SetPoint('bottomRight', -4, 0)

					WardrobeTransmogFrame.HeadButton:SetPoint('left', 15, 0)
					WardrobeTransmogFrame.HandsButton:SetPoint('right', -15, 0)

					WardrobeTransmogFrame.MainHandButton:SetPoint('bottom', -26, 25)
					WardrobeTransmogFrame.MainHandEnchantButton:SetPoint('center', WardrobeTransmogFrame.MainHandButton, 'bottom', 0, -5)

					WardrobeTransmogFrame.SecondaryHandButton:SetPoint('bottom', 26, 25)
					WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint('center', WardrobeTransmogFrame.SecondaryHandButton, 'bottom', 0, -5)

					WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint('left', WardrobeTransmogFrame, 'right', 60, 0)
				end)




				local Model = WardrobeCollectionFrame.SetsCollectionFrame.Model
				local transmogInfoList = Model:GetItemTransmogInfoList()

				TI = function(appearanceIDModifier)
					appearanceIDModifier = tonumber(appearanceIDModifier)

					if not appearanceIDModifier then
						appearanceIDModifier = 2
					end

					-- print(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.Name:GetText())

					DressUpFrame.ModelScene:GetPlayerActor():Undress()

					local transmogInfoList = Model:GetItemTransmogInfoList()

					DressUpFrame.ModelScene:GetPlayerActor():TryOn(transmogInfoList[1].appearanceID + appearanceIDModifier)

					-- for i, transmogInfo in ipairs(transmogInfoList) do
					-- 	local appearanceID = transmogInfo.appearanceID

					-- 	if appearanceID ~= 0 then
					-- 		DressUpFrame.ModelScene:GetPlayerActor():TryOn(appearanceID + appearanceIDModifier)
					-- 	-- 	print(i, appearanceID, transmogInfo.secondaryAppearanceID)
					-- 	end
					-- end
				end
			end
		end
	end)


	return TransmogUI
end)
