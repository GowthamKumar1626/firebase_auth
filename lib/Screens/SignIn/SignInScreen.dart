import 'package:farmx_auth/CommonWidgets/ExceptionAlertDialogue.dart';
import 'package:farmx_auth/Screens/SignIn/EmailSignInScreen.dart';
import 'package:farmx_auth/Screens/SignIn/PhoneSignInFormBloc.dart';
import 'package:farmx_auth/Screens/SignIn/SignInBloc.dart';
import 'package:farmx_auth/Services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPageScreen extends StatelessWidget {
  const SignInPageScreen({required this.bloc});
  final SignInBloc bloc;
  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(auth: auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<SignInBloc>(
        builder: (_, bloc, __) => SignInPageScreen(bloc: bloc),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == "ERROR_ABORTED_BY_USER") {
      return;
    }
    showExceptionAlertDialog(
      context,
      title: "Sign in Failed",
      exception: exception,
    );
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await bloc.signInAnonymously();
    } on Exception catch (error) {
      _showSignInError(context, error);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on Exception catch (error) {
      _showSignInError(context, error);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SignInBloc>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("FarmX"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<bool>(
          stream: bloc.isLoadingStream,
          initialData: false,
          builder: (context, snapshot) {
            return _buildContent(context, snapshot.data);
          }),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context, bool? isLoading) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(isLoading!),
          ),
          PhoneSignInFormBloc.create(context),
          // SignInWithPhone(),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.phone,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.mail,
                  ),
                  onPressed: isLoading ? null : () => _signInWithEmail(context),
                ),
                IconButton(
                  icon: Image.asset("assets/icons/anonymous.png"),
                  onPressed:
                      isLoading ? null : () => _signInAnonymously(context),
                ),
                IconButton(
                  icon: Image.asset("assets/icons/icons8-google.png"),
                  onPressed:
                      isLoading ? null : () => _signInWithGoogle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      "Sign In",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
