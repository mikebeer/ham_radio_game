#!/usr/bin/env python3
"""Generates the game's content JSON (content/**.json) so en/de text stays in one place.

Run:  python3 tools/build_content.py [path/to/50ohm-contents-dl]

* German legal questions are copied verbatim from the official Bundesnetzagentur catalogue
  (3rd edition, March 2024, DL-DE-BY-2.0) as shipped in DARC-e-V/50ohm-contents-dl. In that
  catalogue answer A is the correct one; the game shuffles the answers at runtime.
  English versions are UNOFFICIAL translations written for this game.
* Everything else (lessons, technical practice questions, primers for other countries) is
  original text written for this game.
"""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENTS = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "src", "50ohm-contents-dl")


def L(en, de):
    return {"en": en, "de": de}


def Q(qen, qde, aen, ade, c=0):
    """Question. Answers are given with the correct one FIRST (c = index of correct)."""
    return {"q": L(qen, qde), "a": [L(x, y) for x, y in zip(aen, ade)], "c": c}


def dump(path, obj):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=1)
    print("wrote", path)


# ----------------------------------------------------------------------------------------
# UI strings
# ----------------------------------------------------------------------------------------
UI = {
    "app.title": ("CQ Quest", "CQ Quest"),
    "app.tagline": ("Become a ham radio operator", "Werde Funkamateur"),
    "splash.start": ("Press to start", "Zum Starten drücken"),
    "common.next": ("Next", "Weiter"),
    "common.back": ("Back", "Zurück"),
    "common.skip": ("Skip", "Überspringen"),
    "common.continue": ("Continue", "Los geht's"),
    "common.check": ("Check", "Prüfen"),
    "common.retry": ("Try again", "Nochmal"),
    "common.close": ("Close", "Schließen"),
    "common.correct": ("Correct! Well done.", "Richtig! Gut gemacht."),
    "common.wrong": ("Not quite. The right answer is highlighted.", "Leider falsch. Die richtige Antwort ist markiert."),
    "common.score": ("%d of %d correct", "%d von %d richtig"),
    "common.locked": ("Locked", "Gesperrt"),
    "intro.1.t": ("Somewhere out there, someone is calling CQ.", "Irgendwo da draußen ruft jemand CQ."),
    "intro.1.b": ("Radio waves cross oceans without wires or the internet. Amateur radio lets you send them yourself, once you know the rules and how to build a station.",
                  "Funkwellen überqueren Ozeane, ganz ohne Kabel und Internet. Mit Amateurfunk sendest du sie selbst, sobald du die Regeln kennst und eine Station aufbauen kannst."),
    "intro.2.t": ("Your own radio shack", "Deine eigene Funkbude"),
    "intro.2.b": ("Every part you learn about, from power supply to antenna, appears in your shack. Answer the questions and the part is yours.",
                  "Jedes Teil, über das du etwas lernst, vom Netzteil bis zur Antenne, erscheint in deiner Funkbude. Beantworte die Fragen und das Teil gehört dir."),
    "intro.3.t": ("Four goals", "Vier Ziele"),
    "intro.3.b": ("Learn the rules of your country. Build your shack. Make your first contact. Learn Morse code.",
                  "Lerne die Regeln deines Landes. Baue deine Funkbude auf. Führe dein erstes Funkgespräch. Lerne Morsen."),
    "intro.goal1": ("Know the rules", "Die Regeln kennen"),
    "intro.goal2": ("Build your radio shack", "Deine Funkbude bauen"),
    "intro.goal3": ("Make your first contact", "Dein erstes Funkgespräch"),
    "intro.goal4": ("Learn Morse code", "Morsen lernen"),
    "setup.title": ("Who are you?", "Wer bist du?"),
    "setup.sub": ("Pick an avatar, a name, your country and language.", "Wähle Avatar, Namen, Land und Sprache."),
    "setup.name": ("Your name", "Dein Name"),
    "setup.name_hint": ("Type your name", "Namen eingeben"),
    "setup.country": ("Country (sets the legal chapter)", "Land (bestimmt das Rechtskapitel)"),
    "setup.language": ("Language", "Sprache"),
    "country.de": ("Germany", "Deutschland"),
    "country.ch": ("Switzerland", "Schweiz"),
    "country.at": ("Austria", "Österreich"),
    "country.us": ("United States", "USA"),
    "country.uk": ("United Kingdom", "Großbritannien"),
    "hub.goals": ("Your goals", "Deine Ziele"),
    "hub.goal1": ("Know the rules", "Regeln kennen"),
    "hub.goal2": ("Build your shack", "Funkbude bauen"),
    "hub.goal3": ("First contact (QSO)", "Erstes Funkgespräch (QSO)"),
    "hub.goal4": ("Morse code", "Morsen"),
    "hub.goal1.sub": ("%s · %s", "%s · %s"),
    "hub.goal2.sub": ("Earn each part by learning", "Jedes Teil durch Lernen verdienen"),
    "hub.goal3.sub": ("Needs a working shack", "Braucht eine funktionierende Funkbude"),
    "hub.goal4.sub": ("Koch method", "Koch-Methode"),
    "hub.goal1.prog": ("%d / %d lessons", "%d / %d Lektionen"),
    "hub.goal2.prog": ("%d / %d parts", "%d / %d Teile"),
    "hub.goal4.prog": ("Level %d / %d", "Stufe %d / %d"),
    "hub.goal3.prog": ("%d / %d steps", "%d / %d Schritte"),
    "hub.shack": ("Shack %d / %d", "Funkbude %d / %d"),
    "hub.callsign": ("Practice callsign: %s", "Übungsrufzeichen: %s"),
    "hub.tip_locked": ("Finish the rules and build the transceiver, antenna, microphone and power supply first.",
                       "Schließe zuerst die Regeln ab und baue Transceiver, Antenne, Mikrofon und Netzteil."),
    "hub.click_slot": ("Click an empty slot to learn about that part.", "Klicke auf einen leeren Platz, um das Teil kennenzulernen."),
    "hub.owned": ("Already in your shack. Tune in!", "Schon in deiner Funkbude. Viel Spaß beim Funken!"),
    "hub.about": ("About", "Info"),
    "hub.callsign_pending": ("Callsign: pending", "Rufzeichen: offen"),
    "hub.reset_sure": ("Sure?", "Sicher?"),
    "hub.reset": ("New game", "Neues Spiel"),
    "part.psu": ("Power supply", "Netzteil"),
    "part.antenna": ("Antenna", "Antenne"),
    "part.transceiver": ("Transceiver", "Transceiver"),
    "part.mic": ("Microphone", "Mikrofon"),
    "part.speaker": ("Speaker", "Lautsprecher"),
    "part.swr": ("SWR meter", "SWR-Meter"),
    "part.key": ("Morse key", "Morsetaste"),
    "part.logbook": ("Logbook", "Logbuch"),
    "legal.review": ("Read the lessons", "Lektionen lesen"),
    "legal.title": ("Goal 1 · Know the rules", "Ziel 1 · Regeln kennen"),
    "legal.sub": ("%s · Lesson %d of %d", "%s · Lektion %d von %d"),
    "legal.quiz_sub": ("%s · Quiz", "%s · Quiz"),
    "legal.question": ("QUESTION %d / %d", "FRAGE %d / %d"),
    "legal.start_quiz": ("Start the quiz", "Quiz starten"),
    "legal.passed": ("You know the rules of %s. Goal 1 complete!", "Du kennst die Regeln für %s. Ziel 1 geschafft!"),
    "legal.failed": ("You need %d correct answers. Read the lessons again and retry.", "Du brauchst %d richtige Antworten. Lies die Lektionen nochmal und versuche es erneut."),
    "legal.primer": ("Learning primer, not an official exam pool. Check your regulator's current rules.",
                     "Lern-Überblick, kein offizieller Fragenkatalog. Prüfe die aktuellen Regeln deiner Behörde."),
    "legal.official": ("Official question catalogue", "Offizieller Fragenkatalog"),
    "legal.translation": ("English text is an unofficial translation.", "Der englische Text ist eine inoffizielle Übersetzung."),
    "build.title": ("Goal 2 · Build your shack", "Ziel 2 · Funkbude bauen"),
    "build.sub": ("%s · Question %d of %d", "%s · Frage %d von %d"),
    "build.lesson_sub": ("%s · Learn first", "%s · Erst lernen"),
    "build.unlocked": ("NEW PART UNLOCKED", "NEUES TEIL FREIGESCHALTET"),
    "build.shack_count": ("Shack", "Funkbude"),
    "build.next_part": ("Next part: %s", "Nächstes Teil: %s"),
    "build.all_done": ("Your shack is complete!", "Deine Funkbude ist komplett!"),
    "build.back": ("Back to the shack", "Zurück zur Funkbude"),
    "build.start_quiz": ("Take the quiz", "Zum Quiz"),
    "build.failed": ("You need %d of %d. Have another look at the lesson.", "Du brauchst %d von %d. Sieh dir die Lektion nochmal an."),
    "qso.title": ("Goal 3 · First contact", "Ziel 3 · Erstes Funkgespräch"),
    "qso.sub": ("Practice a real QSO, step by step", "Übe ein echtes QSO, Schritt für Schritt"),
    "qso.tune": ("Tune in", "Abstimmen"),
    "qso.tune_hint": ("Turn the dial with the slider until you hear the station.", "Drehe mit dem Regler, bis du die Station hörst."),
    "qso.signal": ("Signal", "Signal"),
    "qso.found": ("Found a station! Now answer them.", "Station gefunden! Jetzt antworte ihr."),
    "qso.conversation": ("The conversation", "Das Gespräch"),
    "qso.your_turn": ("Your turn: pick the right reply", "Du bist dran: wähle die richtige Antwort"),
    "qso.step1": ("Find a station", "Station finden"),
    "qso.step2": ("Answer the call", "Anruf beantworten"),
    "qso.step3": ("Exchange details", "Daten austauschen"),
    "qso.step4": ("Spell your callsign", "Rufzeichen buchstabieren"),
    "qso.step5": ("Say 73", "73 sagen"),
    "qso.wrong": ("Not the best reply. Try another one.", "Nicht die beste Antwort. Versuche eine andere."),
    "qso.done": ("Your first QSO is in the log! 73!", "Dein erstes QSO steht im Logbuch! 73!"),
    "qso.replay": ("Practice again", "Nochmal üben"),
    "qso.need": ("You need the rules, transceiver, antenna, microphone and power supply first.",
                 "Du brauchst zuerst die Regeln, Transceiver, Antenne, Mikrofon und Netzteil."),
    "morse.title": ("Goal 4 · Morse code", "Ziel 4 · Morsen"),
    "morse.sub": ("Koch method · Level %d of %d · %d WPM", "Koch-Methode · Stufe %d von %d · %d WPM"),
    "morse.listen": ("LISTEN AND PICK WHAT YOU HEAR", "HÖREN UND AUSWÄHLEN"),
    "morse.play": ("Play again", "Nochmal hören"),
    "morse.send": ("Send it yourself", "Selbst geben"),
    "morse.hold": ("Hold SPACE or click", "SPACE halten oder klicken"),
    "morse.known": ("Letters you know", "Bekannte Zeichen"),
    "morse.round": ("Character %d / %d", "Zeichen %d / %d"),
    "morse.levelup": ("Level up! New characters unlocked.", "Stufe geschafft! Neue Zeichen freigeschaltet."),
    "morse.levelfail": ("You need %d of %d. Listen again.", "Du brauchst %d von %d. Hör nochmal hin."),
    "morse.you_sent": ("You sent", "Du hast gegeben"),
    "morse.clear": ("Clear", "Löschen"),
    "morse.practice_send": ("Try to send", "Versuche zu geben"),
    "about.title": ("About CQ Quest", "Über CQ Quest"),
    "about.body": ("CQ Quest is a free game that shows how much fun amateur radio is.\n\nGerman lessons and questions: 50ohm.de, DARC e.V. (CC BY 4.0) and the Bundesnetzagentur question catalogue, 3rd edition, March 2024 (DL-DE-BY-2.0). Changes: shortened, English translation added.\n\nAustrian topics: Fragenkatalog für den Amateurfunkdienst, BMVIT, 2009.\n\nOther text is original. Practice callsigns are examples only.",
                   "CQ Quest ist ein freies Spiel, das zeigt, wie viel Spaß Amateurfunk macht.\n\nDeutsche Lektionen und Fragen: 50ohm.de, DARC e.V. (CC BY 4.0) und der Fragenkatalog der Bundesnetzagentur, 3. Auflage, März 2024 (DL-DE-BY-2.0). Änderungen: gekürzt, englische Übersetzung ergänzt.\n\nÖsterreichische Themen: Fragenkatalog für den Amateurfunkdienst, BMVIT, 2009.\n\nAlle anderen Texte sind eigene Texte. Übungsrufzeichen sind nur Beispiele."),
}

