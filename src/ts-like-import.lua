--- ImportLoader.lua
-- similar to ts's import. Returns a tuple
-- for the stuff imported.
-- Bully me.
-- @author Magical_Noob
local BASE_PARENT = game:GetService("RunService"):IsClient() and game.ReplicatedStorage or game.ServerStorage;
local MODE_KEY_METATABLE = {__mode = "kv"};

local Import = {};
Import.__index = Import;

--- u can change idk
local FILE_FORMATS = {
	lua = "ModuleScript", 
	server = "Script", 
	client = "LocalScript",
	instance = "Instance"
};

--- WaitForChildThatIsA
-- @param parent: Instance
-- @param name: string
-- @param className: string
local function WaitForChildThatIsA(parent, name, className)
	local detect = parent:FindFirstChild(name, true);
	
	if (detect) then
		-- We check if this object is actually
		-- what we wanted
		
		if (detect:IsA(className)) then
			return parent[name];
		end
		
		-- Check the parent if we still cannot find
		-- the object with that certain className
		for _, module in pairs(parent:GetDescendants())do
			if (module.Name == name and module:IsA(className)) then
				return module;
			end
		end		
	end
	
	while (true) do
		-- Simple wait for child,
		-- Checks for descendants added
		
		local result = parent.DescendantAdded:Wait();
		if (result.Name == name and result:IsA(className)) then
			return result;
		end
	end
end

--- GetPath
-- Slashes to index parent
-- Also at the end you must use .something otherwise
-- itll assume its a folder instead of what you want.
-- @param path: string
-- @param parent: Instance?
-- @return final: Instance?
function Import:GetPath(path, parent)
	parent = parent or BASE_PARENT;
	for _, str in pairs(path:split("/"))do
		-- @todo support "."
		
		local format = str:split(".");
		local class = "Folder";
		if (format[2]) then
			-- check if this thing is the correct type	
			class = FILE_FORMATS[format[2]];
		end
		
		parent = WaitForChildThatIsA(parent, format[1], class);	
		if (not parent) then
			-- DISGUSTING
			return;
		end
	end
	
	return parent;
end

--- GetModuleArgs
-- @param module: string
-- @param args: any[]
function Import:GetModuleArgs(modulePath, args, parent)
	local final = {};
	local data = self:GetPath(modulePath, parent);
	if (not data) then
		return {};
	else
		data = require(data);
		if (typeof(data) ~= "table") then
			-- We won't need the indexing stuff
			-- cuz that'll be useless
			return data;
		end
	end
	
	for _, name in pairs(args)do
		if (name == "*") then
			return data;
		else
			table.insert(final, data[name]);
		end
	end
	
	-- gc references
	args = nil;
	data = nil;
	
	return unpack(final, 1, #final);	
end

--- import
-- The main shared function.
-- Also don't bully me because i used shared ://///////////////
-- @param args: any[]
-- @return final: module[]
function shared.import(args)
	return setmetatable(
		{
			from = function(_, module, parent)
				--- Don't mind this bad code
				return Import:GetModuleArgs(module, args, parent);
			end
		}
	, MODE_KEY_METATABLE);
end

-- @function import (i actually don't know how ldoc works ¯\_(ツ)_/¯)
Import.import = shared.import;

--- export
return Import;
