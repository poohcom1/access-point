

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
Unknown: "sdkjfie...eelloa.... Hello! Hello! Check!",  "Is anyone on this comm?", "Can anyone hear me? Over"
Mars: "This is agent 067-Mars with the Galactic Trade Task Force”, "Are you able to receive my transmission?"
Unknown: "Oh thank god!", "Yes! Yes, we can pick up your transmission agent...", "This is radio operator...Aeonia from the North-Central command bunker", "So the GTTF picked up our distress call?", "We need backup ASAP"
Mars: "Unfortunately, I am all there is", "This is a recon mission in order to verify the distress call. I need all the information you have", "Why was the call encrypted?"
Aeonia: "...we were forced to encrypt our message in case it was intercepted", "As for other information, I don't have much", "No records of these creatures exist but they seem to be intelligent enough to be able to intercept and disrupt our comm systems both on and off-world" 
Mars: "That explains why I lost contact with HQ...", "how are we communicating right now?"
Aeonia: "We have been sending out messages on all frequencies regularly since main comms cut out after the first distress call", "You are the first response we have had back"
Mars: "Ok", "You mentioned a base", "Are you able to track my position or guide me there?"
Aeonia: "Negative", "We have no systems online that can track your position", "However, you should be able to follow the radar waypoints back to base", "That's how all our comms get transmitted on-world"
Mars: "And just exactly how long do you think that might take?"
Aeonia: "Anywhere between a few hours to a few days or weeks"
Mars: "...okay then"



"""


with open("dia.txt", "w") as fp:
    fp.write(parse(str))
