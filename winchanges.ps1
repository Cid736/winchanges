#Requires -Version 5.1
# winchanges.ps1 -- Herramientas del sistema para Windows
# Uso: powershell -ExecutionPolicy Bypass -File winchanges.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$host.UI.RawUI.WindowTitle = "WinChanges v1.0"

function W   { param($t, $c = 'White') Write-Host $t -ForegroundColor $c -NoNewline }
function WL  { param($t = '', $c = 'White') Write-Host $t -ForegroundColor $c }
function Sep {
    $s = "  " + ("-" * 56)
    WL $s DarkGray
}
function Pause { Read-Host "`n  Pulsa Enter para continuar" | Out-Null }

function Is-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Need-Admin {
    if (-not (Is-Admin)) {
        WL "`n  [!] Requiere ejecutar como Administrador." Red
        WL "      Clic derecho en PowerShell -> Ejecutar como administrador" DarkGray
        Pause; return $false
    }
    return $true
}

function Reg-Get {
    param($p, $n, $d = $null)
    try { (Get-ItemProperty -Path $p -Name $n -EA Stop).$n } catch { $d }
}

function Reg-Set {
    param($p, $n, $v, $t = 'DWord')
    if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
    Set-ItemProperty $p $n $v -Type $t | Out-Null
}

function ON-OFF {
    param($v)
    if ($v) { W ' [ON] ' Green } else { W ' [OFF]' Red }
}

function Banner {
    Clear-Host
    WL ""
    WL "  +----------------------------------------------------------+" Cyan
    WL "  |   W I N C H A N G E S  v1.0  --  Herramientas del sistema     |" Cyan
    WL "  +----------------------------------------------------------+" Cyan
    if (Is-Admin) {
        WL "  [ADMIN] acceso completo" Green
    } else {
        WL "  [sin admin] -- algunas opciones requieren Administrador" Yellow
    }
    WL ""
}

# ── 1. SISTEMA ────────────────────────────────────────────────────────────────
function Show-System {
    Banner
    WL "  -- INFORMACION DEL SISTEMA --" Yellow
    WL ""

    $os     = Get-CimInstance Win32_OperatingSystem
    $cpu    = Get-CimInstance Win32_Processor | Select-Object -First 1
    $memGB  = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeGB = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedGB = [Math]::Round($memGB - $freeGB, 1)
    $boot   = $os.LastBootUpTime
    $up     = [DateTime]::Now - $boot
    $upStr  = "{0}d {1}h {2}m" -f [int]$up.TotalDays, $up.Hours, $up.Minutes

    W "  SO           : " DarkGray
    WL "$($os.Caption) ($($os.OSArchitecture))" White
    W "  Version      : " DarkGray
    WL "Build $($os.BuildNumber)  --  $($os.Version)" White
    W "  CPU          : " DarkGray
    WL $cpu.Name.Trim() White
    W "  Nucleos      : " DarkGray
    WL "$($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads" White

    $ramStr = "{0} GB usados / {1} GB total  ({2} GB libres)" -f $usedGB, $memGB, $freeGB
    W "  RAM          : " DarkGray
    WL $ramStr White

    $disk   = Get-PSDrive C
    $dUsed  = [Math]::Round($disk.Used / 1GB, 1)
    $dFree  = [Math]::Round($disk.Free / 1GB, 1)
    $dTotal = [Math]::Round($dUsed + $dFree, 1)
    $dskStr = "{0} GB usados / {1} GB total  ({2} GB libres)" -f $dUsed, $dTotal, $dFree
    W "  Disco C:     : " DarkGray
    WL $dskStr White

    W "  Uptime       : " DarkGray
    WL $upStr White
    W "  Hostname     : " DarkGray
    WL $env:COMPUTERNAME White
    W "  Usuario      : " DarkGray
    WL "$env:USERDOMAIN\$env:USERNAME" White
    W "  Admin        : " DarkGray
    if (Is-Admin) { WL "Si" Green } else { WL "No" Yellow }

    Sep

    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    if ($gpu) {
        W "  GPU          : " DarkGray
        WL $gpu.Name White
        $vram = [Math]::Round($gpu.AdapterRAM / 1GB, 1)
        if ($vram -gt 0) {
            W "  VRAM         : " DarkGray
            WL "$vram GB" White
        }
    }

    $nets = Get-NetIPAddress -AddressFamily IPv4 -EA SilentlyContinue |
            Where-Object { $_.InterfaceAlias -notmatch 'Loopback' }
    foreach ($n in $nets | Select-Object -First 3) {
        $ipLine = "{0}/{1}  ({2})" -f $n.IPAddress, $n.PrefixLength, $n.InterfaceAlias
        W "  IP           : " DarkGray
        WL $ipLine White
    }

    Sep

    $planRaw = (powercfg /getactivescheme 2>$null)
    if ($planRaw -match '\((.+)\)') {
        W "  Plan energia : " DarkGray
        WL $Matches[1] White
    }

    WL ""
    Pause
}

