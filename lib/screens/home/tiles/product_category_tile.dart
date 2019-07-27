import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/screens/home/widgets/edit_product_category_dialog.dart';
import 'package:virtual_store_manager/screens/product/product_screen.dart';

class ProductCategoryTile extends StatelessWidget {

  final DocumentSnapshot productCategory;

  ProductCategoryTile({@required this.productCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => EditProductCategoryDialog(
                  productCategory: productCategory,
                )
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(productCategory.data['icon']),
            ),
          ),
          title: Text(productCategory.data['title'], style: TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w500)),
          children: <Widget>[
            FutureBuilder<QuerySnapshot>(
              future: productCategory.reference.collection('items').getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Column(
                  children: snapshot.data.documents.map((doc) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(doc.data['images'][0]),
                      ),
                      title: Text(doc.data['title']),
                      trailing: Text('R\$ ${doc.data['price'].toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                productCategoryId: productCategory.documentID,
                                product: doc,
                              )
                            )
                        );
                      },
                    );
                  }).toList()
                  ..add(ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                    ),
                    title: Text('Adicionar'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productCategoryId: productCategory.documentID)));
                    },
                  )),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
