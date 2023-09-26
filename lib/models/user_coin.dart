// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserCoin {
  final String walletAddress;
  final String privateKey;
  final String email;
  final int coinOnHold;
  final int coinSell;
  final int coinBuy;
  final int totalCoinUser;
  UserCoin({
    required this.walletAddress,
    required this.privateKey,
    required this.email,
    required this.coinOnHold,
    required this.coinSell,
    required this.coinBuy,
    required this.totalCoinUser,
  });

  UserCoin copyWith({
    String? walletAddress,
    String? privateKey,
    String? email,
    int? coinOnHold,
    int? coinSell,
    int? coinBuy,
    int? totalCoinUser,
  }) {
    return UserCoin(
      walletAddress: walletAddress ?? this.walletAddress,
      privateKey: privateKey ?? this.privateKey,
      email: email ?? this.email,
      coinOnHold: coinOnHold ?? this.coinOnHold,
      coinSell: coinSell ?? this.coinSell,
      coinBuy: coinBuy ?? this.coinBuy,
      totalCoinUser: totalCoinUser ?? this.totalCoinUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'walletAddress': walletAddress,
      'privateKey': privateKey,
      'email': email,
      'coinOnHold': coinOnHold,
      'coinSell': coinSell,
      'coinBuy': coinBuy,
      'totalCoinUser': totalCoinUser,
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
      totalCoinUser: map['totalCoinUser'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'walletAddress': walletAddress,
        'privateKey': privateKey,
        'email': email,
        'coinOnHold': coinOnHold,
        'coinSell': coinSell,
        'coinBuy': coinBuy,
        'totalCoinUser': totalCoinUser,
      };

  factory UserCoin.fromJson(String source) =>
      UserCoin.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserCoin(walletAddress: $walletAddress, privateKey: $privateKey, email: $email, coinOnHold: $coinOnHold, coinSell: $coinSell, coinBuy: $coinBuy, totalCoinUser: $totalCoinUser)';
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
        other.totalCoinUser == totalCoinUser;
  }

  @override
  int get hashCode {
    return walletAddress.hashCode ^
        privateKey.hashCode ^
        email.hashCode ^
        coinOnHold.hashCode ^
        coinSell.hashCode ^
        coinBuy.hashCode ^
        totalCoinUser.hashCode;
  }
}
