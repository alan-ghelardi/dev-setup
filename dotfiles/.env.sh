export PATH=$PATH:$HOME/.local/bin

# Default system editor.
export EDITOR=emacs

# GitHub
export GITHUB_USER=alan-ghelardi
export GITHUB_TOKEN=`cat ~/.secrets/github-token`

# Golang
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# GPG
export PINENTRY_USER_DATA="USE_CURSES=1"
export GPG_TTY=$(tty)
unset SSH_AGENT_PID
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# Java
export JAVA_HOME=/usr/lib/jdk/jdk-11.0.8
# Force JDK11 to have the same locale behavior as JDK8
export _JAVA_OPTIONS="-Djava.locale.providers='COMPAT,JRE,CLDR'"

export PATH="$PATH:$JAVA_HOME/bin"

# Kubernetes
export KUBE_EDITOR=emacs

# Leiningen
# Prevent undesired errors caused by missing modules in Java 9 or higher.
# For instance, clojure.instant depends on java.sql.Timestamp whose module
# (java.sql) isn't available in the new Java module system.
export LEIN_USE_BOOTCLASSPATH=no

# Node
# Add the location of the node binary installed via nvm to the path to make
# it visible to the LSP server from within Emacs.
 export PATH=$PATH:$(dirname $(which node))

# Nubank
export NU_HOME="$HOME/dev/nu"
export NUCLI_HOME="$NU_HOME/nucli"
export PATH="$PATH:$NUCLI_HOME"
