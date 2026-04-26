local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection('quest'):AddMixin('api', function()
	local QuestAPI = {}

	function QuestAPI:GetPlayerQuests()
		local playerQuests = {}

		local numQuestLogEntries = C_QuestLog.GetNumQuestLogEntries()

		for questLogIndex = 1, numQuestLogEntries do
			local questLogEntryInfo = C_QuestLog.GetInfo(questLogIndex)

			if not questLogEntryInfo.isHeader and not questLogEntryInfo.isHidden then
				table.insert(playerQuests, questLogEntryInfo)
			end
		end

		return playerQuests
	end


	return QuestAPI
end)
