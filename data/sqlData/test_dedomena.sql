-- ============
-- RESET (προαιρετικό: καθαρίζει όλα τα δεδομένα)
-- ============
TRUNCATE TABLE reviews RESTART IDENTITY CASCADE;
TRUNCATE TABLE rentals RESTART IDENTITY CASCADE;
TRUNCATE TABLE property_photos RESTART IDENTITY CASCADE;
TRUNCATE TABLE properties RESTART IDENTITY CASCADE;
TRUNCATE TABLE user_roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE users RESTART IDENTITY CASCADE;

-- ============
-- USERS (10)
-- password: "pass123" (bcrypt)
-- ============
-- bcrypt("pass123") generated once & reused for all:
-- Χρησιμοποίησε αυτό που ήδη δουλεύει στο project σου αν έχεις διαφορετικό format.
-- Παρακάτω σου βάζω ένα κλασικό έγκυρο bcrypt για "pass123":
-- $2a$10$9e2E0h0Jm4u4cYwz0pM1WOMm2qJmP8uU0s8m2o2k1c8QqQFv2oJrS
-- Αν δεις 401 στο login, άλλαξέ το με δικό σου hash.

WITH pwd AS (
    SELECT '$2a$10$BorzpQK2bWX51uHQA28Z5uaoCbKgVBqs2vK.OjgF0nVs6ufLR11AW'::varchar AS p
)
INSERT INTO users(id, username, password, email, first_name, last_name, passport_number, afm, enabled, account_non_locked, renter_request_status)
SELECT  1,'admin'  ,p,'admin@example.com'  ,'Alice','Papadaki'    ,'P000001','AFM000001',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  2,'owner1' ,p,'owner1@example.com' ,'Bob'  ,'Nikolaidis'  ,'P000002','AFM000002',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  3,'owner2' ,p,'owner2@example.com' ,'Carol','Spanou'      ,'P000003','AFM000003',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  4,'renter1',p,'renter1@example.com','Dave' ,'Kouris'      ,'P000004','AFM000004',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  5,'renter2',p,'renter2@example.com','Eve'  ,'Vlachou'     ,'P000005','AFM000005',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  6,'user1'  ,p,'user1@example.com'  ,'Frank','Georgiou'    ,'P000006','AFM000006',true,true,'REJECTED' FROM pwd UNION ALL
SELECT  7,'user2'  ,p,'user2@example.com'  ,'Grace','Papanikolaou','P000007','AFM000007',true,true,'PENDING'  FROM pwd UNION ALL
SELECT  8,'owner3' ,p,'owner3@example.com' ,'Hank' ,'Christou'    ,'P000008','AFM000008',true,true,'APPROVED' FROM pwd UNION ALL
SELECT  9,'renter3',p,'renter3@example.com','Ivy'  ,'Karveli'     ,'P000009','AFM000009',true,true,'APPROVED' FROM pwd UNION ALL
SELECT 10,'user3'  ,p,'user3@example.com'  ,'John' ,'Mavridis'    ,'P000010','AFM000010',true,true,'REJECTED' FROM pwd
ON CONFLICT (id) DO NOTHING;
-- ============
-- USER_ROLES (πολλοί-πολλοί μέσω ElementCollection)
-- ============
INSERT INTO user_roles(user_id, role) VALUES
                                          (1,'ADMIN'),(1,'USER'),
                                          (2,'USER'),(2,'RENTER'),
                                          (3,'USER'),(3,'RENTER'),
                                          (4,'USER'),(4,'RENTER'),
                                          (5,'USER'),(5,'RENTER'),
                                          (6,'USER'),
                                          (7,'USER'),
                                          (8,'USER'),(8,'RENTER'),
                                          (9,'USER'),(9,'RENTER'),
                                          (10,'USER');

-- ============
-- PROPERTIES (12) (owners: 2,3,8)
-- ============
INSERT INTO properties(id, name, description, country, city, street, postal_code, square_meters, approval_status, price, user_id)
VALUES
    (1,'Lake Villa','By the lake','Greece','Ioannina','Waterfront 3','45221',120.0,'APPROVED', 200.00, 2),
    (2,'City Loft','Center loft','Greece','Athens','Ermou 10','10563',55.0,'APPROVED',  75.00, 2),
    (3,'Sea House','Near the sea','Greece','Chania','Akti 8','73100',85.0,'PENDING', 120.00, 2),
    (4,'Mountain Cabin','Wood cabin','Greece','Metsovo','Forest 1','44200',60.0,'APPROVED', 95.00, 3),
    (5,'Garden Home','Green view','Greece','Larisa','Kipos 5','41222',90.0,'APPROVED', 110.00, 3),
    (6,'Old Town Flat','Classic style','Greece','Rhodes','Sokratous 15','85100',45.0,'REJECTED', 60.00, 3),
    (7,'Island Studio','Quiet place','Greece','Paros','Port 2','84400',35.0,'APPROVED', 70.00, 8),
    (8,'Sunset Suite','Best sunsets','Greece','Santorini','Caldera 1','84700',40.0,'APPROVED', 150.00, 8),
    (9,'Suburb House','Family home','Greece','Thessaloniki','Oak 12','54321',110.0,'APPROVED', 130.00, 2),
    (10,'Riverside','Near river','Greece','Kastoria','River 7','52100',75.0,'APPROVED', 80.00, 3),
    (11,'Stone House','Traditional','Greece','Mani','Stone 4','23071',65.0,'PENDING', 90.00, 8),
    (12,'City View','Top floor','Greece','Athens','View 22','11522',50.0,'APPROVED', 85.00, 8);

