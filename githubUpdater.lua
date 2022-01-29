local args = {...}
REPOSITORY = "Lauriichan/CC-Scripts"
BRANCH = "master"
GITHUB_URL = "https://raw.githubusercontent.com/" .. REPOSITORY .. "/" .. BRANCH .. "/"
EXTENSION = ".lua"
term.clear();
if(#args < 1) then
    term.error("Please specify the file that you want to update")
    return
end
local name = args[1]
if(#args >= 2) then
    name = args[2]
end
local url = GITHUB_URL .. args[1] .. EXTENSION
local result = http.get(url)
if(result.code == 404) then
    term.error("File " .. args[1] .. " doesn't exist!")
    return
end
local content = result.readAll()
result.close()
if(result.code ~= 200) then
    term.error("Couldn't download file " .. args[1] .. "!")
    print(content);
    return
end
local file = fs.open(name, "w")
file.write(content)
file.flush()
file.close()
term.success("Successfully downloaded file " .. args[1] .. " as " .. name .. "!")