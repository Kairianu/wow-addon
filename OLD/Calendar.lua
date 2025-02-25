local addonName, addonTable = ...


-- local function CalendarTimeString(calendarTime)
-- 	return FormatShortDate(calendarTime.month, calendarTime.year, calendarTime.monthDay) .. " " .. GameTime_GetFormattedTime(calendarTime.hour, calendarTime.minute, true)
-- end



local CALENDAR_UPDATE_CALLBACKS = {}
local LOAD_CALENDAR_DATA
local LOADING_SCREEN_DISABLED


local EventFrame = CreateFrame("EventFrame")
EventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
EventFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
EventFrame:SetScript("OnEvent", function(self, event)
	if event == "CALENDAR_UPDATE_EVENT_LIST" then
		while #CALENDAR_UPDATE_CALLBACKS > 0 do
			local callbackData = table.remove(CALENDAR_UPDATE_CALLBACKS, 1)

			callbackData.callback(unpack(callbackData.args))
		end
	elseif event == "LOADING_SCREEN_DISABLED" then
		self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")

		LOADING_SCREEN_DISABLED = true

		if LOAD_CALENDAR_DATA then
			addonTable.Calendar:LoadCalendarData()
		end
	elseif event == "LOADING_SCREEN_ENABLED" then
		self:UnregisterEvent("CALENDAR_UPDATE_EVENT_LIST")

		LOADING_SCREEN_DISABLED = false
	end
end)


local Calendar = {}
addonTable.Calendar = Calendar

function Calendar:UpdateEventList(callback, ...)
	if callback then
		table.insert(CALENDAR_UPDATE_CALLBACKS, {
			callback = callback,
			args = {...},
		})
	end

	if LOADING_SCREEN_DISABLED then
		LOAD_CALENDAR_DATA = false

		self:LoadCalendarData()
	else
		LOAD_CALENDAR_DATA = true
	end
end

function Calendar:LoadCalendarData()
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()

	C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year)
	C_Calendar.OpenCalendar()
end

function Calendar:IsEventActive(eventTitle)
	local currentCalendarTime = date("*t")
	local day = currentCalendarTime.day

	-- local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
	-- local day = currentCalendarTime.monthDay

	local numDayEvents = C_Calendar.GetNumDayEvents(0, day)

	for i = 1, numDayEvents do
		local eventInfo = C_Calendar.GetDayEvent(0, day, i)

		if eventInfo.title == eventTitle then
			if eventInfo.sequenceType == "END" then
				if currentCalendarTime.hour < eventInfo.endTime.hour then
					return true
				elseif currentCalendarTime.hour == eventInfo.endTime.hour then
					local minute

					if currentCalendarTime.min then
						minute = currentCalendarTime.min
					else
						minute = currentCalendarTime.minute
					end

					if minute < eventInfo.endTime.minute then
						return true
					end
				end
			elseif eventInfo.sequenceType == "ONGOING" then
				return true
			elseif eventInfo.sequenceType == "START" then
				if currentCalendarTime.hour > eventInfo.startTime.hour then
					return true
				elseif currentCalendarTime.hour == eventInfo.startTime.hour then
					local minute

					if currentCalendarTime.min then
						minute = currentCalendarTime.min
					else
						minute = currentCalendarTime.minute
					end

					if minute >= eventInfo.startTime.minute then
						return true
					end
				end
			end
		end
	end

	return false
end
