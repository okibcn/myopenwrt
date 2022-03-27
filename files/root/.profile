export EDITOR=nano
export PAGER=less

dl() {
  [ -z "$1" ] && echo "download URL sage: dl <url>" && return 1
  [ -z "$2" ] && wget "$1" -O "$(basename "$1")" || wget -O "$2" "$1"
}

mcd() {
  [ -z "$1" ] && echo "make and change to dir Usage: mcd <dir>" && return 1
  mkdir -p $1 && cd $1
}

f() {
  [ -z "$1" ] && echo "find file: f [dir] <filename>" && return 1
  [ -z "$2" ] && find . -name "$1" || find "$1" -name "$2"
}

fin() {
  [ -z "$1" ] && echo "find in file: fin [file or dir] <string>" && return 1
  [ -z "$2" ] && grep --color=auto -rnw * -e "$1" || grep --color=auto -rnw "$1" -e "$2"
}

tim(){
  [ -z "$1" ] && echo "Returns execution time: tim <command> [args]" && return 1
    read up rest </proc/uptime; t1="${up%.*}${up#*.}"
    $@
    read up rest </proc/uptime; t2="${up%.*}${up#*.}"
    echo "$( awk "BEGIN {print ($t2-$t1)/100}" ) seconds"
}

calc() {
  [ -z "$1" ] && echo "Performs floating point calculations: calc <math expression>" && return 1
    awk "BEGIN {print $@}"
}

x() {
    if [ -z "$1" ]; then
        # display usage if no parameters given
        echo "Usage: x <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        echo "       x <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
        return 1
    else
        for n in $@; do
            if [ -f "$n" ]; then
                case "${n%,}" in
                *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
                    tar xzvf "$n"
                    ;;
                *.lzma) unlzma ./"$n" ;;
                *.bz2) bunzip2 ./"$n" ;;
                *.rar) unrar x -ad ./"$n" ;;
                *.gz) gunzip ./"$n" ;;
                *.zip) unzip ./"$n" ;;
                *.z) uncompress ./"$n" ;;
                *.7z | *.arj | *.cab | *.chm | *.deb | *.dmg | *.iso | *.bin | *.img | *.lzh | *.msi | *.rpm | *.udf | *.wim | *.xar)
                    7z x "$n"
                    ;;
                *.xz) unxz ./"$n" ;;
                *.exe) cabextract ./"$n" ;;
                *)
                    echo "extract: '$n' - unknown archive method"
                    return 1
                    ;;
                esac
            else
                echo "'$n' - file does not exist"
                return 1
            fi
        done
    fi
}

alias ..='cd ..'
alias cd..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias l='ls -CFA --color=auto'
alias d='ls -CFA --color=auto'
alias ll='ls -alsF --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias md='mkdir'
alias now='date +"%T"'
alias today='date +"%Y.%m.%d"'
alias path='echo -e ${PATH//:/\\n}'
alias du1='du -hd 1'
alias meminfo='free -m -l -t'
alias cpuinfo='cat /proc/cpuinfo'
alias ver='cat /etc/os-release ; uname -a'
alias chexe='chmod +x'
alias chrw='chmod 777'
alias i='opkg install'
alias up='opkg update'
alias manifest="opkg list-installed |awk '{print \$1}' |sort"
alias bw='while true ; do clear ; nlbw -c show -g mac -o -rx_bytes; sleep 5; done'
alias mc='mc -P "/tmp/mc-$USER/mc.pwd"; cd `cat /tmp/mc-$USER/mc.pwd`; yes | rm -f /tmp/mc-$USER/mc.pwd'
