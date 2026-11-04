#!/usr/bin/env bash
PROJECTS_DIR=~/Projects/
GIT=false

create_gitignore() {
    local LANGUAGE="$1"
    local FILE_PATH="$2/.gitignore"

    case "$LANGUAGE" in
    python)
        if ! cat <<'EOF' >"$FILE_PATH"
# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
ENV/
env/
.env
.pytest_cache/
EOF
        then
            echo "Error creating .gitignore file"
            exit 1
        fi
        ;;
    esac
}

python_project() {
    PYTHON_DIR="$PROJECTS_DIR/python-projects/$1"
    if ! mkdir -p "$PYTHON_DIR"; then
        echo "Error creating project directory: $PYTHON_DIR"
        exit 1
    fi

    if ! touch "$PYTHON_DIR/$1.py"; then
        echo "Error creating $1.py"
        exit 1
    fi

    if ! python -m venv "$PYTHON_DIR/.venv"; then
        echo "Error creating Python virtual environment"
        exit 1
    fi

    if [ "$2" = "git" ]; then
        GIT=true
    fi

    if $GIT; then
        if ! git init "$PYTHON_DIR"; then
            echo "Error initializing git in $PYTHON_DIR"
            exit 1
        fi

        if ! git -C "$PYTHON_DIR" branch -m main; then
            echo "Error renaming branch to main"
            exit 1
        fi

        create_gitignore "python" "$PYTHON_DIR"
    fi

    exit 0
}

bash_project() {
    BASH_DIR="$PROJECTS_DIR/bash-projects/$1"

    if ! mkdir -p "$BASH_DIR"; then
        echo "Error creating project directory: $BASH_DIR"
        exit 1
    fi

    if ! touch "$BASH_DIR/$1.sh"; then
        echo "Error creating $1.sh"
        exit 1
    fi

    if ! chmod +x "$BASH_DIR/$1.sh"; then
        echo "Error granting permission to $1.sh"
        exit 1
    fi

    exit 0
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    python)
        shift
        python_project "$1" "$2"

        ;;
    bash)
        shift
        bash_project "$1"
        ;;
    *)
        echo "Error: unknown option: $1"
        exit 1
        ;;
    esac
done
