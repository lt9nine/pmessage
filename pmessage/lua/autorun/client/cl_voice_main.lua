print("")
print("")
print("")
print("")
print("Nine's PMessage-System loaded... [CLIENTSIDE]")
print("http://steamcommunity.com/id/lt9nine/")
print("")
print("")
print("")
print("")




local ourMat = Material( "handy/handy.png" )

local ping_enabled = false
local target = ""
local delay = 5
local shouldOccur = true
local panel = nil
local verlauf = ""

local OpenPing = function()

	if (!ping_enabled) then
		ping_enabled = true

	local pingframe = vgui.Create( "DFrame" )
		pingframe:SetPos( ScrW() / 2 - 180, ScrH() / 2 - 375)
		pingframe:SetSize( 400, 650 )
		pingframe:SetTitle( "" )
		pingframe:SetDraggable( false )
		pingframe:MakePopup()
		pingframe:ShowCloseButton( false )
		pingframe.Paint = function( self, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 254 ) ) 
		end
		pingframe.OnClose = function()
			ping_enabled = false
		end


	local pingexit = vgui.Create( "DButton", pingframe )
		pingexit:SetText( "Exit" )
		pingexit:SetTextColor( Color( 255, 255, 255 ) )
		pingexit:SetPos( 10, 600 )
		pingexit:SetSize( 380, 40 )
		pingexit.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 70 ) ) 
		end
		pingexit.DoClick = function()
			ping_enabled = false
			pingframe:Remove()
		end

	local comboBox = vgui.Create( "DComboBox", pingframe )
		comboBox:SetPos( 10, 40 )
		comboBox:SetSize( 380, 20 )
		comboBox:SetValue( "Select Player" )

		comboBox.OnSelect = function( _, _, value )
			--print( value.." was selected!" )
			target = tostring(value)
		end

		for k, v in pairs( player.GetAll() ) do
			comboBox:AddChoice( v:Name() )
		end

		panel = vgui.Create( "RichText", pingframe )
		panel:SetPos(10 , 140)
		panel:SetSize(380 , 440)
		panel:SetText(verlauf)
		panel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) ) 
		end



	local entry2 = vgui.Create("DTextEntry", pingframe)
		entry2:SetPos(10, 80)
		entry2:SetSize(380, 40)
		entry2.OnEnter = function(s)
		if shouldOccur then
			net.Start("sPMessage")
				net.WriteString(s:GetText())
				net.WriteEntity(LocalPlayer())	
				net.WriteString(target)	
				verlauf = verlauf .. "\n" .. LocalPlayer():Nick() .. " -> " .. target .. " : " .. s:GetText()
					if ping_enabled then
						panel:SetText(verlauf)
					end
			net.SendToServer()
			s:SetText("")
			s:RequestFocus()
			shouldOccur = false
			timer.Simple( delay, function() shouldOccur = true end )
		end
		end
		entry2.Paint = function(self)
			surface.SetDrawColor(255, 255, 255, 70)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			self:DrawTextEntryText(Color(255, 255,255), Color(255, 255,255), Color(255, 255,255))
		end

		hook.Add( "HUDPaint", "med_menu", function()
			if (ping_enabled) then
		surface.SetDrawColor( 51, 112, 204, 255 )
		surface.SetMaterial( ourMat	)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( ScrW() / 2 - 605, ScrH() / 2 - 500, 1250, 900 )
	end
end )

end
end

concommand.Add("nine_pmessage", function()

	OpenPing()

end)

net.Receive("rPMessage", function()

	local message = net.ReadString()
	local psender = net.ReadEntity()
	local message2 = ""

	if psender:IsValid() then

	verlauf = verlauf .. "\n" .. LocalPlayer():Nick() .. " <- " .. psender:Nick() .. " : " .. message

	if string.len(verlauf) > 250 then
		verlauf = ""
	end

	if ping_enabled then
	panel:SetText(verlauf)
	end

	


	local notifi = vgui.Create( "DNotify" )
	notifi:SetPos(30 , 30)
	notifi:SetSize( 200, 250 )
	notifi:SetLife( 7 )

	local bg = vgui.Create( "DPanel", notifi )
	bg:Dock( FILL )
	bg:SetBackgroundColor( Color( 64, 64, 64 ) )


	local mdl = vgui.Create( "DModelPanel", bg )
	mdl:SetSize(200 , 100)

	mdl:SetModel(psender:GetModel())

	function mdl:LayoutEntity( ent )
		ent:SetSequence( ent:LookupSequence( "menu_gman" ) )
		mdl:RunAnimation()
		return
	end

	local eyepos = mdl.Entity:GetBonePosition( mdl.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) )

	eyepos:Add( Vector( 0, 0, 2 ) )	-- Move up slightly

	mdl:SetLookAt( eyepos )

	mdl:SetCamPos( eyepos-Vector( -30, 0, 0 ) )	-- Move cam in front of eyes

	mdl.Entity:SetEyeTarget( eyepos-Vector( -30, 0, 0 ) )





	local senderlbl = vgui.Create( "DLabel", bg )
	senderlbl:SetPos(10 , 150)
	senderlbl:SetSize(180, 30)
	senderlbl:SetText("From: " .. psender:Nick())
	senderlbl:SetWrap( true )

	local messagelbl = vgui.Create( "DLabel", bg )
	messagelbl:SetPos(10 , 170)
	messagelbl:SetSize(180 , 80)
	messagelbl:SetText(message)
	messagelbl:SetWrap( true )


	notifi:AddItem( bg )
end
end)
