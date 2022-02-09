**********************************************************
**  Universidad de los Andes - Facultad de Economía     **
** 	 		      Econometría 1 2022-I                  **
** 			   						                    **
**   Clase 3 - Estadisticas Descriptivas y Gráficos     **
**********************************************************
* Empezamos los do-files limpiando el espacio de trabajo y especificando los comando que permiten la ejecución continua

clear all
cap log close
set more off
cd "C:\Users\DANILO\OneDrive - Universidad de Los Andes\Teaching\Econometria 2022\Clase 3. Estadisticas Descriptivas y Graficos"
*Abremos nuestro logFile
log using "log_clase3.log", replace
*Chequeamos que hay en nuestra carpeta
dir 

*******************************************************************************
** 1. Repasemos lo que vimos la semana pasada y conozcamos la Base            *
*******************************************************************************
use "Base_Clase3_1", clear

*1.1 Describe
describe // todas las variables de la base
 
*1.2 Summarize 
sum ingresos_hogar_jefe
sum ingresos_hogar_jefe, d
sum ingresos_hogar_jefe if  qq1==1

*1.3 Tabulate
tab qq1
tab qq1, m
tab qq1 IRA // Tabla de contingencia 

*1.4 Tabstat
tabstat ingresos_hogar_jefe 
*Revisemos las opciones que nos da tabstat
h tabstat
**************************************ESTADISTICAS DISPONIBLES EN TABSTAT*********************
/*     COMANDO          ESTADISTICA DESCRIPTIVA QUE DEVUELVE 
        mean            Media
        count           Cuenta las observaciones (distintas a missings)
        n               Igual que count
        sum             suma
        max             Nos da el máximo
        min             Nos da el minimo
        range           Rango - Nos da el maximo - minimo
        sd              Nos da la desviación Estandar
        variance        Nos da la varianza
        cv              El Coeficiente de variación (sd/mean)
        semean          Los errores Estandar de la Media (sd/sqrt(n))
        skewness        Información sobre Asimetría
        kurtosis        Información sobre la Curtosis
        p1              1st percentil
        p5              5th percentil
        p10             10th percentil
        p25             25th percentil
        median          mediana (p50)
        p50             50th percentil (mediana)
        p75             75th percentil
        p90             90th percentil
        p95             95th percentil
        p99             99th percentil
        iqr             Rango entrecuartiles = p75 - p25
        q               Lo mismo que decirle que nos saque cuartiles de a 25 - p25 p50 p75
*/******************************************************************************************

tabstat ingresos_hogar_jefe, stat(mean range) by(EDA)
tabstat ingresos_hogar_jefe EDI, stat(mean variance) by(qq1)


*1.5 Para organizar por grupos las Estadisticas - Comandos by y bysort
* Podríamos hacerlo con If
sum  ingresos_hogar_jefe if  qq1==.
sum  ingresos_hogar_jefe if  qq1==1
sum  ingresos_hogar_jefe if  qq1==2
sum  ingresos_hogar_jefe if  qq1==3
sum  ingresos_hogar_jefe if  qq1==4
sum  ingresos_hogar_jefe if  qq1==5
*Sin embargo, es más facil utilizar "by". 
by qq1: sum ingresos_hogar_jefe // Note que nos arroja un error porque la base no está ordenanda por en el orden de a_ing
*Organizamos para que se pueda sacar grupalmente       
sort qq1
by qq1: sum ingresos_hogar_jefe
* Podemos hacerlo todo en un único comando 
bys depmuni: sum ingresos_hogar_jefe, d
bys depmuni: tab qq1


***************************************
** 2. Categoricas y Missings Values  **
***************************************
use Base_Clase3_2, clear
*Conozcamos nuestra nueva base
d 
// La base es de un curso. Tiene 38 estudiantes. Nuestro identificador es el código del estudiante. Vemos su género, sí es de colegio mixto, sus notas en el parcial 1 y parcial 2, su carrera y  2 notas del examen final. (La diferencia entre las dos es que muestra los missing values de formas distintas)

*2.1. CATEGORICAS - Podemos ponerle nombres a las variable categoricas 
*Creamos la etiqueta de valores
label define etbinario 1 "Sí" 0 "No", replace
*Se la damos a nuestra variable categoricas
label values col_mixto etbinario
*Podemos usar la etiqueta para más de una variable, por eso es útil llamarla binario sabremos que cuando pongamos 1 sera si y cuando 0 no. 
label define etbinario 1 "Sí" 0 "No", replace

*2.2. MISSINGS - Según lo que estemos trabajando vamos o no vamos a querer contar los missings
* Primero hay que reconocer los Missing
count if e_final >=3.0
count if e_final >=3.0 & !missing(e_final)
label define missing .a "Faltó con excusa" .b "Faltó sin excusa", replace
label values e_final  missing
label var e_final "Nota examen final con excusas"
tab e_final, miss

