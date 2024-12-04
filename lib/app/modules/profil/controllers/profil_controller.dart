import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  var isLoading = true.obs;
  var nama = ''.obs;
  var nohp = ''.obs;
  var alamat = ''.obs;
  var shippingCost = 0.0.obs;
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
            .collection('customers')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          nama.value = snapshot['nama'] ?? '';
          nohp.value = snapshot['nohp'] ?? '';
          alamat.value = snapshot['alamat'] ?? '';
          shippingCost.value = snapshot['shippingCost'] ?? 0.0;
          // Anda bisa mengupdate jarak dan ongkir sesuai kebutuhan
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading(false);
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
        shippingCost.value = userData['ongkir'] ?? 0;
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
      if (dist <= 2) {
        shippingCost.value = 1000;
      } else if (dist <= 3) {
        shippingCost.value = 2000;
      } else {
        shippingCost.value = ((dist - 3).ceil() * 1000) + 2000;
      }
    }
  }

  Future<void> openMap() async {
    final lat = latitude.value;
    final lng = longitude.value;
    if (lat != null && lng != null) {
      final Uri googleMapUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      if (await canLaunchUrl(googleMapUrl)) {
        await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Tidak dapat membuka peta.');
      }
    } else {
      Get.snackbar('Error', 'Koordinat tidak tersedia.');
    }
  }

  Future<void> updateAddressAndShippingCost() async {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        throw Exception('User not logged in');
      }

      if (alamat.value.isEmpty || shippingCost.value == 0) {
        Get.snackbar('Error', 'Alamat atau ongkir tidak valid.');
        return;
      }

      var customerRef = FirebaseFirestore.instance
          .collection('customer')
          .where('email', isEqualTo: email);

      var customerDoc = await customerRef.get();

      if (customerDoc.docs.isNotEmpty) {
        // Update alamat dan ongkir berdasarkan email
        await customerDoc.docs.first.reference.update({
          'alamat': alamat.value,
          'ongkir': shippingCost.value,
        });

        Get.snackbar('Sukses', 'Alamat dan ongkir berhasil disimpan.');
      } else {
        throw Exception('User not found in Firestore');
      }
    } catch (e) {
      print('Error updating address and shipping cost: $e');
      Get.snackbar('Error', 'Gagal menyimpan alamat dan ongkir.');
    }
  }
}
