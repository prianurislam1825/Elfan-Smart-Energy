# Data Mapping — Field Inverter Growatt ke Model Monitoring

> **Label:** `BERDASARKAN DOKUMENTASI` (sumber API `api-plts-inverter.pdf`, `4.3.8`, `4.3.9`; `server.cjs`; `README.md`).  
> **Status:** Field yang tidak dapat dipastikan di dokumen/kode ditandai `BELUM DIVERIFIKASI`.

---

## 1. Tabel pemetaan umum

| Data monitoring | Field Growatt | Satuan | Status |
|---|---|---|---|
| Status inverter | `status` | integer | `BERDASARKAN DOKUMENTASI` |
| Teks status inverter | `statusText` | string | `BERDASARKAN DOKUMENTASI` |
| Daya AC keluaran | `pac` | W (dugaan dari konteks PLTS; pastikan pada produk) | `TERVERIFIKASI` (implikasi dari konteks dashboard README) |
| Daya AC dinamis | `pacr` | W | `BERDASARKAN DOKUMENTASI` |
| Daya PV | `ppv` | W | `BERDASARKAN DOKUMENTASI` |
| Daya PV bagian 1 | `ppv1` | W | `BERDASARKAN DOKUMENTASI` |
| Daya PV bagian 2 | `ppv2` | W | `BERDASARKAN DOKUMENTASI` |
| Tegangan PV | `vpv1`, `vpv2` | V | `BERDASARKAN DOKUMENTASI` |
| Arus PV | `ipv1`, `ipv2` | A | `BERDASARKAN DOKUMENTASI` |
| Tegangan AC keluaran | `vacr` | V | `BERDASARKAN DOKUMENTASI` |
| Frekuensi | `fac` | Hz | `BERDASARKAN DOKUMENTASI` |
| Faktor daya | `pf` | — (ratio/%); contoh mengandung `-1` | `BERDASARKAN DOKUMENTASI` |
| Suhu inverter | `temperature` | °C | `BERDASARKAN DOKUMENTASI` |
| Energi hari ini | `powerToday` | kWh | `BERDASARKAN DOKUMENTASI` |
| Energi total | `powerTotal` | kWh | `BERDASARKAN DOKUMENTASI` |
| Waktu sampel | `time` | string lokal `YYYY-MM-DD HH:MM:SS` | `BERDASARKAN DOKUMENTASI` |
| Kode fault | `faultCode` | integer | `BERDASARKAN IMPLEMENTASI` |
| Kode warning | `warnCode`, atau alternatif `warningcode` | integer | `BERDASARKAN IMPLEMENTASI` |
| Persentase beban | `realOPPercent` | % | `BERDASARKAN DOKUMENTASI` (perhitungan dapat berubah pada data riil) |
| Total waktu operasi | `timeTotal` | jam | `BERDASARKAN DOKUMENTASI` |
| Datalogger yang terhubung | `dataloggerSn` | string | `BERDASARKAN DOKUMENTASI` |

---

## 2. Field tambahan yang ada di contoh JSON

| Field | Mana | Status |
|---|---|---|
| `pBusVoltage` | Tegangan bus | `BERDASARKAN DOKUMENTASI` |
| `nBusVoltage` | Tegangan bus negatif | `BERDASARKAN DOKUMENTASI` |
| `vact` | Tegangan AC | `BERDASARKAN DOKUMENTASI` |
| `vacs` | Tegangan AC suplai | `BERDASARKAN DOKUMENTASI` |
| `vString1..8` | Tegangan string | `BERDASARKAN DOKUMENTASI` |
| `vString7` | — | `BERDASARKAN DOKUMENTASI` |
| `vString5`, `vString6`, `vString8` | — | `BERDASARKAN DOKUMENTASI` |
| `currentString1..8` | Arus string | `BERDASARKAN DOKUMENTASI` |
| `iacs` | Arus AC suplai | `BERDASARKAN DOKUMENTASI` |
| `iacr` | Arus AC dinamis | `BERDASARKAN DOKUMENTASI` |
| `rac` | Resistansi AC? | `BERDASARKAN DOKUMENTASI` |
| `pacs` | Arus AC suplai | `BERDASARKAN DOKUMENTASI` |
| `pf` | Faktor daya | `BERDASARKAN DOKUMENTASI` |
| `pact` | Daya AC total | `BERDASARKAN DOKUMENTASI` |
| `id`, `inverterId` | ID inverter | `BERDASARKAN DOKUMENTASI` |
| `ipmTemperature` | Suhu IPM | `BERDASARKAN DOKUMENTASI` |
| `bigDevice` | Flag perangkat besar | `BERDASARKAN DOKUMENTASI` |
| `eRacToday`, `eRacTotal` | Energi resistansi AC | `BERDASARKAN DOKUMENTASI` |
| `epv1Today`, `epv2Today`, `epvTotal`, `epvTotal2`, `epv1Total`, `epv2Total` | Energi PV | `BERDASARKAN DOKUMENTASI` |
| `faultType` | Jenis fault | `BERDASARKAN DOKUMENTASI` |
| `pidStatus` | Status parameter | `BERDASARKAN DOKUMENTASI` |
| `opFullwatt` | Beban operasi | `BERDASARKAN DOKUMENTASI` |
| `wStringWarningValue1`, `wStringWarningValue2` | Warning string | `BERDASARKAN DOKUMENTASI` |
| `dwStringWarningValue1` | Warning double string | `BERDASARKAN DOKUMENTASI` |
| `timeTotalText`, `realOPPercent`, `timeCalendar`, `timeZone`, `timeInMillis` | Durasi & metadata | `BERDASARKAN DOKUMENTASI` |

