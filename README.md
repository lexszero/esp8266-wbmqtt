# **ESP8266 NodeMCU MQTT wrapper** #

## Summary
Library for ESP8266 WiFi module with [NodeMcu firmware](https://github.com/nodemcu/nodemcu-firmware) having it's goal to simplify development of [WirenBoard](http://contactless.ru/)-compatible home automation devices.

Please note that this wrapper is not limited to interfacing with WirenBoard only, but can be used with any MQTT broker. It's all about using certain topics hierarchy.

Licensed under [WTFPL](http://www.wtfpl.net/)

## wbmqtt.lua
This is a wrapper for default `NodeMCU` MQTT implementation.

~~TODO: document API~~

## Usage
Use some tool like [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader) to put `wbmqtt.lua` to NodeMCU filesystem.
To run example, tweak `init_*.lua` to your needs and upload as `init.lua`.

For example (using `nodemcu-uploader`):
```
../nodemcu-uploader/nodemcu-uploader.py upload wbmqtt.lua -c -v
../nodemcu-uploader/nodemcu-uploader.py upload init_pir_rel.lua:init.lua -v -r
```

Read comments in the source files for further documentation.

## MQTT interface conventions

* [WirenBoard wiki](http://contactless.ru/wiki/index.php/MQTT#.D0.9E.D1.87.D0.B8.D1.81.D1.82.D0.BA.D0.B0_.D1.81.D0.BE.D0.BE.D0.B1.D1.89.D0.B5.D0.BD.D0.B8.D0.B9_MQTT) (russian)
* [Controls types & metadata spec](https://github.com/contactless/homeui/blob/contactless/conventions.md)

### TL;DR

ESP8266-based automation module is a *device* having some *controls* (i.e. parameters that can be controlled or monitored). *Devices* and *controls* are identified by names (arbitrary strings), and have some metadata. Metadata messages is published on device startup with `retained` flag set.
For example, some room lighting control *device* with one input (for wall switch) and one output (for controlling the lamp) *controls* is represented with MQTT topics as following:

* `/devices/RoomLight/meta/name` - 'Light in my room', human-friendly description of the *device*
* `/devices/RoomLight/controls/Lamp` - contains current lamp state, '0' = off, '1' = on
* `/devices/RoomLight/controls/Lamp/on` - send a message with this topic and payload of '0'/'1' to turn lamp off or on
* `/devices/RoomLight/controls/Lamp/meta/type` - 'switch' (binary value)
* `/devices/RoomLight/controls/Switch` - contains current wall switch state
* `/devices/RoomLight/controls/Switch/meta/type` - 'switch'
* `/devices/RoomLight/controls/Switch/meta/readonly` - '1', it doesn't make sense trying to control a wall switch over MQTT
