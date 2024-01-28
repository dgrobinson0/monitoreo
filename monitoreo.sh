#!/bin/bash

# Autor: DGR - UCI - Fac2

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=noninteractive
trap ctrl_c INT

function ctrl_c(){
    	tput cnorm
    	echo -e "\n\n${redColour}[!] Saliendo...${endColour}"
	cd ..
	rm -r Monitoreo 2>/dev/null
    	exit 1
}

#inicio de funciones para tabla
function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}


function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}
#fin de las funciones tabla

function begin(){
	echo -e "${yellowColour}[*]${endColour}${grayColour} Lista de Opciones: ${endColour}\n"
	echo -e "\t${yellowColour}[1]${endColour}${grayColour} Analizar un binario .cap ${endColour}"
	echo -e "\t${yellowColour}[2]${endColour}${grayColour} Proceder a la captura y analisis de paquetes${endColour}\n"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Escoger una opcion [1 2]: ${endColour}\c"
	read option_begin
	echo -e "\n"
	for i in $(seq 1 100); do echo -ne "${blueColour}-"; done; echo -ne "${endCOlour}"
	echo -e "\n"
	case $option_begin in
		#1)
		2)options_list;; 
	esac
}

function dependencies(){
	tput civis
	dependencies=(tcpdump tshark xxd)

	echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Herramienta${endColour}${purpleColour} $program${endColour}${blueColour}...${endColour}"

		test -f /usr/bin/$program

		if [ "$(echo $?)" == "0" ]; then
			echo -e " ${greenColour}(V)${endColour}"
		else
			echo -e " ${redColour}(X)${endColour}\n"
			echo -e "Es necesario instalar la herramienta para continuar. Desea instalarla [${greenColour}y${endColour},${redColour}n${endColour}]: \c"
			read answer
			if [ $answer == "y" ]; then
				echo -e "\n${yellowColour}[*]${endColour}${grayColour} Instalando herramienta ${endColour}${blueColour}$program${endColour}${yellowColour}...${endColour}"
				apt-get install $program -y > /dev/null 2>&1
			else
				exit 1
			fi
		fi; sleep 1
	done
	echo -e "\n"
	for i in $(seq 1 100); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n"
	echo -e "\n"
}

function banner(){
	echo -e "${blueColour}

	%%%%           %%%%    %%%%%%%%%%%%%%   %%%%%
	%%%%           %%%%    %%%%%%%%%%%%%%   %%%%%   Creado por: Dariel G. Robinson
	%%%%           %%%%    %%%%             %%%%%   Universidad de las Ciencias Informaticas
	%%%%           %%%%    %%%%             %%%%%
	%%%%           %%%%    %%%%             %%%%%
	%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%   %%%%%
	%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%   %%%%%

        Ctrl + c para salir.
	${endColour}"

	for i in $(seq 1 100); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
	sleep 1
}

function capture() {
	echo -e "${yellowColour}[*] Capturando paquetes, genere trafico. Para cancelar pulse q${endColour}"
	mkdir Monitoreo; cd Monitoreo
	tcpdump -i wlan0 -w captura.cap 2>/dev/null &
	pid_tcpDump=$!

	while true; do
		read -rsn1 input
        	if [ $input = "q" ]; then
            		end_capture
        	fi
    	done
}

function end_capture(){
	kill $pid_tcpDump
	echo -e "${yellowColour}[*]${endColour}${grayColour} Captura de paquetes detenida.${endColour}\n\n"
	tshark -r captura.cap 2>/dev/null > captura.table
	options_list
}

function options_list(){
	clear;
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} Lista de opciones de analisis: ${endColour}\n"
        echo -e "\t${yellowColour}[1]${endColour}${grayColour} Ver archico de captura ${endColour}"
        echo -e "\t${yellowColour}[2]${endColour}${grayColour} Analizar paquetes ARP ${endColour}"
        echo -e "\t${yellowColour}[3]${endColour}${grayColour} Analizar paquetes ICMP ${endColour}"
        echo -e "\t${yellowColour}[4]${endColour}${grayColour} Analizar paquetes TCP ${endColour}"
        echo -e "\t${yellowColour}[5]${endColour}${grayColour} Analisis inverso de paquetes ${endColour}\n\n"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Escoger una opcion [1 2 3 4 5]: ${endColour}\c"
        read options
        case $options in
                1) see_cap;;
                2) Arp;;
                3) icmp;;
                4) tcp;;
		5) inverso;;
        esac

}

function see_cap(){
	echo -e "\n"
	cat captura.table
	for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
	read options
	if [ $options == "q" ]; then
		clear;options_list
	fi
}

