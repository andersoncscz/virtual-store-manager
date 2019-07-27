import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/products/product_categories_bloc.dart';

import 'dart:io';

import 'package:virtual_store_manager/screens/product/widgets/image_source_sheet.dart';


class EditProductCategoryDialog extends StatefulWidget {

  final DocumentSnapshot productCategory;
  EditProductCategoryDialog({this.productCategory});


  @override
  _EditProductCategoryDialogState createState() => _EditProductCategoryDialogState(productCategory: productCategory);
}

class _EditProductCategoryDialogState extends State<EditProductCategoryDialog> {

  final ProductsCategoriesBloc _productsCategoriesBloc;
  final TextEditingController _controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _EditProductCategoryDialogState({DocumentSnapshot productCategory}) : 
  _productsCategoriesBloc = ProductsCategoriesBloc(productCategory: productCategory),
  _controller = TextEditingController(text: productCategory != null ? productCategory.data['title'] : ''); //Inicializa com o texto da categoria.

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget> [
          Dialog(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(context: context, builder: (context) => ImageSourceSheet(
                          onImageSelected: (image) {
                            Navigator.pop(context);
                            _productsCategoriesBloc.setImage(image);
                          },
                        ));
                      },
                      child: StreamBuilder(
                        stream: _productsCategoriesBloc.streamImage,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: snapshot.data is File 
                                ? FileImage(snapshot.data)
                                : NetworkImage(snapshot.data),
                            );
                          }
                          else {
                            return Icon(Icons.image);
                          }
                        }
                      ),
                    ),
                    title: StreamBuilder<String>(
                      stream: _productsCategoriesBloc.streamTitle,
                      builder: (context, snapshot) {
                        return TextField(
                          controller: _controller,
                          onChanged: _productsCategoriesBloc.setTitle,
                          decoration: InputDecoration(
                            errorText: snapshot.hasError ? snapshot.error : null
                          ),
                        );
                      }
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      StreamBuilder<bool>(
                        stream: _productsCategoriesBloc.streamDelete,
                        builder: (context, snapshot) {
                          return !snapshot.hasData
                            ? Container()
                            : FlatButton(
                            onPressed: snapshot.data ? () {
                              _productsCategoriesBloc.delete();
                              Navigator.of(context).pop();
                            } : null,
                            child: Text('Excluir', style: TextStyle(color: Colors.red)),
                          );
                        }
                      ),
                      StreamBuilder<bool>(
                        stream: _productsCategoriesBloc.streamSubmit,
                        builder: (context, snapshot) {
                          return FlatButton(
                            onPressed: snapshot.hasData ? saveProductCategory : null,
                            child: Text('Salvar'),
                          );
                        }
                      ),                
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<bool>(
            stream: _productsCategoriesBloc.streamLoading,
            initialData: false,
            builder: (context, snapshot) {
              //Cria uma tela por cima na qual bloqueia a tela enquanto esta salvando para que o usuário não feche o dialog antes do Navigator.pop da tela anterior.
              return IgnorePointer(
                ignoring: !snapshot.data,
                child: Container(
                  color: snapshot.data ? Colors.black54 : Colors.transparent,
                  child: snapshot.data ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    ),
                  ) : null,
                ),
              );
            }
          )
        ]
      );
  }

  void saveProductCategory() async {
    bool success = await _productsCategoriesBloc.save();
    Navigator.pop(context, success);
  }
}