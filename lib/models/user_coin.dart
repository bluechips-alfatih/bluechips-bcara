// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserCoin {
  final String walletAddress;
  final String privateKey;
  final String email;
  final int coinOnHold;
  final int coinSell;
  final int coinBuy;
  final double totalCoinUser;
  final int danaUser;
  UserCoin({
    required this.walletAddress,
    required this.privateKey,
    required this.email,
    required this.coinOnHold,
    required this.coinSell,
    required this.coinBuy,
    required this.totalCoinUser,
    required this.danaUser,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'walletAddress': walletAddress,
      'privateKey': privateKey,
      'email': email,
      'coinOnHold': coinOnHold,
      'coinSell': coinSell,
      'coinBuy': coinBuy,
      'totalCoinUser': totalCoinUser,
      'danaUser': danaUser,
    };
  }

  factory UserCoin.fromMap(Map<String, dynamic> map) {
    return UserCoin(
      walletAddress: map['walletAddress'] as String,
      privateKey: map['privateKey'] as String,
      email: map['email'] as String,
      coinOnHold: map['coinOnHold'] as int,
      coinSell: map['coinSell'] as int,
      coinBuy: map['coinBuy'] as int,
      totalCoinUser: map['totalCoinUser'] as double,
      danaUser: map['danaUser'] as int,
    );
  }

  // String toJson() => json.encode(toMap());

  factory UserCoin.fromJson(String source) =>
      UserCoin.fromMap(json.decode(source) as Map<String, dynamic>);

  UserCoin copyWith({
    String? walletAddress,
    String? privateKey,
    String? email,
    int? coinOnHold,
    int? coinSell,
    int? coinBuy,
    double? totalCoinUser,
    int? danaUser,
  }) {
    return UserCoin(
      walletAddress: walletAddress ?? this.walletAddress,
      privateKey: privateKey ?? this.privateKey,
      email: email ?? this.email,
      coinOnHold: coinOnHold ?? this.coinOnHold,
      coinSell: coinSell ?? this.coinSell,
      coinBuy: coinBuy ?? this.coinBuy,
      totalCoinUser: totalCoinUser ?? this.totalCoinUser,
      danaUser: danaUser ?? this.danaUser,
    );
  }

  @override
  bool operator ==(covariant UserCoin other) {
    if (identical(this, other)) return true;

    return other.walletAddress == walletAddress &&
        other.privateKey == privateKey &&
        other.email == email &&
        other.coinOnHold == coinOnHold &&
        other.coinSell == coinSell &&
        other.coinBuy == coinBuy &&
        other.totalCoinUser == totalCoinUser &&
        other.danaUser == danaUser;
  }

  @override
  int get hashCode {
    return walletAddress.hashCode ^
        privateKey.hashCode ^
        email.hashCode ^
        coinOnHold.hashCode ^
        coinSell.hashCode ^
        coinBuy.hashCode ^
        totalCoinUser.hashCode ^
        danaUser.hashCode;
  }

  @override
  String toString() {
    return 'UserCoin(walletAddress: $walletAddress, privateKey: $privateKey, email: $email, coinOnHold: $coinOnHold, coinSell: $coinSell, coinBuy: $coinBuy, totalCoinUser: $totalCoinUser, danaUser: $danaUser)';
  }
}
