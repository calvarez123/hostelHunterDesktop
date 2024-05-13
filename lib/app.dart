import 'package:descktop/admin_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'login_page.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<AppData>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: AdminMenu(),
      home: appData.validate ? AdminMenu() : LoginPage(),
    );
  }
}
