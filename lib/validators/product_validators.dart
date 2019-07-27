class ProductValidator {

  String validateTitle(String text) {
    if (text.isEmpty) return 'Preencha o titulo.';
    return null;
  }

  String validateDescription(String text) {
    if (text.isEmpty) return 'Preencha a descrição.';
    return null;
  }

  String validatePrice(String text) {
    double price = double.tryParse(text);
    if (price != null) {
      //valida se não contem '.' OU se possui mais de 2 casas decimais.
      if (!text.contains('.') || text.split('.')[1].length != 2) {
        return 'Utilize 2 casas decimais.';
      }
    }
    else {
      return 'Formato inválido de preço.';
    }
    return null;
  }

  String validateImages(List images) {
    if (images.isEmpty) {
      return 'Adicione ao menos uma imagem.';
    }
    return null;
  }

  String validateSize(List sizes) {
    if (sizes.isEmpty) return 'Informe um tamanho.';
    return null;    
  }

}