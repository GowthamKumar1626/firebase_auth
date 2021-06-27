import 'package:farmx_auth/CommonWidgets/ExceptionAlertDialogue.dart';
import 'package:farmx_auth/Screens/SignIn/validators.dart';
import 'package:farmx_auth/Services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInWithPhone extends StatefulWidget with EmailAndPasswordValidators {
  @override
  _SignInWithPhoneState createState() => _SignInWithPhoneState();
}

class _SignInWithPhoneState extends State<SignInWithPhone> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  String get _phoneNumber => _phoneNumberController.text;

  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signInWithPhoneNumber(_phoneNumber, context, null);

      FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
    } on FirebaseAuthException catch (error) {
      showExceptionAlertDialog(context,
          title: "Sign in Failed", exception: error);
    }
  }

  List<Widget> _buildChildren() {
    final primaryText = "Confirm";

    return [
      _buildPhoneNumberField(),
      SizedBox(
        height: 15.0,
      ),
      _buildHeader(primaryText),
    ];
  }

  TextField _buildPhoneNumberField() {
    bool showErrorText = _submitted &&
        !widget.phoneNumberValidator.isValidPhoneNumber(_phoneNumber);
    return TextField(
      controller: _phoneNumberController,
      cursorHeight: 22.0,
      decoration: InputDecoration(
        labelText: "Phone number",
        enabled: _isLoading == false,
        errorText: showErrorText ? widget.invalidPhoneNumberErrorText : null,
      ),
      autocorrect: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (email) => _updateState(),
      focusNode: _phoneNumberFocusNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String primaryText) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ElevatedButton(
      // onPressed: !_submitted ? _submit : null,
      onPressed: widget.phoneNumberValidator.isValidPhoneNumber(_phoneNumber)
          ? _isLoading
              ? null
              : _submit
          : null,
      child: Text(
        "$primaryText",
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }
}
