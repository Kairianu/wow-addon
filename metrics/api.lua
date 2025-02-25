local addonName, addonData = ...


local knownDamageEvents = {
	['RANGE_DAMAGE'] = true,
	['SPELL_DAMAGE'] = true,
	['SPELL_PERIODIC_DAMAGE'] = true,
	['SWING_DAMAGE'] = true,
}



local MetricsEventFrame = CreateFrame('frame')

MetricsEventFrame.metricsData = {}

function MetricsEventFrame:GetOrCreateUnitMetricsData(unitGUID)
	local unitMetricsData = self.metricsData[unitGUID]

	if not unitMetricsData then
		unitMetricsData = {
			damage = {},
			healing = {},
		}

		self.metricsData[unitGUID] = unitMetricsData
	end

	return unitMetricsData
end

function MetricsEventFrame:ResetUnitDamage(unitGUID)
	local unitMetricsData = self.metricsData[unitGUID]

	if not unitMetricsData then
		return
	end

	unitMetricsData.damage = {}
end

function MetricsEventFrame:OnCombatLogEventUnfiltered()
	local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destinationGUID, destinationName, destinationFlags, destinationRaidFlags = CombatLogGetCurrentEventInfo()

	local currentDamageAmount

	if combatEvent == 'RANGE_DAMAGE' then
		local spellID, spellName, spellSchool, damageAmount, overkillAmount, damageSpellSchool, _, _, _, isCritical, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

		currentDamageAmount = damageAmount
	elseif combatEvent == 'SPELL_DAMAGE' then
		local spellID, spellName, spellSchool, damageAmount, overkillAmount, damageSpellSchool, _, _, _, isCritical, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

		currentDamageAmount = damageAmount
	elseif combatEvent == 'SPELL_PERIODIC_DAMAGE' then
		local spellID, spellName, spellSchool, damageAmount, overkillAmount, damageSpellSchool, _, _, _, isCritical, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

		currentDamageAmount = damageAmount
	elseif combatEvent == 'SWING_DAMAGE' then
		local damageAmount, overkillAmount, _, _, _, _, isCritical, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

		currentDamageAmount = damageAmount
	end

	if currentDamageAmount then
		local unitMetricsData = self:GetOrCreateUnitMetricsData(sourceGUID)

		local currentTime = GetTime()
		local unitDamageUpdateTime = unitMetricsData.damage.updateTime

		if unitDamageUpdateTime then
			if unitDamageUpdateTime < currentTime - 10 then
				unitMetricsData.damage.amount = 0
				unitMetricsData.damage.startTime = currentTime
			end
		end

		if not unitMetricsData.damage.startTime then
			unitMetricsData.damage.startTime = currentTime
		end

		if not unitMetricsData.damage.amount then
			unitMetricsData.damage.amount = 0
		end

		unitMetricsData.damage.amount = unitMetricsData.damage.amount + currentDamageAmount
		unitMetricsData.damage.updateTime = currentTime
	end
end

MetricsEventFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

MetricsEventFrame:SetScript('onEvent', function(self, event)
	if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		self:OnCombatLogEventUnfiltered()
	end
end)



addonData.CollectionsAPI:GetCollection('metrics'):AddMixin('api', function()
	local MetricsAPI = {}

	function MetricsAPI:GetUnitMetricsData(unitGUID)
		return MetricsEventFrame:GetOrCreateUnitMetricsData(unitGUID)
	end

	function MetricsAPI:GetUnitDamage(unitGUID)
		return self:GetUnitMetricsData(unitGUID).damage.amount or 0
	end

	function MetricsAPI:GetUnitDamagePerSecond(unitGUID)
		local unitMetricsData = MetricsEventFrame:GetOrCreateUnitMetricsData(unitGUID)

		local unitDamageAmount = unitMetricsData.damage.amount
		local unitDamageStartTime = unitMetricsData.damage.startTime

		if not unitDamageAmount or not unitDamageStartTime then
			return 0
		end

		local currentTime = GetTime()
		local unitDamageTimeDifference
		local unitDamageUpdateTime = unitMetricsData.damage.updateTime

		if currentTime > unitDamageUpdateTime + 5 then
			unitDamageTimeDifference = unitDamageUpdateTime - unitDamageStartTime
		else
			unitDamageTimeDifference = currentTime - unitDamageStartTime
		end

		if unitDamageTimeDifference == 0 then
			return unitDamageAmount
		end

		return unitDamageAmount / unitDamageTimeDifference
	end

	function MetricsAPI:ResetUnitDamage(unitGUID)
		MetricsEventFrame:ResetUnitDamage(unitGUID)
	end


	return MetricsAPI
end)
