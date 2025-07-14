local Logging = {}

Logging.filepath = "./"
Logging.filename = nil

function Logging.Init()
    Logging.filename = Logging.filepath .. "logs-" .. os.date("%Y-%m-%d-%H%M%S") .. ".txt"
end

function Logging.Log(message)
    existing_log_data = fs.read(Logging.filename) or ""

    if existing_log_data ~= "" then
        existing_log_data = existing_log_data .. "\n"
    end

    fs.write(Logging.filename, existing_log_data .. tostring(message))
end

return Logging

