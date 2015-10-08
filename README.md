# **ESP8266 NodeMCU MQTT wrapper** #

## Summary
Library for ESP8266 WiFi module with [NodeMcu firmware](https://github.com/nodemcu/nodemcu-firmware) having it's goal to simplify development of [WirenBoard](http://contactless.ru/)-compatible home automation devices. Also includes some examples.

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
