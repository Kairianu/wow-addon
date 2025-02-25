local addonName, addonTable = ...


local PersistentData = addonTable.PersistentData


local persistentDataAccessKey

local function GetPersistentData()
	if not persistentDataAccessKey then
		persistentDataAccessKey = PersistentData:CreateAccessKey("event")
	end

	return PersistentData:GetAccessKeyData(persistentDataAccessKey)
end



local Event = CreateFrame("Frame")
addonTable.Event = Event

function Event:SaveEvent(event, eventArgs)
	GetPersistentData()[event] = eventArgs
end

-- Event:RegisterAllEvents()
-- Event:SetScript("OnEvent", function(self, event, ...)
-- 	self:SaveEvent(event, {...})
-- end)




-- PVP_WORLDSTATE_UPDATE
-- PVP_SPECIAL_EVENT_INFO_UPDATED
