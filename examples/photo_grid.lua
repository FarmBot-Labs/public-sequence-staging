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
local scale = fwe("coord_scale")
local z = fwe("camera_z")
local raw_img_size_x_px = fwe("center_pixel_location_x") * 2
local raw_img_size_y_px = fwe("center_pixel_location_y") * 2
local raw_img_size_x_mm = raw_img_size_x_px * scale
local raw_img_size_y_mm = raw_img_size_y_px * scale
local margin_mm = cropAmount(raw_img_size_x_px, raw_img_size_y_px, cam_rotation)
local cropped_img_size_x_mm = raw_img_size_x_mm - margin_mm
local cropped_img_size_y_mm = raw_img_size_y_mm - margin_mm
if math.abs(cam_rotation) < 45 then
  x_spacing_mm = cropped_img_size_x_mm
  y_spacing_mm = cropped_img_size_y_mm
else
  x_spacing_mm = cropped_img_size_y_mm
  y_spacing_mm = cropped_img_size_x_mm
end
local grid_size_x_mm = garden_size().x - x_spacing_mm
local grid_size_y_mm = garden_size().y - y_spacing_mm
local grid_points_x = math.ceil(grid_size_x_mm / x_spacing_mm)
local grid_points_y = math.ceil(grid_size_y_mm / y_spacing_mm)
local grid_points_total = (grid_points_x + 1) * (grid_points_y + 1)
local grid_start_x_mm = (x_spacing_mm / 2)
local grid_start_y_mm = (y_spacing_mm / 2)
local x_offset_mm = fwe("camera_offset_x")
local y_offset_mm = fwe("camera_offset_y")
local current = 0
for grid_index_x = 0, grid_points_x do
  for grid_index_y = 0, grid_points_y do
    current = current + 1
    if read_status("informational_settings", "locked") then
      return
    else
      local y_temp1 = (y_spacing_mm * grid_index_y)
      if (grid_index_x % 2) == 0 then
        y = (grid_start_y_mm + (y_temp1 - y_offset_mm))
      else
        y = (grid_size_y_mm - (y_temp1 - y_offset_mm))
      end
      move_absolute({
        x = (grid_start_x_mm + (x_spacing_mm * grid_index_x) -
          x_offset_mm),
        y = y,
        z = z
      })
      msg = "Taking photo " .. current .. " of " .. grid_points_total
      send_message("info", msg)
      take_photo()
    end
  end
end
