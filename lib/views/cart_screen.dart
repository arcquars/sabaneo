import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/database/db_helper.dart';
import 'package:sabaneo_2/login/presentation/view/login_page.dart';
import 'package:sabaneo_2/models/cart_model.dart';
import 'package:sabaneo_2/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  CartScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DBHelper? dbHelper = DBHelper();
  List<bool> tapped = [];
  String _selectedClientName = '';

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
      'Ana Martínez'
      // Agrega aquí la lista completa de clientes
    ];
    List<String> filteredClients = List.from(allClients);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar Cliente'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                TextField(
                    controller: searchController,
                    decoration: InputDecoration(hintText: 'Ingrese el nombre del cliente'),
                    onChanged: (value) {
                      setState(() {
                        filteredClients = allClients
                            .where((client) => client.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                SizedBox(
                  height: 200, // Altura fija para la lista de resultados
                  child: ListView.builder(
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredClients[index]),
                        onTap: () {
                          // Acción al seleccionar un cliente
                        },
                      );
                    },
                  ),
                ),
              ],
            )
            
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
    });
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
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            position: const badges.BadgePosition(start: 30, bottom: 30),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ));
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
                                    image: NetworkImage('http://selkisbolivia.com/${provider.cart[index].image!}'),
                                  ),
                                  border: Border.all(
                                    color: Color(0xffe8a63f), // Color del borde
                                    width: 1.0,         // Ancho del borde
                                  ),
                                  borderRadius: BorderRadius.circular(5.0)
                                )
                              ),
                                SizedBox(
                                  width: 130,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: '${provider.cart[index].codigo}',
                                            style: TextStyle(
                                                color: Color(0xfffd7414),
                                                fontSize: 16.0, fontWeight: FontWeight.bold),
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
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${provider.cart[index].unitTag!}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Precio: ' r"$",
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${provider.cart[index].productPrice!}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder<int>(
                                    valueListenable:
                                        provider.cart[index].quantity!,
                                    builder: (context, val, child) {
                                      return PlusMinusButtons(
                                        addQuantity: () {
                                          cart.addQuantity(
                                              provider.cart[index].id!);
                                          dbHelper!
                                              .updateQuantity(Cart(
                                                  id: index,
                                                  productId: index.toString(),
                                                  codigo: provider
                                                      .cart[index].codigo,
                                                  productName: provider
                                                      .cart[index].productName,
                                                  initialPrice: provider
                                                      .cart[index].initialPrice,
                                                  productPrice: provider
                                                      .cart[index].productPrice,
                                                  quantity: ValueNotifier(
                                                      provider.cart[index]
                                                          .quantity!.value),
                                                  unitTag: provider
                                                      .cart[index].unitTag,
                                                  image: provider
                                                      .cart[index].image))
                                              .then((value) {
                                            setState(() {
                                              cart.addTotalPrice(double.parse(
                                                  provider
                                                      .cart[index].productPrice
                                                      .toString()));
                                            });
                                          });
                                        },
                                        deleteQuantity: () {
                                          cart.deleteQuantity(
                                              provider.cart[index].id!);
                                          cart.removeTotalPrice(double.parse(
                                              provider.cart[index].productPrice
                                                  .toString()));
                                        },
                                        text: val.toString(),
                                      );
                                    }),
                                IconButton(
                                    onPressed: () {
                                      dbHelper!.deleteCartItem(
                                          provider.cart[index].id!);
                                      provider
                                          .removeItem(provider.cart[index].id!);
                                      provider.removeCounter();
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade800,
                                    )),
                              ],
                            ),
                          ),
                        );
                      });
                }
              },
            ),
          ),
          Consumer<CartProvider>(
            builder: (BuildContext context, value, Widget? child) {
              final ValueNotifier<double?> totalPrice = ValueNotifier(null);
              for (var element in value.cart) {
                totalPrice.value =
                    (element.productPrice! * element.quantity!.value) +
                        (totalPrice.value ?? 0);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<double?>(
                      valueListenable: totalPrice,
                      builder: (context, val, child) {
                        return ReusableWidget(
                            title: 'Sub-Total',
                            value: r'$' + (val?.toStringAsFixed(2) ?? '0'));
                  }),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle, // Forma circular
                            border: Border.all(color: Color(0xfffd7e14), width: 2), // Borde azul de 2 píxeles
                            borderRadius: BorderRadius.circular(4.0)
                          ),
                          child: IconButton(
                            icon: Icon(Icons.person_search_rounded, color: Color(0xfffd7e14),),
                            iconSize: 25,
                            onPressed: () {
                              // Acción al presionar el botón
                              _showClientSearchDialog();
                            },
                          ),
                        ),
                        SizedBox(width: 2), // Espacio entre el botón y el texto
                        Text(_selectedClientName),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: true, 
                          onChanged: (bool? newValue){}
                          ),
                        SizedBox(width: 2), // Espacio entre el botón y el texto
                        Text('Credito'),
                        SizedBox(width: 6),
                        Flexible(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: 'A cuenta',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  

                ],
              );
            },
          )
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Realizar Venta'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          color: Colors.yellow.shade600,
          alignment: Alignment.center,
          height: 50.0,
          child: const Text(
            'Realizar Venta',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
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
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}