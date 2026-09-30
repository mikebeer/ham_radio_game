"""German legal/technical levels 2 (class E) and 3 (class A).
German question and answer text is copied verbatim from the Bundesnetzagentur question catalogue
(3rd edition, March 2024, DL-DE-BY-2.0) as shipped in DARC-e-V/50ohm-contents-dl. In the catalogue
answer A is correct, so the correct answer is always index 0. English is an UNOFFICIAL translation
written for this game. Lessons are original text."""
import json, os
from build_content import L, CONTENTS

CATALOGUE = os.path.join(CONTENTS, "contents", "questions", "fragenkatalog3b.json")

# (catalogue number, English question, [English answers a..d in catalogue order])
E_ITEMS = [
    ("EA107", "By how many decibels does the power level change when the power is doubled?",
     ["3 dB", "6 dB", "1.5 dB", "12 dB"]),
    ("EC112", "A resistor has a tolerance of 10 %. With a nominal resistance of 5.6 kOhm, the actual value lies between ...",
     ["5040 to 6160 Ohm.", "4760 to 6440 Ohm.", "4.7 to 6.8 kOhm.", "5.2 to 6.3 kOhm."]),
    ("EC202", "How does the AC resistance of an ideal capacitor behave as frequency increases?",
     ["It falls.", "It falls to a minimum and then rises again.", "It rises.", "It rises to a maximum and then falls again."]),
    ("EC303", "How does the AC resistance of an ideal coil behave as frequency increases?",
     ["It rises.", "It falls.", "It falls to a minimum and then rises again.", "It rises to a maximum and then falls again."]),
    ("EC404", "A transformer primary winding with 150 turns has 45 V applied. The secondary voltage is 180 V. How many turns does the secondary have?",
     ["600 turns", "850 turns", "38 turns", "30 turns"]),
    ("EC503", "What are the typical threshold voltages of germanium and silicon diodes? They are ...",
     ["germanium between 0.2 and 0.4 V, silicon between 0.6 and 0.8 V.",
      "germanium between 0.6 and 0.8 V, silicon between 0.2 and 0.4 V.",
      "germanium between 1.4 and 1.6 V, silicon 0.6 to 0.8 V.",
      "germanium between 0.6 and 0.8 V, silicon 1.4 to 1.6 V."]),
    ("EC603", "What is meant by current gain in a transistor?",
     ["A small base current controls a large collector current.",
      "A small emitter current controls a large collector current.",
      "A small emitter current controls a large base current.",
      "A small collector current controls a large emitter current."]),
    ("EE202", "Roughly how much RF bandwidth is needed to transmit an SSB signal?",
     ["It equals the bandwidth of the audio signal.",
      "It equals half the bandwidth of the audio signal.",
      "It equals twice the bandwidth of the audio signal.",
      "It is zero, because the RF carrier is suppressed in SSB."]),
    ("EF209", "What is the purpose of a BFO in a receiver?",
     ["To generate an auxiliary carrier so that CW or SSB signals become audible",
      "To mix with a received signal to produce the IF",
      "To suppress amplitude interference",
      "To suppress FM signals"]),
    ("EG208", "Depending on installation height, the feed-point resistance at the centre of a half-wave dipole is about ...",
     ["40 to 90 Ohm.", "100 to 120 Ohm.", "120 to 240 Ohm.", "240 to 600 Ohm."]),
    ("EG221", "An antenna manufacturer specifies the gain of an antenna as 5 dBd. What is the gain of the antenna in dBi?",
     ["7.15 dBi", "5 dBi", "2.5 dBi", "2.85 dBi"]),
    ("EH204", "What does \"MUF\" mean in shortwave propagation?",
     ["Maximum usable frequency", "Lowest usable frequency", "Critical cut-off frequency", "Mean usable frequency"]),
    ("VD734", "Which power limits apply to callsign holders of class A and E in the frequency ranges 144 to 146 MHz and 430 to 440 MHz?",
     ["Maximum 750 W PEP for class A and 75 W PEP for class E",
      "Maximum 750 W PEP for both classes",
      "Maximum 100 W PEP for class A and 50 W PEP for class E",
      "Maximum 10 W PEP for both classes"]),
    ("VB109", "For how long may a radio amateur temporarily operate abroad per stay when the CEPT arrangement applies?",
     ["Up to 3 months", "Up to 9 months", "Up to 6 months", "Up to one year"]),
    ("BB205", "What do you do when you receive \"PSE QRP\"?",
     ["You reduce your transmitter power.", "You increase your transmitter power.",
      "You change frequency.", "You send a confirmation card to the other station."]),
    ("BG106", "What should you bear in mind when entering times on QSL cards? They should be entered in ...",
     ["Coordinated Universal Time (UTC), to make it easier for radio partners abroad to find the entry in their log.",
      "your own local time, to comply with German regulations.",
      "the local time of your radio partner, to avoid confusion.",
      "your own local time and additionally in your partner's local time, to satisfy both German regulations and make it easy for partners abroad to find the log entry."]),
]

