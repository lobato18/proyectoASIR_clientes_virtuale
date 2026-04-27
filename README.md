-----

# 📝 MEMORIA DEL PROYECTO FINAL - ASIR

## Sistema Centralizado de Despliegue de SO (SDAD-SO) con Gestión de Perfiles Móviles mediante Samba 4 (Linux) para Clientes Ligeros

**Autor:** José Ángel Vargas Lobato  
**Ciclo Formativo:** Administración de Sistemas Informáticos en Red (ASIR)  
**Fecha:** Diciembre, 2025  
**Repositorio Técnico:** [GitHub - Proyecto ASIR](https://github.com/lobato18/proyectoASIR_clientes_virtuale/tree/main)

---

## 1. Introducción y Justificación

### 1.1. Resumen Ejecutivo
El proyecto implementa una infraestructura de red híbrida para el despliegue de un **Entorno Operativo Ligero (Thin Client)** basado en **Windows PE** mediante **PXE Boot**.  

La inteligencia del sistema reside en un servidor central con **Linux**, que actúa como **Controlador de Dominio de Active Directory (Samba 4)**.  

Esta solución permite:

- Gestionar usuarios
- Aplicar políticas de grupo (**GPOs**)
- Habilitar la **redirección de carpetas**
- Operar sin almacenamiento local (**Diskless**)

### Beneficios principales:
- Optimización de recursos
- Centralización de seguridad
- Movilidad total del usuario

---

### 1.2. Justificación y Motivación
Este sistema resuelve la ineficiencia de las instalaciones tradicionales mediante:

#### **Eficiencia de Costes**
- Uso de Linux para servicios críticos
- Eliminación de discos duros en puestos cliente
- Reducción de costes de mantenimiento

#### **Seguridad**
- El sistema operativo se ejecuta en **RAM**
- Al reiniciar desaparecen cambios no autorizados
- Entorno siempre limpio

#### **Movilidad de Usuarios**
- Integración con Samba 4
- Redirección automática de carpetas
- Acceso a datos desde cualquier terminal

---

## 2. Marco Teórico y Tecnológico

### 2.1. Servicios de Infraestructura (Servidor Linux)

#### **Samba 4 AD DC**
Proporciona:

- DNS
- Kerberos
- LDAP
- Dominio compatible con Active Directory nativo

#### **ISC-DHCP-Server**
Gestiona:

- Direccionamiento IP
- Opción 66 → Servidor TFTP
- Opción 67 → Archivo de arranque PXE

#### **TFTP / HTTP**
Permiten:

- Transferencia del cargador de arranque
- Descarga de imagen WIM

---

### 2.2. Entorno de Cliente

#### **Windows PE (Preinstallation Environment)**
Versión mínima de Windows personalizada para:

- Carga de controladores de red
- Scripts de automatización
- Montaje de unidades
- Inicio de sesión en dominio

#### **PXE (Preboot Execution Environment)**
Permite:

- Arranque por red
- Descarga del sistema operativo
- Ejecución sin almacenamiento local

---

## 3. Planificación y Diseño de la Solución

### 3.1. Arquitectura del Sistema
La arquitectura es **Cliente-Servidor Híbrida**:

1. **Servidor Linux**
   - Control de identidades
   - Samba 4
   - DHCP
   - PXE
   - Almacenamiento

2. **Cliente Ligero**
   - Sin HDD
   - Solicitud PXE
   - Windows PE en RAM

3. **Flujo**
   - Solicitud de arranque
   - Descarga por red
   - Ejecución en memoria RAM

---

### 3.2. Estructura de Active Directory en Samba 4

| OU Principal | OU Hija | Propósito |
|--------------|---------|-----------|
| `OU_Usuarios` | `Usuarios_Moviles` | Usuarios con GPO de Redirección activa |
| `OU_Equipos` | `Equipos_Ligeros` | Equipos Thin Client sin disco |
| `OU_Servicios` | `Cuentas_Servicio` | Unión automática al dominio |

---

### 3.3. Configuración del Servidor de Archivos (Samba)

#### Recurso compartido:
- **Ruta local:** `/srv/samba/perfiles`

#### Características:
- ACLs extendidas
- Compatibilidad NTFS
- Seguridad por usuario
- Almacenamiento centralizado

---

## 4. Desarrollo e Implementación

### 4.1. Configuración del Servidor Linux
Se configura el rol de Domain Controller en Linux mediante:

```bash
samba-tool domain provision \
  --use-rfc2307 \
  --realm=DOMINIO.LOCAL \
  --domain=DOMINIO \
  --server-role=dc
```

## 4.2. Preparación de la Imagen y Automatización

Se personaliza el archivo `unattend.xml` para que el cliente Windows se una automáticamente al dominio Linux durante el arranque:

```xml
<UnattendedJoin>
    <Identification>
        <JoinDomain>proyecto.local</JoinDomain>
        <MachineObjectOU>OU=Equipos_Ligeros,DC=proyecto,DC=local</MachineObjectOU>
        <Credentials>
            <Domain>proyecto.local</Domain>
            <Username>join_user</Username>
            <Password>ContraseñaSegura</Password>
        </Credentials>
    </Identification>
</UnattendedJoin>
```
## 5. Pruebas y Resultados
###5.1. Protocolo de Pruebas

Se utiliza un cliente virtual con:

0 GB de disco duro
4 GB de RAM
##5.2. Resultados Obtenidos
Arranque PXE: Exitoso. El cliente carga Windows PE desde el servidor Linux en memoria RAM.
Autenticación: El usuario inicia sesión contra el AD de Samba 4.
Persistencia de Datos: Se crea un archivo en el Escritorio del cliente y se verifica su existencia física en el servidor Linux en la ruta:
/srv/samba/perfiles/
Consumo de Recursos: El servidor Linux mantiene un consumo bajo de CPU, demostrando alta eficiencia comparado con Windows Server.
#6. Conclusiones y Futuras Líneas
###6.1. Conclusiones

Se ha cumplido el objetivo de crear un sistema de despliegue centralizado donde Linux gestiona la identidad y el almacenamiento, y Windows provee la interfaz de usuario. La solución es:

Escalable
Segura
De bajo mantenimiento técnico
##6.2. Futuras Líneas de Desarrollo
VDI con Linux: Implementar escritorios virtuales completos mediante KVM en el servidor.
Alta Disponibilidad: Configurar un segundo DC de Samba 4 para evitar puntos únicos de fallo.
Seguridad Avanzada: Implementar autenticación de doble factor (2FA) en el inicio de sesión del Thin Client.
📚 Bibliografía y Recursos
Documentación oficial de Samba Wiki
Microsoft Docs: Windows PE Customization
