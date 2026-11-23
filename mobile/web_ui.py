#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json, os, urllib.parse

STATE_FILE = "/tmp/tiffany_web/state.json"
REPLY_FILE = "/tmp/tiffany_web/reply.txt"

HTML = """<!DOCTYPE html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Tiffany Mobile</title>
<style>
  body { background:#0d1117; color:#e6edf3; font-family:system-ui,sans-serif; margin:0; padding:16px; }
  .card { background:#161b22; border:1px solid #30363d; border-radius:12px; padding:16px; margin-bottom:16px; }
  h2 { margin:0 0 10px 0; color:#58a6ff; font-size:1.1rem; }
  pre { white-space:pre-wrap; background:#0d1117; padding:12px; border-radius:8px; font-size:0.9rem; overflow-x:auto; }
  button { display:block; width:100%; padding:14px; margin:8px 0; border:none; border-radius:8px; font-size:1rem; font-weight:bold; cursor:pointer; background:#238636; color:white; }
  button.no { background:#da3633; }
  button.opt { background:#1f6feb; text-align:left; }
  input { width:100%; padding:12px; box-sizing:border-box; border-radius:8px; border:1px solid #30363d; background:#0d1117; color:white; font-size:1rem; margin-bottom:8px; }
</style></head><body>
<div class="card" id="box">Chargement de Tiffany...</div>
<script>
let lastId = "";
async function refresh() {
  const r = await fetch('/api/state');
  const d = await r.json();
  if (d.id === lastId) return;
  lastId = d.id;
  let html = `<h2>🤖 ${d.title || 'Tiffany AI'}</h2><pre>${d.text || 'En attente de message...'}</pre>`;
  if (d.pending) {
    if (d.type === 'question') {
      html += `<button onclick="send('YES')">✔ Autoriser / Oui</button><button class="no" onclick="send('NO')">✘ Refuser / Non</button>`;
    } else if (d.type === 'list' && d.options) {
      d.options.forEach(o => { html += `<button class="opt" onclick="send('${o.replace(/'/g,"\\'")}')">👉 ${o}</button>`; });
    } else if (d.type === 'entry') {
      html += `<input id="inp" placeholder="Votre réponse..."><button onclick="send(document.getElementById('inp').value)">Envoyer</button>`;
    } else {
      html += `<button onclick="send('OK')">✔ Lu / Continuer</button>`;
    }
  }
  document.getElementById('box').innerHTML = html;
}
async function send(val) {
  await fetch('/api/reply', {method:'POST', body:val});
  lastId = ""; refresh();
}
setInterval(refresh, 1000); refresh();
</script></body></html>"""

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        if self.path == '/api/state':
            self.send_response(200); self.send_header('Content-Type','application/json'); self.end_headers()
            if os.path.exists(STATE_FILE):
                with open(STATE_FILE) as f: self.wfile.write(f.read().encode())
            else:
                self.wfile.write(b'{"id":"0","title":"Tiffany AI","text":"En attente...","pending":false}')
        else:
            self.send_response(200); self.send_header('Content-Type','text/html'); self.end_headers()
            self.wfile.write(HTML.encode())
    def do_POST(self):
        if self.path == '/api/reply':
            length = int(self.headers.get('Content-Length', 0))
            data = self.rfile.read(length).decode()
            with open(REPLY_FILE, 'w') as f: f.write(data)
            if os.path.exists(STATE_FILE):
                with open(STATE_FILE) as f: st = json.load(f)
                st['pending'] = False
                with open(STATE_FILE, 'w') as f: json.dump(st, f)
            self.send_response(200); self.end_headers()

print("📱 Interface mobile prête sur http://0.0.0")
HTTPServer(('0.0.0.0', 8765), Handler).serve_forever()
