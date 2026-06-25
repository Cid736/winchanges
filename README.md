<p align="center">
  <a href="#english">🇬🇧 English</a> &nbsp;·&nbsp; <a href="#español">🇪🇸 Español</a>
</p>

---

<a name="english"></a>

# WinChanges

Windows system management TUI in PowerShell — no installation, no external dependencies.

## Features

- **7 interactive sections** in the terminal
- Real-time system info (OS, CPU, RAM, disk, GPU, network)
- Privacy controls: telemetry, ads, Cortana, DiagTrack service
- Power plan management, Game Mode, SysMain, WSearch
- Cleanup: temp folders, Windows Update cache, Prefetch, Event Log
- UWP bloatware removal (Xbox, Bing, Skype, etc.)
- Service management with safety warnings
- Network tools: ping, traceroute, DNS flush, TCP/IP reset, DHCP renew

## Usage

```powershell
powershell -ExecutionPolicy Bypass -File winchanges.ps1
```

For full access, run as Administrator:

```
Right-click PowerShell → Run as administrator
```

## Sections

| # | Section | Requires admin |
|---|---------|----------------|
| 1 | System — hardware info, OS, uptime | No |
| 2 | Privacy — telemetry, ads, activity history | Yes |
| 3 | Performance — power plan, Game Mode, services | Yes |
| 4 | Cleanup — temp, cache, recycle bin, Event Log | Yes |
| 5 | Apps — remove UWP bloatware | Yes |
| 6 | Services — enable / disable system services | Yes |
| 7 | Network — info, ping, DNS, TCP/IP, DHCP | Partial |

## Requirements

- Windows 10 / 11
- PowerShell 5.1 or higher (included in Windows)

## Preview

```
  +----------------------------------------------------------+
  |   W I N C H A N G E S  v1.0  --  System tools          |
  +----------------------------------------------------------+
  [ADMIN] full access

  [1]  System          -- Hardware, OS, RAM, disk
  [2]  Privacy         -- Telemetry, ads, history
  [3]  Performance     -- Power plan, Game Mode, services
  [4]  Cleanup         -- Temp, cache, recycle bin, Event Log
  [5]  Apps            -- Remove UWP bloatware
  [6]  Services        -- Enable / disable services
  [7]  Network         -- Info, ping, DNS, TCP/IP reset

  [0]  Exit
```

## License

MIT

## Security

Automated security reviews are powered by [Claude](https://claude.ai) (Anthropic AI) and run on every significant change to detect vulnerabilities, insecure patterns and dependency risks. Findings are tracked in [`BUGLOG.md`](BUGLOG.md).

**Last review:** 2026-06-25 — No significant issues found.

Found a vulnerability? Open an issue or contact directly.

---

<a name="español"></a>

# WinChanges

TUI de administración del sistema Windows en PowerShell — sin instalación, sin dependencias externas.

## Características

- **7 secciones** interactivas en terminal
- Información del sistema en tiempo real (SO, CPU, RAM, disco, GPU, red)
- Control de privacidad: telemetría, anuncios, Cortana, servicio DiagTrack
- Gestión del plan de energía, Game Mode, SysMain, WSearch
- Limpieza de carpetas temporales, caché de Windows Update, Prefetch, Event Log
- Eliminación de bloatware UWP (Xbox, Bing, Skype, etc.)
- Control de servicios del sistema con advertencias de seguridad
- Herramientas de red: ping, traceroute, flush DNS, reset TCP/IP, DHCP

## Uso

```powershell
powershell -ExecutionPolicy Bypass -File winchanges.ps1
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

## Seguridad

Las revisiones de seguridad automatizadas utilizan [Claude](https://claude.ai) (Anthropic AI) y se ejecutan en cada cambio significativo para detectar vulnerabilidades, patrones inseguros y riesgos en dependencias. Los hallazgos se registran en [`BUGLOG.md`](BUGLOG.md).

**Última revisión:** 2026-06-25 (rev 2) — 2 vulnerabilidades encontradas y parcheadas (1 alta, 1 media). Revisión 2: `$ErrorActionPreference` cambiado a `Stop`, confirmación explícita requerida para borrado de Event Logs.

¿Encontraste una vulnerabilidad? Abre un issue o contacta directamente.
## Licencia

MIT
