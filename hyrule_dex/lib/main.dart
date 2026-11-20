// ============================================================
// HYRULE DEX - APP FLUTTER QUE CONSUME HYRULE COMPENDIUM
// ============================================================
// APLICACION CON ENEMIGOS DE THE LEGEND OF ZELDA: TEARS OF THE KINGDOM
// ============================================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ------------------------------------------------------------
// DATOS GLOBALES
// ------------------------------------------------------------

// AQUI GUARDAMOS LOS FAVORITOS MIENTRAS LA APP ESTA ABIERTA
// CADA FAVORITO GUARDA EL ID, EL NOMBRE Y LA IMAGEN DEL ENEMIGO
final List<Map<String, dynamic>> favoritos = [];

// DIRECCION BASE DE LA API
const String urlApi = 'https://api.hyrule-compendium.com/v3/compendium';

// PARAMETRO PARA CONSULTAR SOLAMENTE TEARS OF THE KINGDOM
const String juego = '2';

// FUNCION PARA PONER LA PRIMERA LETRA EN MAYUSCULA
String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

// FUNCION PARA MOSTRAR LA IMAGEN DEL ENEMIGO
// SI LA API NO MANDA UNA IMAGEN, MOSTRAMOS UN ICONO EN SU LUGAR
Widget imagenEnemigo(String? url, {double alto = 60}) {
  if (url == null || url.isEmpty) {
    return Icon(Icons.shield, size: alto, color: Colors.brown);
  }

  return Image.network(
    url,
    height: alto,
    width: alto,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) =>
        Icon(Icons.shield, size: alto, color: Colors.brown),
  );
}

// ------------------------------------------------------------
// PUNTO DE ENTRADA: AQUI ARRANCA TODA LA APP
// ------------------------------------------------------------
void main() {
  runApp(const MiApp());
}

// ------------------------------------------------------------
// WIDGET PRINCIPAL
// ------------------------------------------------------------
class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyrule Dex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF477B5B),
          primary: const Color(0xFF477B5B),
          secondary: const Color(0xFF55C8B5),
          surface: const Color(0xFFE8E1CF),
        ),
        
        scaffoldBackgroundColor: const Color(0xFFE8E1CF),
          appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF172B25),
          foregroundColor: Colors.white,
        ),

        cardTheme: const CardThemeData(
          color: Color(0xFFF5F0E3),
        ),
      ),


      initialRoute: '/',
      routes: {
        '/': (context) => const PaginaInicio(),
        '/lista': (context) => const PaginaLista(),
        '/favoritos': (context) => const PaginaFavoritos(),
        '/acerca': (context) => const PaginaAcerca(),
      },
    );
  }
}

