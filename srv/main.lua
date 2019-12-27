local HUMID_PIN = 6
local TEMP_PIN = 7
local DISP_D = 1
local DISP_C = 2

ow.setup(TEMP_PIN)
local addr = ow.search(TEMP_PIN)

local function readT(pin, addr)
   ow.reset(pin)
   ow.select(pin, addr)
   ow.write(pin, 0x44, 1)

   ow.reset(pin)
   ow.select(pin, addr)
   ow.write(pin, 0xBE, 1)

   local data = ""
   for i = 1, 9 do
      data = data .. string.char(ow.read(pin))
   end

   local s = 1
   if data:byte(2) > 0 then
      s = -1
   end
   local t = s * bit.rshift(data:byte(1), 1) - 0.25 + (data:byte(8) - data:byte(7))/data:byte(8)
   return t
end

lc = dofile("liquidcrystal.lua")
lc:init("I2C", {address=0x27,id=0,sda=DISP_D,scl=DISP_C,speed=i2c.SLOW}, true, false, true, 20, true)

lc:write("Please, wait...")
readT(TEMP_PIN, addr)

collectgarbage()

CBuffer = dofile("CBuffer.lua")
buffer_t = CBuffer(144)
buffer_h = CBuffer(144)

temperature = 0
humidity = 0

collectgarbage()

local mytimer = tmr.create()
mytimer:register(
   5000, tmr.ALARM_AUTO,
   function(_)
      _, _, humidity = dht.read11(HUMID_PIN)
      temperature = readT(TEMP_PIN, addr)
      lc:clear()
      lc:home()
      lc:write(string.format("Temperature: %dC\223", temperature or 0))
      lc:cursorMove(1,2)
      lc:write(string.format("Humidity: %d%%", humidity or 0))
      buffer_t:set(temperature)
      buffer_h:set(humidity)

      lc:cursorMove(1,3)
      lc:write(wifi_info)
      lc:cursorMove(1,4)
      lc:write(wifi.sta.getip() or wifi.ap.getip())
      collectgarbage()
   end
)
mytimer:start()

local mytimer2 = tmr.create()
mytimer2:register(
   T*60*1000, tmr.ALARM_AUTO,
   function(_)
      buffer_t:push(temperature)
      buffer_h:push(humidity)
   end
)
mytimer2:start()
