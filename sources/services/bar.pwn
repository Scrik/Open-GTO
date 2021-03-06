/*
	About: bar service
	Author: ziggi
*/

#if defined _bar_included
	#endinput
#endif

#define _bar_included

/*
	Defines
*/

#define MAX_BAR_ACTORS 12

#if MAX_GULPS >= 255
	#error MAX_GULPS should be lower than 255
#endif

/*
	Enums
*/

enum e_Bar_Info {
	e_bpType,
	Float:e_bpPosX,
	Float:e_bpPosY,
	Float:e_bpPosZ,
	e_bpActor_Model,
	Float:e_bpActor_PosX,
	Float:e_bpActor_PosY,
	Float:e_bpActor_PosZ,
	Float:e_bpActor_PosA,
	e_bpCheckpoint,
}

enum e_Drink_Info {
	e_dName[MAX_NAME],
	e_dCost,
	Float:e_dHealth,
	Float:e_dAlcohol,
	e_dAction,
}

/*
	Vars
*/

static gBarPlace[][e_Bar_Info] = {
	{ENTEREXIT_TYPE_BAR, 495.3609, -76.0381, 998.7578,             176, 495.3513, -77.8193, 998.7651, 7.2703}, // green bar
	{ENTEREXIT_TYPE_JIZZY, -2654.0112, 1413.2083, 906.2771,        176, -2655.8608, 1413.0214, 906.2734, 269.8462}, // Jizzy's
	{ENTEREXIT_TYPE_FOURDRAGONS, 1955.3743, 1017.9493, 992.4688,   176, 1953.7958, 1017.9473, 992.4688, 276.7396}, // 4 Dragons Casino
	{ENTEREXIT_TYPE_REDSANS, 1139.7212, -4.2430, 1000.6719,        177, 1141.8073, -4.4088, 1000.6719, 85.2910}, // Redsands Casino
	{ENTEREXIT_TYPE_LILPROBEINN, -224.7835, 1407.4834, 27.7734,    176, -223.3067, 1407.3264, 27.7734, 77.1677}, // Lil' Probe Inn
	{ENTEREXIT_TYPE_ALHAMBRA, 499.4490, -16.8206, 1000.6719,       177, 501.7473, -17.2167, 1000.6719, 81.5544}, // Alhambra Club
	{ENTEREXIT_TYPE_RESTAURANT, -785.9133, 500.1498, 1371.7422,    177, -785.9677, 498.1729, 1371.7422, 4.4737}, // Liberty City Restoran
	{ENTEREXIT_TYPE_PIGPEN, 1215.3257, -13.0094, 1000.9219,        177, 1215.1998, -15.2597, 1000.9219, 2.2803}, // The Pig Pen
	{ENTEREXIT_TYPE_NUDESTRIPPERS, 1207.3661, -28.5663, 1000.9531, 177, 1206.0661, -28.5663, 1000.9531, -90.8725} // Nude Strippers Daily
};

static gDrinksInfo[][e_Drink_Info] = {
	{"�����", 100, 30.0, 40.0, SPECIAL_ACTION_DRINK_SPRUNK},
	{"����", 30, 10.0, 4.5, SPECIAL_ACTION_DRINK_BEER},
	{"����", 30, 10.0, 10.0, SPECIAL_ACTION_DRINK_WINE},
	{"���", 15, 10.0, -20.0, SPECIAL_ACTION_DRINK_SPRUNK},
	{"������", 15, 5.0, 2.0, SPECIAL_ACTION_SMOKE_CIGGY}
};

static
	gActors[MAX_BAR_ACTORS],
	gPlayerGulps[MAX_PLAYERS char] = {255, ...},
	gPlayerAlcoholID[MAX_PLAYERS char],
	bool:gPlayerIsGulping[MAX_PLAYERS char];

/*
	Functions
*/

Bar_OnGameModeInit()
{
	for (new id = 0; id < sizeof(gBarPlace); id++) {
		gBarPlace[id][e_bpCheckpoint] = CreateDynamicCP(gBarPlace[id][e_bpPosX], gBarPlace[id][e_bpPosY], gBarPlace[id][e_bpPosZ], 1.5, .streamdistance = 20.0);
	}
	Log_Init("services", "Bar module init.");
	return 1;
}

Bar_OnInteriorCreated(id, type, world)
{
	#pragma unused id
	new slot;

	for (new i = 0; i < sizeof(gBarPlace); i++) {
		if (gBarPlace[i][e_bpType] == type) {
			slot = Bar_GetActorFreeSlot();
			if (slot == -1) {
				Log(systemlog, DEBUG, "bar.inc: Free slot not found. Increase MAX_BAR_ACTORS value.");
				break;
			}

			gActors[slot] = CreateActor(gBarPlace[i][e_bpActor_Model],
				gBarPlace[i][e_bpActor_PosX], gBarPlace[i][e_bpActor_PosY], gBarPlace[i][e_bpActor_PosZ],
				gBarPlace[i][e_bpActor_PosA]
			);
			SetActorVirtualWorld(gActors[slot], world);
		}
	}
}

Bar_OnActorStreamIn(actorid, forplayerid)
{
	for (new id = 0; id < sizeof(gActors); id++) {
		if (actorid == gActors[id]) {
			SetPVarInt(forplayerid, "Bar_actor_id", actorid);
			ClearActorAnimations(actorid);
			return 1;
		}
	}
	return 0;
}

