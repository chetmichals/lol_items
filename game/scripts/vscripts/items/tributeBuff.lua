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

function tributeStartBuff( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_tribute_stack_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 )
	local itemName = keys.ability:GetAbilityName()

	if caster.tribute_buff_timer_number == nil then 
		caster.tribute_buff_timer_number = 1 
	else
		caster.tribute_buff_timer_number = caster.tribute_buff_timer_number + 1
	end
	local tributeTimerNumber = caster.tribute_buff_timer_number

	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	if caster.tribute_charges == nil then caster.tribute_charges = maximum_charges end	
	if caster.tribute_charges ~= maximum_charges then caster.start_tribute_charge = true else caster.start_tribute_charge = false end
	caster.tribute_cooldown = 0
	if caster.had_tribute_buff_before == nil then caster.had_tribute_buff_before = false end
	
	if caster.tribute_charges < maximum_charges then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {Duration = charge_replenish_time + .10} )
	else
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	end
	caster:SetModifierStackCount( modifierName, caster, caster.tribute_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			if tributeTimerNumber ~= caster.tribute_buff_timer_number or not keys.caster:HasItemInInventory(itemName) then 
				return nil 
			end

			if caster.start_tribute_charge and not caster.had_tribute_buff_before and caster.tribute_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.tribute_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .10 } )
					--tribute_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_tribute_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.tribute_charges = next_charge
			end

			caster.had_tribute_buff_before = false

			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.tribute_charges ~= maximum_charges then
				caster.start_tribute_charge = true
				return charge_replenish_time
			else
				return 0.25
			end
		end
	)
end

function tributeEndBuff( keys )
	keys.caster.had_tribute_buff_before = true
end

function tribute_break( keys )
	if keys.caster ~= keys.attacker then return nil end
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_tribute_broken"
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = ability:GetLevelSpecialValueFor("break_time",0) })
	ability:StartCooldown(ability:GetLevelSpecialValueFor("break_time",0))
end

function tribute_fire( keys )
	local caster = keys.caster
	local checkForBrokenMod = caster:FindModifierByName("modifier_tribute_broken")
	if caster.tribute_charges > 0 and checkForBrokenMod == nil and (keys.unit:IsHero() or keys.unit:IsBuilding()) then
		-- variables
		local ability = keys.ability
		local modifierName = "modifier_tribute_stack_counter_datadriven"
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 )

		-- Apply effect
		local damageDone = keys.ability:GetLevelSpecialValueFor("bonus_damage" , 0)
		--local bonusGold = keys.ability:GetLevelSpecialValueFor("bonus_damage" , 0)
		local damageTable =  
		{
			victim = keys.unit,
			attacker = keys.caster,
			damage = damageDone,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_tribute_broken", { Duration = .1, IsHidden = 1 })
		ApplyDamage(damageTable)
		keys.caster:ModifyGold(5, false, 0)
		
		-- Deplete charge
		local next_charge = caster.tribute_charges - 1
		if caster.tribute_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .10 } )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.tribute_charges = next_charge
	end
end