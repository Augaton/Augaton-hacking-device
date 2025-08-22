if not guthscp then
	error( "HackingDevice - fatal error! https://github.com/Guthen/guthscpbase must be installed on the server!" )
	return
end

local hdevicereloaded = guthscp.modules.hdevicereloaded
local confighdevice = guthscp.configs.hdevicereloaded

SWEP.PrintName			    = confighdevice.weapon_name
SWEP.Category				= "GuthSCP"
SWEP.Author			        = "Augaton & Guthen"
SWEP.Instructions		    = "Press Left Mouse Button to hack nearest doors."

SWEP.Spawnable              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight	                = 5
SWEP.AutoSwitchTo		    = false
SWEP.AutoSwitchFrom		    = false

SWEP.Slot			        = 1
SWEP.SlotPos			    = 2
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ShouldDropOnDie 		= false

SWEP.GuthSCPLVL       		= 0 -- Starting with 0 so player can't open doors without hacking and let keycard system asociate this SWEP with keycard

// Keycard Modification

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
    ["ValveBiped.Bip01_R_Finger41"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 76.401, 0) },
    ["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(1.445, 6.422, 0) },
    ["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(1.062, -0.332, 2.141), angle = Angle(0.365, 0, 0) },
    ["Detonator"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
    ["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(1.542, 3.132, -36.667) },
    ["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(-0.732, -0.028, -0.242), angle = Angle(-0.127, -0.856, 1.082) },
    ["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(-1.852, -0.48, 3.42), angle = Angle(0, 0, 0) },
    ["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
    ["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(27.715, 40.37, -3.425) }
}

SWEP.VElements = {
    ["CIHD"] = { type = "Model", model = "models/arsen/CIHackingDevice.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4.903, 6.736, 1.467), angle = Angle(36.397, -176.864, 1.268), size = Vector(2, 2, 2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["CIHD"] = { type = "Model", model = "models/arsen/CIHackingDevice.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.653, 6.964, -1.315), angle = Angle(-123.943, 6.752, 5.219), size = Vector(3.22, 2.378, 1.988), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

// End (Thanks Arsen)

local hackingdevice_hack_time = confighdevice.hdevice_hack_time
local hackingdevice_hack_max = confighdevice.hdevice_hack_max

local newGuthSCP = guthscp.modules.guthscpkeycard
local newGuthSCPconfig = guthscp.configs.guthscpkeycard

function SWEP:Success(ent)
	self.isHacking = false
	self:GetOwner():SetNWBool("isHacking", false)
	if SERVER then guthscp.player_message( self:GetOwner(), confighdevice.translation_done ) end
	ent:Use(self:GetOwner(), ent, 4, 1)
	self:GetOwner():EmitSound("ambient/energy/spark3.wav", 65, 100, 1, CHAN_AUTO) -- Sounds exported from HL2
end

function SWEP:Open(ent)
	ent:Use(self:GetOwner(), ent, 4, 1)
end

function SWEP:Failure(fail) -- 1 = Moved mouse, moved too far, 2 = Hacking limited to certain LVL, else = Button blocked
	self.isHacking = false
	self:GetOwner():SetNWBool("isHacking", false)
	if fail == 1 then
		if SERVER then guthscp.player_message( self:GetOwner(), confighdevice.translation_failed ) end
	elseif fail == 2 then
	local max_text = guthscp.helpers.format_message(
	confighdevice.translation_try_bigger_max,
	{
		level = hackingdevice_hack_max,
	}
	)
		if SERVER then guthscp.player_message( self:GetOwner(), max_text ) end
	else
		if SERVER then guthscp.player_message( self:GetOwner(), confighdevice.translation_blocked ) end 
	end
end

local function isButtonExempt(id)
	if not hdevicereloaded.exceptionButtonID then return false end
	if not hdevicereloaded.exceptionButtonID[game.GetMap()] then return false end
	return hdevicereloaded.exceptionButtonID[game.GetMap()][id]
end

function SWEP:PrimaryAttack()

	self.nextFire = 0

    local tr = self:GetOwner():GetEyeTrace()
	local ent = tr.Entity
	local trLVL = newGuthSCP.get_entity_level(ent)

	-- check if everything ok
	if not newGuthSCP then return end -- If no Base Guthen Keycard sys = end
	if not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then return end -- No keycard table
	if not hdevicereloaded.exceptionButtonID then return end -- No buttons file

	hackingdevice_hack_time = confighdevice.hdevice_hack_time
	hackingdevice_hack_max = confighdevice.hdevice_hack_max

	timeridentity = "Hackingsound: "..ent:EntIndex()

	if trLVL < 0 then if SERVER then guthscp.player_message( self:GetOwner(), confighdevice.translation_dont_need ) end return end
	if self.isHacking then return end
	if not IsValid(ent) then return end
	if tr.HitPos:Distance(self:GetOwner():GetShootPos()) > 50 then return end
	if trLVL == 0 and not isButtonExempt(ent:MapCreationID()) then
		self:Open(ent)

	elseif trLVL <= hackingdevice_hack_max and not isButtonExempt(ent:MapCreationID()) then
		self:GetOwner():EmitSound("ambient/machines/keyboard1_clicks.wav", 60, 100, 1, CHAN_AUTO)

		if SERVER then guthscp.player_message( self:GetOwner(), confighdevice.translation_start ) end
		
		self.isHacking = true
		self:GetOwner():SetNWBool("isHacking", true)

		self.startHack = CurTime()
		self.endHack = CurTime() + newGuthSCP.get_entity_level(ent) * hackingdevice_hack_time
		self:GetOwner():SetNWInt("endHack", self.endHack)

		if confighdevice.hacking_sound_bool then
			timer.Create(timeridentity, confighdevice.hdevice_hacking_timesound, self.endHack/confighdevice.hdevice_hacking_timesound, function()
				self:EmitSound(confighdevice.hdevice_hacking_sound, 100, 100)
			end)
		end

	elseif isButtonExempt(ent:MapCreationID()) then
		self:Failure(3)
		timer.Remove(timeridentity)

	elseif IsValid(tr.Entity) and tr.HitPos:Distance(self:GetOwner():GetShootPos()) < 50 and trLVL ~= 0 and trLVL > hackingdevice_hack_max then
		self:Failure(2)
		timer.Remove(timeridentity)
	end
end

function SWEP:SecondaryAttack() end

function SWEP:Think()
    local tr = self:GetOwner():GetEyeTrace()
	local ent = tr.Entity
	local ply = self:GetOwner()

    if not self.startHack then
		self.startHack = 0
		self.endHack = 0
	end

	if self.isHacking and IsValid(ply) then
		if not IsValid(tr.Entity) or tr.HitPos:Distance(ply:GetShootPos()) > 50 or not newGuthSCPconfig.keycard_available_classes[ ent:GetClass() ] then
			self:Failure(1)
			timer.Remove(timeridentity)
		elseif self.endHack <= CurTime() then
			self:Success(tr.Entity)
			timer.Remove(timeridentity)
		end
	else
		self.startHack = 0
		self.endHack = 0
	end
	
	self:NextThink(CurTime())
	return true
end

function SWEP:DrawHUD()
	
    local ply = self:GetOwner()
	if not IsValid( ply ) or not ply:Alive() then return end

	local trg = ply:GetEyeTrace().Entity
	local tr = self:GetOwner():GetEyeTrace()

	hackingdevice_hack_time = confighdevice.hdevice_hack_time
	hackingdevice_hack_max = confighdevice.hdevice_hack_max

	if not IsValid( trg ) then return end
	if not newGuthSCPconfig.keycard_available_classes[ trg:GetClass() ] then return end
	
	local level = newGuthSCP.get_entity_level(trg)

    if level and tr.HitPos:Distance(ply:GetShootPos()) < 50 then

		if level < 0 then draw.SimpleText( confighdevice.translation_dont_need_hud, "ChatFont", ScrW() / 2 + 50, ScrH() / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) return end

		local hud_door_level = guthscp.helpers.format_message(
		confighdevice.translation_level_hud,
		{
			level = level,
		}
		)
		draw.SimpleText( hud_door_level, "ChatFont", ScrW() / 2 + 50, ScrH() / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		local equation = level * hackingdevice_hack_time

		local hud_time_estimate = guthscp.helpers.format_message(
		confighdevice.translation_estimated_time_hud,
		{
			time = equation,
		}
		)
		
		if level ~= 0 then
			draw.SimpleText( hud_time_estimate , "ChatFont", ScrW()/2+50, ScrH()/2+15, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end


		// Partie Hacking

		if not IsValid(ply) or not ply:GetNWBool("isHacking") then return end

		local scrW, scrH = ScrW(), ScrH()
		local boxW, boxH = 200, 30
		local x, y = scrW / 2 - boxW / 2, scrH / 2.2
		local endTime = ply:GetNWInt("endHack") or 0
		local timeLeft = math.max(0, endTime - CurTime())

		local totalTime = hackingdevice_hack_time * (level or 1)
		local progress = math.Clamp(1 - (timeLeft / totalTime), 0, 1)
		local percent = math.Round(progress * 100, 1)

		// Contour externe néon
		surface.SetDrawColor(0, 255, 100, 60)
		surface.DrawOutlinedRect(x - 3, y - 3, boxW + 6, boxH + 6, 4)

		// Fond
		surface.SetDrawColor(10, 10, 10, 200)
		surface.DrawRect(x, y, boxW, boxH)

		// Barre de progression
		surface.SetDrawColor(0, 255, 100, 220)
		surface.DrawRect(x, y, boxW * progress, boxH)

		// Contour interne fin
		surface.SetDrawColor(0, 255, 100, 90)
		surface.DrawOutlinedRect(x, y, boxW, boxH, 1.5)

		// Texte centré
		draw.SimpleText(percent .. "%", "DermaLarge", scrW / 2, y + boxH / 2, Color(221, 4, 4), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		// Texte en haut
		draw.SimpleText(confighdevice.translation_hacking_hud, "Trebuchet24", scrW / 2, y - 25, Color(0, 255, 150, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
end

--
-- SWEP Construction Kit
--

function SWEP:Initialize()

    self:SetHoldType(self.HoldType)

    -- Ustawienie rąk zależnie od modelu gracza
    if SERVER then
        local ply = self.Owner
        if IsValid(ply) then
            local hands = ply:GetHands()
            if IsValid(hands) then
                local handModel = player_manager.TranslatePlayerHands(ply:GetModel())
                if handModel then
                    hands:SetModel(handModel.model)
                    hands:SetSkin(handModel.skin)
                    hands:SetBodyGroups(handModel.body)
                end
            end
        end
    end

    if CLIENT then
        -- Tworzenie kopii tablicy dla każdego przypadku broni
        self.VElements = table.FullCopy(self.VElements)
        self.WElements = table.FullCopy(self.WElements)
        self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)

        self:CreateModels(self.VElements) -- Tworzenie modeli viewmodelu
        self:CreateModels(self.WElements) -- Tworzenie modeli worldmodelu

        -- Inicjalizacja połączeń modelu viewmodel
        if IsValid(self.Owner) then
            local vm = self.Owner:GetViewModel()
            if IsValid(vm) then
                self:ResetBonePositions(vm)
                
                -- Ustawienia widoczności modelu
                if (self.ShowViewModel == nil or self.ShowViewModel) then
                    vm:SetColor(Color(255, 255, 255, 255))
                else
                    vm:SetColor(Color(255, 255, 255, 1))
                    vm:SetMaterial("Debug/hsv")
                end
            end
        end
    end
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

// Icon

if CLIENT then
   	SWEP.WepSelectIcon = surface.GetTextureID("vgui/weapons/arsen/CIHD_icon")
    SWEP.BounceWeaponIcon = false -- désactive l'effet de rebond
    killicon.Add("weapon_hdevice", "vgui/weapons/arsen/CIHD_icon", Color(255, 255, 255, 255))
end
