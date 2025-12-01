
-----



## Este bloque contiene la estructura de directorios y el contenido de los archivos necesarios:

### Estructura de Directorios

```
thin-client-pxe/
├── server_config/
│   ├── dhcpd.conf.snippet
│   ├── exports.nfs
│   └── pxe_config/
│       └── default
├── firmware_client/
│   ├── bootloader_core.c
│   └── startup.s
└── README.md
```

### Contenido de los Archivos

### `README.md`

````markdown
# 🚀 Thin Client PXE Boot Project - Guía de Implementación

Este repositorio contiene la estructura y los archivos de configuración necesarios para establecer un entorno de **arranque sin disco (Diskless Boot)** para clientes ligeros basados en **Linux** utilizando el protocolo **PXE (Preboot Execution Environment)**.

## Requisitos del Servidor

El servidor debe tener instalados y configurados los siguientes servicios (ej. en Ubuntu/Debian):
1.  **Servidor DHCP** (Ej. `isc-dhcp-server`)
2.  **Servidor TFTP** (Ej. `tftpd-hpa`)
3.  **Servidor NFS** (Ej. `nfs-kernel-server`)

## 📋 Pasos Clave de Configuración

### 1. Preparación del Sistema de Archivos Raíz (NFS)

1.  Crea la carpeta raíz: `sudo mkdir -p /export/thinclient`
2.  Prepara tu sistema operativo Linux minimalista dentro de `/export/thinclient`.
3.  Copia el contenido de `server_config/exports.nfs` a `/etc/exports` y aplica los cambios:
    ```bash
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server
    ```

### 2. Configuración TFTP y PXELINUX

1.  Instala TFTP y Syslinux (`sudo apt install tftpd-hpa syslinux-common`).
2.  El directorio raíz de TFTP suele ser `/var/lib/tftpboot`. Crea el directorio de configuración: `sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg`
3.  Copia el bootloader y los archivos de tu kernel a `/var/lib/tftpboot`:
    ```bash
    sudo cp /usr/lib/syslinux/modules/bios/pxelinux.0 /var/lib/tftpboot/
    sudo cp <ruta_a_tu_kernel>/vmlinuz /var/lib/tftpboot/
    sudo cp <ruta_a_tu_initrd>/initrd.img /var/lib/tftpboot/
    ```
4.  Copia el contenido de `server_config/pxe_config/default` a `/var/lib/tftpboot/pxelinux.cfg/default`, **ajustando la IP del servidor** en el archivo.

### 3. Configuración DHCP

1.  Edita `/etc/dhcp/dhcpd.conf` e inserta el snippet de `server_config/dhcpd.conf.snippet` dentro de tu subred, ajustando la IP de `next-server`.
2.  Reinicia DHCP: `sudo systemctl restart isc-dhcp-server`.

---

## 📁 Contenido de Archivos de Configuración (`server_config/`)

### `server_config/dhcpd.conf.snippet` (ISC-DHCP-Server)

```ini
# --- Opciones PXE ---
# Sustituye 192.168.1.10 por la IP de tu servidor TFTP
next-server 192.168.1.10;  

# Indica el archivo de arranque (Bootloader de red)
filename "pxelinux.0"; 
````

### `server_config/exports.nfs` (NFS Root Filesystem)

```
# Ruta de tu sistema de archivos Linux minimalista para el thin client
/export/thinclient *(rw,sync,no_subtree_check,no_root_squash)
```

### `server_config/pxe_config/default` (Menú PXELINUX)

```ini
# Configuración por defecto para PXELINUX

DEFAULT thinclient_nfs
PROMPT 0
TIMEOUT 300

LABEL thinclient_nfs
    MENU LABEL 🚀 Thin Client - Arranque por Red (NFS)
    # KERNEL y INITRD deben estar en el directorio raiz del TFTP
    KERNEL vmlinuz 
    INITRD initrd.img
    
    # IMPORTANTE: Reemplaza 192.168.1.10 con la IP de tu servidor
    APPEND root=/dev/nfs nfsroot=192.168.1.10:/export/thinclient ip=dhcp rw
    
LABEL local_boot
    MENU LABEL Arranque local (HDD/SSD)
    LOCALBOOT 0
```

-----

## 💻 Código de Bootloader Embebido (`firmware_client/`)

Esta carpeta es **OPCIONAL** y solo es necesaria si estás construyendo el thin client con un **microcontrolador embebido (ej. ARM Cortex-M)** que no tiene soporte PXE de fábrica.

### `firmware_client/bootloader_core.c`

```c
#include <stdint.h> 

// --- CONSTANTES DE MEMORIA (Ejemplo ARM Cortex-M) ---
#define FLASH_BASE_ADDR            0x08000000UL 
#define BOOTLOADER_SIZE_BYTES      0x00004000UL 
#define APPLICATION_START_ADDR     (FLASH_BASE_ADDR + BOOTLOADER_SIZE_BYTES)

#define APPLICATION_STACK_POINTER  (*(volatile uint32_t*)APPLICATION_START_ADDR)
#define APPLICATION_RESET_VECTOR   (*(volatile uint32_t*)(APPLICATION_START_ADDR + 4))

typedef void (*pFunction)(void);

// --- DECLARACIONES DE DRIVERS ESPECÍFICOS ---
// Deben ser implementadas usando librerías HAL o registros del chip.
extern void System_Init_Min(void);       
extern int Check_For_Update_Request(void); 
extern void Enter_Flash_Mode(void);      
extern void __set_MSP(uint32_t topOfMainStack);


void Jump_To_Application(void) {
    pFunction application_entry;

    // Verificación de integridad básica
    if (APPLICATION_RESET_VECTOR == 0xFFFFFFFFUL) {
        while(1) {} // Error: SO corrupto
    }

    application_entry = (pFunction)APPLICATION_RESET_VECTOR;

    // Establecer la pila de la aplicación
    __set_MSP(APPLICATION_STACK_POINTER);

    // Saltar a la aplicación
    application_entry();
}

void Bootloader_main(void) {
    System_Init_Min();

    if (Check_For_Update_Request()) {
        Enter_Flash_Mode(); 
    }

    Jump_To_Application();

    while(1) {} 
}
```

### `firmware_client/startup.s`

**(Nota: Este código es altamente dependiente de la arquitectura y el compilador; solo es un marcador de posición.)**

```assembly
// Placeholder para el código Assembly de inicialización.
// Debe configurar los vectores de interrupción y saltar a Bootloader_main.

.section .vectors
    .word _stack_end
    .word Reset_Handler

.section .text
.global Reset_Handler
Reset_Handler:
    // ... Código de inicialización de registros ...
    bl  Bootloader_main 
    b . 
```
