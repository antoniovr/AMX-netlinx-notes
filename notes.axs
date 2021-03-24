PROGRAM_NAME='notes'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/24/2021  AT: 10:49:07        *)
(***********************************************************)

// Comentario de una l�nea

(* Comentario de 
varias l�neas con par�ntesis *)

/* Tambi�n se puede usar
la barra para los comentarios multil�nea */

/* Extensiones de archivo:
 .axs (c�digo fuente)
 .axi (c�digo fuente de librer�as)
 .tkn (archivo ya compilado, listo para enviar a la master, no se puede abrir para ver el contenido)
 .tko (driver compilado, no se puede abrir para ver el contenido)

*/

/* DEFINE_DEVICE
Secci�n donde se definen los dispositivos, tanto reales como virtuales, 
que vamos a usar en la programaci�n.
*/

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0


    /* D:P:S (Dispositivo, puerto, sistema)
    Valor a definir del dispositivo, depende del tipo de dispositivo el primer y segundo valor
    tienen significados diferentes:
    
    Equipos reales:
    D: 5001 es el i1dentificador de la tarjeta que contiene los puertos serie, IR, rel�, etc.
    P: 1 es el n�mero de puerto, en �ste caso el primer puerto serie
    S: 0 es el sistema actual
    */
    dvSerial = 5001:1:0
    
    /* Equipos IP:
    D: 0
    P: a partir del 4
    S: 0 indica el sistema actual 
    */
    dvSocket = 0:4:0
    
    /* Dispositivos virtuales:
    D: a partir del 33001
    P: se suele usar s�lo el 1
    S: 0 indica el sistema actual
    
    Se usa para diferentes prop�sitos, sobre todo comunicaci�n interna de la programaci�n
    */
    vdvDispVirtual = 33001:1:0

/* A continuaci�n del define device, solemos poner las llamadas a librer�as,
archivos que contienen c�digo y que se separan s�lo por temas de orden. 
Toda pieza de c�digo despu�s de la sentencia #include, tendr� visibilidad de lo que
est� contenido dentro del archivo que inclu�mos */

#include 'CUSTOMAPI'
#include 'waits'


/* DEFINE_CONSTANT
Secci�n donde definimos las variables cuyo valor no van a cambiar durante la
ejecuci�n del programa. 

tipos de variables m�s usados:
- Integer - n�meros enteros del 0 al 65535
- SInteger - N�meros enteros con signo, desde el -32000 al 32000
- Float - N�meros con decimales Ex: 23.4
- Char - un car�cter

Arrays de los anteriores tipos:
- integer anNumeros[4] = {1,2,3,4} // Podemos obviar el tama�o (n�mero entre corchetes), si luego listamos entre llaves los n�meros que contiene 
- char sCadena[] = 'Esto es una cadena'
- char asNombres[][32] = {'Array', / 1
			  'de', // 2
			  'varias cadenas'} // 3
*/
DEFINE_CONSTANT

    // Id del timeline, �nica por cada bloque de c�digo cerrado
    volatile long _TLID = 1


/* DEFINE_VARIABLE
Secci�n donde definimos variables, cuyo valor puede cambiar durante la ejecuci�n.

Antes del tipo de variable podemos encontrar otra palabra reservada que hace referencia
al tipo de memoria donde se guarda la variable:

- Volatile: la variable se guardar� en la memoria vol�til; cuando la master reinicie, la 
variable volver� al valor por defecto
- Non-volatile (o en su defecto no poner nada): La variable se guarda en la memoria 
NO vol�til, de forma que cuando se reinicie mantendr� el valor que tuviera
- Persistent: la variable se guarda en la memoria persistente, el valor no cambiar� ni a�n
volcando una nueva versi�n de la programaci�n. La �nica forma de eliminar una variable
persistente es enviando al controlador una programaci�n donde ese nombre no exista.

*/
DEFINE_VARIABLE

    // Definimos los tiempos de los que est� compuesto nuestro timeline
    volatile long lTimes[] = {30000} // Actualiza el feedback cada 30 segundos

    /* Los c�digos de canal (de los botones), que tienen relaci�n entre s� (por ejemplo, un men� de selecci�n)
    , los canales de rel�s, etc. los agrupamos en un mismo array de enteros para capturarlos en un �nico evento de bot�n */
    volatile integer anBtnMenu[] = {11,12,13,14,15}
    volatile integer anCanales[] = {1,2,3,4,5}

    volatile integer nBtnEstructurasControl = 100

