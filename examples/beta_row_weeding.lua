local margin_of_error = 0.89
local chunk_size = 20
local weeding_pin = 10
function swipe_x(length)
    for i = 0, length / chunk_size, chunk_size do
        local position, error = get_position()
        if error then
            -- send_message("error", inspect(error), "toast")
            return
        else
            local x = position.x
            local y = position.y
            local z = soil_height(x, y) * margin_of_error
            move_absolute(x, y, z / 2)
            write_pin(weeding_pin, "analog", 250)
            move_absolute(x + i, y, z)
            write_pin(weeding_pin, "analog", 1)
        end
    end
end

local dead_center = {x = garden_size().x / 2, y = garden_size().y / 2}
dead_center.z = soil_height(dead_center.x, dead_center.y) / 2
move_absolute(dead_center)
swipe_x(60)
