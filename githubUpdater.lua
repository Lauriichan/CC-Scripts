local args = {...}

REPOSITORY = "Lauriichan/CC-Scripts";
BRANCH = "master"
GITHUB_URL = "https://raw.githubusercontent.com/${repo}/${branch}/${file}.lua" % {repo = REPOSITORY, branch = BRANCH};

if(#args < 1) then
    print("ERROR: Please specify the file that you want to update");
    return;    
end

local name = args[1];
if(#args >= 2) then
    name = args[2];
end

local url = GITHUB_URL % {file = args[1]};

local result = http.get(url);
if(result.code == 404) then
    print("ERROR: File ${file} doesn't exist!" % {file = args[1]});
    return;
end
if(result.code ~= 200) then
    print("ERROR: Couldn't download file ${file}!" % {file = args[1]});
    return;
end

local content = result.readAll();
local file = fs.open(name, "w");
file.write(content);
file.flush();
file.close();
result.close();

print("Successfully downloaded file ${file} as ${name}!" % {file = args[1], name = name});