\set BASE '/photos'


-- ================
-- USER AVATARS (10)
-- ================

-- admin (Alice) -> female
SELECT lo_import(:'BASE' || '/avatar_photos/f1.jpg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'f1.jpg'
WHERE username = 'admin';
SELECT lo_unlink(:oid);

-- owner1 (Bob) -> male
SELECT lo_import(:'BASE' || '/avatar_photos/m1.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'm1.jpeg'
WHERE username = 'owner1';
SELECT lo_unlink(:oid);

-- owner2 (Carol) -> female
SELECT lo_import(:'BASE' || '/avatar_photos/f2.webp') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/webp',
    profile_picture_filename = 'f2.webp'
WHERE username = 'owner2';
SELECT lo_unlink(:oid);

-- renter1 (Dave) -> male
SELECT lo_import(:'BASE' || '/avatar_photos/m2.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'm2.jpeg'
WHERE username = 'renter1';
SELECT lo_unlink(:oid);

-- renter2 (Eve) -> female
SELECT lo_import(:'BASE' || '/avatar_photos/f3.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'f3.jpeg'
WHERE username = 'renter2';
SELECT lo_unlink(:oid);

-- user1 (Frank) -> male
SELECT lo_import(:'BASE' || '/avatar_photos/m3.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'm3.jpeg'
WHERE username = 'user1';
SELECT lo_unlink(:oid);

-- user2 (Grace) -> female
SELECT lo_import(:'BASE' || '/avatar_photos/f4.jpg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'f4.jpg'
WHERE username = 'user2';
SELECT lo_unlink(:oid);

-- owner3 (Hank) -> male
SELECT lo_import(:'BASE' || '/avatar_photos/m4.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'm4.jpeg'
WHERE username = 'owner3';
SELECT lo_unlink(:oid);

-- renter3 (Ivy) -> female  (δεν υπάρχει f5.jpg, κάνω reuse f1.jpg)
SELECT lo_import(:'BASE' || '/avatar_photos/f1.jpg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'f1.jpg'
WHERE username = 'renter3';
SELECT lo_unlink(:oid);

-- user3 (John) -> male
SELECT lo_import(:'BASE' || '/avatar_photos/m5.jpeg') AS oid \gset
UPDATE users
SET profile_picture = lo_get(:oid),
    profile_picture_content_type = 'image/jpeg',
    profile_picture_filename = 'm5.jpeg'
WHERE username = 'user3';
SELECT lo_unlink(:oid);


-- =======================
-- PROPERTY PHOTOS (2/prop)
-- =======================

-- id=1: Lake Villa
SELECT lo_import(:'BASE' || '/property_photos/Lake Villa 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (1, lo_get(:oid), 'image/jpeg', 'Lake Villa 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Lake Villa 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (1, lo_get(:oid), 'image/jpeg', 'Lake Villa 2.jpg');
SELECT lo_unlink(:oid);

-- id=2: City Loft
SELECT lo_import(:'BASE' || '/property_photos/City Loft 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (2, lo_get(:oid), 'image/jpeg', 'City Loft 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/City Loft 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (2, lo_get(:oid), 'image/jpeg', 'City Loft 2.jpg');
SELECT lo_unlink(:oid);

-- id=3: Sea House
SELECT lo_import(:'BASE' || '/property_photos/Sea House 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (3, lo_get(:oid), 'image/jpeg', 'Sea House 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Sea House 2.jpeg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (3, lo_get(:oid), 'image/jpeg', 'Sea House 2.jpeg');
SELECT lo_unlink(:oid);

-- id=4: Mountain Cabin
SELECT lo_import(:'BASE' || '/property_photos/Mountain Cabin 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (4, lo_get(:oid), 'image/jpeg', 'Mountain Cabin 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Mountain Cabin 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (4, lo_get(:oid), 'image/jpeg', 'Mountain Cabin 2.jpg');
SELECT lo_unlink(:oid);

-- id=5: Garden Home
SELECT lo_import(:'BASE' || '/property_photos/Garden Home 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (5, lo_get(:oid), 'image/jpeg', 'Garden Home 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Garden Home 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (5, lo_get(:oid), 'image/jpeg', 'Garden Home 2.jpg');
SELECT lo_unlink(:oid);

-- id=6: Old Town Flat   (FILES: "Old Twon Flat *.JPEG")
SELECT lo_import(:'BASE' || '/property_photos/Old Twon Flat 1.JPEG') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (6, lo_get(:oid), 'image/jpeg', 'Old Twon Flat 1.JPEG');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Old Twon Flat 2.JPEG') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (6, lo_get(:oid), 'image/jpeg', 'Old Twon Flat 2.JPEG');
SELECT lo_unlink(:oid);

-- id=7: Island Studio
SELECT lo_import(:'BASE' || '/property_photos/Island Studio 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (7, lo_get(:oid), 'image/jpeg', 'Island Studio 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Island Studio 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (7, lo_get(:oid), 'image/jpeg', 'Island Studio 2.jpg');
SELECT lo_unlink(:oid);

-- id=8: Sunset Suite
SELECT lo_import(:'BASE' || '/property_photos/Sunset Suite 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (8, lo_get(:oid), 'image/jpeg', 'Sunset Suite 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Sunset Suite 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (8, lo_get(:oid), 'image/jpeg', 'Sunset Suite 2.jpg');
SELECT lo_unlink(:oid);

-- id=9: Suburb House
SELECT lo_import(:'BASE' || '/property_photos/Suburb House 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (9, lo_get(:oid), 'image/jpeg', 'Suburb House 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Suburb House 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (9, lo_get(:oid), 'image/jpeg', 'Suburb House 2.jpg');
SELECT lo_unlink(:oid);

-- id=10: Riverside
SELECT lo_import(:'BASE' || '/property_photos/Riverside 1.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (10, lo_get(:oid), 'image/jpeg', 'Riverside 1.jpg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Riverside 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (10, lo_get(:oid), 'image/jpeg', 'Riverside 2.jpg');
SELECT lo_unlink(:oid);

-- id=11: Stone House
SELECT lo_import(:'BASE' || '/property_photos/Stone House 1.jpeg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (11, lo_get(:oid), 'image/jpeg', 'Stone House 1.jpeg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/Stone House 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (11, lo_get(:oid), 'image/jpeg', 'Stone House 2.jpg');
SELECT lo_unlink(:oid);

-- id=12: City View
SELECT lo_import(:'BASE' || '/property_photos/City View 1.jpeg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (12, lo_get(:oid), 'image/jpeg', 'City View 1.jpeg');
SELECT lo_unlink(:oid);
SELECT lo_import(:'BASE' || '/property_photos/City View 2.jpg') AS oid \gset
INSERT INTO property_photos (property_id, image, content_type, filename)
VALUES (12, lo_get(:oid), 'image/jpeg', 'City View 2.jpg');
SELECT lo_unlink(:oid);

