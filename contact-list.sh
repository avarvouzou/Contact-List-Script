
intro() {
    read -p "1)Insert Contact 2)Delete Contact 3)Modify Contact 4)Search Contact 5)Sort Contacts by LastName 6)Sort Contacts by FirstName 7)Quit
What do you want to do? (insert the number) " option
    while !([[ "$option" =~ ^[1-7]$ ]]) 2> /dev/null
    do 
        printf "The option you choosed is incorrect. Please choose one of the following numbers:\n"
        read -p "1)Insert Contact 2)Delete Contact 3)Modify Contact 4)Search Contact 5)Sort Contacts by LastName 6)Sort Contacts by FirstName 7)Quit " option
    done
}

last_name_search() {
    find=$(grep -E ",$last_name" contacts.list)
    while [ -z "$find" ] 
    do
        read -p "There is no contact saved with this last name. Please type it again or type exit to return to menu options " last_name
        if [ "$last_name" == "exit" ]; then
            break 2
        fi
        find=$(grep -E ",$last_name" contacts.list)
    done
} 

answer_check() {
    until [ "$answer" == "y" ] || [ "$answer" == "n" ]
    do
        read -p "Incorrect option please input y or n " answer
    done
}

deletion() {
    echo "$find"
    read -p "Do you want to delete this contact? (y/n) " answer
    answer_check
    if [ "$answer" == "y" ]; then
        sed -i "/$find/d" contacts.list
    fi
}

search() {
    find=$(grep -E "$info" contacts.list)
    while [ -z "$find" ] 
    do
        read -p "There is no contact saved with this info. Please type it again or type exit to return to menu options " info
        if [ "$info" == "exit" ]; then
            return 0
        fi
        find=$(grep -E ",$last_name" contacts.list)
    done
    echo "$find"
}

insert_contact() {
    read -p "Please give contact information seperated with commas " contact
    echo "$contact" >> contacts.list
    read -p "Do you want to insert another contact? (y/n) " answer
    answer_check
    if [ "$answer" == "y" ]; then
        insert_contact
    fi
}

delete_contact() {
    read -p "Please write the last name of the contact " last_name
    last_name_search
    if [ "$last_name" == "exit" ];
    then
       return 0
    fi
    deletion
    read -p "Do you want to delete another contact? (y/n) " answer
    answer_check
    if [ "$answer" == "y"]; then
            delete_contact
    fi
}

search_contact() {
    read -p "Please write the info you have " info
    search
    if [ "$info" == "exit" ];
    then
       return 0
    fi
    read -p "Do you want to search for another contact? (y/n) " answer
    answer_check
    if [ "$answer" == "y" ]; then
        search_contact
    fi
}

modify_contact() {
    read -p "Give last name " last_name
    last_name_search
    echo "$last_name"
    echo "$find"
    read -p "Do you want to motify it? " answer
    answer_check
    if [ "$answer" == "y" ]; then
        read -p "Which info do you want to modify? Name, lastname or telephone " inf
        if [ "$inf" == "name" ]; then
            name=$(echo "$find" | cut -d "," -f 1 )
            read -p "Write the new name " new
            before=$(echo "$name,$last_name")
            after=$(echo "$new,$last_name")
            sed -i "s/$before/$after/g" contacts.list
            last_name_search
            echo "$find"
        elif [ "$inf" == "lastname" ]; then
            name=$(echo "$find" | cut -d "," -f 2 )
            read -p "Write the new lastname " new
            sed -i "s/$last_name/$new/g" contacts.list
            lastname=$new
            last_name_search
            echo "$find"
        fi
    fi

}

while true
do
    intro
    if [ "$option" == "1" ]
    then
        listFind=$(ls . | grep -E 'contacts.list')
        if [ -z $listFind ]; then
            touch contacts.list
            insert_contact    
        else
            insert_contact
        fi
    elif [[ "$option" =~ ^([2-6])$ ]]; then
        listFind=$(ls . | grep -E 'contacts.list')
        if [ -z $listFind ]; then
            echo "Contact list file with already saved contacts does not exist in this folder"
        else
            if [ "$option" == "2" ]; then
                delete_contact
            elif [ "$option" == "3" ]; then
                modify_contact
            elif [ "$option" == "4" ]; then
                search_contact
            elif [ "$option" == "5" ]; then
                sort -t',' -k2 contacts.list
            elif [ "$option" == "6" ]; then
                sort contacts.list
            fi
        fi
    elif [ "$option" == "7" ]; then
        echo "Exiting..."
        exit
    fi
done

