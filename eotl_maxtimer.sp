#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <regex>

#define PLUGIN_AUTHOR  "ack"
#define PLUGIN_VERSION "0.05"

#define CONFIG_FILE    "configs/eotl_maxtimer.cfg"

public Plugin myinfo = {
	name = "eotl_maxtime",
	author = PLUGIN_AUTHOR,
	description = "Sets an upper limit on how high the round timer can be",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar g_cvMaxTime;
ConVar g_cvDebug;
int g_capNum;
StringMap g_cpOverrides;

public void OnPluginStart() {
    LogMessage("version %s starting", PLUGIN_VERSION);
    HookEvent("teamplay_timer_time_added", EventTimeAdded);

    HookEvent("teamplay_round_stalemate", EventRoundEnd);
    HookEvent("teamplay_round_win", EventRoundEnd);
    HookEvent("teamplay_game_over", EventRoundEnd);

    g_cvMaxTime = CreateConVar("eotl_maxtimer_time", "315", "Max time in seconds the round timer can be", FCVAR_NOTIFY);
    g_cvDebug = CreateConVar("eotl_maxtimer_debug", "0", "0/1 enable debug output", FCVAR_NONE, true, 0.0, true, 1.0);

    g_cpOverrides = CreateTrie();
}

public void OnMapStart() {
    g_capNum = 0;
    g_cpOverrides.Clear();
    LoadCpOverrides();
}

public Action EventRoundEnd(Handle event, const char[] name, bool dontBroadcast) {
    if(StrEqual(name, "teamplay_round_win") && !GetEventInt(event, "full_round")) {
        LogDebug("EventRoundEnd: mini round detected, ignoring");
        return Plugin_Continue;
    }

    LogDebug("EventRoundEnd: Resetting g_capNum");
    g_capNum = 0;
    return Plugin_Continue;
}

public Action EventTimeAdded(Handle event, const char[] name, bool dontBroadcast) {
    char cpOverride[8];
    bool isOverride = false;
    float maxTime = g_cvMaxTime.FloatValue;

    g_capNum++;
    Format(cpOverride, sizeof(cpOverride), "cp%d", g_capNum);

    if(g_cpOverrides.ContainsKey(cpOverride)) {
        g_cpOverrides.GetValue(cpOverride, maxTime);
        isOverride = true;
        LogMessage("Using %s override of %1.f seconds", cpOverride, maxTime);
    }

    if(maxTime <= 0.0) {
        return Plugin_Continue;
    }

    int roundTimer = FindEntityByClassname(MaxClients + 1, "team_round_timer");
    if(IsValidEntity(roundTimer)) {
        float endTime = GetEntPropFloat(roundTimer, Prop_Send, "m_flTimerEndTime");
        float timeLeft = endTime - GetGameTime();

        if(timeLeft > maxTime) {
            LogMessage("Adjusting remaining round time from %.1f seconds to %.1f seconds [cp%d] [%s]", timeLeft, maxTime, g_capNum, isOverride ? "O" : "G");
            PrintToChatAll("\x01[\x03maxtimer\x01] Round time limited to %d seconds [cp%d] [%s]", RoundToFloor(maxTime), g_capNum, isOverride ? "O" : "G");
            SetVariantInt(RoundToFloor(maxTime));
            AcceptEntityInput(roundTimer, "SetTime");
        }
    }
    return Plugin_Continue;
}

// given a mapName truncate it at the last "_", as long
// as there are more then 1 of them.
// pl_mymap_rc123 => pl_mymap
bool MakeShortMapName(char[] mapName) {
    int us_count = 0;
    int us_last = 0;
    int len = strlen(mapName);

    for(int i = 0;i < len;i++) {
        if(mapName[i] == '_') {
            us_count++;
            us_last = i;
        }
    }

    if(us_count > 1) {
        mapName[us_last] = '\0';
        return true;
    }

    return false;
}

void LoadCpOverrides() {
    KeyValues cfg = CreateKeyValues("CP Overrides");

    char configFile[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, configFile, sizeof(configFile), CONFIG_FILE);

    LogMessage("Loading config file: %s", configFile);
    if(!FileToKeyValues(cfg, configFile)) {
        LogMessage("Unable to load config file, no overrides");
        return;
    }

    cfg.JumpToKey("maps");

    char mapName[32];
    GetCurrentMap(mapName, sizeof(mapName));
    bool found = false;

    do {
        if(cfg.JumpToKey(mapName)) {
            LogMessage("%s found in config file", mapName);
            found = true;
        } else {
            LogDebug("%s NOT found in config file", mapName);
        }
    } while(!found && MakeShortMapName(mapName));

    if(!found) {
        LogMessage("No config for this map found in the config file");
        CloseHandle(cfg);
        return;
    }

    LogMessage("Loading CP Overrides for %s", mapName);
    if(!cfg.GotoFirstSubKey(false)) {
        LogMessage("GotoFirstSubKey is false, bailing");
        CloseHandle(cfg);
    }

    do {
        char controlPoint[10];
        cfg.GetSectionName(controlPoint, sizeof(controlPoint));
        StringToLower(controlPoint);
        if(!SimpleRegexMatch(controlPoint, "^cp\\d+", 0)) {
            LogMessage("ERROR: Invalid CP name: \"%s\", should be cp#, skipping", controlPoint);
            continue;
        }

        float maxTime = cfg.GetFloat(NULL_STRING, -1.0);
        if(maxTime <= 0.0) {
            LogMessage("ERROR: Invalid maxTime: %.1f for %s, should be > 0, skipping", maxTime, controlPoint);
            continue;
        }

        LogMessage("  Adding %s with %.1f second max time", controlPoint, maxTime);
        g_cpOverrides.SetValue(controlPoint, maxTime, true);
    } while(cfg.GotoNextKey(false));

    CloseHandle(cfg);
}

void StringToLower(char[] string) {
    int len = strlen(string);

    for(int i = 0;i < len;i++) {
        string[i] = CharToLower(string[i]);
    }
}

void LogDebug(char []fmt, any...) {

    if(!g_cvDebug.BoolValue) {
        return;
    }

    char message[128];
    VFormat(message, sizeof(message), fmt, 2);
    LogMessage(message);
}