// File BARU: src/routes/stats.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Endpoint: GET /stats/laporan-total
// Endpoint publik untuk dashboard masyarakat
router.get('/laporan-total', async (req, res) => {
    try {
        // Query sederhana untuk menghitung total baris di tabel laporan
        const [result] = await db.execute('SELECT COUNT(*) as total_laporan FROM laporan');

        // Ambil angkanya
        const total = result[0].total_laporan;

        // Kirim sebagai JSON
        res.json({ total_laporan: total });

    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;