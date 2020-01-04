--- Config: How long until the shutdown is activated
local gShutdownIntervalSeconds = 12 * 60 * 60  -- 12 hours

--- Number of seconds that a warning will be broadcast before shutting down
local gWarningSeconds = 10






local function startCountdown(aWorld)
	LOG("Server shutdown in " .. gWarningSeconds .. " seconds.")
	aWorld:BroadcastChatWarning("The server will be restarted in " .. gWarningSeconds .. " seconds")
	for i = 1, gWarningSeconds do
		aWorld:ScheduleTask(i * 20,
			function(aCBWorld)
				aCBWorld:BroadcastChatWarning("The server will be restarted in " .. (gWarningSeconds - i) .. " seconds")
			end
		)
	end
	aWorld:ScheduleTask(gWarningSeconds * 20,
		function(aCBWorld)
			aCBWorld:BroadcastChatWarning("The server is restarting now")
			LOG("Server shutting down now.")
			cRoot:Get():QueueExecuteConsoleCommand("stop")
		end
	)
end





function Initialize(a_Plugin)
	-- Sanity-check the config:
	gShutdownIntervalSeconds = tonumber(gShutdownIntervalSeconds) or (12 * 60 * 60)
	gWarningSeconds = tonumber(gWarningSeconds) or 10
	if (gShutdownIntervalSeconds < 3) then
		gShutdownIntervalSeconds = 3
	end
	if (gWarningSeconds >= gShutdownIntervalSeconds) then
		gWarningSeconds = gShutdownIntervalSeconds - 1
	end
	LOG("The server will shut down in " .. gShutdownIntervalSeconds ..
		" seconds (" .. (gShutdownIntervalSeconds / 3600) .. " hours), with a warning for " ..
		gWarningSeconds .. " seconds."
	)

	-- Schedule the shutdown:
	cRoot:Get():GetDefaultWorld():ScheduleTask((gShutdownIntervalSeconds - gWarningSeconds) * 20, startCountdown)
	return true
end
