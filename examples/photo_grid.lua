steps_per_mm_y = read_status("mcu_params", "movement_step_per_mm_y")
nr_steps_y = read_status("mcu_params", "movement_axis_nr_steps_y")
steps_per_mm_x = read_status("mcu_params", "movement_step_per_mm_x")
nr_steps_x = read_status("mcu_params", "movement_axis_nr_steps_x")

x_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_y"))
y_spacing = tonumber(env("CAMERA_CALIBRATION_center_pixel_location_x"))
z = tonumber(env("CAMERA_CALIBRATION_camera_z"))
y_length = nr_steps_y / steps_per_mm_y
x_length = nr_steps_x / steps_per_mm_x

send_message("info", "" .. y_length, "toast")
send_message("info", "" .. x_length, "toast")
