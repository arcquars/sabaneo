import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/login/presentation/form/form_login.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDrawer extends StatelessWidget {
  final String userRole;
  const AuthDrawer({super.key, required this.userRole});


  Future<void> _logout(BuildContext context) async {
    // Obtén una instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Elimina la variable "userToken"
    final success = await prefs.remove('isLoggedIn');
    final successToken = await prefs.remove('token');

    if (success && successToken) {
      log('Sesión cerrada y "userToken" eliminada.');
      
      Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => FormLogin()), // ✅ Redirige a HomeScreen
        );
    } else {
      log('Error al cerrar la sesión.');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFe8a63f)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    '${userProvider.name}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    '${userProvider.role}',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ..._getMenuItems(context, userRole)
            
          ],
        ),
      );
  }

  // 🔹 Define los ítems del menú según el rol
  List<Widget> _getMenuItems(BuildContext context, String role) {
    List<Widget> startItems = [
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text("Inicio"),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Perfil"),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(FontAwesomeIcons.users),
        title: const Text("Clientes"),
        onTap: () => Navigator.pushNamed(context, "/customer-list"),
      ),
    ];

    List<Widget> endItems = [
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Configuración'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('Cerrar sesión'),
        onTap: () {
          _logout(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesión cerrada')),
          );
        },
      ),
    ];

    List<Widget> adminItems = [
      ListTile(
        leading: const Icon(Icons.admin_panel_settings),
        title: const Text("Panel de Admin"),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("Configuraciones"),
        onTap: () => Navigator.pop(context),
      ),
    ];

    List<Widget> salesmanItems = [
      ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: const Text("Mis ventas"),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        leading: const Icon(Icons.map_outlined),
        title: const Text("Mis rutas de ventas"),
        onTap: () => Navigator.pushNamed(context, "/sales-route"),
      ),
    ];

    List<Widget> deliveryItems = [
      ListTile(
        leading: const Icon(Icons.shopping_cart),
        title: const Text("Mis entregas"),
        onTap: () => Navigator.pop(context),
      ),
    ];

    List<Widget> finalItems;

    switch(role){
      case 'Administrador':
        finalItems = adminItems;
        break;
      case 'Vendedor':
        finalItems = salesmanItems;
        break;
      default:
        finalItems = deliveryItems;
        break;
    }

    return [
      ...startItems,
      ...finalItems, // 🔹 Agrega menú según el rol
      ...endItems,
      ];
  }

}
