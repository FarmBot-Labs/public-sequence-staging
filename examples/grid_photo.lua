local grid = photo_grid()
grid.each(function(data)
    if read_status("informational_settings", "locked") then
        return
    else
        collectGarbage()
        move_absolute({x = data.x, y = data.y, z = data.z})
        local msg = "Taking photo " .. data.count .. " of " .. grid.total
        send_message("info", msg)
        take_photo()
    end
end)
