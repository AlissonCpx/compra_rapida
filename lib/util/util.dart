import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/destino.dart';
import 'package:compra_rapida_2/models/market.dart';
import 'package:compra_rapida_2/models/order.dart';
import 'package:compra_rapida_2/models/shopper.dart';
import 'package:compra_rapida_2/models/user.dart';

class Util {

  static Future<OrderPed> pesquisaOrder(String idOrder) async {
    OrderPed ped = new OrderPed();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("pedidos")
        .where("idPedido", isEqualTo: idOrder)
        .getDocuments())
        .documents;
    if (documentList != null) {
      ped.idPedido = documentList[0]["idPedido"];
      ped.situacao = documentList[0]["situacao"];
      User user = await Util.getUsuario((documentList[0]["userClId"]["id"]));
      ped.userClId = user;
      Shopper shop = documentList[0]["entregadorClId"] != null ? await Util.pesquisaShopper(documentList[0]["entregadorClId"]["id"]) : null;
      ped.entregadorClId = shop;
      ped.itens = documentList[0]["itens"];
      Market merc = await Util.getMercados(documentList[0]["nome"]);
      ped.mercado = merc;
      ped.dataEntregaPed = documentList[0]["dataEntregaPed"];
      ped.dataHoraPed = documentList[0]["dataHoraPed"];
      ped.valorNota = documentList[0]["valorNota"];
      ped.valorFrete = documentList[0]["valorFrete"];
      ped.nota = documentList[0]["nota"];
      Destino dest = new Destino();
      dest.latitude = documentList[0].data["destino"]["latitude"];
      dest.longitude = documentList[0].data["destino"]["longitude"];
      dest.cidade = documentList[0].data["destino"]["cidade"];
      dest.cep = documentList[0].data["destino"]["cep"];
      dest.bairro = documentList[0].data["destino"]["bairro"];
      dest.numero = documentList[0].data["destino"]["numero"];
      dest.rua = documentList[0].data["destino"]["rua"];

      ped.destino = dest;

    }
    return ped;
  }

  static Future<User> getUsuario(String idUser) async {

    User user = new User();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("usuarios")
        .where("id", isEqualTo: idUser)
        .getDocuments())
        .documents;
    if (documentList != null) {
    user.nome = documentList[0]["nome"];
    user.email = documentList[0]["email"];
    user.deliveryman = documentList[0]["deliveryman"];
    user.balance = documentList[0]["balance"];
    user.idUser = documentList[0]["id"];
    user.urlImagem = documentList[0]["urlImagem"];
    }
    return user;
  }

  static Future<Market> getMercados(String nome) async {

    Market mercado = new Market();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("mercados")
        .where("nome", isEqualTo: nome)
        .getDocuments())
        .documents;
    if (documentList != null) {
      mercado.nome = documentList[0]["nome"];
      mercado.rua = documentList[0]["rua"];
      mercado.bairro = documentList[0]["bairro"];
      mercado.cep = documentList[0]["cep"];
      mercado.cidade = documentList[0]["cidade"];
      mercado.numero = documentList[0]["numero"];
      mercado.latitude = documentList[0]["latitude"];
      mercado.longitude = documentList[0]["longitude"];
    }
    return mercado;
  }

  static Future<Shopper> pesquisaShopper(String idShopper) async {
    Shopper shopper = new Shopper();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("shoppers")
        .where("id", isEqualTo: idShopper)
        .getDocuments())
        .documents;
    if (documentList != null) {
      shopper.nome = documentList[0]["nome"];
      shopper.email = documentList[0]["email"];
      shopper.deliveryman = documentList[0]["deliveryman"];
      shopper.balance = documentList[0]["balance"];
      shopper.idUser = documentList[0]["id"];
      shopper.foto = documentList[0]["foto"];
      shopper.fotoCNH = documentList[0]["fotoCNH"];
      shopper.fotoCRLV = documentList[0]["fotoCRLV"];
      shopper.latitude = documentList[0]["latitude"];
      shopper.longitude = documentList[0]["longitude"];
      shopper.rate = documentList[0]["rate"];
      shopper.phone = documentList[0]["phone"];
    }
    return shopper;
  }

}