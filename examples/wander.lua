-- Wander the garden randomly for demonstration purposes.
local size = garden_size()
function wander()
    x = math.random() * size.x
    y = math.random() * size.y
    move_absolute(x, y, 0, 50)
end

for i = 0, 10, 1 do
    send_message("debug", "wandering...", "toast")
    wander()
end
