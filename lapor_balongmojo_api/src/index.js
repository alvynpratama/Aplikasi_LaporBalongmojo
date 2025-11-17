const path = require('path');

require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const express = require('express');
const cors = require('cors');
const db = require('./config/database');

// --- 1. IMPORT FIREBASE ADMIN ---
const admin = require('firebase-admin');
// --- 2. IMPORT KUNCI RAHASIA ---
const serviceAccount = require('../serviceAccountKey.json');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('public/uploads'));

// --- 3. INISIALISASI FIREBASE ADMIN ---
// (Letakkan ini SEBELUM mendaftarkan rute)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
// -------------------------------------

// Pendaftaran Rute
const authRoutes = require('./routes/auth');
const laporanRoutes = require('./routes/laporan');
const beritaRoutes = require('./routes/berita');
const adminRoutes = require('./routes/admin');
const uploadRoutes = require('./routes/upload');
const statsRoutes = require('./routes/stats');
const profileRoutes = require('./routes/profile');

app.use('/auth', authRoutes);
app.use('/laporan', laporanRoutes);
app.use('/berita', beritaRoutes);
app.use('/admin', adminRoutes);
app.use('/upload', uploadRoutes);
app.use('/stats', statsRoutes);
app.use('/profile', profileRoutes);

app.get('/', (req, res) => {
  res.send('API Lapor Balongmojo sedang berjalan...');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});