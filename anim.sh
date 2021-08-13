#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Description 	- A simple script that allows to stream anime locally.
# Author 		- Sean Reyboz <seanreyboz@tuta.io>
# Date 			- 2021-08-08
# Last modified - 2021-08-13 - 11:37:34
#------------------------------------------------------------------------------

#							 ----- DISCLAIMER -----
#			  THIS PROGRAM HAS BEEN CREATED FOR LEARNING PURPOSES,
#				 AND SHOULD ONLY BE USED AS LEARNING MATERIAL.
#			  ---------------------------------------------------

# Exit status:
#	1: 		program error
#	2: 		user input error
#	130: 	sigint

prog="$0"
ver="2021-08-08"

# Player MUST be able to play urls
player='mpv'

# colors
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
rst='\e[0m'

prompt="$green> $rst"

trap "printf \"$red%s$rst\n\" \"Interruption signal received...\"; exit 130" INT

# error handling
err ()
{
	# display error message to stderr and exit
	printf "${red}Err:${rst} %s\n" "$1" 1>&2
	[ $2 -gt 0 ] && exit $2
}

# Debug function
debug ()
{
	[ $debug ] && printf "${magenta}DEBUG> ${yellow}%s${rst}: '%s'\n" "$1" "$2"
}

# help/usage message
usage ()
{
	while IFS= read line; do
		printf '%b\n' "$line"
	done <<-EOF
			Usage: $prog -s <query> [-h] [-v]

			Options:
			  -s, --search			- Search for the anime given in parameter
			  -d, --debug			- Search for anime in debug mode
			  -h, --help  			- Display this help and exit
			  -v, --version			- Display the version of $prog and exit
	EOF
}

searchAnime ()
{
	local url="https://gogoanime.vc//search.html"
	local id=0
	local data=
	local query=

	# Check whetever the user provided the -s option with a parameter
	if [ -z "$1" ]; then
		printf "%s\n$prompt" "What is the name of the anime you're looking for?"
		read -er query
	else
		query="$1"
	fi

	# Url encode the query to prevent any weird behavior from curl
	data="keyword=$(urlencode "$query")"
	debug "Urlencoded query" "$data"

	# Make sure the server is reachable
	if ! ping -c 1 gogoanime.vc >/dev/null 2>&1; then
		err "The server is unreachable. Check your internet & try again later" 1
	fi

	# Get all the animes that match the query, if any
	searchResult=$(curl -s "$url" -G -d "$data" 2>/dev/null |
		sed -r -n 's/^[[:space:]]+<a href="\/category\/(.+)" title="(.*)">.*$/\1 \2/p')

	if [ -n "$searchResult" ]; then
		printf "\n $green%-18s %-s$rst\n\n" 'ID' 'NAME'

		while read _ name; do
		 	printf ' %-10b %-b\n' "$id" "${cyan}$name${rst}"
			let id++
		done <<-EOF
		$searchResult
		EOF
	else
		err "Couldn't find any anime matching your query." 1
	fi

	# Prompt the user to choose one of the anime in the list
	animeSelection
}

animeSelection ()
{
	local count=0

	# Prompt the user to select an anime
	printf "\n%s\n$prompt" "Select the anime's ID you want to watch"
	read -er input

	# Verify that input is a number
	[ "$input" -eq "$input" ] 2>/dev/null || err "Not a number." 2

	# Get the url name of the selected anime
	while read line _; do
		[ "$input" -eq "$count" ] && selectedAnime=$line
		let count++
	done <<-EOF
	$searchResult
	EOF

	# Check for invalid anime ID
	local max=$(($count - 1))

	if [ $input -gt $max ] || [ $input -lt 0 ]; then
		err "Invalid anime ID (out of range)." 2
	fi

	# DEBUG:
	debug 'Selected anime is' "$selectedAnime"

	# Get the available episodes for the selected anime
	getEpsisodes
}

# Get the maximum number of episodes available for this anime/season
getEpsisodes ()
{
	local url="https://gogoanime.vc/category/$selectedAnime"

	# Get the maximum number of episodes for the selected anime
	episodes=$(curl -s "$url" |
		sed -n -E "s/[[:space:]]+<a href=\"#\" class=\"active\" ep_start.* ep_end = '([0-9]*)'.*/\1/p")

	[ -z "$episodes" ] && err "Can't get any episode for '$selectedAnime'" 1

	printf "%b\n$prompt" "Select an episode: [${yellow}1-$episodes${rst}]"
	read -er choosedEp

	# Make sure choosedEp is a number AND is not invalid
	[ $choosedEp -eq $choosedEp ] 2>/dev/null || err "Not a number." 2

	if [ $choosedEp -gt $episodes ] || [ $choosedEp -le 0 ]; then
		err "Invalid episode number (out of range)." 2
	fi

	# Get all the potentially downloadable links
	getLink
}

getLink ()
{
	if [ -n "$1" ]; then
		case "$1" in
			-)
				let choosedEp--
				printf '%s\n' "Getting video link for episode $choosedEp..."
				;;
			+)
				let choosedEp++
				printf '%s\n' "Getting video link for episode $choosedEp..."
				;;
		esac
	fi

	local url="https://gogoanime.vc/$selectedAnime-episode-$choosedEp"

	# DEBUG:
	debug "Episode url" "$url"

	link=$(curl -s "$url" |
		sed -r -n 's/^[[:space:]]+<li class="down?loads?".* href="(.*)" target.*/\1/p')

	video=$(curl -s "$link" | sed -r -n 's/.*href="(.*.mp4)".*>Download$/\1/p')

	# DEBUG:
	debug 'Video link' "$video"

	# Play the episode
	playAnime "$video"
}

playAnime ()
{
	# DEBUG:
	debug "Remote video link(s)" "$video"

	if $player "$video" >/dev/null 2>&1; then
		postEpisode
	else
		err "Unable to play this episode. Try again later, or try another episode." 1
	fi
}

postEpisode ()
{
	printf '%s\n' "Episode ended (reached EOF). Select one of the following options:"
	printf "Next [${green}n${rst}] - Previous [${green}p${rst}] - Quit [${yellow}q${rst}]\n"
	printf "$prompt"
	read -er choice
	case "$choice" in
		n)
			getLink "+" ;;
		p)
			getLink "-" ;;
		q)
			exit 0 ;;
		*)
			err "Invalid option '$choice'" 2
	esac
}

# big thanks to Dylan Araps
urlencode () {
    local LC_ALL=C
    for (( i = 0; i < ${#1}; i++ )); do
        : "${1:i:1}"
        case "$_" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$_"
            ;;

            *)
                printf '%%%02X' "'$_"
            ;;
        esac
    done
    printf '\n'
}

while [ "$1" ]; do
	case $1 in
		-s|--search)
			searchAnime "$2"
			;;
		-d|--debug)
			debug=:
			searchAnime "$2"
			;;
		-h|--help)
			usage; exit
			;;
		-v|--version)
			printf '%s\n' "$prog: $ver"; exit
			;;
		-*)
			err "Invalid option(s)." 2
			;;
		*)
			exit
			;;
	esac
done

