local grid = photo_grid()
grid.each(function(cell)
    if read_status("informational_settings", "locked") then
        return
    else
        collectgarbage()
        move_absolute({x = cell.x, y = cell.y, z = cell.z})
        local msg = "Detecting weeds at location " .. cell.count .. " of " ..
                        grid.total
        send_message("info", msg)
        detect_weeds()
    end
end)
