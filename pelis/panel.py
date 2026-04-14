from flask import Flask, render_template_string, request, redirect, url_for
import subprocess
import os

app = Flask(__name__)

# CONFIGURACIÓN - Verifica que estos nombres coincidan con tus archivos
RUTA_DISCOS = "/home/pelis/"
RUTA_ISO = "/home/pelis/win10.iso"

# Diseño HTML con avisos de estado
HTML = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>KVM Control Panel - Pro</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0f172a; color: #f1f5f9; text-align: center; padding: 20px; }
        .container { max-width: 900px; margin: auto; background: #1e293b; padding: 30px; border-radius: 15px; }
        h1 { color: #38bdf8; }
        .form-group { background: #334155; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        input { padding: 12px; border-radius: 8px; background: #0f172a; color: white; border: 1px solid #475569; width: 40%; }
        button { padding: 12px 25px; border-radius: 8px; cursor: pointer; font-weight: bold; border: none; }
        .btn-start { background: #22c55e; color: white; }
        .btn-stop { background: #ef4444; color: white; }
        .btn-restart { background: #eab308; color: white; }
        table { width: 100%; margin-top: 20px; border-collapse: collapse; background: #0f172a; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #1e293b; }
        .vnc-alert { background: #38bdf8; color: #0f172a; padding: 10px; border-radius: 5px; margin-bottom: 10px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🖥️ KVM Command Center</h1>
        
        <div class="vnc-alert">
            TIP: Al arrancar, pulsa F12 en el VNC para elegir el menú de arranque si no carga la ISO.
        </div>

        <div class="form-group">
            <form action="/lanzar" method="post">
                <input type="text" name="nombre" placeholder="Nombre de la VM..." required>
                <button type="submit" class="btn-start">🚀 Crear y Arrancar</button>
            </form>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Nombre VM</th>
                    <th>PID</th>
                    <th>VNC</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {% for vm in vms_activas %}
                <tr>
                    <td>{{ vm.nombre }}</td>
                    <td><code>{{ vm.pid }}</code></td>
                    <td><b style="color:#38bdf8">{{ ip }}:1</b></td>
                    <td>
                        <form action="/detener/{{ vm.pid }}" method="post" style="display:inline;">
                            <button type="submit" class="btn-stop">Detener</button>
                        </form>
                        <form action="/reiniciar/{{ vm.nombre }}/{{ vm.pid }}" method="post" style="display:inline;">
                            <button type="submit" class="btn-restart">Reiniciar</button>
                        </form>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</body>
</html>
'''

def obtener_vms_activas():
    vms = []
    try:
        output = subprocess.check_output(["ps", "aux"]).decode("utf-8")
        for line in output.splitlines():
            if "qemu-system-x86_64" in line and ".qcow2" in line:
                parts = line.split()
                pid = parts[1]
                for p in parts:
                    if ".qcow2" in p:
                        nombre = p.split("/")[-1].replace(".qcow2", "")
                        vms.append({'nombre': nombre, 'pid': pid})
                        break
    except: pass
    return vms

def ejecutar_qemu(nombre):
    disco = os.path.join(RUTA_DISCOS, f"{nombre}.qcow2")
    
    # ASEGURAR PERMISOS antes de arrancar
    os.system(f"sudo chmod 666 {RUTA_ISO}")
    
    if not os.path.exists(disco):
        subprocess.run(["qemu-img", "create", "-f", "qcow2", disco, "64G"])
    
    os.system(f"sudo chmod 666 {disco}")

    # COMANDO MODIFICADO: Añadido boot menu y comprobación de CDROM
    comando = (
        f"sudo nohup qemu-system-x86_64 -m 4096 -smp 2 -enable-kvm -cpu host "
        f"-drive file={disco},format=qcow2,if=virtio "
        f"-cdrom {RUTA_ISO} "
        f"-boot menu=on,once=d "
        f"-netdev user,id=n1,tftp=/srv/tftp,bootfile=ipxe.efi -device e1000,netdev=n1 "
        f"-vga std -device qemu-xhci -device usb-tablet "
        f"-vnc :1 > /dev/null 2>&1 &"
    )
    os.system(comando)

@app.route('/')
def index():
    ip = subprocess.getoutput("hostname -I").split()[0]
    vms = obtener_vms_activas()
    return render_template_string(HTML, ip=ip, vms_activas=vms)

@app.route('/lanzar', methods=['POST'])
def lanzar():
    ejecutar_qemu(request.form['nombre'])
    return redirect(url_for('index'))

@app.route('/detener/<pid>', methods=['POST'])
def detener(pid):
    os.system(f"sudo kill -9 {pid}")
    return redirect(url_for('index'))

@app.route('/reiniciar/<nombre>/<pid>', methods=['POST'])
def reiniciar(nombre, pid):
    os.system(f"sudo kill -9 {pid}")
    ejecutar_qemu(nombre)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
