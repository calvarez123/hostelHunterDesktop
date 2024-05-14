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
  File? _image;

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _image = file;
      });
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

    String imageUrl = 'No Image Selected';
    if (_image != null) {
      imageUrl = await appData.subirArchivoADrive(_image!);
    }

    appData
        .crearAlojamiento(
      capacidad: _capacidadController.text,
      precioPorNoche: _precioNocheController.text,
      descripcion: _descripcionController.text,
      nombre: _nombreController.text,
      reglas: _reglasController.text,
      urlFoto: imageUrl,
      direccion: _direccionController.text,
      idusuario: appData.idUsuario,
    )
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

    _image = null;
    _nombreController.clear();
    _descripcionController.clear();
    _direccionController.clear();
    _capacidadController.clear();
    _reglasController.clear();
    _precioNocheController.clear();

    // Print the image URL or a no-image placeholder message
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
                  if (_image != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Cargar Imagen'),
                  ),
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
                        style: ElevatedButton.styleFrom(),
                      ),
                      ElevatedButton(
                        onPressed:
                            _addProperty, // Call the function to add property and check fields
                        child: Text('Añadir'),
                        style: ElevatedButton.styleFrom(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
