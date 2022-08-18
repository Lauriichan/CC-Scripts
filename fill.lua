
function selectNonEmpty()
    if (turtle.getItemCount(turtle.getSelectedSlot()) ~= 0 and turtle.getSelectedSlot() < 16) then
        return true
    end
    for i=1,16 do
        if (turtle.getItemCount(i) > 0) then
            turtle.select(i)
            return true
        end
    end
    return false
end

function turnSide(side)
    if side then
        turtle.turnRight()
        return
    end
    turtle.turnLeft()
end

function tryNextColumn(side)
    turtle.back()
    turnSide(side)
    if turtle.detect() then
        return false
    end
    turtle.forward()
    turnSide(side)
    if turtle.detect() then
        return false
    end
    turtle.forward()
    return turtle.detectDown()
end

function main() 
    local side = false
    local placed = 0
    local reason = ""
    while true do
        if turtle.getFuelLevel() < 50 then
            reason = "Fuel level too low"
            break
        end
        turtle.forward()
        if turtle.detectDown() then
            if not tryNextColumn(side) then
                reason = "Space completely filled"
                break
            end
            side = not side
        end
        if not selectNonEmpty() then
            reason = "No blocks to place"
            break
        end
        turtle.placeDown()
        placed = placed + 1
    end
    print("=======================================")
    print("")
    print("Stopped working!")
    print("Reason: " + reason)
    print("")
    print("Fuel remaining: " + turtle.getFuelLevel())
    print("Total blocks placed: " + placed)
    print("")
    print("=======================================")
end

main()