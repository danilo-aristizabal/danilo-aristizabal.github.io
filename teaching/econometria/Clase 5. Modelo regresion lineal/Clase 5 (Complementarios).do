********************************************************************************
************  Universidad de los Andes - Facultad de Economía       ************
************	      Econometría 1 2022-I                          ************
** 			   						                                ************
************ Clase 5 - Simulacion del modelo de regresion lineal    ************
********************************************************************************

* Limpiamos nuevamente la memoria
clear

* Fijamos el numero de observaciones igual a 1000
set obs 1000

set seed 123456789 // Establecemos una semilla para poder replicar los numeros aleatorios abajo especificados

* Generamos las variables aleatorias: horas de estudio dedicadas a econometria 
gen horas_estudio_semana = runiform(0,7)
* Generamos la variable nota final 
gen nota_final = .
* Generamos una variable termino de error
gen u = .
* Generamos una variable con el vector de los betas que vamos a estimar
gen beta1est = .

forvalues s = 1/500 {
	replace u = rnormal(0,1)
	replace nota_final = 1 + 0.4*horas_estudio_semana + u
	// Estimamos la siguiente regresion nota_final = 1 + 0.4*horas_estudio_semana + u
	reg nota_final horas_estudio_semana
	
	replace beta1est = _b[horas_estudio_semana] in `s'
} 

hist beta1est, name(histo3, replace)
sum beta1est
     