-- ============
-- RENTALS (12) (approved + pending, με future & past ημερομηνίες)
-- ============
-- helper: today = current_date
-- Προσοχή: endDate > startDate (exclusive logic στο service σου)
INSERT INTO rentals(id, start_date, end_date, payment_amount, approval_status, user_id, property_id) VALUES
                                                                                                         -- APPROVED παλαιά (για να μπορεί να αφήσει review)
                                                                                                         (1, DATE '2024-01-10', DATE '2024-01-15', 5*200.00, 'APPROVED', 4, 1),   -- renter1 στο Lake Villa
                                                                                                         (2, DATE '2024-03-01', DATE '2024-03-05', 4* 75.00, 'APPROVED', 5, 2),   -- renter2 στο City Loft
                                                                                                         (3, DATE '2024-05-20', DATE '2024-05-25', 5* 95.00, 'APPROVED', 9, 4),

                                                                                                         -- APPROVED πρόσφατα/μέλλον
                                                                                                         (4, CURRENT_DATE + 5, CURRENT_DATE + 9, 4*110.00, 'APPROVED', 4, 5),
                                                                                                         (5, CURRENT_DATE + 10, CURRENT_DATE + 15, 5* 70.00, 'APPROVED', 5, 7),
                                                                                                         (6, CURRENT_DATE + 20, CURRENT_DATE + 23, 3*150.00, 'APPROVED', 9, 8),

                                                                                                         -- PENDING (για overlap δοκιμές)
                                                                                                         (7,  CURRENT_DATE + 1, CURRENT_DATE + 3, 2*130.00, 'PENDING', 4, 9),
                                                                                                         (8,  CURRENT_DATE + 12, CURRENT_DATE + 14, 2* 80.00, 'PENDING', 5, 10),
                                                                                                         (9,  CURRENT_DATE + 25, CURRENT_DATE + 30, 5* 85.00, 'PENDING', 9, 12),

                                                                                                         -- Διάφορα ακόμα
                                                                                                         (10, DATE '2024-07-10', DATE '2024-07-12', 2*110.00, 'APPROVED', 4, 5),
                                                                                                         (11, DATE '2024-08-01', DATE '2024-08-03', 2* 70.00, 'APPROVED', 5, 7),
                                                                                                         (12, DATE '2024-09-15', DATE '2024-09-18', 3*150.00, 'APPROVED', 9, 8);

-- ============
-- REVIEWS (12) — μόνο για APPROVED rentals με endDate < today
-- (για τα rentals 1,2,3,10,11,12)
-- ============
INSERT INTO reviews(id, content, rating, created_at, user_id, property_id, rental_id) VALUES
                                                                                          (1, 'Άψογη εμπειρία στη λίμνη.', 5, NOW() - INTERVAL '10 days', 4, 1, 1),
                                                                                          (2, 'Κέντρο αλλά λίγο θόρυβος.', 4, NOW() - INTERVAL '9 days', 5, 2, 2),
                                                                                          (3, 'Όμορφη καμπίνα, καθαρή.', 5, NOW() - INTERVAL '8 days', 9, 4, 3),

                                                                                          (4, 'Κήπος υπέροχος, ήσυχα.', 5, NOW() - INTERVAL '7 days', 4, 5, 10),
                                                                                          (5, 'Στούντιο άνετο, κοντά στη θάλασσα.', 4, NOW() - INTERVAL '6 days', 5, 7, 11),
                                                                                          (6, 'Θέα στο ηλιοβασίλεμα, αξίζει!', 5, NOW() - INTERVAL '5 days', 9, 8, 12),

                                                                                          (7, 'Καλή τιμή για παροχές.', 4, NOW() - INTERVAL '4 days', 4, 5, 10),
                                                                                          (8, 'Ικανοποιητικό στούντιο.', 3, NOW() - INTERVAL '3 days', 5, 7, 11),
                                                                                          (9, 'Ρομαντική βεράντα!', 5, NOW() - INTERVAL '2 days', 9, 8, 12),

                                                                                          (10, 'Πολύ καθαρά δωμάτια.', 5, NOW() - INTERVAL '15 days', 4, 1, 1),
                                                                                          (11, 'Καλό WiFi, κεντρικό.', 4, NOW() - INTERVAL '20 days', 5, 2, 2),
                                                                                          (12, 'Τζάκι και ατμόσφαιρα.', 5, NOW() - INTERVAL '25 days', 9, 4, 3);

-- Ρυθμίζει τις sequences να "πιάσουν" το MAX(id) κάθε πίνακα.
-- Δουλεύει τόσο για SERIAL όσο και για IDENTITY.

SELECT setval(pg_get_serial_sequence('users','id'),           COALESCE((SELECT MAX(id) FROM users), 0), true);
SELECT setval(pg_get_serial_sequence('properties','id'),      COALESCE((SELECT MAX(id) FROM properties), 0), true);
SELECT setval(pg_get_serial_sequence('rentals','id'),         COALESCE((SELECT MAX(id) FROM rentals), 0), true);
SELECT setval(pg_get_serial_sequence('reviews','id'),         COALESCE((SELECT MAX(id) FROM reviews), 0), true);
SELECT setval(
               pg_get_serial_sequence('property_photos','id'),
               CASE WHEN (SELECT COUNT(*) FROM property_photos)=0 THEN 1 ELSE (SELECT MAX(id) FROM property_photos) END,
               CASE WHEN (SELECT COUNT(*) FROM property_photos)=0 THEN false ELSE true END
       );
