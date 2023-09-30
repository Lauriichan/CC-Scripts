turbine = peripheral.find("BiggerReactors_Turbine");
montior = peripheral.wrap("left");

battery = turbine.battery();

monitor.setCursorBlink(false);

capacity = battery.capacity();

size = monitor.getSize();

width = size[0];
height = size[1];

centerY = (height / 2) - 1;

ticks = 0;
stored = 0;
while true do
    stored = battery.stored();
    monitor.clear();
    monitor.setCursor(0, centerY);
    
    monitor.write("Capacity: " + capacity + " FE");
    monitor.setCursor(0, centerY - 1);
    monitor.write("Stored: " + stored +  " FE");

    if (stored == capacity) then
        ticks++;
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