local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection('movementSpeed'):AddMixin('api', function()
	local MovementSpeedAPI = {}

	function MovementSpeedAPI:GetMovementSpeedPercent(movementSpeed)
		local adjustedMovementSpeed

		if movementSpeed == 0 then
			adjustedMovementSpeed = movementSpeed
		else
			adjustedMovementSpeed = movementSpeed - BASE_MOVEMENT_SPEED
		end

		local movementSpeedPercent = math.floor(adjustedMovementSpeed / BASE_MOVEMENT_SPEED * 100)
		local movementSpeedPercentTotal = math.floor(movementSpeed / BASE_MOVEMENT_SPEED * 100)

		return movementSpeedPercent, movementSpeedPercentTotal
	end

	function MovementSpeedAPI:GetMovementSpeedPercentString(movementSpeed)
		local movementSpeedPercent = self:GetMovementSpeedPercent(movementSpeed)

		local movementSpeedPercentString

		if movementSpeedPercent > 0 then
			movementSpeedPercentString = '+' .. movementSpeedPercent
		else
			movementSpeedPercentString = movementSpeedPercent
		end

		return movementSpeedPercentString .. '%'
	end


	return MovementSpeedAPI
end)
