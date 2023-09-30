local turbine = peripheral.find("BiggerReactors_Turbine");
local montior = peripheral.wrap("left");

local battery = turbine.battery();

monitor.setCursorBlink(false);

local capacity = battery.capacity();

local size = monitor.getSize();

local width = size[0];
local height = size[1];

local centerY = (height / 2) - 1;

local ticks = 0;
local stored = 0;
while true do
    stored = battery.stored();
    monitor.clear();
    monitor.setCursor(0, centerY);
    
    monitor.write("Capacity: " + capacity + " FE");
    monitor.setCursor(0, centerY - 1);
    monitor.write("Stored: " + stored +  " FE");

    if (stored == capacity) then
        ticks = ticks + 1;
        if (ticks > 50) then
            monitor.setCursor(0, centerY - 2);
            monitor.write("Disabled: " + ticks);
            redstone.setAnalogueOutput("bottom", 15);
        end
    elseif (ticks > 50) then
        ticks = 0;
        redstone.setAnalogueOutput("bottom", 0);
    end
end