#!/bin/bash

# Configures .ratpoisonrc.
# Written by Storm Dragon
# Released under the therms of the unlicense http://unlicense.org

# Gloabal Variables
true=0
false=1

# Get user input args are return variable, question, options
get_input()
{
# Variable names are long, cause I want absolutely no name conflicts.
local __get_input_input=$1
shift
local __get_input_question="$1"
shift
local __get_input_answer=""
local __get_input_i=""
local __get_input_continue=false
for __get_input_i in $@; do
if [ "${__get_input_i:0:1}" = "-" ]; then
local __get_input_default="${__get_input_i:1}"
fi
done
while [ $__get_input_continue = false ]; do
echo -n "$__get_input_question (${@/#-/})"
if [ -n "$__get_input_default" ]; then
read -e -i "$__get_input_default" __get_input_answer
else
read -e __get_input_answer
fi
for __get_input_i in $@; do
if [ "$__get_input_answer" = "${__get_input_i/#-/}" ]; then
__get_input_continue=true
break
fi
done
done
eval $__get_input_input="'$__get_input_answer'"
}

# Set  path for helper scripts.
path="${0##*/}"
exit 0
