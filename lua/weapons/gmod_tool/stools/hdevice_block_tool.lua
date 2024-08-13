if not guthscp then return end

TOOL.Category = "GuthSCP"
TOOL.Name = "#tool.guthscp_hdevicereloaded.name"

local hdevicereloaded = guthscp.modules.hdevicereloaded

--  languages
if CLIENT then
	--  information
	TOOL.Information = {
		{
			name = "left",
		},
		{
			name = "right",
		},
	}

	--  language
	language.Add( "tool.guthscp_hdevicereloaded.name", "Hdevice button blocker" )
	language.Add( "tool.guthscp_hdevicereloaded.desc", "allows you to block buttons on the hacking device." )
	language.Add( "tool.guthscp_hdevicereloaded.left", "Add looked entity to the block list" )
	language.Add( "tool.guthscp_hdevicereloaded.right", "Remove looked entity from the block list" )

	--  context panel
	function TOOL.BuildCPanel( cpanel )
		cpanel:AddControl( "Header", { Description = "#tool.guthscp_hdevicereloaded.desc" } )
	end

	local color_red = Color( 255, 0, 0 )
	function TOOL:DrawHUD()
		local x, y = ScrW() / 2, ScrH() * .75
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid( ent ) then return end

		--  NOTE: This warning is not exact, it doesn't say if you're actually authorized to use the tool. A hook.Run to "CanTool" could be useful here. 
		--  	  However it would need to be done in each tool. For now, this should be enough.
		if FPP and not FPP.canTouchEnt( ent, "Toolgun" ) then
			local text = "Falco's Prop Protection prevent you from editing this entity, please ensure both 'Admins can use tool on world/blocked entities' are enabled in the 'Toolgun options'!"
			draw.SimpleText( text, "DermaDefaultBold", x, y + 30, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

    /*
	hook.Add( "PreDrawHalos", "guthscp:map_entities_filter_configurator", function()
		local ply = LocalPlayer()

		local active_weapon = ply:GetActiveWeapon()
		if not IsValid( active_weapon ) or active_weapon:GetClass() ~= "gmod_tool" then return end

		local tool = ply:GetTool()
		if not istable( tool ) or tool.Mode ~= guthscp.filter.tool_mode then return end

		--  get filter
		local filter_id = tool:GetClientInfo( "filter_id" )
		if #filter_id == 0 then return end

		local filter = guthscp.filters[filter_id]
		assert( filter, "Filter '" .. filter_id .. "' doesn't exists!" )

		--  draw halos
		halo.Add( filter:get_entities(), Color( 255, 0, 0 ), 2, 2, 1, true, true )
	end )
    */
end

--  add access
function TOOL:LeftClick( tr )
    local ply = self:GetOwner()
    if SERVER then
        hdevicereloaded.addblockbutton(ply)
    end
end

--  remove access
function TOOL:RightClick( tr )
    local ply = self:GetOwner()
    if SERVER then
        hdevicereloaded.removeblockbutton(ply)
    end
end