# SQL-data-analysis-and-Criminal-Investigation-
## 🔎 Project Overview

On **July 28, 2024**, the Duck was stolen from Humphrey Street in the town of Fiftyville.  
Using only the clues (date & location) and a relational SQLite database (`fiftyville.db`), this project:

1. Identifies **who** stole the Duck  
2. Determines **which city** they fled to  
3. Uncovers their **accomplice**

All conclusions are drawn by writing layered SQL queries across multiple tables.

---

## 🗄 Database Schema

The provided **`fiftyville.db`** contains:

| Table Name                 | Description                              |
| -------------------------- | ---------------------------------------- |
| `people`                   | Personal records (names, IDs, etc.)      |
| `crime_scene_reports`      | Details of crimes & locations            |
| `flights`                  | Flight schedules & routes                |
| `airports`                 | Airport codes & cities                   |
| `passengers`               | Who flew on which flight                 |
| `bank_accounts`            | Account holders & transactions           |
| `atm_transactions`         | ATM withdrawal logs                      |
| `phone_calls`              | Call records with timestamps             |
| `interviews`               | Witness & suspect interviews             |
| `bakery_security_logs`     | CCTV timestamps from Humphrey Street 
