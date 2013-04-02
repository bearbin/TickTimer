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
        Plugin:SetVersion( 1 )

	LOGPREFIX = "["..Plugin:GetName().."] "

	-- Hooks

        PluginManager:AddHook(Plugin, cPluginManager.HOOK_TICK)
        
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

function OnTick(timeDelay)

	if #TICKTIMES == TICKBUFFER then
		table.remove(TICKTIMES, 1)
	end

	table.insert(TICKTIMES, timeDelay)

	if MSFORLATETICK < timeDelay and LOGLATETICK then

		if GetTime() - LASTLATESECS > (LATETICKDELAY - 1) then
			LOGWARN( LOGPREFIX .. " Tick took too long - took: " .. timeDelay .. " ms. Last late tick was: " .. GetTime() - LASTLATETICK .. " seconds ago!")
		end

		LASTLATESECS = GetTime()

	end

end

function HandleTPSCommand(Split, Player)

	local averageTPS = 0

	for i = 1, #TICKTIMES do
		averageTPS = averageTPS + TICKTIMES[i]
	end

	averageTPS = averageTPS / #TICKTIMES

	Player:SendMessage("Average TPS over the last " .. #TICKTIMES .. " ticks is: " .. (1000 / averageTPS))

	return true

end

function HandleTPSCommandConsole(Split)

	local averageTPS = 0

	for i = 1, #TICKTIMES do
		averageTPS = averageTPS + TICKTIMES[i]
	end

	averageTPS = averageTPS / #TICKTIMES

	LOG(LOGPREFIX .. "Average TPS over the last " .. #TICKTIMES .. " ticks is: " .. (1000 /averageTPS ))

	return true

end
