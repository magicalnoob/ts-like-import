--- Test.lua
-- test thing lol
-- @author Magical_Noob

-- You are able to change it from shared to 
-- the module itself, but I ran out of time so
-- NO!11!!!

local import = shared.import;
local returnCode = import { "object", "test" }: from("TestReturn.lua");

local class = {};
class.__index = class;

function class:test()
	print(returnCode); -- Should print out true, false
end

return class;
