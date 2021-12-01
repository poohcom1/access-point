

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
Mars: "Landed and ready to proceed"
Mars: "HQ do you read me?"
Mars: "This is agent 067-Mars to all callsigns on this frequency", "Does anyone copy?"
Mars: "Shit!", "Stay on comms Agent Mars they said"
Mars: "Proceeding to designated pickup position under auxiliary protocol 6B", "I will come back to haunt your asses if you write me off as dead before I make it"

"""
"""
Unknown: "jlsdfe...oihieifje....ard...ars...mars come in over!"
Mars: "This is Mars over", "Damn!", "I thought I lost you guys!"
HQ.: "Affirmative, there is some serious on-world jamming going on in this world"
Mars: "I'll say", "You had me worried for a bit", "I have been fighting non-stop here"
HQ: "We quite enjoyed the silence honestly"
Mars: "I am sure you did", "Did we break through?"
HQ: "Unsure", "This could be a temporary state", "We have been getting more stable but there have been too many spikes to keep up sustained comms"
Aeonia: "Come in Mars", "The comms seem to be very clear now", "You must be almost to the base", "Just a little more"
Mars: "Copy that Aeonia", "Please hold for a minute"
HQ: "Mars you have strayed from the original LZ course", "Proceed to the designated coordinates as per your briefing", "We need you out of there for a proper debriefing", "Whatever it is you are fighting, we need to figure out what they are and what they want first"
Mars.: "HQ, I have reason to believe I am close to the command bunker the distress call was sent from", "I will proceed there before heading to the LZ"
HQ: "Negative Mars", "We need you to follow protocol", "Besides, we have deciphered more of the distress call", "It seems to be from a certain Commander Volas who reported that the bunker had been infiltrated and overrun" 
"""
"""
Mars: "..."
HQ: "...Mars?"
Mars: "... this was in the initial transmission?"
HQ: "Affirmative", "There are mentions of creatures capable of mimicking speech but that has yet to be confirmed with our database but the distress call was clear on the point of the base having fallen"
Aeonia: "Hey, are you still there?", "Commander Volas wants to talk to you", "It seems he quite likes you huh?"
Volas: "Mars, I heard you are making progress and almost here", "We have cleared the hostile camps near the base", "Contact us when you get here and we will open the main entrance for you"
HQ: "From the transmission itself, we can assume that the base fell, and the commander managed to send out the transmission as a dying message in hopes that it will be able to get off world", "It was an unlikely bet, but it worked, and he managed to time it just right for us to receive it", "However, we need you on your guard as the base is likely to be a stronghold for whatever the fuck overran this planet", "For now, follow the coordinates for the LZ so we can regroup first"
Mars: "....."
Aeonia: "Hey, you haven't responded", "Is everything ok?", "Are you heading towards the base?"
"""


with open("dia.txt", "w") as fp:
    fp.write(parse(str))
