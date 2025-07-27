
require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")
require("scripts/autotracking/hints_mapping")
require("scripts/autotracking/djinn_mapping")
require("scripts/autotracking/setting_mapping")
require("scripts/autotracking/event_mapping")

CUR_INDEX = -1
--SLOT_DATA = nil


SLOT_DATA = {}

function has_value (t, val)
    for i, v in ipairs(t) do
        if v == val then return 1 end
    end
    return 0
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ','
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function forceUpdate()
    local update = Tracker:FindObjectForCode("update")
    update.Active = not update.Active
end

function onClearHandler(slot_data)
    local clear_timer = os.clock()
    
    ScriptHost:RemoveWatchForCode("StateChange")
    -- Disable tracker updates.
    Tracker.BulkUpdate = true
    -- Use a protected call so that tracker updates always get enabled again, even if an error occurred.
    local ok, err = pcall(onClear, slot_data)
    -- Enable tracker updates again.
    if ok then
        -- Defer re-enabling tracker updates until the next frame, which doesn't happen until all received items/cleared
        -- locations from AP have been processed.
        local handlerName = "AP onClearHandler"
        local function frameCallback()
            ScriptHost:AddWatchForCode("StateChange", "*", StateChange)
            ScriptHost:RemoveOnFrameHandler(handlerName)
            Tracker.BulkUpdate = false
            -- forceUpdate()
            print(string.format("Time taken total: %.2f", os.clock() - clear_timer))
        end
        ScriptHost:AddOnFrameHandler(handlerName, frameCallback)
    else
        Tracker.BulkUpdate = false
        print("Error: onClear failed:")
        print(err)
    end
end

function onClear(slot_data)
    --SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local location_obj = Tracker:FindObjectForCode(location)
                if location_obj then
                    if location:sub(1, 1) == "@" then
                        location_obj.AvailableChestCount = location_obj.ChestCount
                    else
                        location_obj.Active = false
                    end
                end
            end
        end
    end
    -- reset items
    for _, item_pair in pairs(ITEM_MAPPING) do
        for item_type, item_code in pairs(item_pair) do
            local item_obj = Tracker:FindObjectForCode(item_code)
            if item_obj then
                if item_obj.Type == "toggle" then
                    item_obj.Active = false
                elseif item_obj.Type == "progressive" then
                    item_obj.CurrentStage = 0
                    item_obj.Active = false
                elseif item_obj.Type == "consumable" then
                    if item_obj.MinCount then
                        item_obj.AcquiredCount = item_obj.MinCount
                    else
                        item_obj.AcquiredCount = 0
                    end
                elseif item_obj.Type == "progressive_toggle" then
                    item_obj.CurrentStage = 0
                    item_obj.Active = false
                end
            end
        end
    end
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    -- reset settings
    print("Fill settings from slot_data")
    for _, table in pairs(slot_data) do
        print(dump_table(value))
        for key, value in pairs(table) do
            print(key)
            print(value)
            if SLOT_CODES[key] then
                local object = Tracker:FindObjectForCode(SLOT_CODES[key].code)
                    if object then
                        print(object)
                        if SLOT_CODES[key].type == "toggle" then
                            object.Active = value
                        elseif SLOT_CODES[key].type == "progressive" then
                            if key == "lemurian_ship" then
                                if value == 2 then
                                    object.Active = true
                                end
                                if value ~= 0 then
                                    local crystal = Tracker:FindObjectForCode("black_crystal")
                                    crystal.Active = true
                                end
                            else
                                object.CurrentStage = SLOT_CODES[key].mapping[value]
                            end
                        elseif SLOT_CODES[key].type == "consumable" then
                            object.AcquiredCount = value
                        end
                    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print(string.format("No setting could be found for key: %s", key))
                    end
            end
        end
    end
    -- if Tracker:FindObjectForCode("autofill_settings").Active == true then
    --     autoFill(slot_data)
    -- end
    -- print(PLAYER_ID, TEAM_NUMBER)
    if Archipelago.PlayerNumber > -1 then

        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})

        DJINN_ID = "gstla_goal_djinn_status_"..PLAYER_ID.."_"..TEAM_NUMBER
        Archipelago:SetNotify({DJINN_ID})
        Archipelago:Get({DJINN_ID})

        OWNED_DJINN_ID = "gstla_djinn_held_"..PLAYER_ID.."_"..TEAM_NUMBER
        Archipelago:SetNotify({OWNED_DJINN_ID})
        Archipelago:Get({OWNED_DJINN_ID})

        EVENT_ID = "gstla_events_status_"..PLAYER_ID.."_"..TEAM_NUMBER
        Archipelago:SetNotify({EVENT_ID})
        Archipelago:Get({EVENT_ID})
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item = ITEM_MAPPING[item_id]
    if not item or not item[1] then
        --print(string.format("onItem: could not find item mapping for id %s", item_id))
        return
    end

    local item_obj = Tracker:FindObjectForCode(item[1])
    if item_obj then
        if item_obj.Type == "toggle" then
            -- print("toggle")
            item_obj.Active = true
        elseif item_obj.Type == "progressive" then
            -- print("progressive")
            item_obj.Active = true
        elseif item_obj.Type == "consumable" then
            -- print("consumable")
            item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item_pair[3]) or 1)
        elseif item_obj.Type == "progressive_toggle" then
            -- print("progressive_toggle")
            if item_obj.Active then
                item_obj.CurrentStage = item_obj.CurrentStage + 1
            else
                item_obj.Active = true
            end
        end
    else
        print(string.format("onItem: could not find object for code %s", item_code[1]))
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_array) do
        local location_obj = Tracker:FindObjectForCode(location)
        -- print(location, location_obj)
        if location_obj then
            if location:sub(1, 1) == "@" then
                location_obj.AvailableChestCount = location_obj.AvailableChestCount - 1
            else
                location_obj.Active = true
            end
        else
            print(string.format("onLocation: could not find location_object for code %s", location))
        end
    end
