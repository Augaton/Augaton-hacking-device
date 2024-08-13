if not guthscp then return end

TOOL.Category = "GuthSCP"
TOOL.Name = "#tool.guthscp_hdevicereloaded.name"

local hdevicereloaded = guthscp.modules.hdevicereloaded
local config = guthscp.configs.guthscpkeycard

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
		local ent = LocalPlayer():GetUseEntity()
		if not IsValid( ent ) then return end

        local can_be_used = config.keycard_available_classes[ent:GetClass()]

        --  alert from FPP prohibition 
        if FPP and not FPP.canTouchEnt( ent, "Toolgun" ) then
            text_info = "Falco's Prop Protection prevent you from editing this entity, please ensure both 'Admins can use tool on world/blocked entities' are enabled in the 'Toolgun options'!"
        end

        --  draw entity
        draw.SimpleText( "Target: " .. tostring( ent ), "Trebuchet24", x, y, can_be_used and color_white or color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

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