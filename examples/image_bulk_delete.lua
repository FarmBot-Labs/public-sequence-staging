local url = "https://my.farm.bot/api/images/"
function get_images()
    response, err = http({
        method = "GET",
        url = url,
        headers = {
            Authorization = ("bearer " .. auth_token()),
            Accept = "application/json"
        }
    })

    function no(msg) send_message("error", msg, "toast") end

    if err then return no("Network Error: " .. inspect(err)) end
    if response.status > 299 then
        return no("HTTP Error: " .. response.status)
    end
    return json.decode(response.body)
end

images = get_images()
count = 0
repeat
    count = count + 1

    local message = "Begining image deletion batch " .. count
    send_message("info", message, "toast")

    for k in pairs(images) do
        if read_status("informational_settings", "locked") then
            return
        else
            if (k % 45) == 0 then
                m =
                    "Deleted " .. k .. " of " .. #images .. " images in batch " ..
                        count
                send_message("info", m, "toast")
            end
            wait(500)
            collectgarbage()
            http({
                url = url .. images[k].id,
                method = "DELETE",
                headers = headers
            })
        end
    end
    wait(500)
until (count >= #images)