function Arp(){
	clear;
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} ARP analisis${endColour}"
	echo -e "\n\t${yellowColour}[1]${endColour}${grayColour} Mostrar toda la captura${endColour}"
	echo -e "\t${yellowColour}[2]${endColour}${grayColour} Mostrar cache ARP${endColour}"
	echo -e "\t${yellowColour}[3]${endColour}${grayColour} Borrar cache ARP${endColour}"
	echo -e "\t${yellowColour}[4]${endColour}${grayColour} Regrear a la lista de opciones${endColour}\n"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Escoger una opcion [1 2 3 4]: ${endColour}\c"
	read options
	case $options in
		1)view_arp;;
		2)view_cache;;
		3)delete_cache;;
		4)options_list;;
	esac
}

function view_arp(){
	echo -e "\n"
        echo -e "${yellowColour}$(cat captura.table | grep "ARP")${endColour}"
	for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                Arp
        fi
}

function view_cache(){
	echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Cache ARP: ${endColour}\n"
	echo -e "${blueColour}$(arp -a)${endColour}\n"
	echo -e "${yellowColour}[*]${endColour} ${grayColour}Regresar a la lista de opciones de arp [y]: ${endColour}\c"
	read options
	if [ $options == "y" ]; then
		Arp
	fi
}

function delete_cache(){
	echo -e "${yellowColour}[*]${endColour} ${grayColour}Eliminando cache arp... ${endColour}"
	sleep 1.5
	ip neigh flush all 2>/dev/null
	echo -e "${yellowColour}[*]${endColour} ${grayColour}Borrado satisfactoriamente... ${endColour}"
	sleep 1
	Arp
}

function icmp(){
	echo -e "\n"
	echo -e "${yellowColour}$(cat captura.table | grep "ICMP")${endColour}"
        for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
        echo -e "${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                clear;options_list
        fi
}

function tcp(){
	clear;
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} TCP analisis${endColour}"
        echo -e "\n\t${yellowColour}[1]${endColour}${grayColour} Mostrar toda la captura${endColour}"
        echo -e "\t${yellowColour}[2]${endColour}${grayColour} Mostrar handshakes de conexion${endColour}"
        echo -e "\t${yellowColour}[3]${endColour}${grayColour} Mostrar handshakes de desconexion${endColour}"
        echo -e "\t${yellowColour}[4]${endColour}${grayColour} Regrear a la lista de opciones${endColour}\n"
        echo -e "${yellowColour}[*]${endColour}${grayColour} Escoger una opcion [1 2 3 4]: ${endColour}\c"
        read options
        case $options in
                1)view_tcp;;
                2)conection_tcp;;
                3)desconection_tcp;;
                4)options_list;;
        esac
}

function conection_tcp(){
	clear
	echo -e "\n"
	for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
	puert=$(cat captura.table | grep "TCP" | tr -d '[],' | awk '$11 == "SYN" && $12 == "ACK"' | awk '{print $10}' | sort -u)
	ips=$(cat captura.table | grep "TCP" | tr -d '[],' | awk '$11 == "SYN" && $12 == "ACK"' | awk '{print $3}' | sort -u)
	cont=1
	for p in $puert; do
		echo -e "$(cat captura.table | grep "$ips" | grep -E "SYN|ACK" | grep -vE "FIN|PSH|Retransmission|Dup|RST" | awk -v IP="$p" '$8 == IP || $10 == IP')" >> tcp_syn.table
		let cont=cont+1
	done
	echo -e "$(cat tcp_syn.table | head -n 3)"
	for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
	echo -e "${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                clear;tcp
        fi
}

function desconection_tcp(){
	clear
        echo -e "\n"
        for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
        ips=$(cat captura.table | grep "FIN, ACK" | awk '{print $3}')
        contador=1
        for i in $ips; do
                echo -e "$(cat captura.table | grep -E "FIN|ACK" | grep -vE "SYN|PSH|Retransmission|Dup|RST" | grep "$i")" >> tcp_fin.table
                let contador=contador+1
        done
        echo -e "$(cat tcp_fin.table | grep "FIN, ACK" -C 3)"
        for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
        echo -e "${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                clear;tcp
        fi

}

function view_tcp(){
	echo -e "\n"
        cat captura.table | grep "TCP"
	for i in $(seq 1 150); do echo -ne "${blueColour}-"; done; echo -ne "${endColour}\n\n"
        echo -e "${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                clear;tcp
        fi
}

function inverso(){
	clear;
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} Analisis inverso de paquetes:${endColour}"
        echo -e "\n\t${yellowColour}[1]${endColour}${grayColour} ARP${endColour}"
        echo -e "\t${yellowColour}[2]${endColour}${grayColour} ICMP${endColour}"
        echo -e "\t${yellowColour}[3]${endColour}${grayColour} TCP${endColour}"
        echo -e "\t${yellowColour}[4]${endColour}${grayColour} Regrear a la lista de opciones${endColour}\n"
        echo -e "${yellowColour}[*]${endColour}${grayColour} Escoger una opcion [1 2 3 4]: ${endColour}\c"
        read options
        case $options in
                1)inverso_arp;;
                2)inverso_icmp;;
                3)inverso_tcp;;
                4)options_list;;
        esac
}

function inverso_arp(){
	echo -e "\n"
	echo -e "${yellowColour}[*]Buscando un paquete ARP...${endColour}"
	sleep 1
	xxd captura.cap > captura_hex.txt
	cont=0
	cat captura_hex.txt | grep "0806 0001" -C 2 | awk '{print $2, $3, $4, $5, $6, $7, $8 , $9}' | xargs > captura_hex_arp.txt
	echo -e "${yellowColour}[*]Paquete encontrado: ${endColour}\n"
	for i in $(cat captura_hex_arp.txt); do
		if [ $i == "0806" ]; then
			cat captura_hex_arp.txt | awk -v conta=$cont '{print $(conta-5), $(conta-4), $(conta-3), $(conta-2), $(conta-1), $(conta), $(conta+1), $(conta+2),$(conta+3), $(conta+4), $(conta+5), $(conta+6), $(conta+7), $(conta+8), $(conta+9), $(conta+10), $(conta+11), $(conta+12), $(conta+13), $(conta+14), $(conta+15)}' > p_arp.txt
			break
		fi
		let cont=cont+1
	done
	t_hadware=$(cat p_arp.txt | awk '{print $8}')
	case $t_hadware in
		0001)t_hadware="Ethernet";;
	esac
	opcode=$(cat p_arp.txt | awk '{print $11}')
	case $opcode in
		0001)opcode="solicitud";;
		0002)opcode="respuesta";;
	esac
	t_protocolo=$(cat p_arp.txt | awk '{print $9}')
	case $t_protocolo in
		0800)t_protocolo="IPv4";;
		1600)t_protocolo="IPv6";;
	esac
	ip_d=$(cat p_arp.txt | awk '{print $20, $21}')
	ip_o=$(cat p_arp.txt | awk '{print $15, $16}')
	echo -e "${yellowColour}Paquete Capturado${endColour}" > p1_arp.txt
	cat p_arp.txt >> p1_arp.txt
	echo -e "${yellowColour}Tipo de Hadware/Tipo de Protocolo/Opcode/MAC Destino/IP Destino/MAC Remitente/IP Remitente${endColour}" >> p2_arp.txt
	echo -e "${blueColour}$t_hadware/$t_protocolo/$opcode/$(cat p_arp.txt | awk '{print $1, $2, $3}')/$ip_d/$(cat p_arp.txt | awk '{print $4, $5, $6}')/$ip_o${endColour}" >> p2_arp.txt
	printTable "/" "$(cat p1_arp.txt)"
	printTable "/" "$(cat p2_arp.txt)"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
		rm p1_arp.txt p2_arp.txt
                inverso
        fi
}

function inverso_icmp(){
	echo -e "\n"
        echo -e "${yellowColour}[*]Buscando un paquete ICMP...${endColour}"
        sleep 1
        xxd captura.cap > captura_hex.txt
        cont=0
	c=2
        cat captura_hex.txt | grep "0800 4500 0054" -A 1 -B 6 | awk '{print $2, $3, $4, $5, $6, $7, $8 , $9}' | xargs > captura_hex_icmp.txt
        echo -e "${yellowColour}[*]Paquete encontrado: ${endColour}\n"
        for i in $(cat captura_hex_icmp.txt); do
                if [ $i == "4500" ]; then
                        cat captura_hex_icmp.txt | awk -v conta=$cont '{print $(conta-6), $(conta-5), $(conta-4), $(conta-3), $(conta-2), $(conta-1), $(conta), $(conta+1), $(conta+2),$(conta+3), $(conta+4), $(conta+5), $(conta+6), $(conta+7), $(conta+8), $(conta+9), $(conta+10), $(conta+11), $(conta+12), $(conta+13), $(conta+14), $(conta+15), $(conta+16), $(conta+17), $(conta+18), $(conta+19), $(conta+20), $(conta+21), $(conta+22), $(conta+23), $(conta+24), $(conta+25), $(conta+26), $(conta+27), $(cont+28), $(conta+29), $(conta+30), $(conta+31), $(conta+32), $(conta+33), $(conta+34), $(conta+35), $(conta+36), $(conta+37), $(conta+38), $(conta+39), $(conta+40), $(conta+41), $(conta+42)}' > p_icmp.txt
			break
                fi
                let cont=cont+1
        done
        Type=$(cat p_icmp.txt | awk '{print $18}')
        case $Type in
                0800)Type="Echo (ping) request";;
		0000)Type="Echo (ping) reply";;
        esac
        ip_d=$(cat p_icmp.txt | awk '{print $16, $17}')
        ip_o=$(cat p_icmp.txt | awk '{print $14, $15}')
        echo -e "${yellowColour}Paquete Capturado${endColour}" > p1_icmp.txt
        cat p_icmp.txt >> p1_icmp.txt
        echo -e "${yellowColour}Tipo/MAC Destino/IP Destino/MAC Remitente/IP Remitente${endColour}" >> p2_icmp.txt
        echo -e "${blueColour}$Type/$(cat p_icmp.txt | awk '{print $1, $2, $3}')/$ip_d/$(cat p_icmp.txt | awk '{print $4, $5, $6}')/$ip_o${endColour}" >> p2_icmp.txt
        printTable "/" "$(cat p1_icmp.txt)"
        printTable "/" "$(cat p2_icmp.txt)"
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
                rm p1_icmp.txt p2_icmp.txt
		inverso
        fi
}

