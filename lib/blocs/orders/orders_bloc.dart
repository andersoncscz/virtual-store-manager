import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:virtual_store_manager/constants/order_constants.dart';


enum SortCriteria {
  FINISHED_FIRST,
  FINISHED_LAST
}

class OrdersBloc extends BlocBase {

  final _ordersController = BehaviorSubject<List>();
  Stream<List> get streamOrders => _ordersController.stream;

  List<DocumentSnapshot> _orders = [];
  Firestore _firestore = Firestore.instance;

  SortCriteria _currentSortCriteria;

  OrdersBloc() {
    _addOrdersListener();
  }

  void _addOrdersListener() {
    _firestore.collection('orders').snapshots().listen((snapshot) {
      snapshot.documentChanges.forEach((change) {
        String oid = change.document.documentID;

        switch(change.type) {
          case DocumentChangeType.added:
            _orders.add(change.document); //Add a ref. do documento na lista.
            break;
          case DocumentChangeType.modified:
            _orders.removeWhere((order) => order.documentID == oid); //Remove a ref. do documento antiga da lista, e adiciona o novo.
            _orders.add(change.document); //Add o novo.
            break;
          case DocumentChangeType.removed:
            _orders.removeWhere((order) => order.documentID == oid); //Remove a ref. do documento antiga da lista, e adiciona o novo.
            break;
        }
      });

      _sort();
      
    });
  }

  /*
   Alterações abaixo no banco já vão ativar o listener: _addOrdersListener, que escuta a collection('orders') e atualizar os dados
     changeToPreviousOrderStatus()
     changeToNextOrderStatus()
     deleteOrder()
   */
  void changeToPreviousOrderStatus(DocumentSnapshot order) {

    if (order.data['status'] > OrderStatus.inProgress) {
      order.reference.updateData({'status' : order.data['status'] - 1});
    }

  }


  void changeToNextOrderStatus(DocumentSnapshot order) {
    if (order.data['status'] < OrderStatus.delivered) {
      order.reference.updateData({'status' : order.data['status'] + 1});
    }
  }


  void deleteOrder(DocumentSnapshot order) {
    //Primeiro: Apaga pedido dos pedidos do usuário
    _firestore
        .collection('users')
        .document(order['user_id'])
        .collection('orders')
        .document(order.documentID)
        .delete();

    //Segundo: Apaga o pedido definitivamente
    order.reference.delete();
  }

  void setOrderCriteria(SortCriteria criteria) {
    _currentSortCriteria = criteria;
    _sort();
  }

  void _sort() {
    switch (_currentSortCriteria) {
      case SortCriteria.FINISHED_FIRST:
        _orders.sort((a, b) {
          int sa = a.data['status'];
          int sb = b.data['status'];

          if (sa < sb) return 1;
          else if(sa > sb) return -1;
          return 0;
        });
        break;
      case SortCriteria.FINISHED_LAST:
        _orders.sort((a, b) {
          int sa = a.data['status'];
          int sb = b.data['status'];

          if (sa > sb) return 1;
          else if(sa < sb) return -1;
          return 0;
        });
        break;
    }

    //Envia os dados ordenados pela stream
    _ordersController.add(_orders);
  }

  @override
  void dispose() {
    _ordersController.close();
  }

}