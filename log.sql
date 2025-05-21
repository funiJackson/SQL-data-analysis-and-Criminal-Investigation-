-- Log of any SQL queries execute as solve the mystery.

sqlite> .tables
airports              crime_scene_reports   people
atm_transactions      flights               phone_calls
bakery_security_logs  interviews
bank_accounts         passengers

TABLE crime_scene_reports (
    id INTEGER,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    street TEXT,
    description TEXT,
    PRIMARY KEY(id)
);

CREATE TABLE interviews (
    id INTEGER,
    name TEXT,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    transcript TEXT,
    PRIMARY KEY(id)
);

CREATE TABLE bakery_security_logs (
    id INTEGER,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    hour INTEGER,
    minute INTEGER,
    activity TEXT,
    license_plate TEXT,
    PRIMARY KEY(id));

CREATE TABLE atm_transactions (
    id INTEGER,
    account_number INTEGER,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    atm_location TEXT,
    transaction_type TEXT,
    amount INTEGER,
    PRIMARY KEY(id)
);

CREATE TABLE phone_calls (
    id INTEGER,
    caller TEXT,
    receiver TEXT,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    duration INTEGER,
    PRIMARY KEY(id)
);

CREATE TABLE flights (
    id INTEGER,
    origin_airport_id INTEGER,
    destination_airport_id INTEGER,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    hour INTEGER,
    minute INTEGER,
    PRIMARY KEY(id),
    FOREIGN KEY(origin_airport_id) REFERENCES airports(id),
    FOREIGN KEY(destination_airport_id) REFERENCES airports(id)
);

CREATE TABLE people (
    id INTEGER,
    name TEXT,
    phone_number TEXT,
    passport_number INTEGER,
    license_plate TEXT,
    PRIMARY KEY(id)
);

CREATE TABLE bank_accounts (
    account_number INTEGER,
    person_id INTEGER,
    creation_year INTEGER,
    FOREIGN KEY(person_id) REFERENCES people(id)
);

CREATE TABLE passengers (
    flight_id INTEGER,
    passport_number INTEGER,
    seat TEXT,
    FOREIGN KEY(flight_id) REFERENCES flights(id)
);

CREATE TABLE airports (
    id INTEGER,
    abbreviation TEXT,
    full_name TEXT,
    city TEXT,
    PRIMARY KEY(id)
);

-- Find the description of the crime
SELECT description
FROM crime_scene_reports
WHERE month = 7 AND day = 28
AND street = 'Humphrey Street';

--Theft took place at 10:15am at the Humphrey Street bakery.
--Interviews were conducted today with three witnesses who were present at the time--each of their interview transcripts mentions the bakery.

-- Find some clue in the interview logs
SELECT transcript,name  FROM interviews WHERE month = 7 AND day = 28 AND year = 2024;
--Some useful info about the interview
--Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame. | Ruth    |
--| I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.| Eugene  |
--| As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. | Raymond |

--Base on the Ruth's interview, les's check out the car left the parking lot around 10:25
SELECT bakery_security_logs.activity,bakery_security_logs.license_plate,people.name FROM people
JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
WHERE bakery_security_logs.year = 2024
AND bakery_security_logs.month = 7
AND bakery_security_logs.day = 28
AND bakery_security_logs.hour = 10
AND bakery_security_logs.minute >= 15
AND bakery_security_logs.minute <= 25;
--Below are the car and the people exit at that time
+----------+---------------+---------+
| activity | license_plate |  name   |
+----------+---------------+---------+
| exit     | 5P2BI95       | Vanessa |
| exit     | 94KL13X       | Bruce   |
| exit     | 6P58WS2       | Barry   |
| exit     | 4328GD8       | Luca    |
| exit     | G412CB7       | Sofia   |
| exit     | L93JTIZ       | Iman    |
| exit     | 322W7JE       | Diana   |
| exit     | 0NTHK55       | Kelsey  |
+----------+---------------+---------+

--Base on the Eugene's interview, let's check out who withdrewing money on Leggett Street via ATM.
SELECT people.name,atm_transactions.transaction_type FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
WHERE atm_transactions.year = 2024
AND atm_transactions.month = 7
AND atm_transactions.day = 28
AND atm_transactions.atm_location = 'Leggett Street'
AND atm_transactions.transaction_type = 'withdraw';
+---------+------------------+
|  name   | transaction_type |
+---------+------------------+
| Bruce   | withdraw         |
| Diana   | withdraw         |
| Brooke  | withdraw         |
| Kenny   | withdraw         |
| Iman    | withdraw         |
| Luca    | withdraw         |
| Taylor  | withdraw         |
| Benista | withdraw         |
+---------+------------------+
-- Base on Raymond's interview, we can check out the phone call info around the crime time also the purchase info of flight ticket
ALTER TABLE phone_calls
ADD caller_name TEXT;

ALTER TABLE phone_calls
ADD receiver_name TEXT;

UPDATE phone_calls
SET caller_name = people.name
FROM people
WHERE phone_calls.caller = people.phone_number;

UPDATE phone_calls
SET receiver_name = people.name
FROM people
WHERE phone_calls.receiver = people.phone_number;


SELECT caller, caller_name, receiver, receiver_name FROM phone_calls
WHERE year = 2024
AND month = 7
AND day = 28
AND duration < 60;

