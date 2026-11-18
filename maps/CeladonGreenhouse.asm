	object_const_def
	const CELADON_GREENHOUSE_GYM_GUIDE
	const CELADON_GREENHOUSE_BUG_CATCHER
	const CELADON_GREENHOUSE_SAILOR
	const CELADON_GREENHOUSE_FRUIT_TREE1
	const CELADON_GREENHOUSE_FRUIT_TREE2
	const CELADON_GREENHOUSE_FRUIT_TREE3
	const CELADON_GREENHOUSE_FRUIT_TREE4

CeladonGreenhouse_MapScripts:
	def_scene_scripts

	def_callbacks

GreenhousePlot1Script:
	faceplayer
	opentext
	readmem wGreenhousePlot1
	ifequal 0, .Empty
	; Something is planted — is it ready?
	checkevent EVENT_GREENHOUSE_PLOT1_GROWN
	iftrue .ReadyToHarvest
	; Planted but not grown yet
	checkevent EVENT_GREENHOUSE_PLOT1_WATERED
	iftrue .AlreadyWatered
	; Not watered yet — does the player have the bottle?
	checkitem SQUIRTBOTTLE
	iftrue .OfferWater
	; No bottle, just describe the seedling
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.OfferWater:
	writetext GreenhouseWaterPromptText
	yesorno
	iffalse .DeclineWater
	setevent EVENT_GREENHOUSE_PLOT1_WATERED
	writetext GreenhouseWateredText
	waitbutton
	closetext
	end

.DeclineWater:
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.AlreadyWatered:
	writetext GreenhouseAlreadyWateredText
	waitbutton
	closetext
	end

.ReadyToHarvest:
	; Set up the berry name for display text
	readmem wGreenhousePlot1
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext GreenhouseReadyText
	promptbutton
	; Determine yield based on watered status
	checkevent EVENT_GREENHOUSE_PLOT1_WATERED
	iftrue .WateredYield
	; Unwatered: 1–2
	random 2
	ifequal 0, .GiveOne
	sjump .GiveTwo

.WateredYield:
	; Watered: 2–3
	random 2
	ifequal 0, .GiveTwo
	sjump .GiveThree

.GiveThree:
	readmem wGreenhousePlot1
	giveitem ITEM_FROM_MEM, 3
	iffalse .GiveTwo
	promptbutton
	writetext GreenhousePickedThreeText
	sjump .FinishHarvest

.GiveTwo:
	readmem wGreenhousePlot1
	giveitem ITEM_FROM_MEM, 2
	iffalse .GiveOne
	promptbutton
	writetext GreenhousePickedTwoText
	sjump .FinishHarvest

.GiveOne:
	readmem wGreenhousePlot1
	giveitem ITEM_FROM_MEM
	iffalse .PackFull
	promptbutton
	writetext GreenhousePickedOneText
	sjump .FinishHarvest

.FinishHarvest:
	specialsound
	itemnotify
	; Reset the plot for next use
	loadmem wGreenhousePlot1, 0
	clearevent EVENT_GREENHOUSE_PLOT1_GROWN
	clearevent EVENT_GREENHOUSE_PLOT1_WATERED
	closetext
	end

.PackFull:
	promptbutton
	writetext GreenhousePackFullText
	waitbutton
	closetext
	end

.Empty:
	writetext GreenhouseEmptyPlotText
	yesorno
	iffalse .DeclinePlant
	special SelectBerryForGreenhouse
	ifequal 0, .DeclinePlant
	; wScriptVar now holds the berry item ID
	writemem wGreenhousePlot1
	clearevent EVENT_GREENHOUSE_PLOT1_GROWN
	clearevent EVENT_GREENHOUSE_PLOT1_WATERED
	writetext GreenhousePlantedText
	waitbutton
	closetext
	end

.DeclinePlant:
	closetext
	end

GreenhousePlot2Script:
	faceplayer
	opentext
	readmem wGreenhousePlot2
	ifequal 0, .Empty
	checkevent EVENT_GREENHOUSE_PLOT2_GROWN
	iftrue .ReadyToHarvest
	checkevent EVENT_GREENHOUSE_PLOT2_WATERED
	iftrue .AlreadyWatered
	checkitem SQUIRTBOTTLE
	iftrue .OfferWater
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.OfferWater:
	writetext GreenhouseWaterPromptText
	yesorno
	iffalse .DeclineWater
	setevent EVENT_GREENHOUSE_PLOT2_WATERED
	writetext GreenhouseWateredText
	waitbutton
	closetext
	end