* Luego hay que definir qué hacer - De valor a missing value
gen e_final3=e_final2
*Vemos si e_final2 tienes missing values
tab e_final2
*Acá 99 y 98 son missings, queremos cambiarlos. Vamos a ver 3 formas de hacerlo
mvdecode e_final3, mv(98=.a \ 99=.b)  // Método 1. 
drop e_final3 
*Parcial 1 esta como e_final1 y parcial 2 esta como e_final2 frente a los missings values, entonces tenemos que lograr que todos queden igual. 

mvdecode parcial1 parcial2 e_final2,  mv(98=.a \ 99=.b) // Método 2. Especifica diferentes tipos de missing values
mvencode parcial1 parcial2 e_final, mv(.a=0 \ .b=0) // De todas maneras, sobre esta variable vamos a calcular la calificación final

*Organizamos nuestra base según nuestro gusto
order codigo genero col_mixto programa parcial1 parcial2 e_final
br codigo genero col_mixto programa parcial1 parcial2 e_final

*** Cálculo de nota definitiva
gen n_def=(parcial1+parcial2+e_final)/3
sort n_def

*2.3. ENCONDE Y MVCODE

gen aprobado=(n_def>=3 & n_def<=5) 
replace aprobado=. if missing(n_def) // Es importante decirle a Stata que tome en cuenta los missing values de la variable original
label var aprobado "Marca si un estudiante aprobó el curso"
**recode nos sirve para crear una nueva variable especificando su conformación según otra
recode aprobado (0=1) (1=0), gen(reprobado)
**************************************¿Qué podemos hacer con recode?********************************************************
*                    ESPECIFICACIÓN                                 RESULTADO                                              *
*                        # = #                       Nos cambia un número por otro                                         *
*                       # # = #                     Nos puede cambiar más de un valor por uno nuevo                        *
*                     #1/#2 = #                    Nos cambia todos los que hay entre el #1 al #2 por el # que le pedimos  *
*                 nonmissing= #                    Todos los que no sean missings los vuelve 4                             *
*                    missing= #                       Nos cambia todos los Missings                                        *
****************************************************************************************************************************
label var reprobado "Marca si un estudiante reprobó el curso"
*usamos el label que creamos al comienzo
label values aprobado reprobado etbinario

**Con encode o decode podemos pasar en variables categoricas de string a numerica, y en decode al contrario. (SOLO SI LAS NÚMERICAS TIENEN LABEL)
encode genero, gen(genero_c)
br genero genero_c
*siempre que use encode las va a transformar en 1, 2, 3 .... según el número de categorias que ud maneje. NO EMPIEZA EN CERO. Tomelo en cuenta (en las dicotomas va a ser muy importante que lo reconozca)
tab genero_c, nol
*Notemos que decode nos vuelve string tomando el label que existe
decode genero_c, gen(genero_d)
br gen*

drop genero_d
tab gen*, nol
recode genero_c (2=1) (1=0), gen(Mujer)
label values Mujer etbinario
drop genero_c
********************
** 3. Comando egen * 
********************
*Creamos unas variables que nos faciliten el manejo de datos de acá en adelante. Queremos saber en que semestre entraron
gen a_ing=substr(codigo,1,4)
destring a_ing, replace


* Queremos ver la nota definita según cada año de ingreso
bysort a_ing: sum n_def
*¿y si solo nos interesa el promedio?
tabstat n_def, by(a_ing)
tabstat n_def, stat(count mean) by(a_ing)

* 3.1 Calculos con una variable y sus categorias.
egen nota_maxima=max(n_def)
egen nota_minima=min(n_def)
egen desvest=sd(n_def)
egen promedio=mean(n_def)
egen percentil=pctile(n_def), p(75)
br nota_maxima nota_minima desvest promedio percentil
*Podemos hacer todo con by para dos variables
order a_ing n_def
br a_ing n_def
bys a_ing: egen media=mean(n_def)
bys a_ing: egen desvest2=sd(n_def)
*Incluso podemos hacerlo para 3
order a_ing Mujer n_def
br a_ing Mujer n_def
bys a_ing Mujer: egen media_generoAño=mean(n_def)
bys a_ing Mujer: egen sd_generoAño=sd(n_def)

* 3.2 Cálculos con varias variables
egen n_def1=rowmean(parcial1 parcial2 e_final) // Cálculo de nota definitiva con egen, le digo que me saque el promedio de las 3
egen mejor_nota=rowmax(parcial1 parcial2 e_final) // Les digo que nos busque en las variables la mejor nota
 
* 3.3 ¿Cómo hacerlo con Categoricas?
egen grupo=cut(n_def), at(1,2,3,4,5) // En este caso asigna 1 si (1 <= n_def <2), 2 si (2 <=n_def <3 ) y así....
sort n_def
br n_def grupo
*Todo en un solo comando
egen grupo2=cut(n_def), at(1(1)5) // Este comando especifica exactamente la misma instrucción de arriba solo que le decimos que vaya de 1 en 1 empezando 1 uno y terminando en 5
egen grupo3 =cut(n_def), group(5) // Este comando me divide a los estudiantes en grupos iguales, no según notas (muy util para crear cuartiles)
br n_def grupo*

