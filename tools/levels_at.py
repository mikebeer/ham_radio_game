"""Austria: Bewilligungsklassen 3 -> 4 -> 1. Level 1 (Klasse 3) lives in build_content.at_pack().
Facts as supplied by the project owner (Austrian authority class descriptions); original text, NOT the official catalogue.
"""
from levels_primers import L, Q, _lesson

_D = [("1", "Wien", "Vienna"), ("2", "Salzburg", "Salzburg"), ("3", "Niederösterreich", "Lower Austria"),
          ("4", "Burgenland", "Burgenland"), ("5", "Oberösterreich", "Upper Austria"), ("6", "Steiermark", "Styria"),
          ("7", "Tirol", "Tyrol"), ("8", "Kärnten", "Carinthia"), ("9", "Vorarlberg", "Vorarlberg")]


def at_levels():
    k4 = {
        "class": L("Class 4", "Klasse 4"), "licence": L("Class 4 (CEPT Novice)", "Klasse 4 (CEPT-Novice)"),
        "lessons": [
            _lesson("The Einsteigerlizenz", "Die Einsteigerlizenz",
                    "Class 4 is the CEPT Novice licence, called Einsteigerlizenz. You may use all modes at up to 100 watts. Because it is a CEPT licence, you may also operate in other countries that recognise it.",
                    "Klasse 4 ist die CEPT-Novice-Bewilligung, die Einsteigerlizenz. Du darfst alle Betriebsarten mit bis zu 100 Watt nutzen. Weil sie eine CEPT-Bewilligung ist, darfst du auch in anderen Ländern funken, die sie anerkennen."),
            _lesson("Your bands", "Deine Bänder",
                    "Class 4 gives you 160 m, 80 m, 15 m, 10 m, 2 m and 70 cm. Low bands like 160 m and 80 m carry regional contacts, 15 m and 10 m open for worldwide contacts when conditions are good, and 2 m and 70 cm are for local work.",
                    "Klasse 4 gibt dir 160 m, 80 m, 15 m, 10 m, 2 m und 70 cm. Die tiefen Bänder 160 m und 80 m tragen regionale Verbindungen, 15 m und 10 m öffnen bei guten Bedingungen für weltweite Verbindungen, 2 m und 70 cm dienen dem lokalen Betrieb."),
            _lesson("Rules for this class", "Regeln dieser Klasse",
                    "With class 4 you may not use self-built transmitters. You use commercial equipment. The exam covers law and operating in full, and technology in a simplified form.",
                    "Mit Klasse 4 darfst du keine selbstgebauten Sender betreiben, sondern nur Industriegeräte. Die Prüfung umfasst Recht und Betrieb vollständig und Technik vereinfacht."),
            _lesson("Upgrade path", "Der Aufstieg",
                    "From class 3 you upgrade to class 4 with the operating (Betrieb) exam. From class 4 you upgrade to class 1 with the technology (Technik) exam.",
                    "Von Klasse 3 kommst du mit der Betriebsprüfung auf Klasse 4. Von Klasse 4 kommst du mit der Technikprüfung auf Klasse 1."),
            _lesson("Callsigns of Austria", "Rufzeichen in Österreich",
                    "Every callsign is unique worldwide and assigned by the authority on request. An Austrian callsign is the prefix OE, one digit for the federal state and a suffix of one to four letters. The ITU, a United Nations agency for telecommunications, assigned the prefix to Austria. Example: OE1XTU is Austria, 1 is Vienna, XTU is the personal suffix.",
                    "Jedes Rufzeichen ist weltweit einmalig und wird von der Behörde auf Antrag zugewiesen. Ein österreichisches Rufzeichen besteht aus dem Landeskenner OE, einer Ziffer für das Bundesland und einem Suffix aus ein bis vier Buchstaben. Den Landeskenner hat die ITU, eine UN-Agentur für Telekommunikation, Österreich zugewiesen. Beispiel: OE1XTU ist Österreich, 1 ist Wien, XTU ist der persönliche Suffix."),
        ],
        "questions": [
            Q("What is another name for the class 4 licence?", "Wie heißt die Klasse-4-Bewilligung noch?",
              ["CEPT Novice (Einsteigerlizenz)", "Club licence", "Broadcast licence", "Test licence"],
              ["CEPT-Novice (Einsteigerlizenz)", "Clublizenz", "Rundfunklizenz", "Testlizenz"]),
            Q("Which band is open to class 4 but NOT to class 3?", "Welches Band ist für Klasse 4, aber NICHT für Klasse 3 offen?",
              ["80 m", "2 m", "70 cm", "None, they are the same"], ["80 m", "2 m", "70 cm", "Keines, sie sind gleich"]),
            Q("What is the maximum power for class 4?", "Wie hoch ist die maximale Leistung in Klasse 4?",
              ["100 W", "10 W", "400 W", "1 kW"], ["100 W", "10 W", "400 W", "1 kW"]),
            Q("Which exam takes you from class 4 to class 1?", "Welche Prüfung bringt dich von Klasse 4 auf Klasse 1?",
              ["The technology exam", "The law exam", "A Morse exam", "No exam"], ["Die Technikprüfung", "Die Rechtsprüfung", "Eine Morseprüfung", "Keine Prüfung"]),
            Q("May a class 4 operator use a self-built transmitter?", "Darf man in Klasse 4 einen selbstgebauten Sender betreiben?",
              ["No", "Yes, always", "Yes, on 2 m", "Yes, up to 10 W"], ["Nein", "Ja, immer", "Ja, auf 2 m", "Ja, bis 10 W"]),
            Q("In OE1XTU, what does the digit 1 stand for?", "Wofür steht die Ziffer 1 in OE1XTU?",
              ["Vienna", "Salzburg", "Tyrol", "Styria"], ["Wien", "Salzburg", "Tirol", "Steiermark"]),
            Q("Which region has the digit 7?", "Welches Bundesland hat die Ziffer 7?",
              ["Tyrol", "Carinthia", "Burgenland", "Vorarlberg"], ["Tirol", "Kärnten", "Burgenland", "Vorarlberg"]),
            Q("Which region has the digit 9?", "Welches Bundesland hat die Ziffer 9?",
              ["Vorarlberg", "Upper Austria", "Lower Austria", "Styria"], ["Vorarlberg", "Oberösterreich", "Niederösterreich", "Steiermark"]),
        ],
        "pass": 6,
    }
    k1 = {
        "class": L("Class 1", "Klasse 1"), "licence": L("Class 1 (CEPT, full licence)", "Klasse 1 (CEPT, Vollzugang)"),
        "lessons": [
            _lesson("The full licence", "Die volle Bewilligung",
                    "Class 1 is the CEPT licence with access to all bands and all modes according to the IARU band plan. A Morse test is no longer required.",
                    "Klasse 1 ist die CEPT-Bewilligung mit Zugang zu allen Bändern und Betriebsarten nach dem IARU-Bandplan. Eine Morseprüfung ist nicht mehr nötig."),
            _lesson("Power classes", "Leistungsklassen",
                    "Class 1 covers all power classes. Power class D is reserved for club stations only.",
                    "Klasse 1 umfasst alle Leistungsklassen. Die Leistungsklasse D ist nur für Klubstationen vorgesehen."),
            _lesson("Building equipment", "Geräte bauen",
                    "Only class 1 operators may build or modify transmitters. That is why the exam covers technology in full, including the things you need to build and adjust a station safely.",
                    "Nur in Klasse 1 darfst du Sender selbst bauen oder verändern. Darum umfasst die Prüfung die Technik vollständig, mit allem, was du für Bau und Abgleich einer Station sicher brauchst."),
            _lesson("Band plan and respect", "Bandplan und Rücksicht",
                    "The IARU band plan divides each band into segments for modes such as CW, data and phone. Stay inside your segment and listen before you transmit.",
                    "Der IARU-Bandplan teilt jedes Band in Abschnitte für Betriebsarten wie Telegrafie, Datenbetrieb und Telefonie. Bleib in deinem Abschnitt und höre vor dem Senden zu."),
        ],
        "questions": [
            Q("Which class allows you to build or modify transmitters?", "Welche Klasse erlaubt den Bau oder die Änderung von Sendern?",
              ["Class 1", "Class 3", "Class 4", "All classes"], ["Klasse 1", "Klasse 3", "Klasse 4", "Alle Klassen"]),
            Q("Which licence gives access to all bands according to the IARU band plan?", "Welche Bewilligung erlaubt alle Bänder nach IARU-Bandplan?",
              ["Class 1", "Class 3", "Class 4", "None"], ["Klasse 1", "Klasse 3", "Klasse 4", "Keine"]),
            Q("Who may use power class D?", "Wer darf die Leistungsklasse D nutzen?",
              ["Club stations only", "Everyone in class 1", "Class 4 operators", "Nobody"], ["Nur Klubstationen", "Alle in Klasse 1", "Klasse-4-Funker", "Niemand"]),
            Q("Is a Morse exam required for class 1?", "Ist für Klasse 1 eine Morseprüfung nötig?",
              ["No, not any more", "Yes, always", "Only on 80 m", "Only for clubs"], ["Nein, nicht mehr", "Ja, immer", "Nur auf 80 m", "Nur für Klubs"]),
            Q("Which exam takes you from class 3 directly to class 1?", "Welche Prüfungen führen von Klasse 3 direkt zu Klasse 1?",
              ["Technology and operating", "Law only", "Operating only", "None"], ["Technik und Betrieb", "Nur Recht", "Nur Betrieb", "Keine"]),
            Q("What does the IARU band plan define?", "Was legt der IARU-Bandplan fest?",
              ["Which modes are used in which segment", "Your callsign", "Your exam date", "Mains voltage"], ["Welche Betriebsarten in welchem Abschnitt genutzt werden", "Dein Rufzeichen", "Dein Prüfungsdatum", "Die Netzspannung"]),
        ],
        "pass": 5,
    }
    return [k4, k1]


