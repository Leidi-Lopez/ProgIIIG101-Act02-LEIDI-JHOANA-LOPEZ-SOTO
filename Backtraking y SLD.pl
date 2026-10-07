/* =========================================================
   ACTIVIDAD 02 - BACKTRACKING Y SLD
   Programación III
   Tema: Grafos, Backtracking y SLD
   ========================================================= */

/* 1. PUENTES DE KONIGSBERG */

puente(1, a, c).
puente(2, a, c).
puente(3, a, d).
puente(4, b, c).
puente(5, b, d).
puente(6, b, d).
puente(7, c, d).

conectado_puente(P, X, Y) :-
    puente(P, X, Y).
conectado_puente(P, X, Y) :-
    puente(P, Y, X).

recorrido_puentes(Inicio, Ruta) :-
    findall(P, puente(P, _, _), Todos),
    recorrer_puentes(Inicio, Inicio, Todos, [Inicio], Ruta).

recorrer_puentes(Actual, Inicio, [], Ruta, Ruta) :-
    Actual = Inicio.
recorrer_puentes(Actual, Inicio, Pendientes, RutaActual, Ruta) :-
    member(Puente, Pendientes),
    conectado_puente(Puente, Actual, Siguiente),
    delete(Pendientes, Puente, NuevosPendientes),
    recorrer_puentes(
        Siguiente, Inicio, NuevosPendientes,
        [Siguiente|RutaActual], Ruta
    ).

/* 2. GRAFO NO DIRIGIDO: RUTAS Y COSTOS */

ruta(coruna, vigo, 171).
ruta(coruna, valladolid, 485).
ruta(vigo, valladolid, 356).
ruta(oviedo, bilbao, 304).
ruta(valladolid, bilbao, 280).
ruta(valladolid, madrid, 193).
ruta(bilbao, madrid, 395).
ruta(bilbao, zaragoza, 324).
ruta(madrid, zaragoza, 325).
ruta(madrid, badajoz, 403).
ruta(madrid, jaen, 335).
ruta(madrid, albacete, 251).
ruta(madrid, valencia, 251).
ruta(zaragoza, barcelona, 296).
ruta(barcelona, gerona, 100).
ruta(barcelona, valencia, 349).
ruta(valencia, murcia, 247).
ruta(albacete, murcia, 55).
ruta(jaen, sevilla, 242).
ruta(jaen, granada, 68).
ruta(sevilla, cadiz, 125).
ruta(sevilla, granada, 256).
ruta(granada, murcia, 278).

conexion(X, Y, Costo) :- ruta(X, Y, Costo).
conexion(X, Y, Costo) :- ruta(Y, X, Costo).

camino(Origen, Destino, Camino) :-
    camino_aux(Origen, Destino, [Origen], Camino).

camino_aux(Destino, Destino, Visitados, Camino) :-
    reverse(Visitados, Camino).
camino_aux(Actual, Destino, Visitados, Camino) :-
    conexion(Actual, Siguiente, _),
    \+ member(Siguiente, Visitados),
    camino_aux(Siguiente, Destino, [Siguiente|Visitados], Camino).

costo_camino([_], 0).
costo_camino([A, B | Resto], Costo) :-
    conexion(A, B, C),
    costo_camino([B|Resto], CostoResto),
    Costo is C + CostoResto.

todas_las_rutas(Origen, Destino, Rutas) :-
    findall([Camino, Costo],
        (camino(Origen, Destino, Camino),
         costo_camino(Camino, Costo)),
        Rutas).

menor_ruta([R], R).
menor_ruta([[Camino1, Costo1]|Resto], Mejor) :-
    menor_ruta(Resto, [Camino2, Costo2]),
    ( Costo1 =< Costo2 ->
        Mejor = [Camino1, Costo1]
    ;
        Mejor = [Camino2, Costo2]
    ).

ruta_mas_corta(Origen, Destino, Camino, Costo) :-
    todas_las_rutas(Origen, Destino, Rutas),
    Rutas \= [],
    menor_ruta(Rutas, [Camino, Costo]).

/* 3. GRAFO DIRIGIDO: CANADA */

arista(vancouver, edmonton, 16).
arista(vancouver, calgary, 13).
arista(edmonton, saskatoon, 12).
arista(calgary, edmonton, 4).
arista(saskatoon, calgary, 9).
arista(calgary, regina, 14).
arista(regina, saskatoon, 7).
arista(saskatoon, winnipeg, 20).
arista(regina, winnipeg, 4).

conexion_dirigida(X, Y) :-
    arista(X, Y, _).

/* 4. REGLA PARA DETERMINAR SI UN NODO TIENE ARISTAS */

tiene_aristas(Nodo) :-
    arista(Nodo, _, _).
tiene_aristas(Nodo) :-
    arista(_, Nodo, _).

/* 5. NODOS CONECTADOS Y COSTOS */

nodos_conectados(Nodo, Lista) :-
    findall(Otro, conexion_dirigida(Nodo, Otro), Lista).

conexiones_con_costo(Nodo, Lista) :-
    findall([Destino, Costo],
            arista(Nodo, Destino, Costo),
            Lista).

/* 6. COSTO X -> Y -> Z */

costo_por(X, Y, Z, CostoTotal) :-
    arista(X, Y, Costo1),
    arista(Y, Z, Costo2),
    CostoTotal is Costo1 + Costo2.

/* 7. CAMINOS EN EL GRAFO DIRIGIDO */

camino_dirigido(Origen, Destino, Camino) :-
    camino_dirigido_aux(Origen, Destino, [Origen], Camino).

camino_dirigido_aux(Destino, Destino, Visitados, Camino) :-
    reverse(Visitados, Camino).
camino_dirigido_aux(Actual, Destino, Visitados, Camino) :-
    arista(Actual, Siguiente, _),
    \+ member(Siguiente, Visitados),
    camino_dirigido_aux(
        Siguiente, Destino, [Siguiente|Visitados], Camino
    ).

costo_camino_dirigido([_], 0).
costo_camino_dirigido([A, B | Resto], Costo) :-
    arista(A, B, C),
    costo_camino_dirigido([B|Resto], CostoResto),
    Costo is C + CostoResto.

es_posible_viajar(Origen, Destino) :-
    camino_dirigido(Origen, Destino, _).

todos_caminos_dirigidos(Origen, Destino, Resultados) :-
    findall([Camino, Costo],
        (camino_dirigido(Origen, Destino, Camino),
         costo_camino_dirigido(Camino, Costo)),
        Resultados).

camino_mas_corto_dirigido(Origen, Destino, Camino, Costo) :-
    todos_caminos_dirigidos(Origen, Destino, Resultados),
    Resultados \= [],
    menor_ruta(Resultados, [Camino, Costo]).
