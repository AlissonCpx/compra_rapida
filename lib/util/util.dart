import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/user.dart';

class Util {



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
}