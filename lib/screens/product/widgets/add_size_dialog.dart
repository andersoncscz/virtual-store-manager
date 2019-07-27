import 'package:flutter/material.dart';

class AddSizeDialog extends StatelessWidget {

  final _sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _sizeController,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: () {
                  //Passa o texto para tela anterior
                  Navigator.pop(context, _sizeController.text);
                },
                child: Text(
                  'Add', 
                  style: TextStyle(color: Theme.of(context).primaryColor)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}