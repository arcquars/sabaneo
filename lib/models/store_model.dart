class Store {
  final int id;
  final String name;

  Store({required this.id, required this.name});

  factory Store.fromJson(Map<String, dynamic> json){
    return Store(
      id: json['id'],
      name: json['name']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name
    };
  }
}