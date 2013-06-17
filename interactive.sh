#!/bin/bash
#OpenAM shell REST client
#Optional interactive front end for using the combined script list

#read version - currently the commit count on the github branch
VERSION=$(git rev-list --all | wc -l) #need to make this machine indepedent for those without git

#check that jq is installed
JQ_LOC=$(which jq)
if [ $JQ_LOC = "" ]; then
	
	echo "JQ not found!  Please download from http://stedolan.github.io/jq/"
	exit
fi

#main menu interface
function menu() { 
	
	clear
	echo "OpenAM Shell REST Client - interactive mode [ver:$VERSION]"
	echo "-----------------------------------------------------"
	echo ""
	echo "1: Authenticate Using Username & Password (token saved for future session use)"
	echo "2: Check current token is valid"
	echo "3: Create User"		
	echo "4: Delete User"
	echo "5: Update User"	
	echo "6: Create Realm"
	echo "7: Update Realm"
	echo "8: Delete Realm"
	echo "X: Exit"
	echo ""
	echo "-----------------------------------------------------"
	echo "Select an option:"
	read option

	case $option in

		1)
			auth_username_password
			;;	

		2)
			check_token
			;;

		3)
			create_user
			;;

		4)
			delete_user
			;;
	
		5)
			update_user
			;;

		6)
			create_realm
			;;

		7)
			#update_realm
			;;
	
		8)
			#delete_realmn
			;;
		
		
		[x] | [X])
				clear	
				echo "Byeeeeeeeeeeeeeeeeeee :)"
				echo ""			
				exit
				;;
		*)

			menu
			;;
	esac

}

#calls create_realm.sh
function create_realm() {

	clear
	echo "Enter path to JSON payload for realm creation: Eg myRealm.json"
	read realm_payload
	echo ""

	#check file exists
	if [ -e "$realm_payload" ]; then
		
		realm_payload="@$realm_payload"	
		./create_realm.sh $realm_payload
			
	else

		echo "Payload JSON file $realm_payload not found!"
	
	fi
	
	echo ""
	read -p "Press [Enter] to return to menu"
	menu


}

#calls update_user.sh
function update_user() {

	clear
	echo "Enter userid of user to update: Eg jdoe"
	read userid
	echo ""
	echo "Enter JSON payload file with values to update: Eg updates.json"
	read updates_payload
	echo ""
	echo "Enter optional realm that user belongs to: Eg myRealm"
	read realm

	#check that updates file exists
	if [ -e "$updates_payload" ]; then
	
		updates_payload="@$updates_payload"
		./update_user.sh $userid $updates_payload $realm
		
	else
		echo ""
		echo "Updates JSON file $updates_payload not found!"
		
	fi

	echo ""
	read -p "Press [Enter] to return to menu"
	menu

}

#calls delete_user.sh
function delete_user() {

	clear
	echo "Enter username of user to delete: Eg jdoe"
	read username
	echo ""
	echo "Enter optional realm. Eg myRealm"
	read realm
	./delete_user.sh $username $realm
	echo ""
	read -p "Press [Enter] to return to menu"
	menu

}

#calls ./valid_token?.sh
function check_token() {
	
	clear
	#check that token file exists
	if [ -e ".token" ]; then
	
		TOKEN=$(cat .token | cut -d "\"" -f 2) #remove start and end quotes
		VALID=$(./valid_token?.sh $TOKEN | jq '.boolean') #call shell client for validating token
		echo ""
		echo "Current token in .token file is valid?: $VALID"
		echo ""
		read -p "Press [Enter] to return to menu"
		menu

	else
		echo ".token file not found!"
		echo "Authenticate with username and password to create"
		echo ""
		read -p "Press [Enter] to return to menu"
		menu
	fi

}



#calls ./authenticate_username_password.sh
function auth_username_password() {

	clear
	echo "Enter OpenAM username:"
	read username
	echo ""
	echo "Enter Password:"
	read -s password
	echo ""
	./authenticate_username_password.sh $username $password
	echo ""
	read -p "Press [Enter] to return to menu"
	menu

}


#calls ./create_user.sh
function create_user() {

	clear
	echo "Enter path to JSON payload file for user creation: Eg. user.json"
	read create_user_payload
	
	echo ""
	echo "Enter optional realm to create user: Eg. myRealm"
	read realm

	#check that payload file actually exists
	if [ -e "$create_user_payload" ]; then

		create_user_payload="@$create_user_payload"
		./create_user.sh $create_user_payload $realm		

	else

		echo "File not found: $create_user_payload"

	fi

	echo ""
	read -p "Press [Enter] to return to menu"
	menu
	
}

#initiate menu
menu