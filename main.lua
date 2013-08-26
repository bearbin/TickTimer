-- Copyright (c) 2013 Alexander Harkness

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- Configuration

TICKBUFFER = 40 -- How many ticks the average is calculated over.
DEBUGMODE = false -- Enable extra verbosity.
LOGLATETICKS = true -- Log ticks that run late to the console.
MSFORLATETICK = 500 -- Any tick that takes longer than this is classed "long".
LATETICKDELAY = 10 -- The period where the server mutes more late tick logs to prevent console spam. Set to 0 to disable.

-- Globals

PLUGIN = {}
LOGPREFIX = ""
TICKTIMES = {}
LASTLATETICK = GetTime()
LASTLATESECS = GetTime()

-- Plugin Start

function Initialize( Plugin )

    PLUGIN = Plugin
    PluginManager = cRoot:Get():GetPluginManager()

    Plugin:SetName( "TickTimer" )
    Plugin:SetVersion( 2 )

	LOGPREFIX = "["..Plugin:GetName().."] "

	-- Hooks

    cPluginManager.AddHook(cPluginManager.HOOK_WORLD_TICK, OnWorldTick)

	-- Commands

	PluginManager:BindCommand("/tps", "ticktimer.tps", HandleTPSCommand, "Find out the server's average tick rate.")
	PluginManager:BindCommand("/lag", "ticktimer.tps", HandleTPSCommand, "")
	PluginManager:BindConsoleCommand("tps", HandleTPSCommandConsole, "Find out the server's average tick rate.")
	PluginManager:BindConsoleCommand("lag", HandleTPSCommandConsole, "")

	LOGINFO( LOGPREFIX .. "Plugin v" .. Plugin:GetVersion() .. " Enabled!" )
        return true
end

function OnDisable()
	LOGINFO( LOGPREFIX .. "Plugin Disabled!" )
end

function OnWorldTick(world, timeDelay)

	if TICKTIMES[world:GetName()] == nil then
		TICKTIMES[world:GetName()] = {}
	end

	if #TICKTIMES[world:GetName()] >= TICKBUFFER then
		table.remove(TICKTIMES[world:GetName()], 1)
	end

	table.insert(TICKTIMES[world:GetName()], timeDelay)

	if MSFORLATETICK < timeDelay and LOGLATETICK then

		if GetTime() - LASTLATESECS > (LATETICKDELAY - 1) then
			LOGWARN( LOGPREFIX .. " Tick took too long - took: " .. timeDelay .. " ms. Last late tick was: " .. GetTime() - LASTLATETICK .. " seconds ago!")
		end

		LASTLATESECS = GetTime()

	end

end

function HandleTPSCommand(Split, Player)

	for world, ticks in pairs(TICKTIMES) do

		local averageTPS = 0

		for i = 1, #ticks do
			averageTPS = averageTPS + ticks[i]
		end

		averageTPS = averageTPS / #ticks

		Player:SendMessage("[" .. world .. "] Average TPS over the last " .. #TICKTIMES .. " ticks is: " .. (1000 / averageTPS))

	end

	return true

end

function HandleTPSCommandConsole(Split)

	for world, ticks in pairs(TICKTIMES) do

		local averageTPS = 0

		for i = 1, #ticks do
			averageTPS = averageTPS + ticks[i]
		end

		averageTPS = averageTPS / #ticks

		LOG("[" .. world .. "] Average TPS over the last " .. #TICKTIMES .. " ticks is: " .. (1000 / averageTPS))

	end

	return true

end
