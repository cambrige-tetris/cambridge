local Object = require "libs.classic"

Scene = Object:extend()

function Scene:new() end
function Scene:update() end
function Scene:render() end
function Scene:onInputPress() end
function Scene:onInputMove() end
function Scene:onInputRelease() end

--#region Named scene-function impostors
--        For some reason, these "scenes" must be loaded before TitleScene or else title screen bugs out

JoinDiscordFunc = require "scene.named_funcs.join_discord"
ReportBugFunc = require "scene.named_funcs.report_bug"

--#endregion

ExitScene = require "scene.exit"
GameScene = require "scene.game"
ResourcePackScene = require "scene.resource_pack_scene"
ReplayScene = require "scene.replay"
ModeSelectScene = require "scene.mode_select"
RevModeSelectScene = require "scene.revamped_mode_select"
HighscoresScene = require "scene.highscores"
ReplaySelectScene = require "scene.replay_select"
KeyConfigScene = require "scene.key_config"
StickConfigScene = require "scene.stick_config"
InputConfigScene = require "scene.input_config"
AbstractConfigScene = require "scene.config" -- this is an abstract scene
GameConfigScene = require "scene.game_config"
VisualConfigScene = require "scene.visual_config"
AudioConfigScene = require "scene.audio_config"
TuningScene = require "scene.tuning"
SettingsScene = require "scene.settings"
CreditsScene = require "scene.credits"
TitleScene = require "scene.title"
TutorialKeybinder = require "scene.tutorial_keybinder"
