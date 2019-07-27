import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/orders/orders_bloc.dart';
import 'package:virtual_store_manager/constants/order_constants.dart';
import 'package:virtual_store_manager/screens/home/widgets/order_header.dart';

class OrderTile extends StatelessWidget {

  final DocumentSnapshot order;
  OrderTile({@required this.order});


  @override
  Widget build(BuildContext context) {

    final _ordersBloc = BlocProvider.of<OrdersBloc>(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          key: Key(order.documentID),
          initiallyExpanded: order.data['status'] != OrderStatus.delivered,
          title: Text(
            '${order.documentID.substring(order.documentID.length-7, order.documentID.length)} - ${OrderStatus.statusMap[order.data['status']]}',
            style: TextStyle(color: order.data['status'] != OrderStatus.delivered ? Colors.grey[850] : Colors.green)
          ),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OrderHeader(order: order),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: order.data['products'].map<Widget>((p) {
                      return ListTile(
                        title: Text(p['product']['title'] + ' ' + p['size']),
                        subtitle: Text(p['category'] + '/' + p['product_id']),
                        trailing: Text(p['quantity'].toString(), style: TextStyle(fontSize: 20)),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () => _ordersBloc.deleteOrder(order),
                        textColor: Colors.red,
                        child: Text('Excluir'),
                      ),
                      FlatButton(
                        onPressed: order.data['status'] > OrderStatus.inProgress ? () => _ordersBloc.changeToPreviousOrderStatus(order) : null,
                        textColor: Colors.grey,
                        child: Text('Regredir'),
                      ),
                      FlatButton(
                        onPressed: order.data['status'] < OrderStatus.delivered ? () => _ordersBloc.changeToNextOrderStatus(order) : null,
                        textColor: Colors.green,
                        child: Text('Avançar'),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
