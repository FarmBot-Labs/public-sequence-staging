steps_per_mm_y = read_status("mcu_params", "movement_step_per_mm_y")
nr_steps_y = read_status("mcu_params", "movement_axis_nr_steps_y")
steps_per_mm_x = read_status("mcu_params", "movement_step_per_mm_x")
nr_steps_x = read_status("mcu_params", "movement_axis_nr_steps_x")

-- 10% margin of error: Taking too many photos is better than taking too few.
x_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_y"))
y_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_x"))
z = tonumber(env("CAMERA_CALIBRATION_camera_z"))
y_length = nr_steps_y / steps_per_mm_y
x_length = nr_steps_x / steps_per_mm_x

y_max = math.ceil(y_length / y_spacing)
x_max = math.ceil(x_length / x_spacing)

progress_key = "PHOTOGRID_PROGRESS"

function reset_progress() return env(progress_key, "0") end

function get_progress()
    last_progress = env(progress_key) or reset_progress()
    return tonumber(last_progress)
end

function set_progress(num) return env(progress_key, "" .. num) end

count = 1

for x = 0, x_max do
    for y = 0, y_max do
        if read_status("informational_settings", "locked") then
            return
        else
            if count >= get_progress() then
                move_absolute({y = y * y_spacing, x = x * x_spacing, z = z})
                write_pin(7, "digital", 1)
                take_photo()
                set_progress(count)
                write_pin(7, "digital", 0)
            end
            count = count + 1
        end
    end
end

reset_progress()
