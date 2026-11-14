#!/usr/bin/env python3
import os, datetime

root = os.path.expanduser("~/tiffany")
raw = os.path.join(root, "logs/session_raw.txt")
facts = os.path.join(root, "memory/long_term_facts.json")
os.makedirs(os.path.dirname(facts), exist_ok=True)

if os.path.exists(raw):
    with open(raw, "r", encoding="utf-8", errors="ignore") as f:
        lines = [l.strip() for l in f if "USER:" in l]
    if lines:
        now = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")
        existing = open(facts, "r", encoding="utf-8", errors="ignore").read() if os.path.exists(facts) else ""
        with open(facts, "a", encoding="utf-8") as out:
            for l in lines[-3:]:
                clean = l.split("USER:", 1)[-1].strip()
                if len(clean) > 10 and clean not in existing:
                    out.write(f"- [{now}] {clean}\n")