# ----------------------------------------------------------------------------------------
# Band-specific shack and QSO content for Austria (overrides the generic tiers)
# ----------------------------------------------------------------------------------------
def _T(len_, lde, qs):
    return {"lesson": L(len_, lde), "questions": qs}


def at_antenna_tiers():
    """Antenna lessons per Austrian class, based on the bands each class may use."""
    k3 = _T(
        "Class 3 uses two bands: 2 m (144 to 146 MHz) and 70 cm (430 to 440 MHz). The wavelength in metres is about 300 divided by the frequency in MHz, so at 145 MHz it is about 2 m and at 435 MHz about 0.7 m. A quarter-wave vertical for 2 m is only about 50 cm long, and a half-wave dipole about 1 m. Such small antennas are easy to build into a window, a car or a mast. Keep away from power lines.",
        "Klasse 3 nutzt zwei Bänder: 2 m (144 bis 146 MHz) und 70 cm (430 bis 440 MHz). Die Wellenlänge in Metern beträgt etwa 300 geteilt durch die Frequenz in MHz, bei 145 MHz also rund 2 m und bei 435 MHz rund 0,7 m. Ein Viertelwellenstrahler für 2 m ist nur etwa 50 cm lang, ein Halbwellendipol etwa 1 m. Solche kleinen Antennen lassen sich leicht am Fenster, am Auto oder auf einem Mast unterbringen. Halte Abstand zu Stromleitungen.",
        [
            Q("What is the wavelength at 145 MHz (approximately)?", "Wie groß ist die Wellenlänge bei 145 MHz (ungefähr)?",
              ["2 m", "20 m", "0.2 m", "200 m"], ["2 m", "20 m", "0,2 m", "200 m"]),
            Q("What is the wavelength at 435 MHz (approximately)?", "Wie groß ist die Wellenlänge bei 435 MHz (ungefähr)?",
              ["0.7 m", "7 m", "70 m", "0.07 m"], ["0,7 m", "7 m", "70 m", "0,07 m"]),
            Q("About how long is a quarter-wave vertical for the 2 m band?", "Wie lang ist ein Viertelwellenstrahler für das 2-m-Band etwa?",
              ["50 cm", "5 m", "2 m", "10 cm"], ["50 cm", "5 m", "2 m", "10 cm"]),
            Q("Which band is 430 to 440 MHz?", "Welches Band ist 430 bis 440 MHz?",
              ["70 cm", "2 m", "10 m", "80 m"], ["70 cm", "2 m", "10 m", "80 m"]),
        ])
    k4 = _T(
        "Class 4 adds the HF bands 160 m, 80 m, 15 m and 10 m. A real half-wave dipole is about 5 % shorter than half a wavelength, so its length in metres is roughly 143 divided by the frequency in MHz. For 80 m (3.6 MHz) that is about 40 m of wire, for 10 m (28.5 MHz) only about 5 m. On 160 m (1.85 MHz) a dipole would be about 77 m, so many stations use a shortened or loaded antenna. A balun joins a balanced dipole to unbalanced coax. You must buy your transmitter: class 4 does not allow self-built transmitters, but you may build antennas.",
        "Klasse 4 bringt die Kurzwellenbänder 160 m, 80 m, 15 m und 10 m dazu. Ein realer Halbwellendipol ist etwa 5 % kürzer als eine halbe Wellenlänge; seine Länge in Metern beträgt grob 143 geteilt durch die Frequenz in MHz. Für 80 m (3,6 MHz) sind das rund 40 m Draht, für 10 m (28,5 MHz) nur rund 5 m. Auf 160 m (1,85 MHz) wäre ein Dipol etwa 77 m lang, darum nutzen viele eine verkürzte oder belastete Antenne. Ein Balun verbindet einen symmetrischen Dipol mit unsymmetrischem Koax. Den Sender musst du kaufen: Klasse 4 erlaubt keine selbstgebauten Sender, Antennen darfst du aber bauen.",
        [
            Q("About how long is a real half-wave dipole for 3.6 MHz (80 m)?", "Wie lang ist ein realer Halbwellendipol für 3,6 MHz (80 m) etwa?",
              ["40 m", "20 m", "80 m", "10 m"], ["40 m", "20 m", "80 m", "10 m"]),
            Q("About how long is a real half-wave dipole for 28.5 MHz (10 m)?", "Wie lang ist ein realer Halbwellendipol für 28,5 MHz (10 m) etwa?",
              ["5 m", "15 m", "50 m", "0.5 m"], ["5 m", "15 m", "50 m", "0,5 m"]),
            Q("Why is 160 m often run with a shortened antenna?", "Warum wird auf 160 m oft eine verkürzte Antenne genutzt?",
              ["A full dipole would be about 77 m long", "The band needs no antenna", "Shorter antennas have more power", "The law demands it"],
              ["Ein voller Dipol wäre etwa 77 m lang", "Das Band braucht keine Antenne", "Kürzere Antennen haben mehr Leistung", "Das Gesetz verlangt es"]),
            Q("Which of these may a class 4 operator build?", "Was darf ein Klasse-4-Funker selbst bauen?",
              ["An antenna", "A transmitter", "A 400 W amplifier", "Nothing at all"], ["Eine Antenne", "Einen Sender", "Eine 400-W-Endstufe", "Gar nichts"]),
        ])
    return {"1": k3, "2": k4}


