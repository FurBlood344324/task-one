#!/bin/bash
# setup.sh - Proje kurulum scripti (Linux/macOS)

echo "🚀 Proje kurulumu başlatılıyor..."

# Virtual environment oluştur
if [ ! -d "venv" ]; then
    echo "📦 Virtual environment oluşturuluyor..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "❌ Virtual environment oluşturulamadı!"
        exit 1
    fi
fi

# Virtual environment'ı aktifleştir
echo "🔧 Virtual environment aktifleştiriliyor..."
source venv/bin/activate

# Requirements yükle
if [ -f "requirements.txt" ]; then
    echo "📚 Requirements kontrol ediliyor..."
    
    # Virtual environment aktif mi kontrol et
    if [ -z "$VIRTUAL_ENV" ]; then
        source venv/bin/activate
    fi
    
    # pip-tools yüklü mü kontrol et
    if ! pip show pip-tools >/dev/null 2>&1; then
        echo "🔧 pip-tools yükleniyor..."
        pip install pip-tools
    fi
    
    # requirements.txt'deki paketler zaten yüklü mü kontrol et
    missing_packages=()
    while IFS= read -r line; do
        # Boş satırları ve comment'leri atla
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            package_name=$(echo "$line" | sed 's/[>=<].*//' | tr -d ' ')
            if ! pip show "$package_name" >/dev/null 2>&1; then
                missing_packages+=("$package_name")
            fi
        fi
    done < requirements.txt
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo "✅ Tüm requirements zaten yüklü!"
    else
        echo "📦 Eksik paketler yükleniyor: ${missing_packages[*]}"
        pip install -r requirements.txt
    fi
else
    echo "⚠️ requirements.txt bulunamadı!"
fi

# MyPy kontrol ve yükleme
if pip show mypy >/dev/null 2>&1; then
    current_mypy_version=$(pip show mypy | grep Version | cut -d' ' -f2)
    echo "✅ MyPy zaten yüklü (v$current_mypy_version)"
else
    echo "🔍 MyPy yükleniyor..."
    pip install mypy
fi

# Type hints için additional packages
echo "📝 Type checking dependencies kontrol ediliyor..."
type_packages=("types-requests" "types-setuptools")
missing_type_packages=()

for pkg in "${type_packages[@]}"; do
    if ! pip show "$pkg" >/dev/null 2>&1; then
        missing_type_packages+=("$pkg")
    fi
done

if [ ${#missing_type_packages[@]} -eq 0 ]; then
    echo "✅ Tüm type packages zaten yüklü!"
else
    echo "📝 Eksik type packages yükleniyor: ${missing_type_packages[*]}"
    pip install "${missing_type_packages[@]}"
fi

# VS Code ayarlarını kontrol et
if [ ! -d ".vscode" ]; then
    mkdir .vscode
fi

# Settings.json var mı kontrol et (varsa dokunma)
settings_file=".vscode/settings.json"

if [ ! -f "$settings_file" ]; then
    echo "🔧 VS Code settings.json oluşturuluyor..."
    # Settings.json dosyasını oluştur (sadece yoksa)
    cat > "$settings_file" << 'EOF'
{
    "mypy-type-checker.path": ["${workspaceFolder}/venv/bin/mypy"],
    "mypy-type-checker.args": ["--ignore-missing-imports", "--show-error-codes"],
    "mypy.dmypyExecutable": "${workspaceFolder}/venv/bin/dmypy",
    "mypy-type-checker.reportingScope": "workspace",
    "mypy-type-checker.severity": {
        "error": "Error",
        "warning": "Warning",
        "note": "Information"
    },
    "mypy-type-checker.preferDaemon": true,
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    }
}
EOF
    echo "✅ VS Code settings.json oluşturuldu!"
else
    echo "✅ VS Code settings.json zaten mevcut, dokunulmadı!"
fi

echo "✅ Kurulum tamamlandı!"
echo "💡 VS Code'u yeniden başlatarak değişikliklerin etkili olmasını sağlayın."

# Kurulum özeti
echo ""
echo "📋 Kurulum Özeti:"
echo "Python Sürümü: $(python3 --version)"
echo "MyPy Sürümü: $(pip show mypy | grep Version)"
echo "Virtual Environment: venv (Linux/macOS)"
