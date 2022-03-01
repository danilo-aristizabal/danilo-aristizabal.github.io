# ##############################
#     Clase 6 Econometría I
#         Oscar Becerra
#     Análisis de regresión

# Nos aseguramos de que no tengamos objetos
rm(list= ls())
# Escogemos un directorio. En stata: cd"Archivo"
setwd('C:/Users/DANILO/OneDrive - Universidad de Los Andes/Teaching/Econometria 2022/Clase 6. MRL en R')

# Instalo los paquetes a utilizar
lista_paquetes <- c('tidyverse','data.table','plyr','dplyr','readxl', 'haven', 'readtext', 'corrplot')
sapply(lista_paquetes,require,character.only=TRUE)

# Abrimos la base. Para eso necesitamos la libreria readxl
library(readxl)
df <- read_excel('Base_PIB_energia.xlsx',sheet='Sheet1')
# Vemos la estructura
str(df)
# *Fecha					= En años
# *GeneraciónGWh  		= En GWh
# *ConsumoGWh     		= En GWh
# *Consumopercapitakwh 	= En kWh
# *PIBanual        		= En miles de dólares, pero es texto
# *VarPIB          		= Decimales
# *PIBPerCapita   		= En dólares, pero es texto
# *VaranualPIBPeercapita 	= Decimales
# *1.3 Identifico si la base tiene missing values
  any(is.na(df))
# Elimino las observaciones que tienen missing
df <-  na.omit(df)
# Algunas estadísticas descriptivas
summary(df)
# Notamos que el pib tiene caracteres y los reemplazamos
# En R podemos llamar las variables por la posición de las
# Columnas
library(ggplot2) #para hacer gráficas
library(dplyr) #Esta libreria nos permite manejar las bases de datos.
library(corrplot) #Nos permitirá analizar más facil las correlaciones

library(stringr) #Nos facilita el manejo con caracteres

df$`PIB anual` <-  gsub("[ M$]", "" , df$`PIB anual`) 
df$`PIB anual` <-  gsub("[.]", "" , df$`PIB anual`) 
# Para no tener espacios en blanco
df$`PIB anual` <- str_trim(df$`PIB anual`) 

df$`PIB Per Capita` <-  gsub("[ $]", "", df$`PIB Per Capita`) 
df$`PIB Per Capita` <-  gsub("[.]", "", df$`PIB Per Capita`) 
# Para no tener espacios en blanco
df$`PIB Per Capita` <-  str_trim(df$`PIB Per Capita`) 

df$`PIB anual` <- as.numeric(df$`PIB anual`)
df$`PIB Per Capita` <-  as.numeric(df$`PIB Per Capita`) 

# Nos volvemos a asegurar de no tener missings
any(is.na(df))
df <-  na.omit(df)
# *Regresión Lineal 
# *pib=b0 + b1ce1 + u 
# Primero veamos los datos
ggplot(df, aes(`PIB Per Capita`, `Consumo per capita kWh`)) + 
  geom_point() + geom_smooth(method = lm)

# Ahora, miremos cómo correr una regresión
?lm
# Para correr el modelo, lo asigno a un objeto
modelo <- lm(`PIB Per Capita` ~ `Consumo per capita kWh`  ,df)
# Para ver el modelo
summary(modelo)
# La salida de R nos da la formula, un summary de los residuales
# los coeficientes con:
# *Std. Err: Error estándar del coeficiente = 0.7124376 
# *T: Estadístico t para la hipótesis nula de coeficiente igual a 0 = 11.16
# *P>|t|: El p-value asociado al testear = 0.000
# *Coefficient: Parámetros estimados Constante y beta.
# consenergpercapita = 7.951498
# *R-squared : Mide la bondad de ajuste del modelo
# (SS_modelo/SS_Total)= 0.7663
# *Prob > F: Es el valor "p" asociado al estadístico F. Permite testear la hipótesis nual de que todos los coeficientes son iguales a 0 = 0.0000

# ***Interpretación del beta
# *En promedio, un aumento del consumo de energía per cápita 
# en una unidad de kWh, aumenta el PIB per capita en 7.951498 
# dólares, todo lo demás constante. 

# Veamos el y predicho
df$y.gorro <- predict(modelo,df)

ggplot(df, aes(`Consumo per capita kWh`,y.gorro)) + 
  geom_point(color='purple') + geom_smooth(method = lm) +
  geom_point(aes(y=`PIB Per Capita`))

# Ahora, obtenemos los residuales
df$res <- residuals(modelo)
head(df$res)
# Queremos ver la distribución para comprobar la 
# normalidad de los errores
ggplot(df,aes(res)) +  geom_histogram(fill='blue',alpha=0.5)
# ¿Los errores tienen una distribución normal?

# Ahora queremos ver la x y el error, ¿se correlacionan?
ggplot(df, aes(res, `Consumo per capita kWh`))+ 
  geom_point() + geom_smooth(method = lm)


# Simulación --------------------------------------------------------------
# Vamos a hacer una simulación
# Las notas finales explicadas por horas de
# estudio. la variable de interés se califica
# sobre 20 (sistema extranjero)
rm(list= ls())
set.seed(123456789)
# Creamos horas de estudio
horas.estudio <- runif(100,0,10)
# Vamos a crear la misma var pero al cuadrado
horas.estudio.cuad <- horas.estudio*horas.estudio
# Hacemos un error con desv.est de 10 
u <- rnorm(100,0,5)
# Al simular, podremos tener valores negativos y por encima de 20.
# Hagamos supuestos de que esto puede pasar.
nota.final <- 0.2 + 0.4*horas.estudio + 0.2*horas.estudio.cuad + u

data <- data.frame(horas.estudio, horas.estudio.cuad, u, nota.final)
summary(data)

ggplot(data, aes(horas.estudio, nota.final)) + 
  geom_point() 
# Estimo el modelo.
modelo <- lm(nota.final ~ horas.estudio + horas.estudio.cuad ,data)
summary(modelo)
# Estimamos  y gorro
data$y.gorro <- predict(modelo)
# Graficamos
ggplot(data, aes(horas.estudio, nota.final)) + 
  geom_point() + geom_point(aes(horas.estudio, y.gorro), color='purple')

# Revisemos la normalidad de los errores
data$res <- residuals(modelo)
ggplot(data,aes(x=res)) + geom_histogram(bins=20,alpha=0.5,fill='blue')

# Revisemos la correlación del error contra la variable explicativa
ggplot(data, aes(res, horas.estudio)) + 
  geom_point() + geom_smooth(method=lm)