# ----------------------------------------------------------------------------------------
# Legal packs
# ----------------------------------------------------------------------------------------

def load_de_questions():
    ids = "VC101 VC104 VC107 VC108 VC110 VC111 VC112 VC114 VC116 VD205 VD207 VD208 VD301 VD303 VD306".split()
    path = os.path.join(CONTENTS, "contents", "questions", "fragenkatalog3b.json")
    d = json.load(open(path, encoding="utf-8"))
    found = {}

    def walk(s):
        for q in s.get("questions", []):
            found[q["number"]] = q
        for c in s.get("sections", []):
            walk(c)

    for s in d["sections"]:
        walk(s)
    return [found[i] for i in ids]


EN_DE = {  # unofficial English translations, keyed by catalogue number: (question, [a, b, c, d])
    "VC101": ("Which law is the legal basis for taking part in amateur radio in Germany?",
              ["The Amateur Radio Act (AFuG)", "The Telecommunications Act", "The Act on making radio equipment available on the market", "The Act on electromagnetic compatibility of equipment"]),
    "VC104": ("Which German authority carries out the tasks arising from the Amateur Radio Act (AFuG) and Ordinance (AFuV)?",
              ["The Federal Network Agency (Bundesnetzagentur)", "The Federal Physical-Technical Institute", "The Federal Post and Telecommunications Office", "The Federal Agency for digital radio of authorities and security organisations"]),
    "VC107": ("May a radio amateur temporarily pass their licence to another person? The licence is ...",
              ["tied to the person named on it and cannot be transferred.", "transferable to people in the same household after notifying the Bundesnetzagentur.", "transferable if the other person is a radio amateur who passed the exam.", "transferable to foreign radio amateurs staying in Germany for a short time."]),
    "VC108": ("Does the Amateur Radio Act require a minimum age for a licence?",
              ["The Act sets no minimum age.", "The minimum age to apply is 15.", "From class E the Act sets a minimum age of 16.", "For class A you must be of legal age."]),
    "VC110": ("What applies to frequency use? A radio amateur may transmit with their station ...",
              ["on the frequencies allocated to the amateur radio service.", "on all frequencies permitted in their ITU region.", "on any frequency as long as other services are not disturbed.", "during an emergency-radio exercise also on frequencies not allocated to amateur radio."]),
    "VC111": ("Which stations may a radio amateur communicate with?",
              ["Only other amateur stations", "All stations active on the amateur bands", "Other amateur stations and stations of authorities and security organisations", "Other amateur stations and stations of the aeronautical or maritime service"]),
    "VC112": ("May a radio amateur relay messages that are not about amateur radio for or to third parties?",
              ["Only in emergencies and disasters", "No, never", "Yes, at any time", "Only when asked by the local office of the Bundesnetzagentur"]),
    "VC114": ("May an amateur station be operated for commercial purposes? An amateur station may ...",
              ["not be operated for commercial purposes.", "be operated commercially after registering a business with the callsign.", "be operated to provide telecommunications services professionally.", "be operated commercially after approval by the Bundesnetzagentur."]),
    "VC116": ("Which personal callsigns may a radio amateur use?",
              ["Only a callsign assigned to them by the Bundesnetzagentur", "Any callsign", "Only a callsign assigned by an amateur radio association", "When using someone else's station, the personal callsign of the station owner"]),
    "VD205": ("When must a radio amateur give their callsign?",
              ["At the start and end of every contact and at least every 10 minutes", "When asked by another station in the contact", "At least every 15 minutes during a contact", "At the latest 5 minutes into an uninterrupted transmission"]),
    "VD207": ("How can you recognise an amateur station on the air?",
              ["By its amateur radio callsign", "By the frequency range used", "By the emission mode used", "By the modulation"]),
    "VD208": ("Is a radio amateur entitled to a specific callsign?",
              ["No, there is no such entitlement.", "Yes, if it is not yet assigned.", "No, unless they have special personal reasons and the callsign is free.", "Yes, if it was assigned to them before."]),
    "VD301": ("What is training radio operation (Ausbildungsfunkbetrieb) for under the Amateur Radio Ordinance? It serves ...",
              ["the practical preparation for the technical exam for an amateur radio certificate.", "the sole demonstration of amateur radio operation.", "the trainee taking part in amateur radio without supervision.", "completing the radio amateur's skills in Morse telegraphy."]),
    "VD303": ("Non-amateurs may take part in training radio operation ...",
              ["only under direct guidance and supervision of a radio amateur with an assigned class A or E callsign.", "only at club stations under supervision of a class A or E amateur.", "also at weekends without special conditions.", "also without guidance and supervision of the training amateur."]),
    "VD306": ("Who must use the callsign suffix \"/T\" or \"/Trainee\" during training radio operation?",
              ["The trainee", "The trainer", "The trainee and the trainer", "The person responsible for the school station"]),
}


