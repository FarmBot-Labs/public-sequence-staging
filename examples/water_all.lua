response, err = http({
    url = "http://localhost:3000/api/points/",
    method = "GET",
    headers = {
        Authorization = ("bearer " .. auth_token()),
        Accept = "application/json"
    }
})

function no(msg) send_message("error", msg, "toast") end

if err then return no("error" .. inspect(err)) end
if response.status > 299 then return no("HTTP " .. response.status) end

points = json.decode(response.body)

local plants = {}

for k, v in pairs(points) do
    if v.pointer_type == "Plant" then
        table.insert(plants, {x = v.x, y = v.y, z = 0})
    end
end

collectgarbage()

table.sort(plants, function(l, r)
    if l.x == r.x then
        return l.y < r.y
    else
        return l.x < r.x
    end
end)

for k, v in pairs(plants) do
    move_absolute(v)
    write_pin(8, "digital", 1)
    wait(2000)
    write_pin(8, "digital", 0)
end
