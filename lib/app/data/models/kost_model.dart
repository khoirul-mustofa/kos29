class KostModel {
  String nama;
  String alamat;
  double latitude;
  double longitude;
  int harga;
  String gambar;
  String jenis;
  List<String> fasilitas;
  List<String> kebijakan;
  double distance;
  int kamarTersedia;
  String uid;
  String idKos;
  String deskripsi;
  String createdAt;
  String visitedAt;

  KostModel({
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.harga,
    required this.gambar,
    required this.jenis,
    this.distance = 0,
    this.fasilitas = const [],
    this.kebijakan = const [],
    required this.uid,
    required this.idKos,
    required this.deskripsi,
    required this.createdAt,
    required this.visitedAt,
    required this.kamarTersedia,
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
      fasilitas: List<String>.from(map['fasilitas'] ?? []),
      kebijakan: List<String>.from(map['kebijakan'] ?? []),
      uid: map['uid'] ?? '',
      idKos: map['id_kos'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      createdAt: map['created_at'] ?? '',
      visitedAt: map['visited_at'] ?? '',
      kamarTersedia: map['kamar_tersedia'] ?? 0,
    );
  }
}
