
hook.Add("HomigradRun", "ZC_Implants_Load", function()
    local sides = {
        ["sv_"] = "sv_",
        ["sh_"] = "sh_",
        ["cl_"] = "cl_",
        ["_sv"] = "sv_",
        ["_sh"] = "sh_",
        ["_cl"] = "cl_",
    }

    local function AddFile(file, dir)
        local fileSide = string.lower(string.Left(file, 3))
        local fileSide2 = string.lower(string.Right(string.sub(file, 1, -5), 3))
        local side = sides[fileSide] or sides[fileSide2]

        if SERVER and side == "sv_" then
            include(dir .. file)
        elseif side == "sh_" then
            if SERVER then AddCSLuaFile(dir .. file) end
            include(dir .. file)
        elseif side == "cl_" then
            if SERVER then
                AddCSLuaFile(dir .. file)
            else
                include(dir .. file)
            end
        else
            if SERVER then AddCSLuaFile(dir .. file) end
            include(dir .. file)
        end
    end

    local function IncludeDir(dir)
        dir = dir .. "/"
        local files, directories = file.Find(dir .. "*", "LUA")
        if files then
            for _, v in ipairs(files) do
                if string.EndsWith(v, ".lua") then
                    AddFile(v, dir)
                end
            end
        end
        if directories then
            for _, v in ipairs(directories) do
                IncludeDir(dir .. v)
            end
        end
    end
    IncludeDir("zc_implants")

    print("[ZC-Implants] Loaded successfully.")
end)