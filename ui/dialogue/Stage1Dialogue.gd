extends DialogueController

const text1 = [
	{
		"s": "UNKNOWN",
		"t": [	
			"sdkjfie…eelloa….",
			"Hello! Hello! Check! Is anyone on this comm?",
			"Can anyone hear me? Over."
			]
			
	},
	{
		"s": "MARS",
		"t": [
			"This is agent 067-Mars with the Galactic Trade Task Force.",
			"Are you able to receive my transmission?"
			]
	},
	{
		"s": "UNKNOWN",
		"t":[
		"Oh thank god! Yes! Yes, we can pick up your transmission agent...Mars.", 
		"This is radio operator... Aeonia from the North-Central command bunker.", 
		"So the GTTF picked up our distress call? We need backup ASAP."
		]
	},
	{
		"s": "MARS",
		"t":[
		"Unfortunately, I am all the backup you get for now.",
		"The distress call could not be fully deciphered so I am only here as recon for the area.",
		"...",
		"Care to explain what I was just attacked by moments ago?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"...we were forced to encrypt our message in case it was intercepted.",
		"We...we don't know what we are fighting against.",
		"No records of these creatures exist but they seem to be intelligent enough to be able to intercept and disrupt our comm systems.",
		"We haven't been able to send any transmissions off-world since the distress call."
		]
	},
	{
		"s": "MARS",
		"t":[
		"That explains why I lost contact with HQ... how are we communicating right now?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"We have been sending out messages on all frequencies regularly since main comms cut out.",
		"You are the first response we have had back."
		]
	},
	{
		"s": "MARS",
		"t":[
		"You mentioned a base. Are you able to track my position or guide me there?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Negative. We have no systems online that can track your position.",
		"However, you should be able to follow the radar waypoints back to base. That's how all our comms get transmitted on-world."
		]
	},
	{
		"s": "MARS",
		"t":[
		"Great! And just exactly how long do you think that might take?"
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Oh anywhere between a few hours to a few days or weeks."
		]
	},
	{
		"s": "MARS",
		"t":[
		"....thanks. Very useful."
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"Of course! You're welcome."
		]
	},
	{
		"s": "AEONIA",
		"t":[
		"But you might want to get moving agent Mars. I don't know if you can tell, but we could really use your help. If you are not too busy that is."
		]
	},
	{
		"s": "MARS",
		"t":[
		"...on it"
		]
	},

]

func _ready():
	start(text1)
