function prinspect(msg) print(msg) end

function round(n) return math.floor(n + 0.5) end

function angleRound(angle)
    local remainder = math.abs(angle % 90)
    if remainder > 45 then
        return 90 - remainder
    else
        return remainder
    end
end

-- Returns an integer that we need to subtract from width/height
-- due to camera rotation issues.
function cropAmount(width, height, angle)
    local absAngle = angleRound(angle or 0)
    if (absAngle > 0) then
        local x = (5.61 - 0.095 * math.pow(absAngle, 2) + 9.06 * absAngle)
        local factor = x / 640
        local longEdge = math.max(width, height)
        local result = round(longEdge * factor)
        return result
    end
    return 0
end

function fwe(key)
    local e = env("CAMERA_CALIBRATION_" .. key)
    if e then
        return tonumber(e)
    else
        send_message("error", "You must first run camera calibration", "toast")
        os.exit()
    end
end

local cam_rotation = fwe("total_rotation_angle")
local height_px = fwe("center_pixel_location_y") * 2
local scale = fwe("coord_scale")
local width_px = fwe("center_pixel_location_x") * 2
local x_length = garden_size().x
local y_length = garden_size().y
local z = fwe("camera_z")
local margin_mm = cropAmount(width_px, height_px, cam_rotation)
local sweep_x = (height_px * scale) - margin_mm
local sweep_y = (width_px * scale) - margin_mm
local x_spacing = (scale * fwe("center_pixel_location_y") * 2) - margin_mm
local y_spacing = (scale * fwe("center_pixel_location_x") * 2) - margin_mm
local x_max = math.ceil(x_length / x_spacing)
local y_max = math.ceil(y_length / y_spacing)

for y_count = 0, y_max do
    for x_count = 0, x_max do
        if read_status("informational_settings", "locked") then
            return
        else
            local x = math.floor((sweep_x * x_count) + margin_mm)
            local y = math.floor((sweep_y * y_count) + margin_mm)
            move_absolute({x = x, y = y, z = z})
            take_photo()
        end
    end
end
