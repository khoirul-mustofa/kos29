class KostModel {
  String nama;
  String alamat;
  double latitude;
  double longitude;
  int harga;
  String gambar;
  String jenis;
  double distance;
  String uid;
  String idKos;
  double? jarak;

  KostModel({
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.harga,
    required this.gambar,
    required this.jenis,
    this.distance = 0,
    required this.uid,
    required this.idKos,
    this.jarak,
  });

  factory KostModel.fromMap(Map<String, dynamic> map) {
    return KostModel(
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      harga: map['harga']?.toInt() ?? 0,
      gambar: map['gambar'] ?? '',
      jenis: map['jenis'] ?? '',
      uid: map['uid'] ?? '',
      idKos: map['id_kos'] ?? '',
      jarak: map['jarak']?.toDouble() ?? 0.0,
    );
  }
}