def de_pack():
    qs = []
    for q in load_de_questions():
        en_q, en_a = EN_DE[q["number"]]
        de_a = [q["answer_" + c].strip() for c in "abcd"]
        qs.append({"id": q["number"], "q": L(en_q, q["question"].strip()),
                   "a": [L(en_a[i], de_a[i]) for i in range(4)], "c": 0})
    lessons = [
        {"t": L("What amateur radio is", "Was Amateurfunk ist"),
         "b": L("Amateur radio is a radio service that radio amateurs use among themselves, for their own training and for technical experiments. The Amateur Radio Act (AFuG) is the legal basis in Germany. You may not use it for business, and you may only talk to other amateur stations.",
                "Amateurfunk ist ein Funkdienst, den Funkamateure untereinander, zur eigenen Weiterbildung und für technische Experimente nutzen. Rechtsgrundlage in Deutschland ist das Amateurfunkgesetz (AFuG). Für Geschäfte darfst du ihn nicht nutzen, und du sprichst nur mit anderen Amateurfunkstellen.")},
        {"t": L("Authority and licence", "Behörde und Zulassung"),
         "b": L("The Bundesnetzagentur looks after amateur radio. To become a radio amateur you pass an exam and get a licence with your own callsign. The licence belongs to you personally and cannot be handed over. The law sets no minimum age.",
                "Die Bundesnetzagentur kümmert sich um den Amateurfunk. Um Funkamateur zu werden, legst du eine Prüfung ab und bekommst eine Zulassung mit eigenem Rufzeichen. Die Zulassung gehört dir persönlich und kann nicht weitergegeben werden. Ein Mindestalter gibt es im Gesetz nicht.")},
        {"t": L("Your callsign", "Dein Rufzeichen"),
         "b": L("A callsign identifies your station. You say it at the start and end of every contact and at least every 10 minutes. You cannot demand a particular callsign. Use only the callsign assigned to you.",
                "Ein Rufzeichen kennzeichnet deine Station. Du nennst es am Anfang und am Ende jeder Funkverbindung und mindestens alle 10 Minuten. Auf ein bestimmtes Rufzeichen hast du keinen Anspruch. Benutze nur das dir zugeteilte Rufzeichen.")},
        {"t": L("What you may and may not do", "Was erlaubt ist und was nicht"),
         "b": L("Transmit only on frequencies allocated to amateur radio. Talk only to other amateur stations. Do not pass messages for third parties, except in emergencies and disasters. Do not operate for commercial purposes.",
                "Sende nur auf Frequenzen, die dem Amateurfunkdienst zugewiesen sind. Sprich nur mit anderen Amateurfunkstellen. Übermittle keine Nachrichten für Dritte, außer in Not- und Katastrophenfällen. Betreibe keinen Funk zu gewerblichen Zwecken.")},
        {"t": L("Training operation", "Ausbildungsfunkbetrieb"),
         "b": L("Beginners may try radio before their exam under direct guidance and supervision of a licensed amateur. The trainee adds \"/T\" to the callsign. It is meant to prepare you for the exam, not to replace it.",
                "Einsteiger dürfen vor der Prüfung unter unmittelbarer Anleitung und Aufsicht eines Funkamateurs Funkbetrieb erleben. Der Auszubildende hängt \"/T\" an das Rufzeichen. Das soll auf die Prüfung vorbereiten, nicht sie ersetzen.")},
    ]
    return {"country": "de", "status": "official", "callsign": "DN1ABC", "partner": "OE3XYZ", "partner_qth": L("Vienna", "Wien"),
            "licence": L("Class N (entry level)", "Klasse N (Einsteiger)"), "pass": 11,
            "source": L("50ohm.de, DARC e.V. (CC BY 4.0); Bundesnetzagentur question catalogue, 3rd ed. March 2024 (DL-DE-BY-2.0)",
                        "50ohm.de, DARC e.V. (CC BY 4.0); Fragenkatalog der Bundesnetzagentur, 3. Aufl. März 2024 (DL-DE-BY-2.0)"),
            "lessons": lessons, "questions": qs}


