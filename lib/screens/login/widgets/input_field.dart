import 'package:flutter/material.dart';

class InputField extends StatelessWidget {

  final IconData icon;
  final String hint;
  final bool obscure;
  final Stream<String> stream;
  final Function(String) onChanged;

  InputField({@required this.icon, @required this.hint, @required this.obscure, @required this.stream, this.onChanged});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          obscureText: obscure,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 5, right: 22, bottom: 22, top: 22),
            icon: Icon(icon, color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor
                )
            ),
            errorText: snapshot.hasError ? snapshot.error : null
          ),
        );
      },
    );
  }
}
