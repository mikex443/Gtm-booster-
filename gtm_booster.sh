#!/bin/bash

CONFIG_DIR="$HOME/.gtm_booster"
DNS_FILE="$CONFIG_DIR/dns_list.txt"
NS_FILE="$CONFIG_DIR/ns_list.txt"
COLOR_FILE="$CONFIG_DIR/ui_color.txt"
DELAY_FILE="$CONFIG_DIR/loop_delay.txt"
COLOR=$(cat "$COLOR_FILE" 2>/dev/null || echo "32")
DELAY=$(cat "$DELAY_FILE" 2>/dev/null || echo "0")

mkdir -p "$CONFIG_DIR"
touch "$DNS_FILE" "$NS_FILE"

# Default DNS and NS values
initialize_defaults() {
    if [ ! -s "$DNS_FILE" ]; then
        cat <<EOF > "$DNS_FILE"
124.6.181.31
124.6.181.26
124.6.181.171
124.6.181.25
124.6.181.27
EOF
    fi

    if [ ! -s "$NS_FILE" ]; then
        echo "vpn.kagerou.site" > "$NS_FILE"
    fi
}

change_color() {
    echo -e "\n\033[1mChoose UI Color:\033[0m"
    echo -e "1. Red\n2. Green\n3. Yellow\n4. Blue\n5. Magenta\n6. Cyan"
    read -p "Enter option (1-6): " opt
    case $opt in
        1) COLOR=31 ;;
        2) COLOR=32 ;;
        3) COLOR=33 ;;
        4) COLOR=34 ;;
        5) COLOR=35 ;;
        6) COLOR=36 ;;
        *) echo "Invalid option." && return ;;
    esac
    echo "$COLOR" > "$COLOR_FILE"
    echo -e "\033[${COLOR}mColor updated!\033[0m"
}

dns_management() {
    echo -e "\n\033[1mDNS List:\033[0m"
    nl -w2 -s'. ' "$DNS_FILE"
    echo -e "\n1. Add DNS\n2. Remove DNS\n3. Back"
    read -p "Option: " choice
    case $choice in
        1) read -p "Enter DNS to add: " dns && echo "$dns" >> "$DNS_FILE" ;;
        2) read -p "Enter line number to remove: " num && sed -i "${num}d" "$DNS_FILE" ;;
    esac
}

ns_management() {
    echo -e "\n\033[1mNS List:\033[0m"
    nl -w2 -s'. ' "$NS_FILE"
    echo -e "\n1. Add NS\n2. Remove NS\n3. Back"
    read -p "Option: " choice
    case $choice in
        1) read -p "Enter NS to add: " ns && echo "$ns" >> "$NS_FILE" ;;
        2) read -p "Enter line number to remove: " num && sed -i "${num}d" "$NS_FILE" ;;
    esac
}

set_loop_delay() {
    read -p "Enter delay in seconds: " delay
    echo "$delay" > "$DELAY_FILE"
    DELAY="$delay"
}

start_digging() {
    echo -e "\n\033[1;${COLOR}mStarting Ping Loop...\033[0m"
    for ns in $(cat "$NS_FILE"); do
        for dns in $(cat "$DNS_FILE"); do
            while true; do
                echo -e "\033[1;${COLOR}m[$(date +%T)] Pinging $dns ($ns)...\033[0m"
                ping -c 1 -W 1 "$dns"
                sleep "$DELAY"
            done
        done
    done
}

ip_scanner() {
    read -p "Enter IP range (e.g. 192.168.1): " base
    for i in {1..254}; do
        ping -c 1 -W 1 "$base.$i" > /dev/null && echo -e "\033[1;${COLOR}mActive: $base.$i\033[0m" &
    done
    wait
}

update_script() {
    echo -e "\033[1;33mUpdate not available yet.\033[0m"
}

main_menu() {
    while true; do
        clear
        echo -e "\033[1;${COLOR}m╔══════════════════════════════════╗"
        echo -e "║        GTM BOOSTER v1.0          ║"
        echo -e "╚══════════════════════════════════╝\033[0m"
        echo "DNS Count: $(wc -l < "$DNS_FILE")  NS Count: $(wc -l < "$NS_FILE")  Loop Delay: ${DELAY}s"
        echo -e "\n1. DNS Management"
        echo "2. NS Management"
        echo "3. Set Loop Delay"
        echo "4. Start Digging"
        echo "5. IP Scanner"
        echo "6. Update Script"
        echo "7. Change UI Color"
        echo "0. Exit"
        read -p "Option: " opt

        case $opt in
            1) dns_management ;;
            2) ns_management ;;
            3) set_loop_delay ;;
            4) start_digging ;;
            5) ip_scanner ;;
            6) update_script ;;
            7) change_color ;;
            0) echo "Exiting..." && break ;;
            *) echo "Invalid!" && sleep 1 ;;
        esac
    done
}

initialize_defaults
main_menu
