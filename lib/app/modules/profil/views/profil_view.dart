import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends StatelessWidget {
  final ProfilController controller = Get.put(ProfilController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF80D8FF).withOpacity(0.8),
              Color(0xFF40C4FF).withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Obx(() {
            if (controller.isLoading.value) {
              return CircularProgressIndicator(
                color: Colors.white,
              );
            } else if (controller.latitude.value != null &&
                controller.longitude.value != null) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Foto Profil dan Edit Foto
                    Stack(
                      children: [
                        Obx(() {
                          return controller.profileImageUrl.value.isNotEmpty
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(controller.profileImageUrl.value),
                                )
                              : CircleAvatar(
                                  radius: 60,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                  ),
                                );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              // Aksi edit foto profil
                              // controller.pickAndUploadProfileImage();
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 16,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nama:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              controller.nama.value,
                              // 'Vera',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            const Divider(),
                            const Text(
                              'Nomor Telepon:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              controller.nohp.value,
                              // '0812345',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alamat:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              controller.alamat.value,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            Divider(),
                            const Text(
                              'Jarak ke Toko:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${controller.distance.value.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            Divider(),
                            Text(
                              'Biaya Ongkir:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Rp ${controller.ongkir.value}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: controller.getGeolocation,
                              icon:
                                  Icon(Icons.my_location, color: Colors.white),
                              label: const Text(
                                'Pilih Lokasi Saat Ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: Color(0xFF0288D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: controller.openMap,
                              icon: const Icon(Icons.map_outlined,
                                  color: Colors.white),
                              label: const Text(
                                'Lihat di Google Maps',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: Color(0xFF0288D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masukkan Alamat Baru:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              onChanged: (value) =>
                                  controller.inputAddress.value = value,
                              decoration: InputDecoration(
                                hintText: 'Contoh: Jalan Malioboro, Yogyakarta',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        controller.updateCoordinatesFromAddress,
                                    icon: Icon(Icons.edit_location_outlined,
                                        color: Colors.white),
                                    label: Text(
                                      'Perbarui Alamat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0288D1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: 10), // Menambah jarak antar tombol
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        controller.updateAddressAndShippingCost,
                                    icon: Icon(Icons.save, color: Colors.white),
                                    label: Text(
                                      'Simpan Alamat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0288D1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text(
                'Gagal mendapatkan lokasi.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
