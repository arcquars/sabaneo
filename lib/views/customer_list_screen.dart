import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sabaneo_2/models/customer_model.dart';
import 'package:sabaneo_2/services/customer_service.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                FaIcon(FontAwesomeIcons.users), // Icono a la izquierda
                SizedBox(width: 8), // Espaciado entre icono y texto
                Text('Clientes'),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.squarePlus),
                tooltip: 'Crear nuevo',
                onPressed: () {
                  Navigator.pushNamed(context, "/customer-create");
                },
              ),
            ],
            centerTitle: true, // Opcional: Centrar el título
            backgroundColor: Color(0xFFFD7E14),
        ),
        body: CustomerListContent()
      );
  }
}

class CustomerListContent extends StatefulWidget {
  const CustomerListContent({super.key});

  @override
  _CustomerListContentStatefulState createState() => _CustomerListContentStatefulState();
}

class _CustomerListContentStatefulState extends State<CustomerListContent> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  final CustomerService _customerService = CustomerService();
  late Future<List<CustomerModel>> _customers;

  Map<String, String> filters = {
    "codigo": "",
    "nit": "",
    "nombre": "",
    "start": "1",
    "limit": "15",
  };

  @override
  void initState() {
    super.initState();
    _customers = _customerService.getCustomers(filters);

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     _search(true);
    //   }
    // });
  }

  Future<void> _search(bool isAdd) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final int start = (_currentPage * _itemsPerPage) - _itemsPerPage;
    Map<String, String> filters = {
      "codigo": _codigoController.text,
      "nit": _nitController.text,
      "nombre": _nombresController.text,
      "start": start.toString(),
      "limit": _itemsPerPage.toString(),
    };

    // filters.addEntries(newEntries)
    setState(() {
      if(isAdd){
        _customers.then((customers) async{
          customers.addAll(await _customerService.getCustomers(filters));
        });
      } else {
        _customers = _customerService.getCustomers(filters);
      }

      _currentPage++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
          // color: Color(0xfff2f2f2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
          // BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
          ],
          ),
          child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Acción del botón
                    _showModalBottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de las esquinas
                      side: BorderSide(
                        color: const Color(0xfffd7e14), // Color del borde
                        width: 1,         // Grosor del borde
                      ),
                    ),
                  ),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(width: 1.0, height: 15,),
                      Icon(
                          Icons.filter_alt_outlined,
                          color: const Color(0xfffd7e14),
                          size: 26),
                    ],
                  ),
                ),
              ]
          )
        ),
        Expanded(
            child: FutureBuilder<List<CustomerModel>>(
              future: _customers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay clientes disponibles.'));
                } else {
                  List<CustomerModel> customers = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return GestureDetector(
                        onTap: () {
                          debugPrint("xxxxx: ${customer.idcliente}");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: ' ${customer.nombres}',
                                            style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Color(0xfffd7e14)),
                                          ),
                                        ],
                                        // recognizer: _tapGestureRecognizer,
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    SizedBox(
                                      height: customer.codigo.length > 50? 50 : 25,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text(customer.codigo.length > 50? "${customer.codigo.substring(0,50)}..." : customer.codigo),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    SizedBox(
                                      height: customer.nit.length > 50? 50 : 25,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text(customer.nit.length > 50? "${customer.nit.substring(0,50)}..." : customer.nit),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Color(0xfffd7e14),),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
        ),
      ],
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el BottomSheet ocupe más espacio si es necesario
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          // padding: const EdgeInsets.all(8.0),
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Ajusta la altura al contenido
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Busqueda',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xfffd7e14)),
                          textAlign: TextAlign.center,

                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: 4.0),
                          TextField(
                            controller: _nombresController,
                            decoration: SabaneoInputDecoration.defaultDecoration(
                                labelText: "Nombre",
                                hintText: ""
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: _nitController,
                                  decoration: SabaneoInputDecoration.defaultDecoration(
                                      labelText: "NIT",
                                      hintText: ""
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: _codigoController,
                                  decoration: SabaneoInputDecoration.defaultDecoration(
                                      labelText: "Codigo",
                                      hintText: ""
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              // Acción al presionar el botón
                              Navigator.pop(context);
                              _nombresController.text = "";
                              _nitController.text = "";
                              _codigoController.text = "";
                              _search(false);
                            },
                            style: SabaneoButtonStyles.primaryButtonStyle(),
                            child: Text('Limpiar filtros'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Acción al presionar el botón
                              Navigator.pop(context);
                              _currentPage = 1;

                              _search(false);
                            },
                            style: SabaneoButtonStyles.primaryButtonStyle(),
                            child: Text('Buscar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
            )
        );
      },
    );
  }
}