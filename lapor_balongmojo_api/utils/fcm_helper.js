const admin = require('firebase-admin');
// const db = require('../src/config/database'); // <--- TIDAK DIPERLUKAN LAGI

/**
 * Mengirim notifikasi ke topik 'emergency_alerts'.
 * @param {string} judulBerita - Judul berita yang akan jadi body notifikasi.
 * @param {string} isiBerita - Isi lengkap berita (untuk data payload).
 */
async function kirimNotifikasiDarurat(judulBerita, isiBerita) {
  try {
    // --- HAPUS: TIDAK PERLU QUERY DATABASE LAGI ---
    /*
    const [users] = await db.execute(
      'SELECT fcm_token FROM users WHERE fcm_token IS NOT NULL AND fcm_token != ""'
    );
    if (users.length === 0) {
      console.log('Tidak ada user dengan FCM token untuk dikirimi notifikasi.');
      return; 
    }
    const tokens = users.map(user => user.fcm_token);
    */
    // ---------------------------------------------
    
    const message = {
      // Data notifikasi visual
      notification: {
        title: `🚨 PERINGATAN DARURAT 🚨`,
        body: judulBerita, // Judul berita kita jadikan isi notifikasi
      },
      // Data payload tersembunyi
      data: {
        screen: 'BeritaDetail', 
        judul: judulBerita,
        isi: isiBerita,
      },
      // --- TARGET BARU: KIRIM KE TOPIK 'emergency_alerts' ---
      topic: 'emergency_alerts', 
      // -----------------------------------------------------
    };

    // 4. Kirim pesannya ke topik! (Gunakan .send() untuk topik)
    const response = await admin.messaging().send(message);
    
    console.log('Notifikasi darurat terkirim ke topik:', response);

    // --- HAPUS LOGIKA PENANGANAN TOKEN GAGAL ---
    // (Ini hanya berlaku untuk sendMulticast dan sendToDevice)

  } catch (error) {
    console.error('Gagal mengirim notifikasi darurat:', error);
  }
}

// Export fungsi ini agar bisa dipakai di file lain
module.exports = {
  kirimNotifikasiDarurat
};