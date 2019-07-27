import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductsBloc extends BlocBase {

  String productCategoryId;
  DocumentSnapshot product;

  final _productsController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get streamProducts => _productsController.stream;
  Stream<bool> get streamLoading => _loadingController.stream;
  Stream<bool> get streamCreated => _createdController.stream;

  Map<String, dynamic> editingData;

  ProductsBloc({this.productCategoryId, this.product}) {
    if (product != null) {
      //Clona os dados para serem editados
      editingData = Map.of(product.data);
      //Cria lista que pode ser expandivel para adição de novas imagens e tamanhos de roupa
      editingData['images'] = List.of(product.data['images']);
      editingData['sizes'] = List.of(product.data['sizes']);
      //Se produto ja existe para edicao, envia true pela stream
      _createdController.add(true);
    }
    else {
      editingData = {
        'title': null,
        'description': null,
        'price': null,
        'images': [],
        'sizes': []
      };
      //Se produto ja existe para edicao, envia false pela stream
      _createdController.add(false);
    }
    
    //Envia vazio, se estiver inserindo novo, ou existe se estiver editando.
    _productsController.add(editingData);

  }


  void saveTitle(String text) {
    editingData['title'] = text;
  }

  void saveDescription(String text) {
    editingData['description'] = text;
  }

  void savePrice(String text) {
    editingData['price'] = double.parse(text);
  }  

  void saveImages(List images) {
    editingData['images'] = images;
  }

  void saveSizes(List sizes) {
    editingData['sizes'] = sizes;
  }  

  Future<bool> save() async {
    
    _loadingController.add(true);

    try {
      if (product != null) {
        //Esta editando um product já cadastrado.
        await _uploadImages(product.documentID);
        await product.reference.updateData(editingData);
      }
      else {
        //Esta inserindo um produto novo.
        //Primeiramente salva todos os dados do produto, sem as imagens, pois é necessário ter o id do produto para salvar as imagens depois.
        DocumentReference doc = await Firestore.instance
          .collection('products')
          .document(productCategoryId)
          .collection('items')
          .add(Map.from(editingData)..remove('images'));

        //Faz os uploads do produto, já com o id.
        await _uploadImages(doc.documentID);
        //Atualiza os dados do produto, já com as URLs das imagens.
        await doc.updateData(editingData);
      }
      
      _createdController.add(true);
      _loadingController.add(false);
      return true;
    } 
    catch (e) {
      _loadingController.add(false);
      return false;
    }

  }

  Future<void> _uploadImages(String productId) async {
    //Percorre as imagens
    for (int i = 0; i < editingData['images'].length; i++) {
      //Verifica se a imagem atual é uma String, se for é porque é uma URL do firebase, então ignora o upload dela.
      if (editingData['images'][i] is String) continue;

      //Se é um arquivo, então faz o upload.
      StorageUploadTask uploadTask = FirebaseStorage.instance.ref()
        .child(productCategoryId)
        .child(productId)
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(editingData['images'][i]);

      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      //Após o upload, troca o arquivo pela url da imagem que fez upload
      editingData['images'][i] = downloadUrl;
    }
  }

  
  void delete() => product.reference.delete();


  @override
  void dispose() {
    _productsController.close();
    _loadingController.close();
    _createdController.close();
  }

}