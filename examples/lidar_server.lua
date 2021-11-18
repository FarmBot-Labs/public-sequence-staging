-- Script that was used to read garden topology with a laser
-- time of flight sensor.
function go()
    local server = "https://my.farm.bot"
    local url = "http://192.168.1.115:8888/"
    local params = {method = "GET", url = url}
    local resp_json, err = http(params)
    local z = json.decode(resp_json.body) * -10
    local p = get_position()
    local body = json.encode({
        name = "Soil Height",
        radius = 0.0,
        x = p.x,
        y = p.y,
        z = z,
        pointer_type = "GenericPointer",
        meta = {color = "red", at_soil_level = "true"}
    })

    ok, error = http({
        method = "POST",
        url = server .. "/api/points",
        body = body,
        headers = {
            Authorization = ("bearer " .. auth_token()),
            Accept = "application/json"
        }
    })

    if error then
        fail()()
        send_message("error", inspect(error), "toast")
    else
        send_message("debug", "OK " .. z, "toast")
    end
end

for yy = 200, 2000, 100 do
    for xx = 200, 1800, 100 do
        if read_status("informational_settings", "locked") then
            return send_message("error", "E-Stopped. Halting execution.")
        end
        move_absolute(xx, yy, 0)
        wait(500)
        go()
    end
end
