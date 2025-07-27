function canAccessNaribwe()
    if Tracker:ProviderCountForCode("lemurian_ship") > 0 then
        return 1
    end

    if Tracker:ProviderCountForCode("briggs_defeated") > 0 then
        return Tracker:ProviderCountForCode("frost") + Tracker:ProviderCountForCode("scoop")
    end

    return 0
end

function canAccessKibombo()
    if canAccessNaribwe() == 0 then
        return 0
    else
        if Tracker:ProviderCountForCode("lemurian_ship") > 0 then
            return 1
        end

        return Tracker:ProviderCountForCode("frost") + Tracker:ProviderCountForCode("whirlwind")
    end
end

function canSailShip()
    return Tracker:ProviderCountForCode("lemurian_ship")
end

function canAccessLemuria()
    return canSailShip() * (Tracker:ProviderCountForCode("grind") + (Tracker:ProviderCountForCode("trident") * hasDjinnCountLogic("24")))
end

function canFlyShip()
    return canSailShip() * Tracker:ProviderCountForCode("hover") * (Tracker:ProviderCountForCode("wings_of_anemos") + Tracker:ProviderCountForCode("reunion"))
end

function canAccessWesternSeas()
    return canSailShip() * (Tracker:ProviderCountForCode("grind") + canFlyShip())
end

function canAccessShip()
    return (canSailShip() * (canAccessLemuria() + canAccessWesternSeas())) + (Tracker:ProviderCountForCode("gabomba_statue_cleared") * Tracker:ProviderCountForCode("black_crystal") * Tracker:ProviderCountForCode("piers_character"))
end

function canAccessUpperMars()
    if Tracker:ProviderCountForCode("burst") > 0 and Tracker:ProviderCountForCode("blaze") > 0 and Tracker:ProviderCountForCode("reveal") > 0 and Tracker:ProviderCountForCode("teleport") > 0 and Tracker:ProviderCountForCode("pound") > 0 then
        return Tracker:ProviderCountForCode("mars_star")
    end
	return 0
end

function canAccessYampiBackside()
    return Tracker:ProviderCountForCode("scoop") + Tracker:ProviderCountForCode("sand") + canSailShip()
end

function neg(code)
    if Tracker:ProviderCountForCode(code) > 0 then
        return 0
    end
    return 1
end

function hasDjinn(num)
    if Tracker:ProviderCountForCode("sett_boss_logic") == 0 then
        return 1
    end

    local djinn = Tracker:ProviderCountForCode("venus") + Tracker:ProviderCountForCode("mars") + Tracker:ProviderCountForCode("jupiter") + Tracker:ProviderCountForCode("mercury")
    if djinn >= tonumber(num) then
        return 1
    end
    return 0
end

function hasDjinnCountLogic(num)
    local logicPercent = Tracker:ProviderCountForCode("djinn_logic_count")
    local djinnCount = Tracker:ProviderCountForCode("venus") + Tracker:ProviderCountForCode("mars") + Tracker:ProviderCountForCode("jupiter") + Tracker:ProviderCountForCode("mercury")

    if djinnCount >= math.ceil(tonumber(num) * logicPercent / 100) then
        return 1
    end
    return 0
end

function canAccessInnerAnemos()
    if Tracker:FindObjectForCode("anemos_door_setting").CurrentStage == 2 then
        return Tracker:ProviderCountForCode("teleport")
    end

    local djinn = Tracker:ProviderCountForCode("venus") + Tracker:ProviderCountForCode("mars") + Tracker:ProviderCountForCode("jupiter") + Tracker:ProviderCountForCode("mercury")
    if Tracker:FindObjectForCode("anemos_door_setting").CurrentStage == 1 then
        return Tracker:ProviderCountForCode("teleport") and djinn >= 28
    end

    return Tracker:ProviderCountForCode("teleport") and djinn == 72
end