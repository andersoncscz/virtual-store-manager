import 'dart:async';

//StreamTransformer: É um transformador. Possui entrada e saída assim como o StreamController, porém consegue processar os dados antes de envia-los ao StreamController.

class LoginValidators {

  //StreamTransformer => Processa o dado que passa dentro de um StreamController, como se fosse um filtro;
  //Neste caso possui o tipo String como entrada, e String também como saída.

  final validateEmail = StreamTransformer<String, String>.fromHandlers(

    //handleData => Função de callback que irá processar os dados;
    handleData: (email, sink) {
      //Valida se o email contain o @, se sim, envia o dado para um StreamController, senão envia uma mensagem de erro.
      if (email.contains("@")) {
        sink.add(email);
      }
      else {
        sink.addError('e-mail inválido.');
      }
    }
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if(password.length >= 6) {
        sink.add(password);
      }
      else {
        sink.addError('Senha inválida. Informe ao menos 6 caracteres');
      }
    }
  );

}