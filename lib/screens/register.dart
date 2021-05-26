import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formkey = GlobalKey<FormState>();

  void onSuccess() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Usuário criado com sucesso"),
      backgroundColor: Colors.lightBlueAccent,
      duration: Duration(seconds: 2),
    ));
    Future.delayed(Duration(seconds: 2))
        .then((value) => Navigator.of(context).pop());
  }

  void onFail() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao criar usuário"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }


  _cadastraUsuario(User user) {


    FirebaseAuth auth = FirebaseAuth.instance;

    auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.senha
    ).then((firebaseUser){

      //Salvar dados do usuário
      Firestore db = Firestore.instance;
      user.idUser = firebaseUser.user.uid;
      db.collection("usuarios")
          .document( firebaseUser.user.uid )
          .setData( user.toMap() );
    onSuccess();

    }).catchError((e) {
      onFail();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Cadastro',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    autofocus: false,
                    controller: nomeController,
                    decoration: InputDecoration(
                        hintText: 'Nome',
                        labelStyle: TextStyle(color: Colors.redAccent)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Digite o seu nome";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    autofocus: false,
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        labelStyle: TextStyle(color: Colors.redAccent)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Digite o seu email";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    obscureText: true,
                    autofocus: false,
                    controller: senhaController,
                    decoration: InputDecoration(
                        hintText: 'Senha',
                        labelStyle: TextStyle(color: Colors.redAccent)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Digite a senha";
                      } else if (value.length <= 6) {
                        return "Digite no minimo 6 caracteres";
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    obscureText: true,
                    autofocus: false,
                    controller: confirmController,
                    decoration: InputDecoration(
                        hintText: 'Confirmar Senha',
                        labelStyle: TextStyle(color: Colors.redAccent)),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Digite a senha novamente";
                      } else if (value != senhaController.text) {
                        return "As senhas tem que ser iguais";
                      }
                    },
                  ),
                ),
                Container(
                  width: 300,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
                      child: RaisedButton(
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          textColor: Colors.white,
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            if (formkey.currentState.validate()) {
                              User user = new User();
                              user.email = emailController.text;
                              user.balance = 0;
                              user.deliveryman = false;
                              user.nome = nomeController.text;
                              user.senha = senhaController.text;

                              _cadastraUsuario(user);
                            }
                          })),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