.DeclineWater:
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.AlreadyWatered:
	writetext GreenhouseAlreadyWateredText
	waitbutton
	closetext
	end

.ReadyToHarvest:
	readmem wGreenhousePlot2
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext GreenhouseReadyText
	promptbutton
	checkevent EVENT_GREENHOUSE_PLOT2_WATERED
	iftrue .WateredYield
	random 2
	ifequal 0, .GiveOne
	sjump .GiveTwo

.WateredYield:
	random 2
	ifequal 0, .GiveTwo
	sjump .GiveThree

.GiveThree:
	readmem wGreenhousePlot2
	giveitem ITEM_FROM_MEM, 3
	iffalse .GiveTwo
	promptbutton
	writetext GreenhousePickedThreeText
	sjump .FinishHarvest

.GiveTwo:
	readmem wGreenhousePlot2
	giveitem ITEM_FROM_MEM, 2
	iffalse .GiveOne
	promptbutton
	writetext GreenhousePickedTwoText
	sjump .FinishHarvest

.GiveOne:
	readmem wGreenhousePlot2
	giveitem ITEM_FROM_MEM
	iffalse .PackFull
	promptbutton
	writetext GreenhousePickedOneText
	sjump .FinishHarvest

.FinishHarvest:
	specialsound
	itemnotify
	loadmem wGreenhousePlot2, 0
	clearevent EVENT_GREENHOUSE_PLOT2_GROWN
	clearevent EVENT_GREENHOUSE_PLOT2_WATERED
	closetext
	end

.PackFull:
	promptbutton
	writetext GreenhousePackFullText
	waitbutton
	closetext
	end

.Empty:
	writetext GreenhouseEmptyPlotText
	yesorno
	iffalse .DeclinePlant
	special SelectBerryForGreenhouse
	ifequal 0, .DeclinePlant
	writemem wGreenhousePlot2
	clearevent EVENT_GREENHOUSE_PLOT2_GROWN
	clearevent EVENT_GREENHOUSE_PLOT2_WATERED
	writetext GreenhousePlantedText
	waitbutton
	closetext
	end

.DeclinePlant:
	closetext
	end

GreenhousePlot3Script:
	faceplayer
	opentext
	readmem wGreenhousePlot3
	ifequal 0, .Empty
	checkevent EVENT_GREENHOUSE_PLOT3_GROWN
	iftrue .ReadyToHarvest
	checkevent EVENT_GREENHOUSE_PLOT3_WATERED
	iftrue .AlreadyWatered
	checkitem SQUIRTBOTTLE
	iftrue .OfferWater
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.OfferWater:
	writetext GreenhouseWaterPromptText
	yesorno
	iffalse .DeclineWater
	setevent EVENT_GREENHOUSE_PLOT3_WATERED
	writetext GreenhouseWateredText
	waitbutton
	closetext
	end

.DeclineWater:
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.AlreadyWatered:
	writetext GreenhouseAlreadyWateredText
	waitbutton
	closetext
	end

.ReadyToHarvest:
	readmem wGreenhousePlot3
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext GreenhouseReadyText
	promptbutton
	checkevent EVENT_GREENHOUSE_PLOT3_WATERED
	iftrue .WateredYield
	random 2
	ifequal 0, .GiveOne
	sjump .GiveTwo

.WateredYield:
	random 2
	ifequal 0, .GiveTwo
	sjump .GiveThree

.GiveThree:
	readmem wGreenhousePlot3
	giveitem ITEM_FROM_MEM, 3
	iffalse .GiveTwo
	promptbutton
	writetext GreenhousePickedThreeText
	sjump .FinishHarvest

.GiveTwo:
	readmem wGreenhousePlot3
	giveitem ITEM_FROM_MEM, 2
	iffalse .GiveOne
	promptbutton
	writetext GreenhousePickedTwoText
	sjump .FinishHarvest

