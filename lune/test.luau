--[[
    Tier-1 headless test runner.
    Discovers *.spec.luau files under tests/ and src/shared/ and runs them.
    Each spec returns a table: { ["test name"] = function() ... end }
    Asserts are plain Luau `assert()` calls — no framework needed.
]]

local fs = require("@lune/fs")
local process = require("@lune/process")

local passed = 0
local failed = 0
local loadErrors = 0

local function runSpec(label: string, requirePath: string)
    print("\n[" .. label .. "]")
    local ok, result = pcall(require, requirePath)
    if not ok then
        print("  ERROR loading spec: " .. tostring(result))
        loadErrors += 1
        return
    end
    if type(result) ~= "table" then
        print("  ERROR: spec must return a { [name] = fn } table")
        loadErrors += 1
        return
    end
    for name, fn in result do
        local ok2, err = pcall(fn)
        if ok2 then
            print("  ✓ " .. name)
            passed += 1
        else
            print("  ✗ " .. name .. "\n    " .. tostring(err))
            failed += 1
        end
    end
end

-- fsDir:       path relative to CWD (the project root)
-- requirePrefix: path relative to lune/test.luau (used for require())
local function discover(fsDir: string, requirePrefix: string)
    if not fs.isDir(fsDir) then
        return
    end
    for _, entry in ipairs(fs.readDir(fsDir)) do
        local fullFs = fsDir .. "/" .. entry
        if fs.isDir(fullFs) then
            discover(fullFs, requirePrefix .. "/" .. entry)
        elseif entry:match("%.spec%.luau$") then
            local stem = entry:gsub("%.luau$", "")
            runSpec(fullFs, requirePrefix .. "/" .. stem)
        end
    end
end

discover("tests", "../tests")
discover("src/shared", "../src/shared")

print(string.format("\n%d passed  %d failed  %d errors\n", passed, failed, loadErrors))

if failed > 0 or loadErrors > 0 then
    process.exit(1)
end
