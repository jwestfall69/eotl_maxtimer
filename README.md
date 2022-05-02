# eotl_maxtimer

This is a TF2 sourcemod plugin.

This plugin allows setting the maximum time the round timer can be.  The purpose of this is to speed up gameplay and not be stuck trying to capture/defend the same point for 15+ minutes.

The Plugin will only check for this when time is added to the timer (ie when a point is captured).

### ConVars
<hr>

**eotl_maxtimer_time [seconds]**

Max time the round timer can be in seconds.  A value that is <= 0 will disable the plugin.

Default: 600