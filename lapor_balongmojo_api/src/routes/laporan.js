const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat, isMasyarakat } = require('../middleware/auth');

router.post('/', [verifyToken, isMasyarakat], async (req, res) => {
  try {
    const { judul, deskripsi, foto_url } = req.body; 
    const user_id = req.user.id; 

    await db.execute(
      'INSERT INTO laporan (user_id, judul, deskripsi, foto_url, status) VALUES (?, ?, ?, ?, ?)',
      [user_id, judul, deskripsi, foto_url, 'belum terdaftar'] 
    );

    res.status(201).json({ message: 'Laporan berhasil dibuat.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/', verifyToken, async (req, res) => {
  try {
    const { id, role } = req.user;
    let query = '';
    let params = [];

    if (role === 'perangkat') {
      query = 'SELECT l.*, u.nama_lengkap FROM laporan l JOIN users u ON l.user_id = u.id ORDER BY l.created_at DESC';
    } else {
      query = 'SELECT * FROM laporan WHERE user_id = ? ORDER BY created_at DESC';
      params.push(id);
    }

    const [laporan] = await db.execute(query, params);
    res.json(laporan);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put('/:id', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { status } = req.body;
    const { id } = req.params;

    const validStatus = ['belum terdaftar', 'terverifikasi', 'diproses', 'selesai'];
    if (!validStatus.includes(status)) {
      return res.status(400).json({ message: 'Status tidak valid.' });
    }

    await db.execute(
      'UPDATE laporan SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status, id]
    );

    res.json({ message: 'Status laporan berhasil diperbarui.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;