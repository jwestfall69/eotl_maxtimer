#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_AUTHOR  "ack"
#define PLUGIN_VERSION "0.02"

public Plugin myinfo = {
	name = "eotl_maxtime",
	author = PLUGIN_AUTHOR,
	description = "Sets an upper limit on how high the round timer can be",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar g_cvMaxTime;

public void OnPluginStart() {
    LogMessage("version %s starting", PLUGIN_VERSION);
    HookEvent("teamplay_timer_time_added", EventTimeAdded);
    g_cvMaxTime = CreateConVar("eotl_maxtimer_time", "600", "Max time in seconds the round timer can be", FCVAR_NOTIFY);
}

public Action EventTimeAdded(Handle event, const char[] name, bool dontBroadcast) {

    float maxTime = g_cvMaxTime.FloatValue;

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