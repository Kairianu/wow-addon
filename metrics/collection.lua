local addonName, addonData = ...


addonData.CollectionsAPI:CreateCollection("metrics")




-- CombatLogGetCurrentEventInfo: default 11 args, additional 13 args possible based on combatEvent
-- local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destinationGUID, destinationName, destinationFlags, destinationRaidFlags = CombatLogGetCurrentEventInfo()
