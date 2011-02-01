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

# {{{ System info
if [[ -z "${!cache_uname_*}" ]] ; then
    cache_uname_s=$(uname -s 2>&1 || echo "Linux" )
    cache_uname_m=$(uname -m 2>&1 || echo "i686" )
    case "${cache_uname_m}" in
        i?86)
            cache_gentoo_arch=x86
            ;;
        sparc*)
            cache_gentoo_arch=sparc
            ;;
        *)
            cache_gentoo_arch=${cache_uname_m}
            ;;
    esac
fi
# }}}

# {{{ Core
ulimit -c0
# }}}

# {{{ Terminal Settings
case "${TERM}" in
    xterm*)
        export TERM=xterm-256color
        cache_term_colours=256
        ;;
    screen)
        cache_term_colours=256
        ;;
    dumb)
        cache_term_colours=2
        ;;
    *)
        cache_term_colours=16
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
fi
if [[ -f /usr/bin/vimpager ]] ; then
    export PAGER=vimpager
    export MANPAGER=vimmanpager
elif [[ -f /usr/share/vim/vim63/macros/less.sh ]] ; then
    export PAGER="/usr/share/vim/vim63/macros/less.sh"
elif [[ -f /usr/share/vim/vim70aa/macros/less.sh ]] ; then
    export PAGER="/usr/share/vim/vim70aa/macros/less.sh"
else
    export MANPAGER="LANG=C less -r"
fi
alias page=$PAGER
# }}}

# {{{ mozilla
export MOZILLA_NEWTYPE=tab
# }}}

# {{{ ls, pushd etc
if [[ -f /etc/DIR_COLORS ]] ; then
    if [[ ${cache_term_colours} -ge 8  ]] ; then
        eval $(dircolors -b /etc/DIR_COLORS )
        alias ls="ls --color=if-tty"
        alias ll="ls --color=if-tty -l -h"
    else
        alias ll="ls -l -h"
    fi
elif [[ "${cache_uname_s}" == "FreeBSD" ]] ; then
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
for a in /etc/profile.d/bash-completion{,.sh} ; do
    if [[ -f "${a}" ]] ; then
        source "${a}"
        break
    fi
done
export COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}

export FIGNORE='~'

export HISTCONTROL=ignorespace:ignoredups
export HISTFILESIZE=50000
export HISTSIZE=50000
# }}}

# {{{ CVS
alias cu="cvs upd"
# }}}

# {{{ SVN
[[ -d ${HOME}/svn ]] && svn_repo_dir=${HOME}/svn
alias svu="svn update"
alias svs="svn status"
alias svc="svn commit"
alias sva="svn add"
alias svar="svn status | grep '^\?' | cut -d\  -f2- | xargs svn add"
svnew() {
    [[ -z "$1" ]] && ( echo "need a parameter" ; return 1 )
    svnadmin create ${HOME}/svn/$1 && \
        svn checkout file://${HOME}/svn/$1
}
# }}}

# {{{ git
alias gis="git status | grep --color=never '^[^a-z]\+\(new file:\|modified:\)' |
cut -d'#' -f2-"
# }}}

# {{{ RSYNC
alias ssync="rsync --rsh=ssh"
alias ssyncr="rsync --rsh=ssh --recursive --verbose --progress"
# }}}

# {{{ Random aliases
alias lib="telnet eleanor.lib.gla.ac.uk"

grab() {
    sudo chown -R ${USER} ${1:-.}
}

mkcd() {
    mkdir $1 && cd $1
}

qcd() {
    cd $1 2>/dev/null
}

fcd() {
    qcd ~/$1 || qcd ~/work/$1 || qcd ~/cvs/$1 || ecd $1
}

alias hmake="hilite make"
alias hmakej="hilite make -j"
alias clean="rm *~"

vgm() {
    valgrind -q --tool=memcheck --leak-check=yes \
        $([[ -f misc/valgrind-suppress ]] && \
            echo --suppressions=misc/valgrind-suppress ) \
        "$@"
}

mktar() {
    tar jcvf "${1%%/}.tar.bz2" "${1%%/}/"
}

