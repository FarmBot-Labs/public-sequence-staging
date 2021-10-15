find_home()

response, err = http({
    url = "https://my.farm.bot/api/points/",
    method = "GET",
    headers = {
        Authorization = ("bearer " .. auth_token()),
        Accept = "application/json"
    }
})

function no(msg) send_message("error", msg, "toast") end

if err then return no("error" .. inspect(err)) end
if response.status > 299 then return no("HTTP " .. response.status) end

local plants = {}

for k, v in pairs(json.decode(response.body)) do
    if v.pointer_type == "Plant" then
        table.insert(plants, {name = v.name, x = v.x, y = v.y, z = 0})
    end
end

table.sort(plants, function(l, r)
    -- "close enough" approximation.
    if math.abs(l.x - r.x) < 150 then
        return l.y < r.y
    else
        return l.x < r.x
    end
end)

count = 0
total = #plants

for k, v in pairs(plants) do
    count = count + 1
    if read_status("informational_settings", "locked") then
        return send_message("error", "E-Stopped. Halting execution.")
    else
        if count % 10 == 0 then collectgarbage() end
        tally = "[" .. count .. "/" .. total .. "]"
        desc = " Watering " .. (v.name or "plant") .. " at "
        coords = " " .. v.x .. ", " .. v.y
        message = tally .. desc .. coords
        send_message("info", message)
        move_absolute(v.x, v.y, v.z)
        write_pin(8, "digital", 1)
        wait(2000)
        write_pin(8, "digital", 0)
    end
end
