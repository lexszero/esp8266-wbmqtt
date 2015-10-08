-- Example controlling RGB LED strip with PCA9685 I2C PWM controller
-- Requires Lua PCA9685 driver: https://github.com/lexszero/esp8266-pwm/

-- Initialize I2C bus with SDA on GPIO0, SCL on GPIO2
-- https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
i2c.setup(0, 3, 4, i2c.SLOW)

-- Initialize PCA9685 PWM controller
-- Args:
--	i2c bus id (should be 0)
--	i2c address (see pca9685 datasheet)
--	mode - 16-bit value, low byte is MODE1, high is MODE2 (see datasheet)
require('pca9685')
pca9685.init(0, 0x40, 0)

m = require('wbmqtt')

-- Define MQTT control for RGB LED strip
rgbstrip = m.Control{
	name = 'Color',
	type = 'rgb',
	on_connect = function(self)
		-- Publish current state
		self:publish(self.value)
	end,

	value = '0;0;0',
}
-- Subscribe to '../on' topic and set PWM duty on messages reception
rgbstrip:subscribe('on', function(self, fn, value)
	r, g, b = value:match('(%d+);(%d+);(%d+)')
	pca9685.set_chan_byte(0, tonumber(r))
	pca9685.set_chan_byte(1, tonumber(g))
	pca9685.set_chan_byte(2, tonumber(b))
	self.value = value
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
	device = 'rgbstrip-room',
	name = 'RGB LED strip'
}
