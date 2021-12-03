token = env("Plant.ID Token")
p = variable("Plant")
r = 40
rad = (math.pi * 2) / 6
o_x = tonumber(env("CAMERA_CALIBRATION_camera_offset_x") or "0")
o_y = tonumber(env("CAMERA_CALIBRATION_camera_offset_y") or "0")

function s(num)
    x = p.x - o_x + (r * math.cos(rad * num))
    y = p.y - o_y + (r * math.sin(rad * num))
    z = 0
    move_absolute(x, y, z)
    data = take_photo_raw()
    return base64.encode(data)
end

images = {s(1), s(2), s(3), s(4), s(5), s(6)}

headers = {}
headers["Content-Type"] = "application/json"
headers["Api-Key"] = token
body = {
    images = images,
    modifiers = {"health_all", "crops_medium"},
    plant_details = {"common_names"}
}
response, err = http({
    url = "https://api.plant.id/v2/identify",
    method = "POST",
    headers = headers,
    body = json.encode(body)
})

function common_name(num)
    return data["suggestions"][num]["plant_details"]["common_names"][1]
end

function probability(num)
    return math.floor((data["suggestions"][num]["probability"]) * 100 + 0.5)
end

function result(num) return common_name(num) .. " (" .. probability(num) .. "%)" end

if err then
    send_message("error", inspect(err), "toast")
else
    data = json.decode(response.body)
    report = "Possible plants: " .. result(1) .. ", " .. result(2) .. ", " ..
                 result(3)
    send_message("info", inspect(report), "toast")
end