# ── 2. PRIVACIDAD ─────────────────────────────────────────────────────────────
function Show-Privacy {
    while ($true) {
        Banner
        WL "  -- PRIVACIDAD --" Yellow
        WL ""

        $tele    = Reg-Get 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
        $ads     = Reg-Get 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' 1
        $tips    = Reg-Get 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 1
        $feed    = Reg-Get 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 1
        $cortana = Reg-Get 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 1
        $lockAds = Reg-Get 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenEnabled' 1
        $diagSvc = (Get-Service DiagTrack -EA SilentlyContinue).StartType

        W "  [1]"; ON-OFF ($tele    -eq 0);          WL "  Telemetria desactivada" White
        W "  [2]"; ON-OFF ($ads     -eq 0);          WL "  Anuncios en el menu Inicio" White
        W "  [3]"; ON-OFF ($tips    -eq 0);          WL "  Sugerencias de apps" White
        W "  [4]"; ON-OFF ($feed    -eq 0);          WL "  Historial de actividad" White
        W "  [5]"; ON-OFF ($cortana -eq 0);          WL "  Cortana desactivada" White
        W "  [6]"; ON-OFF ($lockAds -eq 0);          WL "  Anuncios en pantalla de bloqueo" White
        W "  [7]"; ON-OFF ($diagSvc -eq 'Disabled'); WL "  Servicio telemetria DiagTrack desactivado" White
        WL ""
        WL "  [A]  Aplicar TODO -- maxima privacidad" Yellow
        WL "  [R]  Restaurar valores por defecto" DarkGray
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  > " Cyan
        $opt = Read-Host

        # entrada vacia: redibujar menu; '0' no requiere admin
        if (-not $opt -or ($opt -ne '0' -and !(Need-Admin))) { continue }

        switch ($opt.ToUpper()) {
            '1' {
                if ($tele -eq 0) { Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1 }
                else             { Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0 }
            }
            '2' {
                $v = if ($ads -eq 0) { 1 } else { 0 }
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' $v
            }
            '3' {
                $v = if ($tips -eq 0) { 1 } else { 0 }
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' $v
            }
            '4' {
                $v = if ($feed -eq 0) { 1 } else { 0 }
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' $v
            }
            '5' {
                $v = if ($cortana -eq 0) { 1 } else { 0 }
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' $v
            }
            '6' {
                $v = if ($lockAds -eq 0) { 1 } else { 0 }
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenEnabled' $v
            }
            '7' {
                if ($diagSvc -eq 'Disabled') {
                    Set-Service DiagTrack -StartupType Automatic -EA SilentlyContinue
                    Start-Service DiagTrack -EA SilentlyContinue
                } else {
                    Stop-Service DiagTrack -Force -EA SilentlyContinue
                    Set-Service DiagTrack -StartupType Disabled -EA SilentlyContinue
                }
            }
            'A' {
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' 0
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 0
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenEnabled' 0
                Stop-Service DiagTrack -Force -EA SilentlyContinue
                Set-Service DiagTrack -StartupType Disabled -EA SilentlyContinue
                WL "`n  [OK] Privacidad maxima aplicada." Green
                Pause
            }
            'R' {
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' 1
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 1
                Reg-Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 1
                Set-Service DiagTrack -StartupType Automatic -EA SilentlyContinue
                Start-Service DiagTrack -EA SilentlyContinue
                WL "`n  [OK] Valores de Microsoft restaurados." Green
                Pause
            }
            '0' { return }
        }
    }
}