(* DEFINE_START
Secci�n que se ejecuta s�lo la primera vez que inicia el controlador. 
Se usa para definir condiciones iniciales (valores por defecto de variables, iniciar TIMELINES, etc.)

Al final de �sta secci�n, tambi�n se definen las funciones y procedimientos
*)

DEFINE_START

    /*
	Argumentos
	1 - ID del timeline, debe ser un long
	2 - Tiempos de los que est� compuesto el timeline
	3 - Elegir entre:
	    * timeline_relative: cada tiempo definido es a partir del tiempo anterior
	    * timeline_absolute: cada tiempo definido es a partir del inicio del timeline
	4 - Elegir entre:
	    * timeline_once: el TL se ejecuta una �nica vez
	    * timeline_repeat: el timeline 
    */
    timeline_create(_TLID,lTimes,1,timeline_relative,timeline_repeat)
    
    // Establecemos el nivel de LOG que recoger� de forma autom�tica la master
    set_log_level(3)


    define_function integer fnMiFuncion(integer nArgNumero,char sArgCadena[])
    {
	/* STACK_VAR, LOCAL_VAR
	Palabras reservadas que se usan para definir variables locales
	- stack_var: la variable s�lo es visible en el bloque de c�digo donde est�, 
	y cuando termine el bloque, su valor se destruir�
	- local_var: s�lo visible desde �ste bloque, pero el valor reside en memoria,
	al terminar la ejecuci�n del bloque
	*/
	stack_var integer nResultado
	/* �sto es una funci�n que devuelve un entero y que recibe dos argumentos:
	- nArgNumero: argumento de tipo entero
	- sArgCadena: argumento de tipo cadena (da igual la lontigud) */
	
	
	/*
	    Una cadena puede estar compuesta de palabras o frases literales, contenidas en comillas simples '',
	    pero tambi�n se pueden enlazar con otros valores (n�meros enteros, c�digos hexadecimales, conversiones
	    de n�meros enteros a cadena, etc.). 
	    Cuando hay combinaci�n de tipos, todo se define dentro de comillas dobles "", y para unir los elementos 
	    entre s�, se usa la coma (,)
	*/
	send_string 0,"'�sta es mi funci�n, y el resultado es: ',itoa(nResultado)"
	
	send_string 0,"'esta cadena contiene literales ',$0a,'hexadecimales',20,'y n�meros'"
	
	/* Sentencia para devolver el resultado de la funci�n;
	�sta sentencia s�lo es obligatoria si arriba se define el tipo a devolver*/
	return nResultado
    }

