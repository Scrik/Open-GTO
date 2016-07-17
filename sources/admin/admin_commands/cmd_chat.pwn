/*

	About: chat admin command
	Author: ziggi

*/

#if defined _admin_cmd_chat_included
	#endinput
#endif

#define _admin_cmd_chat_included

COMMAND:chat(playerid, params[])
{
	if (!IsPlayerHavePrivilege(playerid, PlayerPrivilegeModer)) {
		return 0;
	}

	new
		subparams[32];

	if (sscanf(params, "s[32]", subparams)) {
		Lang_SendText(playerid, $ADMIN_COMMAND_CHAT_HELP);
		return 1;
	}

	if (strcmp(subparams, "clean", true) == 0) {
		Chat_ClearAll();

		new
			string[MAX_LANG_VALUE_STRING],
			playername[MAX_PLAYER_NAME + 1];

		GetPlayerName(playerid, playername, sizeof(playername));

		format(string, sizeof(string), _(playerid, ADMIN_COMMAND_CHAT_CLEAN), playername, playerid);
		SendClientMessageToAll(-1, string);
	} else {
		Lang_SendText(playerid, $ADMIN_COMMAND_CHAT_HELP);
	}

	return 1;
}
