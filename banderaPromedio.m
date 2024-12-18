function imagen_salida = banderaPromedio( nombre_origen )
%BANDERAPROMEDIO Lee una lista de paises con sus poblaciones y genera, a partir
%  de las banderas de cada uno, una imagen compuesta, donde el aporte de cada
%  imagen individual depende del porcentaje de poblacion de cada pais con
%  respecto a la poblacion total.
% Fecha de publicación: 03 de octubre de 2012 

    display('Abriendo hoja de datos...');
    % PASO 1
    % Se lee el archivo de datos, que debe respetar estas condiciones:
    %   1) La primera fila debe contener los titulos de los campos,
    %      "Country" (Pais) y "Population" (Poblacion).
    %   2) El campo "Population" (Poblacion) no debe tener los digitos
    %      separados por puntos, ya que esto causa que Matlab los lea como
    %      cadenas de texto.
    %   3) Los campos deben estar separados por punto y coma.
    %   4) Se debe sacar la fila de totales para evitar errores de calculo.
    origen_datos = tdfread(nombre_origen,';');
    
    display('Verificando lista de imagenes... ');
    % PASO 2
    % Se verifica que todas las imagenes se encuentren disponibles. Para
    % ello, se analiza el campo "Country" de cada fila de la matriz, y se
    % busca un archivo en la carpeta "banderas" que tenga el mismo nombre y
    % extension PNG. Deben existir todos los archivos para que la funcion
    % pueda generar la imagen de salida.
    % ---------------------------------------------------------------------
    % Linea          Notas
    % ---------------------------------------------------------------------
    % 40             origen_datos.Country es una matriz de M x N, donde M
    %                es la cantidad de cadenas (paises) y N es la longitud
    %                de cada cadena. Por lo tanto, si la funcion size()
    %                devuelve [M N], es preciso tomar el primer valor.
    % 41             Los elementos 1:N de cada fila representan cada
    %                caracter de cada cadena. Por lo tanto, para leer el
    %                nombre de cada pais es preciso tomar el m-esimo valor
    %                de fila y todas (:) las columnas.
    % 42             La funcion exist(cadena,'file') devuelve 0 si no
    %                existe un archivo con el nombre "cadena".
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

    display('Ponderando datos de cada pais...');
    % PASO 3
    % Calculo la contribucion de cada pais a la poblacion total. Este valor
    % influira en el tamano de la imagen de salida y en la visibilidad de
    % cada bandera en ella.
    poblacion_total = sum(origen_datos.Population);
    ponderaciones = zeros(length(origen_datos.Population),1);
    for nro_pais = 1:1:size(origen_datos.Population,1)
        ponderaciones(nro_pais) = origen_datos.Population(nro_pais) / poblacion_total;
    end
    
    display('Preprocesando imagenes...');
    % PASO 4
    % Calculo un promedio para el tamano de las banderas. Si la funcion ha
    % llegado a este punto, significa que hay un archivo PNG por cada
    % elemento de "Country".
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
    % PASO 5
    % Genero la imagen de salida.
    imagen_salida = zeros(alto_optimo, ancho_optimo, 3,'uint8');
    for nro_pais = 1:1:size(origen_datos.Country,1)
        archivo_actual = strcat('banderas\', origen_datos.Country(nro_pais,:), '.png');       
        buffer_lectura = imread(archivo_actual);
        buffer_lectura = imresize(buffer_lectura, [alto_optimo ancho_optimo]);
        imagen_salida = imagen_salida + ponderaciones(nro_pais) * buffer_lectura;
    end
    
end

