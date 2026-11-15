import os, glob
ROOT = os.path.expanduser("~/tiffany")
B, V, J, C, Z = "\033[96m", "\033[92m", "\033[93m", "\033[95m", "\033[0m"
sources = {}
for nom, fn in [("Dictionnaire Flash (Conversation)", "dictionnaire_flash.txt"), ("Variantes & Langues", "variantes_utilisateur.txt"), ("Mémoire Réflexe & Dojo", "actions_terminal/dictionnaire_ia.txt")]:
    fp = os.path.join(ROOT, fn)
    items = []
    if os.path.exists(fp):
        for l in open(fp, encoding="utf-8", errors="ignore"):
            if "|" in l and not l.startswith("#") and not l.startswith("-"):
                k, v = l.split("|", 1)
                items.append((k.strip(), v.strip()[:48]))
    sources[nom] = items
outils = []
for sh in sorted(glob.glob(ROOT+"/actions_terminal/*.sh")):
    k, d = "", ""
    for l in open(sh, encoding="utf-8", errors="ignore"):
        if l.startswith("# TERM_KEY:"): k = l.split(":",1).pop(1).strip()
        if l.startswith("# TERM_DESC:"): d = l.split(":",1).pop(1).strip()
    if k: outils.append((k, d[:48]))
sources["Outils Terminal (TERM_KEY)"] = outils

print(f"\n{B}══════════════════════════════════════════════════════════════════\n   📚 INVENTAIRE INTÉGRAL DES ALIAS & STATISTIQUES DE FLUIDITÉ\n══════════════════════════════════════════════════════════════════{Z}")
tot = 0
for cat, lst in sources.items():
    tot += len(lst)
    print(f"\n{C}▶ {cat} ({len(lst)} entrées) :{Z}")
    for k, v in lst:
        print(f"  {V}• {k:<28}{Z} ➔ {J}{v}{Z}")

ratio = round(tot / max(len(outils), 1), 1)
note = "EXCELLENTE (Conversation 100 % naturelle)" if ratio >= 5 else "BONNE"
print(f"\n{B}══════════════════════════════════════════════════════════════════\n   📊 STATISTIQUES DE FLUIDITÉ VOCALE & CONVERSATIONNELLE\n══════════════════════════════════════════════════════════════════{Z}")
print(f"  {V}✔ Total des alias et déclencheurs actifs :{Z} {tot}")
print(f"  {V}✔ Outils système de base couverts      :{Z} {len(outils)}")
print(f"  {V}✔ Richesse moyenne (alias / outil)     :{Z} {ratio} variantes par outil")
print(f"  {V}✔ Indice de fluidité conversationnelle :{Z} {J}{note}{Z}\n")