def at_qso_levels():
    def step(id_, them, prompt, good, bad1, bad2):
        return {"id": id_, "them": them, "prompt": prompt, "choices": [good, bad1, bad2], "c": 0}
    k3 = [
        step("answer",
             L("CQ two metres, CQ two metres, this is {other}, {other}, calling CQ on two metres. K.",
               "CQ zwei Meter, CQ zwei Meter, hier ist {other}, {other}, rufe CQ auf zwei Meter. Kommen."),
             L("Answer his CQ call with both callsigns.", "Antworte auf seinen CQ-Ruf mit beiden Rufzeichen."),
             L("{other} de {my}, {my}. K.", "{other} de {my}, {my}. Kommen."),
             L("Hello, who is there?", "Hallo, wer ist da?"),
             L("QRT QRT QRT.", "QRT QRT QRT.")),
        step("exchange",
             L("{my} de {other}. Good evening! You are 59 on two metres. My name is {pname}, QTH {pqth}. I use a vertical antenna on the roof. How copy? K.",
               "{my} de {other}. Guten Abend! Du bist auf zwei Meter 59. Mein Name ist {pname}, QTH {pqth}. Ich nutze eine Vertikalantenne auf dem Dach. Wie hörst du mich? Kommen."),
             L("Send your report, name and location.", "Gib deinen Rapport, Namen und Standort durch."),
             L("{other} de {my}. R, thanks {pname}. You are 59. Name {name}. K.", "{other} de {my}. Verstanden, danke {pname}. Du bist 59. Name {name}. Kommen."),
             L("{other} de {my}. You are 59. I run 500 watts from my self-built amplifier. K.",
               "{other} de {my}. Du bist 59. Ich fahre 500 Watt mit meiner selbstgebauten Endstufe. Kommen."),
             L("CQ CQ CQ, anyone there?", "CQ CQ CQ, ist da jemand?")),
        step("sign_off",
             L("{my} de {other}. Thanks for the QSO, {name}. 73 and all the best. {my} de {other}, SK.",
               "{my} de {other}. Danke für das QSO, {name}. 73 und alles Gute. {my} de {other}, Ende."),
             L("Close the contact politely.", "Beende das Gespräch höflich."),
             L("{other} de {my}. Thanks {pname}, 73! {my} SK.", "{other} de {my}. Danke {pname}, 73! {my} Ende."),
             L("QSY QSY QSY!", "QSY QSY QSY!"),
             L("No more radio for me.", "Kein Funk mehr für mich.")),
    ]
    k4 = [
        step("answer",
             L("CQ eighty metres, CQ eighty metres, this is {other}, {other}, calling CQ and listening. K.",
               "CQ achtzig Meter, CQ achtzig Meter, hier ist {other}, {other}, rufe CQ und höre. Kommen."),
             L("Answer his CQ call with both callsigns, phonetics optional.", "Antworte auf seinen CQ-Ruf mit beiden Rufzeichen, Buchstabieren ist optional."),
             L("{other} de {my}, {my}. K.", "{other} de {my}, {my}. Kommen."),
             L("Break break, 10-4 good buddy, what's your twenty?", "Break break, 10-4 guter Freund, wo steckst du?"),
             L("{other}, {other}, {other}. Come in.", "{other}, {other}, {other}. Kommen.")),
        step("exchange",
             L("{my} de {other}. Thanks for the call, you are 57 here on 80 metres. My name is {pname}, QTH {pqth}. I am running 100 watts into a dipole. How copy? K.",
               "{my} de {other}. Danke für den Anruf, du bist hier auf 80 Metern 57. Mein Name ist {pname}, QTH {pqth}. Ich fahre 100 Watt auf einen Dipol. Wie hörst du mich? Kommen."),
             L("Answer every item: confirm, give his report, your name, QTH and station.",
               "Beantworte jeden Punkt: bestätige, gib seinen Rapport, deinen Namen, QTH und Station durch."),
             L("{other} de {my}. R R, thanks {pname}. Your report is 57. My name is {name}. Your QTH {pqth} is copied. I run 100 watts, the most my class allows. K.",
               "{other} de {my}. Roger, danke {pname}. Dein Rapport ist 57. Mein Name ist {name}. Dein QTH {pqth} ist notiert. Ich fahre 100 Watt, das Maximum meiner Klasse. Kommen."),
             L("{other} de {my}. You are 59. I run 1 kilowatt from my home-built amplifier. K.",
               "{other} de {my}. Du bist 59. Ich fahre 1 Kilowatt mit meiner selbstgebauten Endstufe. Kommen."),
             L("R, thanks. I am {name}. K.", "Verstanden, danke. Ich bin {name}. Kommen.")),
        step("sign_off",
             L("{my} de {other}. Thanks for the nice chat, {name}. 73 and all the best. {my} de {other}, K.",
               "{my} de {other}. Danke für das nette Gespräch, {name}. 73 und alles Gute. {my} de {other}, Kommen."),
             L("Close properly with 73 and both callsigns.", "Beende korrekt mit 73 und beiden Rufzeichen."),
             L("{other} de {my}. Thanks {pname}, 73 and good DX! {other} de {my}, SK.", "{other} de {my}. Danke {pname}, 73 und gutes DX! {other} de {my}, Ende."),
             L("Over and out, 10-4, catch you on the flip side!", "Over and out, 10-4, bis zur nächsten Runde!"),
             L("73, bye bye.", "73, tschüss.")),
    ]
    return {"1": {"steps": k3}, "2": {"steps": k4}}
