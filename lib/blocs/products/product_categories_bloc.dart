import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:io';
import 'dart:async';

class ProductsCategoriesBloc extends BlocBase {

  final _titleController = BehaviorSubject<String>();
  final _deleteController = BehaviorSubject<bool>();
  final _imageController = BehaviorSubject(); //Este controller aceitará URLs e Files
  final _loadingController = BehaviorSubject<bool>();
  
  File image;
  String title;

  DocumentSnapshot productCategory;

  Stream<String> get streamTitle => _titleController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink) {
      if (title.isEmpty) {
        sink.addError('Insira um titulo.');
      }
      else {
        sink.add(title);
      }
    }
  ));
  Stream<bool> get streamDelete => _deleteController.stream;
  Stream<bool> get streamLoading => _loadingController.stream;
  Stream get streamImage => _imageController.stream;
  Stream<bool> get streamSubmit => Observable.combineLatest2(streamTitle, streamImage, (t, i) => true);

  ProductsCategoriesBloc({this.productCategory}) {
    if (productCategory != null) {
      //Categoria já existe
      title = productCategory.data['title'];
      _titleController.add(productCategory.data['title']);
      _imageController.add(productCategory.data['icon']);
      _deleteController.add(true);
    }
    else {
      _deleteController.add(false);
    }
  }

  void setImage(File file) {
    image = file;
    _imageController.add(file);
  }

  void setTitle(String text) {
    title = text;
    _titleController.add(text);
  }


  Future<bool> save() async {
    
    //Se não teve imagem selecionada e o titulo não mudou, então não houve alterações. Nada a fazer.
    if (image == null && productCategory != null && productCategory.data['title'] == title) return true;
    if (await Firestore.instance.collection('products').document(title).get() != null) return false;

    try {

      Map<String, dynamic> dataToUpdate = {};


      _loadingController.add(true);
      //Faz upload da imagem selecionada, seja alteração ou inclusão.
      if (image != null) {

        StorageUploadTask task = FirebaseStorage.instance.ref()
          .child('icons')
          .child(title)
          .putFile(image);

        StorageTaskSnapshot snapshot = await task.onComplete;
        dataToUpdate['icon'] = await snapshot.ref.getDownloadURL();

      }

      //Verifica se é inclusão ou se o title foi alterado (alteração), se foi grava.
      if (productCategory == null || title != productCategory.data['title']) {
        dataToUpdate['title'] = title;
      }

      
      if (productCategory == null) {
        //Insert
        await Firestore.instance
          .collection('products')
          .document(title.toLowerCase())
          .setData(dataToUpdate);
      }
      else {
        //Update
        productCategory.reference.updateData(dataToUpdate);
      }

      _loadingController.add(false);  
      return true;

    } catch (e) {

      _loadingController.add(false);
      return false;

    }

  }

  void delete() {
    //Deleta a categoria
    productCategory.reference.delete();
    //Apaga a imagem do Bucket
    FirebaseStorage.instance.ref()
      .child('icons')
      .child(productCategory.documentID)
      .delete();
  }

  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteController.close();
    _loadingController.close();
  }
}