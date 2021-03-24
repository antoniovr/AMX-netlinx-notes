PROGRAM_NAME='notes'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/24/2021  AT: 10:49:07        *)
(***********************************************************)

// Comentario de una línea

(* Comentario de 
varias líneas con paréntesis *)

/* También se puede usar
la barra para los comentarios multilínea */

/* Extensiones de archivo:
 .axs (código fuente)
 .axi (código fuente de librerías)
 .tkn (archivo ya compilado, listo para enviar a la master, no se puede abrir para ver el contenido)
 .tko (driver compilado, no se puede abrir para ver el contenido)

*/

/* DEFINE_DEVICE
Sección donde se definen los dispositivos, tanto reales como virtuales, 
que vamos a usar en la programación.
*/

DEFINE_DEVICE 

    dvTp = 10001:1:0
    vdvSystem = 33000:1:0


    /* D:P:S (Dispositivo, puerto, sistema)
    Valor a definir del dispositivo, depende del tipo de dispositivo el primer y segundo valor
    tienen significados diferentes:
    
    Equipos reales:
    D: 5001 es el i1dentificador de la tarjeta que contiene los puertos serie, IR, relé, etc.
    P: 1 es el número de puerto, en éste caso el primer puerto serie
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
    P: se suele usar sólo el 1
    S: 0 indica el sistema actual
    
    Se usa para diferentes propósitos, sobre todo comunicación interna de la programación
    */
    vdvDispVirtual = 33001:1:0

/* A continuación del define device, solemos poner las llamadas a librerías,
archivos que contienen código y que se separan sólo por temas de orden. 
Toda pieza de código después de la sentencia #include, tendrá visibilidad de lo que
esté contenido dentro del archivo que incluímos */

#include 'CUSTOMAPI'
#include 'waits'


/* DEFINE_CONSTANT
Sección donde definimos las variables cuyo valor no van a cambiar durante la
ejecución del programa. 

tipos de variables más usados:
- Integer - números enteros del 0 al 65535
- SInteger - Números enteros con signo, desde el -32000 al 32000
- Float - Números con decimales Ex: 23.4
- Char - un carácter

Arrays de los anteriores tipos:
- integer anNumeros[4] = {1,2,3,4} // Podemos obviar el tamaño (número entre corchetes), si luego listamos entre llaves los números que contiene 
- char sCadena[] = 'Esto es una cadena'
- char asNombres[][32] = {'Array', / 1
			  'de', // 2
			  'varias cadenas'} // 3
*/
DEFINE_CONSTANT

    // Id del timeline, única por cada bloque de código cerrado
    volatile long _TLID = 1


/* DEFINE_VARIABLE
Sección donde definimos variables, cuyo valor puede cambiar durante la ejecución.

Antes del tipo de variable podemos encontrar otra palabra reservada que hace referencia
al tipo de memoria donde se guarda la variable:

- Volatile: la variable se guardará en la memoria volátil; cuando la master reinicie, la 
variable volverá al valor por defecto
- Non-volatile (o en su defecto no poner nada): La variable se guarda en la memoria 
NO volátil, de forma que cuando se reinicie mantendrá el valor que tuviera
- Persistent: la variable se guarda en la memoria persistente, el valor no cambiará ni aún
volcando una nueva versión de la programación. La única forma de eliminar una variable
persistente es enviando al controlador una programación donde ese nombre no exista.

*/
DEFINE_VARIABLE

    // Definimos los tiempos de los que está compuesto nuestro timeline
    volatile long lTimes[] = {30000} // Actualiza el feedback cada 30 segundos

    /* Los códigos de canal (de los botones), que tienen relación entre sí (por ejemplo, un menú de selección)
    , los canales de relés, etc. los agrupamos en un mismo array de enteros para capturarlos en un único evento de botón */
    volatile integer anBtnMenu[] = {11,12,13,14,15}
    volatile integer anCanales[] = {1,2,3,4,5}

    volatile integer nBtnEstructurasControl = 100

(* DEFINE_START
Sección que se ejecuta sólo la primera vez que inicia el controlador. 
Se usa para definir condiciones iniciales (valores por defecto de variables, iniciar TIMELINES, etc.)

Al final de ésta sección, también se definen las funciones y procedimientos
*)

DEFINE_START

    /*
	Argumentos
	1 - ID del timeline, debe ser un long
	2 - Tiempos de los que está compuesto el timeline
	3 - Elegir entre:
	    * timeline_relative: cada tiempo definido es a partir del tiempo anterior
	    * timeline_absolute: cada tiempo definido es a partir del inicio del timeline
	4 - Elegir entre:
	    * timeline_once: el TL se ejecuta una única vez
	    * timeline_repeat: el timeline 
    */
    timeline_create(_TLID,lTimes,1,timeline_relative,timeline_repeat)
    
    // Establecemos el nivel de LOG que recogerá de forma automática la master
    set_log_level(3)


    define_function integer fnMiFuncion(integer nArgNumero,char sArgCadena[])
    {
	/* STACK_VAR, LOCAL_VAR
	Palabras reservadas que se usan para definir variables locales
	- stack_var: la variable sólo es visible en el bloque de código donde está, 
	y cuando termine el bloque, su valor se destruirá
	- local_var: sólo visible desde éste bloque, pero el valor reside en memoria,
	al terminar la ejecución del bloque
	*/
	stack_var integer nResultado
	/* Ésto es una función que devuelve un entero y que recibe dos argumentos:
	- nArgNumero: argumento de tipo entero
	- sArgCadena: argumento de tipo cadena (da igual la lontigud) */
	
	
	/*
	    Una cadena puede estar compuesta de palabras o frases literales, contenidas en comillas simples '',
	    pero también se pueden enlazar con otros valores (números enteros, códigos hexadecimales, conversiones
	    de números enteros a cadena, etc.). 
	    Cuando hay combinación de tipos, todo se define dentro de comillas dobles "", y para unir los elementos 
	    entre sí, se usa la coma (,)
	*/
	send_string 0,"'ésta es mi función, y el resultado es: ',itoa(nResultado)"
	
	send_string 0,"'esta cadena contiene literales ',$0a,'hexadecimales',20,'y números'"
	
	/* Sentencia para devolver el resultado de la función;
	Ésta sentencia sólo es obligatoria si arriba se define el tipo a devolver*/
	return nResultado
    }

