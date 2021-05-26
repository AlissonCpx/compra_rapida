import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_2/models/user.dart';
import 'package:compra_rapida_2/screens/home.dart';
import 'package:compra_rapida_2/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formkey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;

  void onFail() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao realizar Login"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  _efetuaLoginGoogle() async {
    setState(() {
      loading = true;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      Firestore db = Firestore.instance;

      List<DocumentSnapshot> documentList;
      documentList = (await Firestore.instance
              .collection("usuarios")
              .where("id", isEqualTo: user.uid)
              .getDocuments())
          .documents;

      if (documentList.isNotEmpty) {
        User usuario = User();
        usuario.urlImagem = documentList[0].data["urlImagem"];
        usuario.idUser = documentList[0].data["id"];
        usuario.deliveryman = false;
        usuario.nome = documentList[0].data["nome"];
        usuario.email = documentList[0].data["email"];
        usuario.balance = documentList[0].data["balance"];

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(usuario),
            ));
      } else {
        User usuario = User();
        usuario.balance = 0;
        usuario.email = user.email;
        usuario.nome = user.displayName;
        usuario.deliveryman = false;
        usuario.idUser = user.uid;
        usuario.urlImagem = user.photoUrl;

        db.collection("usuarios").document(user.uid).setData(usuario.toMap());

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(usuario),
            ));
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      return null;
    }
  }

  _efetuaLogin(User user) {
    setState(() {
      loading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(email: user.email, password: user.senha)
        .then((firebaseUser) async {
      User usuario = new User();

      Firestore db = Firestore.instance;

      List<DocumentSnapshot> documentList;
      documentList = (await Firestore.instance
              .collection("usuarios")
              .where("id", isEqualTo: firebaseUser.user.uid)
              .getDocuments())
          .documents;

      usuario.urlImagem = documentList[0].data["urlImagem"];
      usuario.idUser = documentList[0].data["id"];
      usuario.deliveryman = false;
      usuario.nome = documentList[0].data["nome"];
      usuario.email = documentList[0].data["email"];
      usuario.balance = documentList[0].data["balance"];

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(usuario),
          ));
      setState(() {
        loading = false;
      });
    }).catchError((onError) {
      print(onError);
      setState(() {
        loading = false;
      });
      onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                  child: Image.asset(
                "images/logo.png",
                height: 350,
                width: 350,
              )),
              Form(
                key: formkey,
                child: Column(
                  children: <Widget>[
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
                            return "Insira o email";
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
                            return "Insira o senha";
                          }
                        },
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 255,
                        ),
                        FlatButton(
                          onPressed: () {},
                          child: Text('Esqueceu a senha?'),
                        ),
                      ],
                    ),
                    loading
                        ? CircularProgressIndicator()
                        : Container(
                            width: 300,
                            height: 30,
                            child: PhysicalModel(
                              color: Colors.transparent,
                              shadowColor: Colors.black,
                              elevation: 8.0,
                              child: RaisedButton(
                                child: Text(
                                  'Entrar',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.white,
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (formkey.currentState.validate()) {
                                    User user = new User();
                                    user.email = emailController.text;
                                    user.senha = senhaController.text;
                                    _efetuaLogin(user);
                                  }
                                },
                              ),
                            )),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: PhysicalModel(
                                color: Colors.white54,
                                child: Image.asset("images/google.png"),
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(20),
                              )),
                          onTap: () {
                            _efetuaLoginGoogle();
                          },
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        GestureDetector(
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: PhysicalModel(
                                color: Colors.transparent,
                                child: Image.asset("images/facebook.png"),
                                elevation: 8.0,
                                borderRadius: BorderRadius.circular(20),
                              )),
                          onTap: () {
                            print("teste");
                          },
                        ),
                      ],
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Register()));
                      },
                      child: Text('Criar Conta'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