def primer(country, callsign, partner, partner_qth, licence, source, lessons, questions, pass_n):
    return {"country": country, "status": "primer", "callsign": callsign, "partner": partner, "partner_qth": partner_qth,
            "licence": licence, "pass": pass_n, "source": source, "lessons": lessons, "questions": questions}


def us_pack():
    lessons = [
        {"t": L("Amateur radio in the US", "Amateurfunk in den USA"),
         "b": L("The Federal Communications Commission (FCC) regulates amateur radio under Part 97 of its rules. The service is non-commercial: it is for personal enjoyment, self-training, emergency communication and technical experiments.",
                "Die Federal Communications Commission (FCC) regelt den Amateurfunk in Part 97 ihrer Vorschriften. Der Dienst ist nichtkommerziell: für persönliche Freude, Weiterbildung, Notfunk und technische Experimente.")},
        {"t": L("Licence classes and exams", "Lizenzklassen und Prüfungen"),
         "b": L("There are three classes: Technician (entry level), General and Amateur Extra. Exams are run by volunteer examiners coordinated by Volunteer Examiner Coordinators (VECs). Morse code is not tested.",
                "Es gibt drei Klassen: Technician (Einstieg), General und Amateur Extra. Die Prüfungen nehmen ehrenamtliche Prüfer ab, koordiniert von Volunteer Examiner Coordinators (VECs). Morsen wird nicht geprüft.")},
        {"t": L("Your callsign", "Dein Rufzeichen"),
         "b": L("The FCC assigns your callsign. You identify at the end of a communication and at least every 10 minutes during it.",
                "Die FCC teilt dein Rufzeichen zu. Du nennst es am Ende einer Verbindung und mindestens alle 10 Minuten währenddessen.")},
        {"t": L("What is not allowed", "Was nicht erlaubt ist"),
         "b": L("You may not use amateur radio for business, broadcast music, or send messages meant to hide their meaning. Be polite and avoid interfering with others.",
                "Du darfst Amateurfunk nicht für Geschäfte nutzen, keine Musik senden und keine Nachrichten verschleiern. Sei höflich und störe andere nicht.")},
        {"t": L("Check the details", "Details prüfen"),
         "b": L("Privileges depend on your class: a Technician has all privileges above 30 MHz and limited access to some HF bands. Always check the current FCC rules and the current question pool before your exam.",
                "Die Rechte hängen von der Klasse ab: Technician haben alle Rechte oberhalb von 30 MHz und begrenzten Zugang zu einigen Kurzwellenbändern. Prüfe vor der Prüfung immer die aktuellen FCC-Regeln und den aktuellen Fragenpool.")},
    ]
    qs = [
        Q("Which agency regulates amateur radio in the United States?", "Welche Behörde regelt den Amateurfunk in den USA?",
          ["The FCC", "The FAA", "The ARRL", "The NTSB"], ["Die FCC", "Die FAA", "Die ARRL", "Die NTSB"]),
        Q("How often must you identify your station during a conversation?", "Wie oft musst du dich während eines Gesprächs identifizieren?",
          ["At the end and at least every 10 minutes", "Only at the start", "Once per hour", "Only if someone asks"],
          ["Am Ende und mindestens alle 10 Minuten", "Nur am Anfang", "Einmal pro Stunde", "Nur auf Nachfrage"]),
        Q("Which is the entry-level licence class?", "Welche ist die Einsteiger-Lizenzklasse?",
          ["Technician", "Amateur Extra", "General", "Novice Plus"], ["Technician", "Amateur Extra", "General", "Novice Plus"]),
        Q("May you use amateur radio for your business communications?", "Darfst du Amateurfunk für geschäftliche Kommunikation nutzen?",
          ["No", "Yes, if you are polite", "Yes, on weekends", "Yes, with a special callsign"], ["Nein", "Ja, wenn du höflich bist", "Ja, am Wochenende", "Ja, mit besonderem Rufzeichen"]),
        Q("Who runs the licence exams?", "Wer nimmt die Lizenzprüfungen ab?",
          ["Volunteer examiners", "The post office", "Local police", "Commercial radio stations"], ["Ehrenamtliche Prüfer", "Die Post", "Die örtliche Polizei", "Kommerzielle Radiosender"]),
        Q("Is a Morse code test required today?", "Ist heute eine Morseprüfung erforderlich?",
          ["No", "Yes, at 5 WPM", "Yes, at 13 WPM", "Only for Technician"], ["Nein", "Ja, mit 5 WPM", "Ja, mit 13 WPM", "Nur für Technician"]),
    ]
    return primer("us", "KD2ABC", "W1XYZ", L("Boston", "Boston"), L("Technician (entry level)", "Technician (Einstieg)"),
                  L("Original primer based on FCC Part 97", "Eigener Überblick nach FCC Part 97"), lessons, qs, 5)


