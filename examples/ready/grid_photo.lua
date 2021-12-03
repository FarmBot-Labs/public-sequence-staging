local grid = photo_grid()
grid.each(function(cell)
    if read_status("informational_settings", "locked") then
        return
    else
        collectgarbage()
        move_absolute({x = cell.x, y = cell.y, z = cell.z})
        local msg = "Taking photo " .. cell.count .. " of " .. grid.total
        send_message("info", msg)
        take_photo()
    end
end)
