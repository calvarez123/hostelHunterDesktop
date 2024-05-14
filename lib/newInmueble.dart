import 'dart:convert';
import 'dart:io';
import 'package:descktop/app_data.dart';
import 'package:descktop/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class NewInmueble extends StatefulWidget {
  @override
  _NewInmuebleState createState() => _NewInmuebleState();
}

class _NewInmuebleState extends State<NewInmueble> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _reglasController = TextEditingController();
  final TextEditingController _precioNocheController = TextEditingController();
  List<String> _imageUrls = [];

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

  Future<void> _addProperty() async {
    final appData = Provider.of<AppData>(context, listen: false);

    // Check if all fields are filled except the image
    if (_nombreController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _direccionController.text.isEmpty ||
        _capacidadController.text.isEmpty ||
        _reglasController.text.isEmpty ||
        _precioNocheController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Tienes que llenar todos los campos"),
          actions: <Widget>[
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
            ),
          ],
        ),
      );
      return;
    }

    appData
        .crearAlojamiento(
            capacidad: _capacidadController.text,
            precioPorNoche: _precioNocheController.text,
            descripcion: _descripcionController.text,
            nombre: _nombreController.text,
            reglas: _reglasController.text,
            urlFoto: _imageUrls,
            direccion: _direccionController.text,
            idusuario: appData.idUsuario)
        .then((response) {
      Map<String, dynamic> jsonResponse = jsonDecode(response);

      // Verificar el estado de la respuesta
      if (jsonResponse['status'] == 'OK') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Éxito"),
            content: Text("Se ha creado el alojamiento."),
            actions: <Widget>[
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                  setState(() {
                    _imageUrls.clear(); // Vaciar la lista de URLs de imágenes
                  });
                },
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Error"),
            content: Text("No se pudo agregar el alojamiento."),
            actions: <Widget>[
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainMenu()),
                  );
                },
              ),
            ],
          ),
        );
      }
    });

    _nombreController.clear();
    _descripcionController.clear();
    _direccionController.clear();
    _capacidadController.clear();
    _reglasController.clear();
    _precioNocheController.clear();
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
          title: Text('Nuevo Inmueble'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _direccionController,
                  decoration: InputDecoration(labelText: 'Dirección'),
                ),
                TextField(
                  controller: _capacidadController,
                  decoration: InputDecoration(labelText: 'Capacidad'),
                ),
                TextField(
                  controller: _reglasController,
                  decoration: InputDecoration(labelText: 'Reglas'),
                ),
                TextField(
                  controller: _precioNocheController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio por Noche'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Discard and go back
                      },
                      child: Text('Descartar'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _addProperty, // Call the function to add property and check fields
                      child: Text('Añadir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
