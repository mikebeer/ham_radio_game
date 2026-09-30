"""QSO scripts for levels 2 (rag-chew) and 3 (DX / contest).
Same schema as build_content.qso(). Correct choice is always index 0."""
from build_content import L


def qso_levels():
    lvl2 = [
        {"id": "answer",
         "them": L("CQ CQ CQ, this is {other}, {other}, calling CQ and listening. K.",
                   "CQ CQ CQ, hier ist {other}, {other}, rufe CQ und höre. Kommen."),
         "prompt": L("Answer his CQ call with both callsigns, phonetics optional.",
                     "Antworte auf seinen CQ-Ruf mit beiden Rufzeichen, Buchstabieren ist optional."),
         "choices": [L("{other} de {my}, {my}. K.", "{other} de {my}, {my}. Kommen."),
                     L("Break break, 10-4 good buddy, what's your twenty?", "Break break, 10-4 guter Freund, wo steckst du?"),
                     L("{other}, {other}, {other}. Come in.", "{other}, {other}, {other}. Kommen.")], "c": 0},
        {"id": "exchange",
         "them": L("{my} de {other}. Thanks for the call, you are 57 here. My name is {pname}, QTH {pqth}. I am running 50 watts into a dipole. Weather is sunny and warm. How copy? K.",
                   "{my} de {other}. Danke für den Anruf, du bist hier 57. Mein Name ist {pname}, QTH {pqth}. Ich fahre 50 Watt auf einen Dipol. Wetter ist sonnig und warm. Wie hörst du mich? Kommen."),
         "prompt": L("Answer every item: confirm, give his report, your name, QTH, rig and weather.",
                     "Beantworte jeden Punkt: bestätige, gib seinen Rapport, deinen Namen, QTH, Station und Wetter durch."),
         "choices": [L("{other} de {my}. R R, thanks {pname}. Your report is 57. My name is {name}. Your QTH {pqth} is copied. Fine business on 50 watts. Weather here is cloudy. K.",
                       "{other} de {my}. Roger, danke {pname}. Dein Rapport ist 57. Mein Name ist {name}. Dein QTH {pqth} ist notiert. Schön, mit 50 Watt. Wetter hier ist bewölkt. Kommen."),
                     L("{other} de {my}. You are 59, 10-4. My handle is {name}. Over and out.",
                       "{other} de {my}. Du bist 59, 10-4. Mein Handle ist {name}. Over and out."),
                     L("R, thanks. I am {name}. Weather is cloudy. K.",
                       "Verstanden, danke. Ich bin {name}. Wetter ist bewölkt. Kommen.")], "c": 0},
        {"id": "sign_off",
         "them": L("{my} de {other}. Thanks for the nice chat, {name}. Please confirm by QSL card. 73 and all the best. {my} de {other}, K.",
                   "{my} de {other}. Danke für das nette Gespräch, {name}. Bitte bestätige per QSL-Karte. 73 und alles Gute. {my} de {other}, Kommen."),
         "prompt": L("Confirm the QSL and close properly with 73 and both callsigns.",
                     "Bestätige die QSL und beende korrekt mit 73 und beiden Rufzeichen."),
         "choices": [L("{other} de {my}. QSL, thanks {pname}, I will send my card. 73 and good DX! {other} de {my}, SK.",
                       "{other} de {my}. QSL, danke {pname}, ich schicke meine Karte. 73 und gutes DX! {other} de {my}, Ende."),
                     L("Over and out, 10-4, catch you on the flip side!", "Over and out, 10-4, bis zur nächsten Runde!"),
                     L("73, bye bye.", "73, tschüss.")], "c": 0},
    ]
    lvl3 = [
        {"id": "answer",
         "them": L("CQ DX, CQ DX, this is {other}, {other}. Listening up 5. QRZ?",
                   "CQ DX, CQ DX, hier ist {other}, {other}. Höre up 5. QRZ?"),
         "prompt": L("He listens up 5 kHz (split). Call him once, short, on the right frequency.",
                     "Er hört 5 kHz höher (Split). Rufe ihn kurz und einmal auf der richtigen Frequenz."),
         "choices": [L("{my}. (Calling up 5, callsign only.)", "{my}. (Rufe up 5, nur das Rufzeichen.)"),
                     L("{other}, {other}, {other}, please answer me, I am a new station, {other} de {my}, pse pse pse.",
                       "{other}, {other}, {other}, bitte antworte mir, ich bin eine neue Station, {other} de {my}, bitte bitte bitte."),
                     L("{my}. (Calling on his own frequency, on top of him.)", "{my}. (Rufe auf seiner eigenen Frequenz, mitten in sein Signal.)")], "c": 0},
        {"id": "exchange",
         "them": L("{my}, you are 59 001. QRZ? Again please, your report? K.",
                   "{my}, du bist 59 001. QRZ? Noch einmal bitte, dein Rapport? Kommen."),
         "prompt": L("He asks you to repeat. Send your report and serial number.",
                     "Er bittet um Wiederholung. Gib Rapport und Seriennummer durch."),
         "choices": [L("{other}, you are 59 001. I say again, 59 002. {my}.",
                       "{other}, du bist 59 001. Ich wiederhole, 59 002. {my}."),
                     L("Pardon? What? Say it again slowly please, I did not get anything.",
                       "Wie bitte? Was? Sag es bitte nochmal langsam, ich habe nichts verstanden."),
                     L("59 59 59 59 59 59, over.", "59 59 59 59 59 59, over.")], "c": 0},
        {"id": "sign_off",
         "them": L("{my}, QSL 002, thanks. Time is 1432 UTC. I will upload to LoTW. 73! {other}.",
                   "{my}, QSL 002, danke. Zeit ist 1432 UTC. Ich lade auf LoTW hoch. 73! {other}."),
         "prompt": L("Confirm the log, say thanks and close briefly.",
                     "Bestätige das Log, bedanke dich und beende kurz."),
         "choices": [L("{other}, QSL, 1432 UTC, thanks for the contact. LoTW confirmed. 73! {my}.",
                       "{other}, QSL, 1432 UTC, danke für den Kontakt. LoTW bestätigt. 73! {my}."),
                     L("Great, see you later, time was half past two local, bye!",
                       "Super, bis später, Zeit war halb drei Ortszeit, tschüss!"),
                     L("Over and out, good luck with the contest!", "Over and out, viel Glück beim Contest!")], "c": 0},
    ]
    return {2: {"steps": lvl2}, 3: {"steps": lvl3}}


if __name__ == "__main__":
    d = qso_levels()
    for k, v in d.items():
        assert [s["id"] for s in v["steps"]] == ["answer", "exchange", "sign_off"]
        for s in v["steps"]:
            assert s["c"] == 0 and len(s["choices"]) == 3
    print("ok")