def uk_pack():
    lessons = [
        {"t": L("Amateur radio in the UK", "Amateurfunk in Großbritannien"),
         "b": L("Ofcom, the communications regulator, issues amateur radio licences. The service is for self-training, experiments and communicating with other amateurs. It is not for business.",
                "Ofcom, die Regulierungsbehörde, vergibt Amateurfunklizenzen. Der Dienst dient der Weiterbildung, Experimenten und dem Kontakt mit anderen Funkamateuren. Er ist nicht für Geschäfte gedacht.")},
        {"t": L("Three licence levels", "Drei Lizenzstufen"),
         "b": L("You can progress from Foundation to Intermediate to Full. You start with a Foundation exam. The Radio Society of Great Britain (RSGB) is the national society and supports training.",
                "Du kannst von Foundation über Intermediate zu Full aufsteigen. Du beginnst mit der Foundation-Prüfung. Die Radio Society of Great Britain (RSGB) ist der nationale Verband und unterstützt die Ausbildung.")},
        {"t": L("Callsign and etiquette", "Rufzeichen und Umgangsformen"),
         "b": L("Your licence comes with a callsign. Give it to identify your station, keep your messages appropriate and do not cause interference.",
                "Zu deiner Lizenz gehört ein Rufzeichen. Nenne es, um deine Station zu kennzeichnen, halte deine Nachrichten angemessen und störe niemanden.")},
        {"t": L("Power and limits", "Leistung und Grenzen"),
         "b": L("Each licence level has its own limits on power and frequencies. Foundation licence holders may use up to 10 watts.",
                "Jede Lizenzstufe hat eigene Grenzen für Leistung und Frequenzen. Foundation-Inhaber dürfen bis zu 10 Watt nutzen.")},
        {"t": L("Check the details", "Details prüfen"),
         "b": L("Licence terms change. Read the current Ofcom licence and RSGB guidance before you transmit.",
                "Lizenzbedingungen ändern sich. Lies vor dem Senden die aktuelle Ofcom-Lizenz und die Hinweise der RSGB.")},
    ]
    qs = [
        Q("Who issues amateur radio licences in the UK?", "Wer vergibt Amateurfunklizenzen in Großbritannien?",
          ["Ofcom", "The BBC", "The Post Office", "The police"], ["Ofcom", "Die BBC", "Die Post", "Die Polizei"]),
        Q("Which licence do beginners take first?", "Welche Lizenz machen Einsteiger zuerst?",
          ["Foundation", "Full", "Intermediate", "Advanced"], ["Foundation", "Full", "Intermediate", "Advanced"]),
        Q("May you use your amateur station for business?", "Darfst du deine Amateurfunkstelle für Geschäfte nutzen?",
          ["No", "Yes, always", "Yes, on VHF only", "Yes, at night"], ["Nein", "Ja, immer", "Ja, nur auf UKW", "Ja, nachts"]),
        Q("What is the maximum power for a Foundation licence?", "Wie hoch ist die Höchstleistung bei der Foundation-Lizenz?",
          ["10 watts", "400 watts", "1000 watts", "1 watt"], ["10 Watt", "400 Watt", "1000 Watt", "1 Watt"]),
        Q("How is a station identified on air?", "Woran erkennt man eine Station im Funkbetrieb?",
          ["By its callsign", "By its colour", "By its antenna", "By its power supply"], ["Am Rufzeichen", "An ihrer Farbe", "An ihrer Antenne", "An ihrem Netzteil"]),
        Q("Which body is the UK's national amateur radio society?", "Welcher Verband ist der nationale Amateurfunkverband Großbritanniens?",
          ["RSGB", "ARRL", "DARC", "USKA"], ["RSGB", "ARRL", "DARC", "USKA"]),
    ]
    return primer("uk", "M7ABC", "G3XYZ", L("London", "London"), L("Foundation (entry level)", "Foundation (Einstieg)"),
                  L("Original primer based on Ofcom / RSGB information", "Eigener Überblick nach Ofcom / RSGB"), lessons, qs, 5)


def ch_pack():
    lessons = [
        {"t": L("Amateur radio in Switzerland", "Amateurfunk in der Schweiz"),
         "b": L("The Federal Office of Communications (OFCOM, BAKOM) is responsible for radio in Switzerland. Swiss amateur callsigns start with HB.",
                "Das Bundesamt für Kommunikation (BAKOM) ist in der Schweiz für den Funk zuständig. Schweizer Amateurfunkrufzeichen beginnen mit HB.")},
        {"t": L("Entry and full class", "Einsteiger- und Vollklasse"),
         "b": L("There is an entry-level class with callsigns starting HB3 and a full class with HB9. The national society is the USKA (Union of Swiss Shortwave Amateurs).",
                "Es gibt eine Einsteigerklasse mit Rufzeichen HB3 und eine Vollklasse mit HB9. Der nationale Verband ist die USKA (Union Schweizerischer Kurzwellen-Amateure).")},
        {"t": L("Not for business", "Nicht für Geschäfte"),
         "b": L("Amateur radio is a hobby service. You do not use it for commercial messages or to pass messages for others in place of a normal service.",
                "Amateurfunk ist ein Hobbydienst. Du nutzt ihn nicht für geschäftliche Nachrichten oder um Nachrichten für andere anstelle eines normalen Dienstes weiterzugeben.")},
        {"t": L("Operating abroad", "Funken im Ausland"),
         "b": L("A CEPT licence lets you operate temporarily in many other European countries as a guest. Always check the rules of the country you visit.",
                "Mit einer CEPT-Lizenz darfst du in vielen anderen europäischen Ländern vorübergehend als Gast funken. Prüfe immer die Regeln des Gastlandes.")},
        {"t": L("Check the details", "Details prüfen"),
         "b": L("Details of exams and rules change. Ask the USKA or check the BAKOM website for the current requirements.",
                "Prüfungen und Regeln ändern sich. Frage die USKA oder sieh auf der BAKOM-Webseite nach den aktuellen Anforderungen.")},
    ]
    qs = [
        Q("Which authority is responsible for radio in Switzerland?", "Welche Behörde ist in der Schweiz für den Funk zuständig?",
          ["BAKOM (OFCOM)", "The Post", "SBB", "MeteoSwiss"], ["BAKOM", "Die Post", "SBB", "MeteoSchweiz"]),
        Q("Swiss amateur callsigns start with ...", "Schweizer Amateurfunkrufzeichen beginnen mit ...",
          ["HB", "DL", "OE", "G"], ["HB", "DL", "OE", "G"]),
        Q("Which callsign prefix belongs to the entry-level class?", "Welches Rufzeichenpräfix gehört zur Einsteigerklasse?",
          ["HB3", "HB9", "HB0", "HB1"], ["HB3", "HB9", "HB0", "HB1"]),
        Q("What is the USKA?", "Was ist die USKA?",
          ["The Swiss national amateur radio society", "A Swiss TV station", "The exam authority", "A radio manufacturer"],
          ["Der Schweizer Amateurfunkverband", "Ein Schweizer Fernsehsender", "Die Prüfungsbehörde", "Ein Funkgerätehersteller"]),
        Q("May you use amateur radio for commercial messages?", "Darfst du Amateurfunk für geschäftliche Nachrichten nutzen?",
          ["No", "Yes, if short", "Yes, on 2 m", "Yes, for friends"], ["Nein", "Ja, wenn kurz", "Ja, auf 2 m", "Ja, für Freunde"]),
        Q("What does a CEPT licence allow?", "Was erlaubt eine CEPT-Lizenz?",
          ["Temporary operation in other CEPT countries", "Unlimited power everywhere", "Broadcasting music", "Skipping the exam"],
          ["Vorübergehenden Betrieb in anderen CEPT-Ländern", "Unbegrenzte Leistung überall", "Musik senden", "Die Prüfung überspringen"]),
    ]
    return primer("ch", "HB3ABC", "HB9XYZ", L("Bern", "Bern"), L("HB3 (entry level)", "HB3 (Einsteiger)"),
                  L("Original primer, check BAKOM and USKA", "Eigener Überblick, siehe BAKOM und USKA"), lessons, qs, 5)


