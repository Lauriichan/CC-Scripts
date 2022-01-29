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

LENGTH = 12

WIDTH = 3
HEIGHT = 3
FUEL_ACTION = 4

AUTO_REFUEL = false
AUTO_REFUEL_THRESHHOLD = WIDTH * HEIGHT * FUEL_ACTION

AUTO_TORCH = false
TORCH_SLOT = 16
TORCH_THRESHHOLD = 6

MORE_INV_AMOUNT = 0
MORE_INV_START_SLOT = 0 -- Has to be lower than the index

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
                 if not turtle.drop() then
                    continue = true;
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

function mine_forward()
    if not go_front() then
        return false
    end
    mine_up()
    if not store_inventory() then
        print("No free slots left")
        return false
    end
    return true
end

function mine_up()
    for i=2,HEIGHT do
        while turtle.detectUp() do
            turtle.digUp()
        end
        turtle.up()
    end
    for i=2,HEIGHT do
        turtle.down()
    end
end

function main_loop()
    move_to_floor() -- Go down to floor
    
    go_front() -- Mine first block

    local blocks = 0
    local torch = 0

    local left = math.floor(WIDTH / 2)
    local right = WIDTH - left
    while (blocks < LENGTH) do
        torch = torch + 1
        blocks = blocks + 1
        if not (torch < TORCH_THRESHHOLD) then
            torch = 0
            if not place_torch() then
                print("No torches left")
                return
            end
        end
        if not refuel() then
            print("No fuel left")
            return
        end
        turtle.turnLeft()
        for i=1,left do
            mine_forward()
        end
        turtle.turnLeft()
        turtle.turnLeft()
        for i=2,left do
            if not go_front() then
                return
            end
        end
        for i=1,right do
            mine_forward()
        end
        turtle.turnLeft()
        turtle.turnLeft()
        for i=2,right do
            if not go_front() then
                return
            end
        end
        turtle.turnRight()
        if not go_front() then
            return
        end
    end
end

function print_config()
    term.clear()
    local color = term.getTextColor()
    term.setTextColor(colors.purple)
    print("==========================================")
    print("Tunnel " .. WIDTH .. "x" .. HEIGHT .. " - " .. LENGTH .. " Blöcke lang")
    print("")
    print("Refuel: " .. name(AUTO_REFUEL))
    print("Torches (Slot " .. TORCH_SLOT .. "): " .. name(AUTO_TORCH))
    print("Search Storage (Slot " .. SEARCH_CHEST_SLOT .. "): " .. name(SEARCH_STORAGE))
    print("")
    print("Extra Inventories (Start Slot " .. MORE_INV_START_SLOT .. "): " .. MORE_INV_AMOUNT)
    print("")
    print("Calculated Fuel per Layer (x" .. FUEL_ACTION .. "): " .. AUTO_REFUEL_THRESHHOLD)
    print("==========================================")
    term.setTextColor(color)
    print("Press enter to continue...")
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

LENGTH = get_arg_or(1, TYPES.INTEGER, LENGTH)
WIDTH = get_arg_or(2, TYPES.INTEGER, WIDTH)
HEIGHT = get_arg_or(3, TYPES.INTEGER, HEIGHT)

AUTO_REFUEL = get_arg_or(4, TYPES.BOOLEAN, AUTO_REFUEL)
AUTO_TORCH = get_arg_or(5, TYPES.BOOLEAN, AUTO_TORCH)
SEARCH_STORAGE = get_arg_or(6, TYPES.BOOLEAN, SEARCH_STORAGE)

MORE_INV_AMOUNT = get_arg_or(7, TYPES.INTEGER, MORE_INV_AMOUNT)

TORCH_SLOT = get_arg_or(9, TYPES.INTEGER, TORCH_SLOT)
MORE_INV_START_SLOT = get_arg_or(10, TYPES.INTEGER, MORE_INV_START_SLOT)
SEARCH_CHEST_SLOT = get_arg_or(11, TYPES.INTEGER, SEARCH_CHEST_SLOT)

FUEL_ACTION = get_arg_or(12, TYPES.INTEGER, FUEL_ACTION)

AUTO_REFUEL_THRESHHOLD = WIDTH * HEIGHT * FUEL_ACTION

print_config()

main_loop()

-- Start