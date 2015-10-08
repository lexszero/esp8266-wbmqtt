m = require('wbmqtt')

-- MQTT interface definitions are resembling https://github.com/contactless/homeui/blob/contactless/conventions.md
-- Supported parameters:
--  name        anything
--  type        see above conventions document
--  readonly    1 or 0
--  on_connect  called after establishing connection to the broker and
--              publishing device and control metadata
-- In fact, you can put anything to control parameter table, just be aware to
-- not collide with method names.


-- Define MQTT control for PIR motion sensor
sensor = m.Control{
	name = 'Motion sensor',
	type = 'switch',
	readonly = 1,
	on_connect = function(self)
		-- Publish current state
		self:publish(gpio.read(self.gpio))
	end,
	
	gpio = 4	-- GPIO2
}
-- Configure GPIO pin as interrupt input
gpio.mode(sensor.gpio, gpio.INT, gpio.PULLUP)
-- Register callback to publish sensor state on interrupt
gpio.trig(sensor.gpio, 'both', function(level)
	sensor:publish(level)
end)



-- Define MQTT control for relay
relay = m.Control{
	name = 'Relay',
	type = 'switch',
	on_connect = function(self)
		self:publish(gpio.read(self.gpio))
	end,

	gpio = 3	-- GPIO0
}
-- Configure GPIO pin as output
gpio.mode(relay.gpio, gpio.OUTPUT)
-- Subscribe to '../on' topic and control GPIO on messages reception
relay:subscribe('on', function(self, fn, value)
	if value ~= '0' and value ~= '1' then
		return
	end
	if value == '1' then
		gpio.write(self.gpio, gpio.HIGH)
	else
		gpio.write(self.gpio, gpio.LOW)
	end	
	self:publish(value)
end)


-- Setup Wi-Fi connection
wifi.setmode(wifi.STATION)
wifi.sta.config('HomeNetwork', 'VerySecretPassword')

-- Now everything is ready to run, so finally connect to MQTT broker
m.init{
	host = '192.168.0.1',
	port = '1883',
	user = 'test',
	password = 'test',
	secure = 0,
	device = 'light-room',
	name = 'Room light control'
}
