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

function RestoreMana(keys)
	keys.caster:GetPlayerOwner():GetAssignedHero():GiveMana(keys.manaAmount)
end




function AddCrit(keys)
	playerHero = keys.caster:GetPlayerOwner():GetAssignedHero()
	criticleHit = playerHero:FindModifierByName("modifier_basic_crtitical_strike_stack")
	if criticleHit == nil then
		crit_Buff = CreateItem("item_modifier_crit", nil, nil)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_basic_crtitical_strike_stack",nil)
		criticleHit = playerHero:FindModifierByName("modifier_basic_crtitical_strike_stack")
		UTIL_RemoveImmediate(crit_Buff)
		crit_Buff = nil
	end
	critCount = criticleHit:GetStackCount()
	critCount = keys.critAmount + critCount
	criticleHit:SetStackCount(critCount)

	playerHero:RemoveModifierByName("modifier_lol_crit_chance_one")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_two")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_three")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_four")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_five")

	crit_Buff = CreateItem("item_modifier_crit", nil, nil)


	if (critCount > 80) then
		abilityLevel = critCount - 80
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_five",nil)
	elseif (critCount > 60) then
		abilityLevel = critCount - 60
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_four",nil)
	elseif (critCount > 40) then
		abilityLevel = critCount - 40
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_three",nil)
	elseif (critCount > 20) then
		abilityLevel = critCount - 20
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_two",nil)
	elseif (critCount > 0) then	
		abilityLevel = critCount
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_one",nil)
	end
	UTIL_RemoveImmediate(crit_Buff)
	crit_Buff = nil
end


function RemoveCrit(keys)
	playerHero = keys.caster:GetPlayerOwner():GetAssignedHero()
	criticleHit = playerHero:FindModifierByName("modifier_basic_crtitical_strike_stack")
	if criticleHit == nil then
		crit_Buff = CreateItem("item_modifier_crit", nil, nil)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_basic_crtitical_strike_stack",nil)
		criticleHit = playerHero:FindModifierByName("modifier_basic_crtitical_strike_stack")
		UTIL_RemoveImmediate(crit_Buff)
		crit_Buff = nil
	end
	critCount = criticleHit:GetStackCount()
	critCount = critCount - keys.critAmount
	if critCount < 0 then critCount = 0 end
	criticleHit:SetStackCount(critCount)

	playerHero:RemoveModifierByName("modifier_lol_crit_chance_one")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_two")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_three")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_four")
	playerHero:RemoveModifierByName("modifier_lol_crit_chance_five")

	crit_Buff = CreateItem("item_modifier_crit", nil, nil)

	if (critCount > 80) then
		abilityLevel = critCount - 80
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_five",nil)
	elseif (critCount > 60) then
		abilityLevel = critCount - 60
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_four",nil)
	elseif (critCount > 40) then
		abilityLevel = critCount - 40
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_three",nil)
	elseif (critCount > 20) then
		abilityLevel = critCount - 20
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_two",nil)
	elseif (critCount > 0) then	
		abilityLevel = critCount
		crit_Buff:SetLevel(abilityLevel)
		crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_crit_chance_one",nil)
	end
	UTIL_RemoveImmediate(crit_Buff)
	crit_Buff = nil
end

function ApplyCrit(keys)
	playerHero = keys.caster:GetPlayerOwner():GetAssignedHero()
	crit_Buff = CreateItem("item_modifier_crit", nil, nil)
	crit_Buff:ApplyDataDrivenModifier(playerHero,playerHero,"modifier_lol_basic_crit",nil)
	UTIL_RemoveImmediate(crit_Buff)
	crit_Buff = nil
end

function AddMagicResistItem(keys)
	hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if hero.magicResistance == nil then
		hero.magicResistance = 0
	end
	hero.magicResistance = hero.magicResistance + keys.magicResist
	SetMagicResistance(hero)
end

function RemoveMagicResistItem(keys)
	hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	if hero.magicResistance == nil then
		hero.magicResistance = 100
	end
	hero.magicResistance = hero.magicResistance - keys.magicResist
	SetMagicResistance(hero)
end

function SetMagicResistance(hero)
	newMagicResistance = hero.magicResistance
	print (newMagicResistance)
	if newMagicResistance >= 0 then
		newMagicResistance = 100 / (hero.magicResistance + 100)
		newMagicResistance = (1 - newMagicResistance) * 100
		hero:SetBaseMagicalResistanceValue(newMagicResistance)
	elseif newMagicResistance >= -100 then
		newMagicResistance = 100 / (100 - hero.magicResistance)
		newMagicResistance = 2 - newMagicResistance
		newMagicResistance = (1 - newMagicResistance) * 100
		hero:SetBaseMagicalResistanceValue(newMagicResistance)
	else
		hero:SetBaseMagicalResistanceValue(-100)
	end
end

function AddADItem(keys)
	hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	damage = hero:GetBaseDamageMax()
	damage = damage + keys.ad
	hero:SetBaseDamageMin(damage)
	hero:SetBaseDamageMax(damage)
end

function RemoveADItem(keys)
	hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	damage = hero:GetBaseDamageMax()
	damage = damage - keys.ad
	hero:SetBaseDamageMin(damage)
	hero:SetBaseDamageMax(damage)
end

function HP5Heal(keys)
	hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	baseHeal = hero:GetBaseHealthRegen()
	baseHeal = baseHeal * (1 + keys.healPercent)
	baseHeal = baseHeal / 10
	hero:Heal(baseHeal, nil)
end