local radius = variable("Radius")
local pos = get_position()

for radians = 0, math.pi * 2, 0.2 do
    x = pos.x + (radius * math.cos(radians))
    y = pos.y + (radius * math.sin(radians))
    move_absolute(x, y, pos.z, 50)
end
