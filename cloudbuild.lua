local yaml = require "lua.tinyyaml"
local argparse = require "lua.argparse"
local glue = require "lua.glue"
local readfile = glue.readfile
local split = glue.string.split
-- local inspect = require "lua.inspect"

local dockerRun =
    [[sudo docker run -v "/home/ubuntu/shadowmods/nextcloud/cloud-data/nextcloud/data/%s/files/%s/tags":/invader/tags -v "%s":/invader/maps -v "%s":/invader/resources invader-docker ]]

-- invader-build commands for CI/CD server
-- user, cloudpath, outputpath, resourcespath, tagsize, scenariopath
local buildMap = dockerRun .. [[sudo invader-build -E -g gbx-custom -T %s -H "%s"]]

local parser = argparse("invader-pipe", "Pipeline for Invader projects.")
parser:argument("buildfile", "Path to Invader project to build")
parser:flag("-r --release", "Build project as release")
parser:flag("-d --debug", "Enable debug print on the script")

-- Override args array with parser ones
local args = parser:parse()

---@class buildfile
---@field version number
---@field user string
---@field cloudpath string
---@field engine string
---@field tagsize string
---@field extendlimits boolean
---@field scenarios string[]
---@field outputpath string
---@field packagelabel string
---@field postbuild string[]

-- Build project using yml definition
---@type buildfile
local build = yaml.parse(readfile(args.buildfile))
local resourcespath = os.getenv("INVADER_RESOURCES_PATH")
local outputpath = os.getenv("INVADER_OUTPUT_PATH")
local pipe = io.popen("readlink -f " .. args.buildfile, "r")
local absoluteymlpath = pipe:read()
pipe:close()
local buildfilesplit = split(absoluteymlpath, "/")
buildfilesplit[#buildfilesplit] = nil
local projectpath = table.concat(buildfilesplit, "/")
if (not projectpath or projectpath == "") then
    projectpath = "."
end
-- Map does not require Chimera tag expansion
if (not build.tagsize or build.tagsize == "23M") then
    buildMap = buildMap:gsub("-T %s", "")
end
-- Compile every scenario specified in the yml file
for scenarioindex, scenariopath in pairs(build.scenarios) do
    local buildcmd
    if (not args.release) then
        -- Build directly to test server
        buildcmd = buildMap:format(build.user, build.cloudpath, outputpath, resourcespath,
                                   build.tagsize, scenariopath)
    else
        local scenariosplit = split(scenariopath, "/")
        local scenarioname = scenariosplit[#scenariosplit]:gsub("_dev", "")
        -- Build map to yml output path, remove "_dev" subfix from final scenario name
        buildcmd = buildMap:format(build.user, build.cloudpath,
                                   projectpath .. "/" .. build.outputpath, resourcespath,
                                   build.tagsize, scenariopath)
        buildcmd = ("%s -N \"%s\""):format(buildcmd, scenarioname)
    end
    if (args.debug) then
        print(buildcmd)
    end
    if (not os.execute(buildcmd)) then
        print("Error, on scenario build, abort cloud build.")
        os.exit(1)
    end
end

local vars = {MERCURY_PACKAGE = build.packagelabel, PROJECT_PATH = projectpath}

local fixedvars = ""

-- Run post build commands on release
if (args.release) then
    for _, command in pairs(build.postbuild or {}) do
        if (args.debug) then
            print(command)
        end
        for var, value in pairs(vars) do
            fixedvars = fixedvars .. "export " .. var .. "=" .. value .. " && "
        end
        if not os.execute(fixedvars .. command) then
            print("Command error: " .. command)
            print("Error, abort cloud build.")
            os.exit(1)
        end
    end
end
os.exit(0)
