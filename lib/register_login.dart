import 'package:descktop/contrasenaPerdida.dart';
import 'package:descktop/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_data.dart';

class AuthForm extends StatelessWidget {
  final FormType formType;

  AuthForm({required this.formType});

  // Variables para almacenar los valores de los TextFormField
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  bool _isLoadingButton =
      false; // Variable para controlar el estado del botón de inicio de sesión

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);

    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(formType == FormType.login ? '' : ''),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (formType == FormType.register) ...[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: formType == FormType.login
                    ? 'Correo Electrónico'
                    : 'Correo Electrónico',
              ),
            ),
            if (formType == FormType.register) ...[
              const SizedBox(height: 16.0),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                ),
              ),
            ],
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
              obscureText: true,
            ),
            if (formType == FormType.login) ...[
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordForm(),
                    ),
                  );
                },
                child: const Text(
                  '¿Olvidaste la contraseña?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (formType == FormType.login) {
                  /*
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainMenu(),
                    ),
                  
                  );*/

                  appData
                      .iniciar_sesion(
                          emailController.text, passwordController.text)
                      .then((mensaje) {
                    if (mensaje == 'Usuario inició sesión correctamente') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenu(),
                        ),
                      );
                    } else {
                      // Limpiar campos de texto y mostrar mensaje de error
                      nameController.clear();
                      emailController.clear();
                      passwordController.clear();
                      phoneController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Conectando al servidor...')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenu(),
                        ),
                      );
                    }
                  });
                } else {
                  appData
                      .registrar(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                    phoneController.text,
                  )
                      .then((mensaje) {
                    if (mensaje == 'Usuario registrado correctamente') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenu(),
                        ),
                      );
                    } else {
                      // Limpiar campos de texto y mostrar mensaje de error
                      nameController.clear();
                      emailController.clear();
                      passwordController.clear();
                      phoneController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Conectando al servidor...')),
                      );
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor:
                    formType == FormType.login ? Colors.blue : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                formType == FormType.login ? 'Iniciar Sesión' : 'Registrarse',
                style: const TextStyle(
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

enum FormType {
  login,
  register,
}
