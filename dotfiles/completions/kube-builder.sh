# bash completion for kubebuilder                          -*- shell-script -*-

__kubebuilder_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__kubebuilder_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__kubebuilder_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__kubebuilder_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__kubebuilder_handle_go_custom_completion()
{
    __kubebuilder_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly kubebuilder allows handling aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="KUBEBUILDER_ACTIVE_HELP=0 ${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __kubebuilder_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __kubebuilder_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __kubebuilder_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __kubebuilder_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __kubebuilder_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __kubebuilder_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __kubebuilder_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __kubebuilder_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __kubebuilder_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __kubebuilder_debug "Listing directories in $subdir"
            __kubebuilder_handle_subdirs_in_dir_flag "$subdir"
        else
            __kubebuilder_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__kubebuilder_handle_reply()
{
    __kubebuilder_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __kubebuilder_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __kubebuilder_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __kubebuilder_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __kubebuilder_custom_func >/dev/null; then
            # try command name qualified custom func
            __kubebuilder_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__kubebuilder_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__kubebuilder_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__kubebuilder_handle_flag()
{
    __kubebuilder_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __kubebuilder_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __kubebuilder_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __kubebuilder_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __kubebuilder_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __kubebuilder_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__kubebuilder_handle_noun()
{
    __kubebuilder_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __kubebuilder_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __kubebuilder_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__kubebuilder_handle_command()
{
    __kubebuilder_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_kubebuilder_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __kubebuilder_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__kubebuilder_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __kubebuilder_handle_reply
        return
    fi
    __kubebuilder_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __kubebuilder_handle_flag
    elif __kubebuilder_contains_word "${words[c]}" "${commands[@]}"; then
        __kubebuilder_handle_command
    elif [[ $c -eq 0 ]]; then
        __kubebuilder_handle_command
    elif __kubebuilder_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __kubebuilder_handle_command
        else
            __kubebuilder_handle_noun
        fi
    else
        __kubebuilder_handle_noun
    fi
    __kubebuilder_handle_word
}

_kubebuilder_alpha_generate()
{
    last_command="kubebuilder_alpha_generate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--input-dir=")
    two_word_flags+=("--input-dir")
    local_nonpersistent_flags+=("--input-dir")
    local_nonpersistent_flags+=("--input-dir=")
    flags+=("--output-dir=")
    two_word_flags+=("--output-dir")
    local_nonpersistent_flags+=("--output-dir")
    local_nonpersistent_flags+=("--output-dir=")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_alpha_update()
{
    last_command="kubebuilder_alpha_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--from-branch=")
    two_word_flags+=("--from-branch")
    local_nonpersistent_flags+=("--from-branch")
    local_nonpersistent_flags+=("--from-branch=")
    flags+=("--from-version=")
    two_word_flags+=("--from-version")
    local_nonpersistent_flags+=("--from-version")
    local_nonpersistent_flags+=("--from-version=")
    flags+=("--git-config=")
    two_word_flags+=("--git-config")
    local_nonpersistent_flags+=("--git-config")
    local_nonpersistent_flags+=("--git-config=")
    flags+=("--open-gh-issue")
    local_nonpersistent_flags+=("--open-gh-issue")
    flags+=("--output-branch=")
    two_word_flags+=("--output-branch")
    local_nonpersistent_flags+=("--output-branch")
    local_nonpersistent_flags+=("--output-branch=")
    flags+=("--push")
    local_nonpersistent_flags+=("--push")
    flags+=("--restore-path=")
    two_word_flags+=("--restore-path")
    local_nonpersistent_flags+=("--restore-path")
    local_nonpersistent_flags+=("--restore-path=")
    flags+=("--show-commits")
    local_nonpersistent_flags+=("--show-commits")
    flags+=("--to-version=")
    two_word_flags+=("--to-version")
    local_nonpersistent_flags+=("--to-version")
    local_nonpersistent_flags+=("--to-version=")
    flags+=("--use-gh-models")
    local_nonpersistent_flags+=("--use-gh-models")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_alpha()
{
    last_command="kubebuilder_alpha"

    command_aliases=()

    commands=()
    commands+=("generate")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_completion_bash()
{
    last_command="kubebuilder_completion_bash"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_completion_fish()
{
    last_command="kubebuilder_completion_fish"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_completion_powershell()
{
    last_command="kubebuilder_completion_powershell"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_completion_zsh()
{
    last_command="kubebuilder_completion_zsh"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_completion()
{
    last_command="kubebuilder_completion"

    command_aliases=()

    commands=()
    commands+=("bash")
    commands+=("fish")
    commands+=("powershell")
    commands+=("zsh")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_create_api()
{
    last_command="kubebuilder_create_api"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--controller")
    local_nonpersistent_flags+=("--controller")
    flags+=("--external-api-domain=")
    two_word_flags+=("--external-api-domain")
    local_nonpersistent_flags+=("--external-api-domain")
    local_nonpersistent_flags+=("--external-api-domain=")
    flags+=("--external-api-module=")
    two_word_flags+=("--external-api-module")
    local_nonpersistent_flags+=("--external-api-module")
    local_nonpersistent_flags+=("--external-api-module=")
    flags+=("--external-api-path=")
    two_word_flags+=("--external-api-path")
    local_nonpersistent_flags+=("--external-api-path")
    local_nonpersistent_flags+=("--external-api-path=")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--kind=")
    two_word_flags+=("--kind")
    local_nonpersistent_flags+=("--kind")
    local_nonpersistent_flags+=("--kind=")
    flags+=("--make")
    local_nonpersistent_flags+=("--make")
    flags+=("--namespaced")
    local_nonpersistent_flags+=("--namespaced")
    flags+=("--plural=")
    two_word_flags+=("--plural")
    local_nonpersistent_flags+=("--plural")
    local_nonpersistent_flags+=("--plural=")
    flags+=("--resource")
    local_nonpersistent_flags+=("--resource")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_create_webhook()
{
    last_command="kubebuilder_create_webhook"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--conversion")
    local_nonpersistent_flags+=("--conversion")
    flags+=("--defaulting")
    local_nonpersistent_flags+=("--defaulting")
    flags+=("--defaulting-path=")
    two_word_flags+=("--defaulting-path")
    local_nonpersistent_flags+=("--defaulting-path")
    local_nonpersistent_flags+=("--defaulting-path=")
    flags+=("--external-api-domain=")
    two_word_flags+=("--external-api-domain")
    local_nonpersistent_flags+=("--external-api-domain")
    local_nonpersistent_flags+=("--external-api-domain=")
    flags+=("--external-api-module=")
    two_word_flags+=("--external-api-module")
    local_nonpersistent_flags+=("--external-api-module")
    local_nonpersistent_flags+=("--external-api-module=")
    flags+=("--external-api-path=")
    two_word_flags+=("--external-api-path")
    local_nonpersistent_flags+=("--external-api-path")
    local_nonpersistent_flags+=("--external-api-path=")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--kind=")
    two_word_flags+=("--kind")
    local_nonpersistent_flags+=("--kind")
    local_nonpersistent_flags+=("--kind=")
    flags+=("--legacy")
    local_nonpersistent_flags+=("--legacy")
    flags+=("--make")
    local_nonpersistent_flags+=("--make")
    flags+=("--plural=")
    two_word_flags+=("--plural")
    local_nonpersistent_flags+=("--plural")
    local_nonpersistent_flags+=("--plural=")
    flags+=("--programmatic-validation")
    local_nonpersistent_flags+=("--programmatic-validation")
    flags+=("--spoke=")
    two_word_flags+=("--spoke")
    local_nonpersistent_flags+=("--spoke")
    local_nonpersistent_flags+=("--spoke=")
    flags+=("--validation-path=")
    two_word_flags+=("--validation-path")
    local_nonpersistent_flags+=("--validation-path")
    local_nonpersistent_flags+=("--validation-path=")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_create()
{
    last_command="kubebuilder_create"

    command_aliases=()

    commands=()
    commands+=("api")
    commands+=("webhook")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_edit()
{
    last_command="kubebuilder_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--multigroup")
    local_nonpersistent_flags+=("--multigroup")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_help()
{
    last_command="kubebuilder_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_kubebuilder_init()
{
    last_command="kubebuilder_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--domain=")
    two_word_flags+=("--domain")
    local_nonpersistent_flags+=("--domain")
    local_nonpersistent_flags+=("--domain=")
    flags+=("--fetch-deps")
    local_nonpersistent_flags+=("--fetch-deps")
    flags+=("--license=")
    two_word_flags+=("--license")
    local_nonpersistent_flags+=("--license")
    local_nonpersistent_flags+=("--license=")
    flags+=("--owner=")
    two_word_flags+=("--owner")
    local_nonpersistent_flags+=("--owner")
    local_nonpersistent_flags+=("--owner=")
    flags+=("--project-name=")
    two_word_flags+=("--project-name")
    local_nonpersistent_flags+=("--project-name")
    local_nonpersistent_flags+=("--project-name=")
    flags+=("--project-version=")
    two_word_flags+=("--project-version")
    local_nonpersistent_flags+=("--project-version")
    local_nonpersistent_flags+=("--project-version=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--skip-go-version-check")
    local_nonpersistent_flags+=("--skip-go-version-check")
    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_version()
{
    last_command="kubebuilder_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubebuilder_root_command()
{
    last_command="kubebuilder"

    command_aliases=()

    commands=()
    commands+=("alpha")
    commands+=("completion")
    commands+=("create")
    commands+=("edit")
    commands+=("help")
    commands+=("init")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--plugins=")
    two_word_flags+=("--plugins")
    flags+=("--project-version=")
    two_word_flags+=("--project-version")
    local_nonpersistent_flags+=("--project-version")
    local_nonpersistent_flags+=("--project-version=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_kubebuilder()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __kubebuilder_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("kubebuilder")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __kubebuilder_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_kubebuilder kubebuilder
else
    complete -o default -o nospace -F __start_kubebuilder kubebuilder
fi

# ex: ts=4 sw=4 et filetype=sh
