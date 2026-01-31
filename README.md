# eotl_maxtimer

This is a TF2 sourcemod plugin I wrote for the [EOTL](https://www.endofthelinegaming.com/) community.

This plugin is targeted towards playload maps and allows setting the maximum time the round timer can be.  EOTL's [Payload Extreme](https://eotl.gameme.com/overview/17) runs with fast spawn times, that coupled with this plugin speeds up game play so you aren't stuck trying to capture/defend the same point for 15+ minutes.

The plugin will do its check whenever time is added to the timer (ie when a point is captured).

### Config File (addons/sourcemod/configs/eotl_maxtimer.cfg)

This config file allows having overrides for specific capture point on a given map. Please refer to the config file for more detail on this.

### ConVars
<hr>

**eotl_maxtimer_time [seconds]**

Max time the round timer can be in seconds.  A value that is <= 0 will disable the plugin.

Default: 315

**eotl_maxtimer_debug [0/1]**

Disable/Enable debug logging

Default: 0 (disabled)