# Zsh interactivo de Ruben
# Equivalente autocontenido de ~/.config/fish/config.fish.
# Este archivo esta gestionado por lnk y no debe contener secretos.

[[ -o interactive ]] || return

typeset -gi _zsh_has_tty=0
[[ -t 0 && -t 1 ]] && _zsh_has_tty=1

# Configuracion privada opcional. Mantenerla fuera de lnk.
[[ -r "$HOME/.config/zsh/private.zsh" ]] && source "$HOME/.config/zsh/private.zsh"

# Rutas de usuario, sin duplicados.
typeset -U path PATH
path=(
  "$HOME/.bin"
  "$HOME/.local/bin"
  "$HOME/Applications"
  "$HOME/.sdocs/bin"
  "$HOME/.opencode/bin"
  $path
)
export PATH

export EDITOR=nano
export VISUAL=nano
export FZF_DEFAULT_OPTS='--color=16,header:13,info:5,pointer:3,marker:9,spinner:1,prompt:5,fg:7,hl:14,fg+:3,hl+:9 --inline-info --tiebreak=end,length --bind=shift-tab:toggle-down,tab:toggle-up'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'

# Opciones interactivas cercanas a Fish.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt LIST_PACKED
setopt NO_BEEP

# Historial persistente y deduplicado.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Completar sin distinguir mayusculas, con menu legible.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"
_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_zcompdump="$_zsh_cache_dir/zcompdump"
mkdir -p -- "$_zsh_cache_dir"
autoload -Uz compinit
if [[ -s "$_zcompdump" ]]; then
  compinit -C -d "$_zcompdump"
elif command mkdir -- "$_zcompdump.lock" 2>/dev/null; then
  compinit -d "$_zcompdump"
  command rmdir -- "$_zcompdump.lock" 2>/dev/null
else
  # Otra terminal esta creando el cache; esta sesion puede iniciar sin dump.
  compinit -D
fi
unset _zsh_cache_dir _zcompdump

