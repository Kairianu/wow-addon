local addonName, addonData = ...


addonData.CollectionsAPI:GetCollection('quest'):AddMixin('database', function(collection)
	local QuestDatabase = {}

	function QuestDatabase:IsQuestCompleted(questID)
		local questsRawData = collection:GetRawData('quests')

		local questData = questsRawData[questID]

		if questData then
			if type(questData.isCompleted) == 'function' then
				return questData.isCompleted()
			end
		end

		return C_QuestLog.IsQuestFlaggedCompleted(questID)
	end


	return QuestDatabase
end)