# ── 3. RENDIMIENTO ────────────────────────────────────────────────────────────
function Show-Performance {
    while ($true) {
        Banner
        WL "  -- RENDIMIENTO --" Yellow
        WL ""

        $planRaw    = (powercfg /getactivescheme 2>$null)
        $planName   = if ($planRaw -match '\((.+)\)') { $Matches[1] } else { 'Desconocido' }
        $hibFile    = Test-Path "$env:SystemDrive\hiberfil.sys"
        $game       = Reg-Get 'HKCU:\SOFTWARE\Microsoft\GameBar' 'AllowAutoGameMode' 0
        $sysmainSvc = Get-Service SysMain -EA SilentlyContinue
        $wsearchSvc = Get-Service WSearch -EA SilentlyContinue
        # Si el servicio no existe en este sistema, tratarlo como Disabled
        $sysmain    = if ($sysmainSvc) { $sysmainSvc.StartType } else { 'Disabled' }
        $wsearch    = if ($wsearchSvc) { $wsearchSvc.StartType } else { 'Disabled' }

        W "  Plan actual  : " DarkGray
        WL "[ $planName ]" Cyan
        WL ""
        WL "  [1]  Plan -> Alto rendimiento" White
        WL "  [2]  Plan -> Balanceado (por defecto)" White
        WL "  [3]  Plan -> Ahorro de energia" White
        Sep
        W "  [4]"; ON-OFF $hibFile;                    WL "  Hibernacion" White
        W "  [5]"; ON-OFF ($game -eq 1);               WL "  Game Mode" White
        W "  [6]"; ON-OFF ($sysmain -ne 'Disabled');   WL "  SysMain / Superfetch" White
        W "  [7]"; ON-OFF ($wsearch -ne 'Disabled');   WL "  Indexacion de busqueda (WSearch)" White
        WL ""
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  > " Cyan
        $opt = Read-Host

        if (-not $opt -or ($opt -ne '0' -and !(Need-Admin))) { continue }

        switch ($opt) {
            '1' { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c; WL "`n  [OK] Plan -> Alto rendimiento" Green; Pause }
            '2' { powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e; WL "`n  [OK] Plan -> Balanceado" Green; Pause }
            '3' { powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a; WL "`n  [OK] Plan -> Ahorro de energia" Green; Pause }
            '4' {
                if ($hibFile) { powercfg /h off; WL "`n  [OK] Hibernacion desactivada." Green }
                else          { powercfg /h on;  WL "`n  [OK] Hibernacion activada." Green }
                Pause
            }
            '5' {
                $v = if ($game -eq 1) { 0 } else { 1 }
                Reg-Set 'HKCU:\SOFTWARE\Microsoft\GameBar' 'AllowAutoGameMode' $v
            }
            '6' {
                if ($sysmain -ne 'Disabled') {
                    Stop-Service SysMain -Force -EA SilentlyContinue
                    Set-Service  SysMain -StartupType Disabled -EA SilentlyContinue
                    WL "`n  [OK] SysMain desactivado." Green
                } else {
                    Set-Service  SysMain -StartupType Automatic -EA SilentlyContinue
                    Start-Service SysMain -EA SilentlyContinue
                    WL "`n  [OK] SysMain activado." Green
                }
                Pause
            }
            '7' {
                if ($wsearch -ne 'Disabled') {
                    Stop-Service WSearch -Force -EA SilentlyContinue
                    Set-Service  WSearch -StartupType Disabled -EA SilentlyContinue
                    WL "`n  [OK] WSearch desactivado." Green
                } else {
                    Set-Service  WSearch -StartupType Automatic -EA SilentlyContinue
                    Start-Service WSearch -EA SilentlyContinue
                    WL "`n  [OK] WSearch activado." Green
                }
                Pause
            }
            '0' { return }
        }
    }
}

