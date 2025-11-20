------------------------------------------------------------
-- 0. DB Creation(BiddingDB)
------------------------------------------------------------
IF DB_ID('BiddingDB') IS NULL
BEGIN
    PRINT 'Creating database BiddingDB...';
    CREATE DATABASE BiddingDB;
END
GO

USE BiddingDB;
GO

------------------------------------------------------------
-- 1. Tables (CREATE IF NOT EXISTS)
------------------------------------------------------------

-- 1.1 Facility
IF OBJECT_ID('dbo.Facility', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.Facility...';
    CREATE TABLE dbo.Facility (
        FacilityId        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        SourceId          INT NULL,
        SourceKeyValue    NVARCHAR(100) NULL,
        FacilityType      NVARCHAR(50) NULL,
        SourceAttributes  NVARCHAR(MAX) NULL,
        Attributes        NVARCHAR(MAX) NULL,
        CreatedBy         NVARCHAR(100) NOT NULL,
        CreatedDate       DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy         NVARCHAR(100) NULL,
        UpdatedDate       DATETIME2 NULL,
        IsMigrated        BIT NOT NULL DEFAULT 0
    );
END
GO

-- 1.2 Landowner
IF OBJECT_ID('dbo.Landowner', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.Landowner...';
    CREATE TABLE dbo.Landowner (
        LandownerId      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LandownerName    NVARCHAR(200) NOT NULL,
        Attributes       NVARCHAR(MAX) NULL,
        CreatedBy        NVARCHAR(100) NOT NULL,
        CreatedDate      DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy        NVARCHAR(100) NULL,
        UpdatedDate      DATETIME2 NULL,
        CoNo             NVARCHAR(50) NULL,
        LandownerType    NVARCHAR(50) NULL,
        LandownerStatus  NVARCHAR(50) NULL
    );
END
GO

-- 1.3 BidPackage
IF OBJECT_ID('dbo.BidPackage', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.BidPackage...';
    CREATE TABLE dbo.BidPackage (
        BidPackageId     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        BidPackageName   NVARCHAR(200) NOT NULL,
        BidPackageStatus NVARCHAR(50)  NOT NULL,
        Attributes       NVARCHAR(MAX) NULL,
        CreatedBy        NVARCHAR(100) NOT NULL,
        CreatedDate      DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy        NVARCHAR(100) NULL,
        UpdatedDate      DATETIME2 NULL
    );
END
GO

-- 1.4 FacilityWork
IF OBJECT_ID('dbo.FacilityWork', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.FacilityWork...';
    CREATE TABLE dbo.FacilityWork (
        FacilityWorkId     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        FacilityId         INT NOT NULL,
        FacilityWorkType   NVARCHAR(50) NOT NULL,
        Attributes         NVARCHAR(MAX) NULL,
        CreatedBy          NVARCHAR(100) NOT NULL,
        CreatedDate        DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy          NVARCHAR(100) NULL,
        UpdatedDate        DATETIME2 NULL,
        SourceAttributes   NVARCHAR(MAX) NULL,
        CONSTRAINT FK_FacilityWork_Facility
            FOREIGN KEY (FacilityId) REFERENCES dbo.Facility(FacilityId)
    );
END
GO

-- 1.5 BidPackageFacilityWork
IF OBJECT_ID('dbo.BidPackageFacilityWork', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.BidPackageFacilityWork...';
    CREATE TABLE dbo.BidPackageFacilityWork (
        BidPackageFacilityWorkId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        BidPackageId             INT NOT NULL,
        FacilityWorkId           INT NOT NULL,
        Attributes               NVARCHAR(MAX) NULL,
        CreatedBy                NVARCHAR(100) NOT NULL,
        CreatedDate              DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy                NVARCHAR(100) NULL,
        UpdatedDate              DATETIME2 NULL,
        ReferenceNo              NVARCHAR(50) NULL,
        CONSTRAINT FK_BPFW_BidPackage
            FOREIGN KEY (BidPackageId)   REFERENCES dbo.BidPackage(BidPackageId),
        CONSTRAINT FK_BPFW_FacilityWork
            FOREIGN KEY (FacilityWorkId) REFERENCES dbo.FacilityWork(FacilityWorkId)
    );
END
GO

-- 1.6 BidResponse
IF OBJECT_ID('dbo.BidResponse', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.BidResponse...';
    CREATE TABLE dbo.BidResponse (
        BidResponseId       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        BidPackageId        INT NOT NULL,
        BidResponseStatus   NVARCHAR(50) NOT NULL,
        BidResponseDate     DATETIME2    NOT NULL,
        Attributes          NVARCHAR(MAX) NULL,
        CreatedBy           NVARCHAR(100) NOT NULL,
        CreatedDate         DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy           NVARCHAR(100) NULL,
        UpdatedDate         DATETIME2 NULL,
        BidResponseAmount   DECIMAL(18,2) NOT NULL,
        UnInvoicedWorkTotal DECIMAL(18,2) NOT NULL,
        CONSTRAINT FK_BidResponse_BidPackage
            FOREIGN KEY (BidPackageId) REFERENCES dbo.BidPackage(BidPackageId)
    );
END
GO

-- 1.7 BidResponseFacilityWork
IF OBJECT_ID('dbo.BidResponseFacilityWork', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.BidResponseFacilityWork...';
    CREATE TABLE dbo.BidResponseFacilityWork (
        BidResponseFacilityWorkId      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        BidResponseId                  INT NOT NULL,
        BidPackageFacilityWorkId       INT NOT NULL,
        BidResponseFacilityWorkAmount  DECIMAL(18,2) NOT NULL,
        BidResponseFacilityWorkStatus  NVARCHAR(50) NOT NULL,
        BidResponseFacilityWorkDate    DATETIME2    NOT NULL,
        Attributes                     NVARCHAR(MAX) NULL,
        CreatedBy                      NVARCHAR(100) NOT NULL,
        CreatedDate                    DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy                      NVARCHAR(100) NULL,
        UpdatedDate                    DATETIME2 NULL,
        UnInvoicedWorkTotal            DECIMAL(18,2) NOT NULL,
        IsFullyInvoiced                BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_BRFW_BidResponse
            FOREIGN KEY (BidResponseId)            REFERENCES dbo.BidResponse(BidResponseId),
        CONSTRAINT FK_BRFW_BPFW
            FOREIGN KEY (BidPackageFacilityWorkId) REFERENCES dbo.BidPackageFacilityWork(BidPackageFacilityWorkId)
    );
END
GO

-- 1.8 Invoice
IF OBJECT_ID('dbo.Invoice', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.Invoice...';
    CREATE TABLE dbo.Invoice (
        InvoiceId      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        BidResponseId  INT NOT NULL,
        InvoiceAmount  DECIMAL(18,2) NOT NULL,
        InvoiceStatus  NVARCHAR(50) NOT NULL,
        InvoiceDate    DATETIME2    NOT NULL,
        Attributes     NVARCHAR(MAX) NULL,
        CreatedBy      NVARCHAR(100) NOT NULL,
        CreatedDate    DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy      NVARCHAR(100) NULL,
        UpdatedDate    DATETIME2 NULL,
        CONSTRAINT FK_Invoice_BidResponse
            FOREIGN KEY (BidResponseId) REFERENCES dbo.BidResponse(BidResponseId)
    );
END
GO

-- 1.9 InvoiceFacilityWork
IF OBJECT_ID('dbo.InvoiceFacilityWork', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.InvoiceFacilityWork...';
    CREATE TABLE dbo.InvoiceFacilityWork (
        InvoiceFacilityWorkId      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        InvoiceId                  INT NOT NULL,
        BidResponseFacilityWorkId  INT NOT NULL,
        InvoiceFacilityWorkStatus  NVARCHAR(50) NOT NULL,
        InvoiceFacilityWorkDate    DATETIME2    NOT NULL,
        Attributes                 NVARCHAR(MAX) NULL,
        CreatedBy                  NVARCHAR(100) NOT NULL,
        CreatedDate                DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy                  NVARCHAR(100) NULL,
        UpdatedDate                DATETIME2 NULL,
        DebitAmount                DECIMAL(18,2) NOT NULL DEFAULT 0,
        CreditAmount               DECIMAL(18,2) NOT NULL DEFAULT 0,
        InvoiceFacilityWorkAmount  DECIMAL(18,2) NOT NULL,
        InvoiceFacilityWorkType    NVARCHAR(50) NULL,
        CONSTRAINT FK_IFW_Invoice
            FOREIGN KEY (InvoiceId) REFERENCES dbo.Invoice(InvoiceId),
        CONSTRAINT FK_IFW_BRFW
            FOREIGN KEY (BidResponseFacilityWorkId) REFERENCES dbo.BidResponseFacilityWork(BidResponseFacilityWorkId)
    );
END
GO

-- 1.10 LandownerFacilityLink
IF OBJECT_ID('dbo.LandownerFacilityLink', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.LandownerFacilityLink...';
    CREATE TABLE dbo.LandownerFacilityLink (
        LandownerFacilityLinkId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LandownerId             INT NOT NULL,
        FacilityId              INT NOT NULL,
        Attributes              NVARCHAR(MAX) NULL,
        CreatedBy               NVARCHAR(100) NOT NULL,
        CreatedDate             DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy               NVARCHAR(100) NULL,
        UpdatedDate             DATETIME2 NULL,
        CONSTRAINT FK_LFL_Landowner
            FOREIGN KEY (LandownerId) REFERENCES dbo.Landowner(LandownerId),
        CONSTRAINT FK_LFL_Facility
            FOREIGN KEY (FacilityId)  REFERENCES dbo.Facility(FacilityId)
    );
END
GO

-- 1.11 LandownerBidResponseLink
IF OBJECT_ID('dbo.LandownerBidResponseLink', 'U') IS NULL
BEGIN
    PRINT 'Creating table dbo.LandownerBidResponseLink...';
    CREATE TABLE dbo.LandownerBidResponseLink (
        LandownerBidResponseLinkId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        LandownerId                INT NOT NULL,
        BidResponseId              INT NOT NULL,
        Attributes                 NVARCHAR(MAX) NULL,
        CreatedBy                  NVARCHAR(100) NOT NULL,
        CreatedDate                DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedBy                  NVARCHAR(100) NULL,
        UpdatedDate                DATETIME2 NULL,
        CONSTRAINT FK_LBRL_Landowner
            FOREIGN KEY (LandownerId)   REFERENCES dbo.Landowner(LandownerId),
        CONSTRAINT FK_LBRL_BidResponse
            FOREIGN KEY (BidResponseId) REFERENCES dbo.BidResponse(BidResponseId)
    );
END
GO

------------------------------------------------------------
-- 2. Bulk inserts RANDOM (>= 20 records per table)
--    Each block only runs if the table is empty.
------------------------------------------------------------

------------------------------------------------------------
-- 2.1 Facility
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Facility)
BEGIN
    PRINT 'Inserting records into dbo.Facility...';
    INSERT INTO dbo.Facility
        (SourceId, SourceKeyValue, FacilityType, SourceAttributes, Attributes, CreatedBy)
    SELECT TOP (20)
        ABS(CHECKSUM(NEWID())) % 1000 + 1 AS SourceId,
        CONCAT(N'FAC-', RIGHT(ABS(CHECKSUM(NEWID())), 6)) AS SourceKeyValue,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'PLANT' ELSE N'WAREHOUSE' END AS FacilityType,
        CONCAT(N'{"capacity":', ABS(CHECKSUM(NEWID())) % 500 + 50, N'}') AS SourceAttributes,
        CONCAT(N'{"region":"R', ABS(CHECKSUM(NEWID())) % 99, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.Facility já possui registros. Nada a fazer.';
END
GO

------------------------------------------------------------
-- 2.2 Landowner
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Landowner)
BEGIN
    PRINT 'Inserting records into dbo.Landowner...';
    INSERT INTO dbo.Landowner
        (LandownerName, Attributes, CreatedBy, CoNo, LandownerType, LandownerStatus)
    SELECT TOP (20)
        CONCAT(N'Landowner ', ABS(CHECKSUM(NEWID())) % 9999) AS LandownerName,
        CONCAT(N'{"segment":"SEG', ABS(CHECKSUM(NEWID())) % 100, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CONCAT(N'CO', RIGHT(ABS(CHECKSUM(NEWID())), 4)) AS CoNo,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'COMPANY' ELSE N'PERSON' END AS LandownerType,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN N'INACTIVE' ELSE N'ACTIVE' END AS LandownerStatus
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.Landowner already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.3 BidPackage
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BidPackage)
BEGIN
    PRINT 'Inserting records into dbo.BidPackage...';

    INSERT INTO dbo.BidPackage
        (BidPackageName, BidPackageStatus, Attributes, CreatedBy)
    SELECT TOP (20)
        CONCAT(N'Bid Package ', ABS(CHECKSUM(NEWID())) % 9999) AS BidPackageName,
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN N'OPEN'
            WHEN 1 THEN N'AWARDED'
            ELSE N'CLOSED'
        END AS BidPackageStatus,
        CONCAT(N'{"category":"CAT', ABS(CHECKSUM(NEWID())) % 50, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.BidPackage already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.4 FacilityWork (depends on Facility)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.FacilityWork)
BEGIN
    PRINT 'Inserting records into dbo.FacilityWork...';
    INSERT INTO dbo.FacilityWork
        (FacilityId, FacilityWorkType, Attributes, CreatedBy, SourceAttributes)
    SELECT TOP (20)
        F.FacilityId,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'MAINTENANCE' ELSE N'CONSTRUCTION' END AS FacilityWorkType,
        CONCAT(N'{"workCode":"FW', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CONCAT(N'{"priority":', ABS(CHECKSUM(NEWID())) % 5 + 1, N'}') AS SourceAttributes
    FROM dbo.Facility F
    CROSS JOIN sys.all_objects s
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.FacilityWork already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.5 BidPackageFacilityWork (depends on BidPackage and FacilityWork)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BidPackageFacilityWork)
BEGIN
    PRINT 'Inserting records into dbo.BidPackageFacilityWork...';
    INSERT INTO dbo.BidPackageFacilityWork
        (BidPackageId, FacilityWorkId, Attributes, CreatedBy, ReferenceNo)
    SELECT TOP (20)
        BP.BidPackageId,
        FW.FacilityWorkId,
        CONCAT(N'{"bpfwIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CONCAT(N'REF-', RIGHT(ABS(CHECKSUM(NEWID())), 5)) AS ReferenceNo
    FROM dbo.BidPackage BP
    CROSS JOIN dbo.FacilityWork FW
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.BidPackageFacilityWork already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.6 BidResponse (depends on BidPackage)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BidResponse)
BEGIN
    PRINT 'Inserting records into dbo.BidResponse...';
    INSERT INTO dbo.BidResponse
        (BidPackageId, BidResponseStatus, BidResponseDate,
         Attributes, CreatedBy, BidResponseAmount, UnInvoicedWorkTotal)
    SELECT TOP (20)
        BP.BidPackageId,
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN N'PENDING'
            WHEN 1 THEN N'ACCEPTED'
            ELSE N'REJECTED'
        END AS BidResponseStatus,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 90, SYSUTCDATETIME()) AS BidResponseDate,
        CONCAT(N'{"bidder":"BID', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CAST(1000 + (ABS(CHECKSUM(NEWID())) % 5000) AS DECIMAL(18,2)) AS BidResponseAmount,
        CAST(200 + (ABS(CHECKSUM(NEWID())) % 2000) AS DECIMAL(18,2)) AS UnInvoicedWorkTotal
    FROM dbo.BidPackage BP
    CROSS JOIN sys.all_objects s
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.BidResponse already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.7 BidResponseFacilityWork (depends on BidResponse and BidPackageFacilityWork)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BidResponseFacilityWork)
BEGIN
    PRINT 'Inserting records into dbo.BidResponseFacilityWork...';
    INSERT INTO dbo.BidResponseFacilityWork
        (BidResponseId, BidPackageFacilityWorkId,
         BidResponseFacilityWorkAmount, BidResponseFacilityWorkStatus,
         BidResponseFacilityWorkDate, Attributes, CreatedBy,
         UnInvoicedWorkTotal, IsFullyInvoiced)
    SELECT TOP (20)
        BR.BidResponseId,
        BPFW.BidPackageFacilityWorkId,
        CAST(500 + (ABS(CHECKSUM(NEWID())) % 3000) AS DECIMAL(18,2)) AS BidResponseFacilityWorkAmount,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'NEW' ELSE N'IN_PROGRESS' END AS BidResponseFacilityWorkStatus,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 60, SYSUTCDATETIME()) AS BidResponseFacilityWorkDate,
        CONCAT(N'{"brfwIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CAST(100 + (ABS(CHECKSUM(NEWID())) % 1500) AS DECIMAL(18,2)) AS UnInvoicedWorkTotal,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 1 ELSE 0 END AS IsFullyInvoiced
    FROM dbo.BidResponse BR
    CROSS JOIN dbo.BidPackageFacilityWork BPFW
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.BidResponseFacilityWork already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.8 Invoice (depends on BidResponse)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Invoice)
BEGIN
    PRINT 'Inserting records into dbo.Invoice...';
    INSERT INTO dbo.Invoice
        (BidResponseId, InvoiceAmount, InvoiceStatus, InvoiceDate,
         Attributes, CreatedBy)
    SELECT TOP (20)
        BR.BidResponseId,
        CAST(700 + (ABS(CHECKSUM(NEWID())) % 4000) AS DECIMAL(18,2)) AS InvoiceAmount,
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN N'PENDING'
            WHEN 1 THEN N'PAID'
            ELSE N'PARTIAL'
        END AS InvoiceStatus,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 45, SYSUTCDATETIME()) AS InvoiceDate,
        CONCAT(N'{"invoiceIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy
    FROM dbo.BidResponse BR
    CROSS JOIN sys.all_objects s
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.Invoice already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.9 InvoiceFacilityWork (depends on Invoice and BidResponseFacilityWork)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.InvoiceFacilityWork)
BEGIN
    PRINT 'Inserting records into dbo.InvoiceFacilityWork...';
    INSERT INTO dbo.InvoiceFacilityWork
        (InvoiceId, BidResponseFacilityWorkId,
         InvoiceFacilityWorkStatus, InvoiceFacilityWorkDate,
         Attributes, CreatedBy,
         DebitAmount, CreditAmount, InvoiceFacilityWorkAmount,
         InvoiceFacilityWorkType)
    SELECT TOP (20)
        I.InvoiceId,
        BRFW.BidResponseFacilityWorkId,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'DEBIT' ELSE N'CREDIT' END AS InvoiceFacilityWorkStatus,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, SYSUTCDATETIME()) AS InvoiceFacilityWorkDate,
        CONCAT(N'{"ifwIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0
             THEN CAST(100 + (ABS(CHECKSUM(NEWID())) % 1000) AS DECIMAL(18,2))
             ELSE 0 END AS DebitAmount,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 1
             THEN CAST(80 + (ABS(CHECKSUM(NEWID())) % 800) AS DECIMAL(18,2))
             ELSE 0 END AS CreditAmount,
        CAST(300 + (ABS(CHECKSUM(NEWID())) % 2000) AS DECIMAL(18,2)) AS InvoiceFacilityWorkAmount,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN N'LABOR' ELSE N'MATERIAL' END AS InvoiceFacilityWorkType
    FROM dbo.Invoice I
    CROSS JOIN dbo.BidResponseFacilityWork BRFW
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.InvoiceFacilityWork already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.10 LandownerFacilityLink (depends on Landowner and Facility)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.LandownerFacilityLink)
BEGIN
    PRINT 'Inserting records into dbo.LandownerFacilityLink...';
    INSERT INTO dbo.LandownerFacilityLink
        (LandownerId, FacilityId, Attributes, CreatedBy)
    SELECT TOP (20)
        L.LandownerId,
        F.FacilityId,
        CONCAT(N'{"lflIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy
    FROM dbo.Landowner L
    CROSS JOIN dbo.Facility F
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.LandownerFacilityLink already has records. Nothing to do.';
END
GO

------------------------------------------------------------
-- 2.11 LandownerBidResponseLink (depends on Landowner and BidResponse)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.LandownerBidResponseLink)
BEGIN
    PRINT 'Inserting records into dbo.LandownerBidResponseLink...';
    INSERT INTO dbo.LandownerBidResponseLink
        (LandownerId, BidResponseId, Attributes, CreatedBy)
    SELECT TOP (20)
        L.LandownerId,
        BR.BidResponseId,
        CONCAT(N'{"lbrlIndex":', ABS(CHECKSUM(NEWID())) % 9999, N'"}') AS Attributes,
        N'seed-bulk' AS CreatedBy
    FROM dbo.Landowner L
    CROSS JOIN dbo.BidResponse BR
    ORDER BY NEWID();
END
ELSE
BEGIN
    PRINT 'dbo.LandownerBidResponseLink already has records. Nothing to do.';
END
GO