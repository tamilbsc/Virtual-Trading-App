import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String mobile;
  final String username;
  final String email;
  final String uid;
  String passwordHash; // SHA-256 hex hash

  bool isKycVerified;
  String kycFullName;
  String kycDob; // dd/MM/yyyy
  String kycPan;
  String kycAadhaar; // last 4 digits shown, full stored
  String kycAddress;
  final DateTime createdAt;

  UserModel({
    required this.mobile,
    required this.username,
    required this.email,
    required this.uid,
    required this.passwordHash,
    this.isKycVerified = false,
    this.kycFullName = '',
    this.kycDob = '',
    this.kycPan = '',
    this.kycAadhaar = '',
    this.kycAddress = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'username': username,
      'email': email,
      'uid': uid,
      'isKycVerified': isKycVerified,
      'kycFullName': kycFullName,
      'kycDob': kycDob,
      'kycPan': kycPan,
      'kycAadhaar': kycAadhaar,
      'kycAddress': kycAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      mobile: map['mobile'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      passwordHash: map['passwordHash'] ?? '', 
      isKycVerified: map['isKycVerified'] ?? false,
      kycFullName: map['kycFullName'] ?? '',
      kycDob: map['kycDob'] ?? '',
      kycPan: map['kycPan'] ?? '',
      kycAadhaar: map['kycAadhaar'] ?? '',
      kycAddress: map['kycAddress'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      mobile: data['mobile'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      uid: doc.id,
      passwordHash: data['passwordHash'] ?? '',
      isKycVerified: data['isKycVerified'] ?? false,
      kycFullName: data['kycFullName'] ?? '',
      kycDob: data['kycDob'] ?? '',
      kycPan: data['kycPan'] ?? '',
      kycAadhaar: data['kycAadhaar'] ?? '',
      kycAddress: data['kycAddress'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mobile': mobile,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'isKycVerified': isKycVerified,
      'kycFullName': kycFullName,
      'kycDob': kycDob,
      'kycPan': kycPan,
      'kycAadhaar': kycAadhaar,
      'kycAddress': kycAddress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
