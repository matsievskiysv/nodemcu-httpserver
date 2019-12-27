local I2C4bit = {}

-- I2C GPIO expander bitmap
local LCD_RS = 0
local LCD_RW = 1
local LCD_EN = 2
local LCD_BACKLIGHT = 3
local LCD_D4 = 4
local LCD_D5 = 5
local LCD_D6 = 6
local LCD_D7 = 7

local function send4bitI2C(value, cmd, bus_args, backlight)
   local hi = bit.bor(bit.lshift(bit.band(bit.rshift(value, 4), 1), LCD_D4),
		      bit.lshift(bit.band(bit.rshift(value, 5), 1), LCD_D5),
		      bit.lshift(bit.band(bit.rshift(value, 6), 1), LCD_D6),
		      bit.lshift(bit.band(bit.rshift(value, 7), 1), LCD_D7))
   local lo = bit.bor(bit.lshift(bit.band(bit.rshift(value, 0), 1), LCD_D4),
		      bit.lshift(bit.band(bit.rshift(value, 1), 1), LCD_D5),
		      bit.lshift(bit.band(bit.rshift(value, 2), 1), LCD_D6),
		      bit.lshift(bit.band(bit.rshift(value, 3), 1), LCD_D7))
   if backlight then
      cmd = bit.bor(cmd, bit.lshift(1, LCD_BACKLIGHT))
   end
   i2c.start(bus_args.id)
   i2c.address(bus_args.id, bus_args.address, i2c.TRANSMITTER)
   i2c.write(bus_args.id, bit.bor(hi, cmd, bit.lshift(1, LCD_EN)))
   i2c.write(bus_args.id, bit.bor(hi, bit.band(cmd, bit.bnot(bit.lshift(1, LCD_EN)))))
   i2c.write(bus_args.id, bit.bor(lo, cmd, bit.lshift(1, LCD_EN)))
   i2c.write(bus_args.id, bit.bor(lo, bit.band(cmd, bit.bnot(bit.lshift(1, LCD_EN)))))
   i2c.stop(bus_args.id)
end

I2C4bit.command = function(self, value)
   send4bitI2C(value, 0x0, self._bus_args, self._backlight)
end

I2C4bit.write = function(self, value)
   send4bitI2C(value, bit.lshift(1, LCD_RS), self._bus_args, self._backlight)
end

I2C4bit.backlight = function(self, on)
   self._backlight = on
   self._backend.command(self, 0x0)
end

I2C4bit.init = function(self)
   i2c.setup(self._bus_args.id, self._bus_args.sda, self._bus_args.scl, self._bus_args.speed)
   self._backlight = true
   -- init sequence from datasheet
   self._backend.command(self, 0x33)
   self._backend.command(self, 0x32)
end

return I2C4bit
