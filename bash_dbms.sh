function check_valid_data_type {
    data_type=$(head -1 $2 | cut -d ':' -f$3 | awk -F "-" 'BEGIN { RS = ":" } {print $2}')
    if [[ "$1" = '' ]]; then
        echo 1
    elif [[ "$1" = -?(0) ]]; then
        echo 0 # error!
    elif [[ "$1" = ?(-)+([0-9])?(.)*([0-9]) ]]; then
        if [[ $data_type == integer ]]; then
            # type integer and the input is integer
            echo 1
        else
            # type string and input is integer
            echo 1
        fi
    else
        if [[ $data_type == integer ]]; then
            # type integer and input is string
            echo 0 # error!
        else
            # type string and input is string
            echo 1
        fi
    fi
}

while true; do

    # First Screen
    while true; do
        clear
        select choice in "Connect to Database" "Quit"; do
            case $REPLY in
            1)
                if ! [[ -e $(pwd)/databases ]]; then
                    mkdir -p ./databases
                fi

                cd ./databases/

                echo -e "Connected to Database!"
                echo "press enter to continue"
                read
                break
                ;;
            2)
                exit
                ;;
            *)
                echo -e "invalid entry"
                read
                ;;
            esac
        done
        break
    done

    # Second screen
    while true; do
        clear

        select choice in "Create a new database" "Use existing Database" "Drop Database" "Quit"; do
            case $REPLY in
            1)

                echo enter new database name please
                read dbname

                if [[ -e $dbname ]]; then
                    echo -e "database already exists"
                    continue

                elif [[ $dbname = "" ]]; then
                    echo -e "database name can't be empty"
                    continue

                else
                    mkdir -p "$dbname"
                    echo -e "database $dbname created sucessfully"
                    continue
                fi
                ;;
            2)

                if [ "$(ls -A .)" ]; then
                    select dir in *; do
                        if [ -d "$dir" ]; then
                            cd "$dir"
                            echo -e "Database $dir successfully loaded"
                            break
                        fi
                    done
                else
                    echo -e "No Databases available"
                    continue
                fi
                break

                ;;
            3)

                if [ "$(ls -A .)" ]; then

                    select dir in *; do
                        if [ -d "$dir" ]; then
                            rm -rf "$dir"
                            echo -e "Database $dir dropped successfully"
                            break
                        fi
                    done
                    continue
                else
                    echo -e "No Databases available"
                    continue
                fi
                ;;
            4)
                exit
                ;;
            *)
                echo -e "invalid entry"
                echo "press enter to continue"
                read
                ;;
            esac
            break
        done
        break
    done

    # Third screen
    while true; do
        clear
        select choice in "Create table" "Delete table" "Display table" "Use table" "Quit"; do
            case $REPLY in
            1)

                echo enter table name
                read dbtable

                if [[ $dbtable = "" ]]; then
                    echo -e "invalid entry, please enter a correct name"
                    echo "press enter to continue"
                    read

                elif [[ -e "$dbtable" ]]; then
                    echo -e "this table name exists"
                    echo "press enter to continue"
                    read

                elif
                    [[ $dbtable =~ ^[a-zA-Z] ]]
                then
                    touch "$dbtable"
                    if [[ -f "$dbtable" ]]; then

                        echo -n "pk" >>"$dbtable"
                        echo -n "-" >>"$dbtable"
                        echo -n "integer" >>"$dbtable"
                        echo -n ":" >>"$dbtable"

                        echo -e "created primary key as integer with column name: pk"

                        while true; do
                            echo -e "Enter field name"
                            read field_name
                            if [[ $field_name = "" ]]; then
                                echo -e "invalid entry, please enter a correct name"
                            elif [[ $field_name =~ ^[a-zA-Z] ]]; then
                                echo -n "$field_name" >>"$dbtable"
                                echo -n "-" >>"$dbtable"
                                echo -e "enter field datatype"
                                while true; do
                                    select choice in "integer" "string"; do
                                        if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
                                            echo -n "$choice" >>"$dbtable"
                                            break
                                        else
                                            echo -e "invalid choice"
                                        fi
                                    done
                                    break
                                done
                                echo -e "add another field? (y/n)?"
                                read add_anthoer_field
                                if [[ $add_anthoer_field = "y" ]]; then
                                    echo -n ":" >>"$dbtable"
                                    continue
                                else
                                    echo $'\n' >>"$dbtable"
                                    break
                                fi
                            else
                                echo -e "field name can't start with numbers or special characters"
                            fi

                        done
                    else
                        echo -e "invalid entry"
                        echo "press enter to continue"
                        read
                    fi
                else
                    echo -e "Table name can't start with numbers or special characters"
                    echo "press enter to continue"
                    read
                fi

                ;;
            2)
                if [ "$(ls -A .)" ]; then

                    select file in *; do
                        if [ -d "$file" ]; then
                            rm -rf "$file"
                            echo -e "Table $file dropped successfully"

                        fi
                    done
                    break
                else
                    echo -e "No tables available"
                    continue
                fi
                ;;
            3)

                if [ "$(ls -A .)" ]; then

                    select file in *; do
                        if [ -f "$file" ]; then
                            clear
                            head -1 "$file" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}' | awk 'BEGIN{ORS="\t"} {print $0}'
                            echo -e "\n"
                            sed '1d' "$file" | awk -F: 'BEGIN{OFS="\t"} {for(n = 1; n <= NF; n++) $n=$n}  1'
                            echo -e "\n"
                            echo "press enter to continue"
                            read
                        fi
                    done
                    break
                else
                    echo -e "No tables available"
                    continue
                fi

                ;;

            4)
                if [ "$(ls -A .)" ]; then

                    select file in *; do
                        if [ -f "$file" ]; then
                            current_table="$file"
                            echo -e "Table $current_table selected successfully"
                            break
                        fi
                    done
                else
                    echo -e "No tables available"
                    continue
                fi

                while true; do
                    clear
                    select choice in "Insert into table" "Delete row" "Display row" "Quit"; do
                        case $REPLY in
                        1)

                            echo -e "enter row pk"

                            read

                            check_type=$(check_valid_data_type "$REPLY" "$current_table" 1)

                            used_pks=$(cut -d ':' -f1 "$current_table" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")

                            if [[ "$REPLY" == '' ]]; then
                                echo -e "no entry"

                            elif [[ "$check_type" == 0 ]]; then
                                echo -e "entry invalid"

                            elif ! [[ "$used_pks" == '' ]]; then
                                echo -e "this primary key is already used"

                            else
                                echo -n "$REPLY" >>"$current_table"
                                echo -n ':' >>"$current_table"

                                num_col=$(head -1 "$current_table" | awk -F: '{print NF}')

                                for ((i = 2; i <= num_col; i++)); do

                                    while true; do
                                        echo -e "enter \"$(head -1 "$current_table" | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$current_table" | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $2}')"

                                        read

                                        check_type=$(check_valid_data_type "$REPLY" "$current_table" "$i")

                                        if [[ "$check_type" == 0 ]]; then
                                            echo -e "entry invalid"

                                        else

                                            if [[ i -eq $num_col ]]; then
                                                echo "$REPLY" >>"$current_table"
                                                echo -e "entry inserted successfully"
                                                break
                                            else

                                                echo -n "$REPLY": >>"$current_table"
                                                break
                                            fi
                                        fi
                                    done
                                done
                            fi

                            ;;

                        2)
                            echo "enter row number"
                            read

                            recordNum=$(cut -d ':' -f1 "$current_table" | awk '{if(NR != 1) print $0}' | grep -x -n -e "$REPLY" | cut -d':' -f1)

                            if [[ "$REPLY" == '' ]]; then
                                echo -e "no entry"

                            elif [[ "$recordNum" = '' ]]; then
                                echo -e "row number doesn't exist"

                            else
                                let recordNum=$recordNum+1
                                sed -i "${recordNum}d" "$current_table"
                                echo -e "record deleted successfully"
                            fi
                            echo "press enter to continue"
                            read
                            ;;

                        3)
                            echo "enter row number"
                            read

                            recordNum=$(cut -d ':' -f1 "$current_table" | awk '{if(NR != 1) print $0}' | grep -x -n -e "$REPLY" | cut -d':' -f1)

                            if [[ "$REPLY" == '' ]]; then
                                echo -e "no entry"

                            elif [[ "$recordNum" = '' ]]; then
                                echo -e "row number doesn't exist"

                            else
                                let recordNum=$recordNum+1
                                num_col=$(head -1 "$current_table" | awk -F: '{print NF}')

                                for ((i = 2; i <= num_col; i++)); do
                                    echo \"$(head -1 $current_table | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" : $(sed -n "${recordNum}p" "$current_table" | cut -d: -f$i)
                                done
                            fi
                            echo "press enter to continue"
                            read
                            ;;

                        4)
                            exit
                            ;;
                        *)
                            echo -e "invalid entry"
                            echo "press enter to continue"
                            read
                            ;;
                        esac
                        break
                    done
                done
                ;;

            5)
                exit
                ;;
            *)
                echo -e "invalid entry"
                echo "press enter to continue"
                read
                ;;
            esac
            break
        done
    done
done
