local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local _, revert = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "RTAMode",
    name     = "RTA Mode",
    category = "RunModifiers",
    group    = "World & Combat Tweaks",
    tooltip  = "Disables all combat pausing encounters for RTA runs.",
    default  = false,
    dataMutation = false,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local bannedEncounters = {
    ArtemisCombatF = true,  ArtemisCombatF2 = true,  NemesisCombatF = true,       -- Erebus
    ArtemisCombatG = true,  ArtemisCombatG2 = true,  NemesisCombatG = true,       -- Oceanus
    NemesisCombatH = true,                                                         -- Fields
    NemesisCombatI = true,                                                         -- Tartarus
    ArtemisCombatN = true,  ArtemisCombatN2 = true,                               -- Ephyra
    HeraclesCombatN = true, HeraclesCombatN2 = true,                              -- Ephyra
    IcarusCombatO = true,   IcarusCombatO2 = true,                                -- Thessaly
    HeraclesCombatO = true, HeraclesCombatO2 = true,                              -- Thessaly
    AthenaCombatP = true,   AthenaCombatP02 = true,  IcarusCombatP = true,        -- Olympus
    HeraclesCombatP = true,                                                        -- Olympus
}

local function apply()
end

local function registerHooks()
    modutil.mod.Path.Wrap("ChooseEncounter", function(baseFunc, currentRun, room, args)
        if not lib.isEnabled(config) then return baseFunc(currentRun, room, args) end
        args = args or {}
        local source = args.LegalEncounters or room.LegalEncounters
        if source then
            local filtered = {}
            for _, enc in pairs(source) do
                if not bannedEncounters[enc] then
                    table.insert(filtered, enc)
                end
            end
            args.LegalEncounters = filtered
        end
        return baseFunc(currentRun, room, args)
    end)
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config) then apply() end
         if public.definition.dataMutation and not mods['adamant-Modpack_Core'] then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
rom.gui.add_to_menu_bar(uiCallback)
