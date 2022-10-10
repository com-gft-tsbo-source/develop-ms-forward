COMPONENT=all
source ../setup.sh
export KUBERNETES_NAMESPACE="${KUBERNETES_BASE_NAMESPACE}"

export PS1='\[\e]0;\[\033[00;34m\]$(nice_path "\w")\[\033[00m\] $(if [[ $? == 0 ]]; then echo -en "\[\033[00;32m\]✓\[\033[00m\]"; else echo -en "\[\033[00;31m\]✗\[\033[00m\]"; fi) \$ '
