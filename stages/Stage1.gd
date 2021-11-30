extends "res://stages/scripts/StageInit.gd"

const text1 = [
	{
		"s": "UNKNOWN",
		"t":[
		"sdkjfie...eelloa.... Hello! Hello! Check!",  
		"Is anyone on this comm?", 
		"Can anyone hear me? Over"
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
		"Yes! Yes, we can pick up your transmission agent... Mars", 
		"This is radio operator...Aeonia from the North-Central command bunker", 
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
		"No records of these creatures exist but they seem to be intelligent enough to be able to intercept and disrupt our comm systems."
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

var radars := []

var radar_count = 0

func start():
	$AudioStreamPlayer.play()
	#$UI/UI/DialogueContainer.start(text1)

	radars = get_tree().get_nodes_in_group("bugged_radar")
	for radar in radars:
		radar.connect("destroyed", self, "radar_destroyed")

func radar_destroyed():
	radar_count += 1
	
	if radar_count == 3:
		print("You win!")
