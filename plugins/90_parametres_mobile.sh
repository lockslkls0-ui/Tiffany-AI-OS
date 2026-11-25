#!/usr/bin/env bash
# MENU_NAME: 📱 Paramètres & Aide Mobile (QR Code)
# MENU_DESC: Scanner le QR Code (Wi-Fi Local & Mondial 4G) et afficher le Code PIN
# TERM_KEY: parametres mobile

[ ! -s "$HOME/.config/tiffany/pro_license_disabled_launch" ] && ("$HOME/tiffany/bin/espeak-ng" "Cette option fait partie de l'édition Pro." >/dev/null 2>&1 &) && zenity --question --title="💎 Option Édition PRO" --text="La Télécommande Mobile Wi-Fi nécessite l'Édition PRO.\nVoulez-vous entrer votre clé d'activation maintenant ?" --width=440 2>/dev/null && bash "$HOME/tiffany/plugins/00c_activer_pro.sh" && exit 0

IP=$(hostname -I | awk '{print $1}')
[ -z "$IP" ] && IP="127.0.0.1"
TS_IP=$(tailscale ip -4 2>/dev/null | head -n 1)
PIN=$(cat ~/.config/tiffany/mobile_pin.txt 2>/dev/null || echo 1246)
URL="http://$IP:8486"
TS_URL=""
[ -n "$TS_IP" ] && TS_URL="http://$TS_IP:8486"

python3 - "$URL" "$PIN" "$TS_URL" << 'PYEOF'
import sys, os, subprocess
url, pin, ts_url = sys.argv[1], sys.argv[2], sys.argv[3]

def aide_mondiale():
    msg = (
        "🌍 COMMENT PILOTER TON PC PARTOUT DANS LE MONDE (4G / 5G) :\n\n"
        "1. Sur ton PC : installe Tailscale (sudo snap install tailscale && sudo tailscale up) et connecte-toi.\n"
        "2. Sur ton téléphone : installe l'application gratuite 'Tailscale' (Play Store / App Store), connecte-toi avec le MÊME compte et active-la.\n"
        "3. Relance ce panneau sur le PC : un 2e QR Code 'Accès Mondial' apparaîtra automatiquement à côté du Wi-Fi !\n\n"
        "💡 Astuce Chrome Android : si la page bloque en HTTP, ouvre-la en Navigation Privée ou désactive 'Toujours utiliser des connexions sécurisées' dans Chrome."
    )
    subprocess.Popen(["zenity", "--info", "--title=🌍 Guide Accès Mondial (Tailscale)", "--text=" + msg, "--width=480"])

try:
    import qrcode, tkinter as tk
    from PIL import ImageTk

    root = tk.Tk()
    root.title("📱 Compagnon Mobile Tiffany")
    root.configure(bg="#1a1a2e")
    root.resizable(False, False)

    tk.Label(root, text="🌹 Télécommande Mobile Tiffany", font=("Sans", 13, "bold"), fg="#ff6b9d", bg="#1a1a2e").pack(pady=(12, 4))
    tk.Label(root, text="Scanne le QR Code avec l'appareil photo de ton téléphone :", font=("Sans", 10), fg="white", bg="#1a1a2e").pack(pady=(0, 8))

    frame_qr = tk.Frame(root, bg="#1a1a2e")
    frame_qr.pack(padx=16, pady=4)

    # QR 1 : Wi-Fi Local
    f1 = tk.Frame(frame_qr, bg="#1a1a2e")
    f1.pack(side="left", padx=10)
    tk.Label(f1, text="🏠 Wi-Fi Maison", font=("Sans", 10, "bold"), fg="#4ecca3", bg="#1a1a2e").pack(pady=(0, 4))
    qr1 = qrcode.QRCode(box_size=7, border=2)
    qr1.add_data(url)
    qr1.make(fit=True)
    tk_img1 = ImageTk.PhotoImage(qr1.make_image(fill_color="black", back_color="white"))
    tk.Label(f1, image=tk_img1, bg="white", bd=4).pack()
    tk.Label(f1, text=url, font=("Monospace", 9, "bold"), fg="#4ecca3", bg="#1a1a2e").pack(pady=(4, 0))

    # QR 2 : Accès Mondial Tailscale (si actif)
    if ts_url:
        f2 = tk.Frame(frame_qr, bg="#1a1a2e")
        f2.pack(side="left", padx=10)
        tk.Label(f2, text="🌍 Mondial 4G (Tailscale)", font=("Sans", 10, "bold"), fg="#00d4ff", bg="#1a1a2e").pack(pady=(0, 4))
        qr2 = qrcode.QRCode(box_size=7, border=2)
        qr2.add_data(ts_url)
        qr2.make(fit=True)
        tk_img2 = ImageTk.PhotoImage(qr2.make_image(fill_color="black", back_color="white"))
        tk.Label(f2, image=tk_img2, bg="white", bd=4).pack()
        tk.Label(f2, text=ts_url, font=("Monospace", 9, "bold"), fg="#00d4ff", bg="#1a1a2e").pack(pady=(4, 0))

    tk.Label(root, text=f"🔑 Code PIN secret : {pin}", font=("Monospace", 12, "bold"), fg="#ffd369", bg="#1a1a2e").pack(pady=(12, 8))

    btn_frame = tk.Frame(root, bg="#1a1a2e")
    btn_frame.pack(pady=(0, 14))
    tk.Button(btn_frame, text="🌍 Aide Accès Mondial", command=aide_mondiale, bg="#0f3460", fg="#00d4ff", font=("Sans", 9, "bold"), padx=12, pady=4).pack(side="left", padx=6)
    tk.Button(btn_frame, text="Fermer", command=root.destroy, bg="#ff6b9d", fg="white", font=("Sans", 10, "bold"), padx=18, pady=4).pack(side="left", padx=6)

    root.mainloop()
except Exception:
    os.system(f'zenity --info --title="📱 Compagnon Mobile Tiffany" --text="🏠 Wi-Fi : {url}\n🌍 Mondial : {ts_url or "Non activé"}\n🔑 Code PIN : {pin}" --width=440 2>/dev/null')
PYEOF
