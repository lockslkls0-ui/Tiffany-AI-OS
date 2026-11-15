import os, re, glob, time, sys
ROOT = os.path.expanduser("~/tiffany")
V, J, R, B, C, G, Z = "\033[92m", "\033[93m", "\033[91m", "\033[96m", "\033[95m", "\033[90m", "\033[0m"

for i in range(1, 21):
    pct = i * 5
    barre = "█" * i + "░" * (20 - i)
    sys.stdout.write(f"\r{B}🔍 Scan de la matrice vocale : [{V}{barre}{B}] {pct}%{Z}")
    sys.stdout.flush()
    time.sleep(0.03)
print("\n")

outils = {}
for sh in sorted(glob.glob(ROOT + "/actions_terminal/*.sh")):
    k, desc, ico = "", "", "⚡"
    for l in open(sh, encoding="utf-8", errors="ignore"):
        if l.startswith("# TERM_KEY:"): k = l.split(":", 1).pop(1).strip().lower()
        if l.startswith("# TERM_DESC:"): desc = l.split(":", 1).pop(1).strip()
        if l.startswith("# TERM_ICON:"): ico = l.split(":", 1).pop(1).strip()
    if k: outils[k] = {"desc": desc, "ico": ico, "alias": set([k])}

for fn in ("variantes_utilisateur.txt", "actions_terminal/dictionnaire_ia.txt"):
    fp = os.path.join(ROOT, fn)
    if os.path.exists(fp):
        for l in open(fp, encoding="utf-8", errors="ignore"):
            if "|" in l and not l.startswith(("#", "-")):
                k, v = [x.strip().lower() for x in l.split("|", 1)]
                for ok in outils:
                    if v == ok or v.startswith(ok + " ") or (" " + ok) in v:
                        outils[ok]["alias"].add(k)

iu = os.path.join(ROOT, "interpreteur_universel.sh")
if os.path.exists(iu):
    for l in open(iu, encoding="utf-8", errors="ignore"):
        if ")" in l and ("$ACT/" in l or "$PLUG/" in l):
            cles = [c.strip().strip('"') for c in l.split(")").pop(0).split("|") if c.strip().startswith('"')]
            for ok in outils:
                if l.endswith(f"_{ok}.sh\"") or l.endswith(f"_{ok}.sh'") or f'"{ok}"' in l:
                    outils[ok]["alias"].update(cles)

print(f"{B}══════════════════════════════════════════════════════════════════════════\n   🎯 TABLEAU DE COUVERTURE DES 27 OUTILS & LEURS ALIAS (SANS CONFLIT)\n══════════════════════════════════════════════════════════════════════════{Z}\n")
faibles, index_global, conflits = [], {}, []
for k, data in outils.items():
    nb = len(data["alias"])
    coul = V if nb >= 4 else (J if nb >= 2 else R)
    etat = "🟢 OPTIMAL" if nb >= 4 else ("🟡 MOYEN  " if nb >= 2 else "🔴 MANQUE ")
    if nb < 3: faibles.append(k)
    for a in data["alias"]:
        if a in index_global and index_global[a] != k:
            conflits.append((a, index_global[a], k))
        index_global[a] = k
    liste_str = ", ".join(sorted(data["alias"]))
    print(f"  {coul}{etat} [{nb:2d}]{Z} {data['ico']} {B}{k:<12}{Z} {G}({data['desc'][:36]}){Z}")
    print(f"                  {C}↳ {liste_str}{Z}")

print(f"\n{B}══════════════════════════════════════════════════════════════════════════{Z}")
print(f"  {V}✔ Outils fluides (4+ alias)    :{Z} {sum(1 for d in outils.values() if len(d['alias'])>=4)}/{len(outils)}")
print(f"  {J}⚠️ Outils à enrichir (< 3)     :{Z} {len(faibles)} ({R}{', '.join(faibles) if faibles else 'Aucun'}{Z})")
print(f"  {V if not conflits else R}🛡️ Chevauchements d'aiguillage :{Z} {len(conflits)} conflit(s)")
for a, o1, o2 in conflits:
    print(f"     {R}• Doublon détecté sur '{a}' entre [{o1}] et [{o2}]{Z}")
print(f"{B}══════════════════════════════════════════════════════════════════════════{Z}\n")
