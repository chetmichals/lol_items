local function loadModule(name)
    local status, err = pcall(function()
        -- Load the module
        require(name)
    end)

    if not status then
        -- Tell the user about it
        print('WARNING: '..name..' failed to load!')
        print(err)
    end
end

--[[
Dota PvP game mode
]]

print( "Dota PvP game mode loaded." )
GameRules:Playtesting_UpdateAddOnKeyValues()

if DotaPvP == nil then
	DotaPvP = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.DotaPvP = DotaPvP()
    GameRules.DotaPvP:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function DotaPvP:InitGameMode()
	loadModule ( 'util' )
	loadModule ( 'timers' )
	local GameMode = GameRules:GetGameModeEntity()
	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
	GameRules:SetSameHeroSelectionEnabled( true )
	
	-- Register Think
	GameMode:SetContextThink( "DotaPvP:GameThink", function() return self:GameThink() end, 0.25 )

	-- Register Game Events
	
	--Hooks
	ListenToGameEvent('npc_spawned', Dynamic_Wrap( DotaPvP, 'OnNPCSpawned' ), self )
    ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( DotaPvP, "OnPlayerPicked" ), self )
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(DotaPvP, 'AbilityFilter'), self)
	
end

--------------------------------------------------------------------------------
function DotaPvP:GameThink()
	return 0.25
end

function DotaPvP:AbilityFilter( keys )
	print("----New Ability-----")
	--keys.value = keys.value * 20
	PrintTable (keys)
	--handle = EntIndexToHScript(keys.entindex_caster_const)
	--print(handle:IsItem())
	--PrintTable(handle)
	return true
end

function DotaPvP:OnNPCSpawned( keys )
  local spawnedUnit = EntIndexToHScript( keys.entindex )
  if spawnedUnit:GetUnitName() == "npc_dota_hero_drow_ranger" then
	local spell = spawnedUnit:FindAbilityByName("ashe_focus_passive")
	spell:SetLevel(1)
  end
  
  local spawnedUnit = EntIndexToHScript( keys.entindex )
  if spawnedUnit:IsHero() then
	spawnedUnit.intBonus = 0
  end
end

function DotaPvP:OnPlayerPicked( event )
    local spawnedUnitIndex = EntIndexToHScript(event.heroindex)
    -- Apply timer to update stats
    --DotaPvP:ModifyStatBonuses(spawnedUnitIndex)
end


function DotaPvP:ModifyStatBonuses(unit)
	local spawnedUnitIndex = unit
	print("modifying stat bonuses")
		Timers:CreateTimer(DoUniqueString("updateHealth_" .. spawnedUnitIndex:GetPlayerID()), {
		endTime = 0.25,
		callback = function()
			-- ==================================
			-- Adjust health based on strength
			-- ==================================
 
			-- Get player intelligence
			local intelligence = spawnedUnitIndex:GetIntellect()
 
			--Check if intBonus is stored on hero, if not set it to 0
			if spawnedUnitIndex.intBonus == nil then
				spawnedUnitIndex.intBonus = 0
			end
 
			-- If player int is different this time around, start the adjustment
			if intelligence ~= spawnedUnitIndex.intBonus then
				-- Modifier values
				local bitTable = {512,256,128,64,32,16,8,4,2,1}
 
				-- Gets the list of modifiers on the hero and loops through removing and health modifier
				local modCount = spawnedUnitIndex:GetModifierCount()
				for i = 0, modCount do
					for u = 1, #bitTable do
						local val = bitTable[u]
						if spawnedUnitIndex:GetModifierNameByIndex(i) == "modifier_int_mod_" .. val  then
							spawnedUnitIndex:RemoveModifierByName("modifier_int_mod_" .. val)
						end
					end
				end
 
				-- Creates temporary item to steal the modifiers from
				local intUpdater = CreateItem("item_int_modifier", nil, nil) 
				for p=1, #bitTable do
					local val = bitTable[p]
					local count = math.floor(intelligence / val)
					if count >= 1 then
						intUpdater:ApplyDataDrivenModifier(spawnedUnitIndex, spawnedUnitIndex, "modifier_int_mod_" .. val, {})
						intelligence = intelligence - val
					end
				end
				-- Cleanup
				UTIL_RemoveImmediate(intUpdater)
				intUpdater = nil
			end
			-- Updates the stored intelligence bonus value for next timer cycle
			spawnedUnitIndex.intBonus = spawnedUnitIndex:GetIntellect()
			return 0.25
		end
	})
end


