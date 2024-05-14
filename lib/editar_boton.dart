import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:descktop/app_data.dart';
import 'package:descktop/mainmenu.dart';
import 'package:provider/provider.dart';

class EditarBoton extends StatefulWidget {
  final int id;

  EditarBoton({required this.id});

  @override
  _EditarBotonState createState() => _EditarBotonState();
}

class _EditarBotonState extends State<EditarBoton> {
  late Map<String, dynamic> inmueble = {
    'Nombre': 'Casa de Ejemplo',
    'descripcion': 'Una casa para probar la aplicación.',
    'Dirección': 'Calle Ejemplo, Ciudad',
    'Capacidad': 4,
    'Reglas': 'No fumar, no mascotas',
    'PrecioPorNoche': 50,
  };

  late Map<String, dynamic> inmuebleModificado = {};

  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    obtenerDatosInmuebleDesdeServidor();
  }

  Future<void> obtenerDatosInmuebleDesdeServidor() async {
    final appData = Provider.of<AppData>(context, listen: false);
    String numeroID = widget.id.toString();
    final String response2 = await appData.editar1(numeroID);
    final data2 = json.decode(response2);

    setState(() {
      inmueble = data2["data"];
      _imageUrls = List<String>.from(
          inmueble['urlFoto']); // Modificado para manejar múltiples imágenes
    });
  }

  Future<void> _pickImage() async {
    final appData = Provider.of<AppData>(context, listen: false);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true); // Permitir la selección de múltiples archivos

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          File fileObj = File(file.path!);
          String imageUrl = await appData.subirArchivoADrive(fileObj);
          setState(() {
            _imageUrls.add(
                imageUrl); // Agregar la URL de la imagen seleccionada a la lista
          });
        }
      }
    }
  }

  void modificarValor(String clave) async {
    TextEditingController nuevoValorController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar ${clave}'),
          content: TextField(
            controller: nuevoValorController,
            decoration: InputDecoration(hintText: 'Nuevo ${clave}'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  inmuebleModificado[clave] = nuevoValorController.text;
                  inmueble[clave] = nuevoValorController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void guardarCambios() {
    final appData = Provider.of<AppData>(context, listen: false);
    // Combina los datos originales con los datos modificados

    appData.modificarAlojamiento(
      idalojamiento: inmueble['alojamientoID'].toString(),
      capacidad: inmueble['capacidad'].toString(),
      precioPorNoche: inmueble['precioPorNoche'].toString(),
      descripcion: inmueble['descripcion'],
      nombre: inmueble['nombre'],
      reglas: inmueble['reglas'],
      urlFoto: _imageUrls,
      direccion: inmueble['direccion'],
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar Inmueble ID: ${widget.id}'),
        ),
        body: inmueble == null
            ? Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    List<Map<String, String>> elementos = [
      {'clave': 'nombre', 'texto': 'Nombre'},
      {'clave': 'descripcion', 'texto': 'Descripción'},
      {'clave': 'direccion', 'texto': 'Dirección'},
      {'clave': 'capacidad', 'texto': 'Capacidad'},
      {'clave': 'reglas', 'texto': 'Reglas'},
      {'clave': 'precioPorNoche', 'texto': 'Precio por Noche'},
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageUrls.length,
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      _imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Seleccionar Imágenes'),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: elementos.length,
            itemBuilder: (BuildContext context, int index) {
              final elemento = elementos[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Text(
                    '${elemento['texto']}: ${inmueble[elemento['clave']]}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => modificarValor(elemento['clave']!),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Acción para el botón "Descartar"
              },
              child: Text('Descartar'),
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: guardarCambios,
              child: Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
