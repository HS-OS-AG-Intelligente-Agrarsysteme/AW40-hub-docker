class NewPublicationModel {
  NewPublicationModel({
    required this.network,
    required this.license,
    required this.price,
    required this.privateKey,
  });

  String network;
  String license;
  double? price;
  String privateKey;
}
