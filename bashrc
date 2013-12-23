########################################################################
# Evil bash settings file for Ciaran McCreesh
#
# Not many comments here, you'll have to guess how it works. Note that
# I use the same .bashrc on Linux, IRIX and Slowaris, so there's some
# strange uname stuff in there.
#
########################################################################

shopt -s extglob

# {{{ Locale stuff
eval unset ${!LC_*} LANG
export LANG="en_GB.UTF-8"
export LC_COLLATE="C"
# }}}

# {{{ timezone
if [[ -z "${TZ}" ]] ; then
    export TZ=Europe/London
fi
# }}}

# {{{ Core
ulimit -c0
# }}}

# {{{ Terminal Settings
case "${TERM}" in
    xterm*)
        export TERM=xterm-256color
        bashrc_term_colours=256
        ;;
    screen)
        bashrc_term_colours=256
        ;;
    dumb)
        bashrc_term_colours=2
        ;;
    *)
        bashrc_term_colours=16
        ;;
esac

case "${TERM}" in
    xterm*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac
# }}}

# {{{ Path
if [[ -n "${PATH/*$HOME\/bin:*/}" ]] ; then
    export PATH="$HOME/bin:$PATH"
fi

if [[ -n "${PATH/*\/usr\/local\/bin:*/}" ]] ; then
    export PATH="/usr/local/bin:$PATH"
fi

if [[ -n "${PATH/\/sbin:*/}" ]] ; then
    export PATH="$PATH:/sbin"
fi

if [[ -n "${PATH/\/usr\/sbin:*/}" ]] ; then
    export PATH="$PATH:/usr/sbin"
fi

if [[ -n "${PATH/\/texlive:*/}" ]] && [[ -d /usr/local/texlive/2012/bin/x86_64-linux/ ]] ; then
    export PATH="/usr/local/texlive/2012/bin/x86_64-linux/:$PATH"
fi

# }}}

# {{{ X
if [[ -z "${XSESSION}" ]] ; then
    export XSESSION=awesome
fi
# }}}

# {{{ Keychain
if [[ -z "${SSH_AGENT_PID}" ]] && type keychain &>/dev/null ; then
    eval $(keychain --quiet --eval id_dsa | sed -e 's,;,\n,g' )
fi
# }}}

# {{{ Pager
if [[ -f /usr/bin/less ]] ; then
    export PAGER=less
    export LESS="--ignore-case --long-prompt"
else
    export MANPAGER="env LANG=C less -r"
fi
alias page=$PAGER
# }}}

# {{{ mozilla
export MOZILLA_NEWTYPE=tab
# }}}

# {{{ ls, pushd etc
if [[ -f /etc/DIR_COLORS ]] && [[ ${bashrc_term_colours} -ge 8  ]] ; then
    eval $(dircolors -b /etc/DIR_COLORS )
    alias ls="ls --color=if-tty"
    alias ll="ls --color=if-tty -l -h"
elif type dircolors &>/dev/null && [[ ${bashrc_term_colours} -ge 8  ]] ; then
    eval $(dircolors )
    alias ls="ls --color=if-tty"
    alias ll="ls --color=if-tty -l -h"
elif [[ "${bashrc_uname_s}" == "FreeBSD" ]] ; then
    export CLICOLOR="yes"
    export LSCOLORS=Gxfxcxdxbxegedabagacad
    alias ll="ls -l -h"
else
    alias ll="ls -l"
fi

alias pd="pushd"
alias pp="popd"
# }}}

# {{{ Completion, history
if [[ -f /usr/share/bash-completion/bash_completion ]] ; then
    . /usr/share/bash-completion/bash_completion
fi

export COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}

export FIGNORE='~'

export HISTCONTROL=ignorespace:ignoredups
export HISTFILESIZE=50000
export HISTSIZE=50000

shopt -s histverify
# }}}

grab() {
    sudo chown -R ${USER} ${1:-.}
}

mkcd() {
    mkdir $1 && cd $1
}

alias clean="rm *~"

xt() {
    echo -n -e "\033]0;$*\007"
}

