/*
 * =============================================================================
 * File:		  beaconlasthuman.sp
 * Type:		  Base
 * Description:   Plugin's base file.
 *
 * Copyright (C)   Anubis Edition. All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <zombiereloaded>

#pragma newdecls required

ConVar g_chTime = null;

int g_iTime;

bool g_bRoundEnd = false;
bool g_bBeaconActive = false;

int g_iBeamSprite = -1;
int g_iHaloSprite = -1;

int g_iRedColor[4]		= {255, 75, 75, 255};
int g_iOrangeColor[4]	= {255, 128, 0, 255};
int g_iGreenColor[4]	= {75, 255, 75, 255};
int g_iBlueColor[4]	= {75, 75, 255, 255};
int g_iWhiteColor[4]	= {255, 255, 255, 255};
int g_iGreyColor[4]	= {128, 128, 128, 255};


#define PLUGIN_NAME           "Beacon Last Human"
#define PLUGIN_AUTHOR         "alongub, Anubis Edition"
#define PLUGIN_DESCRIPTION    "Beacons last survivor for X seconds."
#define PLUGIN_VERSION        "1.3"
#define PLUGIN_URL            "https://github.com/Stewart-Anubis"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{
	g_chTime = CreateConVar("sm_beaconlasthuman_time", "30", "The amount of time in seconds to beacon last survivor.");

	g_chTime.AddChangeHook(ConVarChange);

	g_iTime = g_chTime.IntValue;

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);

	AutoExecConfig(true, "beaconlasthuman");
}

public void OnMapStart()
{
	LoadTranslations("beaconlasthuman.phrases");
	g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("sprites/glow01.vmt");
}

public void ConVarChange(ConVar CVar, const char[] oldVal, const char[] newVal)
{
	g_iTime = g_chTime.IntValue;
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_bBeaconActive) return;
	int humans = 0;
	int zombies = 0;
	
	int client = -1;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, true)) continue;

		if (GetClientTeam(i) == 3)
		{
			humans++;
			client = i;
		}
		else if (GetClientTeam(i) == 2)
		{
			zombies++;
		}
	}

	if (zombies > 0 && humans == 1 && client != -1 && !g_bBeaconActive)
	{
		CreateTimer(1.0, Timer_Beacon, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		g_bBeaconActive = true;
	}
	
	return;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = true;
	g_bBeaconActive = false;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = true;
	g_bBeaconActive = false;
}

public Action ZR_OnClientInfect(int &client, int &attacker, bool &motherInfect, bool &respawnOverride, bool &respawn)
{
	g_bRoundEnd = false;
	return Plugin_Continue;
}

public Action Timer_Beacon(Handle timer, any client)
{
	static int times = 0;
	static int i_Colors = 0;

	if (times < g_iTime && !g_bRoundEnd)
	{
		float vec[3];
		GetClientAbsOrigin(client, vec);
		vec[2] += 10;
		
		if (i_Colors == 0) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iRedColor, 10, 0);
		i_Colors++;
		} else if (i_Colors == 1) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iOrangeColor, 10, 0);
		i_Colors++;
		} else if (i_Colors == 2) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iGreenColor, 10, 0);
		i_Colors++;
		} else if (i_Colors == 3) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iBlueColor, 10, 0);
		i_Colors++;
		} else if (i_Colors == 4) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iWhiteColor, 10, 0);
		i_Colors++;
		} else if (i_Colors >= 5) {
		TE_SetupBeamRingPoint(vec, 10.0, 190.0, g_iBeamSprite, g_iHaloSprite, 0, 15, 1.0, 5.0, 0.0, g_iGreyColor, 10, 0);
		i_Colors = 0;
		}
		TE_SendToAll();

		EmitAmbientSound("buttons/blip1.wav", vec, client, SNDLEVEL_RAIDSIREN);
		times++;

		PrintCenterTextAll("%t", "Last human is under beacon", (g_iTime - times));
	}
	else
	{
		times = 0;
		g_bBeaconActive = false;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

stock bool IsValidClient(int client, bool bzrAllowBots = false, bool bzrAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bzrAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bzrAllowDead && !IsPlayerAlive(client)))
		return false;
	return true;
}