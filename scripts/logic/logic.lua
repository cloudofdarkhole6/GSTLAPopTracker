function canAccessNaribwe()
    if Tracker:FindObjectForCode("lemurian_ship").Active then
        return true
    end

    if Tracker:FindObjectForCode("briggs_defeated").Active then
        return Tracker:FindObjectForCode("frost").Active or Tracker:FindObjectForCode("scoop").Active
    end

    return false
end

function canAccessKibombo()
    if ~canAccessNaribwe() then
        return false
    else
        if Tracker:FindObjectForCode("lemurian_ship").Active then
            return true
        end

        return Tracker:FindObjectForCode("frost").Active or Tracker:FindObjectForCode("whirlwind").Active
    end
end

function canSailShip()
    return Tracker:FindObjectForCode("lemurian_ship").Active
end

function canAccessLemuria()
    return canSailShip() and (Tracker:FindObjectForCode("grind").Active or (Tracker:FindObjectForCode("trident").Active and hasDjinnCountLogic("24")))
end

function canFlyShip()
    return canSailShip() and Tracker:FindObjectForCode("hover").Active and Tracker:FindObjectForCode("wings_of_anemos").Active
end

function canAccessWesternSeas()
    return canSailShip() and (Tracker:FindObjectForCode("grind").Active or canFlyShip())
end

function canAccessShip()
    if Tracker:FindObjectForCode("lemurian_ship_setting").CurrentStage == 0 then
        return (canSailShip() and (canAccessLemuria() or canAccessWesternSeas())) or (Tracker:FindObjectForCode("gabomba_statue_cleared") and Tracker:FindObjectForCode("black_crystal") * Tracker:FindObjectForCode("piers_character"))
    end
    return true
end

function canAccessUpperMars()
    if Tracker:FindObjectForCode("burst").Active and Tracker:FindObjectForCode("blaze").Active and Tracker:FindObjectForCode("reveal").Active and Tracker:ProviderCountForCode("teleport").Active and Tracker:ProviderCountForCode("pound").Active then
        return Tracker:FindObjectForCode("mars_star").Active
    end
	return false
end

function canAccessYampiBackside()
   return Tracker:FindObjectForCode("scoop").Active or Tracker:FindObjectForCode("sand").Active or canSailShip()
end

function neg(code)
    if Tracker:FindObjectForCode(code).Active then
        return false
    end
    return true
end

function hasDjinnCountLogic(num)
    local logicPercent = Tracker:ProviderCountForCode("djinn_logic_count")
    local djinnCount = Tracker:ProviderCountForCode("venus") + Tracker:ProviderCountForCode("mars") + Tracker:ProviderCountForCode("jupiter") + Tracker:ProviderCountForCode("mercury") -4

    if djinnCount >= math.ceil(tonumber(num) * logicPercent / 100) then
        return true
    end
    return false
end

function canAccessInnerAnemos()
    if Tracker:FindObjectForCode("anemos_door_setting").CurrentStage == 2 then
        return Tracker:FindObjectForCode("teleport")
    end

    local djinn = Tracker:ProviderCountForCode("venus") + Tracker:ProviderCountForCode("mars") + Tracker:ProviderCountForCode("jupiter") + Tracker:ProviderCountForCode("mercury") - 4
    if Tracker:FindObjectForCode("anemos_door_setting").CurrentStage == 1 then
        return Tracker:FindObjectForCode("teleport") and djinn >= 28
    end

    return Tracker:FindObjectForCode("teleport") and djinn == 72
end