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

loadModule ( 'util' )

function spoils_of_war_start_buff( keys )
	PrintTable(keys)

	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
	local modifierName = "modifier_spoils_of_war_stack_counter_datadriven"
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 )
	local itemName = keys.ability:GetAbilityName()

	if caster.spoils_of_war_buff_timer_number == nil then 
		caster.spoils_of_war_buff_timer_number = 1 
	else
		caster.spoils_of_war_buff_timer_number = caster.spoils_of_war_buff_timer_number + 1  
	end
	local spoils_of_warTimerNumber = caster.spoils_of_war_buff_timer_number

	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.spoils_of_war_charges = 0
	if caster.had_spoils_of_war_buff_before == nil then caster.had_spoils_of_war_buff_before = false end
	
	if caster.spoils_of_war_charges < maximum_charges then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {Duration = charge_replenish_time + .10} )
	else
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	end

	--If Melee, give melee bonus
	if not caster:IsRangedAttacker() then ability:ApplyDataDrivenModifier( caster, caster, "modifier_spoils_of_war_melee_bonus", {} ) end

	caster:SetModifierStackCount( modifierName, caster, caster.spoils_of_war_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			if spoils_of_warTimerNumber ~= caster.spoils_of_war_buff_timer_number or not keys.caster:HasItemInInventory(itemName) then 
				return nil 
			end

			if caster.start_spoils_of_war_charge and not caster.had_spoils_of_war_buff_before and caster.spoils_of_war_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.spoils_of_war_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .10 } )
					--spoils_of_war_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_spoils_of_war_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.spoils_of_war_charges = next_charge
			end

			caster.had_spoils_of_war_buff_before = false

			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.spoils_of_war_charges ~= maximum_charges then
				caster.start_spoils_of_war_charge = true
				return charge_replenish_time
			else
				return 0.25
			end
		end
	)
end

function spoils_of_war_end_buff( keys )
	keys.caster.had_spoils_of_war_buff_before = true
end

function spoils_of_war_melee_bonus( keys )
	print ("melee guy attack!")

	--To Do, 
end

function spoils_of_war_fire( keys )
	-- To do, check if target is building or champ, and if so do extra damage and give moneys
	PrintTable(keys)
	local validUnit = (keys.unit:IsCreep() or keys.unit:IsNeutralUnitType() or keys.unit:IsMechanical())
	if validUnit ~= true then return nil end
	local caster = keys.caster
	local checkForBrokenMod = caster:FindModifierByName("modifier_spoils_of_war_broken")
	keys.caster.spoils_of_war_charges = 1
	if keys.caster.spoils_of_war_charges > 0 and checkForBrokenMod == nil then

		
		--Check if there is an allied unit in the area
		checkRadius = keys.ability:GetLevelSpecialValueFor( "search_radius", 0 )
		unitCheck = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor( "search_radius", 0 ), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
		local alliedUnit = nil
		if #unitCheck > 1 then 
			for i,units in ipairs(unitCheck) do
				if units ~= keys.attacker then
					alliedUnit = units
					break
				end
			end
		else
			return nil
		end

		--Apply Effects
		keys.attacker:Heal(40,keys.attacker)
		alliedUnit:Heal(40,keys.attacker)

		goldToGrant = keys.unit:GetGoldBounty()
		alliedUnit:ModifyGold(goldToGrant,false,0)



		-- variables
		local ability = keys.ability
		local modifierName = "modifier_spoils_of_war_stack_counter_datadriven"
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 )
		
		-- Deplete charge
		local next_charge = caster.spoils_of_war_charges - 1
		if caster.spoils_of_war_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .10 } )
			--spoils_of_war_start_cooldown( caster, charge_replenish_time )
		end

		

		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.spoils_of_war_charges = next_charge
	end
end