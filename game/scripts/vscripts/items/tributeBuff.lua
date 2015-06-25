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
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {Duration = charge_replenish_time + .05} )
	else
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	end
	caster:SetModifierStackCount( modifierName, caster, caster.tribute_charges )
	
	print("starting timer")
	-- create timer to restore stack
	Timers:CreateTimer( function()
			if tributeTimerNumber ~= caster.tribute_buff_timer_number and not keys.caseter:HasItemInInventory(itemName) then 
				print("Killing Charge Timer")
				return nil 
			end

			if caster.start_tribute_charge and not caster.had_tribute_buff_before and caster.tribute_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.tribute_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .05 } )
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
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_tribute_broken"
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = ability:GetLevelSpecialValueFor("break_time",0) })
end

function tribute_fire( keys )
	-- To do, check if target is building or champ, and if so do extra damage and give moneys
	local caster = keys.caster
	local checkForBrokenMod = caster:FindModifierByName("modifier_tribute_broken")
	if keys.caster.tribute_charges > 0 and checkForBrokenMod == nil then
		-- variables
		local ability = keys.ability
		local modifierName = "modifier_tribute_stack_counter_datadriven"
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 ) + .05
		
		-- Deplete charge
		local next_charge = caster.tribute_charges - 1
		if caster.tribute_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			--tribute_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.tribute_charges = next_charge
	end
end