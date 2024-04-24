class Agence{
  String id;
  String bank_id;
  String name;
  final LocationBranch locationBranch;

  Agence({required this.id,required this.bank_id, required this.name, required this.locationBranch});

  factory Agence.fromJson(Map<String, dynamic> json) {
    try {
      final lb = json['locationBranch'];
      final latitude = lb['latitude'] != null ? (double.tryParse(lb['latitude'].toString().replaceAll(',', '.')) ?? 0) : 0;
      final longitude = lb['longitude'] != null ? (double.tryParse(lb['longitude'].toString().replaceAll(',', '.')) ?? 0) : 0;
      final locationBranch = LocationBranch(latitude: latitude.toDouble(), longitude: longitude.toDouble());

      return Agence(
        id: json['id'] ?? '',
        bank_id: json['bank_id'] ?? '',
        name: json['name'] ?? '',
        locationBranch: locationBranch,
        // Add more properties as needed
      );
    } catch (e) {
      print('Error parsing latitude or longitude: $e');
      rethrow; // Rethrow the exception for further debugging
    }
  }

  @override
  String toString() {
    return 'Agence{id: $id, bank_id: $bank_id, name: $name, locationBranch: $locationBranch}';
  }
}
class LocationBranch{
  double latitude;
  double longitude;

  //LocationBranch(this.latitude, this.longitude);
  LocationBranch({ required this.latitude, required this.longitude});

}