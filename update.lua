local args = {...}
REPOSITORY = "Lauriichan/CC-Scripts"
BRANCH = "master"
GITHUB_URL = "https://raw.githubusercontent.com/" .. REPOSITORY .. "/" .. BRANCH .. "/"
EXTENSION = ".lua"
term.clear();
local col = term.getTextColor()
if(#args < 1) then
    term.setTextColor(colors.red)
    print("Please specify the file that you want to update")
    term.setTextColor(col)
    return
end
local name = args[1]
if(#args >= 2) then
    name = args[2]
end
local gitUrl = GITHUB_URL .. args[1] .. EXTENSION

http.request{
    url = gitUrl
    method = "GET"
}

local handle = nil;
while true do
    event, resUrl, sHandle, fHandle = os.pullEvent()
    if (event == "http_success" || event == "http_failure" && resUrl = gitUrl then
        if (event == "http_failure") then
            handle = fHandle
        else
            handle = sHandle
        end
        break
    end
end

if not handle then 
    term.setTextColor(colors.red)
    print("Failed to connect to '" .. gitUrl .. "'!")
    term.setTextColor(col)
    return
end
if handle.getResponseCode() == 404 then
    term.setTextColor(colors.red)
    print("File " .. args[1] .. " doesn't exist!")
    term.setTextColor(col)
    return
end
local content = handle.readAll()
handle.close()
if handle.getResponseCode() ~= 200 then
    term.setTextColor(colors.red)
    print("Couldn't download file " .. args[1] .. "!")
    print(content);
    term.setTextColor(col)
    return
end
local file = fs.open(name, "w")
file.write(content)
file.flush()
file.close()
term.setTextColor(colors.green)
print("Successfully downloaded file " .. args[1] .. " as " .. name .. "!")
term.setTextColor(col)