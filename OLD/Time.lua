local addonName, addonTable = ...


local Time = {}
addonTable.Time = Time

function Time:GetHumanReadableDHMS(givenTime)
	local days = math.floor(givenTime / 86400)
	local hours = math.floor(givenTime % 86400 / 3600)
	local minutes = math.floor(givenTime % 3600 / 60)
	local seconds = math.floor(givenTime % 60)

	local humanReadableTime = ""

	local showHours = false
	local showMinutes = false
	local showSeconds = false

	if days > 0 then
		humanReadableTime = humanReadableTime .. days .. "d:"

		showHours = true
	end

	if showHours or hours > 0 then
		if showHours and hours < 10 then
			hours = "0" .. hours
		end

		humanReadableTime = humanReadableTime .. hours .. "h:"

		showMinutes = true
	end

	if showMinutes or minutes > 0 then
		if showMinutes and minutes < 10 then
			minutes = "0" .. minutes
		end

		humanReadableTime = humanReadableTime .. minutes .. "m:"

		showSeconds = true
	end

	if showSeconds and seconds < 10 then
		seconds = "0" .. seconds
	end

	humanReadableTime = humanReadableTime .. seconds .. "s"

	return humanReadableTime
end