end

function onEvent(key, value, old_value)
    updateEvents(value)
end

function onEventsLaunch(key, value)
    updateEvents(value)
end

-- this Autofill function is meant as an example on how to do the reading from slotdata and mapping the values to
-- your own settings
-- function autoFill()
--     if SLOT_DATA == nil  then
--         print("its fucked")
--         return
--     end
--     -- print(dump_table(SLOT_DATA))

--     mapToggle={[0]=0,[1]=1,[2]=1,[3]=1,[4]=1}
--     mapToggleReverse={[0]=1,[1]=0,[2]=0,[3]=0,[4]=0}
--     mapTripleReverse={[0]=2,[1]=1,[2]=0}

--     slotCodes = {
--         map_name = {code="", mapping=mapToggle...}
--     }
--     -- print(dump_table(SLOT_DATA))
--     -- print(Tracker:FindObjectForCode("autofill_settings").Active)
--     if Tracker:FindObjectForCode("autofill_settings").Active == true then
--         for settings_name , settings_value in pairs(SLOT_DATA) do
--             -- print(k, v)
--             if slotCodes[settings_name] then
--                 item = Tracker:FindObjectForCode(slotCodes[settings_name].code)
--                 if item.Type == "toggle" then
--                     item.Active = slotCodes[settings_name].mapping[settings_value]
--                 else
--                     -- print(k,v,Tracker:FindObjectForCode(slotCodes[k].code).CurrentStage, slotCodes[k].mapping[v])
--                     item.CurrentStage = slotCodes[settings_name].mapping[settings_value]
--                 end
--             end
--         end
--     end
-- end

function onNotify(key, value, old_value)
    print("onNotify", key, value, old_value)
    if value ~= nil and value ~= 0 then
        if key == DJINN_ID then
			updateDjinnLocations(value)
        end
        if key == OWNED_DJINN_ID then
            updateSingleDjinnCount(value[#value])
        end
        if key == EVENT_ID then
            updateProgression(value)
        end
    end
end

function onNotifyLaunch(key, value)
    print("onNotifyLaunch", key, value)
    if value ~= nil and value ~= 0 then
        if key == DJINN_ID then
            updateDjinnLocations(value)
        end
        if key == OWNED_DJINN_ID then
            updateDjinnCount(value)
        end
        if key == EVENT_ID then
            updateProgression(value)
        end
    end
end

function updateDjinnLocations(value)
    print("Update Djinn Locations")
	for _, id in pairs(value) do
		local obj = Tracker:FindObjectForCode(DJINN_MAPPING[id])
		print(obj)
		obj.Active = true
	end
end

function updateSingleDjinnCount(value)
    local djinn = DJINN_MAPPING[value]
	print(djinn)
	local splitIndex = string.find(djinn, "_")
	local code = string.sub(djinn, 1, splitIndex-1)
	local obj = Tracker:FindObjectForCode(code)
	print(obj)
    obj.AcquiredCount = obj.AcquiredCount + 1
end

function updateDjinnCount(value)
    print("Update Djinn Counts")
	for _, id in pairs(value) do
	    local djinn = DJINN_MAPPING[id]
	    print(djinn)
	    local splitIndex = string.find(djinn, "_")
	    local code = string.sub(djinn, 1, splitIndex-1)
		local obj = Tracker:FindObjectForCode(code)
		print(obj)
        obj.AcquiredCount = obj.AcquiredCount + 1
	end
end

function updateProgression(value)
    print("Update progression events")
    print(dump_table(value))
    for _, id in pairs(value) do
        local obj = Tracker:FindObjectForCode(EVENT_MAPPING[id])
        print(obj)
        obj.Active = true
    end
end

function updateHints(locationID, clear)
    local item_codes = HINTS_MAPPING[locationID]

    for _, item_table in ipairs(item_codes, clear) do
        for _, item_code in ipairs(item_table) do
            local obj = Tracker:FindObjectForCode(item_code)
            if obj then
                if not clear then
                    obj.Active = true
                else
                    obj.Active = false
                end
            else
                print(string.format("No object found for code: %s", item_code))
            end
        end
    end
end


-- ScriptHost:AddWatchForCode("settings autofill handler", "autofill_settings", autoFill)
Archipelago:AddClearHandler("clear handler", onClearHandler)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)

Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)



--doc
--hint layout
-- {
--     ["receiving_player"] = 1,
--     ["class"] = Hint,
--     ["finding_player"] = 1,
--     ["location"] = 67361,
--     ["found"] = false,
--     ["item_flags"] = 2,
--     ["entrance"] = ,
--     ["item"] = 66062,
-- } 
