
class Pedido {
  String _userId;
  String _situacao;
  List _itens;


  Pedido();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "id" : this.userId,
      "situacao" : this.situacao,
      "itens" : this.itens,

    };

    return map;

  }



  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get situacao => _situacao;

  set situacao(String value) {
    _situacao = value;
  }

  List get itens => _itens;

  set itens(List value) {
    _itens = value;
  }
}