local exceptionButtonID = exceptionButtonID or
{
	-- [2346] = true,
	-- [3510] = true,
	-- [3762] = true,
	-- [1781] = true,
	-- [1783] = true,
}

hdevicereloaded = hdevicereloaded or {}

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

function hdevicereloaded.load()
	local newGuthSCP = guthscp.modules.guthscpkeycard

	if not newGuthSCP then
		print("HDevice reloaded - Guthen Keycard System not found, HDevice reloaded won't work without it.")
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("HDevice reloaded - Guthen Keycard System not found, HDevice reloaded won't work without it.")
		end
		return
	end	

	if GuthSCP then
		print("HDevice reloaded - Guthen Keycard System found but outdated, HDevice reloaded won't work with a old version.")
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("HDevice reloaded - Guthen Keycard System found but outdated, HDevice reloaded won't work with a old version.")
		end
		return
	end
	
	if file.Exists( "guth_scp/hdevice_blocked_buttons.txt", "DATA" ) then
		local txt = file.Read( "guth_scp/hdevice_blocked_buttons.txt", "DATA" )
		exceptionButtonID = util.JSONToTable( txt )
		newGuthSCP.exceptionButtonID = exceptionButtonID
		print( "HDevice reloaded - Buttons IDs loaded!" )
	else
		newGuthSCP.exceptionButtonID = {}
	end
end

hook.Add( "PostCleanupMap", "HDevice:GetIDsbycleanup", function()
	hdevicereloaded.load()
end )

hook.Add( "InitPostEntity", "HDevice:GetIDsbyentity", function()
	hdevicereloaded.load()
end )



if SERVER then
    concommand.Add( "hdevice_block_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end
		if not guthscp.configs.guthscpkeycard then return end

		local newGuthSCPconfig = guthscp.configs.guthscpkeycard

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = true

		if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
        file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )
        
        newGuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
    end )

    concommand.Add( "hdevice_unblock_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end
		if not guthscp.configs.guthscpkeycard then return end

		local newGuthSCPconfig = guthscp.configs.guthscpkeycard

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = nil

		if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
		file.Write( "guthscp/hdevice_reloaded_blockedb.txt", util.TableToJSON( exceptionButtonID ) )

        newGuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
	end )
end