A_ITEMS = [
    ("AA113", "How big is the difference between S-units S4 and S7 in dB?",
     ["18 dB", "9 dB", "15 dB", "3 dB"]),
    ("AA105", "A power gain of 40 corresponds to ...",
     ["16 dB.", "36.8 dB.", "32 dB.", "73.8 dB."]),
    ("AB213", "A voltage converter changes 12 V to 5 V. It draws 2 A and delivers 3 A. What is its efficiency?",
     ["62.5 %", "160 %", "27.7 %", "41.7 %"]),
    ("AC105", "What is the magnitude of the capacitive reactance of a 50 pF capacitor at a frequency of 145 MHz?",
     ["approx. 22 Ohm", "approx. 0.045 Ohm", "approx. 18.2 kOhm", "approx. 69 Ohm"]),
    ("AC101", "A lossless capacitor is connected to an AC voltage source. What phase shift between voltage and current results?",
     ["The current leads the voltage by 90 degrees.", "The voltage leads the current by 90 degrees.",
      "The voltage leads the current by 45 degrees.", "The current leads the voltage by 45 degrees."]),
    ("AC305", "To match an antenna with a feed-point resistance of 450 Ohm to a 50 Ohm transmission line, a transformer with a turns ratio of ...",
     ["3:1 should be used.", "4:1 should be used.", "9:1 should be used.", "16:1 should be used."]),
    ("AD201", "What cut-off frequency results for a high-pass filter with a resistor of 4.7 kOhm and a capacitor of 2.2 nF?",
     ["15.4 kHz", "1.54 kHz", "154 kHz", "154 Hz"]),
    ("AD427", "An audio amplifier raises the input voltage from 1 mV to 4 mV output voltage. Input and output resistance are equal. What is the voltage gain of the amplifier?",
     ["12 dB", "3 dB", "6 dB", "9 dB"]),
    ("AE309", "A 145 MHz carrier is frequency-modulated with an audio frequency of 2 kHz and a deviation of 1.8 kHz. Roughly what bandwidth does the modulated signal have? The bandwidth is approximately ...",
     ["7.6 kHz", "3.8 kHz", "5.8 kHz", "12 kHz"]),
    ("AF107", "A single-conversion superhet receiver is tuned to 14.24 MHz. The local oscillator runs at 24.94 MHz, which is above the IF. Where can image-frequency interference occur?",
     ["35.64 MHz", "10.7 MHz", "3.54 MHz", "24.94 MHz"]),
    ("AF103", "A radio amateur increases his transmitter power from 10 to 100 W. Before the increase your S-meter showed exactly S8. To what value should your S-meter reading rise after the power increase?",
     ["S9+4 dB", "S9+7 dB", "S9", "S9+9 dB"]),
    ("AF609", "How many different output values, e.g. voltages, can an ideal D/A converter with 10-bit resolution produce?",
     ["1024", "10", "100", "256"]),
    ("AD605", "Which of the listed oscillators has the greatest frequency stability?",
     ["OCXO", "TCXO", "VCO", "XO"]),
    ("AG103", "A wire dipole has a total length of 20 m. At what frequency is the dipole resonant if a velocity (shortening) factor of 0.95 is used?",
     ["7.125 MHz", "6.768 MHz", "7.500 MHz", "7.000 MHz"]),
    ("AJ201", "The second harmonic of the frequency 3.730 MHz is located at ...",
     ["7.460 MHz.", "1.865 MHz.", "11.190 MHz.", "5.730 MHz."]),
    ("VD731", "What is the maximum permitted transmitter output power for callsign holders of class A in the frequency ranges 14.000 to 14.350 MHz and 18.068 to 18.168 MHz?",
     ["750 W PEP", "75 W PEP", "150 W PEP", "250 W PEP"]),
    ("VD735", "What is the maximum permitted transmit power for callsign holders of class A in the frequency range 1240 to 1300 MHz?",
     ["750 W PEP, but only a maximum of 5 W EIRP in the sub-range 1247 to 1263 MHz",
      "100 W PEP", "250 W PEP",
      "75 W PEP, but only a maximum of 5 W EIRP in the sub-range 1247 to 1263 MHz"]),
    ("VD730", "What is the maximum permitted transmitter output power for callsign holders of class A in the frequency range 10.1 to 10.15 MHz?",
     ["150 W PEP", "75 W PEP", "250 W PEP", "750 W PEP"]),
]


