import 'package:cloud_firestore/cloud_firestore.dart';

class KostModel {
  final String? id; // Document ID from Firestore
  final String namaKos;
  final String jenis; // 'putra', 'putri', 'campur'
  final String alamat;
  final double? latitude;
  final double? longitude;
  final String deskripsi;
  final List<String> fasilitas;
  final int harga;
  final int? uangJaminan;
  final List<String> fotoKosUrls;
  final String namaPemilik;
  final String nomorHp;
  final String status; 
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String ownerId; // Owner's Firebase Auth UID
  final int kamarTersedia;
  final List<String> kebijakan;
  double distance; // Computed field for distance calculation
  String visitedAt; // Last visit timestamp

  KostModel({
    this.id,
    required this.namaKos,                 
    required this.jenis,
    required this.alamat,
    this.latitude,
    this.longitude,
    required this.deskripsi,
    required this.fasilitas,
    required this.harga,
    this.uangJaminan,
    required this.fotoKosUrls,
    required this.namaPemilik,
    required this.nomorHp,
    this.status = 'active',
    DateTime? createdAt,
    this.updatedAt,
    required this.ownerId,
    required this.kamarTersedia,
    this.kebijakan = const [],
    this.distance = 0,
    this.visitedAt = '',
  }) : createdAt = createdAt ?? DateTime.now();

  // For backward compatibility
  String get nama => namaKos;
  String get gambar => fotoKosUrls.isNotEmpty ? fotoKosUrls[0] : '';
  String get uid => ownerId;
  String get idKos => id ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'namaKos': namaKos,
        'jenis': jenis,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'deskripsi': deskripsi,
        'fasilitas': fasilitas,
        'harga': harga,
        'uangJaminan': uangJaminan,
        'fotoKosUrls': fotoKosUrls,
        'namaPemilik': namaPemilik,
        'nomorHp': nomorHp,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'ownerId': ownerId,
        'kamarTersedia': kamarTersedia,
        'kebijakan': kebijakan,
        'visitedAt': visitedAt,
      };

  factory KostModel.fromJson(Map<String, dynamic> json) => KostModel(
        id: json['id_kos'] as String?,
        namaKos: json['namaKos'] as String? ?? json['nama'] as String? ?? '',
        jenis: json['jenis'] as String? ?? '',
        alamat: json['alamat'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        deskripsi: json['deskripsi'] as String? ?? '',
        fasilitas: List<String>.from(json['fasilitas'] as List? ?? []),
        harga: json['harga'] as int? ?? 0,
        uangJaminan: json['uangJaminan'] as int?,
        fotoKosUrls: List<String>.from(json['fotoKosUrls'] as List? ?? []),
        namaPemilik: json['namaPemilik'] as String? ?? '',
        nomorHp: json['nomorHp'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        createdAt: json['createdAt'] is String 
            ? DateTime.parse(json['createdAt'] as String)
            : json['created_at'] is String
                ? DateTime.parse(json['created_at'] as String)
                : (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'] as String)
                : (json['updatedAt'] as Timestamp).toDate()
            : null,
        ownerId: json['ownerId'] as String? ?? json['uid'] as String? ?? '',
        kamarTersedia: json['kamarTersedia'] as int? ?? json['kamar_tersedia'] as int? ?? 0,
        kebijakan: List<String>.from(json['kebijakan'] as List? ?? []),
        visitedAt: json['visitedAt'] as String? ?? json['visited_at'] as String? ?? '',
      );

  // For backward compatibility
  factory KostModel.fromMap(Map<String, dynamic> map) => KostModel.fromJson(map);
}

