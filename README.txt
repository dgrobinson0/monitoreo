Herramienta para dar solucion a las practicas
----------------------------------------------

Funciones:
	1) ctrl_c--------------- sale de la ejecucion de la herramienta y borra el directorio q se crea para trabajar
	2) printTable, removeEmptyLines, repeatString, isEmptyString, trimString ---------------- imprimir tablas a partir de un delimitador y un output dado
	3) begin ---------------- (No esta implementada completamente todavia) se utiliza para guiar: si x captura de paquetes o analisis de paquete ya capturado
	4) dependencies --------- verifica paquetes necesarios para la ejecucion de la herramienta y los instala
	5) banner --------------- imprimir logo (inicio de la herramienta) 
	6) capture -------------- capturar paquetes de la red con la herramienta tcpdump
	7) endCapture ----------- termina la captura y con tshark escribe la captura en un archivo 
	8) optionslist ---------- menu
	9) seeCap --------------- muestra la captura completa 
	10) arp ----------------- menu para funciones arp
	11) view_arp ------------ mostrar toda la captura de paquetes arp
	12) view_cache ---------- mostrar la cache arp
	13) delete_cache -------- eliminar la cache arp
	14) icmp ---------------- ver captura de paquetes icmp (No incluido ICMPv6)
	15) tcp ----------------- menu para funciones tcp
	16) conection_tcp ------- ver los handshake
	17) desconection -------- (Faltan algunos ajustes en el filtrado) ver paquetes de desconexion
	18) view_tcp ------------ ver captura tcp
	19) inverso ------------- menu para la busqueda de paquetes inverso
	20) inverso_arp --------- busqueda inversa de un paquete arp (falta llevar las ip de hexadecimal a decimal)
	21) inverso_icmp -------- busqueda inversa de un paquete icmp (implementado solo para paquetes icmp tipo ping con longitud de 98)
	22) inverso_tcp --------- busqueda inversa de un paquete tcp (implementado solo para paquetes tcp de tipo SYN)

--Ejecutar como superusuario.
--La herramienta esta hecha en KaliLinux, si presenta problemas al ejecutarla podria ser x falta de paquetes q se utilizan. Las explresiones regulares son escenciales en esta herramienta.

--El teclado de la laptop esta en ingles x lo q si algo lleva tilde pues no la tiene aqui
