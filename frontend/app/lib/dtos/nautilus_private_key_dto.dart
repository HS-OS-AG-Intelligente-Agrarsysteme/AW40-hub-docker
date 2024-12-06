import "package:json_annotation/json_annotation.dart";

part "nautilus_private_key_dto.g.dart";

@JsonSerializable()
class NautilusPrivateKeyDto {
  NautilusPrivateKeyDto(
    this.nautilusPrivateKey,
  );

  factory NautilusPrivateKeyDto.fromJson(Map<String, dynamic> json) =>
      _$NautilusPrivateKeyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NautilusPrivateKeyDtoToJson(this);

  @JsonKey(name: "nautilus_private_key")
  String nautilusPrivateKey;
}
