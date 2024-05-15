import 'package:descktop/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:descktop/app_data.dart';

class VerifyPasswordScreen extends StatelessWidget {
  final String email;

  VerifyPasswordScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);
    String password1 = '';
    String password2 = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar Contraseña'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/imagenes/logo.png',
              height: 200,
              width: 200,
              fit: BoxFit.scaleDown,
            ),
            Text(
              'Verifica la contraseña para el siguiente correo:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
              onChanged: (value) {
                password1 = value;
              },
              obscureText: true,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Repetir Contraseña',
              ),
              onChanged: (value) {
                password2 = value;
              },
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (password1 == password2) {
                  print('La contraseña es: $password1');
                  appData.verificarpassword(email, password1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña Cambiada con exito')),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                } else {
                  print('Las contraseñas no coinciden');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Las Contraseñas no coinciden')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Verificar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
