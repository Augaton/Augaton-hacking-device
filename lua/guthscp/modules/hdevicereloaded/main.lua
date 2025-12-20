local MODULE = {
    name = "Hacking Device",
    author = "Augaton",
    version = "1.3.4",
    description = [[Control what the CI do with their Hacking Device.]],
    icon = "icon16/key.png",
    version_url = "https://raw.githubusercontent.com/augaton/scp-hacking-device-reloaded/main/lua/guthscp/modules/hdevicereloaded/main.lua",
    dependencies = {
        base = "2.4.0",
        guthscpkeycard = "2.1.6",
    },
    requires = {
        ["server.lua"] = guthscp.REALMS.SERVER,
    },
}

MODULE.menu = {
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
                type = "Bool",
                name = "Show Time on HUD",
                id = "hdevice_show_time_hud",
                desc = "Should the remaining time be displayed on the HUD during hacking?",
                default = true,
            },

            "Hacking Sound",
            {
                type = "Bool",
                name = "Enable Sound",
                id = "hacking_sound_bool",
                desc = "Should the hacking have a sound when used?",
                default = true,
            },
            {
                type = "Number",
                name = "Sound Delay",
                id = "hdevice_hacking_timesound",
                desc = "Time between each hacking beep.",
                default = 1, -- Réduit à 1 par défaut pour être plus réaliste
                decimals = 1,
            },
            {
                type = "String",
                name = "Sound Path",
                id = "hdevice_hacking_sound",
                desc = "Sound path played when hacking.",
                default = "buttons/blip2.wav",
            },

            "RNG Chaos",
            {
                type = "Bool",
                name = "Enable Random Time",
                id = "hdevice_rng_enabled",
                desc = "Should the hack time be randomized?",
                default = false,
            },
            {
                type = "Number",
                name = "Randomness Percentage",
                id = "hdevice_rng_percentage",
                desc = "Variation percentage (e.g., 20 for +/- 20%).",
                default = 20,
                min = 0,
                max = 100,
                decimals = 0,
            },

            "Translations Messages",
            {
                type = "String",
                name = "Weapon Name",
                id = "weapon_name",
                desc = "Display name of the SWEP.",
                default = "SCP - Hacking Device",
            },
            {
                type = "String",
                name = "Hack Start",
                id = "translation_start",
                desc = "Message when starting.",
                default = "Hacking Started!",
            },
            {
                type = "String",
                name = "Hack Done",
                id = "translation_done",
                desc = "Message when successful.",
                default = "Hacking Done!",
            },
            {
                type = "String",
                name = "Hack Failed",
                id = "translation_failed",
                desc = "Message when failed.",
                default = "Hacking FAILED!",
            },
            {
                type = "String",
                name = "Level Exceeded",
                id = "translation_try_bigger_max",
                desc = "Message when level is too high. Arg: {level}",
                default = "Hacking limited to LVL {level} Keycard",
            },
            {
                type = "String",
                name = "Button Blocked",
                id = "translation_blocked",
                desc = "Message when button is manually blocked.",
                default = "Can't hack this!",
            },
            {
                type = "String",
                name = "No Hack Needed",
                id = "translation_dont_need",
                desc = "Message when door is already open/unlocked.",
                default = "No Hack needed!",
            },

            "Translations HUD",
            {
                type = "String",
                name = "HUD Level",
                id = "translation_level_hud",
                desc = "Door level text. Arg: {level}",
                default = "Keycard LVL Required: {level}",
            },
            {
                type = "String",
                name = "HUD Progress",
                id = "translation_hacking_hud",
                desc = "Text above the progress bar.",
                default = "HACKING IN PROGRESS...",
            },
            {
                type = "String",
                name = "HUD Time Remaining",
                id = "translation_time_remaining_hud",
                desc = "Text for time remaining. Arg: {time}",
                default = "Temps restant : {time}s",
            },
        },
    },
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

-- Logique de migration et init inchangée
MODULE.map_name = game.GetMap()
MODULE.relative_path = "hdevicereloaded/" .. MODULE.map_name .. "/blockhdevice.txt"
local old_path = "guthscp/hdevicereloaded/" .. MODULE.map_name .. "/blockhdevice" .. MODULE.map_name .. ".txt"
local old_old_path = "guth_scp/hdevice_blocked_buttons.txt"

function MODULE:init()
    self.path = guthscp.modules.hdevicereloaded.relative_path
    if file.Exists( old_path, "DATA" ) then
        guthscp.data.move_file( old_path, self.path )
    end
    if file.Exists( old_old_path, "DATA" ) and not file.Exists( "guthscp/" .. self.path, "DATA" ) then
        local content = file.Read( old_old_path, "DATA" )
        if content then
            file.CreateDir( "guthscp/hdevicereloaded/" .. self.map_name )
            file.Write( "guthscp/" .. self.path, content )
            file.Rename( old_old_path, old_old_path .. ".bak" )
        end
    end
    timer.Simple( 0, function()
        if hook.GetTable()["PlayerInitialSpawn"] and hook.GetTable()["PlayerInitialSpawn"]["HDevice:GetIDs"] then
            local text = "Old version of Hacking Device detected. Please remove it."
            self:add_error( text )
        end
    end )
    self:info( "The Hacking Device has been loaded !" )
end

guthscp.module.hot_reload( "hdevicereloaded" )
return MODULE