xa() {
    local retcode cmd="" c
    for c in "$@" ; do
        [[ ${c} == "nice" ]] || [[ ${c} == "ionice" ]] || \
            [[ ${c} == "sudo" ]] || [[ ${c#-} != ${c} ]] && continue
        if [[ -z ${cmd} ]] ; then
            cmd=${c}
        else
            cmd="${cmd} ${c}"
            break
        fi
    done
    echo $$ $cmd >> ~/.config/awesome/active
    "$@"
    retcode=$?
    sed -e "/^$$ /d" -i ~/.config/awesome/active
    return $retcode
}
# }}}

# {{{ screen
screen() {
    [[ -f ~/.screenrc ]] && sed -i -e "s!hardstatus string \".*\"!hardstatus string \"%h - $(hostname)\"!" \
        ~/.screenrc
    $(which screen ) "$@"
}
# }}}

# {{{ gcc
compiler-gcc() {
    export \
        CFLAGS="-O2 -D__CIARANM_WAS_HERE -pipe -g -ggdb3 -march=native" \
        CXXFLAGS="-O2 -D__CIARANM_WAS_HERE -pipe -g -ggdb3 -march=native" \
        LDFLAGS="-Wl,--as-needed" \
        PATH="/usr/lib/ccache/bin/:/usr/libexec/ccache/:${PATH}" \
        ACTIVE_COMPILER="+"
}
# }}}

# {{{ Colours
case "${bashrc_term_colours}" in
    256)
        bashrc_colour_l_blue='\033[38;5;33m'
        bashrc_colour_d_blue='\033[38;5;21m'
        bashrc_colour_m_purp='\033[38;5;69m'
        bashrc_colour_l_yell='\033[38;5;229m'
        bashrc_colour_m_yell='\033[38;5;227m'
        bashrc_colour_m_gren='\033[38;5;35m'
        bashrc_colour_m_grey='\033[38;5;245m'
        bashrc_colour_m_orng='\033[38;5;208m'
        bashrc_colour_l_pink='\033[38;5;206m'
        bashrc_colour_m_teal='\033[38;5;38m'
        bashrc_colour_m_brwn='\033[38;5;130m'
        bashrc_colour_l_whte='\033[38;5;230m'
        bashrc_colour_end='\033[0;0m'
        ;;
    16)
        bashrc_colour_l_blue='\033[1;34m'
        bashrc_colour_d_blue='\033[0;32m'
        bashrc_colour_m_purp='\033[0;35m'
        bashrc_colour_l_yell='\033[1;33m'
        bashrc_colour_m_yell='\033[0;33m'
        bashrc_colour_m_gren='\033[0;32m'
        bashrc_colour_m_grey='\033[0;37m'
        bashrc_colour_m_orng='\033[1;31m'
        bashrc_colour_l_pink='\033[1;35m'
        bashrc_colour_m_teal='\033[0;36m'
        bashrc_colour_m_brwn='\033[0;31m'
        bashrc_colour_l_whte='\033[0;37m'
        bashrc_colour_end='\033[0;0m'
        ;;
    *)
        eval unset ${!bashrc_colour_*}
        ;;
esac

bashrc_colour_usr=${bashrc_colour_l_yell}
bashrc_colour_cwd=${bashrc_colour_m_gren}
bashrc_colour_wrk=${bashrc_colour_m_teal}
bashrc_colour_rok=${bashrc_colour_l_yell}
bashrc_colour_rer=${bashrc_colour_m_orng}
bashrc_colour_job=${bashrc_colour_l_pink}
bashrc_colour_dir=${bashrc_colour_m_brwn}
bashrc_colour_mrk=${bashrc_colour_m_yell}
bashrc_colour_lda=${bashrc_colour_m_yell}
bashrc_colour_scr=${bashrc_colour_l_blue}
bashrc_colour_scm=${bashrc_colour_m_orng}

case "${HOSTNAME:-$(hostname )}" in
    snowblower*)
        bashrc_colour_hst=${bashrc_colour_m_grey}
        ;;
    snowcone*)
        bashrc_colour_hst=${bashrc_colour_m_purp}
        ;;
    snowbell*)
        bashrc_colour_hst=${bashrc_colour_l_blue}
        ;;
    snowstorm*)
        bashrc_colour_hst=${bashrc_colour_d_blue}
        ;;
    sibu*)
        bashrc_colour_hst=${bashrc_colour_m_orng}
        ;;
    padang*)
        bashrc_colour_hst=${bashrc_colour_m_teal}
        ;;
    savage|cyprus|karkar|futuna|togian|manipa|togian*)
        bashrc_colour_hst=${bashrc_colour_l_pink}
        ;;
    *)
        bashrc_colour_hst=${bashrc_colour_m_gren}
        ;;
esac
# }}}

# {{{ Prompt
ps_wrk_f() {
    if [[ "${PWD/ciaranm\/snow}" != "${PWD}" ]] ; then
        local p="snow${PWD#*/ciaranm/snow}"
        p="${p%%/*}"
        echo "@${p}"
    fi
}

ps_retc_f() {
    if [[ ${1} -eq 0 ]] ; then
        echo -e "${bashrc_colour_rok}"
    else
        echo -e "${bashrc_colour_rer}"
    fi
    return $1
}

ps_job_f() {
    local j="$(jobs)"
    if [[ -n ${j} ]] ; then
        local l="${j//[^$'\n']/}"
        echo "&$(( ${#l} + 1 )) "
    fi
}

