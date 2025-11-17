const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database'); 

router.post('/register/masyarakat', async (req, res) => {
  try {
    const { nama_lengkap, email, no_telepon, password } = req.body;

    const [existing] = await db.execute(
      'SELECT * FROM users WHERE email = ? OR no_telepon = ?',
      [email, no_telepon]
    );
    if (existing.length > 0) {
      return res.status(400).json({ message: 'Email atau No Telepon sudah terdaftar.' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    await db.execute(
      'INSERT INTO users (nama_lengkap, email, no_telepon, password_hash, role, is_verified) VALUES (?, ?, ?, ?, ?, ?)',
      [nama_lengkap, email, no_telepon, password_hash, 'masyarakat', false] 
    );

    res.status(201).json({ message: 'Registrasi masyarakat berhasil. Menunggu verifikasi.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(401).json({ message: 'Email atau password salah.' });
    }
    const user = users[0];

    if (user.role === 'masyarakat' && !user.is_verified) {
      return res.status(403).json({ message: 'Akun Anda belum diverifikasi oleh perangkat desa.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Email atau password salah.' });
    }

    const payload = {
      id: user.id,
      role: user.role,
      nama: user.nama_lengkap
    };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.json({
      message: 'Login berhasil',
      token: token,
      user: payload
    });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;