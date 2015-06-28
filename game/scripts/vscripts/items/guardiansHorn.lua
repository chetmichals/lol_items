function guardiansHorn(keys)
	--print ("HORN!")
	if keys.caster:GetTeam() ~= keys.unit:GetTeam() then
		 --Search for a Magic Stick in the aura creator's inventory.  If there are multiple Magic Sticks in the player's inventory,
		 --the oldest one that's not full receives a charge.
		 local cooldowntime = keys.ability:GetCooldownTimeRemaining() - 1
		 if cooldowntime < 0 then cooldowntime = 0 end
		 keys.ability:EndCooldown()
		 keys.ability:StartCooldown(cooldowntime)
	end
end