-----

# 📝 MEMORIA DEL PROYECTO FINAL DE GRADO SUPERIOR

## Sistema Centralizado de Despliegue de SO (SDAD-SO) con Gestión de Perfiles Móviles mediante Active Directory para Clientes Ligeros

### Autor(a): [José Ángel vargas lobato]

### Ciclo Formativo: [ASIR]

### Fecha: [12,2025]

-----

## 1\. Introducción y Justificación

### 1.1. Resumen Ejecutivo

El proyecto implementa una infraestructura de red robusta para el despliegue de un **Entorno Operativo Ligero (Thin Client)** mediante **PXE Boot** y **WDS**. La solución integra **Active Directory (AD)** para gestionar usuarios, aplicar políticas de seguridad (GPO) y habilitar la **gestión de perfiles móviles** mediante redirección de carpetas. Esto permite a los equipos arrancar y operar sin necesidad de almacenamiento local (disco duro), optimizando la gestión de recursos y la movilidad de los usuarios.

### 1.2. Justificación y Motivación

Este sistema de despliegue resuelve la ineficiencia de las instalaciones tradicionales y aporta valor crítico para entornos de **Thin Client** y **Bare Metal**:

  * **Eficiencia y Coste:** Se reduce el coste de *hardware* al eliminar la necesidad de discos duros en los clientes y se minimiza el tiempo de mantenimiento.
  * **Seguridad:** El sistema operativo base se carga en la memoria **RAM** del cliente y se inicia desde una fuente centralizada y controlada (WDS/TFTP).
  * **Movilidad de Usuarios:** La integración con AD y la **Redirección de Carpetas** aseguran que los datos y la configuración del usuario sigan al usuario, no al equipo físico.

### 1.3. Alcance y Limitaciones

El proyecto cubre el diseño, la implementación y la validación del servidor de despliegue y el Controlador de Dominio. El foco principal es el despliegue de un **Entorno Windows PE personalizado (SO Ligero)** que opera en RAM, la unión a dominio y la aplicación de GPO de seguridad y Redirección de Carpetas.

-----

## 2\. Marco Teórico y Tecnológico

### 2.1. Conceptos Clave del Arranque por Red (PXE)

  * **PXE (Preboot Execution Environment):** Protocolo que permite al cliente iniciar la carga del sistema operativo **directamente desde la red** sin requerir disco local.
  * **DHCP y TFTP:** DHCP proporciona la dirección IP y la información de arranque (Opciones 66 y 67). **TFTP** (Trivial File Transfer Protocol) se encarga de transferir el pequeño *bootloader* inicial al cliente.

### 2.2. Thin Client y Windows PE

  * **Thin Client / Cliente Ligero sin Disco:** Equipo que depende de la red para su funcionamiento, cargando el sistema operativo y las aplicaciones desde un servidor central.
  * **Windows PE (Preinstallation Environment):** En este proyecto, Windows PE se personaliza para actuar como el **Sistema Operativo Ligero (Thin Client OS)**, cargándose completamente en la **memoria RAM** del cliente para la operación de red y la autenticación de usuario.

### 2.3. Active Directory y Gestión de Movilidad

  * **AD DS (Active Directory Domain Services):** Proporciona la autenticación de usuarios y la gestión de políticas centralizada.
  * **Redirección de Carpetas:** Mecanismo GPO esencial para la **gestión de usuarios móviles**. Las carpetas clave (Documentos, Escritorio) se almacenan en un **recurso compartido de red** en lugar de en el almacenamiento local (que no existe en el *Thin Client*), permitiendo al usuario acceder a sus datos desde cualquier equipo.

-----

## 3\. Planificación y Diseño de la Solución

### 3.1. Arquitectura del Sistema

La arquitectura es **Cliente-Servidor**. El Servidor Principal (Windows Server) consolida los roles de **DC, WDS, DHCP y Servidor de Archivos**. El cliente inicia el proceso por PXE y carga el SO ligero directamente en su memoria.

### 3.2. Diseño de la Estructura de Active Directory

Se implementa una estructura de OU jerárquica para la correcta aplicación de políticas:

| OU Principal | OU Hija | Propósito |
| :--- | :--- | :--- |
| `OU_Usuarios` | `Usuarios_Móviles` | Aplica la GPO de **Redirección de Carpetas** y el entorno de usuario. |
| **`OU_Equipos`** | **`Equipos_Ligeros`** | Contiene las cuentas de equipo. Es el destino de unión automática. |
| `OU_Servicios` | `Cuentas_Servicio` | Almacena el usuario con permisos de unión a dominio. |

### 3.3. Configuración del Servidor de Archivos

Se crea un recurso compartido centralizado (ej. `\\DC01\Perfiles$`) con permisos NTFS y de recurso compartido adecuados para que solo los usuarios puedan acceder a sus propios directorios de perfil. Esta ruta será el destino de la GPO de Redirección de Carpetas.

