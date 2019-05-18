print("")
print("")
print("")
print("")
print("Nine's PMessage-System loaded... [SERVERSIDE]")
print("http://steamcommunity.com/id/lt9nine/")
print("")
print("")
print("")
print("")

--===========================================================

resource.AddFile( "materials/handy/handy.png" )

util.AddNetworkString("sPMessage")
util.AddNetworkString("rPMessage")

net.Receive("sPMessage" , function( len , ply ) 

	local message = net.ReadString()
	local sender = net.ReadEntity()
	local target = net.ReadString()

	--print(message)
	--print(sender)
	--print(target)
	print("")
	print("")
	print("")
	print("#=================================================>")
	print("# " .. sender:Nick() .. " -> " .. target .. " : " .. message)
	print("#=================================================>")
	print("")
	print("")
	print("")

	net.Start("rPMessage")

	net.WriteString(message)
	net.WriteEntity(sender)


	for k, v in pairs( player.GetAll() ) do
		if v:Nick() == target then
			net.Send(v)
		end
	end

end)