def at_pack():
    lessons = [
        {"t": L("Rules that apply", "Welche Regeln gelten"),
         "b": L("Austrian amateur radio is based on the Amateur Radio Act, national ordinances, international rules of the ITU (Radio Regulations) and recommendations of the CEPT. The exam catalogue lists these as legal topics.",
                "Der österreichische Amateurfunk beruht auf dem Amateurfunkgesetz, nationalen Verordnungen, den internationalen Regeln der ITU (VO Funk) und Empfehlungen der CEPT. Der Fragenkatalog führt diese als Rechtsthemen auf.")},
        {"t": L("Licence classes 1, 3 and 4", "Bewilligungsklassen 1, 3 und 4"),
         "b": L("Austria issues amateur radio licences in classes 1, 3 and 4. The exam covers legal rules, operating and skills, and technical basics. On request you can take an extra Morse exam.",
                "Österreich vergibt Amateurfunkbewilligungen der Klassen 1, 3 und 4. Die Prüfung umfasst Recht, Betrieb und Fertigkeiten sowie technische Grundlagen. Auf Antrag kann zusätzlich eine Morseprüfung abgelegt werden.")},
        {"t": L("Callsigns and the log", "Rufzeichen und Funktagebuch"),
         "b": L("Austrian callsigns start with OE. The digit tells you the region. You keep a station log (Funktagebuch) of your contacts.",
                "Österreichische Rufzeichen beginnen mit OE. Die Ziffer zeigt die Region an. Du führst ein Funktagebuch über deine Verbindungen.")},
        {"t": L("Q-codes and abbreviations", "Q-Gruppen und Abkürzungen"),
         "b": L("Operators use short codes: QRM (interference), QSO (contact), QSY (change frequency), QRP (low power), QTH (my location), QRT (stop). CQ means a call to all stations, DE means from, K means go ahead.",
                "Funkamateure nutzen Kurzzeichen: QRM (Störung), QSO (Verbindung), QSY (Frequenzwechsel), QRP (geringe Leistung), QTH (mein Standort), QRT (Sendeschluss). CQ heißt Anruf an alle, DE heißt von, K heißt kommen.")},
        {"t": L("Exam topics to practise", "Prüfungsthemen zum Üben"),
         "b": L("The 2009 catalogue asks open questions, for example: What is the ITU? What is the CEPT? When does a licence expire? What must you do if you move your station? What does the log contain? Try to answer them aloud. This catalogue is from 2009, so check the current rules.",
                "Der Katalog von 2009 stellt offene Fragen, zum Beispiel: Was ist die ITU? Was ist die CEPT? Wann erlischt eine Bewilligung? Was tun bei Standortwechsel? Was steht im Funktagebuch? Versuche, sie laut zu beantworten. Dieser Katalog stammt von 2009, prüfe also die aktuellen Regeln.")},
    ]
    qs = [
        Q("What does QRM mean?", "Was bedeutet QRM?", ["I am being interfered with", "I will send a confirmation", "Change to frequency ...", "My location is ..."],
          ["Ich werde gestört", "Ich gebe eine Empfangsbestätigung", "Wechseln Sie auf die Frequenz ...", "Mein Standort ist ..."]),
        Q("What does QSY mean?", "Was bedeutet QSY?", ["Change to another frequency", "Reduce your power", "Stop transmitting", "What time is it?"],
          ["Wechseln Sie die Frequenz", "Vermindern Sie die Leistung", "Stellen Sie die Aussendung ein", "Wie spät ist es?"]),
        Q("What does QTH mean?", "Was bedeutet QTH?", ["My location is ...", "Your signal fades", "I am ready", "Send faster"],
          ["Mein Standort ist ...", "Ihre Zeichen schwanken", "Ich bin betriebsbereit", "Geben Sie schneller"]),
        Q("Which Q-code asks the other station to reduce power?", "Welche Q-Gruppe bittet die Gegenstation, die Leistung zu vermindern?",
          ["QRP", "QRO", "QRT", "QRV"], ["QRP", "QRO", "QRT", "QRV"]),
        Q("What does CQ mean?", "Was bedeutet CQ?", ["A call to all stations", "Please repeat", "Go ahead", "Goodbye"],
          ["Anruf an alle Funkstellen", "Bitte wiederholen", "Kommen", "Auf Wiederhören"]),
        Q("What does DE mean in a radio call?", "Was bedeutet DE in einem Funkanruf?", ["From", "Please", "Good", "Distance"],
          ["Von", "Bitte", "Gut", "Entfernung"]),
        Q("What does QRT mean?", "Was bedeutet QRT?", ["Stop transmitting", "I am ready", "Send slower", "Increase power"],
          ["Stellen Sie die Aussendung ein", "Ich bin betriebsbereit", "Geben Sie langsamer", "Erhöhen Sie die Leistung"]),
        Q("What does R mean in Morse operating?", "Was bedeutet R im Funkbetrieb?", ["Roger, understood", "No", "Repeat", "Reduce"],
          ["Verstanden", "Nein", "Wiederholen", "Vermindern"]),
    ]
    return primer("at", "OE1ABC", "DL5XYZ", L("Munich", "München"), L("Class 4 / class 3", "Klasse 4 / Klasse 3"),
                  L("Fragenkatalog für den Amateurfunkdienst, BMVIT, 2009 (topics and Q-codes); original text", "Fragenkatalog für den Amateurfunkdienst, BMVIT, 2009 (Themen und Q-Gruppen); eigener Text"),
                  lessons, qs, 6)


