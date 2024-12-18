# BanderaPromedio

<p align="center">
  <img src="./assets/banderaPromedio.png" height="150" />
</p>

¿Te has preguntado cómo sería una bandera que represente proporcionalmente la población de varios países? Este script permite combinar las banderas de diferentes países, reflejando su proporción de población en el diseño final. ¡Explora cómo las matemáticas y la programación pueden transformar imágenes!

## Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Cómo Funciona](#cómo-funciona)
3. [Implementación en MATLAB](#implementación-en-matlab)
4. [Cómo Ejecutar el Script](#cómo-ejecutar-el-script)
5. [Licencia](#licencia)

## Descripción General

Este proyecto genera una imagen compuesta usando las banderas de un grupo de países. La “dominancia” de cada bandera en la imagen resultante depende de la proporción de la población del país en relación al total. Los cálculos se basan en datos estadísticos (ejemplo: población del año 2012).

El script está implementado en MATLAB debido a su simplicidad para realizar operaciones con imágenes.

## Cómo funciona

### Interpolación de banderas

Sean $A$ y $B$ dos países con poblaciones $p_A$ y $p_B$. El porcentaje de población de cada uno con respecto al total será:

* $p_{A\%} = \dfrac{p_A}{p_A + p_B}$

* $p_{B\%} = \dfrac{p_B}{p_A + p_B}$

Como ejemplo, si las poblaciones respectivas son $p_A = 2$ y $p_B = 2$, los porcentajes serán:

* $p_{A\%} = \dfrac{1}{1 + 1} = \dfrac{1}{2} = 50\%$

* $p_{B\%} = \dfrac{1}{1 + 1} = \dfrac{1}{2} = 50\%$

Suponiendo que en un punto determinado de la bandera el valor RGB es `#888888`, y en el mismo punto de la otra bandera el valor RGB es `#000000`, el valor resultante debería ser `#444444`. Esto se puede expresar en forma matemática como:

$$
\begin{array}{rcl}
  \text{RGB}_{\text{interpolado}} & = & \text{RGB}(p_A) \times p_{A\%} + \text{RGB}(p_B) \times p_{B\%} \\
  {} & = & \left( 88 \space 88 \space 88 \right) \times 50\% + \left( 00 \space 00 \space 00 \right) \times 50\% \\
  {} & = & \left( 44 \space 44 \space 44 \right) + \left( 00 \space 00 \space 00 \right) \\
  {} & = & \left( 44 \space 44 \space 44 \right)
\end{array}
$$

Podemos comprobar que esta fórmula es correcta, por ejemplo, analizando el caso para el que el país $B$ tiene $3$ habitantes, lo que da una población total de $4$. El resultado será ahora:

$$
\begin{array}{rcl}
  \text{RGB}_{\text{interpolado}} & = & \text{RGB}(p_A) \times p_{A\%} + \text{RGB}(p_B) \times p_{B\%} \\
  {} & = & \left( 88 \space 88 \space 88 \right) \times 25\% + \left( 00 \space 00 \space 00 \right) \times 75\% \\
  {} & = & \left( 22 \space 22 \space 22 \right) + \left( 00 \space 00 \space 00 \right) \\
  {} & = & \left( 22 \space 22 \space 22 \right)
\end{array}
$$

Esto nos sugiere que el color resultante en ese punto será más oscuro, y esto es lógico, puesto que tiene mayor “peso” el punto `#000000`.

La fórmula para $n$ países que se desprende a partir de estos cálculos es

$$
\text{RGB}_{\text{xy(interpolado)}} = \sum_{i=1}^{n} \text{RGB} \left( p_{xy(i)} \right) \times p_{i\%}
$$

donde $(x,y)$ son las coordenadas del pixel.

### Interpolación de proporciones de banderas

El otro problema al interpolar las imágenes de las banderas es que cada bandera tiene sus propias proporciones. Si suponemos que una bandera tiene un tamaño de 800x400 píxeles (1:2) y otra tiene un tamaño de 800x500 (5:8), podemos estimar un primer “tamaño interpolado” como un promedio:

$$
\text{XY}_{\text{interpolado}} = \dfrac {\left( 400 \space 800 \right) + \left( 500 \space 800 \right)}{2} = \dfrac {\left( 900 \space 1600 \right)}{2} = \left( 450 \space 800 \right)
$$

Sin embargo, esto no es óptimo. ¿Por qué? Porque, aunque las banderas del ejemplo tenían dimensiones similares, existen casos en los que existe una excesiva desproporción. Por ejemplo, si la segunda bandera tiene medidas 492x600, el resultado sería

$$
\text{XY}_{\text{interpolado}} = \dfrac {\left( 400 \space 800 \right) + \left( 600 \space 492 \right)}{2} = \dfrac {\left( 1000 \space 1292 \right)}{2} = \left( 500 \space 646 \right)
$$

Esto haría a una bandera como la de Nepal distorsionarse considerablemente:

<p align="center">
  <img src="./assets/banderaNepal.png" width="161" />
</p>

Se puede mejorar el cálculo anterior usando los valores _p_ ya determinados:

$$
\begin{array}{rcl}
  \text{XY}_{\text{interpolado}} & = & \text{XY}(p_A) \times p_{A\%} + \text{XY}(p_B) \times p_{B\%} \\
  {} & = & \left( 400 \space 800 \right) \times 50\% + \left( 600 \space 492 \right) \times 50\% \\
  {} & = & \left( 200 \space 400 \right) + \left( 300 \space 246 \right) \\
  {} & = & \left( 500 \space 646 \right)
\end{array}
$$

Esta otra forma propone una mejora significativa en el caso en que un país cuya bandera sea más “cuadrada” domine en términos de población sobre otra con una bandera más “rectangular”. Por ejemplo, si dicho país tiene 9 veces la cantidad de habitantes que el otro, con los mismos tamaños de bandera, resulta:

$$
\begin{array}{rcl}
  \text{XY}_{\text{interpolado}} & = & \text{XY}(p_A) \times p_{A\%} + \text{XY}(p_B) \times p_{B\%} \\
  {} & = & \left( 400 \space 800 \right) \times 10\% + \left( 600 \space 492 \right) \times 90\% \\
  {} & = & \left( 40 \space 80 \right) + \left( 540 \space 443 \right) \\
  {} & = & \left( 580 \space 523 \right)
\end{array}
$$

Las proporciones, entonces, son evidentemente más apropiadas si el país tiene una población significativa. En el caso opuesto, se observa que:

$$
\begin{array}{rcl}
  \text{XY}_{\text{interpolado}} & = & \text{XY}(p_A) \times p_{A\%} + \text{XY}(p_B) \times p_{B\%} \\
  {} & = & \left( 400 \space 800 \right) \times 90\% + \left( 600 \space 492 \right) \times 10\% \\
  {} & = & \left( 360 \space 720 \right) + \left( 60 \space 49 \right) \\
  {} & = & \left( 420 \space 769 \right)
\end{array}
$$

Se puede ver que la bandera resultante es más parecida en sus proporciones a la que contiene la mayoría de la población, por lo que la fórmula resulta útil.

La fórmula para N países que se desprende a partir de estos cálculos es

$$
\overline{\text{XY}_{\text{interpolado}}} = \sum_{i=1}^{n} \overline{\text{XY}} \left( p_{xy(i)} \right) \times p_{i\%}
$$

## Implementación en MatLab

```matlab
function imagen_salida = banderas( nombre_origen )

    display('Abriendo hoja de datos...');
    origen_datos = tdfread(nombre_origen,';');
    
    display('Verificando lista de imágenes... ');
    cont_errores = 0;
    for nro_pais = 1:1:size(origen_datos.Country,1)
        archivo_actual = strcat('banderas\', origen_datos.Country(nro_pais,:), '.png');
        if exist(archivo_actual,'file') == 0
            display([' -- ERROR: No se encuentra el archivo ' archivo_actual]);
            cont_errores = cont_errores + 1;
        end
    end

    if cont_errores > 0
        error('Corrija los errores descritos y vuelva a intentar.');
    end

    display('Ponderando datos de cada país...');
    poblacion_total = sum(origen_datos.Population);
    ponderaciones = zeros(length(origen_datos.Population),1);
    for nro_pais = 1:1:size(origen_datos.Population,1)
        ponderaciones(nro_pais) = origen_datos.Population(nro_pais) / poblacion_total;
    end
    
    display('Preprocesando imágenes...');
    alto_optimo = 0;
    ancho_optimo = 0;
    for nro_pais = 1:1:size(origen_datos.Country,1)
        archivo_actual = strcat('banderas\', origen_datos.Country(nro_pais,:), '.png');       
        buffer_lectura = imread(archivo_actual);
        [alto, ancho, dim] = size(buffer_lectura);
        alto_optimo = alto_optimo + alto * ponderaciones(nro_pais);
        ancho_optimo = ancho_optimo + ancho * ponderaciones(nro_pais);
    end
    alto_optimo = round(alto_optimo);
    ancho_optimo = round(ancho_optimo);
    
    display('Generando imagen de salida...');
    imagen_salida = zeros(alto_optimo, ancho_optimo, 3,'uint8');
    for nro_pais = 1:1:size(origen_datos.Country,1)
        archivo_actual = strcat('banderas\', origen_datos.Country(nro_pais,:), '.png');       
        buffer_lectura = imread(archivo_actual);
        buffer_lectura = imresize(buffer_lectura, [alto_optimo ancho_optimo]);
        imagen_salida = imagen_salida + ponderaciones(nro_pais) * buffer_lectura;
    end
    
end
```

## Cómo Ejecutar el Script

1. Crear un archivo de texto en formato CSV, con los siguientes campos:

    ```
    Country;Population
    ```

2. Colocar las banderas en la carpeta `./banderas`. Los nombres de archivo deben coincidir con los valores del campo `Country`.

3. Ejecutar el script:

    ```
    banderaPromedio(nombre_de_archivo)
    ```

4. Buscar en la carpeta del script el archivo generado con formato PNG.

## Licencia

Este proyecto está disponible bajo la licencia MIT.