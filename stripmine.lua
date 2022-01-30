local args = {...}

-- Argument Parsing

TYPES = {
    STRING = {
        name = "string",
        parse = function(idx, argument)
            return argument;
        end,
    },
    INTEGER = {
        name = "integer",
        parse = function(idx, argument)
            return math.floor(tonumber(argument));
        end,
    },
    DECIMAL = {
        name = "decimal",
        parse = function(idx, argument)
            return tonumber(argument);
        end,
    },
    BOOLEAN = {
        name = "boolean",
        parse = function(idx, argument)
            return string.match(argument,"[tT][rR][uU][eE]") ~= nil
        end
    }
}

local function get_arg(index, arg_type)
    if(#args < index) then
        print("Expected argument of type '" .. arg_type.name .. "' at index " .. index .. "!")
        return nil
    end
    return arg_type.parse(index, args[index])
end

local function get_arg_or(index, arg_type, default)
    if(#args < index) then
        return default
    end
    return arg_type.parse(index, args[index])
end

-- Argument Parsing

-- Globals

HALLS = 24
DEPTH = 4
HALL_UNTIL_SWITCH = 8

FUEL_ACTION = 4

AUTO_REFUEL = false
AUTO_REFUEL_THRESHHOLD = WIDTH * HEIGHT * FUEL_ACTION

AUTO_TORCH = false
TORCH_SLOT = 16
TORCH_THRESHHOLD = 6

MORE_INV_AMOUNT = 0
MORE_INV_START_SLOT = 1 -- Has to be lower than the index

SEARCH_STORAGE = false
SEARCH_CHEST_SLOT = 15

-- Globals

-- Functions

function move_to_floor()
    while not turtle.detectDown() do
        turtle.down();
    end
end

function break_to(slot)
    local free_slot = get_free_slot()
    if (free_slot == nil) then
        return false
    end
    turtle.select(free_slot)
    turtle.dig()
    if (free_slot == slot) then
        return true
    end
    turtle.transferTo(slot)
    return true
end

function get_free_slot()
    local free_slot = 1
    while not (turtle.getItemCount(free_slot) == 0) do
        free_slot = free_slot + 1
        if free_slot == 17 then
            return nil
        end
    end
    return free_slot
end

function store_inventory()
    if not (MORE_INV_AMOUNT > 0) then
        local free = false
        for i=1,16 do
            if (i == TORCH_SLOT and AUTO_TORCH) or (i == SEARCH_CHEST_SLOT and SEARCH_STORAGE) then
                -- Do nothing because its a torch
            else
                if turtle.getItemCount(i) == 0 then
                    free = true
                    break
                end
            end
        end
        return free -- Inventory is still free
    end
    local free = false
    for i=MORE_INV_START_SLOT + 2,16 do
        if (i == TORCH_SLOT and AUTO_TORCH) or (i == SEARCH_CHEST_SLOT and SEARCH_STORAGE) then
            -- Do nothing because its a torch
        else
            if turtle.getItemCount(i) == 0 then
                free = true
                break
            end
        end
    end
    if free then
        return true
    end
    turtle.turnLeft()
    turtle.turnLeft()
    break_front()
    break_up()
    local continue = false
    for n=1,MORE_INV_AMOUNT do
         turtle.select(MORE_INV_START_SLOT + n)
         turtle.place()
         continue = false
         for i=MORE_INV_START_SLOT + 2,16 do
             if (i == TORCH_SLOT and AUTO_TORCH) or (i == SEARCH_CHEST_SLOT and SEARCH_STORAGE) then
                 -- Do nothing because its a torch
             else
                turtle.select(i);
                if turtle.placeUp() then
                    local _, block = turtle.inspectUp()
                    turtle.digUp()
                    if not is_ore(block) then
                        turtle.dropDown()
                    else
                        if not turtle.drop() then
                            continue = true;
                        end
                    end
                else
                    if not turtle.drop() then
                        continue = true;
                    end
                end
             end
         end
         break_to(MORE_INV_START_SLOT + n) -- No check because we know we are free
         if not continue then
            break
         end
    end
    turtle.turnLeft()
    turtle.turnLeft()
    return (not continue)
end

function place_torch()
    if not AUTO_TORCH then
        return true
    end
    if not has_torch() then
        return false
    end
    turtle.select(TORCH_SLOT)
    turtle.turnLeft()
    turtle.turnLeft()
    break_front()
    turtle.place()
    turtle.turnLeft()
    turtle.turnLeft()
    return true
end

function has_torch()
    if (turtle.getItemCount(TORCH_SLOT) > 0) then
        return true
    end
    if search_inventory("torch", TORCH_SLOT) then
        return true
    end
    return false
end

function refuel()
    if not AUTO_REFUEL then
        return true
    end
    if (turtle.getFuelLevel() > AUTO_REFUEL_THRESHHOLD) then
        return true
    end
    for i=MORE_INV_START_SLOT + 2,16 do
        if (i == TORCH_SLOT and AUTO_TORCH) or (i == SEARCH_CHEST_SLOT and SEARCH_STORAGE) then
            -- Do nothing because its a torch
        else
            turtle.select(i)
            turtle.refuel()
        end
    end
    if (turtle.getFuelLevel() > AUTO_REFUEL_THRESHHOLD) then
        return true
    end
    local free_slot = get_free_slot()
    if (free_slot == nil) then
        return false
    end
    while (turtle.getFuelLevel() < AUTO_REFUEL_THRESHHOLD) do
        if search_inventory("coal", free_slot) then
            turtle.select(free_slot)
            turtle.refuel()
        else
            return false
        end
    end
    return true
end


function search_inventory(id, slot)
    if not SEARCH_STORAGE then
        return false
    end
    local mcId = "minecraft:" .. id
    turtle.turnRight()
    break_front()
    turtle.select(SEARCH_CHEST_SLOT)
    turtle.place()
    turtle.turnLeft()
    turtle.turnLeft()
    break_front()
    local found = false
    for n=1,MORE_INV_AMOUNT do
         turtle.select(MORE_INV_START_SLOT + n)
         turtle.place()
         turtle.select(slot)
         turtle.suck()
         local detail;
         while not (turtle.getItemCount(slot) == 0) do
            detail = turtle.getItemDetail(slot)
            if (detail.name == mcId) then
                found = true
                break
            end
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.drop()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.suck()
         end
         local transfer = slot
         if found then
            transfer = SEARCH_CHEST_SLOT
         end
         turtle.select(transfer)
         turtle.turnLeft()
         turtle.turnLeft()
         turtle.suck()
         while not (turtle.getItemCount(transfer) == 0) do
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.drop()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.suck()
         end
         turtle.turnLeft()
         turtle.turnLeft()
         break_to(MORE_INV_START_SLOT + n) -- No check because we know we are free
         if not found then
            break
         end
    end
    turtle.turnLeft()
    turtle.turnLeft()
    break_to(SEARCH_CHEST_SLOT)
    turtle.turnLeft()
    return found
end

function break_front()
    while turtle.detect() do 
        turtle.dig()
    end
end

function go_front()
    break_front()
    if not store_inventory() then
        print("No free slots left")
        return false
    end
    turtle.forward()
    return true
end

function break_up()
    if turtle.detectUp() then
        turtle.digUp()
    end
end

function is_ore(obj)
    if not (obj) then
        return false
    end
    local tags = obj.tags
    if not (tags) then
        return false
    end
    for i=1,#tags do
        if (string.find(tags[i], "^forge:ores")) then
            return true
        end
    end
    return false
end

function mine_ore_front()
    local _, block = turtle.inspect()
    if is_ore(block) then
        turtle.dig()
    end
    if not store_inventory() then
        print("No free slots left")
        return false
    end
    return true
end

function mine_ore_down()
    local _, block = turtle.inspectDown()
    if is_ore(block) then
        turtle.dig()
    end
    if not store_inventory() then
        print("No free slots left")
        return false
    end
    return true
end

function mine_ore_up()
    local _, block = turtle.inspectUp()
    if is_ore(block) then
        turtle.digUp()
    end
    if not store_inventory() then
        print("No free slots left")
        return false
    end
    return true
end

function mine_forward()
    for i = 1,DEPTH do
        if not go_front() then
            return false
        end
        turtle.turnLeft()
        if not mine_ore_front() then
            return false
        end
        turtle.turnLeft()
        turtle.turnLeft()
        if not mine_ore_front() then
            return false
        end
        turtle.turnRight()
        if not mine_ore_up() then
            return false
        end
        if not mine_ore_down() then
            return false
        end
    end
    return true
end

function go_back()
    for i = 1,DEPTH do
        turtle.forward()
    end
end

function turnSide(right)
    if right then
        turtle.turnLeft()
        return
    end
    turtle.turnRight()
end

function mine(side, current, current_hall)
    if not go_front() then
        return -1
    end
    break_up()
    if current_hall == 0 then
        turnSide(side)
        for i=1,(DEPTH * 2 + 2) do
            if not go_front() then
                return -1
            end
            break_up()
        end
        turnSide(side)
        return 1
    end
    if current == 0 then
        turtle.up()
        turtle.turnLeft()
        if not mine_forward() then
            return -1
        end
        turtle.turnLeft()
        turtle.turnLeft()
        go_back()
        if not mine_forward() then
            return -1
        end
        turtle.turnLeft()
        turtle.turnLeft()
        go_back()
        turtle.turnRight()
        return 1
    end
    return 0
end

function main_loop()
    move_to_floor() -- Go down to floor

    local blocks = 0
    local torch = 0

    local current = 0
    local current_hall = 1

    local side = false

    local tmp = 0
    while (blocks < LENGTH) do
        torch = torch + 1
        blocks = blocks + 1
        if not refuel() then
            print("No fuel left")
            return
        end
        tmp = mine(side, current, current_hall)
        if tmp == -1 then
            return
        end
        if not (torch < TORCH_THRESHHOLD) then
            torch = 0
            if not place_torch() then
                print("No torches left")
                return
            end
        end
        current_hall = current_hall + tmp
        if (current_hall == HALL_UNTIL_SWITCH) then
            current_hall = 0
            side = not side
            torch = TORCH_THRESHHOLD
        end
        current = current + 1
        if (current == 3) then -- To prevent overflow
            current = 0
        end
    end
end

function print_config()
    term.clear()
    local color = term.getTextColor()
    term.setTextColor(colors.purple)
    print("=======================================")
    print("Stripmine (Depth " .. DEPTH .. ") - " .. HALLS .. " Halls and switch every " .. HALL_UNTIL_SWITCH .. " Halls")
    print("")
    print("Refuel: " .. name(AUTO_REFUEL))
    print("Torches (Slot " .. TORCH_SLOT .. "): " .. name(AUTO_TORCH))
    print("Search Storage (Slot " .. SEARCH_CHEST_SLOT .. "): " .. name(SEARCH_STORAGE))
    print("")
    print("Extra Inventories (Start Slot " .. (MORE_INV_START_SLOT + 1) .. "): " .. MORE_INV_AMOUNT)
    print("")
    print("Calculated Fuel per Hall (x" .. FUEL_ACTION .. "): " .. AUTO_REFUEL_THRESHHOLD)
    print("=======================================")
    print("Press enter to start...")
    term.setTextColor(color)
    read()
end

function name(state)
    -- Normally I wouldn't do it like this
    -- However "state" can be nil therefore I have to check
    if (state == true) then 
        return "yes"
    end
    return "no"
end

-- Functions

-- Start

HALLS = get_arg_or(1, TYPES.INTEGER, HALLS)
DEPTH = get_arg_or(2, TYPES.INTEGER, DEPTH)
HALL_UNTIL_SWITCH = get_arg_or(3, TYPES.INTEGER, HALL_UNTIL_SWITCH)

AUTO_REFUEL = get_arg_or(4, TYPES.BOOLEAN, AUTO_REFUEL)
AUTO_TORCH = get_arg_or(5, TYPES.BOOLEAN, AUTO_TORCH)
SEARCH_STORAGE = get_arg_or(6, TYPES.BOOLEAN, SEARCH_STORAGE)

MORE_INV_AMOUNT = get_arg_or(7, TYPES.INTEGER, MORE_INV_AMOUNT)

MORE_INV_START_SLOT = get_arg_or(8, TYPES.INTEGER, MORE_INV_START_SLOT) - 1 -- Remove one because it has to be lower than the actual index
SEARCH_CHEST_SLOT = get_arg_or(9, TYPES.INTEGER, SEARCH_CHEST_SLOT)
TORCH_SLOT = get_arg_or(10, TYPES.INTEGER, TORCH_SLOT)

FUEL_ACTION = get_arg_or(11, TYPES.INTEGER, FUEL_ACTION)

AUTO_REFUEL_THRESHHOLD = FUEL_ACTION * (DEPTH + 1) * 2

print_config()

main_loop()

-- Start