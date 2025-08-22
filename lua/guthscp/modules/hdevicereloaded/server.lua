local exceptionButtonID = exceptionButtonID or
{
}

local hdevicereloaded = guthscp.modules.hdevicereloaded

if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end

local map_name = game.GetMap()
local path = "guthscp/hdevicereloaded/" .. map_name .. "/blockhdevice" .. map_name .. ".txt"

hdevicereloaded.exceptionButtonID = {}

if not file.Exists(path, "DATA")then
	hdevicereloaded.exceptionButtonID[game.GetMap()] = {}
	file.Write( path, util.TableToJSON( exceptionButtonID ) )
else
	local txt = file.Read( path, "DATA" )
    exceptionButtonID = util.JSONToTable( txt )
	if not hdevicereloaded.exceptionButtonID[game.GetMap()] then hdevicereloaded.exceptionButtonID[game.GetMap()] = {} end
	file.Write( path, util.TableToJSON( exceptionButtonID ) )
end

function hdevicereloaded.load()
	if file.Exists( path, "DATA" ) then
		local txt = file.Read( path, "DATA" )
		exceptionButtonID = util.JSONToTable( txt )
		hdevicereloaded.exceptionButtonID = exceptionButtonID
		print( "HDevice reloaded - Buttons IDs loaded!" )
	else
		hdevicereloaded.exceptionButtonID = {}
	end
end

hook.Add( "PostCleanupMap", "HDevice:GetIDsbycleanup", function()
	hdevicereloaded.load()
end )

hook.Add( "InitPostEntity", "HDevice:GetIDsbyentity", function()
	hdevicereloaded.load()
end )


function hdevicereloaded.addblockbutton(ply)
	if not ply:IsValid() or not ply:IsSuperAdmin() then return end
	if not guthscp.configs.guthscpkeycard then return end

	local newGuthSCPconfig = guthscp.configs.guthscpkeycard

	local ent = ply:GetEyeTrace().Entity
	if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
		guthscp.player_message( ply, "HDevice - Invalid entity selected!" )
		return
	end

	if not hdevicereloaded.exceptionButtonID[game.GetMap()] then hdevicereloaded.exceptionButtonID[game.GetMap()] = {} end
	hdevicereloaded.exceptionButtonID[game.GetMap()][ent:MapCreationID()] = true

	if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
	file.Write( path, util.TableToJSON( exceptionButtonID ) )
	
	hdevicereloaded.exceptionButtonID = exceptionButtonID

	guthscp.player_message( ply, "HDevice - The button has been succesfully blocked" )
end

function hdevicereloaded.removeblockbutton(ply)
	if not ply:IsValid() or not ply:IsSuperAdmin() then return end
	if not guthscp.configs.guthscpkeycard then return end

	local newGuthSCPconfig = guthscp.configs.guthscpkeycard

	local ent = ply:GetEyeTrace().Entity
	if not IsValid( ent ) or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then 
		guthscp.player_message( ply, "HDevice - Invalid entity selected!" )
		return
	end

	if not hdevicereloaded.exceptionButtonID[game.GetMap()] then hdevicereloaded.exceptionButtonID[game.GetMap()] = {} end
	hdevicereloaded.exceptionButtonID[game.GetMap()][ent:MapCreationID()] = nil

	if not file.Exists( "guthscp", "DATA" ) then file.CreateDir( "guthscp" ) end
	file.Write( path, util.TableToJSON( exceptionButtonID ) )

	hdevicereloaded.exceptionButtonID = exceptionButtonID

	guthscp.player_message( ply, "HDevice - The button has been succesfully unblocked" )
end

if SERVER then
    concommand.Add( "hdevice_block_button", function( ply )
		hdevicereloaded.addblockbutton(ply)
    end )

    concommand.Add( "hdevice_unblock_button", function( ply )
		hdevicereloaded.removeblockbutton(ply)
	end )
end