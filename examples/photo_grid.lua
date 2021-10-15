steps_per_mm_y = read_status("mcu_params", "movement_step_per_mm_y")
nr_steps_y = read_status("mcu_params", "movement_axis_nr_steps_y")
steps_per_mm_x = read_status("mcu_params", "movement_step_per_mm_x")
nr_steps_x = read_status("mcu_params", "movement_axis_nr_steps_x")

-- Add 10% margin of error; taking too many photos is better than not enough.
x_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_y")) * 0.90
y_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_x")) * 0.90
z = tonumber(env("CAMERA_CALIBRATION_camera_z"))
y_length = nr_steps_y / steps_per_mm_y
x_length = nr_steps_x / steps_per_mm_x

y_max = math.ceil(y_length / y_spacing)
x_max = math.ceil(x_length / x_spacing)
count = 0
write_pin(7, "digital", 1)
for x = 0, x_max do
    for y = 0, y_max do
        if read_status("informational_settings", "locked") then
            return
        else
            -- TODO: Add pause / resume ability.
            move_absolute({y = y * y_spacing, x = x * x_spacing, z = z})
            take_photo()
        end
    end
end
write_pin(7, "digital", 0)
