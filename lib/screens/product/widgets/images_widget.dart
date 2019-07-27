import 'package:flutter/material.dart';
import 'image_source_sheet.dart';

class ImagesWidget extends FormField<List>{

  ImagesWidget({
    BuildContext context,
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
    List initialValue,
    bool autoValidate = false,
  }) : super (
    onSaved: onSaved,
    validator: validator,
    initialValue: initialValue,
    autovalidate: autoValidate,
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 124,
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: state.value.map<Widget>((image) {
                return Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    child: image is String 
                      ? Image.network(image, fit: BoxFit.cover) //Url da imagem que já existe no firebase.
                      : Image.file(image, fit: BoxFit.cover), //Arquivo selecionado da galeria pelo usuário.
                    onLongPress: () {
                      //Remove imagem da lista
                      state.didChange(state.value..remove(image));
                    },
                  ),
                );
              }).toList()..add(
                GestureDetector(
                  child: Container(
                    color: Colors.white.withAlpha(50),
                    height: 100,
                    width: 100,
                    child: Icon(Icons.camera_enhance, color: Colors.white),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context, 
                      builder: (context) => ImageSourceSheet(
                        onImageSelected: (image) {
                          //Adiciona nova imagem na lista
                          state.didChange(state.value..add(image));
                          Navigator.pop(context);
                        },
                      )
                    );
                  },
                )
              ),
            ),
          ),
          state.hasError ? Text(state.errorText, style: TextStyle(color: Colors.red, fontSize: 12)) : Container(),
        ],
      );
    }
  );

}