// ------------------------------------------------------------
// MENU LATERAL - SE REUSA EN TODAS LAS PANTALLAS
// ------------------------------------------------------------
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE8E1CF),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: const Color(0xFF172B25)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Hyrule Dex',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Enemy List'),
            onTap: () => Navigator.pushReplacementNamed(context, '/lista'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () => Navigator.pushReplacementNamed(context, '/favoritos'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => Navigator.pushReplacementNamed(context, '/acerca'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// PANTALLA 1: INICIO
// ------------------------------------------------------------
class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF172B25),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuLateral(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 150, color: Colors.brown),
            const SizedBox(height: 20),
            const Text(
              '¡WELCOME TO HYRULE DEX!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Explore the enemies of The Legend of Zelda: Tears of the Kingdom',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/lista'),
              icon: const Icon(Icons.search),
              label: const Text('View Enemies'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// PANTALLA 2: LISTA DE ENEMIGOS (CONSUME LA API)
// ------------------------------------------------------------
class PaginaLista extends StatefulWidget {
  const PaginaLista({super.key});

  @override
  State<PaginaLista> createState() => _EstadoLista();
}

class _EstadoLista extends State<PaginaLista> {
  List<Map<String, dynamic>> enemigos = [];
  bool cargando = true;
  String? error;
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cargarEnemigos();
  }

  // CONSULTAMOS LA CATEGORIA MONSTERS Y FILTRAMOS POR TOTK (game=2)
  Future<void> cargarEnemigos() async {
    try {
      final uri = Uri.parse('$urlApi/category/monsters')
          .replace(queryParameters: {'game': juego});
      final respuesta = await http.get(uri);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final resultados = datos['data'] as List;

        setState(() {
          enemigos = resultados.map<Map<String, dynamic>>((e) {
            return {
              'id': e['id'],
              'nombre': e['name'] ?? 'Enemy without a name',
              'imagen': e['image'],
            };
          }).toList();
          cargando = false;
        });
      } else {
        setState(() {
          error = 'The API responded with error ${respuesta.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Could not load enemies, please check your internet connection.';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = enemigos
        .where((e) => e['nombre']
            .toString()
            .toLowerCase()
            .contains(busqueda.toLowerCase()))
        .toList();

    /*final filtrados = enemigos
      .where((e) {
        String nombre = e['nombre'].toString().toLowerCase();
        String id = e['id'].toString();
        String texto = busqueda.toLowerCase().trim();
        
        return nombre.contains(texto) || id == texto;
        })
        .toList();*/

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Legend of Zelda: Tears of the Kingdom Enemies'),
        backgroundColor: const Color(0xFF172B25),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuLateral(),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search enemies...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (texto) =>
                            setState(() => busqueda = texto),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, i) {
                          final enemigo = filtrados[i];
                          return ListTile(
                            leading: imagenEnemigo(
                              enemigo['imagen'],
                              alto: 50,
                            ),
                            title: Text(capitalizar(enemigo['nombre'])),
                            subtitle: Text('ID: ${enemigo['id']}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaginaDetalle(
                                  id: enemigo['id'],
                                  nombre: enemigo['nombre'],
                                  imagen: enemigo['imagen'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ------------------------------------------------------------
// PANTALLA 3: DETALLE DE UN ENEMIGO (OTRA PETICION A LA API)
// ------------------------------------------------------------
class PaginaDetalle extends StatefulWidget {
  final dynamic id;
  final String nombre;
  final String? imagen;

  const PaginaDetalle({
    super.key,
    required this.id,
    required this.nombre,
    this.imagen,
  });

  @override
  State<PaginaDetalle> createState() => _EstadoDetalle();
}

class _EstadoDetalle extends State<PaginaDetalle> {
  Map<String, dynamic>? datos;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
  }

  // PEDIMOS LOS DATOS COMPLETOS DEL ENEMIGO POR SU ID
  Future<void> cargarDetalle() async {
    try {
      final uri = Uri.parse('$urlApi/entry/${widget.id}')
          .replace(queryParameters: {'game': juego});
      final respuesta = await http.get(uri);

      if (respuesta.statusCode == 200) {
        final resultado = json.decode(respuesta.body);
        setState(() {
          datos = resultado['data'];
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  bool get esFavorito => favoritos.any((f) => f['id'] == widget.id);

  void alternarFavorito() {
    setState(() {
      if (esFavorito) {
        favoritos.removeWhere((f) => f['id'] == widget.id);
      } else {
        favoritos.add({
          'id': widget.id,
          'nombre': widget.nombre,
          'imagen': widget.imagen,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagen = datos?['image'] ?? widget.imagen;
    final ubicaciones = datos?['common_locations'] as List? ?? [];
    final drops = datos?['drops'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalizar(widget.nombre)),
        backgroundColor: const Color(0xFF172B25),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border),
            color: Colors.white,
            onPressed: alternarFavorito,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : datos == null
              ? const Center(child: Text('The enemy details could not be loaded.'))
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        imagenEnemigo(imagen, alto: 230),
                        Text(
                          capitalizar(widget.nombre),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(datos!['description'] ??
                                    'There is no description available for this enemy.'),
                                const SizedBox(height: 16),
                                const Text(
                                  'Usual locations',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(ubicaciones.isEmpty
                                    ? 'No usual locations registered.'
                                    : ubicaciones.join(', ')),
                                const SizedBox(height: 16),
                                const Text(
                                  'Objects dropped',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(drops.isEmpty
                                    ? 'No objects registered.'
                                    : drops.join(', ')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ------------------------------------------------------------
// PANTALLA 4: FAVORITOS
// ------------------------------------------------------------
class PaginaFavoritos extends StatefulWidget {
  const PaginaFavoritos({super.key});

  @override
  State<PaginaFavoritos> createState() => _EstadoFavoritos();
}

class _EstadoFavoritos extends State<PaginaFavoritos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF172B25),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuLateral(),
      body: favoritos.isEmpty
          ? const Center(child: Text('You have no favorites yet 💔'))
          : ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, i) {
                final favorito = favoritos[i];
                return ListTile(
                  leading: imagenEnemigo(favorito['imagen'], alto: 50),
                  title: Text(capitalizar(favorito['nombre'])),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        setState(() => favoritos.removeAt(i)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaDetalle(
                        id: favorito['id'],
                        nombre: favorito['nombre'],
                        imagen: favorito['imagen'],
                      ),
                    ),
                  ).then((_) => setState(() {})),
                );
              },
            ),
    );
  }
}

// ------------------------------------------------------------
// PANTALLA 5: ACERCA DE
// ------------------------------------------------------------
class PaginaAcerca extends StatelessWidget {
  const PaginaAcerca({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: const Color(0xFF172B25),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuLateral(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 80, color: const Color(0xFF172B25)),
            SizedBox(height: 16),
            Text(
              'Development team:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            Text('Emmanuel Cruz Mora'),
            Text('Alan Campos Suarez'),
            Text('Fernanda Suarez Arias'),
            Text('Ricardo Castillo Cruz'),
            Text('Laura Jaramillo Yah'),
            SizedBox(height: 20),
            Text(
              'Data: Hyrule Compendium API',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'The Legend of Zelda: Tears of the Kingdom',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
