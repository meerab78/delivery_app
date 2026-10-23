// One row of the addresses table.
class AddressModel {
  final String id;
  final String label; // Home, Office, Other
  final String fullAddress;
  final double? lat; // we will fill these when we add the map
  final double? lng;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
      lat: json['lat'] == null ? null : double.parse(json['lat'].toString()),
      lng: json['lng'] == null ? null : double.parse(json['lng'].toString()),
      isDefault: json['is_default'] as bool,
    );
  }
}