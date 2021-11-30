

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
Aeonia: "uoijf...hello test", "ah is this better now?"
Mars: "Significantly", "The comms seem to be getting better"
Aeonia: "Yes it seems so", "Surprisingly, your brute force approach to clearing out hostiles near radars seems to be working", "Don't know how though", "But the next area should be easier to handle now that the hostiles seem to be cleared out"
Mars: "You're welcome by the way"
Aeonia: "Not until you get to the command bunker"
"""


with open("dia.txt", "w") as fp:
    fp.write(parse(str))