.GiveOne:
	readmem wGreenhousePlot3
	giveitem ITEM_FROM_MEM
	iffalse .PackFull
	promptbutton
	writetext GreenhousePickedOneText
	sjump .FinishHarvest

.FinishHarvest:
	specialsound
	itemnotify
	loadmem wGreenhousePlot3, 0
	clearevent EVENT_GREENHOUSE_PLOT3_GROWN
	clearevent EVENT_GREENHOUSE_PLOT3_WATERED
	closetext
	end

.PackFull:
	promptbutton
	writetext GreenhousePackFullText
	waitbutton
	closetext
	end

.Empty:
	writetext GreenhouseEmptyPlotText
	yesorno
	iffalse .DeclinePlant
	special SelectBerryForGreenhouse
	ifequal 0, .DeclinePlant
	writemem wGreenhousePlot3
	clearevent EVENT_GREENHOUSE_PLOT3_GROWN
	clearevent EVENT_GREENHOUSE_PLOT3_WATERED
	writetext GreenhousePlantedText
	waitbutton
	closetext
	end

.DeclinePlant:
	closetext
	end

GreenhousePlot4Script:
	faceplayer
	opentext
	readmem wGreenhousePlot4
	ifequal 0, .Empty
	checkevent EVENT_GREENHOUSE_PLOT4_GROWN
	iftrue .ReadyToHarvest
	checkevent EVENT_GREENHOUSE_PLOT4_WATERED
	iftrue .AlreadyWatered
	checkitem SQUIRTBOTTLE
	iftrue .OfferWater
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.OfferWater:
	writetext GreenhouseWaterPromptText
	yesorno
	iffalse .DeclineWater
	setevent EVENT_GREENHOUSE_PLOT4_WATERED
	writetext GreenhouseWateredText
	waitbutton
	closetext
	end

.DeclineWater:
	writetext GreenhouseSeedlingText
	waitbutton
	closetext
	end

.AlreadyWatered:
	writetext GreenhouseAlreadyWateredText
	waitbutton
	closetext
	end

.ReadyToHarvest:
	readmem wGreenhousePlot4
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext GreenhouseReadyText
	promptbutton
	checkevent EVENT_GREENHOUSE_PLOT4_WATERED
	iftrue .WateredYield
	random 2
	ifequal 0, .GiveOne
	sjump .GiveTwo

.WateredYield:
	random 2
	ifequal 0, .GiveTwo
	sjump .GiveThree

.GiveThree:
	readmem wGreenhousePlot4
	giveitem ITEM_FROM_MEM, 3
	iffalse .GiveTwo
	promptbutton
	writetext GreenhousePickedThreeText
	sjump .FinishHarvest

.GiveTwo:
	readmem wGreenhousePlot4
	giveitem ITEM_FROM_MEM, 2
	iffalse .GiveOne
	promptbutton
	writetext GreenhousePickedTwoText
	sjump .FinishHarvest

.GiveOne:
	readmem wGreenhousePlot4
	giveitem ITEM_FROM_MEM
	iffalse .PackFull
	promptbutton
	writetext GreenhousePickedOneText
	sjump .FinishHarvest

.FinishHarvest:
	specialsound
	itemnotify
	loadmem wGreenhousePlot4, 0
	clearevent EVENT_GREENHOUSE_PLOT4_GROWN
	clearevent EVENT_GREENHOUSE_PLOT4_WATERED
	closetext
	end

.PackFull:
	promptbutton
	writetext GreenhousePackFullText
	waitbutton
	closetext
	end

.Empty:
	writetext GreenhouseEmptyPlotText
	yesorno
	iffalse .DeclinePlant
	special SelectBerryForGreenhouse
	ifequal 0, .DeclinePlant
	writemem wGreenhousePlot4
	clearevent EVENT_GREENHOUSE_PLOT4_GROWN
	clearevent EVENT_GREENHOUSE_PLOT4_WATERED
	writetext GreenhousePlantedText
	waitbutton
	closetext
	end

.DeclinePlant:
	closetext
	end

GreenhouseGymGuideScript:
	jumptextfaceplayer GreenhouseGymGuideText

GreenhouseBugCatcherScript:
	jumptextfaceplayer GreenhouseBugCatcherText

GreenhouseSailorScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_SQUIRTBOTTLE
	iftrue .GotBottle
	callasm .CheckGrassTypeCompletion
	iftrue .GiveBottle
	writetext GreenhouseSailorText
	waitbutton
	closetext
	end

.GiveBottle:
	writetext GreenhouseSailorCaughtAllGrassText
	promptbutton
	verbosegiveitem SQUIRTBOTTLE
	iffalse .BagFull
	setevent EVENT_GOT_SQUIRTBOTTLE
.GotBottle:
	writetext GreenhouseSailorAfterText
	waitbutton
.BagFull:
	closetext
	end

.CheckGrassTypeCompletion:
	ld a, GRASS
	farcall CheckAllTypeSpeciesCaught
	sbc a
	and 1
	ld [wScriptVar], a
	ret

GreenhouseWeirdTreeScript:
	jumptextfaceplayer GreenhouseWeirdTreeText

GreenhouseEmptyPlotText:
	text "This plot is"
	line "empty."

	para "Plant a BERRY?"
	done

GreenhousePlantedText:
	text "Planted the BERRY"
	line "in the soil."

	para "Come back tomorrow"
	line "to harvest."
	done

GreenhouseSeedlingText:
	text "A small seedling"
	line "is growing."

	para "It's not ready"
	line "for harvest yet."
	done

GreenhouseWaterPromptText:
	text "A small seedling"
	line "is growing."

	para "Water it with the"
	line "SQUIRTBOTTLE?"
	done

GreenhouseWateredText:
	text "Watered the"
	line "seedling."

	para "That should help"
	line "it grow strong."
	done

GreenhouseAlreadyWateredText:
	text "A small seedling"
	line "is growing."

	para "The soil is nice"
	line "and moist."
	done

GreenhouseReadyText:
	text "The tree is"
	line "bearing"
	cont "@"
	text_ram wStringBuffer3
	text "S!"
	done

GreenhousePickedOneText:
	text "Picked a"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

GreenhousePickedTwoText:
	text "Picked two"
	line "@"
	text_ram wStringBuffer3
	text "S!"
	done

GreenhousePickedThreeText:
	text "Picked three"
	line "@"
	text_ram wStringBuffer3
	text "S!"
	done

GreenhousePackFullText:
	text "But the PACK is"
	line "full…"
	done

GreenhouseGymGuideText:
	text "The GREENHOUSE is"
	line "always warm in"
	cont "winter."
	done

GreenhouseBugCatcherText:
	text "I'm trying to work"
	line "out what that"
	cont "weird tree is…"
	done

GreenhouseSailorText:
	text "These trees grow"
	line "BERRIES if you"
	cont "water them with a"
	cont "SQUIRTBOTTLE."

	para "I'd only give one"
	line "to someone who's"
	cont "caught every"
	cont "GRASS #MON."
	done

GreenhouseSailorCaughtAllGrassText:
	text "Whoa! You've"
	line "caught every GRASS"
	cont "#MON there is?"

	para "Then you've earned"
	line "this. Take it!"
	done

GreenhouseSailorAfterText:
	text "You can water that"
	line "line of trees and"
	cont "plant a BERRY."

	para "Tomorrow, they'll"
	line "have more BERRIES"
	cont "for you."
	done

GreenhouseWeirdTreeText:
	text "It's a weirdly"
	line "shaped tree."

	para "It vaguely reminds"
	line "you of a #MON."
	done

CeladonGreenhouse_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2, 13, CELADON_CITY, 10
	warp_event  3, 13, CELADON_CITY, 10

	def_coord_events

	def_bg_events

	def_object_events
	object_event  8, 11, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_WANDER, 2, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, GreenhouseGymGuideScript, -1
	object_event  6,  4, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, GreenhouseBugCatcherScript, -1
	object_event 13, 10, SPRITE_SAILOR, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, GreenhouseSailorScript, -1
	object_event 13,  7, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, GreenhousePlot1Script, -1
	object_event 14,  8, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, GreenhousePlot2Script, -1
	object_event 15,  9, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, GreenhousePlot3Script, -1
	object_event 16, 10, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, GreenhousePlot4Script, -1
	object_event  4,  4, SPRITE_WEIRD_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, GreenhouseWeirdTreeScript, -1
