local CBuffer = {}
CBuffer.__index = CBuffer

setmetatable(CBuffer, {
		__call = function (cls, ...)
		   return cls.new(...)
		end,
})

function CBuffer.new(N)
   local self = setmetatable({}, CBuffer)
   self.size = N
   self.current = 1
   self.buffer = {}
   for i=1,self.size do
      self.buffer[i] = 0
   end
   return self
end

function CBuffer:push(val)
   self.buffer[self.current] = val
   if self.current == self.size then
      self.current = 1
   else
      self.current = self.current + 1
   end
end

function CBuffer:set(val)
   self.buffer[self.current] = val
end

function CBuffer:iterate()
   local i = 0
   local j = self.current
   return function()
      i = i + 1
      if i <= self.size then
	 local p = j
	 if j == 1 then
	    j = self.size
	 else
	    j = j - 1
	 end
	 return self.buffer[p]
      end
   end
end

return CBuffer
