local exceptionButtonID = exceptionButtonID or
{
	-- [2346] = true,
	-- [3510] = true,
	-- [3762] = true,
	-- [1781] = true,
	-- [1783] = true,
}

newGuthSCPH = newGuthSCPH or {} 

if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end

if not file.Exists("guthscp/hdevice_reloaded_blockedb.txt", "DATA")then
	exceptionButtonID[game.GetMap()] = {}
	file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )
else
	local txt = file.Read( "guthscp/hdevice_reloaded_blockedb.txt", "DATA" )
    exceptionButtonID = util.JSONToTable( txt )
	if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
	file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )
end

if SERVER then
	local newGuthSCPconfig = guthscp.configs.guthscpkeycard

    concommand.Add( "hdevice_block_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = true

		if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
        file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )
        
        newGuthSCPH.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
    end )

    concommand.Add( "hdevice_unblock_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = nil

		if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
		file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )

        newGuthSCPH.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
	end )
end

hook.Add( "PlayerInitialSpawn", "HDevice:GetIDs", function()
	
	local newGuthSCP = guthscp.modules.guthscpkeycard

	if GuthSCP then
		print("HDevice-reloaded - Guthen Keycard System found but outdated, please update your keycard system, HDevice-reloaded will be disable while you don't update.")
		return
	elseif newGuthSCP then 
		
		if file.Exists( "guthscp/hdevice_reloaded_blockedb.txt", "DATA" ) then
			local txt = file.Read( "guthscp/hdevice_reloaded_blockedb.txt", "DATA" )
			exceptionButtonID = util.JSONToTable( txt )
			newGuthSCPH.exceptionButtonID = exceptionButtonID
			print( "HDevice-reloaded - Buttons IDs loaded!" )
		else
			newGuthSCPH.exceptionButtonID = {}
		end

		hook.Remove( "PlayerInitialSpawn", "HDevice:GetIDs" )
	else
		print("HDevice-reloaded - Guthen Keycard System not found, HDevice-reloaded won't work without it.")
		return
	end
end )
