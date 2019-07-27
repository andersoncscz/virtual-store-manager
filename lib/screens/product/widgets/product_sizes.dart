import 'package:flutter/material.dart';

import 'add_size_dialog.dart';

class ProductSizes extends FormField<List> {
  ProductSizes({
    BuildContext context,
    List initialValue,
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
  }) 
  : super(
    initialValue: initialValue,
    onSaved: onSaved,
    validator: validator,
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 34,
            child: GridView(
              padding: EdgeInsets.symmetric(vertical: 4),
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                childAspectRatio: 0.5 //AspectRatio = altura / largura
              ),
              children: state.value.map<Widget>((size){
                return GestureDetector(
                  onLongPress: () {
                    state.didChange(state.value..remove(size));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                        color: Theme.of(context).primaryColor, 
                        width: 3
                      ),
                    ),
                    child: Text(size, style: TextStyle(color: Colors.white)),
                  ),
                );
              }).toList()..add(
                GestureDetector(
                  onTap: () async {
                    String size = await showDialog(
                      context: context,
                      builder: (context) => AddSizeDialog()
                    );
                    if (size != null) {
                      //Adiciona o tamanho
                      state.didChange(state.value..add(size));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                        color: state.hasError ? Colors.red : Theme.of(context).primaryColor, 
                        width: 3
                      ),
                    ),
                    child: Text('+', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          state.hasError ? Text(state.errorText, style: TextStyle(color: Colors.red, fontSize: 12)) : Container(),
        ],
      );
    }
  );
}