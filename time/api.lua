local addonName, addonData = ...


local SUB_SECOND_PRECISION = {
	min = 0,
	millisecond = 3,
	max = 7,
}


local SUB_SECOND_BASE_FORMAT_STRING = '%%0%dd'

local SUB_SECOND_FORMAT_STRINGS = {
	millisecond = string.format(SUB_SECOND_BASE_FORMAT_STRING, SUB_SECOND_PRECISION.millisecond),
	max = string.format(SUB_SECOND_BASE_FORMAT_STRING, SUB_SECOND_PRECISION.max),
}


local function GetTimeZeroPreciseSecond()
	local startTime = GetServerTime()

	while true do
		if GetServerTime() > startTime then
			return GetTimePreciseSec()
		end
	end
end

local TIME_ZERO_PRECISE_SECOND = GetTimeZeroPreciseSecond()





local imports = {
	math = {
		api = true,
	},
}

addonData.CollectionsAPI:GetCollection('time'):AddMixin('api', imports, function()
	local TimeAPI = {
		enums = {
			subSecondPrecision = SUB_SECOND_PRECISION,
		},
	}

	function TimeAPI:GetISOString(subSecondPrecision)
		local unixTime, timeSubSeconds = self:GetUnixTime()

		subSecondPrecision = self:ValidateSubSecondPrecision(subSecondPrecision)

		local subSecondString

		if subSecondPrecision == 0 then
			subSecondString = ''
		elseif subSecondPrecision == SUB_SECOND_PRECISION.max then
			subSecondString = '.' .. self:GetTimeSubSecondsString()
		else
			local subSecondFormatString = '.%0' .. subSecondPrecision .. 'd'
			local subSecondMultiplier = 10 ^ subSecondPrecision

			local subSeconds = math.floor(self:GetTimePreciseSecond() * subSecondMultiplier)

			subSecondString = string.format(subSecondFormatString, subSeconds)
		end

		return date('!%Y-%m-%dT%H:%M:%S', unixTime) .. subSecondString .. 'Z'
	end

	-- This returns the time from the local operating system.
	-- It should be avoided for cross compatibility since it can be changed to a different time.
	function TimeAPI:GetLocalUnixTime()
		return time()
	end

	-- This timestamp is already adjusted for the server's time zone.
	-- If used with date function, make sure it is not timezone adjusted.
	-- Provides minute precision.
	function TimeAPI:GetServerLocaleTime()
		return C_DateAndTime.GetServerTimeLocal()
	end

	function TimeAPI:GetTimeMilliseconds()
		return math.floor(self:GetTimePreciseSecond() * 1e3)
	end

	function TimeAPI:GetTimeMillisecondsString()
		local timeMilliseconds = self:GetTimeMilliseconds()

		return string.format(SUB_SECOND_FORMAT_STRINGS.millisecond, timeMilliseconds)
	end

	-- This time is only accurate to 7 decimal places.
	function TimeAPI:GetTimePreciseSecond()
		return (GetTimePreciseSec() - TIME_ZERO_PRECISE_SECOND) % 1
	end

	function TimeAPI:GetTimeSubSeconds()
		local timePreciseSecond = self:GetTimePreciseSecond()

		return imports.math.api:Round(timePreciseSecond * 1e7)
	end

	function TimeAPI:GetTimeSubSecondsString()
		local timeSubSeconds = self:GetTimeSubSeconds()

		return string.format(SUB_SECOND_FORMAT_STRINGS.max, timeSubSeconds)
	end

	function TimeAPI:GetUnixTime()
		return GetServerTime(), self:GetTimeSubSeconds()
	end

	function TimeAPI:ValidateSubSecondPrecision(subSecondPrecision)
		subSecondPrecision = tonumber(subSecondPrecision)

		if not subSecondPrecision then
			return SUB_SECOND_PRECISION.max
		end

		return imports.math.api:Limit(
			subSecondPrecision,
			SUB_SECOND_PRECISION.min,
			SUB_SECOND_PRECISION.max
		)
	end


	return TimeAPI
end)
