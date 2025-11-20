# 📘 BiddingDB – Docker + SQL Server 2022 Ready for Test
This project contains a fully prepared Docker environment to spin up a SQL Server 2022, create the BiddingDB database, generate all required tables, and automatically execute random inserts (20+ records in each table) through the init.sql script.”
---

## 📁 Folder Structure

```
SQLTest/
│
├── init/
│   └── init.sql        # Full Script: DB Creation, Tables and seeds
│
└── docker-compose.yml  # Docker Composer up + executes the seed by default
```

---

## 🐳 Docker Compose

File used to spin up SQL Server and run the seed script:

```yaml
version: "3.9"

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sql-bidding-db
    ports:
      - "1433:1433"
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_PID=Developer
      - MSSQL_SA_PASSWORD=@@Matheus#2025
    volumes:
      - mssql-data:/var/opt/mssql

  db-init:
    image: mcr.microsoft.com/mssql-tools:latest
    depends_on:
      - sqlserver
    environment:
      - SA_PASSWORD=@@Matheus#2025
    volumes:
      - ./init:/init:ro
    entrypoint: >
      bash -c "
      /opt/mssql-tools/bin/sqlcmd -S sqlserver,1433 -U sa -P '@@Matheus#2025' -i /init/init.sql
      && echo 'Seed executed successfully'
      || (echo 'Seed Failed' && exit 1)
      "
    restart: "no"

volumes:
  mssql-data:
```

---

## 🗄️ init.sql – Content

The file `init.sql` has:

### ✔ DB Creation:

```sql
IF DB_ID('BiddingDB') IS NULL
BEGIN
    CREATE DATABASE BiddingDB;
END
GO
USE BiddingDB;
GO
```

---

### ✔ Creation of the DB tables in order :

- Facility  
- Landowner  
- BidPackage  
- FacilityWork  
- BidPackageFacilityWork  
- BidResponse  
- BidResponseFacilityWork  
- Invoice  
- InvoiceFacilityWork  
- LandownerFacilityLink  
- LandownerBidResponseLink  

Each portion uses:

```sql
IF OBJECT_ID('dbo.Table', 'U') IS NULL
BEGIN
    CREATE TABLE ...
END
GO
```

---

### ✔ Inserts (SEED) — 20 registers per table

“Each table inserts 20 random records using a combination of:”

- `NEWID()`
- `ABS(CHECKSUM())`
- `TOP (20)`
- `CROSS JOIN sys.all_objects`

And Always Checking:

```sql
IF NOT EXISTS (SELECT 1 FROM dbo.Tabela)
BEGIN
    INSERT ...
END
```

💡 **Seed only runs with empty table**

---

## ▶️ How to Execute

Just execute this on root project folder

```bash
docker-compose up -d
```

Flw:

1. SQL Server installs 
2. The `db-init` container waits for SQL to load
3. Automatically executes `init/init.sql`  
4. Logs:

- “Seed executed with success”
- ou  
- “Seed Failed”

---

## 🔑 DB Access

```
Server=localhost,1433
User=sa
Password=@@Matheus#2025
Database=BiddingDB
```

---

## 📦 Persistent Volume

“The mssql-data volume stores the database and its data, even after restarting the container.”

---

## 🏁 Conclusion

This environment provides:

Optimized SQL Server in Docker

Automatic creation of all tables

Complete seed with 20+ records per table

Clean structure

Perfect for testing.”
