local addonName, addonData = ...

--[[ legion class quests
	47039 - marksmanship-the-twisted-twin
]]

--[[ tww daily quests
	80187 - preserving in skirmishes
	80189 - preserving teamwork
	80592 - forge a pact
	80672 - hand of the vizier
	81796 - sparks of war: azj-kahet
	82678 - archives: the first disc
	82679 - archives: seeking history
	83345 - a call to battle
	83469 - city of threads
]]

--[[ tww leveing weeklys(/dailys?)
	82452 - worldsoul: world quests
	82516 - worldsoul: forging a pact
	82489 - worldsoul: the dawnbreaker
]]


addonData.CollectionsAPI:GetCollection('quest'):AddRawData('quests', function()
	return {
		[8149] = {
			categoryID = 22,
			obtain = {
				id = 15011,
				type = "npc",
			},
		},

		[8311] = {
			categoryID = 21,
			obtain = {
				id = 15310,
				type = "npc",
			},
		},

		[8312] = {
			categoryID = 21,
			obtain = {
				id = 15309,
				type = "npc",
			},
			complete = {
				id = 15309,
				type = "npc",
			},
		},

		[8354] = {
			categoryID = 21,
			obtain = {
				id = 6741,
				type = "npc",
			},
			complete = {
				id = 6741,
				type = "npc",
			},
		},

		[8356] = {
			categoryID = 21,
			obtain = {
				id = 6740,
				type = "npc",
			},
			complete = {
				id = 6740,
				type = "npc",
			},
		},

		[8358] = {
			categoryID = 21,
			obtain = {
				id = 11814,
				type = "npc",
			},
			complete = {
				id = 11814,
				type = "npc",
			},
		},

		[8359] = {
			categoryID = 21,
			obtain = {
				id = 6929,
				type = "npc",
			},
			complete = {
				id = 6929,
				type = "npc",
			},
		},

		[8360] = {
			categoryID = 21,
			obtain = {
				id = 6746,
				type = "npc",
			},
			complete = {
				id = 6746,
				type = "npc",
			},
		},

		[11117] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5505,
				y = 0.377,
			},
		},

		[11118] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5505,
				y = 0.377,
			},
		},

		[11120] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4127,
				y = 0.1848,
			},
			factionID = LE_QUEST_FACTION_HORDE,
		},

		[11122] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5365,
				y = 0.3854,
			},
		},

		[11131] = {
			categoryID = 21,
			obtain = {
				id = 24519,
				type = "npc",
			},
		},

		[11293] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.56,
				y = 0.3811,
			},
		},

		[11294] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5657,
				y = 0.3683,
			},
		},

		[11318] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5365,
				y = 0.3854,
			},
		},

		[11356] = {
			categoryID = 21,
			obtain = {
				{
					id = 18927,
					type = "npc",
				},
				{
					id = 19148,
					type = "npc",
				},
			},
			complete = {
				id = 24519,
				type = "npc",
			},
		},

		[11360] = {
			categoryID = 21,
			obtain = {
				id = 24519,
				type = "npc",
			},
		},

		[11407] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4049,
				y = 0.1831,
			},
		},

		[11408] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4026,
				y = 0.1693,
			},
		},

		[11409] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4262,
				y = 0.1784,
			},
		},

		[11412] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4262,
				y = 0.1784,
			},
		},

		[11431] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4127,
				y = 0.1848,
			},
		},

		[11441] = {
			categoryID = 370,
			location = {
				uiMapID = 84,
				x = 0.6167,
				y = 0.7418,
			},
		},

		[11446] = {
			categoryID = 370,
			obtain = {
				id = 19175,
				type = "npc",
			},
		},

		[12022] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5471,
				y = 0.3803,
			},
		},

		[12133] = {
			categoryID = 21,
			obtain = {
				id = 186887,
				type = "object",
			},
		},

		[12135] = {
			categoryID = 21,
			obtain = {
				id = 24519,
				type = "npc",
			},
		},

		[12191] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4163,
				y = 0.1752,
			},
		},

		[12278] = {
			categoryID = 370,
			obtain = {
				id = 27478,
				type = "npc",
			},
		},

		[12492] = {
			categoryID = 370,
			location = {
				uiMapID = 243,
				x = 0.466,
				y = 0.6,
			},
		},

		[13952] = {
			categoryID = 41,
			obtain = {
				id = 34435,
				type = "npc",
			},
			raceID = {1, 32},
		},

		[14022] = {
			categoryID = 375,
			obtain = {
				id = 18927,
				type = "npc",
			},
			complete = {
				id = 34675,
				type = "npc",
			},
		},

		[14023] = {
			categoryID = 375,
			obtain = {
				id = 34675,
				type = "npc",
			},
			complete = {
				id = 0,
				type = "npc",
			},
		},

		[29054] = {
			categoryID = 21,
			obtain = {
				id = 51934,
				type = "npc",
			},
			progress = {
				id = 52548,
				type = "npc",
			},
			complete = {
				id = 51934,
				type = "npc",
			},
		},

		[29074] = {
			categoryID = 21,
			obtain = {
				{
					id = 18927,
					type = "npc",
				},
				{
					id = 19148,
					type = "npc",
				},
			},
		},

		[29075] = {
			categoryID = 21,
			obtain = {
				id = 51665,
				type = "npc",
			},
		},

		[29144] = {
			categoryID = 21,
			obtain = {
				id = 51934,
				type = "npc",
			},
			complete = {
				id = 51934,
				type = "npc",
			},
		},

		[29371] = {
			categoryID = 21,
			obtain = {
				id = 52064,
				type = "npc",
			},
			progress = {
				id = 53737,
				positionIndex = 1,
				type = "npc",
			},
		},

		[29374] = {
			categoryID = 21,
			obtain = {
				id = 53763,
				type = "npc",
			},
			complete = {
				id = 53763,
				type = "npc",
			},
		},

		[29375] = {
			categoryID = 21,
			obtain = {
				id = 53763,
				type = "npc",
			},
			complete = {
				id = 53763,
				type = "npc",
			},
		},

		[29376] = {
			categoryID = 21,
			obtain = {
				id = 15197,
				type = "npc",
			},
			complete = {
				id = 15197,
				type = "npc",
			},
		},

		[29377] = {
			categoryID = 21,
			obtain = {
				id = 15197,
				type = "npc",
			},
			progress = {
				id = 53737,
				positionIndex = 2,
				type = "npc",
			},
			complete = {
				id = 15197,
				type = "npc",
			},
		},

		[29392] = {
			categoryID = 21,
			obtain = {
				id = 53949,
				type = "npc",
			},
		},

		[29393] = {
			categoryID = 370,
			obtain = {
				id = 24497,
				type = "npc",
			},
		},

		[29394] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5365,
				y = 0.3854,
			},
		},

		[29397] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5356,
				y = 0.3856,
			},
		},

		[29430] = {
			categoryID = 21,
			obtain = {
				id = 51934,
				type = "npc",
			},
			complete = {
				id = 53949,
				type = "npc",
			},
		},

		[39716] = {
			categoryID = 21,
			obtain = {
				id = 96705,
				type = "npc",
			},
			complete = {
				id = 96362,
				type = "npc",
			},
		},

		[39719] = {
			categoryID = 21,
			obtain = {
				id = 96705,
				type = "npc",
			},
			complete = {
				id = 96362,
				type = "npc",
			},
		},

		[39720] = {
			categoryID = 21,
			obtain = {
				id = 96705,
				type = "npc",
			},
			complete = {
				id = 96362,
				type = "npc",
			},
		},

		[39721] = {
			categoryID = 21,
			obtain = {
				id = 96705,
				type = "npc",
			},
			complete = {
				id = 96362,
				type = "npc",
			},
		},

		[43055] = {
			categoryID = 21,
			obtain = {
				id = 251670,
				type = "object",
			},
		},

		[43162] = {
			categoryID = 21,
			obtain = {
				id = 109734,
				type = "npc",
			},
			progress = {
				id = 251706,
				type = "object",
			},
			complete = {
				id = 109734,
				type = "npc",
			},
		},

		[43259] = {
			categoryID = 21,
			obtain = {
				id = 109854,
				type = "npc",
			},
			complete = {
				id = 109734,
				type = "npc",
			},
		},

		[56322] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5555,
				y = 0.3764,
			},
		},

		[56341] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5555,
				y = 0.3764,
			},
		},

		[56372] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5555,
				y = 0.3764,
			},
		},

		[56714] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4097,
				y = 0.1773,
			},
		},

		[56716] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4097,
				y = 0.1772,
			},
		},

		[56748] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4228,
				y = 0.1844,
			},
		},

		[56764] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5481,
				y = 0.3859,
			},
		},

		[76072] = {
			categoryID = 21,
			obtain = {
				id = 206158,
				type = "npc",
			},
			complete = {
				id = 205473,
				type = "npc",
			},
		},

		[76073] = {
			categoryID = 21,
			obtain = {
				id = 205473,
				type = "npc",
			},
			progress = {
				{
					id = 209078,
					type = "npc",
				},
				{
					id = 209216,
					type = "npc",
				},
				{
					id = 209217,
					type = "npc",
				},
			},
			complete = {
				id = 205448,
				type = "npc",
			},
			secondary = {
				complete = {
					{
						id = 404269,
						type = "object",
					},
				},
			},
		},

		[76074] = {
			categoryID = 21,
			obtain = {
				id = 205448,
				type = "npc",
			},
			complete = {
				id = 209609,
				type = "npc",
			},
			secondary = {
				progress = {
					{
						id = 209640,
						positionIndex = 1,
						type = "npc",
					},
				},
			},
		},

		[76075] = {
			categoryID = 21,
			obtain = {
				{
					id = 53865,
					type = "npc",
				},
				{
					id = 53869,
					type = "npc",
				},
			},
		},

		[76531] = {
			categoryID = 370,
			location = {
				uiMapID = 2022,
				x = 0.5828,
				y = 0.6755,
			},
		},

		[76577] = {
			categoryID = 370,
			location = {
				uiMapID = 27,
				x = 0.5512,
				y = 0.3807,
			},
		},

		[76579] = {
			categoryID = 370,
			location = {
				uiMapID = 1,
				x = 0.4154,
				y = 0.1837,
			},
		},

		[76591] = {
			categoryID = 370,
			location = {
				uiMapID = 2112,
				x = 0.2974,
				y = 0.5617,
			},
		},

		[77095] = {
			categoryID = 370,
			location = {
				uiMapID = 2022,
				x = 0.7637,
				y = 0.3543,
			},
		},

		[77096] = {
			categoryID = 370,
			location = {
				uiMapID = 2024,
				x = 0.469,
				y = 0.402,
			},
		},

		[77097] = {
			categoryID = 370,
			location = {
				uiMapID = 2024,
				x = 0.1237,
				y = 0.4932,
			},
		},

		[77099] = {
			categoryID = 370,
			location = {
				uiMapID = 2023,
				x = 0.2859,
				y = 0.6044,
			},
		},

		[77152] = {
			categoryID = 370,
			location = {
				uiMapID = 2023,
				x = 0.5978,
				y = 0.3872,
			},
		},

		[77153] = {
			categoryID = 370,
			location = {
				uiMapID = 2112,
				x = 0.4788,
				y = 0.466,
			},
		},

		[77155] = {
			categoryID = 370,
			location = {
				uiMapID = 2025,
				x = 0.5218,
				y = 0.8149,
			},
		},

		[77208] = {
			categoryID = 370,
			location = {
				uiMapID = 2112,
				x = 0.2974,
				y = 0.5617,
			},
		},

		[77744] = {
			categoryID = 370,
			location = {
				uiMapID = 2022,
				x = 0.4767,
				y = 0.833,
			},
		},

		[77745] = {
			categoryID = 370,
			location = {
				uiMapID = 2023,
				x = 0.8582,
				y = 0.3533,
			},
		},

		[77746] = {
			categoryID = 370,
			location = {
				uiMapID = 2024,
				x = 0.6278,
				y = 0.5772,
			},
		},

		[77747] = {
			categoryID = 370,
			location = {
				uiMapID = 2025,
				x = 0.5009,
				y = 0.427,
			},
		},

		[77779] = {
			categoryID = 21,
			obtain = {
				id = 209609,
				type = "npc",
			},
			complete = {
				id = 53869,
				type = "npc",
			},
		},

		[78444] = {
			obtain = {
				id = 208143,
				type = "npc",
			},
		},
	}
end)
