steps_per_mm_y = read_status("mcu_params", "movement_step_per_mm_y")
nr_steps_y = read_status("mcu_params", "movement_axis_nr_steps_y")
steps_per_mm_x = read_status("mcu_params", "movement_step_per_mm_x")
nr_steps_x = read_status("mcu_params", "movement_axis_nr_steps_x")

function e(key) return tonumber(env(key)) end

local camera = {
    -- 50
    offset_x = e("CAMERA_CALIBRATION_camera_offset_x"),
    -- 100
    offset_y = e("CAMERA_CALIBRATION_camera_offset_y"),
    -- 320
    width = e("CAMERA_CALIBRATION_center_pixel_location_x"),
    -- 240
    height = e("CAMERA_CALIBRATION_center_pixel_location_y"),
    -- 0
    z = e("CAMERA_CALIBRATION_camera_z")
}

send_message("debug", inspect(camera), "toast")

function photograph(x, y) move_absolute(x, y, camera.z) end
