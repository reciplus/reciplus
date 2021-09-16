import 'dart:async';
// import 'dart:convert' show json;

// import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:reciplus/theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reciplus/recipe_page.dart';
// import 'package:reciplus/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: primarySwatchColor,
      ),
      home: const SignInDemo(),
    );
  }
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  // Declaring global variables
  GoogleSignInAccount? _currentUser;
  UserCredential? _credential;
  String? _uid;

  // Life cycle functions
  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  // Events handlers
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth auth = FirebaseAuth.instance;
    } catch (e) {
      print(e);
    }
  }

  void _goAddRecipe() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp2()));
  }

  Future<void> _handleSignIn() async {
    UserCredential? credential = await _getAuth();
    setState(() {
      _credential = credential;
    });
  }

  Future<UserCredential> _getAuth() async {
    final googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    setState(() {
      _uid = FirebaseAuth.instance.currentUser?.uid;
    });
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  // Render display
  Widget _buildBody() {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(
              user.displayName ?? '',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
                border: Border(
              right: BorderSide(width: 10, color: Color(0x00000000)),
              left: BorderSide(width: 10, color: Color(0x00000000)),
            )),
            child: Text(
              'Welcome, ${user.displayName}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 10, color: Color(0x00000000)),
                left: BorderSide(width: 10, color: Color(0x00000000)),
                right: BorderSide(width: 10, color: Color(0x00000000)),
                bottom: BorderSide(width: 15, color: Color(0x00000000)),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Spacer(),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    child: const Text('SIGN OUT'),
                    onPressed: _handleSignOut,
                  ),
                ),
                const Spacer(flex: 2),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    child: const Text('MY RECIPES'),
                    onPressed: () => _goAddRecipe(),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                border: Border(
              right: BorderSide(width: 10, color: Color(0x00000000)),
              left: BorderSide(width: 10, color: Color(0x00000000)),
            )),
            child: const Text(
              "Sign in to Begin Your Healthy Journey",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reciplus'),
        ),
        body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35), BlendMode.colorBurn),
                  image: const AssetImage("assets/images/background.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: _buildBody(),
            )));
  }
}
