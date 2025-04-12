import 'package:flutter/material.dart';
import 'package:sabaneo_2/login/presentation/form/form_login.dart';
import 'package:sabaneo_2/views/register_screen.dart';

class GuestDrawer extends StatelessWidget {
  const GuestDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFe8a63f)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Iniciar Sesion'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FormLogin()),);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Registrarse'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()),);
              },
            ),
          ],
        ),
      );
  }
}
