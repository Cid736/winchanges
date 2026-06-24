# WinToys

TUI de administración del sistema Windows en PowerShell — sin instalación, sin dependencias externas.

## Características

- **7 secciones** interactivas en terminal
- Muestra información del sistema en tiempo real (SO, CPU, RAM, disco, GPU, red)
- Control de privacidad: telemetría, anuncios, Cortana, DiagTrack
- Gestión del plan de energía, Game Mode, SysMain, WSearch
- Limpieza de carpetas temporales, caché de Windows Update, Prefetch, Event Log
- Eliminación de bloatware UWP (Xbox, Bing, Skype, etc.)
- Control de servicios del sistema con advertencias de seguridad
- Herramientas de red: ping, traceroute, flush DNS, reset TCP/IP, DHCP

## Uso

```powershell
powershell -ExecutionPolicy Bypass -File wintoys.ps1
```

Para acceso completo, ejecutar como Administrador:

```
Clic derecho en PowerShell → Ejecutar como administrador
```

## Secciones

| # | Sección | Requiere admin |
|---|---------|----------------|
| 1 | Sistema — info hardware, SO, uptime | No |
| 2 | Privacidad — telemetría, anuncios, historial | Sí |
| 3 | Rendimiento — plan energía, Game Mode, servicios | Sí |
| 4 | Limpieza — temp, caché, papelera, Event Log | Sí |
| 5 | Aplicaciones — eliminar bloatware UWP | Sí |
| 6 | Servicios — activar / desactivar servicios | Sí |
| 7 | Red — info, ping, DNS, TCP/IP, DHCP | Parcial |

## Requisitos

- Windows 10 / 11
- PowerShell 5.1 o superior (incluido en Windows)

## Capturas

```
  +----------------------------------------------------------+
  |   W I N T O Y S  v1.0  --  Herramientas del sistema     |
  +----------------------------------------------------------+
  [ADMIN] acceso completo

  [1]  Sistema          -- Hardware, SO, RAM, disco
  [2]  Privacidad       -- Telemetria, anuncios, historial
  [3]  Rendimiento      -- Plan energia, Game Mode, servicios
  [4]  Limpieza         -- Temp, cache, papelera, Event Log
  [5]  Aplicaciones     -- Eliminar bloatware UWP
  [6]  Servicios        -- Activar / desactivar servicios
  [7]  Red              -- Info, ping, DNS, TCP/IP reset

  [0]  Salir
```

## Licencia

MIT
