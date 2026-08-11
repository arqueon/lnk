# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# SmallDocs alias
alias md="sdoc bridge"

# added by the sdoc installer
export PATH="$HOME/.sdocs/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Force remote changes to prevail on 'lnk pull'
lnk() {
    if [[ "$1" == "pull" ]]; then
        local repo="${LNK_HOME:-$HOME/.config/lnk}"
        git -C "$repo" fetch origin 2>/dev/null
        git -C "$repo" reset --hard origin/main 2>/dev/null
        shift
        command lnk pull "$@"
    else
        command lnk "$@"
    fi
}
