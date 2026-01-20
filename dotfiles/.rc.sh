dotfiles=~/src/dev-setup/dotfiles

source $dotfiles/.env.sh
source ${dotfiles}/helpers/microphone.sh
source ${dotfiles}/helpers/tekton-results.sh

for file in $(ls $dotfiles/completions/*.sh); do
    source $(realpath $file)
done

# Nubank
source $HOME/.nurc

# Homebrew
if [ -d /home/linuxbrew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi
