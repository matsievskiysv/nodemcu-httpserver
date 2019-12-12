return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'json')
   if args.humid ~= nil then
      connection:send([==[{"y":[]==])
      for i in buffer_h:iterate() do
	 connection:send(tostring(i) .. ",")
      end
      connection:send([==[0],"x":[]==])
      for i=0,buffer_h.size-1 do
	 connection:send(tostring(-i*T/60) .. ",")
      end
      connection:send(tostring(-(buffer_h.size+1)*T/60) .. "]}")
   else
      connection:send([==[{"y":[]==])
      for i in buffer_t:iterate() do
	 connection:send(tostring(i) .. ",")
      end
      connection:send([==[0],"x":[]==])
      for i=0,buffer_t.size-1 do
	 connection:send(tostring(-i*T/60) .. ",")
      end
      connection:send(tostring(-(buffer_h.size+1)*T/60) .. "]}")
   end
end