# Edicion de linea, busqueda por prefijo y fzf.
if (( _zsh_has_tty )) && [[ -o zle ]]; then
  bindkey -e
  [[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  [[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  if (( $+widgets[fzf-cd-widget] )); then
    bindkey '^T' fzf-cd-widget
  fi

  if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#969896'
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  if [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
  fi
fi

# Integraciones opcionales.
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Funciones de uso cotidiano.
reload() {
  exec zsh
}

backup() {
  if (( $# != 1 )); then
    print -u2 'uso: backup ARCHIVO'
    return 2
  fi
  cp -- "$1" "$1.bak"
}

history() {
  builtin fc -li 1 "$@" | sort
}

ripp() {
  local length="${1:-100}"
  expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n "$length" | nl
}

gl() {
  git log --graph --color=always \
    --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort='`' \
      --bind="ctrl-m:execute:echo '{}' | grep -o '[a-f0-9]\\{7\\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R'"
}

ex() {
  if (( $# != 1 )) || [[ ! -f "$1" ]]; then
    print -u2 -- "'${1:-}' no es un archivo valido"
    return 1
  fi

  case "$1" in
    (*.tar.bz2|*.tbz2) tar xjf -- "$1" ;;
    (*.tar.gz|*.tgz)   tar xzf -- "$1" ;;
    (*.tar.xz|*.tar.zst|*.tar) tar xf -- "$1" ;;
    (*.bz2)            bunzip2 -- "$1" ;;
    (*.rar)            unrar x -- "$1" ;;
    (*.gz)             gunzip -- "$1" ;;
    (*.zip)            unzip -- "$1" ;;
    (*.Z)              uncompress -- "$1" ;;
    (*.7z)             7z x -- "$1" ;;
    (*.deb)            ar x -- "$1" ;;
    (*) print -u2 -- "'$1' no se puede extraer con ex"; return 1 ;;
  esac
}

less() {
  command less -R "$@"
}

cd() {
  builtin cd "$@" && ls
}

depends() {
  if (( $# != 1 )); then
    print -u2 'uso: depends PAQUETE'
    return 2
  fi
  sudo pacman -Sii -- "$1" |
    sed -n '/^Required By/{s/^Required By[[:space:]]*:[[:space:]]*//; s/  */\n/g; p;}'
}

cleanup() {
  local orphan_output
  if ! orphan_output=$(pacman -Qtdq 2>/dev/null) || [[ -z "$orphan_output" ]]; then
    print 'No hay paquetes huerfanos.'
    return 0
  fi
  local -a orphans
  orphans=("${(@f)orphan_output}")
  sudo pacman -Rns -- "${orphans[@]}"
}

clean() {
  clear
  if (( $+commands[sparklines] && $+commands[lolcat] )); then
    seq 1 "$(tput cols)" | sort -R | sparklines | lolcat
  fi
}

mist() {
  local model=authormist
  [[ "${1:-}" == es ]] && model=authormist-es
  ollama run "$model"
}

if (( $+commands[tree] )); then
  l1()  { tree --dirsfirst -ChFL 1 "$@"; }
  l2()  { tree --dirsfirst -ChFL 2 "$@"; }
  l3()  { tree --dirsfirst -ChFL 3 "$@"; }
  ll1() { tree --dirsfirst -ChFupDaL 1 "$@"; }
  ll2() { tree --dirsfirst -ChFupDaL 2 "$@"; }
  ll3() { tree --dirsfirst -ChFupDaL 3 "$@"; }
fi

# Listados y navegacion.
alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -alFh'
alias l='ls'
alias 'l.'="ls -A | egrep '^\\.'"
alias listdir='ls -d -- */ > list'
alias cd..='cd ..'
alias pdw='pwd'

if (( $+commands[eza] )); then
  alias ls='eza'
  alias xls='eza -a --icons --color=always --group-directories-first'
  alias xll='eza -lag --icons --color=always --group-directories-first --octal-permissions'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi

# Pacman y actualizaciones.
alias sps='sudo pacman -S'
alias spr='sudo pacman -R'
alias sprs='sudo pacman -Rs'
alias sprdd='sudo pacman -Rdd'
alias spqo='sudo pacman -Qo'
alias spsii='sudo pacman -Sii'
alias update='sudo pacman -Syyu'
alias upd='sudo pacman -Syu'
alias u='sudo pacman -Syyu'
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'
alias updte='sudo pacman -Syyu'
alias updqte='sudo pacman -Syyu'
alias pksyua='paru -Syu --noconfirm'
alias upall='paru -Syu --noconfirm'
alias upa='paru -Syu --noconfirm'
alias upqll='paru -Syu --noconfirm'
alias upal='paru -Syu --noconfirm'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias rmpacmanlock='sudo rm /var/lib/pacman/db.lck'
alias pamac-unlock='sudo rm /var/tmp/pamac/dbs/db.lock'
alias paruskip='paru -S --mflags --skipinteg'
alias yayskip='yay -S --mflags --skipinteg'
alias trizenskip='trizen -S --mflags --skipinteg'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\\t%n %v' | sort | tail -200 | nl"
alias riplong="expac --timefmt='%Y-%m-%d %T' '%l\\t%n %v' | sort | tail -3000 | nl"
alias list='sudo pacman -Qqe'
alias listt='sudo pacman -Qqet'
alias listaur='sudo pacman -Qqem'
alias big="expac -H M '%m\\t%n' | sort -h | nl"

# Salida legible y diagnostico.
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ip='ip -color'
alias df='df -h'
alias free='free -mt'
alias wget='wget -c'
alias psa='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias userlist="cut -d: -f1 /etc/passwd | sort"
alias whichvga='/usr/local/bin/edu-which-vga'
alias hw='hwinfo --short'
alias ff='fastfetch'
alias neo='neofetch'
alias audio="pactl info | grep 'Server Name'"
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'
alias howold='sudo lshw | grep -B 3 -A 8 BIOS'
alias cpu='cpuid -i | grep uarch | head -n 1'
alias jctl='journalctl -p 3 -xb'
alias sysfailed='systemctl list-units --failed'
alias kernel='ls /usr/lib/modules'
alias kernels='ls /usr/lib/modules'
alias xd='ls /usr/share/xsessions'
alias xdw='ls /usr/share/wayland-sessions'

# Sistema y mantenimiento.
alias give-me-azerty-be='sudo localectl set-x11-keymap be'
alias give-me-qwerty-us='sudo localectl set-x11-keymap us'
alias setlocale='sudo localectl set-locale LANG=en_US.UTF-8'
alias setlocales='sudo localectl set-x11-keymap be && sudo localectl set-locale LANG=en_US.UTF-8'
alias merge='xrdb -merge ~/.Xresources'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias grub-update='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias install-grub-efi='sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArcoLinux'
alias update-fc='sudo fc-cache -fv'
alias rmlogoutlock='sudo rm /tmp/arcologout.lock'
alias mirror='sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrord='sudo reflector --latest 30 --number 10 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors='sudo reflector --latest 30 --number 10 --sort score --save /etc/pacman.d/mirrorlist'
alias mirrora='sudo reflector --latest 30 --number 10 --sort age --save /etc/pacman.d/mirrorlist'
alias mirrorx='sudo reflector --age 6 --latest 20 --fastest 20 --threads 5 --sort rate --protocol https --save /etc/pacman.d/mirrorlist'
alias mirrorxx='sudo reflector --age 6 --latest 20 --fastest 20 --threads 20 --sort rate --protocol https --save /etc/pacman.d/mirrorlist'
alias ram='rate-mirrors --allow-root --disable-comments arch | sudo tee /etc/pacman.d/mirrorlist'
alias rams='rate-mirrors --allow-root --disable-comments --protocol https arch | sudo tee /etc/pacman.d/mirrorlist'
alias start-vmware='sudo systemctl enable --now vmtoolsd.service'
alias vmware-start='sudo systemctl enable --now vmtoolsd.service'
alias sv='sudo systemctl enable --now vmtoolsd.service'
alias unhblock='hblock -S none -D none'
alias probe='sudo edu-probe'
alias ssn='sudo shutdown now'
alias sr='reboot'
alias kc='killall conky'
alias kp='killall polybar'
alias kpi='killall picom'

# Gestores de sesion; conservados por paridad con Fish.
alias tolightdm='sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm --needed; sudo systemctl enable lightdm.service -f; echo "LightDM esta activo; reinicia cuando corresponda."'
alias tosddm='sudo pacman -S sddm --noconfirm --needed; sudo systemctl enable sddm.service -f; echo "SDDM esta activo; reinicia cuando corresponda."'
alias toly='sudo pacman -S ly --noconfirm --needed; sudo systemctl enable ly.service -f; echo "Ly esta activo; reinicia cuando corresponda."'
alias togdm='sudo pacman -S gdm --noconfirm --needed; sudo systemctl enable gdm.service -f; echo "GDM esta activo; reinicia cuando corresponda."'
alias tolxdm='sudo pacman -S lxdm --noconfirm --needed; sudo systemctl enable lxdm.service -f; echo "LXDM esta activo; reinicia cuando corresponda."'
alias toemptty='sudo pacman -S emptty --noconfirm --needed; sudo systemctl enable emptty.service -f; echo "emptty esta activo; reinicia cuando corresponda."'

# Cambio de shell. No se ejecuta automaticamente.
alias tobash='sudo chsh "$USER" -s /bin/bash && echo "Listo. Cierra la sesion."'
alias tozsh='sudo chsh "$USER" -s /bin/zsh && echo "Listo. Cierra la sesion."'
alias tofish='sudo chsh "$USER" -s /bin/fish && echo "Listo. Cierra la sesion."'

# Multimedia.
alias yta-aac='yt-dlp --extract-audio --audio-format aac'
alias yta-best='yt-dlp --extract-audio --audio-format best'
alias yta-flac='yt-dlp --extract-audio --audio-format flac'
alias yta-mp3='yt-dlp --extract-audio --audio-format mp3'
alias ytv-best="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4"

# Edicion de configuracion.
alias nlxdm='sudo $EDITOR /etc/lxdm/lxdm.conf'
alias nlightdm='sudo $EDITOR /etc/lightdm/lightdm.conf'
alias npacman='sudo $EDITOR /etc/pacman.conf'
alias ngrub='sudo $EDITOR /etc/default/grub'
alias nconfgrub='sudo $EDITOR /boot/grub/grub.cfg'
alias nmakepkg='sudo $EDITOR /etc/makepkg.conf'
alias nmkinitcpio='sudo $EDITOR /etc/mkinitcpio.conf'
alias nmirrorlist='sudo $EDITOR /etc/pacman.d/mirrorlist'
alias nchaoticmirrorlist='sudo $EDITOR /etc/pacman.d/chaotic-mirrorlist'
alias nsddm='sudo $EDITOR /etc/sddm.conf'
alias nsddmk='sudo $EDITOR /etc/sddm.conf.d/kde_settings.conf'
alias nsddmd='sudo $EDITOR /usr/lib/sddm/sddm.conf.d/default.conf'
alias nfstab='sudo $EDITOR /etc/fstab'
alias nnsswitch='sudo $EDITOR /etc/nsswitch.conf'
alias nsamba='sudo $EDITOR /etc/samba/smb.conf'
alias ngnupgconf='sudo $EDITOR /etc/pacman.d/gnupg/gpg.conf'
alias nhosts='sudo $EDITOR /etc/hosts'
alias nhostname='sudo $EDITOR /etc/hostname'
alias nresolv='sudo $EDITOR /etc/resolv.conf'
alias nb='$EDITOR ~/.bashrc'
alias nz='$EDITOR ~/.zshrc'
alias nf='$EDITOR ~/.config/fish/config.fish'
alias nneofetch='$EDITOR ~/.config/neofetch/config.conf'
alias nfastfetch='$EDITOR ~/.config/fastfetch/config.jsonc'
alias nplymouth='sudo $EDITOR /etc/plymouth/plymouthd.conf'
alias nvconsole='sudo $EDITOR /etc/vconsole.conf'
alias nenvironment='sudo $EDITOR /etc/environment'
alias nloader='sudo $EDITOR /boot/efi/loader/loader.conf'
alias nrefind='sudo $EDITOR /boot/refind_linux.conf'
alias nalacritty='$EDITOR ~/.config/alacritty/alacritty.toml'
alias nemptty='sudo $EDITOR /etc/emptty/conf'
alias nkitty='$EDITOR ~/.config/kitty/kitty.conf'
alias npicom='$EDITOR ~/.config/arco-chadwm/picom/picom.conf'

# Logs y GPG.
alias lcalamares='bat /var/log/Calamares.log'
alias lpacman='bat /var/log/pacman.log'
alias lxorg='bat /var/log/Xorg.0.log'
alias lxorgo='bat /var/log/Xorg.0.log.old'
alias scal='subl /var/log/Calamares.log'
alias spac='subl /etc/pacman.conf'
alias rvariety='edu-remove-variety'
alias rkmix='edu-remove-kmix'
alias rconky='edu-remove-conky'
alias gpg-check='gpg2 --keyserver-options auto-key-retrieve --verify'
alias fix-gpg-check='gpg2 --keyserver-options auto-key-retrieve --verify'
alias gpg-retrieve='gpg2 --keyserver-options auto-key-retrieve --receive-keys'
alias fix-gpg-retrieve='gpg2 --keyserver-options auto-key-retrieve --receive-keys'
alias fix-keyserver='[[ -d ~/.gnupg ]] || mkdir ~/.gnupg; cp /etc/pacman.d/gnupg/gpg.conf ~/.gnupg/; echo listo'
alias fix-permissions='sudo chown -R "$USER:$USER" ~/.config ~/.local'
alias keyfix='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias key-fix='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias keys-fix='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias fixkey='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias fixkeys='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias fix-key='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias fix-keys='/usr/local/bin/edu-fix-pacman-databases-and-keys'
alias fix-pacman-conf='/usr/local/bin/edu-fix-pacman-conf'
alias fix-pacman-keyserver='/usr/local/bin/edu-fix-pacman-gpg-conf'
alias fix-archlinux-mirrors='/usr/local/bin/edu-fix-archlinux-servers'

# Git y utilidades locales.
alias rmgitcache='rm -r ~/.cache/git'
alias grh='git reset --hard'
alias undopush='git push -f origin HEAD^:master'
alias rg='rg --sort path'
alias cls='clean'
alias md='sdoc bridge'

# No se migran cb/cz/cf: sobrescribirian archivos que ahora gestiona lnk.

# Fastfetch se muestra una sola vez al abrir una terminal, igual que en Fish.
[[ -t 1 ]] && (( $+commands[fastfetch] )) && fastfetch

# Starship es el prompt activo de Fish y Zsh.
if (( _zsh_has_tty )) && [[ -o zle ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Debe cargarse al final para poder resaltar todos los widgets anteriores.
if (( _zsh_has_tty )) && [[ -o zle ]] && [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_STYLES[command]='fg=#0782DE'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#fb4934'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#b8bb26'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#b8bb26'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#f0c674'
fi

unset _zsh_has_tty
