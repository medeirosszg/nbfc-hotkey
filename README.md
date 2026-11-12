# nbfc-hotkey

**Controle as ventoinhas do seu notebook no Linux com uma tecla.**

O `nbfc-hotkey` instala o [NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux), escolhe a
configuração certa para o seu notebook e liga uma tecla (aquela que no Windows abria o
NitroSense, o Omen Gaming Hub, o Armoury Crate... ou qualquer outra) ao painel de ventoinhas
[nbfc-qt](https://github.com/nbfc-linux/nbfc-qt).

*English summary at the end.*

```bash
curl -fsSL https://raw.githubusercontent.com/medeirosszg/nbfc-hotkey/main/install.sh | bash
```

Rode como seu usuário normal (sem `sudo`). A senha é pedida só quando precisa.

## O que ele faz

1. **Detecta o sistema**: distro, ambiente gráfico e modelo do notebook.
2. **Instala o NBFC-Linux e o painel nbfc-qt** com os pacotes oficiais do projeto
   (o checksum SHA-256 é conferido). Se não houver pacote pronto para a sua distro, compila o
   NBFC-Linux a partir do código-fonte.
3. **Configura o NBFC** para o seu modelo (`nbfc config --set auto`, ou mostra uma lista de
   configurações compatíveis para você escolher) e liga o serviço no boot.
4. **Descobre a tecla**: você aperta a tecla que quer usar e ele lê direto do kernel qual
   código ela manda. Se a tecla não tiver um nome que o ambiente gráfico entenda, ele a
   remapeia com uma regra do udev.
5. **Cria o atalho** no seu ambiente gráfico. Apertar a tecla abre o painel; apertar de
   novo fecha.

## Uso

Sem argumentos, abre um menu:

```
$ nbfc-hotkey
nbfc-hotkey 0.1.0
  Sistema:   Fedora Linux 44 (Workstation Edition) · GNOME (wayland)
  Notebook:  Acer Nitro AN515-58
  NBFC:      0.4.0, rodando, config "Acer Nitro AN515-58"
  Painel:    instalado
  Tecla:     XF86Launch1 → abrir painel

O que você quer fazer?
  1) Instalar e configurar tudo
  2) Escolher a tecla
  3) Escolher o que a tecla faz
  4) Testar (abrir o painel agora)
  5) Remover o atalho
  6) Desinstalar o nbfc-hotkey
  7) Sair (padrão)
```

Ou direto pela linha de comando:

| Comando | O que faz |
|---|---|
| `nbfc-hotkey install` | Instala e configura tudo |
| `nbfc-hotkey bind` | Escolhe a tecla (aperte a tecla quando pedir) |
| `nbfc-hotkey bind --key ctrl+alt+f` | Escolhe a tecla sem detecção |
| `nbfc-hotkey action panel` | A tecla abre/fecha o painel de ventoinhas (padrão) |
| `nbfc-hotkey action command "meu-comando"` | A tecla roda outro comando qualquer |
| `nbfc-hotkey status` | Mostra o estado |
| `nbfc-hotkey unbind` | Remove o atalho |
| `nbfc-hotkey uninstall` | Remove o nbfc-hotkey (o NBFC continua instalado) |

## Compatibilidade

### Distros

| Distro | Como instala | Testado |
|---|---|---|
| Fedora 43/44 (e derivadas como Nobara) | pacote `.rpm` oficial | ✅ Fedora 44 |
| Ubuntu 22.04/24.04/26.04 (e Pop!_OS, Zorin...) | pacote `.deb` oficial | ✅ Ubuntu 24.04 |
| Linux Mint 21/22 | pacote `.deb` oficial | — |
| Debian 12/13 (e LMDE) | pacote `.deb` oficial | ✅ Debian 13 |
| Arch (e Manjaro, EndeavourOS, CachyOS...) | pacote oficial; se não rodar, compila | ✅ (compilou) |
| openSUSE Tumbleweed | pacote `.rpm` oficial; se não rodar, compila | ✅ (compilou) |
| Outras | compila do código-fonte | ✅ Fedora 42 |

Os testes de instalação foram feitos em containers de cada distro. O atalho e o painel foram
testados de verdade só no GNOME (Fedora 44).

Depois de instalar, o `nbfc-hotkey` confere se o `nbfc` roda. Em novembro de 2026, os pacotes
oficiais para Arch e openSUSE instalavam mas não rodavam (bibliotecas incompatíveis); nesses
casos ele remove o pacote e compila o NBFC-Linux automaticamente, instalando as dependências
de compilação pelo gerenciador de pacotes.

### Ambientes gráficos

| Ambiente | Como cria o atalho | Testado |
|---|---|---|
| GNOME, Ubuntu, Budgie, Pantheon | `gsettings` (atalhos personalizados) | ✅ |
| Cinnamon | `gsettings` | — |
| MATE | `dconf` | — |
| XFCE | `xfconf-query` | — |
| KDE Plasma 5/6 | `kglobalshortcutsrc` (experimental) | — |
| Sway, i3, Hyprland | bloco marcado no arquivo de configuração | — |
| Outros | mostra a tecla e o comando para você criar o atalho à mão | — |

Testou em outro ambiente? Abra uma issue contando se funcionou.

## Problemas conhecidos

- **A tecla não gera nada.** Algumas teclas especiais (NitroSense, Armoury, Omen...) só
  funcionam quando o driver do fabricante está carregado (`acer_wmi`, `asus_wmi`, `hp_wmi`...).
  Se nenhuma tecla chegar, o `nbfc-hotkey` avisa; você pode usar outra tecla ou uma
  combinação como `Ctrl+Alt+F`.
- **O painel não abre e fica travado.** Acontece quando o driver proprietário da NVIDIA está
  instalado mas não carregou (por exemplo, depois de atualizar o kernel): o `nbfc` fica
  esperando o sensor da NVIDIA para sempre. O `nbfc-hotkey` já contorna isso: ele abre o
  painel com um `nbfc` intermediário que desiste depois de alguns segundos.
- **O serviço do NBFC não inicia.** Com Secure Boot ligado, o kernel pode bloquear o acesso
  ao controlador das ventoinhas. Veja a seção sobre `ec_sys` e `acpi_ec` no
  [Troubleshooting do NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux#troubleshooting).
- **Nenhuma configuração serve para o meu notebook.** Veja como criar uma no
  [NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux#getting-started-without-the-gui).

## O que ele muda no seu sistema

- Instala os pacotes `nbfc-linux` e `nbfc-qt` e liga o serviço `nbfc_service`.
- Copia a si mesmo para `~/.local/bin/nbfc-hotkey` e cria `~/.local/lib/nbfc-hotkey/`
  e `~/.config/nbfc-hotkey/`.
- Cria um atalho de teclado chamado **NBFC Hotkey** no seu ambiente gráfico.
- Só se você aceitar remapear uma tecla: cria `/etc/udev/hwdb.d/90-nbfc-hotkey.hwdb`.

O `nbfc-hotkey uninstall` desfaz tudo isso, menos os pacotes do NBFC.

## English

`nbfc-hotkey` installs [NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux) and the
[nbfc-qt](https://github.com/nbfc-linux/nbfc-qt) panel, picks the right config for your laptop,
detects the key you press (e.g. the one that opened NitroSense/Omen/Armoury on Windows) and
binds it to open the fan panel in your desktop environment. Run
`curl -fsSL https://raw.githubusercontent.com/medeirosszg/nbfc-hotkey/main/install.sh | bash`
as your normal user. The interface follows your system language (Portuguese or English).

## Créditos

Todo o controle das ventoinhas é feito pelo [NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux)
e pelo [nbfc-qt](https://github.com/nbfc-linux/nbfc-qt). Este projeto só automatiza a instalação
e o atalho, e não tem ligação com esses projetos nem com os fabricantes citados. Os nomes de
produtos pertencem aos seus donos.

Licença MIT.
