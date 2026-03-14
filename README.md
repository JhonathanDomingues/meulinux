<div align="center">

# 🚀 Bazzite Setup

### _Configuração automatizada para o meu Bazzite_

[![Bazzite](https://img.shields.io/badge/Bazzite-Ready-blue?style=for-the-badge)](https://bazzite.gg)


</div>

---

## ✨ O que faz?

Este projeto automatiza a configuração inicial do **Bazzite**, instalando aplicativos essenciais e preparando o ambiente de desenvolvimento.

> ⚙️ **Nota:** Estas configurações são baseadas no meu uso pessoal. Sinta-se livre para adaptar o `flatpaks.txt` e `firefox-profiles.sh` às suas necessidades.

```bash
./install.sh
```

<div align="center">

### 📦 Aplicativos Incluídos

| App | Descrição |
|-----|-----------|
| 🦊 Firefox | Navegador |
| 💻 VS Code | Editor de código |
| 🎥 OBS Studio | Gravação de tela |
| 🍷 Bottles | Compatibilidade Windows |
| 🦙 Alpaca | Interface para Ollama |
| 🎮 Steam | Jogos |
| 🌐 Google Chrome | Navegador |
| 🎮 Heroic | Launcher para Epic/GOG |
| 📥 JDownloader | Gerenciador de downloads |
| 📥 qBittorrent | Cliente torrent |
| 📁 FileZilla | Cliente FTP/SFTP |
| 📊 Mission Center | Monitor de sistema |
| 📄 OnlyOffice | Suíte de escritório |
| 🗄️ pgAdmin 4 | Administração PostgreSQL |
| 🔧 Postman | Testes de API |
| 🎨 Easy Effects | Processamento de áudio |
| 🖥️ AnyDesk | Acesso remoto |
| 🤖 LM Studio | Interface local para LLMs |
| 📦 Distrobox | Containers para desenvolvimento em Python, Go, Rust e Node |
| 🎁 LinuxToys | Ferramentas úteis para Linux |
</div>

## 🎯 Features

- ✅ Detecção automática de hardware (GPU NVIDIA/AMD RX, Notebook/Desktop)
- ✅ Instalação de Flatpaks essenciais
- ✅ Configuração de perfis do Firefox
- ✅ Setup do Ollama para IA local com aceleração GPU
- ✅ Ambientes Distrobox para desenvolvimento:
  - 🐍 **Python** - Poetry, pip, venv
  - 🦀 **Rust** - Rustup, cargo
  - 🟢 **Node.js** - npm, pnpm, yarn
  - 🔵 **Go** - Compilador Go
- ✅ LM Studio AppImage configurado para Gear Lever
- ✅ Ferramentas LinuxToys para produtividade

## 🤖 LM Studio

O script baixa e configura automaticamente o **LM Studio** como AppImage no diretório `~/.local/share/applications/appimages/`. 

**LM Studio** é uma interface desktop para executar modelos de linguagem (LLMs) localmente com aceleração de GPU, ideal para:
- ✨ Testar modelos LLM offline
- 🔒 Privacidade total (dados não saem da sua máquina)
- ⚡ Suporte a GPU NVIDIA/AMD para inferência rápida

Após a instalação, o AppImage estará disponível no **Gear Lever** para fácil gerenciamento e execução.

## 🚦 Início Rápido

```bash
# Clone o repositório
git clone https://github.com/JhonathanDomingues/meulinux.git
cd meulinux

# Execute a instalação
./install.sh
```

> 💡 **Dica:** Reinicie o sistema após a instalação para garantir que tudo funcione perfeitamente.

---

<div align="center">

💻 Jhonathan Domingues

</div>
