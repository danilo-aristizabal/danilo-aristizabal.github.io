*****************************************************
** Universidad de los Andes - Facultad de Economía **
** 			    Econometría I 2022-I                **
**												   **
** 				      Clase 1                      **
*****************************************************

* 1) Interfaz
* Comando display: Con este comando se le puede pedir a Stata que nos muestre un texto determinado
display "Muy buenas tardes apreciados estudiantes"
dis 2+2 // Este comando también puede ser empleado como una calculadora 

** Archivos de ayuda y búsqueda e instalación de paquetes 
help dis // Esto muestra el archivo de ayuda del comando especificado. 

** Ahora supongamos que queremos un paquete que permita implementar el filtro de Hodrick-Prescott en Stata:
findit hodrick prescott // Busqueda de paquetes
ssc install hprescott // Instalación de paquetes

* Do-file
** Comandos son útiles para empezar los do-files: 
clear // Borra la base de datos que se encuentre abierta
set more off // Quita la opción de more. Con esto se pueden ver completas las tablas que son demasiado grandes
browse // Con esto puedo ver la base de datos
clear all // Borra la base de datos que encuentra abierta y toda la información guardada durante la sesión (e.g. escalares, matrices, etc.)

* Cargamos la base de datos auto
sysuse auto // Importamos una base de datos del servidor de Stata para explorar. 
set more off
sum price 
browse make price trunk

** ¿Cómo incorporar comentarios en el do-file?

* Opción 1: 
* Esta es la clase de Econometria I 
* Opción 2: 
/* Esta es la clase de Econometria I */
* Opción 3: 
// Esta es la clase de Econometria I

* 2) Tipos de archivos

* Do-file	.do
* Base de datos	.dta, .csv, .txt, .xlsx

*******************************************
**  3) Identificar el formato de la base **
*******************************************
cd "C:\Users\DANILO\OneDrive - Universidad de Los Andes\Teaching\Econometria 2022\Clase_1" // Fija el directorio de trabajo en Windows

clear all

*3.1. Comando dir:

dir // ¿Que hay en la carpeta?
  
*3.2. Usar "type" para ver los datos contenidos en un archivo

type NBI_1993.csv
type NBI_1993.txt

*******************************************
** 4)  Importar datos de otros formatos  **
*******************************************

*4.1 Archivo Excel
import excel "NBI_2011", describe  
import excel "NBI_2011.xlsx", clear // Si se tiene un archivo de Excel con varias
			//hojas y no se especifica la opcion sheet Stata toma la primera hoja 
import excel "NBI_2011.xlsx", sheet("Municipios") cellrange(A5:G1127) firstrow clear

*4.2 Archivos de texto (.csv.txt .raw)

*4.2.1 Separado por comas(.csv)
import delimited "NBI_1993.csv", delimiter(comma) clear // No es necesario 
											// la extensión (por defecto es .csv)
import delimited "NBI_1993", delimiter(comma) rowrange(1:1122) clear //permite 
										// ajustar el número de columnas o variables
insheet using "NBI_1993.csv", clear delimiter(",") // para versiones recientes 
									//insheet fue reemplazado por import delimited
*4.2.2 Separado por espacio(.txt)
import delimited "NBI_1993.txt", delimiter(tab) clear
insheet using "NBI_1993.txt", clear 

*************************************************
** 5. Comandos para la descripción de variables *
*************************************************
use "Base_clase_1.dta", replace

*5.1 Summarize 
sum ingresos_hogar_jefe
sum ingresos_hogar_jefe, d

*5.2 Tabulate
tab qq1
tab qq1, m
drop if qq1 == .
tab qq1 IRA // Tabla de contingencia

*1.4 Describe
describe // todas las variables de la base
describe EDI MALT IRA EDA // variables señaladas

******************************
** 6. Creación de variables **
******************************

/* Creando variables numéricas */
gen bogota=0
replace bogota=1 if depmuni=="11001"

/* Creando variables de texto (string) */
sum ingresos_hogar_jefe
sum ingresos_hogar_jefe, detail
gen ingresos_altos="Sí" if ingresos_hogar_jefe>=904052.6
replace ingresos_altos="No" if ingresos_hogar_jefe<904052.6

/* Cambiar el nombre de las variables */
rename EDA eda
rename (algo qq1) (desconocida quintil_n)
rename ingresos* ing*
rename _all, lower // otra forma de decir: rename (IRA MALT EDI) (ira malt edi)

***************************
** 7. Operadores lógicos **
***************************
	*-------------------------------------------------------------------*
	*	Expresiones Lógicas 					Significado				*
	*-------------------------------------------------------------------*
	*			&, |						  Y (And), O (Or)			*
	*			>,<							Mayor que, Menor que		*
	*		   ==, !=						Igual a, Diferente a		*
	*		   >=, <=					Mayor Igual, Menor o Igual 		*
	*-------------------------------------------------------------------*
	*	Expresiones Aritméticas 										*
	*-------------------------------------------------------------------*
	*			+, -							Más, Menos				*
	*			*, /					 Multiplicación, Division 		*
	*			_n					Número de observación corriente		*
	*			_N					Número de observaciones totales		*
	*-------------------------------------------------------------------*
	
sum ing_hogar_jefe if _n<=10
sum ing_hogar_jefe if _n<=15 & _n>10
sum ing_hogar_jefe if _n<10 & ing_hogar_jefe!=0
gen obs=_N

***************************
** 8. Tipos de variables **
***************************

** (A) Numéricas
 *--------------------------------------------------------------------------*
 *  Storage                                              Número más         *
 *  type      Número más pequeño    Número más grande    cercano a 0  bytes *
 *  ----------------------------------------------------------------------- *
 *  byte                    -127                  100    +/-1          1    *
 *  int                  -32,767               32,740    +/-1          2    *
 *  long          -2,147,483,647        2,147,483,620    +/-1          4    *
 *  float   -1.70141173319*10^38  1.70141173319*10^38    +/-10^-38     4    *
 *  double  -8.9884656743*10^307  8.9884656743*10^307    +/-10^-323    8    *
 *  ----------------------------------------------------------------------- *

recast byte eda // cambiamos el tipo de almacenamiento para una variable
compress // Para ahorrar espacio en memoria
 
******************************************
** 9. Conversión entre tipo de variables *
******************************************

tostring muestreo, gen(muestreo2) // de número a caracter
br muestreo muestreo2
tostring muestreo, replace
drop muestreo2
br muestreo

destring malt, gen(malt2) // de caracter a número
br malt malt2
destring malt, replace
drop malt2

*************************************************
** 10.	Operaciones con variables de caracteres *
*************************************************

gen id_hogar=muestreo+vivienda+hogar // otra forma es: egen id_hogar=concat(muestreo vivienda hogar)
gen substr1=substr(id_hogar,1,4)
gen substr2=substr(id_hogar,6,3)
gen cod_depto=substr(depmuni,1,2)

********************
* 11. Etiquetas    *
********************

** Variables
gen edad_madre = rnormal(30,15) 
label var edad_madre "edad de la madre" // Asignación directa
d edad_madre 

* Hacemos un histograma de la variable edad_madre
hist edad_madre

graph bar ing_hogar_jefe, name(barras1, replace) // el promedio es por defecto
graph bar (mean) ing_hogar_jefe, over(cod_depto) name(barras2, replace) 
// graficamos el promedio del ingreso del jefe de hogar por depto