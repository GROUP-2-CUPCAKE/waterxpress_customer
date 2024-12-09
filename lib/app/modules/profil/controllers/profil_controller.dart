import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilController extends GetxController {
  // var latitude = Rx<double?>(null);
  // var longitude = Rx<double?>(null);
  // var alamat = RxString('');
  // var isLoading = false.obs;

  // var nama = ''.obs;
  // var nohp = ''.obs;
  // var distance = RxDouble(0.0); // Jarak ke toko
  // var shippingCost = RxInt(0); // Biaya ongkir
  final RxString profileImageUrl = ''.obs;
  var isLoading = true.obs;
  var nama = ''.obs;
  var nohp = ''.obs;
  var alamat = ''.obs;
  var ongkir = 0.0.obs;
  var distance = 0.0.obs;
  var inputAddress = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  // Variabel untuk input manual
  // var inputAddress = RxString('');

  // Koordinat toko
  final double storeLatitude = -0.9292; // Contoh latitude toko
  final double storeLongitude = 119.8583; // Contoh longitude toko

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    getGeolocation();
    loadUserProfile();
  }

  void loadUserProfile() async {
    isLoading(true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('customer')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          nama.value = snapshot['nama'] ?? '';
          nohp.value = snapshot['nohp'] ?? '';
          alamat.value = snapshot['alamat'] ?? '';
          ongkir.value = snapshot['ongkir'] ?? 0.0;
          profileImageUrl.value = snapshot['profileImageUrl'] ?? '';
          // Anda bisa mengupdate jarak dan ongkir sesuai kebutuhan
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<void> editProfilePhoto() async {
  try {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isLoading.value = true;

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Pengguna tidak terautentikasi');
      }

      String filePath = 'profile_pictures/${currentUser.uid}.jpg';

      File imageFile = File(pickedFile.path);

      UploadTask uploadTask = FirebaseStorage.instance.ref(filePath).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      DocumentReference customerDocRef = FirebaseFirestore.instance.collection('customer').doc(currentUser.uid);
      await customerDocRef.update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      profileImageUrl.value = downloadUrl;

      Get.snackbar(
        'Sukses',
        'Foto profil berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
      );

    } else {
      Get.snackbar('Info', 'Tidak ada gambar yang dipilih.');
    }
  } catch (e) {
    Get.snackbar('Error', 'Gagal memperbarui foto profil: $e');
  } finally {
    isLoading.value = false;
  }
  }


  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      // Mendapatkan email pengguna
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        throw Exception('User not logged in');
      }

      // Ambil data pengguna dari Firestore
      var doc = await FirebaseFirestore.instance
          .collection('customer')
          .where('email', isEqualTo: email)
          .get();

      if (doc.docs.isNotEmpty) {
        var userData = doc.docs.first.data();
        nama.value = userData['username'] ?? 'N/A';
        nohp.value = userData['nohp'] ?? 'N/A';
        alamat.value = userData['alamat'] ?? '';
        ongkir.value = userData['ongkir'] ?? 0;
        profileImageUrl.value = userData['profileImageUrl'] ?? '';
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGeolocation() async {
    try {
      isLoading.value = true;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Hitung jarak ke toko
      calculateDistanceAndCost();

      // Dapatkan alamat menggunakan geocoding
      updateAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        alamat.value =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
        calculateDistanceAndCost();
      }
    } catch (e) {
      print('Error updating address from coordinates: $e');
    }
  }

  void updateCoordinatesFromAddress() async {
    if (inputAddress.value.isNotEmpty) {
      try {
        isLoading.value = true;
        List<Location> locations =
            await locationFromAddress(inputAddress.value);
        if (locations.isNotEmpty) {
          final location = locations.first;
          latitude.value = location.latitude;
          longitude.value = location.longitude;

          updateAddressFromCoordinates(latitude.value!, longitude.value!);
        }
      } catch (e) {
        print('Error getting coordinates from address: $e');
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Error', 'Alamat tidak boleh kosong');
    }
  }

  void calculateDistanceAndCost() {
    if (latitude.value != null && longitude.value != null) {
      double dist = Geolocator.distanceBetween(
            latitude.value!,
            longitude.value!,
            storeLatitude,
            storeLongitude,
          ) /
          1000; // Konversi ke kilometer
      distance.value = dist;

      // Hitung biaya ongkir
      if (dist <= 1) {
        ongkir.value = 0;
      }
      else if (dist <= 2) {
        ongkir.value = 1000;
      } else if (dist <= 3) {
        ongkir.value = 2000;
      } else {
        ongkir.value = ((dist - 3).ceil() * 1000) + 2000;
      }
    }
  }

  Future<void> openGoogleMaps() async {
  try {
    final double lat = latitude.value;
    final double lng = longitude.value;

    // Periksa apakah koordinat tersedia
    if (lat == 0.0 && lng == 0.0) {
      Get.snackbar('Error', 'Koordinat tidak tersedia.');
      return;
    }

    // Format URL untuk Google Maps
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    // Periksa apakah URL bisa dibuka
    if (await canLaunchUrl(googleMapsUrl)) {
      // Buka URL menggunakan aplikasi eksternal
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka Google Maps.');
    }
  } catch (e) {
    // Tangani error jika ada
    Get.snackbar('Error', 'Terjadi kesalahan: $e');
  }
}

  Future<void> updateAddressAndShippingCost() async {
  try {

    // Validasi input
    if (alamat.value.isEmpty) {
      Get.snackbar('Error', 'Alamat tidak boleh kosong');
      return;
    }

    // Dapatkan user saat ini
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Pengguna tidak terautentikasi');
    }

    // Referensi dokumen pelanggan
    DocumentReference customerDocRef = FirebaseFirestore.instance
        .collection('customer')
        .doc(currentUser.uid);

    // Siapkan data update
    Map<String, dynamic> updateData = {
      'uid': currentUser.uid,
      'alamat': alamat.value,
      'ongkir': ongkir.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    // Lakukan update atau set dengan merge
    await customerDocRef.set(updateData, SetOptions(merge: true));

    // Tampilkan pesan sukses
    Get.snackbar(
      'Sukses', 
      'Alamat dan ongkos kirim berhasil diperbarui',
    );

    // Refresh data setelah update
    loadUserProfile();

  } on FirebaseException catch (firebaseError) {

    Get.snackbar(
      'Error Firebase', 
      firebaseError.message ?? 'Terjadi kesalahan pada Firebase',
    );

  } catch (e) {

    Get.snackbar(
      'Error', 
      'Gagal menyimpan alamat dan ongkir: $e',
    );
  }
}
}
