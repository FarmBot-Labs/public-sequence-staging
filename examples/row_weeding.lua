-- Adds a `swipe_x` function that shaves weeds by turning on the rotary trimmer
-- and swiping down the X axis at a specified length, following the curvature of
-- the soil as it goes.
-- TODO: Configure this with text-based variables.
local weeding_pin = 10
-- How close of a shave do we want?
-- Going too low risks a stall.
local margin_of_error = 15
local chunk_size = 10

function swipe_x(length)
    for i = 0, length / chunk_size, chunk_size do
        local position, error = get_position()
        if error then
            send_message("error", inspect(error), "toast")
            return
        else
            local x = position.x
            local y = position.y
            local z = soil_height(x, y) + margin_of_error
            write_pin(weeding_pin, "analog", 250)
            move_absolute(x + i, y, z)
            write_pin(weeding_pin, "analog", 1)
        end
    end
end

for yy = 100, 600, 10 do
    move_absolute(100, yy, -200)
    swipe_x(600)
end
