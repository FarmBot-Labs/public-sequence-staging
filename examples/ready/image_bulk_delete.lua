local url = "https://my.farm.bot/api/images/"
local pause = 250
local headers = {
    Authorization = ("bearer " .. auth_token()),
    Accept = "application/json"
}
function get_images()
    response, err = http({method = "GET", url = url, headers = headers})

    function no(msg) send_message("error", msg, "toast") end

    if err then return no("Network Error: " .. inspect(err)) end
    if response.status > 299 then
        return no("HTTP Error: " .. response.status)
    end
    return json.decode(response.body)
end

local images = get_images()
for k in pairs(images) do
    if read_status("informational_settings", "locked") then
        return
    else
        if (k % 25) == 0 then
            m = "Deleted " .. k .. " of " .. #images .. " images"
            send_message("info", m, "toast")
        end
        wait(pause)
        collectgarbage()
        ok, error = http({
            url = url .. images[k].id,
            method = "DELETE",
            headers = headers
        })
        if error then
            send_message("error", inspect(error), "toast")
            return
        else
            if ok.status > 399 then
                local msg = "" .. ok.status .. " error: "
                inspect(ok.body)
                send_message("error", msg, "toast")
                return
            end
        end
    end
end
