 Explicación Técnica del Servidor

Para entender cómo funciona este servidor web tras ejecutar el script, aquí tienes un desglose de los puntos clave:

¿Qué es Apache?: Es el software encargado de escuchar peticiones en el puerto 80 (HTTP) y entregar archivos (como el index.html) al navegador que los solicita.

Gestión del Servicio: Usamos systemctl enable para que el servidor web arranque automáticamente si reinicias la máquina, y systemctl start para ponerlo en marcha inmediatamente.

Ruta de los archivos: En sistemas basados en Debian/Ubuntu, la "raíz" del sitio web es /var/www/html. Cualquier archivo .html que pongas ahí será visible desde el exterior.

El comando cat <<EOF: Es una técnica de Bash llamada "Here Document". Permite escribir bloques largos de texto (en este caso, el código HTML/CSS) directamente dentro de un archivo sin tener que usar un editor manual.

Permisos de Usuario: El usuario www-data es la cuenta estándar bajo la cual corre Apache. Al asignar la propiedad con chown, nos aseguramos de que el servidor tenga permisos de lectura sobre la página web.

🛠️ Instrucciones de uso

Crear el archivo: nano instalar_web.sh.

Dar permisos: chmod +x instalar_web.sh.

Ejecutar: sudo ./instalar_web.sh.

Para ver tu página, abre el navegador y escribe la dirección IP de tu máquina Linux (ejemplo: http://192.168.1.10).
