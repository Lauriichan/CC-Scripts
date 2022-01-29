

FLOOR_SLOT = 1
TORCH_SLOT = 13

function selectFloor()
    if (turtle.getItemCount(turtle.getSelectedSlot()) ~= 0 and turtle.getSelectedSlot() < TORCH_SLOT) then
        return true
    end
    for i=FLOOR_SLOT,(TORCH_SLOT - 1) do
        if (turtle.getItemCount(i) > 0) then
            turtle.select(i)
            return true
        end
    end
    return false
end

function selectTorch()
    if (turtle.getItemCount(turtle.getSelectedSlot()) ~= 0 and turtle.getSelectedSlot() >= TORCH_SLOT) then
        return true
    end
    for i=TORCH_SLOT,16 do
        if (turtle.getItemCount(i) > 0) then
            turtle.select(i)
            return true
        end
    end
    return false
end

function placeTorch(row, space, size)
    if (row % 4 ~= 0) then
        return false
    end
    if (space % 3 ~= 0) then
        return false
    end
    if not (selectTorch()) then
        return false
    end
    turtle.up()
    turtle.placeDown()
    return true
end

function turnSide(side)
    if side then
        turtle.turnLeft()
        return
    end
    turtle.turnRight()
end

function main()
    local side = false
    local tries = 0

    local size = 0
    local record = true

    local row = 0
    local space = 0

    local high = false

    while true do
        if high then
            high = false
            turtle.down()
        end
        if not turtle.detectDown() then
            if not selectFloor() then
                break
            end
            turtle.placeDown()
        end
        if record then
            size = size + 1
        else 
            if placeTorch(row, space, size) then
                high = true
            end
            space = space + 1
        end
        if turtle.detect() then
            row = row + 1
            space = 0
            if (size ~= 0 and record) then
                record = false
            end
            turnSide(side)
            if not turtle.detect() then
                turtle.forward()
                tries = 0
            else 
                tries = tries + 1
            end
            turnSide(side)
            side = not side
        else
            turtle.forward()
        end
    end
end

main()