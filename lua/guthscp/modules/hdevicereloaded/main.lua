local MODULE = {
	name = "Hacking Device",
	author = "Augaton",
	version = "1.1.1",
	description = [[Control what the CI do with their Hacking Device.]],
	icon = "icon16/key.png",
	version_url = "https://raw.githubusercontent.com/augaton/scp-hacking-device-reloaded/main/lua/guthscp/modules/hdevicereloaded/main.lua",
	dependencies = {
		base = "2.2.0",
        guthscpkeycard = "2.1.4",
	},
	requires = {
		["server.lua"] = guthscp.REALMS.SERVER,
	},
}

MODULE.menu = {
	--  config
	config = {
		form = {
			"Configuration",
			{
				type = "Number",
				name = "Hack Time",
				id = "hdevice_hack_time",
				desc = "Amount of seconds needed for hacking device to open certain door.",
				default = 5,
				decimals = 2,
			},
            {
			    type = "Number",
				name = "Max Accreditation Hack",
				id = "hdevice_hack_max",
				desc = "Highest level that the device can crack.",
				default = 5,
				decimals = 0,
			},
			{
			    type = "Number",
				name = "Sound delay time",
				id = "hdevice_hacking_timesound",
				desc = "Time between hacking sound",
				default = 5,
				decimals = 0,
			},
			{
				type = "String",
				name = "Hacking Sound",
				id = "hdevice_hacking_sound",
				desc = "Sound that's play when hacking",
				default = "buttons/blip2.wav",
			},

			--  translations
            
			"Translations Messages",
			{
				type = "String",
				name = "Hack Start",
				id = "translation_start",
				desc = "Text shown to the player when the hack is starting",
				default = "Hacking Started!",
			},
			{
				type = "String",
				name = "Hack Done",
				id = "translation_done",
				desc = "Text shown to the player when the hack is complete",
				default = "Hacking Done!",
			},
			{
				type = "String",
				name = "Hack Failed",
				id = "translation_failed",
				desc = "Text shown to the player when the hack is failed because the player move the mouse outside the button",
				default = "Hacking FAILED!",
			},
			{
				type = "String",
				name = "Level Exceeded the max",
				id = "translation_try_bigger_max",
				desc = "Text shown to the player whose access was restricted because the max level of the device is exceeded . Available arguments: '{level}'",
				default = "Hacking limited to LVL {level} Keycard",
			},
			{
				type = "String",
				name = "Button block",
				id = "translation_blocked",
				desc = "Text shown when the button is blocked by a admin using the command 'hdevice_block_button'",
				default = "Can't hack this!",
			},
			{
				type = "String",
				name = "Hack don't need",
				id = "translation_dont_need",
				desc = "Text shown when the button doesn't have a accreditation",
				default = "No Hack needed!",
			},

			"Translations HUD",
			{
				type = "String",
				name = "Hack don't need",
				id = "translation_dont_need_hud",
				desc = "Text shown when the button doesn't have a accreditation",
				default = "No hack needed",
			},
			{
				type = "String",
				name = "Door level",
				id = "translation_level_hud",
				desc = "Text shown to the player that indicate the level of the door that looking. Available arguments: '{level}'",
				default = "Keycard LVL Required: {level}",
			},
			{
				type = "String",
				name = "Estimated time",
				id = "translation_estimated_time_hud",
				desc = "Text shown to the player that show the estimated time that the hack take. Available arguments: '{time}'",
				default = "Estimated Hack Time: {time}s",
			},
            
		},
	},
	--  details
	details = {
		{
			text = "CC-BY-SA",
			icon = "icon16/page_white_key.png",
		},
		"Social",
		{
			text = "Github",
			icon = "guthscp/icons/github.png",
			url = "https://github.com/augaton/scp-hacking-device-reloaded",
		},
		{
			text = "Steam",
			icon = "guthscp/icons/steam.png",
			url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3302753364"
		},
		{
			text = "Discord",
			icon = "guthscp/icons/discord.png",
			url = "https://discord.gg/kJFQe95pgh",
		},
	},
}

function MODULE:init()

	--  warn for old version
	timer.Simple( 0, function()
		if hook.GetTable()["PlayerInitialSpawn"] then
			if hook.GetTable()["PlayerInitialSpawn"]["HDevice:GetIDs"] then
				local text = "The old version of this addon is currently running on this server. Please, delete the '[SCP] Hacking Device by zgredinzyyy' addon to avoid any possible conflicts."
				self:add_error( text )
				self:error( text )
			end
		end
	end )

    MODULE:info("The Hacking Device has been loaded !")
end

guthscp.module.hot_reload( "hdevicereloaded" )
return MODULE
