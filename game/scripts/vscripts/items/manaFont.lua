function ManaFont(keys)
	caster = keys.caster
	maxMana = caster:GetMaxMana()
	currentMana = caster:GetMana()
	missingMana = maxMana - currentMana
	manaToRestore = missingMana * .02
	caster:GiveMana(manaToRestore)
end