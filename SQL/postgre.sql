CREATE TABLE ogrenci(
	id SERIAL PRIMARY KEY,
	ad VARCHAR(50),
	not_ort NUMERIC (4,2)
);

CREATE TABLE  bolum (
	id SERIAL PRIMARY KEY,
	ad VARCHAR(50) NOT NULL
);

CREATE TABLE ders (
	id SERIAL PRIMARY KEY,
	ad VARCHAR(100) NOT NULL,
	kredi INT,
	bolum_id INT REFERENCES bolum(id)
);

CREATE TABLE kayit(
	ogrenci_id INT REFERENCES ogrenci(id) ON DELETE CASCADE,
	ders_id INT REFERENCES ders(id) ON DELETE CASCADE,
	notu INT,
	donem VARCHAR(25),
	PRIMARY KEY(ogrenci_id, ders_id)
);

ALTER TABLE ogrenci ADD COLUMN bolum VARCHAR(50);

-- 1. BÖLÜM VERİLERİ
INSERT INTO bolum (id, ad) VALUES
(1, 'Şanssızlık Mühendisliği'),
(2, 'Dedikodu Bilimleri ve Stratejik Fısıltı'),
(3, 'Uykusuzluk ve Gece 3 Mesajları Anabilim Dalı'),
(4, 'Fast Food Felsefesi ve Ketçap Yönetimi');

-- 2. ÖĞRENCİ VERİLERİ
INSERT INTO ogrenci (ad, not_ort) VALUES
('Zıpırcan', 68.30),
('Cırcırböceği Cemal', 42.10),
('Parıltılı Pınar', 12.50),
('Makyajlı Muhtar', 88.90),
('Çorapsız Çetin', 50.00),
('Tostçu Tayfun', 31.80),
('Biberli Bedriye', 74.20),
('Hapşıran Hikmet', 61.70);

-- 3. DERS VERİLERİ
INSERT INTO ders (ad, kredi, bolum_id) VALUES
('Kopya Çekme Teknikleri 101', 4, 1),
('Açık Unutulan Muslukları Kapatma Sanatı', 3, 1),
('Yan Masadakinin Konuşmasını Dinleme ve Raporlama', 5, 2),
('Sabah 8.00 Dersine Gidiyormuş Gibi Görünme', 2, 3),
('Ketçap ve Mayonez Dökülme Risk Analizi', 4, 4),
('Sosyal Medyada Eski Sevgilinin Profilini İnceleme', 3, 2);

-- 4. KAYIT (NOT VE DÖNEM) VERİLERİ
INSERT INTO kayit(ogrenci_id, ders_id, notu, donem) VALUES
(1, 1, 45, '2025-Güz'),
(1, 2, 70, '2025-Güz'),
(2, 3, 90, '2025-Güz'),
(3, 4, 15, '2026-Bahar'),
(4, 5, 88, '2026-Bahar'),
(5, 1, 50, '2025-Güz'),
(6, 5, 30, '2026-Bahar'),
(7, 6, 95, '2026-Bahar'),
(8, 2, 62, '2025-Güz');

--tüm derslerin notları
SELECT o.ad AS ogrenci, d.ad AS Ders, k.notu
FROM kayit k
JOIN ogrenci o ON k.ogrenci_id = o.id
JOIN ders d ON k.ders_id = d.id
ORDER BY o.ad, k.notu DESC

--bölüm bazında ders ortalaması

SELECT b.ad AS bolum, d.ad AS ders, AVG(k.notu) AS ort
FROM kayit k
JOIN ders d ON k.ders_id = d.id
JOIN bolum b ON d.bolum_id = b.id
GROUP BY b.ad, d.ad
ORDER BY ort DESC;

--Her öğrencinin toplam kredisi
SELECT o.ad AS ogrenci, SUM(d.kredi) AS toplam_kredi
FROM ogrenci o
JOIN kayit k ON o.id = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY o.id
ORDER BY toplam_kredi DESC;

--subquery not otalama genel ortalamanın üstünde olan öğrenciler

SELECT ad, not_ort
FROM ogrenci
WHERE not_ort > (SELECT AVG(not_ort) FROM ogrenci)
ORDER BY not_ort DESC;

--En çok ders alan öğrenciler
SELECT o.ad AS ogrenci, COUNT(k.ders_id) AS ders_sayisi
FROM ogrenci o
JOIN kayit k ON o.id = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY o.id
ORDER BY ders_sayisi DESC;

--harf notu if else case end
SELECT o.ad,
	CASE
		WHEN AVG(k.notu) >= 90 THEN 'AA'
		WHEN AVG(k.notu) >= 80 THEN 'BB'
		WHEN AVG(k.notu) >= 70 THEN 'CC'
		WHEN AVG(k.notu) >= 60 THEN 'DD'
		ELSE 'FF'
	END AS harf_notu	
FROM ogrenci o
JOIN kayit k ON o.id = k.ogrenci_id
GROUP BY o.id, o.ad

--her öğrencinin derslerde kaçıncı geldiğini gösterir
SELECT o.ad, d.ad AS ders, k.notu,
	row_number() OVER (PARTITION BY k.ders_id ORDER BY k.notu DESC) AS siralama
FROM ogrenci o
JOIN kayit k ON o.id = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id;

-- öğrenci başına toplam kredi ve sınıfın kredi ortalaması
SELECT 
	o.ad AS ogrenci, 
	SUM(d.kredi) AS ogrenci_toplam_kredi, 
	d.ad AS ders_adi, 
	ROUND(AVG(SUM(d.kredi)) OVER(), 2) AS sinif_kredi_ortalamasi
FROM ogrenci o
JOIN kayit k ON o.id = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY ders_adi, o.id
ORDER BY ogrenci_toplam_kredi DESC;

-- CTE with common table expression
-- önce öğrenci ortalamasını hesapla sonra kullan
WITH ogrenci_ort as (
	SELECT o.id, o.ad, AVG(k.notu) AS ort
	FROM ogrenci o
	JOIN kayit k ON o.id = k.ogrenci_id
	GROUP BY o.id, o.ad
)
SELECT * FROM ogrenci_ort WHERE ort>80 ORDER BY ort desc;

--Kaç farklı derse not verilmiş
SELECT DISTINCT ders_id FROM kayit;

--ders başına istatistik
SELECT d.ad,
	COUNT(k.ogrenci_id) AS ogrenci_sayisi,
	AVG(k.notu) AS ort_not,
	MIN(k.notu) AS en_dusuk,
	MAX(k.notu) AS en_yuksek,
	STDDEV (k.notu) AS standart_sapma
FROM ders d
LEFT JOIN kayit k on d.id = k.ders_id
GROUP BY d.id, d.ad
ORDER BY ort_not DESC;

--Her öğrencinin sıralaması
SELECT o.ad, d.ad as ders, k.notu,
	row_number() over (PARTITION by k.ders_id order by k.notu desc) as siralama
from ogrenci o
join kayit k on o.id = k.ogrenci_id
join ders d on k.ders_id = d.id;

SELECT
	o.ad AS ogrenci_adi,
	SUM(d.kredi) AS ogrenci_toplam_kredisi,
	ROUND(AVG(SUM(d.kredi)) OVER(), 2) AS sinif_kredi_ortalamasi
FROM ogrenci o
JOIN kayit k On o.id = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY o.id, o.ad
ORDER BY ogrenci_toplam_kredisi DESC;