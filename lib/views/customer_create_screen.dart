import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:sabaneo_2/services/customer_service.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';
import 'package:sabaneo_2/utils/location_util.dart';

class CustomerCreateScreen extends StatelessWidget {
  const CustomerCreateScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                FaIcon(FontAwesomeIcons.userGear), // Icono a la izquierda
                SizedBox(width: 8), // Espaciado entre icono y texto
                Text('Crear Cliente'),
              ],
          ),
          centerTitle: true, // Opcional: Centrar el título
          backgroundColor: Color(0xFFFD7E14),
        ),
        body: CustomerCreateForm()
      );
  }
}

class CustomerCreateForm extends StatefulWidget {
  const CustomerCreateForm({super.key});

  @override
  State<CustomerCreateForm> createState() => _CustomerCreateFormState();
}

class _CustomerCreateFormState extends State<CustomerCreateForm> {
  final CustomerService _customerService = CustomerService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _representanteLegalController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _coordenadasController = TextEditingController();
  LatLng? _ubicacion;
  File? _imagenFrontis;

  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _seleccionarUbicacion(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/mapa_direccion') as LatLng?;
    if (result != null) {
      setState(() {
        _ubicacion = result;
        _coordenadasController.text = 'Lat: ${_ubicacion!.latitude.toStringAsFixed(6)}, Lng: ${_ubicacion!.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imagenFrontis = File(pickedFile.path);
      } else {
        debugPrint('No se tomó ninguna foto.');
      }
    });
  }

  void _guardarCliente() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes acceder a los valores de los controladores y _ubicacion y _imagenFrontis
      debugPrint('Codigo: ${_codigoController.text}');
      debugPrint('Nombre: ${_nombreController.text}');
      debugPrint('NIT: ${_nitController.text}');
      debugPrint('Representante Legal: ${_representanteLegalController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Ubicación: $_ubicacion');
      debugPrint('Imagen Frontis: $_imagenFrontis');

      _createCustomer();
      // Lógica para guardar el cliente en tu backend o base de datos
    }
  }

  Future<String?> pickAndEncodeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  Future<void> _createCustomer() async {
    final bytes = await _imagenFrontis!.readAsBytes();
    await _customerService.createCustomer(
      _codigoController.text,
        _nitController.text,
        _nombreController.text,
        _telefonoController.text,
        "TIENDA",
        _ubicacion.toString(),
        base64Encode(bytes));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Se creo el cliente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Crear Nuevo Cliente'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _codigoController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Codigo",
                    // hintText: "Ingrese el nombre del cliente"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el codigo del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _nitController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "NIT",
                    hintText: "Ingrese el NIT cliente"
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _nombreController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                  labelText: "Razon social",
                  // hintText: "Ingrese el nombre del cliente"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _telefonoController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Teléfono de Contacto",
                    hintText: ""
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _representanteLegalController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Representante Legal",
                    hintText: ""
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _direccionController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Dirección",
                    hintText: ""
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _coordenadasController,
                readOnly: true,
                decoration: SabaneoInputDecoration.defaultDecorationSuffixIcon(
                    labelText: "Coordenadas",
                    hintText: "",
                    suffixIcon: const Icon(Icons.map),
                    onPressedSuffixIcon: () {
                      _seleccionarUbicacion(context);
                    }
                ),
                validator: (value) {
                  if (_ubicacion == null || value == null || value.isEmpty) {
                    return 'Por favor, selecciona la ubicación en el mapa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto del Frontis'),
                style: SabaneoButtonStyles.primaryButtonStyle(),
                onPressed: _takePhoto,
              ),
              const SizedBox(height: 8.0),
              if (_imagenFrontis != null)
                SizedBox(
                  height: 100,
                  child: Image.file(_imagenFrontis!),
                ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _guardarCliente,
                style: SabaneoButtonStyles.secondaryButtonStyle(),
                child: const Text('Guardar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapaDireccion extends StatefulWidget {
  const MapaDireccion({super.key});

  @override
  State<MapaDireccion> createState() => _MapaDireccionState();
}

class _MapaDireccionState extends State<MapaDireccion> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-17.3936, -66.1571), // Cochabamba como ubicación inicial
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<Position> obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    // Verificar los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente.');
    }

    // Obtener la posición actual
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<CameraPosition> obtenerCameraPosition() async {
    Position posicion = await obtenerUbicacion();
    return CameraPosition(
      target: LatLng(posicion.latitude, posicion.longitude),
      zoom: 18.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CameraPosition>(
      future: obtenerCameraPosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al obtener la ubicación.'));
        } else {
          return Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: snapshot.data!,
                  // myLocationEnabled: true,
                  // myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: _selectedLocation == null
                      ? {}
                      : {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                    ),
                  },
                ),
                // Center(
                //   child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                // ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // Retornar la posición seleccionada al cerrar la pantalla
                      Navigator.pop(context, _selectedLocation);
                    },
                    child: Text('Confirmar ubicación'),
                  ),
                ),
                ]
          );
        }
      },
    );
  }
}