*De otras formas
egen aprobado3=cut(n_def), at(0,3,5) icode // de 0 a 3 les da el valor de 0 y de 3 a 5 les da el valor de 1. Es otra forma de crear una dicotoma
egen año_Mujer=group(a_ing Mujer) // si son del mismo genero y del mismo año las mete en el mismo grupo
bysort año_Mujer: sum(n_def) // 
bysort año_Mujer: egen total=sum(n_def)


**************************
** 4. Graficos Básicos  **
**************************
* 4.1. Barras
*Opciónes de las graficas de barras
graph bar (mean) n_def, over(Mujer) name(BarrasPromedio, replace) 


graph bar (mean) n_def if a_ing>2012, over(Mujer)  ///Condicional por grupos
title("Nota final de 2012 en Adelante") subtitle(según si es o no mujer) ytitle("Promedio Nota Final") ///titulos de los grupos
name(BarrasPromedio2, replace) 

*Barras horizontales 
graph hbar n_def if a_ing<=2015, over(programa, label(angle(0) labsize(small))) /// Ponemos más cuidado en como queremos organizar los grupos 
title (Según Programa) ytitle(Nota Final) name(barrash, replace)

*Doble over, título, subtítulo y título de eje
graph bar (mean) n_def if a_ing<=2015, /// 
over(Mujer, label(angle(90) labsize(small))) /// Orientación y tamaño de leyenda
over(programa, label(angle(90) labsize(vsmall))) /// Orientación y tamaño de leyenda  
title("Notas Finales") /// Título
subtitle("Según programa y si es mujer") /// Subtitulo
ytitle(Calificación) /// Título del eje Y
name(barras4, replace)
	
	
*Varios cálculos - Un color para cada uno
graph bar (mean) n_def (median) n_def, over(Mujer, label(angle(vertical))) ///
b1title(Estadisticos) /// Titulo de la leyenda
ytitle(NotaFinal) ylabel(0(0.8)5) /// Modificar el eje
title(Notas Finales) ///
subtitle(Según si es o no mujer) ///
legend(order(1 "Media" 0 "Mediana")) ///
name(barras5, replace)

* 4.2.  Box
graph box n_def, over(Mujer) ytitle(Nota Definitiva) title(Clase de Econometría 1) subtitle(¿Es mujer?) name(box1,replace) saving(box1, replace)


*Varias variables y arreglamos el legend para que salga por rows y no columns
graph box n_def mejor_nota, over(Mujer, label(angle(vertical))) ///
ytitle(Nota) ///
title(Econometría 1) ///
subtitle(¿Es Mujer?) ///
legend(order(1 "Definitiva" 0 "Mejor Nota")) ///
legend(r(2))


* 4.3.  Pie
graph pie, over(programa) title(Distribución por Carreras) note(Estudiantes de Econometría 1)
	

**************************
** 5. Graficos Twoway  **
**************************

* 5.1 Barra
*chequeemos si hay una relación entre las notas del parcial 1 y las finales
graph twoway bar n_def parcial1 //La sintaxis cambia respecto al comando anterior
tw bar n_def parcial1, name(barras1, replace) // Abreviando el comando
	
* 5.2 Scatter
twoway scatter n_def parcial1 if Mujer==1, ylabel(0(1)5) name(scat1, replace)

twoway (scatter n_def parcial1) (lfit n_def parcial1) if Mujer==1, ylabel(0(1)5) name(scat2, replace) //Introduce línea de tendencia
twoway (scatter n_def parcial1) (qfit n_def parcial1) if Mujer==1, ylabel(0(1)5) name(scat2, replace) //Con una tendencia no lineal
scatter n_def parcial1 || lfit n_def parcial1 || if Mujer==1, ylabel(0(1)5) name(scat3, replace)

* 5.3 Unir varios twoways scatter
twoway scatter parcial1 parcial2 n_def, ylabel(0(1)5) name(scat3, replace) // Varias variables
twoway (scatter parcial1 parcial2 n_def) (lfit parcial1 n_def) (lfit parcial2 n_def), legend(c(1)) name(scat4, replace) legend(order(1 "Parcial 1" 2 "Parcial 2" 3 "Aproximación 1" 4 "Aproximación 2"))


* 5.4. Histograma
twoway histogram parcial1, name(histogr1, replace)
twoway histogram parcial2, name(histogr2, replace)
twoway histogram n_def if, freq name(histogr3, replace)
hist parcial 1 , bin(10) name(histogr4, replace)

* 5.5 By en gráficos
drop if parcial1==0
drop  if parcial2==0
twoway (scatter parcial2 parcial1) (qfit parcial2 parcial1), by(col_mixto) name(scat_by, replace) 


/* 	Fin 
	de 
	la 
	clase */
	
log close