### 3.4. Diseño de Directivas de Grupo (GPO)

Se definen las GPO clave para validar la funcionalidad del sistema:

1.  **GPO\_01\_Arranque\_PXE:** Configuración de las restricciones del Entorno Ligero.
2.  **GPO\_02\_Redireccion\_Carpetas:** **CRÍTICA:** Vinculada a `Usuarios_Móviles`. Redirige las carpetas **Documentos** y **Escritorio** al servidor de archivos, garantizando la movilidad de los datos.
3.  **GPO\_03\_Entorno\_Usuario:** Configura el fondo de escritorio y el entorno de red de los usuarios de dominio.

-----

## 4\. Desarrollo e Implementación

### 4.1. Configuración de Infraestructura

  * Instalación de Windows Server y promoción a **Controlador de Dominio (DC)**.
  * Configuración de **DHCP** (Opciones 66/67).
  * Instalación y configuración de los roles **WDS** y **Servidor de Archivos**.

### 4.2. Implementación de AD, Servidor de Archivos y GPO

  * Creación de la estructura de OUs.
  * Creación de la carpeta compartida `\\DC01\Perfiles$`.
  * Implementación y vinculación de la **GPO\_02\_Redireccion\_Carpetas** a la OU `Usuarios_Móviles`.

### 4.3. Preparación de la Imagen y Automatización del Arranque

  * Personalización del **Windows PE** para incluir los controladores y utilidades necesarias.

  * El archivo de configuración **`unattend.xml`** se personaliza para el entorno de Windows PE, asegurando que, al cargarse, el sistema tenga la configuración de red y las credenciales para la autenticación de red/AD.

  * **Lógica Clave del `unattend.xml` (Unión a Dominio para Servicios):**

<!-- end list -->

```xml
<UnattendedJoin>
    <Identification>
        <JoinDomain>dominio.local</JoinDomain>
        <MachineObjectOU>OU=Equipos_Ligeros,OU=Equipos,DC=dominio,DC=local</MachineObjectOU>
        <Credentials>
            <Domain>dominio.local</Domain>
            <Username>svc_join</Username>
            <Password>MiPasswordSegura</Password>
        </Credentials>
    </Identification>
</UnattendedJoin>
```

-----

## 5\. Pruebas y Resultados

### 5.1. Protocolo de Pruebas

El escenario de prueba se centra en la funcionalidad del Thin Client: Un cliente virtual sin disco duro inicia el arranque PXE.

### 5.2. Prueba de Carga en Memoria (Thin Client Operativo)

  * **Resultado:** El equipo inicia por PXE, descarga el *bootloader* y carga el **Windows PE personalizado** directamente en la RAM, presentando el entorno de usuario. Se confirma la **ausencia de actividad en el disco duro local**.
  * **Verificación de AD:** Se verifica que la cuenta de equipo aparece en la **OU `Equipos_Ligeros`** y que la autenticación de red funciona.

### 5.3. Prueba de Gestión de Usuarios Móviles (Redirección de Carpetas)

  * **Procedimiento:** Un usuario de `Usuarios_Móviles` inicia sesión en el Thin Client. Crea un archivo en el Escritorio.
  * **Resultado:** Se comprueba directamente en el Servidor de Archivos (`\\DC01\Perfiles$`) que el archivo aparece en la carpeta del usuario. Se confirma que la GPO de Redirección de Carpetas se aplicó correctamente, asegurando la movilidad del usuario.

### 5.4. Evaluación de Objetivos

Se confirma el cumplimiento de todos los objetivos, destacando la viabilidad de la solución de Thin Client sin disco mediante la infraestructura de red.

-----

## 6\. Conclusiones y Futuras Líneas de Desarrollo

### 6.1. Conclusiones

El proyecto ha implementado con éxito una solución avanzada de despliegue de **Thin Clients basados en Windows PE**, superando el desafío de la falta de almacenamiento local. La integración con Active Directory y la gestión de la movilidad de perfiles no solo automatizan la puesta en marcha, sino que crean un entorno de trabajo flexible y seguro.

### 6.2. Futuras Líneas de Desarrollo

1.  Implementación de **VDI (Virtual Desktop Infrastructure)** para ofrecer escritorios completos desde el servidor, en lugar de solo Windows PE.
2.  Uso de **PowerShell** avanzado para automatizar la gestión de las cuentas de equipo en la OU de AD.
3.  Despliegue de un sistema operativo ligero basado en Linux (ej. Thinstation) junto con la solución de Windows, creando un menú PXE dual.

-----

## Anexos y Bibliografía

  * **Anexo A:** Manual Operativo para iniciar un despliegue.
  * **Anexo B:** Capturas de la configuración de WDS y la consola de Gestión de Directivas de Grupo (GPO).
  * **Bibliografía:** Lista de fuentes técnicas.-----
### https://github.com/lobato18/proyectoASIR_clientes_virtuale/tree/main
