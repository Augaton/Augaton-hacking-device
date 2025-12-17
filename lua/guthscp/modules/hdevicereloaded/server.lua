local hdevicereloaded = guthscp.modules.hdevicereloaded
hdevicereloaded.exceptionButtonID = hdevicereloaded.exceptionButtonID or {}
local relative_path = guthscp.modules.hdevicereloaded.relative_path

function hdevicereloaded.save_db()
    local data = hdevicereloaded.exceptionButtonID[map_name] or {}
    local json = util.TableToJSON( data, true )
    
    guthscp.data.save( relative_path, json )
end

function hdevicereloaded.load()
    if guthscp.data.exists( relative_path ) then
        local txt = guthscp.data.read( relative_path )
        hdevicereloaded.exceptionButtonID[map_name] = util.JSONToTable( txt ) or {}
        print( "[HDevice] Données chargées pour la map : " .. map_name )
    else
        hdevicereloaded.exceptionButtonID[map_name] = {}
    end
end

hook.Add("Initialize", "HDevice:LoadData", function()
    hdevicereloaded.load()
end)

hook.Add("PostCleanupMap", "HDevice:ReloadOnCleanup", function()
    hdevicereloaded.load()
end)

function hdevicereloaded.addblockbutton(ply)
    if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
    
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end

    hdevicereloaded.exceptionButtonID[map_name] = hdevicereloaded.exceptionButtonID[map_name] or {}
    hdevicereloaded.exceptionButtonID[map_name][ent:MapCreationID()] = true

    hdevicereloaded.save_db()
    guthscp.player_message(ply, "HDevice - Objet bloqué avec succès.")
end

function hdevicereloaded.removeblockbutton(ply)
    if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
    
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end

    if hdevicereloaded.exceptionButtonID[map_name] then
        hdevicereloaded.exceptionButtonID[map_name][ent:MapCreationID()] = nil
    end

    hdevicereloaded.save_db()
    guthscp.player_message(ply, "HDevice - Blocage retiré.")
end

if SERVER then
    concommand.Add( "hdevice_block_button", function( ply )
		hdevicereloaded.addblockbutton(ply)
    end )

    concommand.Add( "hdevice_unblock_button", function( ply )
		hdevicereloaded.removeblockbutton(ply)
	end )
end