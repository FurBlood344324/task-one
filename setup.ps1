# setup.ps1 - Windows PowerShell setup script

Write-Host "🚀 Proje kurulumu başlatılıyor..." -ForegroundColor Green

# Virtual environment kontrolü ve oluşturma
if (-not (Test-Path "venv")) {
    Write-Host "📦 Virtual environment oluşturuluyor..." -ForegroundColor Yellow
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Virtual environment oluşturulamadı!" -ForegroundColor Red
        exit 1
    }
}

# Virtual environment aktivasyonu
Write-Host "🔧 Virtual environment aktifleştiriliyor..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"

# Requirements yükleme
if (Test-Path "requirements.txt") {
    Write-Host "📚 Requirements kontrol ediliyor..." -ForegroundColor Yellow
    
    # Virtual environment aktif mi kontrol et
    if (-not $env:VIRTUAL_ENV) {
        & "venv\Scripts\Activate.ps1"
    }
    
    # pip-tools yüklü mü kontrol et
    $pipTools = pip show pip-tools 2>$null
    if (-not $pipTools) {
        Write-Host "🔧 pip-tools yükleniyor..." -ForegroundColor Yellow
        pip install pip-tools | Out-Null
    }
    
    # requirements.txt'deki paketler zaten yüklü mü kontrol et
    $requirements = Get-Content "requirements.txt" | Where-Object { $_.Trim() -and -not $_.StartsWith("#") }
    $missingPackages = @()
    
    foreach ($req in $requirements) {
        $packageName = ($req -split '[>=<]')[0].Trim()
        $installed = pip show $packageName 2>$null
        if (-not $installed) {
            $missingPackages += $packageName
        }
    }
    
    if ($missingPackages.Count -eq 0) {
        Write-Host "✅ Tüm requirements zaten yüklü!" -ForegroundColor Green
    } else {
        Write-Host "📦 Eksik paketler yükleniyor: $($missingPackages -join ', ')" -ForegroundColor Yellow
        pip install -r requirements.txt
    }
} else {
    Write-Host "⚠️ requirements.txt bulunamadı!" -ForegroundColor Yellow
}

# MyPy kontrol ve yükleme
$mypyInstalled = pip show mypy 2>$null
if ($mypyInstalled) {
    $mypyVersion = ($mypyInstalled | Select-String "Version:" | ForEach-Object { $_.Line.Split(" ")[1] })
    Write-Host "✅ MyPy zaten yüklü (v$mypyVersion)" -ForegroundColor Green
} else {
    Write-Host "🔍 MyPy yükleniyor..." -ForegroundColor Yellow
    pip install mypy
}

# Type hints için additional packages
Write-Host "📝 Type checking dependencies kontrol ediliyor..." -ForegroundColor Yellow
$typePackages = @("types-requests", "types-setuptools")
$missingTypePackages = @()

foreach ($pkg in $typePackages) {
    $installed = pip show $pkg 2>$null
    if (-not $installed) {
        $missingTypePackages += $pkg
    }
}

if ($missingTypePackages.Count -eq 0) {
    Write-Host "✅ Tüm type packages zaten yüklü!" -ForegroundColor Green
} else {
    Write-Host "📝 Eksik type packages yükleniyor: $($missingTypePackages -join ', ')" -ForegroundColor Yellow
    pip install $missingTypePackages
}

# VS Code klasörü kontrolü
if (-not (Test-Path ".vscode")) {
    New-Item -ItemType Directory -Name ".vscode" | Out-Null
}

# Settings.json var mı kontrol et (varsa dokunma)
$settingsFile = ".vscode/settings.json"

if (-not (Test-Path $settingsFile)) {
    Write-Host "🔧 VS Code settings.json oluşturuluyor..." -ForegroundColor Yellow
    $settingsContent = @'
{
    "mypy-type-checker.path": ["${workspaceFolder}/venv/Scripts/mypy.exe"],
    "mypy-type-checker.args": ["--ignore-missing-imports", "--show-error-codes"],
    "mypy.dmypyExecutable": "${workspaceFolder}/venv/Scripts/dmypy.exe",
    "mypy-type-checker.reportingScope": "workspace",
    "mypy-type-checker.severity": {
        "error": "Error",
        "warning": "Warning",
        "note": "Information"
    },
    "mypy-type-checker.preferDaemon": true,
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/Scripts/python.exe",
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    }
}
'@

    $settingsContent | Out-File -FilePath $settingsFile -Encoding UTF8
    Write-Host "✅ VS Code settings.json oluşturuldu!" -ForegroundColor Green
} else {
    Write-Host "✅ VS Code settings.json zaten mevcut, dokunulmadı!" -ForegroundColor Green
}Write-Host "✅ Kurulum tamamlandı!" -ForegroundColor Green
Write-Host "💡 VS Code'u yeniden başlatarak değişikliklerin etkili olmasını sağlayın." -ForegroundColor Cyan

# Python sürümü ve paket listesi göster
Write-Host "`n📋 Kurulum Özeti:" -ForegroundColor Cyan
Write-Host "Python Sürümü: $(python --version)" -ForegroundColor White
Write-Host "MyPy Sürümü: $(pip show mypy | Select-String 'Version')" -ForegroundColor White
Write-Host "Virtual Environment: venv (Windows)" -ForegroundColor White
