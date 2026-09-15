PRAGMA foreign_keys = ON;

CREATE TABLE uyeler(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	ad TEXT NOT NULL,
	yas INTEGER CHECK (yas > 13),
	sehir TEXT DEFAULT 'Erzincan',
	kayit TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kitaplar(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	ad TEXT NOT NULL UNIQUE
);

CREATE TABLE odunc(
	uye_id INTEGER,
	kitap_id INTEGER,
	gun INTEGER,
	PRIMARY KEY (uye_id, kitap_id),
	FOREIGN KEY (uye_id) REFERENCES uyeler(id) ON DELETE CASCADE
	FOREIGN KEY (kitap_id) REFERENCES kitaplar(id)
);

INSERT INTO kitaplar (ad) VALUES
('Sefiller'),
('Suç ve Ceza'),
('Kürk Mantolu Madonna'),
('Simyacı'),
('1984');

INSERT INTO uyeler (ad, yas, sehir) VALUES 
('Ahmet', 25, 'Ankara'),
('Mehmet', 19, 'İstanbul'),
('Ali', 28, 'İzmir'),
('Can', 15, 'Bursa'),
('Elif', 24, 'İzmit'),
('Burak', 40, 'Antalya'),
('Deniz', 29, 'Adana');

INSERT INTO uyeler (ad, yas) VALUES
('Ayşe', 30),
('Fatma', 22),
('Burak', 18),
('Zeynep', 35);


INSERT INTO uyeler(ad, yas) VALUES ("Ufaklık", 10);
INSERT INTO odunc (uye_id, kitap_id, gun) VALUES (99, 1, 10)

INSERT INTO odunc (uye_id, kitap_id, gun) VALUES 
(1, 1, 5), (1, 2, 20),
(2, 3, 35), (2, 4, 10),
(3, 5, 40), (3, 1, 12),
(4, 2, 15), (4, 3, 25),
(5, 4, 30), (5, 5, 8),
(6, 1, 45), (6, 2, 3),
(7, 3, 14), (7, 4, 22),
(8, 5, 11), (8, 1, 33),
(9, 2, 9), (9, 3, 18),
(10, 4, 42), (10, 5, 27),
(11, 1, 16), (11, 2, 35);

SELECT u.ad, k.ad, o.gun 
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id;

SELECT u.ad, k.ad, o.gun 
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id
WHERE o.gun > 30;

SELECT u.ad, k.ad, o.gun 
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id
WHERE u.sehir = 'Erzincan';

SELECT u.ad, avg(o.gun) AS ort_gun, count(o.kitap_id) AS kitap_sayisi, max(o.gun) AS max_odunc
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id;

SELECT u.ad, avg(o.gun) AS ort_gun, count(o.kitap_id) AS kitap_sayisi, max(o.gun) AS max_odunc
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id
HAVING avg(o.gun) > 20;

SELECT k.ad, count(o.uye_id) AS odunc_sayisi
FROM kitaplar k
LEFT JOIN odunc o  ON k.id = o.kitap_id
GROUP BY k.id;

SELECT sehir, COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;

SELECT ad FROM uyeler
WHERE id IN (
	SELECT uye_id
	FROM odunc
	WHERE gun > 30
);

SELECT ad FROM kitaplar
WHERE id NOT IN (
    SELECT kitap_id
    FROM odunc
);

SELECT * FROM odunc
WHERE gun > (
    SELECT AVG(gun)
    FROM odunc
);

SELECT uye_id, kitap_id, gun,
	CASE
		WHEN gun > 30 THEN 'Gecikmiş'
		WHEN gun BETWEEN 15 and 30 THEN 'Uyarı'
		ELSE 'Normal'
	END AS durum
FROM odunc;

SELECT ad, yas,
	CASE
		WHEN yas <= 18 THEN 'Genç'
		ELSE 'Yetişkin'
	END AS yas_grubu
FROM uyeler;

SELECT 
    CASE 
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum,
    COUNT(*) AS kayit_sayisi
FROM odunc
GROUP BY durum;

SELECT
	CASE
		WHEN yas <= 18 THEN 'Genç'
		ELSE 'Yetişkin'
	END AS yas_grubu,
	COUNT(*) AS kayit_sayisi
FROM uyeler
GROUP BY yas_grubu;

CREATE INDEX idx_uyeler_ad ON uyeler(ad);

ALTER TABLE uyeler ADD COLUMN eposta TEXT;
CREATE UNIQUE INDEX idx_uyeler_eposta ON uyeler(eposta);

UPDATE uyeler
SET eposta = 'uye@mail.com'
WHERE id = 1;

UPDATE uyeler
SET eposta = 'uye@mail.com'
WHERE id = 2;