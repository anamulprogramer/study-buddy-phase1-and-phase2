// PHASE 2 - Provider state, CRUD, validation, local storage
class AppUser {
  final String uid, name, email, phone, role, idNumber, idStatus, passHash;
  final String? idCardPath;
  final bool active;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.idNumber = '',
    this.idStatus = 'pending', // pending | submitted | skipped
    this.passHash = '',
    this.idCardPath,
    this.active = true,
  });

  AppUser copyWith({String? name, String? phone, String? idStatus, String? idCardPath, String? passHash, bool? active}) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        idNumber: idNumber,
        idStatus: idStatus ?? this.idStatus,
        passHash: passHash ?? this.passHash,
        idCardPath: idCardPath ?? this.idCardPath,
        active: active ?? this.active,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid, 'name': name, 'email': email, 'phone': phone, 'role': role, 'idNumber': idNumber,
        'idStatus': idStatus, 'passHash': passHash, 'idCardPath': idCardPath, 'active': active,
      };

  factory AppUser.fromJson(Map<String, dynamic> m) => AppUser(
        uid: m['uid'],
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        phone: m['phone'] ?? '',
        role: m['role'] ?? 'student',
        idNumber: m['idNumber'] ?? '',
        idStatus: m['idStatus'] ?? 'pending',
        passHash: m['passHash'] ?? '',
        idCardPath: m['idCardPath'],
        active: m['active'] ?? true,
      );
}
