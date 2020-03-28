# Hitachi WDE1200 shop-vac

- Inside, it's a NodeMCU (12E) with OTA capabilities ("shopvac-wde1200" port)

- It's configured to hook onto "Axilo" wifi-network

- It tries to connect to the MQTT server "workshop-pi.local"

- It's identifying itself as "shopvac/wde1200"



## MQTT Topics

The main MQTT-topic for the vac is **shopvac/wde1200**



### Inward

The vac is only responsive to MQTT commandes while in automatic mode.

- shopvac/wde1200/**on** - Switches the vac on (and publishes its state)

- shopvac/wde1200/**off** - Switches the vac off (and publishes its state)

- shopvac/wde1200/**toggle** - Toggles the vac on or off (and publishes its state)

- shopvac/wde1200/**ping** - Switches the built-in led of the NodeMCU card rapidly to check if it is receiving over MQTT.

- shopvac/wde1200/**reboot** - Reboots the NodeMCU


### Outward

- shopvac/wde1200/**state** - Indicates the state of the vac when it is in automatic mode (in manual mode, the state is not published, because it is unknown...)

