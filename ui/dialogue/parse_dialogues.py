

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
Aeonia: "We are still stretched thin here and some backup would be much appreciated"
Mars: "Working on it", "How many of you are at the base?"
Aeonia: "...about 10 of us are still alive and able to fight", "The rest...didn't make it"
Mars: "..."
Mars: "Are you the highest ranking officer?"
Aeonia: "....no", "my CO is still alive"
Mars: "Would you mind putting him on?"
Aeonia: "..."
Aeonia: "He is currently on patrol around the bunker", "He isn't here at the moment"
Mars: "hmm", "No matter", "But I would like to confirm a few things with him next time", "His rank will allow him to decide how the GTTF proceeds"
Aeonia: "...I see... I will try to contact you when he gets back", "Over."
Mars: "Gotcha", "Over"

"""


with open("dia.txt", "w") as fp:
    fp.write(parse(str))
