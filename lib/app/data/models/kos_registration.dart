import 'package:cloud_firestore/cloud_firestore.dart';

class KosRegistration {
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
  final String ktpUrl;
  final String buktiKepemilikanUrl;
  final String namaPemilik;
  final String nomorHp;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? ownerId; // Owner's Firebase Auth UID

  KosRegistration({
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
    required this.ktpUrl,
    required this.buktiKepemilikanUrl,
    required this.namaPemilik,
    required this.nomorHp,
    this.status = 'pending',
    this.rejectionReason,
    DateTime? createdAt,
    this.updatedAt,
    this.ownerId,
  }) : createdAt = createdAt ?? DateTime.now();

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
        'ktpUrl': ktpUrl,
        'buktiKepemilikanUrl': buktiKepemilikanUrl,
        'namaPemilik': namaPemilik,
        'nomorHp': nomorHp,
        'status': status,
        'rejectionReason': rejectionReason,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'ownerId': ownerId,
      };

  factory KosRegistration.fromJson(Map<String, dynamic> json) => KosRegistration(
        id: json['id'] as String?,
        namaKos: json['namaKos'] as String,
        jenis: json['jenis'] as String,
        alamat: json['alamat'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        deskripsi: json['deskripsi'] as String,
        fasilitas: List<String>.from(json['fasilitas'] as List),
        harga: json['harga'] as int,
        uangJaminan: json['uangJaminan'] as int?,
        fotoKosUrls: List<String>.from(json['fotoKosUrls'] as List),
        ktpUrl: json['ktpUrl'] as String,
        buktiKepemilikanUrl: json['buktiKepemilikanUrl'] as String,
        namaPemilik: json['namaPemilik'] as String,
        nomorHp: json['nomorHp'] as String,
        status: json['status'] as String? ?? 'pending',
        rejectionReason: json['rejectionReason'] as String?,
        createdAt: json['createdAt'] is String 
            ? DateTime.parse(json['createdAt'] as String)
            : (json['createdAt'] as Timestamp).toDate(),
        updatedAt: json['updatedAt'] != null
            ? json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'] as String)
                : (json['updatedAt'] as Timestamp).toDate()
            : null,
        ownerId: json['ownerId'] as String?,
      );
} 