function inverso_tcp(){
	echo -e "\n"
        echo -e "${yellowColour}[*]Buscando un paquete TCP...${endColour}"
        sleep 1
        xxd captura.cap > captura_hex.txt
        cont=0
        cat captura_hex.txt | grep "0800 4500 003c" -A 1 -B 6 | awk '{print $2, $3, $4, $5, $6, $7, $8 , $9}' | xargs > captura_hex_tcp.txt
        echo -e "${yellowColour}[*]Paquete encontrado: ${endColour}\n"
        for i in $(cat captura_hex_tcp.txt); do
                if [ $i == "4500" ]; then
                        puntero=$(cat captura_hex_tcp.txt | awk -v conta=$cont '{print $(conta+17)}')
			case $puntero in
				a002) cat captura_hex_tcp.txt | awk -v conta=$cont '{print $(conta-6), $(conta-5), $(conta-4), $(conta-3), $(conta-2), $(conta-1), $(conta), $(conta+1), $(conta+2),$(conta+3), $(conta+4), $(conta+5), $(conta+6), $(conta+7), $(conta+8), $(conta+9), $(conta+10), $(conta+11), $(conta+12), $(conta+13), $(conta+14), $(conta+15), $(conta+16), $(conta+17), $(conta+18), $(conta+19), $(conta+20), $(conta+21), $(conta+22), $(conta+23), $(conta+24), $(conta+25), $(conta+26), $(conta+27), $(cont+28), $(conta+29), $(conta+30)}' > p_tcp.txt; flag="SYN"; longitud=74; break;;
				#a012) cat captura_hex_tcp.txt | awk -v conta=$cont '{print $(conta-6), $(conta-5), $(conta-4), $(conta-3), $(conta-2), $(conta-1), $(conta), $(conta+1), $(conta+2),$(conta+3), $(conta+4), $(conta+5), $(conta+6), $(conta+7), $(conta+8), $(conta+9), $(conta+10), $(conta+11), $(conta+12), $(conta+13), $(conta+14), $(conta+15), $(conta+16), $(conta+17), $(conta+18), $(conta+19), $(conta+20), $(conta+21), $(conta+22), $(conta+23), $(conta+24), $(conta+25), $(conta+26), $(cont+27), $(cont+28), $(conta+29), $(conta+30)}' > p_tcp.txt; flag="SYN-ACK"; longitud=74; break;;
				#7012) flag="SYN-ACK"; longitud=62; break;;
				#8010) flag="ACK"; longitud=66; break;;
				#5010) flag="ACK"; longitud=54; break;;
                        esac
                fi
                let cont=cont+1
        done
        ip_d=$(cat p_tcp.txt | awk '{print $16, $17}')
        ip_o=$(cat p_tcp.txt | awk '{print $14, $15}')
	puerto_o=$(cat p_tcp.txt | awk '{print $18}')
	puerto_d=$(cat p_tcp.txt | awk '{print $19}')
        echo -e "${yellowColour}Paquete Capturado${endColour}" > p1_tcp.txt
        cat p_tcp.txt >> p1_tcp.txt
        echo -e "${yellowColour}Bandeera/Longitud/MAC Destino/IP Destino/MAC Remitente/IP Remitente/Puerto Remitente/Puerto Destino${endColour}" >> p2_tcp.txt
        echo -e "${blueColour}$flag/$longitud/$(cat p_tcp.txt | awk '{print $1, $2, $3}')/$ip_d/$(cat p_tcp.txt | awk '{print $4, $5, $6}')/$ip_o/$puerto_o/$puerto_d${endColour}" >> p2_tcp.txt
        printTable "/" "$(cat p1_tcp.txt)"
        printTable "/" "$(cat p2_tcp.txt)"
        echo -e "\n${yellowColour}[*]${endColour}${grayColour} Terminar visualizacion [q]:${endColour} \c"
        read options
        if [ $options == "q" ]; then
		rm p1_tcp.txt p2_tcp.txt
		inverso
        fi
}

banner
dependencies
capture
#begin

