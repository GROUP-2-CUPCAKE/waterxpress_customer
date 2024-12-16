import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilController extends GetxController {
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString nama = ''.obs;
  final RxString nohp = ''.obs;
  final RxString alamat = ''.obs;
  final RxDouble ongkir = 0.0.obs;
  final RxDouble distance = 0.0.obs;
  final RxString inputAddress = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Koordinat toko
  static const double storeLatitude = -0.9292;
  static const double storeLongitude = 119.8583;

  var isRefreshingLocation = false.obs;

  // untuk refresh lokasi
  Future<void> refreshUserLocation() async {
    try {
      // Set status loading
      isRefreshingLocation.value = true;

      // Cek apakah alamat tersedia
      if (alamat.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Alamat belum tersedia',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return;
      }

      // Update koordinat dari alamat
      await updateCoordinatesFromAddress();

      // Hitung ulang jarak dan biaya
      calculateDistanceAndCost();

      // Simpan perubahan ke Firebase
      await saveNewAddress();

      Get.closeAllSnackbars(); // Tutup semua snackbar sebelumnya
      Get.snackbar(
        'Pembaruan Berhasil',
        'Jarak dan ongkir telah diperbarui',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error',
        'Gagal memperbarui lokasi: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      // Reset status loading
      isRefreshingLocation.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      loadUserProfile(),
      _checkAndRequestLocationPermission(),
    ] as Iterable<Future>);
  }

  Future<void> _checkAndRequestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      print('Permission check error: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Pengguna tidak terautentikasi');
      }

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('customer')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        nama.value = (snapshot.data() as Map<String, dynamic>?)?['username']
                ?.toString() ??
            'Pengguna Baru';
        nohp.value =
            (snapshot.data() as Map<String, dynamic>?)?['nohp']?.toString() ??
                '';

        // Periksa keberadaan field sebelum mengaksesnya
        var data = snapshot.data() as Map<String, dynamic>?;

        alamat.value = data?['alamat']?.toString() ?? '';
        ongkir.value = _safeParseDouble(data?['ongkir']) ?? 0.0;
        profileImageUrl.value = data?['profileImageUrl']?.toString() ?? '';

        // Hitung ulang jarak jika alamat tersedia
        if (alamat.value.isNotEmpty) {
          await updateCoordinatesFromAddress();
        }
      } else {
        // Jika dokumen tidak ditemukan, inisialisasi dengan data default
        nama.value = 'Pengguna Baru';
        alamat.value = '';
        ongkir.value = 0.0;
        profileImageUrl.value = '';
      }
    } catch (e) {
      print('Error memuat profil: $e');

      // Berikan nilai default
      nama.value = 'Pengguna Baru';
      alamat.value = '';
      ongkir.value = 0.0;
      profileImageUrl.value = '';

      Get.snackbar(
        'Informasi',
        'Silakan lengkapi profil Anda',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCoordinatesFromAddress() async {
    try {
      if (alamat.value.isEmpty) {
        throw Exception('Alamat kosong');
      }

      List<Location> locations = await locationFromAddress(alamat.value);
      if (locations.isNotEmpty) {
        final location = locations.first;
        latitude.value = location.latitude;
        longitude.value = location.longitude;
        calculateDistanceAndCost();
      } else {
        throw Exception('Tidak dapat menemukan koordinat');
      }
    } catch (e) {
      print('Error updating coordinates from address: $e');

      // Reset koordinat
      latitude.value = 0.0;
      longitude.value = 0.0;
      distance.value = 0.0;
      ongkir.value = 0.0;
    }
  }

  void calculateDistanceAndCost() {
    try {
      double dist = Geolocator.distanceBetween(
            latitude.value,
            longitude.value,
            storeLatitude,
            storeLongitude,
          ) /
          1000; // Konversi ke kilometer

      distance.value = dist;

      // Menghitung biaya ongkir
      ongkir.value = _calculateShippingCost(dist);
    } catch (e) {
      print('Error calculating distance and cost: $e');
      distance.value = 0.0;
      ongkir.value = 0.0;
    }
  }

  double _calculateShippingCost(double distance) {
    if (distance <= 1) return 1000;
    if (distance <= 2) return 2000;
    if (distance <= 3) return 3000;
    return ((distance - 3).ceil() * 1000) + 3000;
  }

  //pilih lokasi saat ini
  Future<void> getGeolocation() async {
    try {
      // Izin lokasi
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Dapatkan alamat dari koordinat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        alamat.value = _formatAddress(place);
        calculateDistanceAndCost();
      }
      Get.snackbar(
        'Berhasil mendapatkan lokasi',
        'Jangan lupa simpan alamat barumu!',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _formatAddress(Placemark place) {
    return [
      place.street ?? '',
      place.subLocality ?? '',
      place.locality ?? '',
      place.administrativeArea ?? '',
      place.country ?? ''
    ].where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> saveNewAddress() async {
    try {
      // Validasi alamat
      if (alamat.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Alamat tidak boleh kosong',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return;
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Pengguna tidak terautentikasi');
      }

      isLoading.value = true;
      Map<String, dynamic> updateData = {
        'alamat': alamat.value,
        'jarak': distance.value,
        'ongkir': ongkir.value,
        'latitude': latitude.value,
        'longitude': longitude.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update dokumen
      await FirebaseFirestore.instance
          .collection('customer')
          .doc(currentUser.uid)
          .update(updateData);

      Get.snackbar(
        'Alamat berhasil disimpan',
        'Refresh terlebih dahulu!',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan alamat: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }

  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Method untuk edit foto profil
  Future<void> editProfilePhoto() async {
    try {
      // Tampilkan bottom sheet loading
      Get.bottomSheet(
        Container(
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularProgressIndicator(),
                Text("Mengunggah Foto"),
              ],
            )),
        isDismissible: false,
      );

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        isLoading.value = true;
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Pengguna tidak terautentikasi');
        }

        //path untuk foto profil
        String filePath =
            'profile_pictures/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload file
        File imageFile = File(pickedFile.path);
        UploadTask uploadTask =
            FirebaseStorage.instance.ref(filePath).putFile(imageFile);

        // Dapatkan URL download
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update di Firestore
        await FirebaseFirestore.instance
            .collection('customer')
            .doc(currentUser.uid)
            .update({
          'profileImageUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local state
        profileImageUrl.value = downloadUrl;
        // Tutup bottom sheet loading
        Get.back();

        Get.snackbar(
          'Sukses',
          'Foto profil berhasil diperbarui',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF0288D1),
        );
      } else {
        // Jika tidak memilih foto, tutup bottom sheet
        Get.back();
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal memperbarui foto profil: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk update profil
  Future<void> updateProfile({
    String? newName,
    String? newPhone,
  }) async {
    try {
      isLoading.value = true;

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Pengguna tidak terautentikasi');
      }
      Map<String, dynamic> updateData = {};
      if (newName != null && newName.isNotEmpty) {
        updateData['username'] = newName;
        nama.value = newName;
      }
      if (newPhone != null && newPhone.isNotEmpty) {
        updateData['nohp'] = newPhone;
        nohp.value = newPhone;
      }
      // update jika ada perubahan
      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('customer')
            .doc(currentUser.uid)
            .update(updateData);

        Get.snackbar(
          'Sukses',
          'Profil berhasil diperbarui',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF0288D1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk update alamat manual
  Future<void> updateAddressManually(String newAddress) async {
    try {
      // Validasi alamat tidak kosong
      if (newAddress.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Alamat tidak boleh kosong',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return;
      }

      try {
        // Konversi alamat ke koordinat
        List<Location> locations = await locationFromAddress(newAddress);

        if (locations.isNotEmpty) {
          Location location = locations.first;

          // Update values
          alamat.value = newAddress;
          latitude.value = location.latitude;
          longitude.value = location.longitude;

          // Hitung jarak dan ongkir
          calculateDistanceAndCost();

          // Simpan ke Firebase
          await saveNewAddress();
        } else {}
      } catch (geocodingError) {
        Get.snackbar(
          'Error',
          'Gagal mengkonversi alamat: $geocodingError',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses alamat: $e',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
