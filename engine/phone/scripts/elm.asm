ElmPhoneCalleeScript:
	readvar VAR_SPECIALPHONECALL
	ifequal SPECIALCALL_POKERUS, .pokerus
	checkevent EVENT_SHOWED_TOGETIC_TO_ELM
	iftrue .discovery
	checkevent EVENT_GOT_TOGEPI_FROM_ELMS_AIDE
	iffalse .next
	checkevent EVENT_TOGEPI_EVOLVED
	iftrue .togepievolved
.next
	checkevent EVENT_GOT_TOGEPI_FROM_ELMS_AIDE
	iftrue .togepistatus
	checkevent EVENT_ELMS_AIDE_IN_LAB
	iftrue .assistant
	checkevent EVENT_GAVE_MYSTERY_EGG_TO_ELM
	iftrue .checkingegg
	checkevent EVENT_ELM_CALLED_ABOUT_STOLEN_POKEMON
	iftrue .stolen
	checkevent EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON
	iftrue .sawmrpokemon
	farwritetext ElmPhoneHealYourMonText
	end

.sawmrpokemon
	farwritetext ElmPhoneSawMrPokemonText
	end

.stolen
	farwritetext ElmPhonePokemonStolenText
	end

.checkingegg
	farwritetext ElmPhoneCheckingTheEggText
	end

.assistant
	farwritetext ElmPhoneAssistantText
	end

.togepistatus
	farwritetext ElmPhoneHowIsTogepiText
	end

.togepievolved
	farwritetext ElmPhoneTogepiEvolvedText
	setevent EVENT_TOLD_ELM_ABOUT_TOGETIC_OVER_THE_PHONE
	end

.discovery
	random 2
	ifequal 0, .nextdiscovery
	farwritetext ElmPhoneDiscoveredHappinessText
	end

.nextdiscovery
	farwritetext ElmPhoneInvestigatingHappinessMovesText
	end

.pokerus
	farwritetext ElmPhoneDiscoveredPokerusText
	specialphonecall SPECIALCALL_NONE
	end

ElmPhoneCallerScript:
	readvar VAR_SPECIALPHONECALL
	ifequal SPECIALCALL_ROBBED, .disaster
	ifequal SPECIALCALL_ASSISTANT, .assistant
	ifequal SPECIALCALL_WEIRDBROADCAST, .rocket
	ifequal SPECIALCALL_WILDHUNT, .wildhunt
	ifequal SPECIALCALL_SUICUNE, .suicune
	ifequal SPECIALCALL_SSTICKET, .ssticket
	ifequal SPECIALCALL_MASTERBALL, .gift
	farwritetext ElmPhoneDiscoveredPokerusText
	specialphonecall SPECIALCALL_NONE
	end

.disaster
	farwritetext ElmPhoneDisasterText
	specialphonecall SPECIALCALL_NONE
	setevent EVENT_ELM_CALLED_ABOUT_STOLEN_POKEMON
	end

.assistant
	farwritetext ElmPhoneEggAssistantText
	specialphonecall SPECIALCALL_NONE
	clearevent EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER
	setevent EVENT_ELMS_AIDE_IN_LAB
	end

.rocket
	farwritetext ElmPhoneRuinsOfAlphRocketTakeoverText
	specialphonecall SPECIALCALL_NONE
	end

.wildhunt
	farwritetext ElmPhoneRoute38WildHuntText
	specialphonecall SPECIALCALL_NONE
	end

.suicune
	farwritetext ElmPhoneSuicuneText
	specialphonecall SPECIALCALL_NONE
	end

.gift
	farwritetext ElmPhoneGiftText
	specialphonecall SPECIALCALL_NONE
	end

.ssticket
	farwritetext ElmPhoneSSTicketText
	specialphonecall SPECIALCALL_NONE
	end
