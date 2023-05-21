# eotl_maxtimer

This is a TF2 sourcemod plugin I wrote for the [EOTL](https://www.endofthelinegaming.com/) community.

This plugin is targeted towards playload maps and allows setting the maximum time the round timer can be.  EOTL's [Payload Extreme](https://eotl.gameme.com/overview/17) runs with fast spawn times, that coupled with this plugin speeds up game play so you aren't stuck trying to capture/defend the same point for 15+ minutes.

The plugin will do its check whenever time is added to the timer (ie when a point is captured).

### ConVars
<hr>

**eotl_maxtimer_time [seconds]**

Max time the round timer can be in seconds.  A value that is <= 0 will disable the plugin.

Default: 315

**eotl_maxtimer_time_cashworks_cp3 [seconds]**

pl_cashworks* has some badly placed capture point locations relative to choke locations, which makes having the same maxtimer for all sections of the map not work well.  This convar allows setting a specific maxtimer for capture point 3 (before the bridge).  Note: we normally make eotl_maxtimer_timer be 375 on pl_cashworks, and leave this convar the default.

Default: 315