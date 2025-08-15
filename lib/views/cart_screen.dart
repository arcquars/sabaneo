import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/database/db_helper.dart';
import 'package:sabaneo_2/models/cart_model.dart';
import 'package:sabaneo_2/models/customer_model.dart';
import 'package:sabaneo_2/providers/cart_provider.dart';
import 'package:sabaneo_2/providers/user_provider.dart';
import 'package:sabaneo_2/services/customer_service.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_button_styles.dart';
import 'package:sabaneo_2/utils/decorations/sabaneo_input_decoration.dart';

class CartScreen extends StatefulWidget {
  CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DBHelper? dbHelper = DBHelper();
  List<bool> tapped = [];
  String _selectedClientName = '';
  String _selectedClientNIT = '';
  String _errorMessage = '';
  double _subTotal = 0;
  double _selectedAcuenta = 0;
  bool _isCheckedCredito = false;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  Future<void> _showClientSearchDialog() async {
    TextEditingController searchController = TextEditingController();
    List<String> allClients = [
        'Juan Perez Laime',
        'Maria Garcia',
        'Carlos López',
        'Ana Martínez',
        'Pedro Sánchez',
        'Sofia Ramirez',
        'Jorge Morales',
        'Laura Torres'
        // Agrega aquí la lista completa de clientes de forma dinámica
    ];
    // La lista filtrada debe ser mutable
    List<String> filteredClients = List.from(allClients);

    await showDialog(
        context: context,
        builder: (BuildContext context) {
        // Usamos StatefulBuilder para gestionar el estado local del diálogo
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
                title: const Text('Buscar Cliente'),
                content: SizedBox(
                width: double.maxFinite,
                child: Column(
                    mainAxisSize: MainAxisSize.min, // Es importante para diálogos
                    children: [
                    TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                        hintText: 'Ingrese el nombre del cliente',
                        ),
                        onChanged: (value) {
                        // Usamos setStateDialog para reconstruir solo el contenido del diálogo
                        setStateDialog(() {
                            filteredClients = allClients
                                .where((client) => client.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                        });
                        },
                    ),
                    const SizedBox(height: 10),
                    // Usar Expanded dentro de la Column para la lista
                    Expanded(
                        child: ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                            return ListTile(
                            title: Text(filteredClients[index]),
                            onTap: () {
                                // Actualizamos el estado del widget principal
                                // con el cliente seleccionado.
                                setState(() {
                                _selectedClientName = filteredClients[index];
                                });
                                Navigator.of(context).pop();
                            },
                            );
                        },
                        ),
                    ),
                    ],
                ),
                ),
                actions: [
                TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                    Navigator.of(context).pop();
                    },
                ),
                ],
            );
            },
        );
        },
    );
    }

    Future<void> _showClientSearchDialog1() async {
    final CustomerService customerService = CustomerService();
    
    // Controladores para los campos de filtro.
    TextEditingController nameController = TextEditingController();
    TextEditingController nitController = TextEditingController();
    TextEditingController codigoController = TextEditingController();

    List<CustomerModel> allClients = [];
    List<CustomerModel> filteredClients = [];
    int itemsPerPage = 5;
    int currentPage = 0;
    bool isLoading = false;
    bool hasMore = true;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
            
            // Función para buscar y cargar clientes paginados.
            Future<void> _searchAndLoadCustomers() async {
                if (isLoading || !hasMore) return; // Evita múltiples cargas.

                setStateDialog(() {
                isLoading = true;
                });
                
                try {
                // Llamada a getCustomers con los filtros.
                // Para la paginación en el lado del cliente, se obtienen todos
                // y se paginan localmente. Si la API soporta paginación,
                // se modificaría esta parte.
                final Map<String, String> filters = {
                    'nombre': nameController.text,
                    'nit': nitController.text,
                    'codigo': codigoController.text,
                };
                allClients = await customerService.getCustomers(filters);
                
                // Inicializamos la lista filtrada con la primera página.
                filteredClients = allClients.take(itemsPerPage).toList();
                currentPage = 1;
                hasMore = allClients.length > itemsPerPage;

                } catch (e) {
                debugPrint("Error al cargar clientes: $e");
                } finally {
                setStateDialog(() {
                    isLoading = false;
                });
                }
            }
            
            // Función para cargar más clientes (la siguiente página).
            void _loadMoreCustomers() {
                if (isLoading || !hasMore) return;

                setStateDialog(() {
                isLoading = true;
                });
                
                final int startIndex = currentPage * itemsPerPage;
                final int endIndex = startIndex + itemsPerPage;
                
                List<CustomerModel> newClients = allClients.sublist(
                startIndex,
                endIndex > allClients.length ? allClients.length : endIndex,
                );

                setStateDialog(() {
                filteredClients.addAll(newClients);
                currentPage++;
                if (filteredClients.length >= allClients.length) {
                    hasMore = false;
                }
                isLoading = false;
                });
            }

            return AlertDialog(
                titlePadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                title: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xfffd7e14), // El color de fondo que deseas
                        borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10), // Bordes redondeados para que coincidan con el AlertDialog
                        topRight: Radius.circular(10)
                        ),
                    ),
                    padding: const EdgeInsets.all(8.0), // Añade el padding deseado al contenido del título
                    child: const Center(
                        child: Text(
                        'Buscar Cliente',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0
                        ),
                        ),
                    ),
                ),
                content: SizedBox(
                width: double.maxFinite,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    TextField(
                        controller: nameController,
                        // decoration: const InputDecoration(hintText: 'Buscar por nombre'),
                        decoration: SabaneoInputDecoration.defaultDecoration(
                            labelText: "Buscar por nombre",
                        ),
                    ),
                    const SizedBox(height: 4.0),
                    TextField(
                        controller: nitController,
                        decoration: SabaneoInputDecoration.defaultDecoration(
                            labelText: "Buscar por NIT",
                        ),
                    ),
                    const SizedBox(height: 4.0),
                    TextField(
                        controller: codigoController,
                        decoration: SabaneoInputDecoration.defaultDecoration(
                            labelText: "Buscar por código",
                        ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                        onPressed: _searchAndLoadCustomers,
                        style: SabaneoButtonStyles.secondaryButtonStyle(),
                        child: const Text('Buscar'),
                    ),
                    const SizedBox(height: 10),
                    // Muestra los resultados o un indicador de carga.
                    if (isLoading && filteredClients.isEmpty)
                        const Center(child: CircularProgressIndicator())
                    else if (filteredClients.isEmpty && !isLoading)
                        const Text('No hay resultados. Presione "Buscar".')
                    else
                        Expanded(
                        child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                            if (!isLoading && hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                _loadMoreCustomers();
                            }
                            return false;
                            },
                            child: ListView.builder(
                            itemCount: filteredClients.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                                if (index == filteredClients.length) {
                                // Muestra un indicador de carga para la paginación.
                                return const Center(child: CircularProgressIndicator());
                                }
                                final customer = filteredClients[index];
                                return ListTile(
                                title: Text(customer.nombres ?? 'N/A'),
                                subtitle: Text(
                                    'NIT: ${customer.nit ?? 'N/A'} | '
                                    'Código: ${customer.codigo ?? 'N/A'}',
                                ),
                                onTap: () {
                                    setState(() {
                                    _selectedClientName = customer.nombres ?? '';
                                    _selectedClientNIT = customer.nit ?? '';
                                    });
                                    Navigator.of(context).pop();
                                },
                                );
                            },
                            ),
                        ),
                        ),
                    ],
                ),
                ),
                actions: [
                TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                    Navigator.of(context).pop();
                    },
                ),
                ],
            );
            },
        );
        },
    );
    }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
          children: [
            FaIcon(FontAwesomeIcons.store), // Icono a la izquierda
            SizedBox(width: 8), // Espaciado entre icono y texto
            Text('Mi carrito'),
          ],
        ),
        actions: [
          badges.Badge(
            badgeContent: Consumer<CartProvider>(
              builder: (context, value, child) {
                return Text(
                  value.getCounter().toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            position: const badges.BadgePosition(start: 30, bottom: 30),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
        backgroundColor: Color(0xFFFD7E14),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CartProvider>(
              builder: (BuildContext context, provider, widget) {
                if (provider.cart.isEmpty) {
                  return const Center(
                    child: Text(
                      'Su carro está vacío',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.cart.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white70,
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 80.0, // Ancho deseado
                                height: 100.0, // Altura deseada
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle, // Forma circular
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      'http://selkisbolivia.com/${provider.cart[index].image!}',
                                    ),
                                  ),
                                  border: Border.all(
                                    color: Color(0xffe8a63f), // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2.0),
                                    RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                        text: '${provider.cart[index].codigo}',
                                        style: TextStyle(
                                          color: Color(0xfffd7414),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        // children: [
                                        //   TextSpan(
                                        //       text:
                                        //           '',
                                        //       style: const TextStyle(
                                        //           fontWeight:
                                        //               FontWeight.bold)),
                                        // ]
                                      ),
                                    ),
                                    RichText(
                                      maxLines: 1,
                                      text: TextSpan(
                                        text: 'Unidad: ',
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade800,
                                          fontSize: 16.0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '${provider.cart[index].unitTag!}\n',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      maxLines: 1,
                                      text: TextSpan(
                                        text:
                                            'Precio: '
                                            r"$",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade800,
                                          fontSize: 16.0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '${provider.cart[index].productPrice!}\n',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: provider.cart[index].quantity!,
                                builder: (context, val, child) {
                                  return PlusMinusButtons(
                                    addQuantity: () {
                                      cart.addQuantity(
                                        provider.cart[index].id!,
                                      );
                                      dbHelper!
                                          .updateQuantity(
                                            Cart(
                                              id: index,
                                              productId: index.toString(),
                                              codigo:
                                                  provider.cart[index].codigo,
                                              productName:
                                                  provider
                                                      .cart[index]
                                                      .productName,
                                              initialPrice:
                                                  provider
                                                      .cart[index]
                                                      .initialPrice,
                                              productPrice:
                                                  provider
                                                      .cart[index]
                                                      .productPrice,
                                              quantity: ValueNotifier(
                                                provider
                                                    .cart[index]
                                                    .quantity!
                                                    .value,
                                              ),
                                              unitTag:
                                                  provider.cart[index].unitTag,
                                              image: provider.cart[index].image,
                                            ),
                                          )
                                          .then((value) {
                                            setState(() {
                                              cart.addTotalPrice(
                                                double.parse(
                                                  provider
                                                      .cart[index]
                                                      .productPrice
                                                      .toString(),
                                                ),
                                              );
                                            });
                                          });
                                    },
                                    deleteQuantity: () {
                                      cart.deleteQuantity(
                                        provider.cart[index].id!,
                                      );
                                      cart.removeTotalPrice(
                                        double.parse(
                                          provider.cart[index].productPrice
                                              .toString(),
                                        ),
                                      );
                                    },
                                    text: val.toString(),
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  dbHelper!.deleteCartItem(
                                    provider.cart[index].id!,
                                  );
                                  provider.removeItem(provider.cart[index].id!);
                                  provider.removeCounter();
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Consumer<CartProvider>(
            builder: (BuildContext context, value, Widget? child) {
              final ValueNotifier<double?> totalPrice = ValueNotifier(null);
              final ValueNotifier<double?> totalDue = ValueNotifier(null);
              totalPrice.value = 0;
              for (var element in value.cart) {
                totalPrice.value =
                    (element.productPrice! * element.quantity!.value) +
                    (totalPrice.value ?? 0);
              }
              if(_selectedAcuenta > 0){
                totalDue.value = totalPrice.value! - _selectedAcuenta;
              } else {
                totalDue.value = totalPrice.value;
              }
              _subTotal = totalPrice.value!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle, // Forma circular
                            border: Border.all(
                              color: Color(0xfffd7e14),
                              width: 2,
                            ), // Borde azul de 2 píxeles
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.person_search_rounded,
                              color: Color(0xfffd7e14),
                            ),
                            iconSize: 25,
                            onPressed: () {
                              // Acción al presionar el botón
                              _showClientSearchDialog1();
                            },
                          ),
                        ),
                        SizedBox(width: 2), // Espacio entre el botón y el texto
                        Text(_selectedClientName),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<double?>(
                    valueListenable: totalPrice,
                    builder: (context, val, child) {
                      return ReusableWidget(
                        title: 'Sub Total',
                        value: r'$' + (val?.toStringAsFixed(2) ?? '0'),
                      );
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                            value: _isCheckedCredito, 
                            onChanged: (bool? newValue) {
                                setState(() {
                                  _isCheckedCredito = newValue  ?? false;
                                });
                            }
                        ),
                        SizedBox(width: 2), // Espacio entre el botón y el texto
                        Text('Credito'),
                        SizedBox(width: 6),
                        if (_isCheckedCredito)
                            Flexible(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _selectedAcuenta = 0;
                                  if(value != '') {
                                    _selectedAcuenta = double.parse(value);
                                  }
                                  if(_selectedAcuenta < 0){
                                    _selectedAcuenta = 0;
                                  }
                                });
                              },
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: SabaneoInputDecoration.defaultDecorationMedium(
                                    labelText: "A cuenta",
                                ),
                            ),
                            ),
                      ],
                      
                    ),
                  ),
                  ValueListenableBuilder<double?>(
                    valueListenable: totalDue,
                    builder: (context, val, child) {
                      return ReusableWidget(
                        title: 'SALDO',
                        value: r'$' + (val?.toStringAsFixed(2) ?? '0'),
                      );
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Text(
                        _errorMessage,
                      style: TextStyle(
                          color: Colors.red,
                        fontSize: 12
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          setState(() {
            _errorMessage = "";
            if(_selectedClientName == ""){
              _errorMessage = "Tiene que elegir un Cliente";
            }
            if(_subTotal <= 0){
              _errorMessage = "El carrito esta vacio";
            }
            if(_isCheckedCredito && _selectedAcuenta > _subTotal){
              _errorMessage = "A cuenta tiene que ser menor a Sub Total";
            }

            if(_errorMessage == ""){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Realizar Venta'),
                  duration: Duration(seconds: 2),
                ),
              );
            }






          });

        },
        child: Container(
          color: Colors.yellow.shade600,
          alignment: Alignment.center,
          height: 50.0,
          child: const Text(
            'Realizar Venta',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons({
    Key? key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: deleteQuantity, icon: const Icon(Icons.remove)),
        Text(text),
        IconButton(onPressed: addQuantity, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  const ReusableWidget({Key? key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