Bar_OnPlayerEnterCheckpoint(playerid, cp)
{
	for (new id = 0; id < sizeof(gBarPlace); id++) {
		if (cp == gBarPlace[id][e_bpCheckpoint]) {
			Dialog_Show(playerid, Dialog:ServiceBar);
			ApplyActorAnimation(GetPVarInt(playerid, "Bar_actor_id"), "MISC", "Idle_Chat_02", 4.1, 0, 1, 1, 1, 1);
			return 1;
		}
	}
	return 0;
}

Bar_OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if ( PRESSED ( KEY_FIRE ) ) {
		if (IsPlayerDrinking(playerid) && !IsPlayerGulping(playerid)) {
			MakePlayerGulp(playerid);
			return 1;
		}
	} else if ( PRESSED ( KEY_SECONDARY_ATTACK ) ) {
		StopPlayerDrinking(playerid);
		return 1;
	}
	return 0;
}

DialogCreate:ServiceBar(playerid)
{
	static
		string[MAX_LANG_VALUE_STRING * (sizeof(gDrinksInfo) + 1)];

	Lang_GetPlayerText(playerid, "BAR_DIALOG_LIST_HEADER", string);

	for (new i = 0; i < sizeof(gDrinksInfo); i++) {
		Lang_GetPlayerText(playerid, "BAR_DIALOG_LIST_ITEM", string, _,
		                   string,
		                   gDrinksInfo[i][e_dName],
		                   gDrinksInfo[i][e_dCost],
		                   gDrinksInfo[i][e_dAlcohol],
		                   gDrinksInfo[i][e_dHealth]);
	}

	Dialog_Open(playerid, Dialog:ServiceBar, DIALOG_STYLE_TABLIST_HEADERS,
	            "BAR_DIALOG_HEADER",
	            string,
	            "BAR_DIALOG_BUTTON_0", "BAR_DIALOG_BUTTON_1",
	            MDIALOG_NOTVAR_INFO);
}

DialogResponse:ServiceBar(playerid, response, listitem, inputtext[])
{
	if (!response) {
		return 1;
	}

	if (GetPlayerMoney(playerid) < gDrinksInfo[listitem][e_dCost]) {
		Dialog_Message(playerid, "BAR_DIALOG_HEADER", "BAR_NOT_ENOUGH_MONEY", "BAR_DIALOG_BUTTON_OK");
		return 1;
	}

	GivePlayerMoney(playerid, -gDrinksInfo[listitem][e_dCost]);
	SetPlayerSpecialAction(playerid, gDrinksInfo[listitem][e_dAction]);
	StartPlayerDrinking(playerid, listitem);

	Dialog_Message(playerid,
	               "BAR_DIALOG_HEADER",
	               "BAR_DIALOG_INFORMATION_TEXT",
	               "BAR_DIALOG_BUTTON_OK",
	               MDIALOG_NOTVAR_NONE,
	               gDrinksInfo[listitem][e_dName],
	               gDrinksInfo[listitem][e_dCost],
	               gDrinksInfo[listitem][e_dAlcohol],
	               gDrinksInfo[listitem][e_dHealth]);
	return 1;
}

Bar_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	#pragma unused vehicleid
	if (ispassenger) {
		StopPlayerDrinking(playerid);
	}
	return 1;
}

forward Bar_GulpProcess(playerid);
public Bar_GulpProcess(playerid)
{
	new id = GetPlayerAlcoholID(playerid);
	SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + floatround(gDrinksInfo[id][e_dAlcohol] * 100.0 / MAX_GULPS, floatround_round));

	new Float:max_health;
	GetMaxHealth(playerid, max_health);

	new Float:health;
	GetPlayerHealth(playerid, health);

	if (health + gDrinksInfo[id][e_dHealth] / MAX_GULPS > max_health) {
		SetPlayerHealth(playerid, max_health);
	} else {
		SetPlayerHealth(playerid, health + gDrinksInfo[id][e_dHealth] / MAX_GULPS);
	}

	if (GetPlayerGulps(playerid) >= MAX_GULPS) {
		StopPlayerDrinking(playerid);
	}

	gPlayerIsGulping{playerid} = false;
	return 1;
}

static stock StopPlayerDrinking(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	gPlayerGulps{playerid} = 255;
	gPlayerIsGulping{playerid} = false;
	gPlayerAlcoholID{playerid} = 0;
	return 1;
}

static stock IsPlayerGulping(playerid)
{
	return gPlayerIsGulping{playerid};
}

static stock IsPlayerDrinking(playerid)
{
	return gPlayerGulps{playerid} != 255;
}

static stock GetPlayerGulps(playerid)
{
	return gPlayerGulps{playerid};
}

static stock GetPlayerAlcoholID(playerid)
{
	return gPlayerAlcoholID{playerid};
}

static stock StartPlayerDrinking(playerid, alcoholid)
{
	gPlayerGulps{playerid} = 0;
	gPlayerAlcoholID{playerid} = alcoholid;
}

static stock MakePlayerGulp(playerid)
{
	if (gPlayerGulps{playerid} == 255) {
		gPlayerGulps{playerid} = 1;
	} else {
		gPlayerGulps{playerid}++;
	}
	gPlayerIsGulping{playerid} = true;
	SetTimerEx("Bar_GulpProcess", 2000, 0, "i", playerid);
}

stock IsPlayerAtBar(playerid)
{
	for (new b_id = 0; b_id < sizeof(gBarPlace); b_id++) {
		if (IsPlayerInRangeOfPoint(playerid, 2, gBarPlace[b_id][Bar_x], gBarPlace[b_id][Bar_y], gBarPlace[b_id][Bar_z])) {
			return 1;
		}
	}
	return 0;
}

stock Bar_GetActorFreeSlot()
{
	static slot;

	if (slot >= sizeof(gActors)) {
		return -1;
	}

	return slot++;
}
