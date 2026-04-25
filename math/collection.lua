local addonName, addonData = ...


local MathCollection = addonData.CollectionsAPI:CreateCollection('math')





MathCollection:AddMixin('api', function()
	local MathAPI = {}

	function MathAPI:Limit(value, min, max)
		if value < min then
			return min
		elseif value > max then
			return max
		end

		return value
	end

	function MathAPI:MaxLimit(value, max)
		if value > max then
			return max
		end

		return value
	end

	function MathAPI:MinLimit(value, min)
		if value < min then
			return min
		end

		return value
	end

	function MathAPI:Round(value)
		return math.floor(value + 0.5)
	end


	return MathAPI
end)
