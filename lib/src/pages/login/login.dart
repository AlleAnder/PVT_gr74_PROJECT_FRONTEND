import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:history_go/src/components/buttons.dart';
import 'package:history_go/src/components/title_logo.dart';
import 'package:history_go/src/firestore/firestore_service.dart';
import 'package:history_go/src/pages/pages.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
String _message = '';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  final String title = 'Login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map userProfile;

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('eller'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Saknar konto?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: Text(
              'Registrera ett här',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _resetPasswordDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ResetPasswordDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
                TitleLogo(),
                SizedBox(
                  height: 50,
                ),
                _EmailPasswordForm(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _resetPasswordDialog(),
                    child: Text('Glömt lösenord?',
                        style: TextStyle(
                            color: Color(0xfff79c4f),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                _divider(),
                _OtherProvidersSignInSection(),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _createAccountLabel(),
          ),
          Positioned(
              top: 40,
              left: 0,
              child: CustomBackButton(
                onPressed: () => Navigator.pop(context),
              )),
        ],
      ),
    )));
  }
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode focus;

  @override
  void initState() {
    super.initState();

    focus = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-postadress'),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focus);
            },
            validator: Validator.validateEmail,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Lösenord'),
            focusNode: focus,
            obscureText: true,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Vänligen ange lösenord';
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              _message,
              style: TextStyle(color: Colors.red),
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: WelcomeButton(
                  text: 'Logga in',
                  color: Colors.grey.shade300,
                  filled: true,
                  onTap: () async {
                    if (_formKey.currentState.validate()) {
                      _resetErrorMessage();
                      _signInWithEmailAndPassword();
                    }
                  },
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xfffbb448), Color(0xfff7892b)]))),
        ],
      ),
    );
  }

  void _signInWithEmailAndPassword() async {
    FirebaseUser user;
    try {
      user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
    } on PlatformException catch (e) {
      print(e);
      _setErrorMessage(e.message);
    } catch (e) {
      print(e);
    }
    if (user != null) {
      setState(() {
        print('Successful login: email: ' + user.toString());
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/'));
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    focus.dispose();
    super.dispose();
  }

  void _setErrorMessage(String message) {
    if (message != null) {
      setState(() {
        _message = message;
      });
    }
  }

  void _resetErrorMessage() {
    _setErrorMessage(' ');
  }
}

class _OtherProvidersSignInSection extends StatefulWidget {
  _OtherProvidersSignInSection();

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  final facebookLogin = FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SignInButton(
          Buttons.Facebook,
          onPressed: () {
            _resetErrorMessage();
            _signInWithFacebook();
          },
        ),
        SignInButton(
          Buttons.Google,
          onPressed: () {
            _resetErrorMessage();
            _signInWithGoogle();
          },
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            _message,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _signInHandler('Google', credential);
    } else {
      _setErrorMessage("Google sign in failed.");
    }
  }

  void _signInWithFacebook() async {
    final result = await facebookLogin
        .logInWithReadPermissions(["public_profile", "email"]);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );

        _signInHandler('Facebook', credential);

        break;
      case FacebookLoginStatus.cancelledByUser:
        print(FacebookLoginStatus.cancelledByUser.toString());
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        _setErrorMessage(result.errorMessage);
        break;
    }
  }

  void _signInHandler(String authProvider, AuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      final FirebaseUser fbUser = await _auth.currentUser();
      if (fbUser != null) {
        await FirestoreService.getUser(fbUser.uid).then((firestoreUser) => {
              if (firestoreUser == null)
                {
                  FirestoreService.createUser(fbUser).then((m) {
                    print('First time login for ' +
                        authProvider +
                        " user. Creating Firestore user: " +
                        fbUser.uid);
                    setState(() {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', ModalRoute.withName('/'));
                    });
                  })
                }
              else
                {
                  setState(() {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', ModalRoute.withName('/'));
                  })
                }
            });
      } else {
        _setErrorMessage('Bad credentials.');
      }
    } on PlatformException catch (e) {
      print(e);
      _setErrorMessage(e.message);
    } catch (e) {
      print(e);
    }
  }

  void _setErrorMessage(String message) {
    if (message != null) {
      setState(() {
        _message = message;
      });
    }
  }

  void _resetErrorMessage() {
    _setErrorMessage(' ');
  }
}

class ResetPasswordDialog extends StatefulWidget {
  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _resetKey = GlobalKey<FormState>();
  final _resetEmailController = TextEditingController();
  String _resetEmail;
  String _resetMessage = '';

  Future<bool> _sendResetEmail() async {
    _resetEmail = _resetEmailController.text;

    if (_resetKey.currentState.validate()) {
      _resetKey.currentState.save();

      try {
        await _auth.sendPasswordResetEmail(email: _resetEmail);
        return true;
      } catch (e) {
        setState(() {
          _resetMessage = e.message;
        });
        print(e);
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Återställ lösenord",
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Form(
            key: _resetKey,
            child: ListBody(
              children: <Widget>[
                Text('Ange emailadress kopplat till kontot för att få ett mail med instruktioner för återställning av lösenordet'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                TextFormField(
                  controller: _resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validator.validateEmail,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.only(top: 15.0),
                  ),
                  onSaved: (String val) {
                    _resetEmail = val;
                  },
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _resetMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'AVBRYT',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            _sendResetEmail().then((value) {
              if (value) {
                Navigator.of(context).pop();
              }
            });
          },
        )
      ],
    );
  }
}