# ── 4. LIMPIEZA ───────────────────────────────────────────────────────────────
function Get-FolderMB {
    param($path)
    if (-not (Test-Path $path)) { return 0 }
    $sum = (Get-ChildItem $path -Recurse -Force -EA SilentlyContinue |
            Measure-Object Length -Sum).Sum
    # [long] convierte $null a 0 si la carpeta esta vacia
    [Math]::Round(([long]$sum / 1MB), 1)
}

function Show-Cleanup {
    while ($true) {
        Banner
        WL "  -- LIMPIEZA --" Yellow
        WL "  Calculando tamanos..." DarkGray

        $t1 = Get-FolderMB $env:TEMP
        $t2 = Get-FolderMB 'C:\Windows\Temp'
        $t3 = Get-FolderMB 'C:\Windows\SoftwareDistribution\Download'
        $t4 = Get-FolderMB 'C:\Windows\Prefetch'

        WL ""
        W "  [1]  Temp usuario               : " DarkGray; WL "$t1 MB" Yellow
        W "  [2]  Temp Windows               : " DarkGray; WL "$t2 MB" Yellow
        W "  [3]  Cache Windows Update       : " DarkGray; WL "$t3 MB" Yellow
        W "  [4]  Prefetch                   : " DarkGray; WL "$t4 MB" Yellow
        WL "  [5]  Vaciar Papelera de reciclaje" White
        WL "  [6]  Limpiar cache DNS" White
        WL "  [7]  Limpiar registros de eventos  [!] IRREVERSIBLE" Red
        WL ""
        WL "  [A]  Limpiar TODO" Yellow
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  > " Cyan
        $opt = Read-Host

        if (-not $opt -or ($opt -ne '0' -and !(Need-Admin))) { continue }

        $any = $false
        $u = $opt.ToUpper()

        if ($u -eq '1' -or $u -eq 'A') { Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue; WL "  [OK] Temp usuario limpiado." Green; $any = $true }
        if ($u -eq '2' -or $u -eq 'A') { Remove-Item 'C:\Windows\Temp\*' -Recurse -Force -EA SilentlyContinue; WL "  [OK] Temp Windows limpiado." Green; $any = $true }
        if ($u -eq '3' -or $u -eq 'A') { Remove-Item 'C:\Windows\SoftwareDistribution\Download\*' -Recurse -Force -EA SilentlyContinue; WL "  [OK] Cache WU limpiado." Green; $any = $true }
        if ($u -eq '4' -or $u -eq 'A') { Remove-Item 'C:\Windows\Prefetch\*' -Recurse -Force -EA SilentlyContinue; WL "  [OK] Prefetch limpiado." Green; $any = $true }
        if ($u -eq '5' -or $u -eq 'A') { Clear-RecycleBin -Force -EA SilentlyContinue; WL "  [OK] Papelera vaciada." Green; $any = $true }
        if ($u -eq '6' -or $u -eq 'A') { Clear-DnsClientCache -EA SilentlyContinue; WL "  [OK] Cache DNS limpiado." Green; $any = $true }
        if ($u -eq '7') {
            WL ""
            WL "  ADVERTENCIA: Esta accion BORRARA todos los registros de eventos del sistema." Yellow
            WL "  Esta operacion es IRREVERSIBLE y destruye evidencia forense." Red
            WL ""
            W "  Escribe CONFIRMAR para continuar (o Enter para cancelar): " Cyan
            $confirm = Read-Host
            if ($confirm -eq 'CONFIRMAR') {
                Get-WinEvent -ListLog * -EA SilentlyContinue |
                    Where-Object { $_.RecordCount -gt 0 } |
                    ForEach-Object {
                        try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) } catch {}
                    }
                WL "  [OK] Event Log limpiado." Green; $any = $true
            } else {
                WL "  [--] Operacion cancelada." DarkGray
            }
        }

        if ($any) { Pause }
        if ($opt -eq '0') { return }
    }
}