ps_dir_f() {
    if [[ "${#DIRSTACK[@]}" -gt 1 ]] ; then
        echo "^$(( ${#DIRSTACK[@]} - 1 )) "
    fi
}

ps_lda_f() {
    local u=$(uptime )
    u=${u#*average?(s): }
    echo "${u%%,*} "
}

ps_scr_f() {
    if [[ "${TERM/screen/}" != "${TERM}" ]] ; then
        echo "s "
    fi
}

ps_scm_f() {
    local s=
    if [[ -d ".svn" ]] ; then
        local r=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p' )
        s="(r$r$(svn status | grep -q -v '^?' && echo -n "*" ))"
    else
        local d=$(git rev-parse --git-dir 2>/dev/null ) b= r= a= c= e= f= g=
        if [[ -n "${d}" ]] ; then
            if [[ -d "${d}/../.dotest" ]] ; then
                if [[ -f "${d}/../.dotest/rebase" ]] ; then
                    r="rebase"
                elif [[ -f "${d}/../.dotest/applying" ]] ; then
                    r="am"
                else
                    r="???"
                fi
                b=$(git symbolic-ref HEAD 2>/dev/null )
            elif [[ -f "${d}/.dotest-merge/interactive" ]] ; then
                r="rebase-i"
                b=$(<${d}/.dotest-merge/head-name)
            elif [[ -d "${d}/../.dotest-merge" ]] ; then
                r="rebase-m"
                b=$(<${d}/.dotest-merge/head-name)
            elif [[ -f "${d}/MERGE_HEAD" ]] ; then
                r="merge"
                b=$(git symbolic-ref HEAD 2>/dev/null )
            elif [[ -f "${d}/BISECT_LOG" ]] ; then
                r="bisect"
                b=$(git symbolic-ref HEAD 2>/dev/null )"???"
            else
                r=""
                b=$(git symbolic-ref HEAD 2>/dev/null )
            fi

            if git status | grep -q '^# Changes not staged' ; then
                a="${a}*"
            fi

            if git status | grep -q '^# Changes to be committed:' ; then
                a="${a}+"
            fi

            if git status | grep -q '^# Untracked files:' ; then
                a="${a}?"
            fi

            e=$(git status | sed -n -e '/^# Your branch is /s/^.*\(ahead\|behind\).* by \(.*\) commit.*/\1 \2/p' )
            if [[ -n ${e} ]] ; then
                f=${e#* }
                g=${e% *}
                if [[ ${g} == "ahead" ]] ; then
                    e="+${f}"
                else
                    e="-${f}"
                fi
            else
                e=
            fi

            b=${b#refs/heads/}
            b=${b// }
            [[ -n "${b}" ]] && c="$(git config "branch.${b}.remote" 2>/dev/null )"
            [[ -n "${r}${b}${c}${a}" ]] && s="(${r:+${r}:}${b}${c:+@${c}}${e}${a:+ ${a}})"
        fi
    fi
    s="${s}${ACTIVE_COMPILER}"
    s="${s:+${s} }"
    echo -n "$s"
}

PROMPT_COMMAND="export prompt_exit_status=\$? ; $PROMPT_COMMAND"
ps_usr="\[${bashrc_colour_usr}\]\u@"
ps_hst="\[${bashrc_colour_hst}\]\h "
ps_cwd="\[${bashrc_colour_cwd}\]\W\[${bashrc_colour_wrk}\]\$(ps_wrk_f) "
ps_mrk="\[${bashrc_colour_mrk}\]\$ "
ps_end="\[${bashrc_colour_end}\]"
ps_ret='\[$(ps_retc_f $prompt_exit_status)\]$prompt_exit_status '
ps_job="\[${bashrc_colour_job}\]\$(ps_job_f)"
ps_lda="\[${bashrc_colour_lda}\]\$(ps_lda_f)"
ps_dir="\[${bashrc_colour_dir}\]\$(ps_dir_f)"
ps_scr="\[${bashrc_colour_scr}\]\$(ps_scr_f)"
case "${HOSTNAME:-$(hostname )}" in
    snowstorm)
        ;;
    snow*)
        ps_scm="\[${bashrc_colour_scm}\]\$(ps_scm_f)"
        ;;
    padang)
        ps_scm="\[${bashrc_colour_scm}\]\$(ps_scm_f)"
        ;;
    *)
        ;;
esac
export PS1="${ps_sav}${ps_usr}${ps_hst}${ps_cwd}${ps_ret}${ps_lda}${ps_job}${ps_dir}${ps_scr}${ps_scm}"
export PS1="${PS1}${ps_mrk}${ps_end}"
# }}}

true

# vim: set et ts=4 tw=120 :