# ----------------------------------------------------------------------------------------
# Shack parts
# ----------------------------------------------------------------------------------------
def parts():
    P = []

    def part(pid, order, title_en, title_de, lesson_en, lesson_de, qs):
        P.append({"id": pid, "order": order, "lesson": L(lesson_en, lesson_de), "questions": qs})

    part("psu", 1, "", "",
         "Most transceivers run on 13.8 volts of direct current (DC). A power supply turns mains AC into steady DC and must deliver enough current. Ohm's law: voltage U = current I × resistance R. Power P = U × I. A fuse protects against overload.",
         "Die meisten Transceiver laufen mit 13,8 Volt Gleichspannung (DC). Ein Netzteil wandelt Netz-Wechselspannung in stabile Gleichspannung und muss genug Strom liefern. Ohmsches Gesetz: Spannung U = Strom I × Widerstand R. Leistung P = U × I. Eine Sicherung schützt vor Überlast.",
         [Q("Which supply voltage do most transceivers use?", "Welche Versorgungsspannung nutzen die meisten Transceiver?", ["13.8 V DC", "230 V AC", "3.3 V DC", "1000 V DC"], ["13,8 V Gleichspannung", "230 V Wechselspannung", "3,3 V Gleichspannung", "1000 V Gleichspannung"]),
          Q("A device draws 20 A at 13.8 V. What is its power?", "Ein Gerät nimmt bei 13,8 V einen Strom von 20 A auf. Welche Leistung ist das?", ["276 W", "34.5 W", "6.9 W", "2760 W"], ["276 W", "34,5 W", "6,9 W", "2760 W"]),
          Q("Which formula is Ohm's law?", "Welche Formel ist das Ohmsche Gesetz?", ["U = I × R", "U = I / R", "U = I + R", "U = R / I"], ["U = I × R", "U = I / R", "U = I + R", "U = R / I"]),
          Q("What protects a circuit against too much current?", "Was schützt eine Schaltung vor zu hohem Strom?", ["A fuse", "A knob", "A speaker", "A key"], ["Eine Sicherung", "Ein Drehknopf", "Ein Lautsprecher", "Eine Taste"])])
    part("antenna", 2, "", "",
         "An antenna turns electrical signals into radio waves and back. The wavelength in metres is about 300 divided by the frequency in MHz. A half-wave dipole is two wires, each a quarter wavelength long. Keep antennas far away from power lines.",
         "Eine Antenne wandelt elektrische Signale in Funkwellen um und zurück. Die Wellenlänge in Metern beträgt etwa 300 geteilt durch die Frequenz in MHz. Ein Halbwellendipol besteht aus zwei Drähten von je einer Viertelwellenlänge. Halte Antennen weit weg von Stromleitungen.",
         [Q("What is the wavelength at 14 MHz (approximately)?", "Wie groß ist die Wellenlänge bei 14 MHz (ungefähr)?", ["21 m", "2.1 m", "210 m", "0.21 m"], ["21 m", "2,1 m", "210 m", "0,21 m"]),
          Q("About how long is a half-wave dipole for 14 MHz?", "Wie lang ist ein Halbwellendipol für 14 MHz etwa?", ["10 m", "2 m", "40 m", "100 m"], ["10 m", "2 m", "40 m", "100 m"]),
          Q("A higher frequency means the wavelength is ...", "Eine höhere Frequenz bedeutet, die Wellenlänge ist ...", ["shorter", "longer", "the same", "zero"], ["kürzer", "länger", "gleich", "null"]),
          Q("What must you keep well away from when putting up an antenna?", "Wovon musst du beim Antennenbau weit entfernt bleiben?", ["Overhead power lines", "Birds", "Garden gnomes", "Rain"], ["Freileitungen", "Vögeln", "Gartenzwergen", "Regen"])])
    part("transceiver", 3, "", "",
         "A transceiver combines a transmitter and a receiver. You choose a frequency, measured in hertz, and a mode: CW for Morse, SSB for voice on shortwave, FM for local voice. 14.205 MHz lies in the 20-metre band.",
         "Ein Transceiver vereint Sender und Empfänger. Du wählst eine Frequenz in Hertz und eine Betriebsart: CW für Morsen, SSB für Sprache auf Kurzwelle, FM für lokale Sprache. 14,205 MHz liegt im 20-Meter-Band.",
         [Q("What does \"transceiver\" mean?", "Was bedeutet \"Transceiver\"?", ["Transmitter and receiver in one", "A kind of antenna", "A power supply", "A cable"], ["Sender und Empfänger in einem", "Eine Antennenart", "Ein Netzteil", "Ein Kabel"]),
          Q("How many kilohertz are 1 MHz?", "Wie viele Kilohertz sind 1 MHz?", ["1000 kHz", "10 kHz", "100 kHz", "1 kHz"], ["1000 kHz", "10 kHz", "100 kHz", "1 kHz"]),
          Q("Which mode is common for long-distance voice on shortwave?", "Welche Betriebsart ist für Sprache auf Kurzwelle über große Entfernung üblich?", ["SSB", "Broadcast AM", "Morse only", "Fax"], ["SSB", "Rundfunk-AM", "Nur Morse", "Fax"]),
          Q("Which band is 14.205 MHz in?", "In welchem Band liegt 14,205 MHz?", ["20 m", "40 m", "10 m", "2 m"], ["20 m", "40 m", "10 m", "2 m"])])
    part("mic", 4, "", "",
         "The microphone turns sound into a weak electrical audio signal. The transceiver uses it to modulate the radio signal. Speak clearly and do not shout: too much audio distorts your signal and can disturb others. PTT means push to talk.",
         "Das Mikrofon wandelt Schall in ein schwaches elektrisches Tonsignal um. Der Transceiver moduliert damit das Funksignal. Sprich deutlich und schreie nicht: zu viel Ton verzerrt dein Signal und kann andere stören. PTT heißt Sprechtaste (push to talk).",
         [Q("What does a microphone do?", "Was macht ein Mikrofon?", ["Turns sound into an electrical signal", "Turns light into sound", "Stores power", "Measures SWR"], ["Wandelt Schall in ein elektrisches Signal", "Wandelt Licht in Schall", "Speichert Strom", "Misst das SWR"]),
          Q("What does PTT stand for?", "Wofür steht PTT?", ["Push to talk", "Power to tune", "Peak transmit time", "Play the tone"], ["Sprechtaste (push to talk)", "Power to tune", "Peak transmit time", "Play the tone"]),
          Q("What is modulation?", "Was ist Modulation?", ["Putting information onto a radio wave", "Making an antenna longer", "Charging a battery", "Filtering mains hum"], ["Information auf eine Funkwelle aufbringen", "Eine Antenne verlängern", "Einen Akku laden", "Netzbrummen filtern"]),
          Q("What happens if you speak much too loudly?", "Was passiert, wenn du viel zu laut sprichst?", ["Your signal gets distorted", "Your antenna grows", "The band closes", "Nothing"], ["Dein Signal wird verzerrt", "Deine Antenne wächst", "Das Band schließt", "Nichts"])])
    part("speaker", 5, "", "",
         "The speaker or headphones turn the receiver's audio signal back into sound. Speech uses roughly 300 to 3000 hertz. Headphones help you hear weak stations and keep the noise out. Signal levels are compared in decibels (dB).",
         "Der Lautsprecher oder Kopfhörer wandelt das Tonsignal des Empfängers zurück in Schall. Sprache belegt etwa 300 bis 3000 Hertz. Kopfhörer helfen dir, schwache Stationen zu hören, und halten Störgeräusche fern. Signalpegel vergleicht man in Dezibel (dB).",
         [Q("What does a speaker do?", "Was macht ein Lautsprecher?", ["Turns an electrical signal into sound", "Turns sound into a signal", "Measures frequency", "Stores audio"], ["Wandelt ein elektrisches Signal in Schall", "Wandelt Schall in ein Signal", "Misst die Frequenz", "Speichert Ton"]),
          Q("Roughly which audio range does speech use?", "Welchen Tonbereich belegt Sprache ungefähr?", ["300 to 3000 Hz", "3 to 30 Hz", "30 to 300 MHz", "3 to 30 GHz"], ["300 bis 3000 Hz", "3 bis 30 Hz", "30 bis 300 MHz", "3 bis 30 GHz"]),
          Q("Why use headphones?", "Warum Kopfhörer benutzen?", ["To hear weak stations better", "To make the antenna work", "To raise the power", "To tune the dial"], ["Um schwache Stationen besser zu hören", "Damit die Antenne funktioniert", "Um die Leistung zu erhöhen", "Um den Regler zu drehen"]),
          Q("Which unit compares signal levels?", "Welche Einheit vergleicht Signalpegel?", ["Decibel (dB)", "Ohm", "Farad", "Henry"], ["Dezibel (dB)", "Ohm", "Farad", "Henry"])])
    part("swr", 6, "", "",
         "The SWR meter shows how well the antenna matches the transmitter. Ham radios and coax cables are usually 50 ohms, which is where the name of the 50ohm.de learning platform comes from. An SWR of 1:1 is perfect. A high SWR means power is reflected back, so fix the antenna first.",
         "Das SWR-Meter zeigt, wie gut die Antenne zum Sender passt. Amateurfunkgeräte und Koaxkabel haben meist 50 Ohm, daher kommt der Name der Lernplattform 50ohm.de. Ein SWR von 1:1 ist ideal. Ein hohes SWR bedeutet, dass Leistung zurückgeworfen wird. Repariere also zuerst die Antenne.",
         [Q("Which impedance do amateur coax cables usually have?", "Welche Impedanz haben Amateurfunk-Koaxkabel meist?", ["50 ohms", "5 ohms", "500 ohms", "5000 ohms"], ["50 Ohm", "5 Ohm", "500 Ohm", "5000 Ohm"]),
          Q("Which SWR is ideal?", "Welches SWR ist ideal?", ["1:1", "10:1", "100:1", "0:1"], ["1:1", "10:1", "100:1", "0:1"]),
          Q("What does a high SWR tell you?", "Was sagt ein hohes SWR aus?", ["Power is reflected because of a mismatch", "The antenna is perfect", "The battery is full", "The band is open"], ["Leistung wird wegen Fehlanpassung reflektiert", "Die Antenne ist perfekt", "Die Batterie ist voll", "Das Band ist offen"]),
          Q("What should you do about a high SWR?", "Was tust du bei hohem SWR?", ["Reduce power and fix the antenna", "Turn the power up", "Ignore it", "Add a longer cable"], ["Leistung reduzieren und die Antenne prüfen", "Die Leistung erhöhen", "Es ignorieren", "Ein längeres Kabel anschließen"])])
    part("key", 7, "", "",
         "A Morse key sends short and long tones: dit and dah. A dah is three times as long as a dit. Morse code, also called CW, works with weak signals and simple equipment. The letter E is one dit, T is one dah.",
         "Eine Morsetaste sendet kurze und lange Töne: Dit und Dah. Ein Dah ist dreimal so lang wie ein Dit. Morsen, auch CW genannt, funktioniert mit schwachen Signalen und einfacher Technik. Der Buchstabe E ist ein Dit, T ist ein Dah.",
         [Q("How long is a dah compared to a dit?", "Wie lang ist ein Dah im Vergleich zu einem Dit?", ["3 times as long", "Twice as long", "The same", "10 times as long"], ["3-mal so lang", "Doppelt so lang", "Gleich lang", "10-mal so lang"]),
          Q("How is the letter E sent?", "Wie wird der Buchstabe E gesendet?", ["One dit", "One dah", "Two dits", "Dit dah"], ["Ein Dit", "Ein Dah", "Zwei Dits", "Dit Dah"]),
          Q("What is Morse code called as a mode?", "Wie heißt Morsen als Betriebsart?", ["CW", "FM", "SSB", "TV"], ["CW", "FM", "SSB", "TV"]),
          Q("What does the Q-code QRS ask?", "Worum bittet die Q-Gruppe QRS?", ["Send more slowly", "Send faster", "Stop", "Repeat"], ["Geben Sie langsamer", "Geben Sie schneller", "Aufhören", "Wiederholen"])])
    part("logbook", 8, "", "",
         "A log records date, time, frequency, mode, callsign and signal reports of each contact. Logs use UTC, a time that is the same everywhere. A QSL card confirms a contact. RST 59 means perfectly readable and very strong.",
         "Ein Logbuch hält Datum, Uhrzeit, Frequenz, Betriebsart, Rufzeichen und Rapport jeder Verbindung fest. Logbücher nutzen UTC, eine Zeit, die überall gleich ist. Eine QSL-Karte bestätigt eine Verbindung. RST 59 heißt perfekt lesbar und sehr stark.",
         [Q("Which time standard do amateur logs use?", "Welche Zeit nutzen Amateurfunk-Logbücher?", ["UTC", "Local summer time", "Sunrise time", "Winter time"], ["UTC", "Lokale Sommerzeit", "Sonnenaufgangszeit", "Winterzeit"]),
          Q("What does QSO mean?", "Was bedeutet QSO?", ["A radio contact", "A power supply", "An antenna type", "A radio band"], ["Eine Funkverbindung", "Ein Netzteil", "Eine Antennenart", "Ein Funkband"]),
          Q("What does a QSL card do?", "Was bewirkt eine QSL-Karte?", ["Confirms a contact", "Tunes the radio", "Pays the licence fee", "Powers the shack"], ["Bestätigt eine Verbindung", "Stimmt das Funkgerät ab", "Bezahlt die Lizenzgebühr", "Versorgt die Funkbude"]),
          Q("What does the report 59 mean?", "Was bedeutet der Rapport 59?", ["Perfectly readable, very strong", "Barely readable, very weak", "The 59th contact", "59 watts"], ["Perfekt lesbar, sehr stark", "Kaum lesbar, sehr schwach", "Die 59. Verbindung", "59 Watt"])])
    return P


