********************************************************************************
************  Universidad de los Andes - Facultad de Economía       ************
************	      Econometría 1 2022-I                          ************
** 			   						                                ************
************ Clase 5 - Simulacion del modelo de regresion lineal    ************
********************************************************************************

/* En esta clase vamos a simular el rendimiento de los estudiantes del curso de econometria
con base en las horas dedicadas a la semana a estudiar la asignatura. Como variable dependiente 
vamos a usar la calificacion al final del semestre y como variable independiente (variable explicativa),
vamos a usar las horas dedicadas a la semana a estudiar la materia.
*/

// Empezamos los do-files limpiando el espacio de trabajo y especificando 
// los comandos que permiten la ejecución continua

clear all
set more off
cap log close

cd "C:\Users\de.aristizabal411\OneDrive - Universidad de los Andes\Teaching\Econometria 2022\Clase 5. Modelo regresion lineal"

*Abrimos nuestro logFile
log using "log_clase5.log", replace

* Le decimos a stata que queremos que nos cree 1000 observaciones
set obs 1000

set seed 12345 // Establecemos una semilla para poder replicar los numeros aleatorios abajo especificados

* Generamos dos variables aleatorias: horas de estudio dedicadas a econometria y un término de error
// Suponga que los estudiantes dedican entre 0 y 7 horas a la semana a estudiar la asignatura (fuera de clase)
gen horas_estudio_semana = runiform(0,7) 
// u recoge todo lo que pueda explicar la nota final del curso que no logra explicar las horas dedicadas a estudiar
gen u = rnormal(0,1)

sum horas_estudio_semana u
asdoc sum horas_estudio_semana u, save(tabla2.rtf) replace

* Veamos los histogramas de nuestras dos variables aleatorias
hist horas_estudio_semana, name(histo1, replace)
hist u, name(histo2, replace)

* Generemos una variable aleatoria nota_final = 1 + 0.4X + u
gen nota_final = 1 + 0.4*horas_estudio_semana + u

/* Veamos graficamente la correlacion entre las horas de estudio dedicadas a 
estudiar econometria y la nota final del curso
*/ 
tw (scatter nota_final horas_estudio_semana) ///
   (lfit nota_final horas_estudio_semana, color(red)), name(grafico1, replace) ///
   ytitle(Nota final) xtitle(Horas de estudio dedicadas a la semana) ///
   title(Correlación entre horas de estudio y nota final)
   
* Veamos graficamente la correlacion entre los errores y las horas estudiadas
tw (scatter u horas_estudio_semana) ///
   (lfit u horas_estudio_semana, color(red)), name(grafico2, replace) ///
   ytitle(errores (u)) xtitle(Horas de estudio dedicadas a la semana)
   title(Correlación entre los errores y horas de estudio)
* No existe correlacion entre las horas de estudio y los errores
   
* Estimamos el modelo de regresion lineal simple
cap erase "regresion.txt"
reg nota_final horas_estudio_semana
outreg2 using "regresion.xls", replace

* ¿Donde se guardan los coeficientes de la regresion?
ereturn list
matrix list e(b)

* Guardamos nuestros coeficientes en una matriz
matrix coef = e(b)
matrix list coef
* Tambien podemos guardar nuestro coeficiente de horas de estudio semana como un escalar
scalar b1est = _b[horas_estudio_semana]
display b1est

* Encontremos los valores predichos de la nota final usando los betas estimados 
predict y_predict, xb 

/* Si graficamos los valores predichos de la nota final, estos estan sobre la lineal
de regresion que mejor se ajusta a la nube de puntos
*/
tw (scatter nota_final horas_estudio_semana) ///
   (scatter y_predict horas_estudio_semana, color(black)) ///
   (lfit nota_final horas_estudio_semana, color(red)), name(grafico3, replace)
      
* Tambien podemos encontrar los residuales del modelo 
predict e, res 

* Veamos graficamente la correlacion entre los errores y las horas estudiadas
tw (scatter e horas_estudio_semana) ///
   (lfit e horas_estudio_semana, color(red)), name(grafico2, replace) ///
   ytitle(residuales (e)) xtitle(Horas de estudio dedicadas a la semana)
   title(Correlación entre los residuales y horas de estudio)
   
// Ahora vamos a hacer este mismo ejercicio 500 veces, condicional a horas de 
// estudio dedicadas a la semana a estudiar econometria. Este ejecicio nos sirve
// para ver algunas propiedades del estimador beta1
 

log close  
