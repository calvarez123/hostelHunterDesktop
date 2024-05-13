import 'dart:convert';
import 'package:descktop/app_data.dart';
import 'package:descktop/newInmueble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:descktop/editar_boton.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<DateTime> occupiedDates = [];
  List<dynamic> _inmuebles = [];
  bool _isLoading = true; // Estado para controlar si está cargando
  int pagActual = 1;
  bool _nextTrue = true;
  bool _isLoading2 = true; // Estado para controlar si está cargando

  @override
  void initState() {
    super.initState();
    _loadInmuebles(pagActual);
    _loadOccupiedDates();
  }

  void _loadOccupiedDates() {
    // Simulando la carga de un JSON que contiene intervalos de fechas
    String jsonIntervalos = '''
    {
      "occupiedIntervals": [
        {
          "start": "2024-05-01",
          "end": "2024-05-05"
        },
        {
          "start": "2024-05-10",
          "end": "2024-05-12"
        }
      ]
    }
    ''';

    var data = json.decode(jsonIntervalos);
    List<dynamic> intervals = data['occupiedIntervals'];
    for (var interval in intervals) {
      DateTime start = DateTime.parse(interval['start']).toUtc();
      DateTime end = DateTime.parse(interval['end']).toUtc();
      List<DateTime> days = getDaysInBetween(start, end);
      occupiedDates.addAll(days);
    }
    // Asegurarse de que los cambios se reflejan en el UI
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadInmuebles(int pagina) async {
    final appData = Provider.of<AppData>(context, listen: false);
    String paginaString = pagina.toString();
    int nextpage = pagina + 1;
    String paginaStringnext = nextpage.toString();

    try {
      // `await` aquí asegura que el Future se complete y obtengamos el String resultante
      final String response = await appData.pedir_info(paginaString);
      final String response2 = await appData.pedir_info(paginaStringnext);

      final data2 = json.decode(response2);
      if (data2["data"].isEmpty) {
        _nextTrue = false;
      }
      final data = json.decode(
          response); // Ahora `response` es un String y puede ser decodificado
      setState(() {
        _inmuebles = data[
            "data"]; // Asegúrate de que la clave es correcta basada en la estructura de tu JSON
        _isLoading = false; // Carga completada
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading =
            false; // Asegurar que el indicador de carga se oculte en caso de error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tus Inmuebles'),
      ),
      body: _isLoading ? _buildLoadingView() : _buildListView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(), // Widget de carga
    );
  }

  Widget _buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  alignment: Alignment.center,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _inmuebles.length,
                    itemBuilder: (context, index) {
                      var inmueble = _inmuebles[index];
                      return _buildInmuebleItem(inmueble, index);
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el botón "Anterior" solo si pagActual no es 1
            pagActual > 1
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        pagActual = pagActual - 1;
                        _nextTrue = true;
                      });

                      // Lógica para ir a la página anterior
                      _loadInmuebles(pagActual);
                    },
                    child: Text('Anterior'),
                  )
                : SizedBox
                    .shrink(), // Usar SizedBox.shrink() para no ocupar espacio si no se muestra el botón

            SizedBox(width: 10),

            // Mostrar el botón "Siguiente" solo si _nextPage es true
            _nextTrue
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        pagActual = pagActual + 1;
                      });

                      // Lógica para ir a la página siguiente
                      _loadInmuebles(pagActual);
                    },
                    child: Text('Siguiente'),
                  )
                : SizedBox
                    .shrink(), // Usar SizedBox.shrink() para no ocupar espacio si no se muestra el botón
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NewInmueble() // Pasar el id
                  ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'AÑADIR',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInmuebleItem(Map<String, dynamic> inmueble, int index) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            child: Image.network(
              inmueble['urlFoto'] ?? 'https://via.placeholder.com/200',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text('Imagen no disponible');
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre: ${inmueble['nombre']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Descripción: ${inmueble['descripcion']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Dirección: ${inmueble['direccion']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Capacidad: ${inmueble['capacidad']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Reglas: ${inmueble['reglas']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Precio Por Noche: ${inmueble['precioPorNoche']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          int numero = inmueble['alojamientoID'];
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarBoton(id: numero),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCalendarDialog(context, inmueble),
                        icon: Icon(Icons.calendar_today),
                        label: Text('Calendario'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (DateTime d = startDate;
        d.isBefore(endDate.add(Duration(days: 1)));
        d = d.add(Duration(days: 1))) {
      days.add(DateTime.utc(d.year, d.month, d.day)); // Normalize date
    }
    return days;
  }

  void _showCalendarDialog(BuildContext context,
      [Map<String, dynamic>? inmueble]) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Calendario de Reservas"),
          content: Container(
            width: 400,
            height: 400,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (occupiedDates
                      .contains(DateTime.utc(day.year, day.month, day.day))) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red, // Día ocupado en rojo
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                print("Selected day: $selectedDay");
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
