# Sistem Kendali PID AUV untuk Mempertahankan Kedalaman

Proyek simulasi dan implementasi sistem kontrol PID (Proportional-Integral-Derivative) untuk pengendalian kedalaman Autonomous Underwater Vehicle (AUV) menggunakan MATLAB/Simulink.

## 📋 Deskripsi Proyek

Autonomous Underwater Vehicle (AUV) merupakan kendaraan bawah air yang dapat beroperasi secara mandiri tanpa memerlukan pengendali manusia. Proyek ini fokus pada pengembangan sistem kontrol PID untuk mengatur kedalaman AUV dengan tingkat akurasi dan stabilitas yang tinggi.

### 🎯 Tujuan Proyek

1. Menyusun model matematis sederhana dari sistem kedalaman AUV berdasarkan hukum Newton
2. Mendesain dan mengimplementasikan kontroler PID untuk mengatur sistem dengan fungsi alih integrasi ganda (1/s²)
3. Melakukan simulasi untuk mengevaluasi performa sistem kontrol berdasarkan parameter seperti waktu tunak, overshoot, dan kestabilan
4. Memahami dampak tuning parameter PID (Kp, Ki, Kd) terhadap respons sistem

## 🔧 Teknologi yang Digunakan

- **MATLAB R2023a** atau versi yang lebih baru
- **Simulink** untuk pemodelan dan simulasi sistem
- **Control System Toolbox** untuk analisis sistem kontrol
- **PID Tuner App** untuk optimasi parameter

## 📊 Model Sistem

Dengan parameter optimal:
- **Kp** = 0.62 (Proportional Gain)
- **Ki** = 0.003 (Integral Gain)  
- **Kd** = 1.34 (Derivative Gain)

## 📈 Hasil Simulasi

### Performance Metrics
| Parameter | Manual Tuning | Auto Tuning |
|-----------|---------------|-------------|
| Rise Time | 1.95 seconds | 1.4 seconds |
| Settling Time | 17.4 seconds | 17.6 seconds |
| Overshoot | 0% | 10.8% |
| Peak | 1.0 | 1.11 |
| Gain Margin | 19.3 dB @ 6.63 rad/s | 23.2 dB @ 6.42 rad/s |
| Phase Margin | 99.2 deg @ 1.28 rad/s | 64.5 deg @ 0.085 rad/s |

### Keunggulan Manual Tuning
- ✅ Zero overshoot (0%)
- ✅ Phase margin yang lebih besar (99.2°)
- ✅ Respons yang lebih smooth
- ✅ Robustness yang lebih baik

## 🚀 Cara Menjalankan Simulasi

### Prerequisites
Pastikan MATLAB/Simulink telah terinstall dengan toolbox berikut:
- Control System Toolbox
- Simulink Control Design