/* DEFINE_EVENT
Sección donde recogemos los diferentes tipos de eventos que se pueden producir. Los más comunes son:
- Button event: pulsación del usuario sobre la pantalla
- Channel event: un canal cambia de estado (detección de un relé, cambio de estado de un canal
en la lógica de la programación, etc.
- Data event: recibimos una cadena o comando desde un dispositivo (real o virtual), un dispositivo 
hace online, offline o recibe un error.
- Level event: detectamos un cambio en un nivel
*/
DEFINE_EVENT

    /* BUTTON_EVENT
    Tipo de evento que se produce cuando el usuario pulsa un botón. En la cabecera del evento se 
    define sobre qué dispositivo y qué canales en concreto vamos a estar a la escucha.
    */
    
    /* Entrará en ésta sección, cuando se pulse cualquiera de los botones en el panel dvTp con 
    Channel Codes definidos en el array anBtnMenu (11,12,13,14,15) */
    button_event[dvTp,anBtnMenu]
    {
	// Evento cuando se pulsa (es la única sección obligatoria)
	push:
	{
	    /* Usamos sentencias send_string 0,'cadena', (que luego aparecerán en la ventana de Diagnostics),
	    para comprobar que la ejecución pasa por las partes del código que nos interesan */
	    send_string 0,'¡El usuario ha pulsado uno de los botones!'
	    
	    
	    // dentro de éste bloque, la referencia button.input.channel contendrá el código de canal que se ha pulsado
	    send_string 0,"'el usuario ha pulsado el canal: ',button.input.channel"
	}
	// Evento cuando se mantiene pulsado el botón
	// Entre corchetes el tiempo que debe transcurrir (en décimas) para que entre
	hold[50]:
	{
	
	}
	// Evento cuando se suelta el botón
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
    Sección para recoger eventos relacionados con dispositivos (tanto reales como virtuales)
    Dependiendo del tipo de dispositivo, algunas secciones tendrán más sentido o no. 
    Para el ejemplo usaré el tipo socket (conexión TCP/IP o UDP), que es el que más secciones usa.
    */
    
    data_event[dvSocket]
    {
	online:
	{
	    // Entrará por aquí cuando el dispositivo se conecte
	}
	offline:
	{
	    // Entrará por aquí cuando el dispositivo se desconecte
	}
	onerror:
	{
	    // ENtrará por aquí cuando se produzca algún error, en el caso de los sockets, cada 
	    // Número de error está definido en la ayuda
	}
	string:
	{
	    // Entrará por aquí cuando recibamos una cadena que nos envíe el equipo al que 
	    // Nos hemos conectado
	    
	    // la palabra reservada data.text contiene la cadena que hemos recibido
	    send_string 0,"'recibimos la cadena: ',data.text"
	}
	command:
	{
	    // ésta sección no aplica en los sockets, sólo tiene sentido en dispositivos virtuales
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
		    // Entra aquí si X de vale 10
		}
		case 20:
		{
		    // Entra aquí si X de vale 20
		}
		case 30:
		{
		    // Entra aquí si X de vale 30
		}
		default:
		{
		    // Entra aquí si ninguna de las condiciones anteriores se cumple
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
		    // Entra aquí si la cadena vale Antonio
		}
		active(sCadena == 'Juan'):
		{
		    // Entra aquí si la cadena vale Juan
		}
		active(find_string(sRespuesta,'ON',1)):
		{
		    // Entrará si dentro de sRespuesta encuentra a partir de la posición 1 la trama 'ON' 
		    /*
		    FUNCIONES DE TRATAMIENTO DE CADENAS:
		    
		    Algunas de las más usadas:
		    
		    find_string(dondeBuscar,queBuscar,aPartirDeQuePosicion) // Devolverá en formato número la posición donde ha encontrado la trama
		    
		    remove_string(dondeBorrar,queBorrar,aPartirDeQuePosicionBuscoLaCadenaABorrar) // Devolverá en formato cadena la secuencia que ha borrado
		    
		    get_buffer_string(dondeBorrar,cuantosCaracteresBorrar) // Devolverá en formato cadena los caracteres extraídos
		    */
		}
		active(1):
		{
		    // Entra aquí si ninguna de las condiciones anteriores se cumple
		}
	    }
	}
    }
    
    timeline_event[_TLID]
    {
	// Entrará aquí cada 30 segundos
	send_string 0,"'I´m alive'"
    }    

(**********************************************************)
(*		        END OF PROGRAM 			  *)
(**********************************************************) 