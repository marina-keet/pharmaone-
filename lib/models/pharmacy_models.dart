class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String fullName;

  User({this.id, required this.username, required this.password, required this.role, required this.fullName});

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
        'fullName': fullName,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        username: map['username'] ?? '',
        password: map['password'] ?? '',
        role: map['role'] ?? 'Caissier',
        fullName: map['fullName'] ?? '',
      );
}

class Product {
  final int? id;
  final String name;
  final String category;
  final String barcode;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final String manufactureDate;
  final String expiryDate;
  final String supplier;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.manufactureDate,
    required this.expiryDate,
    required this.supplier,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'barcode': barcode,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'quantity': quantity,
        'manufactureDate': manufactureDate,
        'expiryDate': expiryDate,
        'supplier': supplier,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'] ?? '',
        category: map['category'] ?? '',
        barcode: map['barcode'] ?? '',
        purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0,
        salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0,
        quantity: map['quantity'] ?? 0,
        manufactureDate: map['manufactureDate'] ?? '',
        expiryDate: map['expiryDate'] ?? '',
        supplier: map['supplier'] ?? '',
      );
}

class Supplier {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String note;

  Supplier({this.id, required this.name, required this.phone, required this.address, required this.note});

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'note': note,
      };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
        id: map['id'],
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
        note: map['note'] ?? '',
      );
}

class Client {
  final int? id;
  final String name;
  final String phone;
  final String address;

  Client({this.id, required this.name, required this.phone, required this.address});

  Map<String, Object?> toMap() => {'id': id, 'name': name, 'phone': phone, 'address': address};

  factory Client.fromMap(Map<String, dynamic> map) => Client(
        id: map['id'],
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
      );
}

class PharmacySettings {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String currency;
  final double taxRate;
  final String logoPath;

  PharmacySettings({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.currency,
    required this.taxRate,
    required this.logoPath,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'currency': currency,
        'taxRate': taxRate,
        'logoPath': logoPath,
      };

  factory PharmacySettings.fromMap(Map<String, dynamic> map) => PharmacySettings(
        id: map['id'],
        name: map['name'] ?? 'PharmaOne',
        address: map['address'] ?? '',
        phone: map['phone'] ?? '',
        currency: map['currency'] ?? 'CDF',
        taxRate: (map['taxRate'] as num?)?.toDouble() ?? 16.0,
        logoPath: map['logoPath'] ?? '',
      );
}
