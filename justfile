# Justfile for common development tasks

# 🧪 Run and check
test:
  pytest

test-basic:
  python test_ailabkit.py

lint:
  ruff src/ailabkit tests scripts

format:
  ruff format src/ailabkit tests scripts

# 💼 Run linter and tests together
ci: 
  just lint
  just test

# 🔧 Project setup
install-dev:
  pip install -r requirements-dev.txt

sync-version:
  python scripts/inject_version.py --all
  echo "✅ Synced version across pyproject.toml and version.json"

requirements:
  uv pip compile pyproject.toml --output-file=requirements.txt
  uv pip compile pyproject.toml --extra=dev --output-file=requirements-dev.txt
  echo "✅ Regenerated requirements.txt and requirements-dev.txt"

# 🏗️ Build and distribute
build:
  python -m build

bundle:
  python scripts/build_zip.py

# 📚 Documentation
docs:
  python scripts/generate_project_index.py
  mkdocs build --clean

deploy-docs:
  python scripts/generate_project_index.py
  mkdocs gh-deploy --force

# 🧪 Run CLI modules in interactive mode
chat-repl:
  ailabkit chat interactive

rag-repl:
  ailabkit rag interactive

agent-repl:
  ailabkit agent interactive

# 🩺 Run diagnostic check
doctor:
  ailabkit doctor

# 🌐 Run web interfaces
chat-web:
  ailabkit chat web

rag-web:
  ailabkit rag web
  
agent-web:
  ailabkit agent web

# 🔧 Rebuild mini-projects markdown from individual project files
build-mini-projects:
  python scripts/build_mini_projects.py


# 🇦🇺 Convert American spelling to Australian/British spelling in docs
spelling-au:
  python scripts/convert_spelling.py --verbose

# 🌐 Regenerate HTML-based project browser
build-project-browser:
  python scripts/project_browser.py --output project_browser.html

# 🛠️ Rebuild everything: sync version, docs, browser, mini-projects
build-all:
  just sync-version
  just build-mini-projects
  python scripts/generate_project_index.py
  just build-project-browser
  just docs

# 🚀 Publish a new release
release:
  just build-all
  echo "🔖 Preparing release..."
  version=$(grep '^version *= *"' pyproject.toml | sed 's/version *= *"\(.*\)"/\1/')
  echo "🔖 Version: $$version"
  git add .
  git commit -m "🔖 Release $$version"
  git tag v$$version
  git push
  git push --tags
  echo "📦 Building and uploading to PyPI..."
  python -m build
  twine upload dist/*
  echo "✅ Release $$version published!"

# 🚀 Publish a new release to TestPyPI
release-test:
  just build-all
  python -m build
  twine upload --repository testpypi dist/*

# Lint mini-projects markdown files
lint-mini-projects:
  python scripts/lint_mini_projects.py
  
# Generate the projects index.md file
generate-project-index:
  python scripts/generate_project_index.py

# Lint chat mini-projects markdown files
lint-chat-projects:
  python scripts/lint_mini_projects.py docs/projects/chat

# Lint rag mini-projects markdown files  
lint-rag-projects:
  python scripts/lint_mini_projects.py docs/projects/rag

# Lint agent mini-projects markdown files
lint-agent-projects:
  python scripts/lint_mini_projects.py docs/projects/agent

# Lint all module-specific mini-projects
lint-all-projects: lint-chat-projects lint-rag-projects lint-agent-projects

clean:
  rm -rf build dist *.egg-info __pycache__ .pytest_cache .mypy_cache

# 📋 Help menu
help:
  @echo "Available commands:"
  @echo "  install-dev           Install dev dependencies"
  @echo "  test                  Run all tests with pytest"
  @echo "  test-basic            Run basic imports test directly"
  @echo "  lint                  Run Ruff linter"
  @echo "  format                Auto-format code with Ruff"
  @echo "  build                 Build and optionally upload"
  @echo "  bundle                Create offline zip"
  @echo "  sync-version          Sync version across files"
  @echo "  docs                  Build MkDocs site"
  @echo "  deploy-docs           Deploy site to GitHub Pages"
  @echo "  chat-repl             Start AiLabKit chat interactive mode"
  @echo "  rag-repl              Start AiLabKit RAG interactive mode"
  @echo "  agent-repl            Start AiLabKit agent interactive mode"
  @echo "  chat-web              Start AiLabKit chat web interface"
  @echo "  rag-web               Start AiLabKit RAG web interface"
  @echo "  agent-web             Start AiLabKit agent web interface"
  @echo "  doctor                Run system diagnostic for AiLabKit"
  @echo "  build-mini-projects   Rebuild mini-projects.md from /docs/projects"
  @echo "  spelling-au           Convert American spelling to Australian/British spelling"
  @echo "  lint-mini-projects    Lint the combined mini-projects.md file"
  @echo "  generate-project-index  Generate the projects/index.md file"
  @echo "  lint-chat-projects    Lint chat mini-projects"
  @echo "  lint-rag-projects     Lint RAG mini-projects"
  @echo "  lint-agent-projects   Lint agent mini-projects"
  @echo "  lint-all-projects     Lint all module-specific mini-projects"
  @echo "  build-project-browser Generate the project_browser.html"
  @echo "  build-all             Sync version, rebuild docs and project browser"
  @echo "  release               Build, tag, push and publish to PyPI"
  @echo "  release-test          Publish release to TestPyPI"
  @echo "  clean                 Clean up build artifacts"
  @echo "  help                  Show this help message"
  