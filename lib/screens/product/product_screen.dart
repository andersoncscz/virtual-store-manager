import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/products/products_bloc.dart';
import 'package:virtual_store_manager/screens/product/widgets/product_sizes.dart';
import 'package:virtual_store_manager/validators/product_validators.dart';

import 'widgets/images_widget.dart';

class ProductScreen extends StatefulWidget {

  final String productCategoryId;
  final DocumentSnapshot product;

  ProductScreen({this.productCategoryId, this.product});

  @override
  _ProductScreenState createState() => _ProductScreenState(productCategoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {
  

  final ProductsBloc _productsBloc;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  _ProductScreenState(String productCategoryId, DocumentSnapshot product) : 
    _productsBloc = ProductsBloc(productCategoryId: productCategoryId, product: product);

  @override
  Widget build(BuildContext context) {

    final _fieldStyle = TextStyle(color: Colors.white, fontSize: 16);

    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey)
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
          initialData: false,
          stream: _productsBloc.streamCreated,
          builder: (context, snapshot) => Text(snapshot.data ? 'Alterar Produto' : 'Adicionar Produto')
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productsBloc.streamCreated,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data) {
                return StreamBuilder<bool>(
                  stream: _productsBloc.streamLoading,
                  initialData: false,
                  builder: (context, snapshot) {
                    return IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: snapshot.data ? null : () {
                        _productsBloc.delete();
                        Navigator.pop(context);
                      },
                    );
                  }
                );
              }
              return Container();
            }
          ),
          StreamBuilder<bool>(
            stream: _productsBloc.streamLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.save),
                onPressed: snapshot.data ? null : saveProduct,
              );
            }
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
              stream: _productsBloc.streamProducts,
              builder: (context, snapshot) {

                if (!snapshot.hasData) return Container();

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    Text('Imagens', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ImagesWidget(
                      context: context,
                      initialValue: snapshot.data['images'],
                      onSaved: _productsBloc.saveImages,
                      validator: validateImages,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['title'],
                      style: _fieldStyle, 
                      decoration: _buildDecoration('Titulo'), 
                      onSaved: _productsBloc.saveTitle, 
                      validator: validateTitle,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['description'],
                      style: _fieldStyle, 
                      decoration: _buildDecoration('Descrição'),
                      maxLines: 6,
                      onSaved: _productsBloc.saveDescription, 
                      validator: validateDescription,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['price']?.toStringAsFixed(2),
                      style: _fieldStyle, 
                      decoration: _buildDecoration('Preço'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onSaved: _productsBloc.savePrice, 
                      validator: validatePrice,
                    ),
                    SizedBox(height: 16),
                    Text('Tamanhos', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ProductSizes(
                      context: context,
                      initialValue: snapshot.data['sizes'],
                      onSaved: _productsBloc.saveSizes,
                      validator: validateSize,
                    )
                  ],
                );
              }
            ),
          ),
          StreamBuilder<bool>(
            stream: _productsBloc.streamLoading,
            initialData: false,
            builder: (context, snapshot) {
              //Cria uma tela por cima na qual bloqueia a tela enquanto esta salvando para que o usuário não edite nada.
              return IgnorePointer(
                ignoring: !snapshot.data,
                child: Container(
                  color: snapshot.data ? Colors.black54 : Colors.transparent,
                ),
              );
            }
          )
        ]
      ),
    );
  }

  void saveProduct() async {
    if (_formKey.currentState.validate()) {
      //Com tudo validado, chamara on onSaved de todos TextFormField
      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('Salvando...', style: TextStyle(color: Colors.white)),
        )
      );

      bool success = await _productsBloc.save();
      _scaffoldKey.currentState.removeCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(success ? 'Salvo com sucesso' : 'Erro ao salvar.', style: TextStyle(color: Colors.white)),
        )
      );
    }    
  }

}
