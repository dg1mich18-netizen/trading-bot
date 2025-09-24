#!/bin/bash

# Настройка логирования с проверкой прав доступа
LOG_DIR=".logs"
LOG_FILE="$LOG_DIR/setup.log"
mkdir -p "$LOG_DIR"

if ! touch "$LOG_FILE" 2>/dev/null; then
    echo "❌ Не удалось создать файл логов $LOG_FILE. Проверьте права доступа." >&2
    exit 1
fi

exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Настройка среды разработки Trading Bot на Kubuntu..."
echo "📜 Логи сохраняются в $LOG_FILE"
echo "===================================================="

# Функция для вывода ошибок
error_exit() {
    echo "❌ $1" >&2
    exit 1
}

# Проверка запуска из корня проекта
if [ ! -f "pyproject.toml" ]; then
    error_exit "pyproject.toml не найден. Запустите скрипт из корня проекта."
fi

# Проверка свободного места
MIN_DISK_SPACE_MB=2048
FREE_SPACE=$(df -m . | tail -1 | awk '{print $4}')
if [ "$FREE_SPACE" -lt "$MIN_DISK_SPACE_MB" ]; then
    error_exit "Недостаточно места на диске: требуется минимум $MIN_DISK_SPACE_MB MB, доступно $FREE_SPACE MB"
fi

# Функция установки Poetry
install_poetry() {
    echo "📦 Устанавливаю Poetry..."
    if ! curl -sSL https://install.python-poetry.org | python3 -; then
        error_exit "Ошибка установки Poetry"
    fi
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ Poetry установлен"
}

# Функция установки VSCode
install_vscode() {
    echo "💻 Устанавливаю VSCode..."
    if command -v snap &> /dev/null; then
        echo "📦 Установка через Snap..."
        sudo snap install --classic code || error_exit "Ошибка установки VSCode через Snap"
    elif command -v apt &> /dev/null; then
        echo "📦 Установка через APT..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f microsoft.gpg
        sudo apt update -qq
        sudo apt install -y code || error_exit "Ошибка установки VSCode через APT"
    else
        error_exit "Не найден подходящий пакетный менеджер для установки VSCode"
    fi
    echo "✅ VSCode установлен"
}

# Функция установки расширений VSCode
install_vscode_extensions() {
    echo "🔌 Устанавливаю расширения VSCode..."
    extensions=(
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-toolsai.jupyter"
        "ms-azuretools.vscode-docker"
        "eamodio.gitlens"
        "usernamehw.errorlens"
        "formulahendry.auto-rename-tag"
        "bierner.color-info"
        "gruntfuggly.todo-tree"
        "ms-vscode.makefile-tools"
        "redhat.vscode-yaml"
        "ms-vscode.vscode-json"
    )

    for extension in "${extensions[@]}"; do
        echo "📦 Устанавливаю: $extension"
        if code --install-extension "$extension" --force; then
            echo "✅ $extension установлен"
        else
            echo "⚠️ Не удалось установить $extension"
        fi
    done
}

# Функция настройки VSCode
setup_vscode() {
    echo "🔧 Настраиваю VSCode..."
    mkdir -p .vscode

    cat > .vscode/settings.json << 'EOL'
{
    "python.defaultInterpreterPath": ".venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.analysis.autoImportCompletions": true,
    "python.analysis.typeCheckingMode": "basic",
    "python.analysis.autoSearchPaths": true,
    "python.analysis.diagnosticMode": "workspace",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "editor.minimap.enabled": false,
    "editor.fontSize": 14,
    "editor.lineHeight": 1.5,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "workbench.colorTheme": "Default Dark Modern",
    "workbench.iconTheme": "vs-seti",
    "terminal.integrated.shell.linux": "/bin/bash",
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.nosetestsEnabled": false,
    "[python]": {
        "editor.defaultFormatter": "ms-python.python",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    }
}
EOL

    cat > .vscode/extensions.json << 'EOL'
{
    "recommendations": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter",
        "ms-azuretools.vscode-docker",
        "eamodio.gitlens",
        "usernamehw.errorlens",
        "formulahendry.auto-rename-tag",
        "bierner.color-info",
        "gruntfuggly.todo-tree",
        "ms-vscode.makefile-tools",
        "redhat.vscode-yaml",
        "ms-vscode.vscode-json"
    ]
}
EOL

    cat > .vscode/tasks.json << 'EOL'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Install Dependencies",
            "type": "shell",
            "command": "poetry",
            "args": ["install"],
            "group": "build"
        },
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "poetry",
            "args": ["run", "pytest"],
            "group": "test"
        },
        {
            "label": "Start Docker Services",
            "type": "shell",
            "command": "docker",
            "args": ["compose", "up", "-d"],
            "group": "build"
        }
    ]
}
EOL

    echo "✅ Настройки VSCode созданы"
}

echo "🔍 Проверка системных зависимостей..."

# Обновление пакетов
echo "🔄 Обновление списка пакетов..."
sudo apt update -qq || error_exit "Ошибка обновления списка пакетов"

# ss (iproute2)
if ! command -v ss &> /dev/null; then
    echo "❌ ss не найден. Устанавливаю iproute2..."
    sudo apt install -y iproute2 || error_exit "Ошибка установки iproute2"
fi

# Python
MIN_PYTHON_VERSION="3.8"
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не найден. Устанавливаю..."
    sudo apt install -y python3 python3-venv python3-pip || error_exit "Ошибка установки Python3"
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
if ! printf '%s\n' "$MIN_PYTHON_VERSION" "$PYTHON_VERSION" | sort -C -V; then
    error_exit "Требуется Python $MIN_PYTHON_VERSION или выше. Установлена версия: $PYTHON_VERSION"
fi
echo "✅ Python $PYTHON_VERSION"

# Curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl не найден. Устанавливаю..."
    sudo apt install -y curl || error_exit "Ошибка установки curl"
fi

# Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден. Устанавливаю..."
    sudo apt install -y docker.io || error_exit "Ошибка установки Docker"
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$(whoami)"
    echo "⚠️ Выполните 'newgrp docker' или перелогиньтесь, чтобы применить права Docker"
fi

# Проверка и запуск Docker демона
if ! systemctl is-active --quiet docker; then
    echo "🔄 Запуск Docker демона..."
    sudo systemctl start docker
    sleep 2
    if ! systemctl is-active --quiet docker; then
        error_exit "Не удалось запустить Docker демон"
    fi
fi

# Docker Compose
if ! docker compose version &> /dev/null; then
    echo "❌ Docker compose plugin не найден. Устанавливаю..."
    sudo apt install -y docker-compose-plugin || error_exit "Ошибка установки Docker Compose"
else
    DOCKER_COMPOSE_VERSION=$(docker compose version 2>/dev/null | awk '{print $3}' | head -1)
    echo "✅ Docker Compose: $DOCKER_COMPOSE_VERSION"
fi

# Poetry
if ! command -v poetry &> /dev/null; then
    install_poetry
else
    echo "✅ Poetry уже установлен: $(poetry --version)"
fi

# Установка и настройка VSCode
if ! command -v code &> /dev/null; then
    install_vscode
fi

setup_vscode
install_vscode_extensions

echo "🎉 Среда разработки успешно настроена!"
echo ""
