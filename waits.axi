PROGRAM_NAME='waits'
(***********************************************************)
(*  FILE CREATED ON: 03/24/2021  AT: 10:32:14              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/24/2021  AT: 10:48:54        *)
(***********************************************************)


/* SECCIONES DENTRO DE UNA LIBRERÍA
    Las librerías también pueden incluir todas las secciones que tenemos 
    en la línea principal del programa. No pasa nada por repetir, a la hora
    de compilar el compilador las juntará en un único archivo
    
*/
DEFINE_VARIABLE

    volatile integer nBtnWaits = 200
    volatile integer x = 11
    
DEFINE_EVENT

    /* La variable dvTp es reconocida porque en la línea principal incluimos 
    ésta librería después de haber definido el dispositivo dvTp, por lo que 
    la reconoce*/
    button_event[dvTp,nBtnWaits]
    {
	push:
	{
	    /* WAITS
	    Los waits son órdenes que nos permiten retrasar la ejecución de un
	    trozo de código X tiempo o hasta que se produzca una condición en 
	    concreto. Ejemplos:
	    */
	    
	    wait 100 // cuando pasen 100 décimas de segundo (10 segundos), entrará por el bloque
	    {
		send_string 0,'¡han pasado 10 segundos!'
	    }
	    
	    wait 50 'con_nombre' // los waits pueden tener nombre...
	    {
		send_string 0,'han pasado 5 segundos'
	    }
	    
	    // ... para poder cancelarlos si fuera necesario
	    cancel_wait 'con_nombre'
	    
	    // Otros tipos de WAIT son los WAIT_UNTIL
	    
	    wait_until(x == 10) 'dale_siempre_nombre'
	    {
		// Esperará a entrar aquí cuando x valga 10 y no antes
	    }
	    
	    /* Éste tipo de waits, son muy peligrosos porque corren el riesgo
	    de quedarse siempre a la espera de una condición que no sucede,
	    por lo que es buena praxis cancelarlos después de un tiempo de timeout
	    */
	    
	    wait 100 'timeout'
	    {
		cancel_wait_until 'dale_siempre_nombre'
	    }
	}
    }
    