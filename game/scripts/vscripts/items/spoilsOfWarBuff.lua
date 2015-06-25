function spoils_of_war_start_buff( keys )
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
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {Duration = charge_replenish_time + .05} )
	else
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	end
	caster:SetModifierStackCount( modifierName, caster, caster.spoils_of_war_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			if spoils_of_warTimerNumber ~= caster.spoils_of_war_buff_timer_number and not keys.caseter:HasItemInInventory(itemName) then 
				return nil 
			end

			if caster.start_spoils_of_war_charge and not caster.had_spoils_of_war_buff_before and caster.spoils_of_war_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.spoils_of_war_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time + .05 } )
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


function spoils_of_war_fire( keys )
	-- To do, check if target is building or champ, and if so do extra damage and give moneys
	local caster = keys.caster
	local checkForBrokenMod = caster:FindModifierByName("modifier_spoils_of_war_broken")
	if keys.caster.spoils_of_war_charges > 0 and checkForBrokenMod == nil then
		-- variables
		local ability = keys.ability
		local modifierName = "modifier_spoils_of_war_stack_counter_datadriven"
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", 0 )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", 0 ) + .05
		
		-- Deplete charge
		local next_charge = caster.spoils_of_war_charges - 1
		if caster.spoils_of_war_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			--spoils_of_war_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.spoils_of_war_charges = next_charge
	end
end