def _catalogue():
    d = json.load(open(CATALOGUE, encoding="utf-8"))
    found = {}

    def walk(s):
        for q in s.get("questions", []):
            found[q["number"]] = q
        for c in s.get("sections", []):
            walk(c)

    for s in d["sections"]:
        walk(s)
    return found


def _questions(items):
    cat = _catalogue()
    out = []
    for num, en_q, en_a in items:
        q = cat[num]
        de_a = [q["answer_" + c].strip() for c in "abcd"]
        assert len(en_a) == 4
        out.append({"id": num, "q": L(en_q, q["question"].strip()),
                    "a": [L(en_a[i], de_a[i]) for i in range(4)], "c": 0})
    return out


def _lessons_e():
    return [
        {"t": L("Decibels and tolerances", "Dezibel und Toleranzen"),
         "b": L("Doubling the power adds 3 dB to the power level. A resistor with a 10 % tolerance may differ by that much from its nominal value, so 5.6 kOhm can really be anywhere from 5040 to 6160 Ohm. The turns ratio of a transformer is a simple proportion: a 150-turn primary at 45 V with 180 V on the secondary needs 600 secondary turns.",
                "Eine Verdopplung der Leistung erhöht den Leistungspegel um 3 dB. Ein Widerstand mit 10 % Toleranz darf um so viel vom Nennwert abweichen, 5,6 kOhm können also zwischen 5040 und 6160 Ohm liegen. Das Windungsverhältnis eines Transformators ist eine einfache Proportion: Bei 150 Windungen primär mit 45 V und 180 V sekundär braucht man 600 Windungen sekundär.")},
        {"t": L("Coils, capacitors, diodes, transistors", "Spule, Kondensator, Diode, Transistor"),
         "b": L("With rising frequency the AC resistance of an ideal capacitor falls, while that of an ideal coil rises. A germanium diode starts to conduct at about 0.2 to 0.4 V, a silicon diode at about 0.6 to 0.8 V. A transistor amplifies current: a small base current controls a large collector current. Together, these parts make up the building blocks of every radio circuit you will meet later.",
                "Mit steigender Frequenz sinkt der Wechselstromwiderstand eines idealen Kondensators, der einer idealen Spule steigt. Eine Germaniumdiode leitet ab etwa 0,2 bis 0,4 V, eine Siliziumdiode ab etwa 0,6 bis 0,8 V. Ein Transistor verstärkt den Strom: Ein kleiner Basisstrom steuert einen großen Kollektorstrom. Diese Bauteile sind die Bausteine aller Funkschaltungen, die dir später begegnen.")},
        {"t": L("SSB and the receiver", "SSB und der Empfänger"),
         "b": L("A single-sideband signal needs about as much RF bandwidth as the audio signal it carries, because the carrier and one sideband are suppressed. In the receiver, the beat-frequency oscillator (BFO) supplies an auxiliary carrier so that CW and SSB signals become audible. Without it, these signals would only sound like faint clicks or unintelligible noise.",
                "Ein Einseitenbandsignal braucht etwa so viel HF-Bandbreite wie das übertragene NF-Signal, weil Träger und ein Seitenband unterdrückt werden. Im Empfänger liefert der Überlagerungsoszillator (BFO) einen Hilfsträger, damit CW- und SSB-Signale hörbar werden. Ohne ihn wären diese Signale nur als leises Knacken oder unverständliches Rauschen zu hören.")},
        {"t": L("Antennas and propagation", "Antennen und Ausbreitung"),
         "b": L("At the centre of a half-wave dipole the feed-point resistance is roughly 40 to 90 Ohm, depending on height. An antenna gain given in dBd becomes dBi by adding 2.15 dB, so 5 dBd is 7.15 dBi. On shortwave, the MUF is the maximum usable frequency for a given path.",
                "In der Mitte eines Halbwellendipols beträgt der Fußpunktwiderstand je nach Aufbauhöhe etwa 40 bis 90 Ohm. Ein Antennengewinn in dBd wird durch Addition von 2,15 dB zu dBi, 5 dBd sind also 7,15 dBi. Im Kurzwellenbereich ist die MUF die höchste nutzbare Frequenz einer Funkstrecke.")},
        {"t": L("Power, CEPT, Q-codes and log", "Leistung, CEPT, Q-Gruppen und Log"),
         "b": L("In the 2 m and 70 cm bands class A may use up to 750 W PEP and class E up to 75 W PEP. Under the CEPT arrangement you may operate temporarily abroad for up to 3 months per stay. \"PSE QRP\" asks you to reduce your power. Write times on QSL cards in UTC so partners abroad can find them in their log.",
                "Auf 2 m und 70 cm darf Klasse A bis 750 W PEP senden, Klasse E bis 75 W PEP. Nach der CEPT-Regelung darfst du je Aufenthalt bis zu 3 Monate vorübergehend im Ausland funken. \"PSE QRP\" bittet dich, die Sendeleistung zu verringern. Trage Uhrzeiten auf QSL-Karten in UTC ein, damit Funkpartner im Ausland sie im Logbuch finden.")},
    ]


