#!/usr/bin/env python3
import os, json, time, subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs
import moteur_mobile as m

DIR = os.path.dirname(os.path.abspath(__file__))
FAILS = {}

class H(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        if self.path == "/stats":
            self.send_response(200); self.send_header("Content-Type","application/json"); self.end_headers()
            self.wfile.write(json.dumps(m.stats()).encode())
        else:
            outils = m.lister_outils()
            btns = "".join(f'<button onclick="send(\'{c}\')">{l}</button>' for l, c in outils)
            html = open(os.path.join(DIR, "interface.html"), encoding="utf-8").read().replace("__COUNT__", str(len(outils))).replace("__BOUTONS__", btns)
            self.send_response(200); self.send_header("Content-Type","text/html; charset=utf-8"); self.end_headers()
            self.wfile.write(html.encode("utf-8"))
    def do_POST(self):
        ip = self.client_address
        nb, ts = FAILS.get(ip, (0, 0))
        if nb >= 5 and (time.time() - ts) < 60:
            self.send_response(429); self.end_headers(); self.wfile.write("⏳ Trop d'essais. Attends 1 min.".encode()); return
        length = int(self.headers.get("Content-Length", 0))
        data = parse_qs(self.rfile.read(length).decode("utf-8"))
        pin_list = data.get("pin", [""])
        pin_val = pin_list.pop(0) if pin_list else ""
        if not m.check_pin(pin_val):
            FAILS[ip] = (nb + 1, time.time())
            self.send_response(403); self.end_headers(); self.wfile.write("❌ Code PIN incorrect.".encode()); return
        FAILS[ip] = (0, 0)
        q_list = data.get("q", [""])
        q = q_list.pop(0) if q_list else ""
        res = m.set_pin(q.split(":", 1).pop()) if q.startswith("SETPIN:") else m.executer(q)
        self.send_response(200); self.send_header("Content-Type","text/plain; charset=utf-8"); self.end_headers()
        self.wfile.write(res.encode("utf-8"))

if __name__ == "__main__":
    pin = m.init_pin()
    ips = subprocess.check_output(["hostname", "-I"]).decode().split()
    ip_loc = ips.pop(0) if ips else "127.0.0.1"
    print(f"\n📱 COMPAGNON MODULAIRE PRÊT : http://{ip_loc}:8486 | PIN : {pin}\n")
    HTTPServer.allow_reuse_address = True
    HTTPServer(("0.0.0.0", 8486), H).serve_forever()
