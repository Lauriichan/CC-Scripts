local turbine = peripheral.find("BiggerReactors_Turbine");
local monitor = peripheral.wrap("left");

local battery = turbine.battery();

monitor.setCursorBlink(false);
monitor.clear();

local capacity = battery.capacity();

local size = monitor.getSize();

local width = size[0];
local height = size[1];

local centerY = (height / 2) - 3;

local ticks = 0;
local stored = 0;
while true do
    sleep(0.5)
    stored = battery.stored();

    monitor.setCursor(0, centerY);
    monitor.clearLine();
    monitor.write("Capacity: " + capacity + " FE");

    monitor.setCursor(0, centerY + 1);
    monitor.clearLine();
    monitor.write("Stored: " + stored +  " FE");

    if (stored == capacity) then
        ticks = ticks + 1;
        if (ticks > 10) then
            redstone.setAnalogueOutput("bottom", 0);
            turbine.setActive(false);
        end
    elseif (ticks > 10) then
        ticks = 0;
        redstone.setAnalogueOutput("bottom", 15);
        turbine.setActive(true);
    end
    monitor.setCursor(0, centerY + 2);
    monitor.clearLine();
    monitor.write("Disabled: " + ticks);
end