/* DEFINE_EVENT
Secci�n donde recogemos los diferentes tipos de eventos que se pueden producir. Los m�s comunes son:
- Button event: pulsaci�n del usuario sobre la pantalla
- Channel event: un canal cambia de estado (detecci�n de un rel�, cambio de estado de un canal
en la l�gica de la programaci�n, etc.
- Data event: recibimos una cadena o comando desde un dispositivo (real o virtual), un dispositivo 
hace online, offline o recibe un error.
- Level event: detectamos un cambio en un nivel
*/
DEFINE_EVENT

    /* BUTTON_EVENT
    Tipo de evento que se produce cuando el usuario pulsa un bot�n. En la cabecera del evento se 
    define sobre qu� dispositivo y qu� canales en concreto vamos a estar a la escucha.
    */
    
    /* Entrar� en �sta secci�n, cuando se pulse cualquiera de los botones en el panel dvTp con 
    Channel Codes definidos en el array anBtnMenu (11,12,13,14,15) */
    button_event[dvTp,anBtnMenu]
    {
	// Evento cuando se pulsa (es la �nica secci�n obligatoria)
	push:
	{
	    /* Usamos sentencias send_string 0,'cadena', (que luego aparecer�n en la ventana de Diagnostics),
	    para comprobar que la ejecuci�n pasa por las partes del c�digo que nos interesan */
	    send_string 0,'�El usuario ha pulsado uno de los botones!'
	    
	    
	    // dentro de �ste bloque, la referencia button.input.channel contendr� el c�digo de canal que se ha pulsado
	    send_string 0,"'el usuario ha pulsado el canal: ',button.input.channel"
	}
	// Evento cuando se mantiene pulsado el bot�n
	// Entre corchetes el tiempo que debe transcurrir (en d�cimas) para que entre
	hold[50]:
	{
	
	}
	// Evento cuando se suelta el bot�n
	release:
	{
	
	}
    }

    channel_event[vdvSystem,anCanales]
    {
	on:
	{
	    stack_var integer nCanalActivado
	    nCanalActivado = get_last(anCanales)
	    switch(nCanalActivado)
	    {
		case 1: 
		{
		    fnInfo("'hello there!'")
		}
		case 2:
		{
		    send_string 0,'how is it going?'
		}
		case 3:
		{
		
		}
		case 4:
		{
		
		}
		case 5:
		{
		
		}
		case 6:
		{
		
		}
	    }
	}
    }
    
    /* DATA_EVENT
    Secci�n para recoger eventos relacionados con dispositivos (tanto reales como virtuales)
    Dependiendo del tipo de dispositivo, algunas secciones tendr�n m�s sentido o no. 
    Para el ejemplo usar� el tipo socket (conexi�n TCP/IP o UDP), que es el que m�s secciones usa.
    */
    
    data_event[dvSocket]
    {
	online:
	{
	    // Entrar� por aqu� cuando el dispositivo se conecte
	}
	offline:
	{
	    // Entrar� por aqu� cuando el dispositivo se desconecte
	}
	onerror:
	{
	    // ENtrar� por aqu� cuando se produzca alg�n error, en el caso de los sockets, cada 
	    // N�mero de error est� definido en la ayuda
	}
	string:
	{
	    // Entrar� por aqu� cuando recibamos una cadena que nos env�e el equipo al que 
	    // Nos hemos conectado
	    
	    // la palabra reservada data.text contiene la cadena que hemos recibido
	    send_string 0,"'recibimos la cadena: ',data.text"
	}
	command:
	{
	    // �sta secci�n no aplica en los sockets, s�lo tiene sentido en dispositivos virtuales
	}
    }
    
    button_event[dvTp,nBtnEstructurasControl]
    {
	push:
	{
	    stack_var integer x
	    stack_var integer y
	    stack_var integer i
	    stack_var char sCadena[32]
	    stack_var char sRespuesta[32]
	    sCadena = 'Esto es una cadena'
	    sRespuesta = "'PWR_ON',$0D"
	    x = 10
	    y = 15
	    
	    // IF-ELSE
	    if(x > y)
	    {
		send_string 0,'X es mayor que Y'
	    }
	    else if(x == y)
	    {
		send_string 0,'X es igual que Y'
	    }
	    else
	    {
		send_string 0,'X es menor que Y'
	    }
	    
	    // SWICH
	    switch(x) // Evaluamos el valor contenido en X
	    {
		case 10:
		{
		    // Entra aqu� si X de vale 10
		}
		case 20:
		{
		    // Entra aqu� si X de vale 20
		}
		case 30:
		{
		    // Entra aqu� si X de vale 30
		}
		default:
		{
		    // Entra aqu� si ninguna de las condiciones anteriores se cumple
		}
	    }
	    
	    // For
	    for(i=1;i<10;i++)
	    {
		send_string 0,"'i vale: ',itoa(i)"
		/*
		i vale: 1
		i vale: 2
		[..]
		i vale: 10
		*/
	    }
	    
	    /* SELECT
	    Evaluamos diferentes condiciones; sustituto natural del IF-ELSE si son varias condiciones a enlazar
	    */
	    select
	    {
		active(sCadena == 'Antonio'):
		{
		    // Entra aqu� si la cadena vale Antonio
		}
		active(sCadena == 'Juan'):
		{
		    // Entra aqu� si la cadena vale Juan
		}
		active(find_string(sRespuesta,'ON',1)):
		{
		    // Entrar� si dentro de sRespuesta encuentra a partir de la posici�n 1 la trama 'ON' 
		    /*
		    FUNCIONES DE TRATAMIENTO DE CADENAS:
		    
		    Algunas de las m�s usadas:
		    
		    find_string(dondeBuscar,queBuscar,aPartirDeQuePosicion) // Devolver� en formato n�mero la posici�n donde ha encontrado la trama
		    
		    remove_string(dondeBorrar,queBorrar,aPartirDeQuePosicionBuscoLaCadenaABorrar) // Devolver� en formato cadena la secuencia que ha borrado
		    
		    get_buffer_string(dondeBorrar,cuantosCaracteresBorrar) // Devolver� en formato cadena los caracteres extra�dos
		    */
		}
		active(1):
		{
		    // Entra aqu� si ninguna de las condiciones anteriores se cumple
		}
	    }
	}
    }
    
    timeline_event[_TLID]
    {
	// Entrar� aqu� cada 30 segundos
	send_string 0,"'I�m alive'"
    }    

(**********************************************************)
(*		        END OF PROGRAM 			  *)
(**********************************************************) 