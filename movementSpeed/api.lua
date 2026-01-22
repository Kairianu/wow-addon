local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection('movementSpeed'):AddMixin('api', function()
	local MovementSpeedAPI = {}

	function MovementSpeedAPI:ValidateMovementSpeed(movementSpeed)
		movementSpeed = tonumber(movementSpeed)

		if not movementSpeed then
			movementSpeed = self:GetCurrentMovementSpeed()
		end

		return math.abs(movementSpeed)
	end

	function MovementSpeedAPI:GetCurrentMovementSpeed()
		local isGliding, _, glidingSpeed = C_PlayerInfo.GetGlidingInfo()

		local currentMovementSpeed

		if isGliding then
			currentMovementSpeed = math.max(0, glidingSpeed)
		else
			currentMovementSpeed = GetUnitSpeed('player')
		end

		return currentMovementSpeed
	end

	function MovementSpeedAPI:GetMovementSpeedPercent(movementSpeed)
		movementSpeed = self:ValidateMovementSpeed(movementSpeed)

		return movementSpeed / BASE_MOVEMENT_SPEED
	end

	function MovementSpeedAPI:GetOffsetMovementSpeedPercent(movementSpeed)
		local movementSpeedPercent = self:GetMovementSpeedPercent(movementSpeed)

		return movementSpeedPercent - 1
	end

	function MovementSpeedAPI:GetReadableMovementSpeedPercent(movementSpeedPercent)
		return math.floor(movementSpeedPercent * 100)
	end

	function MovementSpeedAPI:GetReadableMovementSpeedPercentString(movementSpeedPercent)
		local readableMovementSpeedPercent = self:GetReadableMovementSpeedPercent(movementSpeedPercent)

		return readableMovementSpeedPercent .. '%'
	end

	function MovementSpeedAPI:GetMovementSpeedPercentString(movementSpeed)
		local movementSpeedPercent = self:GetMovementSpeedPercent(movementSpeed)

		return self:GetReadableMovementSpeedPercentString(movementSpeedPercent)
	end

	function MovementSpeedAPI:GetOffsetMovementSpeedPercentString(movementSpeed)
		local offsetMovementSpeedPercent = self:GetOffsetMovementSpeedPercent(movementSpeed)

		local readableOffsetMovementSpeedPercentString = self:GetReadableMovementSpeedPercentString(offsetMovementSpeedPercent)

		if offsetMovementSpeedPercent >= 0 then
			readableOffsetMovementSpeedPercentString = '+' .. readableOffsetMovementSpeedPercentString
		end

		return readableOffsetMovementSpeedPercentString
	end


	return MovementSpeedAPI
end)
