-- IMPORTANT: Change these values if you are self hosted:
protocol = "https"
host = "my.farm.bot"

-- BEGIN --

url = protocol .. "://" .. host .. "/api/images/"
headers = {
    Authorization = ("bearer " .. auth_token()),
    Accept = "application/json"
}
response, error = http({url = url, method = "GET", headers = headers})

if error then
    send_message("error", "ERROR: " .. inspect(error), "toast")
    return
end

images = json.decode(response.body)

for k in pairs(images) do
    image = images[k]
    send_message("info", "Delete image #" .. image.id, "toast")
    wait(500)
    http({url = url .. image.id, method = "DELETE", headers = headers})
end