# ── 5. APLICACIONES (Bloatware) ───────────────────────────────────────────────
$script:BLOATWARE = @(
    @{ N='Microsoft.3DBuilder';                L='3D Builder'            }
    @{ N='Microsoft.BingWeather';              L='Bing Weather'          }
    @{ N='Microsoft.BingNews';                 L='Bing Noticias'         }
    @{ N='Microsoft.BingFinance';              L='Bing Finanzas'         }
    @{ N='Microsoft.BingSports';               L='Bing Deportes'         }
    @{ N='Microsoft.GetHelp';                  L='Get Help'              }
    @{ N='Microsoft.Getstarted';               L='Tips / Get Started'    }
    @{ N='Microsoft.MicrosoftSolitaireCollection'; L='Solitario'         }
    @{ N='Microsoft.MicrosoftOfficeHub';       L='Office Hub'            }
    @{ N='Microsoft.MixedReality.Portal';      L='Mixed Reality Portal'  }
    @{ N='Microsoft.People';                   L='Personas'              }
    @{ N='Microsoft.SkypeApp';                 L='Skype'                 }
    @{ N='Microsoft.WindowsMaps';              L='Mapas'                 }
    @{ N='Microsoft.ZuneVideo';                L='Peliculas y TV'        }
    @{ N='Microsoft.ZuneMusic';                L='Groove Musica'         }
    @{ N='Microsoft.YourPhone';                L='Tu Telefono'           }
    @{ N='Microsoft.Xbox.TCUI';                L='Xbox TCUI'             }
    @{ N='Microsoft.XboxApp';                  L='Xbox App'              }
    @{ N='Microsoft.XboxGameOverlay';          L='Xbox Game Overlay'     }
    @{ N='Microsoft.XboxGamingOverlay';        L='Xbox Gaming Overlay'   }
    @{ N='Microsoft.XboxIdentityProvider';     L='Xbox Identity Provider'}
    @{ N='Microsoft.XboxSpeechToTextOverlay';  L='Xbox Speech to Text'   }
    @{ N='Microsoft.Advertising.Xaml';         L='Publicidad Microsoft'  }
    @{ N='Microsoft.549981C3F5F10';            L='Cortana (app)'         }
)

# Definida fuera del bucle para evitar redefinicion en cada iteracion
function Remove-Bloat {
    param([int]$idx)
    $app = $script:BLOATWARE[$idx - 1]
    $pkg = Get-AppxPackage -AllUsers -Name $app.N -EA SilentlyContinue
    if ($pkg) {
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -EA SilentlyContinue
        WL "  [OK] Eliminado: $($app.L)" Green
    } else {
        WL "  [--] No encontrado: $($app.L)" DarkGray
    }
}

