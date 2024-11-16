
print("Loading Discord GameSDK...")
DiscordGameSDK = {
	loaded = false,
	references = {},
	presence = {
		details = "Loading game...",
		state = "",
		large_image = "icon2",
		large_text = "Arcade Stacker",
		small_image = "",
		small_text = ""
	}
}
local now = 0
local success, libDiscordGameSDK = pcall(require, "libs.discordGameSDK")
if success then
	DiscordGameSDK.loaded = true
	DiscordGameSDK.app_id = 599778517789573120

	DiscordGameSDK.references = libDiscordGameSDK.initialize(DiscordGameSDK.app_id)
	DiscordGameSDK.presence.start_time = os.time(os.date("*t"))
	DiscordGameSDK.references = libDiscordGameSDK.updatePresence(DiscordGameSDK.references, DiscordGameSDK.presence)

	DiscordGameSDK.GameSDK = libDiscordGameSDK
	print("Discord GameSDK successfully loaded")
else
	print("Discord GameSDK failed to load!")
end

function DiscordGameSDK:update(newstuff)
	for k, v in pairs(newstuff) do self.presence[k] = v end
	if self.loaded then self.references = self.GameSDK.updatePresence(self.references, self.presence) end
end