import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/screens/home/tiles/product_category_tile.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return ProductCategoryTile(productCategory: snapshot.data.documents[index]);
          }
        );
      },
    );
  }

  //Mantem o widget vivo sem sair da tab, assim mantem os dados sem precisa de um scopedmodel ou um bloc.
  //Porém, só é útil em casos como este, de apenas exibição.
  @override
  bool get wantKeepAlive => true;
}
