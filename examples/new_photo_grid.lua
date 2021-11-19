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
local z = fwe("camera_z")
local margin_mm = cropAmount(width_px, height_px, cam_rotation)
if math.abs(cam_rotation) < 45 then
    x_spacing = (width_px * scale) - margin_mm
    y_spacing = (height_px * scale) - margin_mm
else
    x_spacing = (height_px * scale) - margin_mm
    y_spacing = (width_px * scale) - margin_mm
end
local x_max = math.ceil(garden_size().x / x_spacing)
local y_max = math.ceil(garden_size().y / y_spacing)

for y_count = 0, y_max do
    for x_count = 0, x_max do
        if read_status("informational_settings", "locked") then
            return
        else
            move_absolute({
                x = math.floor(x_spacing * x_count),
                y = math.floor(y_spacing * y_count),
                z = z
            })
            take_photo()
        end
    end
end
