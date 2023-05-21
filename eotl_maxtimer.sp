#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_AUTHOR  "ack"
#define PLUGIN_VERSION "0.03"

public Plugin myinfo = {
	name = "eotl_maxtime",
	author = PLUGIN_AUTHOR,
	description = "Sets an upper limit on how high the round timer can be",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar g_cvMaxTime;
ConVar g_cvMaxTimeCashworksCP3;
bool g_isCashworks;
int g_capNum;

public void OnPluginStart() {
    LogMessage("version %s starting", PLUGIN_VERSION);
    HookEvent("teamplay_timer_time_added", EventTimeAdded);
    HookEvent("teamplay_round_start", EventRoundStart, EventHookMode_PostNoCopy);
    g_cvMaxTime = CreateConVar("eotl_maxtimer_time", "315", "Max time in seconds the round timer can be", FCVAR_NOTIFY);
    g_cvMaxTimeCashworksCP3 = CreateConVar("eotl_maxtimer_time_cashworks_cp3", "315", "Max time in seconds the round timer can be for pl_cashworks* capture point B3", FCVAR_NOTIFY);
}

public void OnMapStart() {
    char mapName[32];
    GetCurrentMap(mapName, sizeof(mapName));
    if(StrContains(mapName, "pl_cashworks") >= 0) {
        g_isCashworks = true;
    } else {
        g_isCashworks = false;
    }
    LogMessage("isCashworks: %d", g_isCashworks);
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast) {
    g_capNum = 0;
    return Plugin_Continue;
}

public Action EventTimeAdded(Handle event, const char[] name, bool dontBroadcast) {

    float maxTime = g_cvMaxTime.FloatValue;

    g_capNum++;
    if(g_capNum == 3 && g_isCashworks) {
        maxTime = g_cvMaxTimeCashworksCP3.FloatValue;
        LogMessage("Cashworks CP3 override! %f", maxTime);
    }

    if(maxTime <= 0.0) {
        return Plugin_Continue;
    }

    int roundTimer = FindEntityByClassname(MaxClients + 1, "team_round_timer");
    if(IsValidEntity(roundTimer)) {
        float endTime = GetEntPropFloat(roundTimer, Prop_Send, "m_flTimerEndTime");
        float timeLeft = endTime - GetGameTime();

        if(timeLeft > maxTime) {
            LogMessage("adjusting remaining round time from %.1f seconds to %.1f seconds", timeLeft, maxTime);
            PrintToChatAll("Round time limited to %d seconds", RoundToFloor(maxTime));
            SetVariantInt(RoundToFloor(maxTime));
            AcceptEntityInput(roundTimer, "SetTime");
        }
    }
    return Plugin_Continue;
}