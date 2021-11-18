weed_x = variable("weed").x
weed_y = variable("weed").y
weed_z = variable("weed").z

staging_z_offset = 50
sweep_length = 200

rotary_tool_pin = 2
load_sense_pin = 60
stall_load = 90

-- Watch Rotary Tool's load sense pin and e-stop if load is too high
watcher = function(data)
    if data.value > stall_load then
        m = "Rotary tool stalled (load = " .. data.value .. "), e-stopping..."
        send_message("error", m, "toast")
        emergency_lock()
    else
        m = "Rotary tool nominal (load = " .. data.value .. "), continuing..."
        send_message("debug", m, "toast")
    end
end

function stop(where)
    local message = "E-Stopped at " .. where
    send_message("debug", message, "toast")
end

watch_pin(load_sense_pin, watcher)

function locked() return read_status("informational_settings", "locked") end

function move(x, y, z)
    if not locked() then
        return move_absolute(x, y, z)
    else
        return nil, "LOCKED!!!"
    end
end

function write(pin, mode, val)
    if not locked() then
        write_pin(pin, mode, val)
    else
        return nil, "LOCKED!!!"
    end
end

function go()

    -- Move to staging position
    _ok, error = move(weed_x - sweep_length, weed_y, weed_z + staging_z_offset)

    if error then return stop("line 34") end

    -- Turn Rotary Tool ON
    _ok, error = write(rotary_tool_pin, "digital", 1)

    if error then return stop("line 39") end

    -- Descend
    _ok, error = move(weed_x - sweep_length, weed_y, weed_z)

    if error then return stop("line 44") end

    -- Annihilate weed
    _ok, error = move(weed_x + sweep_length, weed_y, weed_z)

    if error then return stop("line 49") end

    -- Ascend
    _ok, error = move(weed_x + sweep_length, weed_y, weed_z + staging_z_offset)

    if error then return stop("line 54") end

    -- Turn Rotary Tool OFF
    _ok, error = write(rotary_tool_pin, "digital", 0)

    if error then return stop("line 59") end
    return "ok"
end

for i = 0, 10, 1 do
    -- Check if locked
    if locked() then
        -- unlock if locked
        emergency_unlock()
        wait(2000)
    end
    if go() == "ok" then return end
end

send_message("debug", "Unable to mow weeds after 10 attemps", "toast")