makepasswords() {
    # suggest a bunch of possible passwords. not suitable for really early perl
    # versions that don't do auto srand() things.
    perl <<EOPERL
        my @a = ("a".."z","A".."Z","0".."9",(split //, q{#@,.<>$%&()*^}));
        for (1..10) {
            print join "", map { \$a[rand @a] } (1..rand(3)+7);
            print qq{\n}
        }
EOPERL
}

echo1() {
    echo "$1"
}

if ! type tac &>/dev/null ; then
    alias tac="sed -n -e '1!G;\$p;h'"
fi

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

# {{{ Paludis
export PALUDIS_OPTIONS="--resume-command-template ${HOME}/.paludis-resume/XXXXXX"
# }}}

# {{{ Gentoo things
if [[ -f /etc/gentoo-release ]] ; then
    export ECHANGELOG_USER="Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>"

    alias accept="ACCEPT_KEYWORDS='~${cache_gentoo_arch}'"
    alias acceptp="accept emerge -pv"
    alias accepte="accept sudo emerge"

    esync() {
        sudo emerge --sync
    }

    alias eupdp="emerge -uDpv world"
    alias eupd="sudo emerge -uD world"
    alias eetc="sudo /usr/sbin/etc-update"

    alias reps="repoman scan"
    alias repc="repoman commit"
    alias ech="echangelog"
    alias echvb="echangelog 'Version bump'"
    alias fixh='sed -i -e "1s,-200.,-`date +%Y`,"'
    alias remrw="sudo mount -oremount -orw"

    svcs () {
        sudo /etc/init.d/$1 start
    }

    svce () {
        sudo /etc/init.d/$1 stop
    }

    svcr () {
        sudo /etc/init.d/$1 restart
    }

    svcz () {
        sudo /etc/init.d/$1 zap
    }

    rca () {
        sudo /sbin/rc-update add $1 default
    }

    rcd () {
        sudo /sbin/rc-update del $1 default
    }

    uploadtogentoomirrors() {
        scp $1 dev.gentoo.org:/space/distfiles*local/ && \
            ssh dev.gentoo.org chmod g+rw /space/distfiles*local/$1
    }

    uploadconfigfile() {
        scp $1 dev.gentoo.org:public_html/configs/${1#.}
    }

    explainuseflag() {
        sed -ne "s,^\([^ ]*:\)\?$1 - ,,p" \
            /usr/portage/profiles/use.desc \
            /usr/portage/profiles/use.local.desc
    }

    edesc() {
        cat *.ebuild | sed -ne 's-^DESCRIPTION="\(.*\)".*-\1-1p' | sort -u
    }

    ewww() {
        cat *.ebuild | sed -ne 's-^HOMEPAGE="\(.*\)".*-\1-1p' | sort -u
    }

fi
# }}}

# {{{ minicom
alias minic='echo -ne "\033]0;minicom\007" ; minicom -c on'
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

compiler-gcc-4.6() {
    local s=$(ls /etc/env.d/gcc/x86_64-pc-linux-gnu-4.6.0* | sort | tail -n1 | xargs basename | sed -e 's,.*-,-,')
    export \
        CFLAGS="-O2 -D__CIARANM_WAS_HERE -pipe -g -ggdb3 -march=native" \
        CXXFLAGS="-O2 -D__CIARANM_WAS_HERE -pipe -g -ggdb3 -march=native" \
        LDFLAGS="-Wl,--as-needed" \
        PATH="/usr/lib/ccache/bin/:/usr/libexec/ccache/:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.0${s}:${PATH}" \
        ACTIVE_COMPILER="+4.6${s}" \
        ROOTPATH="/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.0${s}" \
        GCC_PATH="/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.0${s}" \
        LDPATH="/usr/lib/gcc/x86_64-pc-linux-gnu/4.6.0${s}:/usr/lib/gcc/x86_64-pc-linux-gnu/4.6.0${s}/32" \
        MANPATH="/usr/share/gcc-data/x86_64-pc-linux-gnu/4.6.0${s}/man" \
        INFOPATH="/usr/share/gcc-data/x86_64-pc-linux-gnu/4.6.0${s}/info" \
        STDCXX_INCDIR="g++-v4"
}

compiler-icc() {
    . /opt/intel/cce/*/bin/iccvars.sh
    export CC=icc CXX=icpc CXXFLAGS="-O1 -D__CIARANM_WAS_HERE__ -g -pipe" \
        ACTIVE_COMPILER="+icc"
}
# }}}

# {{{ Colours
case "${cache_term_colours}" in
    256)
        cache_colour_l_blue='\033[38;5;33m'
        cache_colour_d_blue='\033[38;5;21m'
        cache_colour_m_purp='\033[38;5;69m'
        cache_colour_l_yell='\033[38;5;229m'
        cache_colour_m_yell='\033[38;5;227m'
        cache_colour_m_gren='\033[38;5;35m'
        cache_colour_m_grey='\033[38;5;245m'
        cache_colour_m_orng='\033[38;5;208m'
        cache_colour_l_pink='\033[38;5;206m'
        cache_colour_m_teal='\033[38;5;38m'
        cache_colour_m_brwn='\033[38;5;130m'
        cache_colour_l_whte='\033[38;5;230m'
        cache_colour_end='\033[0;0m'
        ;;
    16)
        cache_colour_l_blue='\033[1;34m'
        cache_colour_d_blue='\033[0;32m'
        cache_colour_m_purp='\033[0;35m'
        cache_colour_l_yell='\033[1;33m'
        cache_colour_m_yell='\033[0;33m'
        cache_colour_m_gren='\033[0;32m'
        cache_colour_m_grey='\033[0;37m'
        cache_colour_m_orng='\033[1;31m'
        cache_colour_l_pink='\033[1;35m'
        cache_colour_m_teal='\033[0;36m'
        cache_colour_m_brwn='\033[0;31m'
        cache_colour_l_whte='\033[0;37m'
        cache_colour_end='\033[0;0m'
        ;;
    *)
        eval unset ${!cache_colour_*}
        ;;
esac

cache_colour_usr=${cache_colour_l_yell}
cache_colour_cwd=${cache_colour_m_gren}
cache_colour_wrk=${cache_colour_m_teal}
cache_colour_rok=${cache_colour_l_yell}
cache_colour_rer=${cache_colour_m_orng}
cache_colour_job=${cache_colour_l_pink}
cache_colour_dir=${cache_colour_m_brwn}
cache_colour_mrk=${cache_colour_m_yell}
cache_colour_lda=${cache_colour_m_yell}
cache_colour_scr=${cache_colour_l_blue}
cache_colour_scm=${cache_colour_m_orng}

case "${HOSTNAME:-$(hostname )}" in
    snowblower*)
        cache_colour_hst=${cache_colour_l_whte}
        ;;
    snowcone*)
        cache_colour_hst=${cache_colour_m_purp}
        ;;
    snowmobile*)
        cache_colour_hst=${cache_colour_m_orng}
        ;;
    snowmelt*)
        cache_colour_hst=${cache_colour_l_whte}
        ;;
    *)
        cache_colour_hst=${cache_colour_m_gren}
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
        echo -e "${cache_colour_rok}"
    else
        echo -e "${cache_colour_rer}"
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
ps_usr="\[${cache_colour_usr}\]\u@"
ps_hst="\[${cache_colour_hst}\]\h "
ps_cwd="\[${cache_colour_cwd}\]\W\[${cache_colour_wrk}\]\$(ps_wrk_f) "
ps_mrk="\[${cache_colour_mrk}\]\$ "
ps_end="\[${cache_colour_end}\]"
ps_ret='\[$(ps_retc_f $prompt_exit_status)\]$prompt_exit_status '
ps_job="\[${cache_colour_job}\]\$(ps_job_f)"
ps_lda="\[${cache_colour_lda}\]\$(ps_lda_f)"
ps_dir="\[${cache_colour_dir}\]\$(ps_dir_f)"
ps_scr="\[${cache_colour_scr}\]\$(ps_scr_f)"
ps_scm="\[${cache_colour_scm}\]\$(ps_scm_f)"
export PS1="${ps_sav}${ps_usr}${ps_hst}${ps_cwd}${ps_ret}${ps_lda}${ps_job}${ps_dir}${ps_scr}${ps_scm}"
export PS1="${PS1}${ps_mrk}${ps_end}"
# }}}

true

# vim: set et ts=4 tw=120 :