function Show-Apps {
    while ($true) {
        Banner
        WL "  -- APLICACIONES -- Bloatware UWP --" Yellow
        WL ""

        $installed   = Get-AppxPackage -AllUsers -EA SilentlyContinue | Select-Object -ExpandProperty Name
        $i           = 1
        $presentIdxs = @()

        foreach ($app in $script:BLOATWARE) {
            $present = $installed -contains $app.N
            W ("  [{0:D2}]" -f $i) White
            if ($present) { W ' [instalado] ' Green; $presentIdxs += $i }
            else           { W ' [---]       ' DarkGray }
            WL $app.L White
            $i++
        }

        WL ""
        WL "  [A]  Eliminar TODO el bloatware instalado" Yellow
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  Numero o A/0: " Cyan
        $opt = Read-Host

        if ($opt -eq '0') { return }
        if (-not $opt) { continue }
        if (!(Need-Admin)) { continue }

        if ($opt -eq 'A' -or $opt -eq 'a') {
            foreach ($idx in $presentIdxs) { Remove-Bloat $idx }
            Pause
        } elseif ($opt -match '^\d+$') {
            $n = [int]$opt
            if ($n -ge 1 -and $n -le $script:BLOATWARE.Count) { Remove-Bloat $n; Pause }
        }
    }
}

# ── 6. SERVICIOS ──────────────────────────────────────────────────────────────
$script:SERVICES = @(
    @{ N='DiagTrack';          L='Telemetria (DiagTrack)';             Safe=$true  }
    @{ N='dmwappushservice';   L='WAP Push Message Routing';           Safe=$true  }
    @{ N='SysMain';            L='SysMain / Superfetch';               Safe=$true  }
    @{ N='WSearch';            L='Windows Search (indexacion)';        Safe=$true  }
    @{ N='PrintSpooler';       L='Cola de impresion (PrintSpooler)';   Safe=$true  }
    @{ N='Fax';                L='Fax';                                Safe=$true  }
    @{ N='RemoteRegistry';     L='Registro remoto';                    Safe=$true  }
    @{ N='TabletInputService'; L='Teclado tactil y escritura';         Safe=$true  }
    @{ N='XblAuthManager';     L='Xbox Live Auth Manager';             Safe=$true  }
    @{ N='XblGameSave';        L='Xbox Live Game Save';                Safe=$true  }
    @{ N='wuauserv';           L='Windows Update';                     Safe=$false }
    @{ N='BITS';               L='BITS (transferencias segundo plano)';Safe=$false }
    @{ N='W32Time';            L='Hora de Windows (W32Time)';          Safe=$false }
    @{ N='LanmanServer';       L='Comparticion de archivos (SMB)';     Safe=$false }
)

function Show-Services {
    while ($true) {
        Banner
        WL "  -- SERVICIOS --" Yellow
        WL ""

        $i = 1
        foreach ($svc in $script:SERVICES) {
            $s = Get-Service $svc.N -EA SilentlyContinue
            W ("  [{0:D2}]" -f $i) White
            if (-not $s) {
                WL "  [N/A]      $($svc.L)" DarkGray
            } else {
                ON-OFF ($s.Status -eq 'Running')
                W "  $($svc.L)" White
                if (-not $svc.Safe) { W "  [!]" Yellow }
                WL ""
            }
            $i++
        }

        WL ""
        WL "  [!] = cambiar puede afectar el sistema" Yellow
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  Numero: " Cyan
        $opt = Read-Host

        if ($opt -eq '0') { return }
        if (-not $opt) { continue }
        if (!(Need-Admin)) { continue }

        if ($opt -match '^\d+$') {
            $n = [int]$opt
            if ($n -ge 1 -and $n -le $script:SERVICES.Count) {
                $svc = $script:SERVICES[$n - 1]
                $s   = Get-Service $svc.N -EA SilentlyContinue
                if ($s) {
                    if ($s.Status -eq 'Running') {
                        Stop-Service $svc.N -Force -EA SilentlyContinue
                        Set-Service  $svc.N -StartupType Disabled -EA SilentlyContinue
                        WL "`n  [OK] Detenido y desactivado: $($svc.L)" Green
                    } else {
                        Set-Service  $svc.N -StartupType Automatic -EA SilentlyContinue
                        Start-Service $svc.N -EA SilentlyContinue
                        WL "`n  [OK] Activado: $($svc.L)" Green
                    }
                    Pause
                }
            }
        }
    }
}

