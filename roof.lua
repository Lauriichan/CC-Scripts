SAMPLE_SLOT = 1

function isItem(slot, id)
    local data = turtle.getItemDetail(slot)
    if not data then
        return false
    end
    if not (data.name == id) then
        return false
    end
    return true
end

function selectNext(id)
    if isItem(turtle.getSelectedSlot(), id) then
        return true
    end
    for i=1,16 do
        if isItem(i, id) then
            turtle.select(i)
            return true
        end
    end
    return false
end

function place(id)
    if turtle.detect() then
        local _, block = turtle.inspectUp()
        if (block.name == id) then
            return true
        end
        turtle.digUp()
    end
    if not selectNext(id) then
        return false
    end
    turtle.placeUp()
    return true
end

function turnSide(right)
    if right then
        turtle.turnLeft()
        return
    end
    turtle.turnRight()
end

function main()
    local id = turtle.getItemDetail(SAMPLE_SLOT)
    if not id then
        print("No sample item")
        return
    end
    id = id.name
    local right = false
    turtle.turnRight()
    if turtle.detect() then
        right = true
    end
    turtle.turnLeft()
    local swapped = false
    while true do
        if not place(id) then
            print("No item")
            return
        end
        if turtle.detect() then
            if swapped then
                break
            end
            turnSide(right)
            swapped = true
            if turtle.detect() then
                break
            end
        else
            turtle.forward()
            swapped = false
        end
    end
end

main()