def _lessons_a():
    return [
        {"t": L("Decibels and the S-meter", "Dezibel und S-Meter"),
         "b": L("One S-unit is 6 dB, so S4 to S7 is 18 dB. A power gain of 40 equals 16 dB, and a voltage ratio of 4 equals 12 dB. Raising power from 10 to 100 W adds 10 dB, which takes an S8 reading to S9+4 dB. Efficiency is output power divided by input power: 3 A at 5 V from 2 A at 12 V is 62.5 %.",
                "Eine S-Stufe entspricht 6 dB, von S4 auf S7 sind es also 18 dB. Eine Leistungsverstärkung von 40 entspricht 16 dB, ein Spannungsverhältnis von 4 entspricht 12 dB. Von 10 auf 100 W sind es 10 dB, die S8 auf S9+4 dB anheben. Der Wirkungsgrad ist Ausgangsleistung geteilt durch Eingangsleistung: 3 A bei 5 V aus 2 A bei 12 V ergeben 62,5 %.")},
        {"t": L("Reactance, filters, transformers", "Blindwiderstand, Filter, Übertrager"),
         "b": L("In an ideal capacitor the current leads the voltage by 90 degrees. A 50 pF capacitor has about 22 Ohm of reactance at 145 MHz. A high-pass filter of 4.7 kOhm and 2.2 nF cuts off at 15.4 kHz. To match 450 Ohm to 50 Ohm you need a 3:1 turns ratio, because impedance scales with the square of the turns.",
                "Im idealen Kondensator eilt der Strom der Spannung um 90 Grad voraus. Ein Kondensator mit 50 pF hat bei 145 MHz etwa 22 Ohm Blindwiderstand. Ein Hochpass aus 4,7 kOhm und 2,2 nF hat eine Grenzfrequenz von 15,4 kHz. Zur Anpassung von 450 Ohm an 50 Ohm braucht man ein Windungsverhältnis von 3:1, weil die Impedanz mit dem Quadrat der Windungszahl wächst.")},
        {"t": L("Modulation, receivers, digital", "Modulation, Empfänger, Digitales"),
         "b": L("An FM signal with 2 kHz audio and 1.8 kHz deviation needs roughly 7.6 kHz of bandwidth. In a superhet the image frequency lies twice the IF away from the wanted one: for 14.24 MHz with a 24.94 MHz oscillator it is 35.64 MHz. A 10-bit D/A converter can produce 1024 different output values.",
                "Ein FM-Signal mit 2 kHz NF und 1,8 kHz Hub braucht etwa 7,6 kHz Bandbreite. Beim Superhet liegt die Spiegelfrequenz um die doppelte ZF von der Nutzfrequenz entfernt: Bei 14,24 MHz und einem Oszillator auf 24,94 MHz sind es 35,64 MHz. Ein D/A-Umsetzer mit 10 Bit Auflösung kann 1024 verschiedene Ausgangswerte erzeugen.")},
        {"t": L("Oscillators, antennas, harmonics", "Oszillatoren, Antennen, Oberwellen"),
         "b": L("Of the listed oscillator types the OCXO, a crystal oscillator in a temperature-controlled oven, is the most stable. A 20 m wire dipole with a velocity factor of 0.95 resonates at 7.125 MHz. The second harmonic of a signal is at twice its frequency, so for 3.730 MHz it lies at 7.460 MHz.",
                "Von den genannten Oszillatoren ist der OCXO, ein Quarzoszillator im temperaturgeregelten Ofen, der stabilste. Ein 20 m langer Runddraht-Dipol mit Verkürzungsfaktor 0,95 ist bei 7,125 MHz in Resonanz. Die zweite Harmonische liegt bei der doppelten Frequenz, bei 3,730 MHz also bei 7,460 MHz.")},
        {"t": L("Power limits for class A", "Leistungsgrenzen der Klasse A"),
         "b": L("Class A has the highest limits: up to 750 W PEP on 20 m and 17 m, and 750 W PEP at 1240 to 1300 MHz, but no more than 5 W EIRP in the sub-range 1247 to 1263 MHz. On 30 m (10.1 to 10.15 MHz) the limit is 150 W PEP.",
                "Die Klasse A hat die höchsten Grenzen: bis zu 750 W PEP auf 20 m und 17 m sowie 750 W PEP bei 1240 bis 1300 MHz, im Teilbereich 1247 bis 1263 MHz jedoch höchstens 5 W EIRP. Auf 30 m (10,1 bis 10,15 MHz) liegt die Grenze bei 150 W PEP.")},
    ]


def de_levels():
    return [
        {"class": L("Class E", "Klasse E"),
         "licence": L("Class E (intermediate)", "Klasse E (Fortgeschrittene)"),
         "lessons": _lessons_e(), "questions": _questions(E_ITEMS), "pass": 7},
        {"class": L("Class A", "Klasse A"),
         "licence": L("Class A (full licence)", "Klasse A (Vollzugang)"),
         "lessons": _lessons_a(), "questions": _questions(A_ITEMS), "pass": 7},
    ]


if __name__ == "__main__":
    for lv in de_levels():
        print(lv["class"]["en"], len(lv["questions"]), "questions, pass", lv["pass"], "lessons", len(lv["lessons"]))
        for q in lv["questions"]:
            assert len(q["a"]) == 4 and q["c"] == 0 and q["a"][0]["de"].strip() and q["a"][0]["en"].strip()
            for a in q["a"]:
                assert a["en"].strip() and a["de"].strip()