# ── 7. RED ────────────────────────────────────────────────────────────────────
function Show-Network {
    while ($true) {
        Banner
        WL "  -- RED --" Yellow
        WL ""

        $adapters = Get-NetAdapter -EA SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
        foreach ($a in $adapters) {
            # Select-Object -First 1 evita que $ip sea un array si hay varias IPs
            $ip = (Get-NetIPAddress -InterfaceIndex $a.InterfaceIndex -AddressFamily IPv4 -EA SilentlyContinue |
                   Select-Object -First 1).IPAddress
            $gw = (Get-NetRoute -InterfaceIndex $a.InterfaceIndex -DestinationPrefix '0.0.0.0/0' -EA SilentlyContinue |
                   Select-Object -First 1).NextHop
            W "  $($a.Name) " Cyan
            W " $ip" White
            if ($gw) { W "  GW: $gw" DarkGray }
            WL ""
        }

        $dns = (Get-DnsClientServerAddress -AddressFamily IPv4 -EA SilentlyContinue |
                Where-Object { $_.ServerAddresses } | Select-Object -First 1).ServerAddresses
        if ($dns) { W "  DNS: " DarkGray; WL ($dns -join ', ') White }

        WL ""
        WL "  [1]  Conexiones TCP activas" White
        WL "  [2]  Ping a 8.8.8.8" White
        WL "  [3]  Traceroute a 8.8.8.8" White
        WL "  [4]  Flush DNS" White
        WL "  [5]  Reset stack TCP/IP  [!]" White
        WL "  [6]  Renovar DHCP" White
        WL "  [7]  Puertos en escucha" White
        WL ""
        WL "  [0]  Volver" DarkGray
        WL ""
        W "  > " Cyan
        $opt = Read-Host

        switch ($opt) {
            '1' { WL ""; netstat -n -p TCP | Select-Object -First 35; Pause }
            '2' { WL ""; Test-Connection 8.8.8.8 -Count 4 | Format-Table; Pause }
            '3' { WL ""; tracert 8.8.8.8; Pause }
            '4' { Clear-DnsClientCache -EA SilentlyContinue; WL "`n  [OK] DNS flush completado." Green; Pause }
            '5' {
                if (!(Need-Admin)) { continue }
                netsh int ip reset  | Out-Null
                netsh winsock reset | Out-Null
                WL "  [OK] Stack TCP/IP reseteado. Reinicia para aplicar." Green
                Pause
            }
            '6' {
                if (!(Need-Admin)) { continue }
                ipconfig /release | Out-Null
                ipconfig /renew   | Out-Null
                WL "`n  [OK] DHCP renovado." Green; Pause
            }
            '7' { WL ""; netstat -an | Select-String 'LISTENING' | Select-Object -First 30; Pause }
            '0' { return }
        }
    }
}

# ── MENU PRINCIPAL ────────────────────────────────────────────────────────────
while ($true) {
    Banner
    WL "  [1]  Sistema          -- Hardware, SO, RAM, disco" White
    WL "  [2]  Privacidad       -- Telemetria, anuncios, historial" White
    WL "  [3]  Rendimiento      -- Plan energia, Game Mode, servicios" White
    WL "  [4]  Limpieza         -- Temp, cache, papelera, Event Log" White
    WL "  [5]  Aplicaciones     -- Eliminar bloatware UWP" White
    WL "  [6]  Servicios        -- Activar / desactivar servicios" White
    WL "  [7]  Red              -- Info, ping, DNS, TCP/IP reset" White
    WL ""
    WL "  [0]  Salir" DarkGray
    WL ""
    W "  > " Cyan
    $opt = Read-Host

    switch ($opt) {
        '1' { Show-System }
        '2' { Show-Privacy }
        '3' { Show-Performance }
        '4' { Show-Cleanup }
        '5' { Show-Apps }
        '6' { Show-Services }
        '7' { Show-Network }
        '0' { WL "`n  Hasta luego.`n" DarkGray; exit 0 }
    }
}
