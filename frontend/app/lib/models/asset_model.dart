import "package:aw40_hub_frontend/models/asset_definition_model.dart";
import "package:aw40_hub_frontend/models/publication_model.dart";

class AssetModel {
  AssetModel({
    required this.id,
    required this.name,
    required this.definition,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.author,
    required this.dataStatus,
    required this.publication,
  });

  String? id; // TODO make non-nullable?
  String name;
  AssetDefinitionModel definition;

  String description;
  DateTime? timestamp;
  String? type;
  String author;
  String? dataStatus;
  PublicationModel? publication;
}
