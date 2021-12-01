extends "res://stages/scripts/StageInit.gd"



const start_text = [
	{
		"s": "MARS",
		"t":[
		"Landed and ready to proceed"
		]
	},
	{ "s": "", "t": ["..."] },
	{
		"s": "MARS",
		"t":[
		"HQ do you read me?"
		]
	},
	{ "s": "", "t": ["..."] },
	{
		"s": "MARS",
		"t":[
		"This is agent 067-Mars to all callsigns on this frequency", "Does anyone copy?"
		]
	},
	{ "s": "", "t": ["..."] },
	{
		"s": "MARS",
		"t":[
		"Shit!", ";Stay on comms Agent Mars,' they said"
		]
	},
	{
		"s": "MARS",
		"t":[
		"Proceeding to designated pickup position under auxiliary protocol 6B", "I will come back to haunt your asses if you write me off as dead before I make it"
		]
	},
]

const text1 = [
	{
		"s": "UNKNOWN",
		"t":[
		"sdkjfie...eelloa.... Hello! Hello! Check!",  
		"Is anyone on this comm? Can anyone hear me?", 
		]
	},
	{
		"s": "MARS",
		"t":[
		"This is agent 067-Mars with the Galactic Trade Task Force", 
		"Are you able to receive my transmission?"
		]
	},
	{
		"s": "UNKNOWN",
		"t":[
		"Oh thank god!",  
		"This is radio operator...Aeonia from the North-Central command bunker",
		]
	},
		{
		"s": "AEONIA",
		"t":[ 
		"\\skip",
		"We need backup ASAP"
		]
	},
	{
		"s": "MARS",
		"t":[
		"Unfortunately, I am all there is", 
		"This is a recon mission in order to verify the distress call. Care to explain what the hell just attacked me?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"We...we don’t know what we are fighting against.", 
		"No records of these creatures exist but they seem to be intelligent enough to be able to intercept our comm systems."
		]
	},
	{
		"s": "MARS",
		"t":[
		"That explains why I lost contact with HQ...",
		"Will you be able to guide me to your position?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Negative", 
		"We have no systems online at the moment", 
		"However, the recon radars are still online. You should be able to use them."
		]
	},
	{
		"s": "MARS",
		"t":[
		"...got it.", 
		]
	},
	{
		"s": "",
		"t":[
			"Seems like my minimap is still functioning.",
			"It should eventually lead me to the bunker."
		]
	}
]

var text_end = [
		{
		"s": "AEONIA",
		"t":[
		"uoijf...hello test", "ah is this better now?"
		]
	},
	{
		"s": "MARS",
		"t":[
		"Significantly", "The comms seem to be getting better"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Yes it seems so", "Surprisingly, your brute force approach to clearing out hostiles near radars seems to be working", "Don't know how though", "But the next area should be easier to handle now that the hostiles seem to be cleared out"
		]
	},
	{
		"s": "MARS",
		"t":[
		"You're welcome by the way"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Not until you get to the command bunker"
		]
	},
]

var radars := []
var radar_count = 0

var end_timer := Timer.new()

func start():
	add_child(end_timer)
	end_timer.connect("timeout", LoadingScreen, "save_and_transition", ["res://stages/Stage2.tscn"])
	
	$AudioStreamPlayer.play()
	GameManager.soundtrack = $AudioStreamPlayer
	GameManager.dialogue.connect("dialogue_ended", self, "on_end")

	radars = get_tree().get_nodes_in_group("bugged_radar")
	for radar in radars:
		radar.connect("destroyed", self, "radar_destroyed")
		
	GameManager.dialogue.start(start_text)

func radar_destroyed():
	radar_count += 1
	
	if radar_count == 3:
		GameManager.dialogue.start(text_end)

func on_end(dia):
	if dia == text_end:
		end_timer.start(1.0)
		# the change scene is connect to timer in _ready

