local addonName, addonTable = ...


local function CheckActionButtons()
	for actionButtonIndex = 1, 12 do
		local actionButton = _G["ActionButton" .. actionButtonIndex]

		if GetCursorInfo() or actionButton:HasAction() then
			actionButton:SetAlpha(1)
		else
			actionButton:SetAlpha(0)
		end
	end
end

local function HookActionButtons()
	for actionButtonIndex = 1, 12 do
		local actionButton = _G["ActionButton" .. actionButtonIndex]

		actionButton:HookScript("OnEnter", function(self)
			CheckActionButtons()
		end)
	end
end



local AddonEventFrame = CreateFrame("EventFrame")
AddonEventFrame:RegisterEvent("ADDON_LOADED")
AddonEventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "Blizzard_PlayerSpells" then
			local ClearActionBarsButton = CreateFrame("Button", nil, PlayerSpellsFrame.SpellBookFrame, "UIPanelButtonTemplate")
			ClearActionBarsButton.defaultText = "Clear Action Bars"
			ClearActionBarsButton.waitDuration = 2

			ClearActionBarsButton:SetPoint("Bottom", 0, 35)
			ClearActionBarsButton:SetText(ClearActionBarsButton.defaultText)

			ClearActionBarsButton:FitToText()

			ClearActionBarsButton.OnUpdate = function(self, elapsed)
				self.elapsedTotal = self.elapsedTotal + elapsed

				if self.elapsedTotal >= self.waitDuration then
					self:SetScript("OnClick", self.OnClick)
					self:SetText(self.defaultText)
				else
					self:SetText(math.ceil(self.waitDuration - self.elapsedTotal))
				end
			end

			ClearActionBarsButton.OnClick = function(self)
				for i = 1, 1000 do
					PickupAction(i)
					ClearCursor()
				end
			end

			ClearActionBarsButton:SetScript("OnEnter", function(self)
				self.elapsedTotal = 0

				self:SetScript("OnUpdate", self.OnUpdate)
			end)

			ClearActionBarsButton:SetScript("OnLeave", function(self)
				self:SetScript("OnClick", nil)
				self:SetScript("OnUpdate", nil)

				self:SetText(self.defaultText)
			end)
		end

		if arg1 == addonName then
			local ActionBarEventFrame = CreateFrame("EventFrame")
			ActionBarEventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			ActionBarEventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
			ActionBarEventFrame:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")

			ActionBarEventFrame:SetScript("OnEvent", function(self, event)
				if event == "UPDATE_OVERRIDE_ACTIONBAR" then
					HookActionButtons()
				end

				CheckActionButtons()
			end)









			local DressUpFrameMultiplier = 1.3
			local DressUpFrameWidth = DressUpFrame:GetWidth() * DressUpFrameMultiplier
			local DressUpFrameHeight = DressUpFrame:GetHeight() * DressUpFrameMultiplier

			local function DressUpFrameResize(self)
				C_Timer.After(0, function()
					self:SetSize(DressUpFrameWidth, DressUpFrameHeight)
				end)
			end

			DressUpFrame:HookScript("OnShow", DressUpFrameResize)
			DressUpFrame:HookScript("OnSizeChanged", DressUpFrameResize)








			local function ClearMount(_, mountTypeID)
				addonTable.Mount:SetMount(mountTypeID, nil)
			end

			local function SetMount(_, mountTypeID, mountID)
				addonTable.Mount:SetMount(mountTypeID, mountID)
			end

			local CollectionsEventFrame = CreateFrame("EventFrame")
			CollectionsEventFrame:RegisterEvent("ADDON_LOADED")
			CollectionsEventFrame:SetScript("OnEvent", function(self, event, arg1)
				if event == "ADDON_LOADED" then
					if arg1 == "Blizzard_Collections" then
						-- TODO: Find new context menu api
						local originalInitializeFunction = addonTable.C_Table:GetKey(MountJournal, "mountOptionsMenu", "initialize")

						if not originalInitializeFunction then
							return
						end

						MountJournal.mountOptionsMenu.initialize = function(...)
							originalInitializeFunction(...)

							local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(MountJournal.menuMountIndex)

							local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)

							if isForDragonriding then
								local currentDragonridingMountID = addonTable.Mount:GetMountID(Enum.MountType.Dragonriding)
								local dragonridingChecked = false
								local func
								local text

								if mountID == currentDragonridingMountID then
									dragonridingChecked = true
									func = ClearMount
									text = "Clear Dragonriding Mount"
								else
									func = SetMount
									text = "Set Dragonriding Mount"
								end

								if currentDragonridingMountID then
									text = text .. " |cff00ff00[" .. C_MountJournal.GetMountInfoByID(currentDragonridingMountID) .. "]|r"
								end

								UIDropDownMenu_AddButton({
									arg1 = Enum.MountType.Dragonriding,
									arg2 = mountID,
									checked = dragonridingChecked,
									func = func,
									text = text,
								}, 1)
							else
								local currentGroundMountID = addonTable.Mount:GetMountID(Enum.MountType.Ground)
								local func
								local groundChecked = false
								local text

								if mountID == currentGroundMountID then
									func = ClearMount
									groundChecked = true
									text = "Clear Ground Mount"
								else
									func = SetMount
									text = "Set Ground Mount"
								end

								if currentGroundMountID then
									text = text .. " |cff00ff00[" .. C_MountJournal.GetMountInfoByID(currentGroundMountID) .. "]|r"
								end

								UIDropDownMenu_AddButton({
									arg1 = Enum.MountType.Ground,
									arg2 = mountID,
									checked = groundChecked,
									func = func,
									text = text,
								}, 1)

								if addonTable.Mount:CanMountFly(mountID) then
									local currentFlyingMountID = addonTable.Mount:GetMountID(Enum.MountType.Flying)
									local flyingChecked = false
									local func
									local text

									if mountID == currentFlyingMountID then
										flyingChecked = true
										func = ClearMount
										text = "Clear Flying Mount"
									else
										func = SetMount
										text = "Set Flying Mount"
									end

									if currentFlyingMountID then
										text = text .. " |cff00ff00[" .. C_MountJournal.GetMountInfoByID(currentFlyingMountID) .. "]|r"
									end

									UIDropDownMenu_AddButton({
										arg1 = Enum.MountType.Flying,
										arg2 = mountID,
										checked = flyingChecked,
										func = func,
										text = text,
									}, 1)
								end
							end

							UIDropDownMenu_AddButton({
								disabled = true,
								text = "Mount ID: " .. mountID
							}, 1)

							UIDropDownMenu_AddButton({
								disabled = true,
								text = "Mount Type ID: " .. mountTypeID
							}, 1)
						end
					end
				end
			end)






			local PvPEventFrame = CreateFrame("EventFrame")
			-- PvPEventFrame:RegisterEvent("AREA_POIS_UPDATED")

			PvPEventFrame:SetScript("OnEvent", function(self, event, ...)
				print(event, ...)

				-- if event == "UPDATE_BATTLEFIELD_STATUS" then
				-- 	if GetBattlefieldStatus(...) == "confirm" then
				-- 		self.startTime = GetTime()
				-- 		print("Start")
				-- 	elseif GetBattlefieldStatus(...) == "none" then
				-- 		print("End:", GetTime() - self.startTime)
				-- 	end
				-- end
			end)
		end
	end
end)
