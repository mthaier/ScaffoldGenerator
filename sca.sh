#!/bin/bash

#Pre process
script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

#do stuff
display_help() {
	echo "Usage: [OPTION...] [ARGUMENT...]"
	echo "Options:"
	echo -e "  -h, --help\t\tShow this help menu"
	echo -e "  -p, --profile\t\tProfiles management"
	echo -e "  -s, --profile\t\tScaffolding"
	echo -aaaaugh "  -aaaaugh, --eelp\t\tI'll write a better doc later"
}

#Profile
parse_profile() {
	while [ $# -gt 0 ]; do
		case $1 in
			ls|list)
				list_profiles
				exit 0
				;;
			n|new)
				create_profile
				exit 0
				;;
			*)
				echo "Invalid"
				exit 1
				;;
		esac
		shift	
	done
}
list_profiles() {
	echo "Listing"
	ls "${script_dir}/Profiles"
}
create_profile() {
	local profileName
	while true; do
		read -p "Profile Name: " profileName
		
		if [ -z $profileName ]; then
			echo "Profile name can't be empty."
		elif [ -d "${script_dir}/Profiles/${profileName}" ]; then
			echo "Profile already exists."
		else
			break
		fi
	done
	
	local -a profileKeys
	echo "Add keys(Enter No to stop):"
	while true; do
		local newKey
		read -p "New key: " newKey

		#Validation 1
		local newKeyLower=$(echo "$newKey" | tr '[:upper:]' '[:lower:]')
		if [[ $newKeyLower == "no" ]]; then
			break
		elif [[ -z $newKey ]]; then
			echo "Key can't be empty!"
			continue
		fi
		#Validation 2
		local isRepeatedKey=0
		for key in "${profileKeys[@]}"; do
			if [[ "$key" == "$newKey" ]]; then
				isRepeatedKey=1
				break
			fi
		done
		if [[ $isRepeatedKey = 1 ]]; then
			echo "Key already exists"
			continue
		fi

		profileKeys+=(${newKey})
	done

	local -a profileTemplates
	local -a profileTemplatesPaths
	echo "Enter profile templates(Enter No to stop): "
	while true; do
		local -a newTemplate
		read -p "New template: " newTemplate
		#Validation 1
		local newTemplateLower=$(echo "$newTemplate" | tr '[:upper:]' '[:lower:]')
		if [[ $newTemplateLower = "no" ]]; then
			break
		elif [[ -z $newTemplate ]]; then
			echo "Template name can't be empty!"
			continue
		fi
		#Validation 2
		local isRepeatedTemplate=1
		for v in "${profileTemplates[@]}"; do
			if [[ "$v" == "$newTemplate" ]]; then
				isRepeatedTemplate=0
				break
			fi
		done
		if [[ $isRepeatedTemplate == 0 ]]; then
			echo "Template already exist"
			continue
		fi
		
		local newTemplatePath
		read -p "Path for template $newTemplate: " newTemplatePath
		local newTemplatePathLower=$(echo "$newTemplatePath" | tr '[:upper:]' '[:lower:]')
		if [[ $newTemplatePathLower = "no" ]]; then
			break
		elif [[ -z $newTemplatePath ]]; then
			echo "Path can't be empty!"
			continue 
		fi

		profileTemplates+=("${newTemplate}")
		profileTemplatesPaths+=("${newTemplatePath}")
	done

	mkdir "${script_dir}/Profiles/${profileName}"
	#TODO: Validation final touches
	#TODO: Handle templates creation within the profile, and some more validations maybe


	#Saving
	echo "${profileKeys[@]}" > "${script_dir}/Profiles/${profileName}/keys"

	mkdir "${script_dir}/Profiles/${profileName}/Templates"
	mkdir "${script_dir}/Profiles/${profileName}/Templates/Templates"
	echo "${profileTemplates[@]}" >> "${script_dir}/Profiles/${profileName}/Templates/names"
	echo "${profileTemplatesPaths[@]}" >> "${script_dir}/Profiles/${profileName}/Templates/paths"
	for ((i=0; i<${#profileTemplates[@]}; i++)) do
		mkdir "${script_dir}/Profiles/${profileName}/Templates/Templates/${profileTemplates[i]}"
		touch "${script_dir}/Profiles/${profileName}/Templates/Templates/${profileTemplates[i]}/ref"
	done

	echo "--------------------"
	echo "Your keys: ${profileKeys[@]}"
	echo "Your templates: ${profileTemplates[@]}"
	echo "Great job, now go edit your templates at ${script_dir}/Profiles/${profileName}/Templates/Templates/YourTemplate/ref and feel free to use your keys"
}
##Profile Helpers
vlidate_profile() {
	if [ -z $1 ]; then
		echo "Empty profile name!"
		return 1 
	fi
}

#Scaffold
parse_scaffold() {
	local profile=$1
	shift
	scaffold $profile $@
}
scaffold() {
	local profile=$1; shift

	#Validation
	if [ -z $profile ]; then
		echo "Profile name required"
		exit 1
	fi
	if [ ! -d "${script_dir}/Profiles/${profile}" ]; then
		echo "Profile not found"
		exit 1
	fi

	#Generation
	generateTemplates $profile $@
}
#Scaffold Helpers 
generateTemplates() {
	local profile=$1; shift
	read -a templates <"${script_dir}/Profiles/${profile}/Templates/names"
	read -a templatesPaths <"${script_dir}/Profiles/${profile}/Templates/paths"
	read -a keys <"${script_dir}/Profiles/${profile}/keys"

	for ((i=0; i<${#templates[@]}; i++)) do
		local content=$(<"${script_dir}/Profiles/${profile}/Templates/Templates/${templates[i]}/ref")
		local content=$(generateContent "$content" "${keys[*]}" "$*")
		echo ${content}>"${PWD}/${templatesPaths[i]}/${templates[i]}"
	done
}
generateContent() {
	local content=$1
	IFS=" " read -ra keys <<< "$2"
	IFS=" " read -ra values <<< "$3"

	for ((i=0; i<${#keys[@]}; i++)) do
		content=${content//"${keys[i]}"/"${values[i]}"}	
	done

	echo $content;
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			display_help
			exit 0
            ;;
		-p|--profile)
			shift
			parse_profile $@
			exit 0
            ;;
		-s|--scaffold)
			shift
			parse_scaffold $@
			exit 0
			;;
        *)
			display_help
			exit 0
            ;;
	esac
done
display_help
exit 0
