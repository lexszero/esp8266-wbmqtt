local modname = ...
local M = {}
_G[modname] = M

local online = false
local controls = {}

local mqtt_args = nil

local mqtt_device = nil
local mqtt_controls = nil

local Control = {}
function Control:subscribe(name, func)
	self.callbacks[name] = func
end

function Control:register()
	if not online then
		return
	end
	local mqtt_control = mqtt_controls .. self.name
	m:publish(mqtt_control .. '/meta/type', self.type, 0, 1)
	if self.readonly then
		m:publish(mqtt_control .. '/meta/readonly', '1', 0, 1)
	end
	for cbn, cbf in pairs(self.callbacks) do
		local topic = mqtt_control .. '/' .. cbn 
		m:subscribe(topic, 0, function(conn)
			print('mqtt: subscribed to ' .. topic)
		end)
	end
	if self.on_connect then
		self.on_connect(self)
	end
end

function Control:publish(value)
	if online then
		return m:publish(mqtt_controls .. self.name, tostring(value), 0, 1)
	else
		return false
	end
end

function M.Control(arg)
	c = arg or {}
	if not c.name then
		local count = 0
		for _ in pairs(controls) do
			count = count + 1
		end
		c.name = 'control'..tostring(count)
	end
	c.type = c.type or 'value'
	c.callbacks = {}
	setmetatable(c, {__index = Control})
	controls[c.name] = c
	return c
end

function M.init(arg)
	mqtt_args = arg
	mqtt_args.clientid = mqtt_args.clientid or 'esp8266_' .. wifi.sta.getmac()
	mqtt_args.name = mqtt_args.name or 'ESP8266 MQTT device'

	mqtt_device = '/devices/'..(arg.device or arg.clientid)
	mqtt_controls = mqtt_device..'/controls/'

	m = mqtt.Client(mqtt_args.clientid, 120, mqtt_args.user, mqtt_args.password)
	m:on('connect', function(conn)
		online = true
		print('mqtt: connected')
	end)
	m:on('offline', function(conn)
		online = false
		print('mqtt: offline')
	end)
	m:on('message', function(conn, topic, data)
		local cn, fn = topic:match('/devices/[^/]+/controls/([^/]+)/(.*)')
		control = controls[cn]
		if not control then
			print('dispatch: unknown control', cn)
			return
		end
		callback = control.callbacks[fn]
		if callback then
			callback(control, fn, data)
		else
			print('dispatch: no callback for', cn, '/', fn)
		end
	end)

	tmr.alarm(0, 1000, 1, function()
		if wifi.sta.getip() == nil then
			print('wifi: connecting')
		else
			if online == false then
				print('mqtt: connecting')
				m:connect(mqtt_args.host, mqtt_args.port, mqtt_args.secure, function(conn)
					print('mqtt: connected')
					online = true
					m:publish(mqtt_device..'/meta/name', mqtt_args.name, 0, 1)
					for cname, c in pairs(controls) do
						c:register()
					end
				end)
			end
		end
	end)
end

return M
