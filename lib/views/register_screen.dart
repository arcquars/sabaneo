import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sabaneo_2/main.dart';
import 'package:sabaneo_2/models/store_model.dart';
import 'package:sabaneo_2/models/user_register_model.dart';
import 'package:sabaneo_2/services/store_service.dart';
import 'package:sabaneo_2/services/user_service.dart';
import 'package:sabaneo_2/utils/sabaneo_input_decoration.dart';

class RegisterScreen extends StatefulWidget {
    const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final StoreService _storeService = StoreService();
  final UserService _userService = UserService();

  Map<String, dynamic> _errores = {};

  // final List<String> _options = ['Opción 1', 'Opción 2', 'Opción 3'];
  List<Store>? _stores;
  List<String>? _roles; 

  String? _selectedOption;
  String? _selectedRol;

  // UserRegister? _userRegister;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchRoles();
  }

  Future<void> _fetchUsers() async {
    List<Store>? stores = await _storeService.getStores();
    setState(() {
      _stores = stores;
    });
  }

  Future<void> _fetchRoles() async {
    List<String>? roles = await _userService.getRoles();
    setState(() {
      _roles = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Row(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
            children: [
              FaIcon(FontAwesomeIcons.store), // Icono a la izquierda
              SizedBox(width: 8), // Espaciado entre icono y texto
              Text('SABANEO'),
            ],
          ),
          centerTitle: true, // Opcional: Centrar el título
          backgroundColor: Color(0xFFFD7E14),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Ingrese su usuario", icon: Icons.person_2_sharp, errorText: _errores['username']?.join(', ')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El nombre de usuario es obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  // decoration: const InputDecoration(hintText: "Ingrese su nombre"),
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Ingrese sus nombres", icon: Icons.person_2_outlined, errorText: _errores['names']?.join(', ')),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El nombre es obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Ingrese su email", icon: Icons.email_outlined, errorText: _errores['email']?.join(', ')),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El email es obligatorio";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Ingrese un email válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Ingrese su numero de celular", icon: Icons.mobile_screen_share_outlined, errorText: _errores['phone']?.join(', ')),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El phone es obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Rol", icon: Icons.store_outlined),
                  value: _selectedRol,
                  items: _roles?.map((String rol) {
                    return DropdownMenuItem<String>(
                      value: rol,
                      child: Text(rol),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRol = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione una opción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: SabaneoInputDecoration.textFieldStyle(hintText: "Empresa", icon: Icons.store_outlined),
                  value: _selectedOption,
                  items: _stores?.map((Store store) {
                    return DropdownMenuItem<String>(
                      value: store.id.toString(),
                      child: Text(store.name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione una opción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text("Registrarse"),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    )       
    );
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      UserRegister userRegister = UserRegister(
        name: _nameController.text, 
        username: _usernameController.text, 
        email: _emailController.text, 
        role: _selectedRol.toString(), phone: _phoneController.text, store: _selectedOption.toString());
      
      final Map<String, dynamic> respuestaData = await _userService.createUser(userRegister);

      debugPrint("Error Pdm::: $respuestaData");
      if(!respuestaData['success']){
        if(respuestaData['errors'] != null){
          setState(() {
            _errores = respuestaData['errors'] ?? {};
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(respuestaData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(respuestaData['message'])),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(isLoggedIn: false)), // ✅ Redirige a HomeScreen
        );
      }
      

      
    }
  }
}
