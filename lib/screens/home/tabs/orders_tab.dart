import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:virtual_store_manager/blocs/orders/orders_bloc.dart';
import 'package:virtual_store_manager/screens/home/tiles/order_tile.dart';

class OrdersTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final _ordersBloc = BlocProvider.of<OrdersBloc>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<List>(
        stream: _ordersBloc.streamOrders,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            );
          }
          else if (snapshot.data.length == 0) {
            return Center(
              child: Text('Nenhum pedido encontrado!', style: TextStyle(color: Theme.of(context).primaryColor)),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return OrderTile(order: snapshot.data[index]);
            }
          );
        }
      ),
    );
  }
}
