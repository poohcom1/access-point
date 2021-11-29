

def parse(text):
    text_json = ""
    text_split = text.split("\n")

    for line in text_split:
        if line == "": continue
        line_split = line.split(": ")

        speaker = line_split[0].upper()

        dia = line_split[1]

        text_json += '\t{\n\t\t"s": "%s",\n\t\t"t":[\n\t\t%s\n\t\t]\n\t},\n' % (speaker, dia)

    return text_json

str = """
Mars: "This is agent 067-Mars with the Galactic Trade Task Force. Are you able to receive my transmission?"
Unknown: "Oh thank god! Yes! Yes, we can pick up your transmission agent...Mars. This is radio operator...Aeonia from the North-Central command bunker. So the GTTF picked up our distress call? We need backup ASAP."
Mars: "Unfortunately, I am all the backup you get for now. The distress call could not be fully deciphered so I am only here as recon for the area. Care to explain what I was just attacked by moments ago?"
Aeonia: "...we were forced to encrypt our message in case it was intercepted. We...we don't know what we are fighting against. No records of these creatures exist but they seem to be intelligent enough to be able to intercept and disrupt our comm systems. We haven't been able to send any transmissions off-world since the distress call."
Mars: "That explains why I lost contact with HQ...how are we communicating right now?"
Aeonia: "We have been sending out messages on all frequencies regularly since main comms cut out. You are the first response we have had back."
Mars: "You mentioned a base. Are you able to track my position or guide me there?"
Aeonia: "Negative. We have no systems online that can track your position. However, you should be able to follow the radar waypoints back to base. That's how all our comms get transmitted on-world."
Mars: "Great! And just exactly how long do you think that might take?"
Aeonia: "Oh anywhere between a few hours to a few days or weeks."
Mars: "....thanks. Very useful."
Aeonia: "Of course! You're welcome."
Aeonia: "But you might want to get moving agent Mars. I don't know if you can tell, but we could really use your help. If you are not too busy that is."
Mars: "...on it"

"""


with open("dia.txt", "w") as fp:
    fp.write(parse(str))