--Below are the caller and the receiver, we can use this to find the accomplice later.
+----------------+-------------+----------------+---------------+
|     caller     | caller_name |    receiver    | receiver_name |
+----------------+-------------+----------------+---------------+
| (130) 555-0289 | Sofia       | (996) 555-8899 | Jack          |
| (499) 555-9472 | Kelsey      | (892) 555-8872 | Larry         |
| (367) 555-5533 | Bruce       | (375) 555-8161 | Robin         |
| (499) 555-9472 | Kelsey      | (717) 555-1342 | Melissa       |
| (286) 555-6063 | Taylor      | (676) 555-6554 | James         |
| (770) 555-1861 | Diana       | (725) 555-3243 | Philip        |
| (031) 555-6622 | Carina      | (910) 555-3251 | Jacqueline    |
| (826) 555-1652 | Kenny       | (066) 555-9701 | Doris         |
| (338) 555-6650 | Benista     | (704) 555-2131 | Anna          |
+----------------+-------------+----------------+---------------+

--Find the earliest flight ticket.
SELECT id, hour, minute, origin_airport_id, destination_airport_id
FROM flights
WHERE year = 2024
AND month = 7 AND DAY = 29
ORDER BY hour ASC
LIMIT 1;

-- the flight which the criminal going to take
+----+------+--------+-------------------+------------------------+
| id | hour | minute | origin_airport_id | destination_airport_id |
+----+------+--------+-------------------+------------------------+
| 36 | 8    | 20     | 8                 | 4                      |
+----+------+--------+-------------------+------------------------+

--So let's find out what origin_airport_id(8) and destination_airport_id(4) stands for
SELECT city FROM airports WHERE id = 8 OR id = 4;

+---------------+
|     city      |
+---------------+
| New York City |
| Fiftyville    |
+---------------+
--find out the flights.id = 36, see those people's info
SELECT flights.destination_airport_id, name, phone_number, license_plate FROM people
JOIN passengers ON people.passport_number = passengers.passport_number
JOIN flights ON flights.id = passengers.flight_id
WHERE flights.id = 36
ORDER BY flights.hour ASC;

+------------------------+--------+----------------+---------------+
| destination_airport_id |  name  |  phone_number  | license_plate |
+------------------------+--------+----------------+---------------+
| 4                      | Doris  | (066) 555-9701 | M51FA04       |
| 4                      | Sofia  | (130) 555-0289 | G412CB7       |
| 4                      | Bruce  | (367) 555-5533 | 94KL13X       |
| 4                      | Edward | (328) 555-1152 | 130LD9Z       |
| 4                      | Kelsey | (499) 555-9472 | 0NTHK55       |
| 4                      | Taylor | (286) 555-6063 | 1106N58       |
| 4                      | Kenny  | (826) 555-1652 | 30G67EN       |
| 4                      | Luca   | (389) 555-5198 | 4328GD8       |
+------------------------+--------+----------------+---------------+

--Join all these table together and finds out who appeared in all these tables.
SELECT name FROM people
JOIN passengers ON people.passport_number = passengers.passport_number
JOIN flights ON flights.id = passengers.flight_id
WHERE (flights.year = 2024 AND flights.month = 7 AND flights.day = 29 AND flights.id = 36)
AND name IN
(SELECT phone_calls.caller_name FROM phone_calls
WHERE year = 2024
AND month = 7
AND day = 28
AND duration < 60)
AND name IN
(SELECT people.name FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
WHERE atm_transactions.year = 2024
AND atm_transactions.month = 7
AND atm_transactions.day = 28
AND atm_transactions.atm_location = 'Leggett Street'
AND atm_transactions.transaction_type = 'withdraw')
AND name IN
(SELECT people.name FROM people
JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
WHERE bakery_security_logs.year = 2024
AND bakery_security_logs.month = 7
AND bakery_security_logs.day = 28
AND bakery_security_logs.hour = 10
AND bakery_security_logs.minute >= 15
AND bakery_security_logs.minute <= 25);

--GOT YOU!!! HAHA
+-------+
| name  |
+-------+
| Bruce |
+-------+

--And base on the phone call table we generated before, we can find whose the ACCOMPLICE

+----------------+-------------+----------------+---------------+
|     caller     | caller_name |    receiver    | receiver_name |
+----------------+-------------+----------------+---------------+
| (130) 555-0289 | Sofia       | (996) 555-8899 | Jack          |
| (499) 555-9472 | Kelsey      | (892) 555-8872 | Larry         |
| (367) 555-5533 | Bruce       | (375) 555-8161 | Robin         |
| (499) 555-9472 | Kelsey      | (717) 555-1342 | Melissa       |
| (286) 555-6063 | Taylor      | (676) 555-6554 | James         |
| (770) 555-1861 | Diana       | (725) 555-3243 | Philip        |
| (031) 555-6622 | Carina      | (910) 555-3251 | Jacqueline    |
| (826) 555-1652 | Kenny       | (066) 555-9701 | Doris         |
| (338) 555-6650 | Benista     | (704) 555-2131 | Anna          |
+----------------+-------------+----------------+---------------+

-- ROBIN!!!!

--The THIEF is: Bruce
--The city the thief ESCAPED TO: New York City
--The ACCOMPLICE is: Robin
