PAV - P4: reconocimiento y verificación del locutor
===================================================

Obtenga su copia del repositorio de la práctica accediendo a [Práctica 4](https://github.com/albino-pav/P4)
y pulsando sobre el botón `Fork` situado en la esquina superior derecha. A continuación, siga las
instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para crear una rama con el apellido de
los integrantes del grupo de prácticas, dar de alta al resto de integrantes como colaboradores del proyecto
y crear la copias locales del repositorio.

También debe descomprimir, en el directorio `PAV/P4`, el fichero [db_8mu.tgz](https://atenea.upc.edu/mod/resource/view.php?id=3654387?forcedownload=1)
con la base de datos oral que se utilizará en la parte experimental de la práctica.

Como entrega deberá realizar un *pull request* con el contenido de su copia del repositorio. Recuerde
que los ficheros entregados deberán estar en condiciones de ser ejecutados con sólo ejecutar:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  make release
  run_spkid mfcc train test classerr verify verifyerr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recuerde que, además de los trabajos indicados en esta parte básica, también deberá realizar un proyecto
de ampliación, del cual deberá subir una memoria explicativa a Atenea y los ficheros correspondientes al
repositorio de la práctica.

A modo de memoria de la parte básica, complete, en este mismo documento y usando el formato *markdown*, los
ejercicios indicados.

## Ejercicios.

### SPTK, Sox y los scripts de extracción de características.

- Analice el script `wav2lp.sh` y explique la misión de los distintos comandos involucrados en el *pipeline*
  principal (`sox`, `$X2X`, `$FRAME`, `$WINDOW` y `$LPC`). Explique el significado de cada una de las 
  opciones empleadas y de sus valores.
  
  * `sox` nos permite transformar una señal de entrada sin cabecera a una del fromato indicado. También nos permite transformar las  señales guradadas en un programa externo. Al fiechero de entrada se le pueden aplicar las siguientes opciones:
  
    - `-t`: Formato de audio.
    - `e`: Referente a la codificación que queremos aplicar (signed-integer, unsigned-integer, etc.). 
    - `b`: Indica el numero de bits por muestra.
    - `-`: Redirección del output hacia el pipeline.

  * `$X2X`:Permite la conversión entre distintos formatos de datos. Por ejemplo pasar de un formato short (2 bytes) a un formato float (4 bytes) con la opcion `"+sf"` 
  
  * `$FRAME`:Extrae o divide la señal de entrada en tramas, indicando  la longitud del segmento en la que divide las muestras y el periodo de desplazamiento entre ellas. También se puede indicar si el punto de comienzo esta centrado o no.
  
    - `-l`: Número de muestras de cada trama. Su valor máximo es de 256.
    - `-p`: Número de muestras de desplazamineto. Su valor máximo es de 100.

  * `$WINDOW`:Pondera cada trama por una ventana.
  
    - `-l`: Tamaño de la ventana en su input. Su valor máximo es 256.
    - `-L`: Tamaño de la ventana en su output. Su valor máximo es 256.
    
  * `$LPC`:Calcula los coeficientes de predicción lineal (LPC) de cada trama enventanada del fichero de entrada. Tanto la señal de entrada como la señal de salida tienen un formato float.
    - `-l`: Longitud de trama. Máximo 256.
    - `-m`: Númerode coeficientes LPC. Cmomo mucho 25.
    - `-f`: Valor mínimo del determinante. Como mucho 10^-6.
    - "output_file" : Fichero de salida
  
  En el script wav2lp.sh encontramos el siguiente pipeline principal:
  
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$LPC -l 240 -m $lpc_order > $base.lp
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


- Explique el procedimiento seguido para obtener un fichero de formato *fmatrix* a partir de los ficheros de
  salida de SPTK (líneas 45 a 51 del script `wav2lp.sh`).
  
  
Para conseguir la matriz fmatrix necesitamos calcular el número  de filas ($nrow) y columnas ($ncol), las columnas las calculamos con el orden del predictor y les sumamos 1($lpc_order+1) debido ya que en el primer elemento del vector de predicción se almacena la ganancia del predictor. Para determinar el número de filas, hemos de tener en cuenta la longitud de la señal y la lomgitud y desplazamiento de ventana que le aplicamos a dicha señal. Utilianzo el comando `sox` transformamos los datos del tipo float al tipo ascii y finalmente contamos las líneas con el comando <code>wc-1</code> e imprimimos en pantalla, separando filas y columnas con un salto de línea usando <code>perl -ne</code>.

En el script wav2lp.sh encontramos el siguiente pipeline principal:

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
# Our array files need a header with the number of cols and rows:
ncol=$((lpc_order+1)) # lpc p =>  (gain a1 a2 ... ap) 
nrow=`$X2X +fa < $base.lp | wc -l | perl -ne 'print $_/'$ncol', "\n";'`

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.lp >> $outputfile
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  

  * ¿Por qué es más conveniente el formato *fmatrix* que el SPTK?
  
  *fmatrix* nos permite pasarle un fichero de datos (en nuestro caso     "base.lp") y nos lo "ordena" como float en "nrow" filas y "ncol"       columnas.
  De esta forma, con <code>fmatrix_show</code> podremos ver los datos de   forma sencilla, y situarnos en la posición de la matriz que nos         interesa sabiendo el número del audio para encontrar los coeficientes   de este, que en nuestro caso son los coeficientes 2 y 3.

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales de predicción lineal
  (LPCC) en su fichero <code>scripts/wav2lpcc.sh</code>:
  
   Main command for feature extration
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$LPC -l 240 -m $lpc_order | $LPCC -m $lpc_order -M $lpcc_order > $base.lpcc
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales en escala Mel (MFCC) en su
  fichero <code>scripts/wav2mfcc.sh</code>:
  
  Main command for feature extration
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 180 -p 100 | $WINDOW -l 180 -L 180 |
	$MFCC -s $fm -l 180 -m $mfcc_order -n $melbank_order > $base.mfcc
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Extracción de características.

- Inserte una imagen mostrando la dependencia entre los coeficientes 2 y 3 de las tres parametrizaciones
  para todas las señales de un locutor.
  
  + Indique **todas** las órdenes necesarias para obtener las gráficas a partir de las señales 
    parametrizadas.
    
    - Orden para obtener el fichero de texto LP:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
      fmatrix_show work/lp/BLOCK01/SES017/*.lp | egrep '^\[' | cut -f4,5 > lp_2_3.txt
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    - Orden para obtener el fichero de texto LPCC:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
      fmatrix_show work/lpcc/BLOCK01/SES017/*.lpcc | egrep '^\[' | cut -f4,5 > lpcc_2_3.txt
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    - Orden para obtener el fichero de texto MFCC:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
      fmatrix_show work/mfcc/BLOCK01/SES017/*.mfcc | egrep '^\[' | cut -f4,5 > mfcc_2_3.txt
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    A partir de los fichers generados, representamos las gráficas a aprtir de siguente código python:
    
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
    import matplotlib.pyplot as plt

    # LP
    X, Y = [], []
    for line in open('lp_2_3.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(1)
    plt.plot(X, Y, 'rx', markersize=4)
    plt.savefig('lp_2_3.png')
    plt.title('LP',fontsize=20)
    plt.grid()
    plt.xlabel('a(2)')
    plt.ylabel('a(3)')
    plt.savefig('lp_2_3.png')
    plt.show()

    # LPCC
    X, Y = [], []
    for line in open('lpcc_2_3.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(2)
    plt.plot(X, Y, 'rx', markersize=4)
    plt.savefig('lpcc_2_3.png')
    plt.title('LPCC',fontsize=20)
    plt.grid()
    plt.xlabel('c(2)')
    plt.ylabel('c(3)')
    plt.savefig('lpcc_2_3.png')
    plt.show()

    # MFCC
    X, Y = [], []
    for line in open('mfcc_2_3.txt', 'r'):
      values = [float(s) for s in line.split()]
      X.append(values[0])
      Y.append(values[1])
    plt.figure(3)
    plt.plot(X, Y, 'rx', markersize=4)
    plt.savefig('mfcc_2_3.png')
    plt.title('MFCC',fontsize=20)
    plt.grid()
    plt.xlabel('mc(2)')
    plt.ylabel('mc(3)')
    plt.savefig('mfcc_2_3.png')
    plt.show()
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  + ¿Cuál de ellas le parece que contiene más información?

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los
  parámetros 2 y 3 para un locutor, y rellene la tabla siguiente con los valores obtenidos.

  |                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | &rho;<sub>x</sub>[2,3] |      |      |      |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.

- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.

### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.

### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
 
### Test final

- Adjunte, en el repositorio de la práctica, los ficheros `class_test.log` y `verif_test.log` 
  correspondientes a la evaluación *ciega* final.

### Trabajo de ampliación.

- Recuerde enviar a Atenea un fichero en formato zip o tgz con la memoria (en formato PDF) con el trabajo 
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como 
  resultado del mismo.