> Field tambahan di atas muncul di contoh JSON, tetapi banyak yang tidak digunakan di `server.cjs`. Sehingga pembacaan `BELUM DIVERIFIKASI` untuk implementasi.

---

## 3. Pemetaan ke panel dashboard

### Panel utama

| Panel | Field |
|---|---|
| Total daya AC | `pac` |
| Total energi hari ini | `powerToday` |
| Total energi akumulasi | `powerTotal` |
| Suhu | `temperature` |
| Status | `status`, `statusText` |

### Kartu inverter

| Elemen | Field |
|---|---|
| Status LED | `status`, `statusText` |
| PAC | `pac` |
| PPV | `ppv`, `ppv1`, `ppv2` |
| VAC | `vacr` |
| IAC | `iacr` |
| VPV | `vpv1`, `vpv2` |
| IPV | `ipv1`, `ipv2` |
| Frekuensi | `fac` |
| Suhu | `temperature`, `ipmTemperature` |
| Kurva 15 menit | `history` (simulasi) |
| Fault/warning | `faultCode`, `warnCode` |

### Status bar

| Item | Sumber |
|---|---|
| Mode server | `mode` |
| Poll ke- | `pollCount` |
| Penyimpanan terakhir | `lastPollAtMs` |
| Status poll | `lastPollOk` |
| Error terakhir | `lastError` |
| Total PAC | `totalPac` |
| Total energi hari ini | `totalToday` |
| Total akumulasi | `totalAll` |

---

## 4. Rule penting yang harus dipatuhi

1. **Gunakan `device_sn` sebagai kunci polling inverter**, bukan `datalogger_sn`.
2. **`datalogger_sn` hanya untuk pemetaan nomor kolompok/datang**, bukan sebagai pengenal datalogger.
3. **Status online** dapat dihitung dari selisih `lastPollAtMs` dengan interval polling, bukan dari HTTP satu kali.
4. **History lokal** di `server.cjs` hanya menyimpan 720 entri; `api/snapshot.js` menggunakan 30 titik untuk display. Bukan data historis Growatt.
5. **Field `powerToday`** dalam contoh PDF adalah nilai dalam hal waktu, bukan menentukan arus; dalam implementasi konversi ke angka menggunakan `Number()`.

---

## 5. Kapan field satuan tidak dapat dipastikan

Berikut adalah field yang **kritis** untuk konsistensi data, tetapi **tidak dapat dipastikan** dari dokumen API saja:

| Field | Alasan |
|---|---|
| `pac`, `ppv` | Bisa W, kVAR, atau kuantitas lain tergantung konfigurasi device; dari konteks dashboard terlihat W |
| `pf` | Bisa ratio 0–1 atau nilai persen; contoh PDF tampak `-1` |
| `statusText` | Kode teks bisa berbeda antar firmware/firmware version |
| `faultCode`, `warnCode` | Kode jenis/angka tidak ada kamus di dokumen yang diamati |
| `time` | Format lokal mengikuti server Growatt; dapat berubah antar timezone |

Untuk memastikan konsistensi data di sistem berikut, backend ELFAN harus mencatat:

- `source` = `growatt/last_new_data`
- `source_url` per device
- `poll_at`
- `status_code`
- `e_code`, `e_msg`
- `timestamp` data dari Growatt
- `device_sn`
- `datalogger_sn`
