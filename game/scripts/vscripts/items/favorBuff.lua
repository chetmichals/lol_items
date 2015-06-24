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

function GrantFavor(keys)
	if keys.caster ~= keys.attacker then
		keys.caster:GetPlayerOwner():GetAssignedHero():Heal(keys.healAmount, nil)
		keys.caster:ModifyGold(keys.goldAmount, false, 0)
	end
end