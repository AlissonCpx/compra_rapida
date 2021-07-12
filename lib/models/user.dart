import 'package:compra_rapida_2/models/pedido.dart';

class User {
  String _idUser;
  String _nome;
  String _email;
  String _urlImagem;
  String _senha;
  double _balance = 0;
  bool _deliveryman;
  List<Pedido> _pedidos;


  User();



  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "id" : this.idUser,
      "nome" : this.nome,
      "email" : this.email,
      "urlImagem" : this.urlImagem,
      "balance": this.balance,
      "deliveryman": false,
      "pedidos" : this.pedidos
    };

    return map;

  }

  bool get deliveryman => _deliveryman;

  set deliveryman(bool value) {
    _deliveryman = value;
  }

  double get balance => _balance;

  set balance(double value) {
    _balance = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }

  List<Pedido> get pedidos => _pedidos;

  set pedidos(List<Pedido> value) {
    _pedidos = value;
  }
}