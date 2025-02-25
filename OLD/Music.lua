local addonName, addonTable = ...


local DALARAN_MUSIC_IDS = {
	229800,
	229801,
	229802,
	229803,
	229804,
	229805,
	229806,
	229807,
	229808,
	229809,
	1417233,
	1417234,
	1417235,
	1417236,
	1417237,
	1417238,
	1417239,
	1417251,
	1417252,
	1417253,
	1417254,
	1417255,
	1417256,
	1417257,
	1417258,
	1417259,
	1417260,
	1417261,
	1417262,
	1417263,
	1417264,
	1417265,
	1417266,
	1417267,
	1417268,
	1417269,
	1417270,
	1417271,
	1417272,
	1417273,
	1417274,
	1417275,
	1417276,
}


local C_Music = {}
addonTable.C_Music = C_Music



local EventFrame = CreateFrame("EventFrame")
EventFrame:RegisterEvent("FIRST_FRAME_RENDERED")
EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
EventFrame:SetScript("OnEvent", function()
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if uiMapID == 84 then
		PlayMusic(addonTable.C_Table:GetRandomItem(DALARAN_MUSIC_IDS))
	end
end)




SLASH_MUSIC_PLAY1 = "/music"
SLASH_MUSIC_PLAY2 = "/m"
SlashCmdList["MUSIC_PLAY"] = function(argString)
	if argString == "" then
		local musicEnabledCVar = "Sound_EnableMusic"

		if C_CVar.GetCVar(musicEnabledCVar) == "1" then
			C_CVar.SetCVar(musicEnabledCVar, "0")
			C_CVar.SetCVar(musicEnabledCVar, "1")
		end
	elseif argString == "f" then
		PlayMusic(addonTable.C_Table:GetRandomItem(DALARAN_MUSIC_IDS))
	else
		PlayMusic(argString)
	end
end
