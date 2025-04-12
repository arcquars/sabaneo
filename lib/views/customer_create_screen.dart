import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _representanteLegalController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _coordenadasController = TextEditingController();
  LatLng? _ubicacion;
  File? _imagenFrontis;

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
      debugPrint('Nombre: ${_nombreController.text}');
      debugPrint('NIT: ${_nitController.text}');
      debugPrint('Representante Legal: ${_representanteLegalController.text}');
      debugPrint('Teléfono: ${_telefonoController.text}');
      debugPrint('Ubicación: $_ubicacion');
      debugPrint('Imagen Frontis: $_imagenFrontis');

      // Lógica para guardar el cliente en tu backend o base de datos
    }
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
                controller: _nombreController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                  labelText: "Nombre",
                  hintText: "Ingrese el nombre del cliente"
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
                controller: _nitController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "NIT",
                    hintText: "Ingrese el NIT cliente"
                ),
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
                controller: _telefonoController,
                decoration: SabaneoInputDecoration.defaultDecoration(
                    labelText: "Teléfono de Contacto",
                    hintText: ""
                ),
                keyboardType: TextInputType.phone,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
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
    );
  }
}