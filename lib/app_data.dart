import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AppData extends ChangeNotifier {
  String serverUrl = '';

  String username = '';
  String password = '';
  bool waitingResponse = false;
  bool responseArrived = false;
  bool showPopup = false;
  bool updateSuccesfull = false;
  bool validate = false;
  int idUsuario = 0;
  late List<Map<String, dynamic>> users = [];
  //  =[
  //      {'id': '1', 'name': 'Usuario 1', 'phoneNumber': '123456789', 'isPremium': true},
  //      {'id': '2', 'name': 'Usuario 2', 'phoneNumber': '987654321', 'isPremium': false},];
  late List<Map<String, dynamic>> changes = [];

  AppData() {
    _loadUrlFromStorage(); // Llama a _loadUrlFromStorage() al iniciar
  }

  Future<void> _loadUrlFromStorage() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/url.txt');
      if (await file.exists()) {
        serverUrl = "192.168.0.122:8889";
        notifyListeners(); // Notificar a los listeners sobre el cambio en la URL
      }
    } catch (e) {
      print('Error reading URL: $e');
    }
  }

  Future<String> registrar(
      String nombre, String email, String contra, String telefono) async {
    try {
      Map<String, dynamic> body = {
        "nombre": "$nombre",
        'email': "$email",
        'contraseña': "$contra",
        'telefono': "$telefono",
        'tipo': 'propietario'
      };
      String bodyEncoded = jsonEncode(body);

      final response = await http.post(
        Uri.parse('https://hostelhunter.ieti.site/api/usuari/registrar'),
        headers: {
          "Content-Type": "application/json"
        }, // Asegúrate de enviar el header correcto
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        print('Usuario registrado correctamente');
        print(response.body);
        return 'entras';
      } else {
        // Manejo de errores basado en el estado de la respuesta
        print('Error al registrar usuario: ${response.statusCode}');
        print(response.body);
        return 'no';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud: $e';
    }
  }

  Future<String> editar1(String id) async {
    try {
      Map<String, dynamic> body = {"id": "$id"};
      String bodyEncoded = jsonEncode(body);

      final response = await http.post(
        Uri.parse('https://hostelhunter.ieti.site/api/pedir/alojamiento'),
        headers: {
          "Content-Type": "application/json"
        }, // Asegúrate de enviar el header correcto
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Manejo de errores basado en el estado de la respuesta
        print('Error al registrar usuario: ${response.statusCode}');
        print(response.body);
        return 'no';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud: $e';
    }
  }

  Future<String> iniciar_sesion(String email, String contra) async {
    try {
      Map<String, dynamic> body = {
        "email": email,
        'contraseña': contra,
        'tipo': 'propietario'
      };
      String bodyEncoded = jsonEncode(body);

      final response = await http.post(
        Uri.parse('https://hostelhunter.ieti.site/api/usuari/login'),
        headers: {
          "Content-Type": "application/json"
        }, // Asegúrate de enviar el header correcto
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        print('Usuario inició sesión correctamente');
        print(response.body);
        final data2 = json.decode(response.body);
        idUsuario = data2["data"]["id"];

        return 'entras';
      } else {
        // Manejo de errores basado en el estado de la respuesta
        print('Error al iniciar sesión: ${response.statusCode}');
        print(response.body);
        return 'no';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud: $e';
    }
  }

  Future<String> pedir_info(String pagina) async {
    try {
      // Construimos la URL
      var url =
          Uri.parse('https://hostelhunter.ieti.site/api/flutter/informacion');

      print('Enviando email');

      // Creamos el cuerpo de la solicitud con el email
      var body = {
        'page': pagina,
        'size': '2', // Aquí asumimos que aún necesitas enviar 'size'
        'email': 'cristian@example.com',
      };
      String bodyEncoded = jsonEncode(body);

      // Realizamos una solicitud POST
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        print('Email enviado correctamente');

        return response.body.toString();
      } else {
        // Manejo de errores basado en el estado de la respuesta
        print('Error al enviar email: ${response.statusCode}');
        print(response.body);
        return 'no';
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return 'Error en la solicitud: $e';
    }
  }

  forcenotify() {
    notifyListeners();
  }

  Future<void> enviarMensaje(String url, String mensaje) async {
    try {
      // Realizar la solicitud HTTP POST
      var respuesta = await http.post(
        Uri.parse(url),
        body: {
          "nombre": "133122",
          'email': "alex",
          'contraseña': "alex",
          'telefono': "alex",
        },
      );

      // Verificar el estado de la respuesta
      if (respuesta.statusCode == 200) {
        // Imprimir la respuesta del servidor
        print('Respuesta del servidor: ${respuesta.body}');
      } else {
        // Si la solicitud falla, imprimir el estado de la respuesta
        print('Error en la solicitud: ${respuesta.statusCode}');
      }
    } catch (e) {
      // Si ocurre una excepción, imprimir el error
      print('Error: $e');
    }
  }

  Future<String> subirArchivoADrive(File archivo) async {
    var client = http.Client();
    try {
      var credentials = auth.ServiceAccountCredentials.fromJson(r'''
    {
      "private_key_id": "20d20209617c48910554caf7fce9507a99b93378",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC0Zt7VXfHs0OPH\n9BhX2vYdVbQPSZHTPTMm2OxKUy1kctu1z8GJrDqCrgnQe/ItTCcEIvDxD9gghaQM\nmTWjclcmOqFc8G9iZteZQ6OSGgqxFd3a3YPNpLUPfYKEZqVvYzLhRy0gsNzaBlPw\nIbKl3pBjxLFLL0j3JD13kb60o0m4B1psE2IyKoFvMdq8Uu6hTYFuY3Y2lgE4mIma\nOMq6+Tan9iVkbISogBhi78d4kXasBy1ZKj+OajjlUtskR54MvW72/3F5EyERjqHw\n5EQc5TQmR6EUVn8iOD6ct2dkBInVfTKHbJG3E7sgEuCcQeozUMX3V3/RTUtGf9JZ\nUvPCgFALAgMBAAECggEAC1QCXieeD3Q2jtHMeDKEYzyEfV6Yokkk3dBKq4gkQOXY\nLMc1AgN8pm7DUwIq0klb5y3tL1YCs61wqxHb2mhNrKrggx4zVbHbjADr/pAAEoqq\n+cQQiL31A1oASMwhS1NRWJrIQgCZKF+0BE+Ou6Je3W+hKnV3rCfsbDEMu/nHoUn0\nVGbdtbMvvEmZanlLapdp1701ntWvUO4p3SRxdQ7txFPZqlmpnjOCVSoglqJF+hMv\nZ1OoLh2h1aw5Y6cdvCUalaBfLEkHh2utgezorUn48QRTlT25DUY5M3ZPdE0ygOGX\nnfEMVPpOItOjvpWlWTS0PhvQbBCm4O+BpuuuvTZr4QKBgQD3N47m9h+ks8lA3fyj\nC3Ow6CJ54bohQXbofYUdWPlewpphhqmcWe3zThTVdLY04Ha8OYcX6zqG1i+tEP2J\nGry8OFoG2qCW3GjlTcrzp6wbDosugff1TWSGvYL3v0zjFJeMFUXaGRnxa3dK+X6n\ngXCff6I/RuDzYMm4D1/5gq3gswKBgQC6z6CXe4UnVFpvusCXkTIpfaU4ITq1oHKy\nctv9vjTqkAj9VR1wwTWXCwoc+Rp2UTG2mNUTNNgHcxQklg6mjeGXVBbfZtKD4EOp\noGs5Li82rtGaFDdpwPdP7IGD19oa6J7Jb1TQ3wuiUhY4T/EXDk+d764LbInvtOBI\nlddBMRxPSQKBgFyN2Fpv2vj2tmoqseL47p9UyVOIRv8cW0A/fg62uOXZRaMtn2KB\n6Kwml3Yy8+RoBQwDHai+0HKazc6lhcZG1FJDZrEaOPVCH6N5tHn0VGLs1v7aedLE\n3tXzLY1Dea2qj/JKJJS6wRO5gDf5oIll1JxiVIQMLTvxCJR4bR4k5qQxAoGAQgfz\nzreVaEJzuPx86NYkse+8f6uXMe3lvNfGlNkvoR2KX+k+/8T7aUk4qOcQCHRIqy84\nWZKbLX7qxsfXo92QuMm7T/nrPTv/Dq0qWUrO23hNlDXDJHlVsYV6fhzE9i/1OGRG\nyZGdbiGvwvXW1Px0/fFjRpx14SnBAUcdj+iJBikCgYEAvxdEoYs4aswBdkZgtWct\nkfMxGpCwprIuVn+MURlhxmAYrOcUimUQMb5jmHQxEDa2fUtb6/POMQKGNj737Uh4\n6BOa5f/5ybRVlxO6NWAAtBDgru+DpQ1DfcqPsj5NsP4bA5CNxjCgVBLzU5rI6dGy\n7QRr+j05/HSyZmZAhU283WM=\n-----END PRIVATE KEY-----\n",
      "client_email": "proyectodual@dual-421316.iam.gserviceaccount.com",
      "client_id": "114276124345954002816",
      "type": "service_account"
    }
    ''');

      var scopes = [drive.DriveApi.driveScope];
      var authClient = await auth.clientViaServiceAccount(credentials, scopes,
          baseClient: client);

      var apiDrive = drive.DriveApi(authClient);
      var archivoDrive = drive.File();
      archivoDrive.name = path.basename(archivo.path);
      archivoDrive.parents = ['1rvghI05yWVkhF24trC-rRW0ihLbVbb-j'];

      var respuesta = await apiDrive.files.create(archivoDrive,
          uploadMedia: drive.Media(archivo.openRead(), archivo.lengthSync()));

      // Cambio de permisos a cualquier persona con el enlace
      var permiso = drive.Permission();
      permiso.type = 'anyone';
      permiso.role = 'reader';
      await apiDrive.permissions.create(permiso, respuesta.id!);

      // Construir y devolver la URL en formato "export view"
      var urlExportacion =
          "https://drive.google.com/uc?export=view&id=${respuesta.id}";
      return urlExportacion;
    } finally {
      client.close();
    }
  }

  Future<String> crearAlojamiento({
    required int idusuario,
    required String capacidad,
    required String precioPorNoche,
    required String descripcion,
    required String nombre,
    required String reglas,
    required String urlFoto,
    required String direccion,
  }) async {
    try {
      final url = Uri.parse(
          'https://hostelhunter.ieti.site/api/meter/alojamiento'); // Asegúrate de que la URL es correcta
      Map<String, dynamic> body = {
        "id": idusuario,
        "capacidad": capacidad,
        "preciopornoche": precioPorNoche,
        "descripcion": descripcion,
        "nombre": nombre,
        "reglas": reglas,
        "url": urlFoto,
        "direccion": direccion,
      };
      String bodyEncoded = jsonEncode(body);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        print("Alojamiento creado correctamente");
        return response
            .body; // Puedes decidir retornar el mensaje completo o parsear el JSON para extraer información específica
      } else {
        print("Error al crear alojamiento: ${response.statusCode}");
        print(bodyEncoded);
        return 'Error: No se pudo crear el alojamiento';
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 'Error en la solicitud: $e';
    }
  }

  Future<String> modificarAlojamiento({
    required String capacidad,
    required String precioPorNoche,
    required String descripcion,
    required String nombre,
    required String reglas,
    required String urlFoto,
    required String direccion,
    required String idalojamiento,
  }) async {
    try {
      final url = Uri.parse(
          'https://hostelhunter.ieti.site/api/editar/alojamiento'); // Asegúrate de que la URL es correcta
      Map<String, dynamic> body = {
        "alojamientoID": idalojamiento,
        "capacidad": capacidad,
        "precioPorNoche": precioPorNoche,
        "descripcion": descripcion,
        "nombre": nombre,
        "reglas": reglas,
        "url": urlFoto,
        "direccion": direccion,
      };

      String bodyEncoded = jsonEncode(body);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyEncoded,
      );

      if (response.statusCode == 200) {
        print("Alojamiento creado correctamente");
        return response
            .body; // Puedes decidir retornar el mensaje completo o parsear el JSON para extraer información específica
      } else {
        print("Error al crear alojamiento: ${response.statusCode}");
        return 'Error: No se pudo crear el alojamiento';
      }
    } catch (e) {
      print("Error en la solicitud: $e");
      return 'Error en la solicitud: $e';
    }
  }
}
