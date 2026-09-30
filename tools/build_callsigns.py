#!/usr/bin/env python3
"""Generates content/callsigns/<country>.json: a fictional callsign directory per country.

Names are invented first names with a surname initial, callsigns are random within the
country's real format. Real callsigns are assigned by the national regulator; this is
a game. Run: python3 tools/build_callsigns.py
"""
import json, os, random, re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
LET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

NAMES = {
    "de": ["Lena", "Jonas", "Mia", "Felix", "Hannah", "Paul", "Emma", "Leon", "Clara", "Tim", "Nele", "Ben", "Sophie", "Finn", "Laura", "Max", "Greta", "Oskar"],
    "at": ["Lukas", "Anna", "Florian", "Julia", "Stefan", "Katharina", "Matthias", "Verena", "Andreas", "Sarah", "Thomas", "Lisa", "David", "Eva", "Patrick", "Nina", "Georg", "Marie"],
    "ch": ["Noah", "Sara", "Luca", "Elena", "Nico", "Lea", "Jan", "Nora", "Reto", "Anja", "Marco", "Selina", "Urs", "Fabienne", "Dario", "Livia", "Beat", "Mirjam"],
    "us": ["Jake", "Emily", "Tyler", "Megan", "Ryan", "Olivia", "Carlos", "Dana", "Kevin", "Priya", "Sam", "Chloe", "Dylan", "Maya", "Ethan", "Grace", "Luis", "Amy"],
    "uk": ["Oliver", "Amelia", "Harry", "Isla", "George", "Poppy", "Jack", "Ruby", "Alfie", "Freya", "Charlie", "Ella", "Thomas", "Grace", "Oscar", "Lily", "Henry", "Evie"],
}
PLACES = {
    "de": ["Berlin", "Hamburg", "München", "Köln", "Leipzig", "Dresden", "Bremen", "Stuttgart", "Kiel"],
    "at": ["Wien", "Graz", "Linz", "Salzburg", "Innsbruck", "Klagenfurt", "Bregenz", "Eisenstadt", "St. Pölten"],
    "ch": ["Bern", "Zürich", "Basel", "Luzern", "St. Gallen", "Chur", "Lausanne", "Lugano", "Aarau"],
    "us": ["Boston", "Austin", "Denver", "Seattle", "Chicago", "Atlanta", "Phoenix", "Portland", "Miami"],
    "uk": ["Leeds", "Bristol", "Glasgow", "Cardiff", "Belfast", "Norwich", "York", "Exeter", "Dundee"],
}
# prefix: what every callsign starts with; rule: short explanation key is in the UI strings.
FORMATS = {
    "de": {"prefix": "DN", "pattern": r"^DN[0-9][A-Z]{3}$", "make": lambda r: "DN%d%s" % (r.randint(1, 9), "".join(r.choice(LET) for _ in range(3))), "example": "DN1ABC"},
    "at": {"prefix": "OE", "pattern": r"^OE[1-9][A-Z]{1,3}$", "make": lambda r: "OE%d%s" % (r.randint(1, 9), "".join(r.choice(LET) for _ in range(r.choice([2, 3, 3])))), "example": "OE1ABC"},
    "ch": {"prefix": "HB3", "pattern": r"^HB3[A-Z]{3}$", "make": lambda r: "HB3" + "".join(r.choice(LET) for _ in range(3)), "example": "HB3ABC"},
    "us": {"prefix": "K/N/W", "pattern": r"^[KNW][A-Z]?[0-9][A-Z]{2,3}$", "make": lambda r: r.choice("KNW") + r.choice(LET) + str(r.randint(0, 9)) + "".join(r.choice(LET) for _ in range(3)), "example": "KD2ABC"},
    "uk": {"prefix": "M7", "pattern": r"^M7[A-Z]{3}$", "make": lambda r: "M7" + "".join(r.choice(LET) for _ in range(3)), "example": "M7ABC"},
}
PARTNERS = {"de": "OE3XYZ", "at": "DL2XYZ", "ch": "DL2XYZ", "us": "W1XYZ", "uk": "DL2XYZ"}


def build(cc: str) -> dict:
    r = random.Random("cq-quest-" + cc)
    fmt = FORMATS[cc]
    calls: list[str] = []
    while len(calls) < 18:
        c = fmt["make"](r)
        if c not in calls and re.match(fmt["pattern"], c) and c != PARTNERS[cc]:
            calls.append(c)
    calls.sort()
    names = NAMES[cc][:]
    r.shuffle(names)
    places = PLACES[cc]
    free_idx = set(r.sample(range(18), 7))
    entries = []
    for i, c in enumerate(calls):
        if i in free_idx:
            entries.append({"call": c})
        else:
            entries.append({"call": c, "name": "%s %s." % (names[i], r.choice(LET)), "qth": r.choice(places)})
    return {"country": cc, "prefix": fmt["prefix"], "pattern": fmt["pattern"], "example": fmt["example"], "entries": entries}


if __name__ == "__main__":
    os.makedirs(os.path.join(ROOT, "content", "callsigns"), exist_ok=True)
    for cc in FORMATS:
        d = build(cc)
        with open(os.path.join(ROOT, "content", "callsigns", cc + ".json"), "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False, indent=1)
        print("wrote", cc, sum(1 for e in d["entries"] if "name" not in e), "free of", len(d["entries"]))
