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
local url = GITHUB_URL .. args[1] .. EXTENSION
local result = http.get(url)
if (!result) then
    term.setTextColor(colors.red)
    print("Failed to connect to '" .. url .. "'!")
    term.setTextColor(col)
    return;
end
if(result.getResponseCode() == 404) then
    term.setTextColor(colors.red)
    print("File " .. args[1] .. " doesn't exist!")
    term.setTextColor(col)
    return
end
local content = result.readAll()
result.close()
if(result.getResponseCode() ~= 200) then
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