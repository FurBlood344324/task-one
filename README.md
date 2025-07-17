# Task One - Python Data Analysis Project

Bu proje veri analizi ve görselleştirme için Python kullanır.

## 🚨 Gerekli VS Code Extensions

Bu projede çalışmak için şu extension'lar **zorunludur**:

- `ms-python.python` - Python dil desteği, IntelliSense, debugging
- `ms-python.mypy-type-checker` - Type checking ve static analysis
- `charliermarsh.ruff` - Fast Python linter ve formatter

### Otomatik Kurulum

Workspace açıldığında VS Code size bu extension'ları önerecektir. "Install All" butonuna tıklayın.

### Manuel Kurulum

```bash
code --install-extension ms-python.python
code --install-extension ms-python.mypy-type-checker
code --install-extension charliermarsh.ruff
```

### Extension Kontrolü

Extension'lar **otomatik olarak** kontrol edilir ve kurulur:
- Workspace açıldığında VS Code size otomatik önerecektir
- Tasks.json ile otomatik kurulum yapılır

## 🔄 GitHub Actions

Bu repo'da otomatik kontroller aktif:

- **Push/PR'larda**: Gerekli extension'ların `.vscode/extensions.json`'da tanımlı olup olmadığı kontrol edilir
- **Başarısızlık durumunda**: CI/CD pipeline fail olur ve eksik extension'lar listelenir

## 🚀 Kurulum

### Otomatik Kurulum (Önerilen)

Workspace açıldığında VS Code otomatik olarak gerekli setup'ı çalıştırır.

### Manuel Kurulum

#### Linux/macOS:
```bash
# 1. Projeyi klonla
git clone <repo-url>
cd task_one

# 2. Setup (otomatik veya manuel)
./setup.sh

# 3. Experiment'i çalıştır
python experiment.py
```

#### Windows:
```powershell
# 1. Projeyi klonla
git clone <repo-url>
cd task_one

# 2. Setup (otomatik veya manuel)
powershell -ExecutionPolicy Bypass .\setup.ps1

# 3. Experiment'i çalıştır
python experiment.py
```

## 📁 Proje Yapısı

```
task_one/
├── .github/workflows/
│   └── dev-environment-check.yml  # Extension kontrolü
├── .vscode/
│   ├── extensions.json            # Önerilen extension'lar
│   ├── settings.json              # Workspace ayarları
│   └── tasks.json                 # Otomatik kurulum taskları
├── experiment.py                  # Ana analiz kodu
├── requirements.txt               # Python dependencies
├── setup.sh                      # Linux/macOS kurulum
├── setup.ps1                     # Windows kurulum
└── pyproject.toml                 # MyPy konfigürasyonu
```

## 💡 Development Best Practices

1. **Type Hints**: MyPy kontrolünü geçecek şekilde type hint'ler kullanın
2. **Code Quality**: Ruff linter önerilerini takip edin  
3. **Automated Setup**: VS Code workspace açıldığında otomatik kurulum çalışır

---

**Not**: Extension'lar otomatik kurulur, type checking ve linting VS Code açılışında hazır olur!
