import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/Screens/text_composer.dart';
import 'package:compra_rapida_2/models/shopper.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  String idUser;
  String idPedidoDocument;


  ChatScreen(this.idUser, this.idPedidoDocument);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
  }

  void sendMessage({String text, File imgFile}) async {
 User user = await Util.getUsuario(widget.idUser);

    
    Map<String, dynamic> data = {
      "uid": user.idUser,
      "senderName": user.nome,
      "senderPhotoUrl": user.urlImagem,
      'time': Timestamp.now(),
    };
   bool img = false;
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString() +
          user.idUser.toString())
          .putFile(imgFile);

      setState(() {
        isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
      img = true;
      setState(() {
        isLoading = false;
      });
    }
    if (text != null && text.isNotEmpty) {
      data['text'] = text;
    } else {
    }
    Firestore.instance.collection("pedidos").document(widget.idPedidoDocument).collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chat'),
        elevation: 0,
        actions: <Widget>[
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('pedidos').document(widget.idPedidoDocument).collection("messages")
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                    snapshot.data.documents.reversed.toList();

                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(documents[index].data,
                            documents[index].data['uid'] == widget.idUser);
                      },
                    );
                }
              },
            ),
          ),
          isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(sendMessage),
        ],
      ),
    );
  }
}