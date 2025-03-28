


//models/user_table_db.dart

import 'dart:ffi';
import 'package:flutter/cupertino.dart';

final String tableUsers = 'users';

class UserFields {
  static final String id = '_id';
  static final String first_name = 'first_name';
  static final String last_name = 'last_name';
  static final String username = 'username';
  static final String email = 'email';
  static final String password = 'password';
  static final String phone_num = 'phone_num';
  static final String address = 'address';
  static final String profile_picture = 'profile_picture';
}

class Users {
  final int? id;
  final String first_name;
  final String last_name;
  final String username;
  final String email;
  final String password;
  final int phone_num;
  final String address;
  final String profile_picture;

  const Users({
    this.id,
    required this.first_name,
    required this.last_name,
    required this.username,
    required this.email,
    required this.password,
    required this.phone_num,
    required this.address,
    this.profile_picture = 'assets/default_profile.png',
  });

  Users copy({
    int? id,
    String? first_name,
    String? last_name,
    String? username,
    String? email,
    String? password,
    int? phone_num,
    String? address,
    String? profile_picture,
  }) =>
      Users(
        id: id ?? this.id,
        first_name: first_name ?? this.first_name,
        last_name: last_name ?? this.last_name,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        phone_num: phone_num ?? this.phone_num,
        address: address ?? this.address,
        profile_picture: profile_picture ?? this.profile_picture,
      );

  Map<String, Object?> tojson() => {
    UserFields.id: id,
    UserFields.first_name: first_name,
    UserFields.last_name: last_name,
    UserFields.username: username,
    UserFields.email: email,
    UserFields.password: password,
    UserFields.phone_num: phone_num,
    UserFields.address: address,
    UserFields.profile_picture: profile_picture,
  };

  // Method to print user data
  void printUserData(user) {
    print('User ID: $id');
    print('First Name: $first_name');
    print('Last Name: $last_name');
    print('Username: $username');
    print('Email: $email');
    print('Phone Number: $phone_num');
    print('Address: $address');
    print('Address: $profile_picture');
  }

}

