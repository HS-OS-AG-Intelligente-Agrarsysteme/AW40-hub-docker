class PublicationModel {
  PublicationModel({
    required this.network,
    required this.license,
    required this.price,
    required this.did,
    required this.assetUrl,
  });

  String network;
  String license;
  int? price;
  String did;
  String assetUrl;
}
