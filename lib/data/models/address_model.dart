class AddressModel {
  final String id;
  final String name;
  final String provinsi;
  final String kabupaten;
  final String kecamatan;
  final String kelurahan;
  final String detail;
  final String? user;

  AddressModel({
    required this.id,
    required this.name,
    required this.provinsi,
    required this.kabupaten,
    required this.kecamatan,
    required this.kelurahan,
    required this.detail,
    this.user,
  });

  String get fullAddress => '$detail, $kelurahan, $kecamatan, $kabupaten, $provinsi';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kabupaten: json['kabupaten']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      kelurahan: json['kelurahan']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      user: json['user']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'provinsi': provinsi,
        'kabupaten': kabupaten,
        'kecamatan': kecamatan,
        'kelurahan': kelurahan,
        'detail': detail,
        if (user != null) 'user': user,
      };
}
