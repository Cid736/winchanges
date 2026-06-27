# Bug Log — WinChanges

No se han encontrado vulnerabilidades ni bugs significativos en la revisión automatizada de seguridad del 2026-06-25 (Revisión 1).

---

## 2026-06-25 — Revisión 2 (Auditoría profesional completa)

### [HIGH] `$ErrorActionPreference = 'SilentlyContinue'` ocultaba errores críticos
- **Archivo:** `winchanges.ps1` línea 6
- **Descripción:** El valor global `SilentlyContinue` impedía que cualquier error de cmdlet (disco lleno, permisos insuficientes, servicios no encontrados) fuera visible. Operaciones fallidas silenciosas pueden dejar el sistema en estado inconsistente.
- **Fix:** Cambiado a `$ErrorActionPreference = 'Stop'`. Los cmdlets con fallos esperados siguen usando `-EA SilentlyContinue` individualmente donde tiene sentido.

### [MEDIA] Borrado de Event Logs sin confirmación explícita
- **Archivo:** `winchanges.ps1` línea 339/358
- **Descripción:** La opción "Limpiar registros de eventos" y el modo "Limpiar TODO" borraban los event logs del sistema sin ninguna advertencia ni solicitud de confirmación. Esta operación es irreversible y destruye evidencia forense de seguridad.
- **Fix:** La opción [7] ahora muestra una advertencia prominente y requiere escribir `CONFIRMAR` explícitamente. La opción [A] (Limpiar TODO) ya no incluye el borrado de event logs automáticamente.

---

## 2026-06-28 — Revisión 3 (Auditoría profesional completa)

No se han encontrado vulnerabilidades nuevas.

### Resultado de la auditoría
- No se encontró command injection: el script no usa `Invoke-Expression`, `[scriptblock]::Create`, ni `&` con input del usuario. Todas las operaciones son llamadas directas a cmdlets de PowerShell.
- Las rutas de registro están hardcodeadas; no se construyen con input del usuario.
- El input del usuario (menú numérico) se valida con `$opt -match '^\d+$'` y se comprueba contra rangos antes de indexar arrays.
- `Remove-Item` usa rutas hardcodeadas (`$env:TEMP\*`, `C:\Windows\Temp\*`), sin posibilidad de path traversal.
- La confirmación de borrado de Event Log (`CONFIRMAR`) protege contra uso accidental.
- `$ErrorActionPreference = 'Stop'` garantiza que los errores no silenciosos lleguen al usuario.
