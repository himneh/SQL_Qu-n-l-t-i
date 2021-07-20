﻿--Lớp: CQ2019/03
--Room: 23
--Mã đề thi: 322
--MSSV: 19120583
--Họ tên: Lê Thái Bình Minh

-------Bài làm --------------
USE QLLV

--Câu 1:
SELECT TV.MSGV, GV.HOTEN, BM.TENBM
FROM THANHVIENHD TV JOIN GIANGVIEN GV ON GV.MSGV = TV.MSGV
JOIN BOMON BM ON BM.MABM =  GV.MABM
WHERE TV.VAITRO = N'Chủ tịch hội đồng'
GROUP BY TV.MSGV, GV.HOTEN, BM.TENBM
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
						FROM THANHVIENHD TV2 JOIN GIANGVIEN GV2 ON GV2.MSGV = TV2.MSGV
						WHERE TV2.VAITRO = N'Chủ tịch hội đồng'
						GROUP BY TV2.MSGV)
GO

--Câu 2:
SELECT TV.MSGV, GV.HOTEN
FROM KETQUABAOVE KQ JOIN THANHVIENHD TV ON TV.ID = KQ.ID
JOIN GIANGVIEN GV ON GV.MSGV = TV.MSGV
JOIN LUANVAN LV ON LV.MSLV = KQ.MSLV	
WHERE LV.TENLV = N'Nghiên cứu xây dựng website học online'
GROUP BY KQ.DIEM, TV.MSGV, GV.HOTEN
HAVING KQ.DIEM = (SELECT MAX(KQ2.DIEM)
					FROM KETQUABAOVE KQ2 JOIN LUANVAN LV2 ON LV2.MSLV = KQ2.MSLV
					WHERE LV2.TENLV = N'Nghiên cứu xây dựng website học online')
GO

--Câu 3:
--R là THANHVIENHOIDONG
--S là GIANGVIEN
SELECT DISTINCT TV.MAHD, TV.NAM
FROM THANHVIENHD TV
WHERE NOT EXISTS( SELECT GV.MSGV FROM GIANGVIEN GV, BOMON BM
WHERE GV.MABM = BM.MABM AND BM.TENBM = N'Mạng máy tính'
EXCEPT
(SELECT TV1.MSGV
FROM THANHVIENHD TV1
WHERE TV1.MAHD = TV.MAHD AND TV1.NAM = TV .NAM))
GO

--Câu 4:
CREATE PROC sp_ThemTVHoiDong @id CHAR(10), @magv CHAR(6), @mahd int, @nam CHAR(4), @vt NVARCHAR(20)
AS
	--KIỂM TRA GIÁO VIÊN CÓ TỒN TẠI HAY KHÔNG
	IF(NOT EXISTS (SELECT * FROM GIANGVIEN GV WHERE GV.MSGV = @magv))
		RETURN -1
	
	--KIỂM TRA HỘI ĐỒNG CÓ TỒN TẠI HAY KHÔNG
	IF(NOT EXISTS (SELECT * FROM HOIDONG HD WHERE HD.MAHD = @mahd AND HD.NAM = @nam))
		RETURN -1

	--KIỂM TRA VAI TRÒ THÀNH VIÊN HỘI ĐỒNG
		--NẾU ĐÃ CÓ CHỦ TỊCH HOẶC THƯ KÝ
	IF(EXISTS(SELECT * FROM THANHVIENHD TV WHERE TV.MAHD = @mahd AND (TV.VAITRO = N'Chủ tịch hội đồng'
														OR TV.VAITRO = N'Thư kí')))
		RETURN -1 
		--NẾU ĐÃ ĐỦ 3 ỦY VIÊN
	IF(EXISTS(SELECT TV.MSGV FROM THANHVIENHD TV WHERE TV.MAHD = @mahd AND TV.VAITRO = N'Ủy viên'
			GROUP BY TV.MSGV HAVING COUNT(TV.MSGV) >= 3))
		RETURN -1

	INSERT INTO THANHVIENHD VALUES (@id, @mahd, @nam, @magv, @vt)
GO
--test
INSERT INTO HOIDONG VALUES(4,'2020')
DECLARE @ID INT, @magv CHAR(6), @mahd int, @nam CHAR(4), @vt NVARCHAR(20)
SET @ID = 1111
SET @mahd = 4
SET @magv = 'GV1010'
SET @NAM = '2020'
SET @VT = N'Chủ tịch hội đồng'
DECLARE @ANS INT
EXEC @ANS = sp_ThemTVHoiDong @ID, @magv, @mahd, @nam, @vt
PRINT @ANS