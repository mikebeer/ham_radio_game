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
