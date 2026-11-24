#!/usr/bin/env bash
# MENU_NAME: 📱 Paramètres & Aide Mobile (QR Code)
# MENU_DESC: Scanner le QR Code, afficher URL Wi-Fi et Code PIN
# TERM_KEY: parametres mobile

[ ! -s "$HOME/.config/tiffany/pro_license_disabled_launch" ] && ("$HOME/tiffany/bin/espeak-ng" "Cette option fait partie de l'édition Pro." >/dev/null 2>&1 &) && zenity --question --title="💎 Option Édition PRO" --text="La Télécommande Mobile Wi-Fi nécessite l'Édition PRO.\nVoulez-vous entrer votre clé d'activation maintenant ?" --width=440 2>/dev/null && bash "$HOME/tiffany/plugins/00c_activer_pro.sh" && exit 0

IP=$(hostname -I | awk '{print $1}')
[ -z "$IP" ] && IP="127.0.0.1"
PIN=$(cat ~/.config/tiffany/mobile_pin.txt 2>/dev/null || echo 1246)
URL="http://$IP:8486"

python3 - "$URL" "$PIN" << 'PYEOF'
import sys, os
url, pin = sys.argv.pop(1), sys.argv.pop(1)

try:
    import qrcode, tkinter as tk
    from PIL import ImageTk

    qr = qrcode.QRCode(box_size=8, border=2)
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    root = tk.Tk()
    root.title("📱 Compagnon Mobile Tiffany")
    root.configure(bg="#1a1a2e")
    root.resizable(False, False)

    tk.Label(root, text="🌹 Télécommande Mobile Tiffany", font=("Sans", 13, "bold"), fg="#ff6b9d", bg="#1a1a2e").pack(pady=(12, 6))
    tk.Label(root, text="Scanne ce QR Code avec l'appareil photo de ton téléphone :", font=("Sans", 10), fg="white", bg="#1a1a2e").pack(pady=(0, 8))

    tk_img = ImageTk.PhotoImage(img)
    lbl_qr = tk.Label(root, image=tk_img, bg="white", bd=4)
    lbl_qr.pack(padx=20, pady=4)

    tk.Label(root, text=f"🌐 Adresse Wi-Fi : {url}", font=("Monospace", 11, "bold"), fg="#4ecca3", bg="#1a1a2e").pack(pady=(10, 2))
    tk.Label(root, text=f"🔑 Code PIN secret : {pin}", font=("Monospace", 12, "bold"), fg="#ffd369", bg="#1a1a2e").pack(pady=(2, 12))
    tk.Button(root, text="Fermer", command=root.destroy, bg="#ff6b9d", fg="white", font=("Sans", 10, "bold"), padx=18, pady=4).pack(pady=(0, 14))

    root.mainloop()
except Exception:
    os.system(f'zenity --info --title="📱 Compagnon Mobile Tiffany" --text="🌐 Adresse Wi-Fi : {url}\n🔑 Code PIN secret : {pin}" --width=420 2>/dev/null')
PYEOF