def qso():
    """QSO script. Placeholders: {my} your callsign, {other} partner callsign, {name} your name, {pname} partner name, {pqth} partner QTH."""
    steps = [
        {"id": "answer", "them": L("{other} de {other} calling CQ, CQ, CQ. K.", "CQ CQ CQ de {other}, {other} kommen."),
         "prompt": L("Answer their call.", "Antworte auf den Anruf."),
         "choices": [L("{other} de {my}, {my}. K.", "{other} de {my}, {my}. Kommen."),
                     L("Hello, who is there?", "Hallo, wer ist da?"),
                     L("QRT QRT QRT.", "QRT QRT QRT.")], "c": 0},
        {"id": "exchange", "them": L("{my} de {other}. Good evening! Your report is 59. My name is {pname}, QTH {pqth}. How copy? K.",
                                     "{my} de {other}. Guten Abend! Dein Rapport ist 59. Mein Name ist {pname}, QTH {pqth}. Wie hörst du mich? Kommen."),
         "prompt": L("Send your report, name and location.", "Gib deinen Rapport, Namen und Standort durch."),
         "choices": [L("{other} de {my}. R, thanks {pname}. You are 59. Name {name}. K.", "{other} de {my}. Verstanden, danke {pname}. Du bist 59. Name {name}. Kommen."),
                     L("CQ CQ CQ, anyone there?", "CQ CQ CQ, ist da jemand?"),
                     L("Goodbye.", "Auf Wiedersehen.")], "c": 0},
        {"id": "sign_off", "them": L("{my} de {other}. Thanks for the QSO, {name}. 73 and all the best. {my} de {other}, SK.",
                                       "{my} de {other}. Danke für das QSO, {name}. 73 und alles Gute. {my} de {other}, Ende."),
         "prompt": L("Close the contact politely.", "Beende das Gespräch höflich."),
         "choices": [L("{other} de {my}. Thanks {pname}, 73! {my} SK.", "{other} de {my}. Danke {pname}, 73! {my} Ende."),
                     L("QSY QSY QSY!", "QSY QSY QSY!"),
                     L("No more radio for me.", "Kein Funk mehr für mich.")], "c": 0},
    ]
    return {"steps": steps}


if __name__ == "__main__":
    dump("content/i18n/ui.json", {k: L(*v) for k, v in UI.items()})
    for pack in (de_pack(), us_pack(), uk_pack(), ch_pack(), at_pack()):
        dump("content/legal/%s.json" % pack["country"], pack)
    dump("content/tech/parts.json", parts())
    dump("content/qso/scripts.json", qso())
