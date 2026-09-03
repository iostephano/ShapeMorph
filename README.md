# ShapeMorph — Morphing entre figuras 2D con Core Graphics

ShapeMorph es una app de iOS que anima transiciones suaves entre seis figuras
(cuadrado, rectángulo, rombo, círculo, corazón y estrella). Cada figura se
representa con el mismo número de puntos repartidos por igual a lo largo de su
perímetro; al elegir otra figura, la app empareja los puntos de la actual con los
de la nueva de la mejor forma posible y luego interpola entre ambos conjuntos frame
a frame. Existe como proyecto de portafolio para mostrar cómo se combinan muestreo
por longitud de arco, emparejamiento de puntos y render en tiempo real para conseguir
un morphing limpio, con esa geometría separada del UIKit y cubierta por pruebas.

---

## Tecnologías usadas

- Swift 6 (con verificación estricta de concurrencia activada)
- UIKit, construido por código (sin Storyboards)
- Core Graphics / `UIBezierPath` para el render
- `CADisplayLink` para la animación por frames
- Swift Testing para las pruebas
- Integración continua con GitHub Actions (compila y corre los tests en cada push/PR)
- Cero dependencias externas

---

## Cómo está organizado el proyecto

```
ShapeMorph/
├── AppDelegate.swift / SceneDelegate.swift   # Arranque; SceneDelegate crea el ViewController
├── Controllers/
│   └── ViewController.swift                  # La vista de morphing + una fila de botones
├── Views/
│   └── MorphingView.swift                    # Estado de la animación y dibujo con UIBezierPath
└── Shapes/
    ├── Shape.swift                           # Las seis figuras y su título
    ├── ShapeLibrary.swift                    # Genera cada figura y la remuestrea por longitud de arco
    └── Morph.swift                           # Emparejamiento de puntos e interpolación
```

`ShapeLibrary` y `Morph` no importan UIKit: son geometría pura sobre `CGPoint`.
`MorphingView` solo lleva el progreso de la animación y dibuja el resultado.

---

## Cómo funciona / flujo principal

1. `ShapeLibrary` genera cada figura como una lista de vértices (densa para las
   curvas) y la **remuestrea a 64 puntos equiespaciados por longitud de arco**, de
   modo que todas las figuras tienen la misma cantidad y densidad de puntos. La
   estrella usa un remuestreo que además fija sus 10 vértices, para que las puntas no
   salgan romas.
2. Al tocar un botón, `MorphingView.setTarget(_:)` congela la figura que se ve en ese
   instante y pide los puntos de la figura destino.
3. `Morph.aligned(_:to:)` reordena los puntos de la figura de partida: prueba los 64
   desplazamientos cíclicos y los dos sentidos de giro, y se queda con el que
   minimiza la suma de distancias al cuadrado frente al destino. Así el punto de una
   esquina no se empareja con un punto del lado opuesto y la figura **no gira**
   durante la transición.
4. Un `CADisplayLink` avanza el progreso según el tiempo transcurrido; cada frame
   `Morph.interpolate(from:to:progress:)` calcula la figura intermedia (con un
   suavizado *ease-in-out*) y `MorphingView` la dibuja con un `UIBezierPath` relleno.
5. Al llegar a 1, la figura de partida pasa a ser la de destino y el `CADisplayLink`
   se detiene.

---

## Funcionalidades / qué demuestra

- Remuestreo de cualquier contorno a un número fijo de puntos equiespaciados por
  longitud de arco.
- Emparejamiento de puntos entre dos figuras por búsqueda del desplazamiento cíclico
  y el sentido de giro óptimos (la parte de "álgebra lineal" del morphing).
- Interpolación lineal punto a punto con suavizado, dirigida por tiempo.
- `CADisplayLink` con el ciclo de vida atado a la ventana, para no dejar el timer
  corriendo ni retener la vista.
- Geometría aislada de UIKit y cubierta por pruebas.

---

## Pruebas

`ShapeMorphTests` (Swift Testing):

- **`ShapeLibrary`**: cada figura se representa con exactamente 64 puntos; su caja
  contenedora queda centrada en el lienzo y dentro de él; ningún hueco entre puntos
  consecutivos pasa de 1.5x la media (antes el corazón y la estrella no pasaban por el
  remuestreo y dejaban huecos varias veces mayores). Además: `resample` conserva la
  cantidad pedida, arranca en el primer vértice y produce huecos idénticos en un
  cuadrado; el remuestreo con vértices fijos conserva todos los vértices de entrada; y
  la estrella mantiene sus 5 picos exteriores y 5 interiores tras el remuestreo.
- **`Morph.aligned`**: alinear listas idénticas no cambia nada; la alineación nunca
  empeora el coste de emparejamiento y para cuadrado→círculo lo mejora de verdad;
  recupera un desplazamiento cíclico y un giro invertido del destino; con longitudes
  distintas cae al destino.
- **`Morph.interpolate`**: progreso 0 / 1 / 0.5 dan inicio / fin / punto medio; el
  progreso se recorta a 0...1.
- **`Morph.easeInOut`**: fija extremos y punto medio, monótona, recorta fuera de rango.

Correr los tests:

```bash
xcodebuild test \
  -project ShapeMorph.xcodeproj \
  -scheme ShapeMorph \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Cómo correr el proyecto

1. Clona el repo:
   ```bash
   git clone https://github.com/iostephano/ShapeMorph.git
   ```
2. Abre `ShapeMorph.xcodeproj` con **Xcode 26** (ver `.xcode-version`).
3. El objetivo mínimo es **iOS 26**. Elige un simulador de iPhone o un dispositivo y
   ejecuta (Cmd-R).
4. Toca cualquiera de los seis botones para morfar la figura actual hacia esa.

---

## Cosas pendientes o limitadas (a propósito)

- **El emparejamiento de puntos es global, no elástico.** Se elige un único
  desplazamiento y sentido para toda la figura; no se reparametriza cada tramo. Para
  estas seis figuras convexas (y el corazón) basta; con formas muy cóncavas o con
  agujeros haría falta algo más.
- **La figura se dibuja como polígono de 64 lados**, sin curvas Bézier reales. A este
  tamaño no se nota, pero un círculo es en realidad un polígono de 64 lados.
- **El lienzo es de 300x300 puntos fijos** y centrado; las figuras no se adaptan al
  tamaño de pantalla más allá de eso.
- **Sin control del progreso**: la animación dura 0.6 s y no hay slider ni forma de
  pausarla a medio camino.
- **Solo color de relleno**: no se anima el color ni el trazo durante la transición.

---

## Autor

Stephano Portella
