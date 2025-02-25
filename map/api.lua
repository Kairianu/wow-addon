local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection("map"):AddMixin("api", function()
	local MapAPI = {}

	function MapAPI:FormatCoordinate(coordinate)
		return math.floor(coordinate * 10000 + 0.5) / 10000
	end

	function MapAPI:FormatCoordinates(x, y)
		return self:FormatCoordinate(x), self:FormatCoordinate(y)
	end


	return MapAPI
end)
