/* ============================================================
   智慧康养平台 · 练习数据库 SmartCare
   用途：配合《商务软件解决方案零基础备赛教程》第 05–08 章练习。
   这是自拟的练习数据，不是任何比赛的官方素材。
   使用：在 SSMS 中打开本文件，按 F5 执行。会删除并重建 SmartCare 库。
   ============================================================ */
USE master;
GO
IF DB_ID(N'SmartCare') IS NOT NULL
BEGIN
    ALTER DATABASE SmartCare SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SmartCare;
END
GO
CREATE DATABASE SmartCare;
GO
USE SmartCare;
GO

/* ---------- 1. 管理者（桌面端登录） ---------- */
CREATE TABLE Manager (
    ManagerId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Manager PRIMARY KEY,
    UserName    NVARCHAR(50)  NOT NULL CONSTRAINT UQ_Manager_UserName UNIQUE,
    Password    NVARCHAR(64)  NOT NULL,          -- 练习库为便于核对使用明文；真实项目应存哈希
    Phone       CHAR(11)      NOT NULL,
    CreatedAt   DATETIME      NOT NULL CONSTRAINT DF_Manager_CreatedAt DEFAULT (GETDATE())
);

/* ---------- 2. 客户（手机端用户） ---------- */
CREATE TABLE Customer (
    CustomerId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customer PRIMARY KEY,
    Phone       CHAR(11)      NOT NULL CONSTRAINT UQ_Customer_Phone UNIQUE,
    Password    NVARCHAR(64)  NOT NULL,
    RealName    NVARCHAR(20)  NULL,
    Gender      NCHAR(1)      NULL CONSTRAINT CK_Customer_Gender CHECK (Gender IN (N'男', N'女')),
    BirthDate   DATE          NULL,
    Address     NVARCHAR(100) NULL,
    Avatar      NVARCHAR(100) NULL,              -- 图片文件名；为空时界面显示 default.jpg
    Status      TINYINT       NOT NULL CONSTRAINT DF_Customer_Status DEFAULT (1),  -- 1 正常 0 禁用
    CreatedAt   DATETIME      NOT NULL CONSTRAINT DF_Customer_CreatedAt DEFAULT (GETDATE())
);

/* ---------- 3. 服务分类 ---------- */
CREATE TABLE ServiceCategory (
    CategoryId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ServiceCategory PRIMARY KEY,
    CategoryName NVARCHAR(20) NOT NULL CONSTRAINT UQ_ServiceCategory_Name UNIQUE
);

/* ---------- 4. 康养服务 ---------- */
CREATE TABLE CareService (
    ServiceId       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CareService PRIMARY KEY,
    CategoryId      INT NOT NULL CONSTRAINT FK_CareService_Category REFERENCES ServiceCategory(CategoryId),
    ServiceName     NVARCHAR(50)  NOT NULL,
    Price           DECIMAL(10,2) NOT NULL CONSTRAINT CK_CareService_Price CHECK (Price >= 0),
    DurationMinutes INT           NOT NULL CONSTRAINT CK_CareService_Duration CHECK (DurationMinutes > 0),
    Description     NVARCHAR(500) NULL,
    ImageName       NVARCHAR(100) NULL,
    IsOnSale        BIT           NOT NULL CONSTRAINT DF_CareService_IsOnSale DEFAULT (1)
);

/* ---------- 5. 服务订单 ---------- */
CREATE TABLE ServiceOrder (
    OrderId         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ServiceOrder PRIMARY KEY,
    OrderNo         VARCHAR(20)   NOT NULL CONSTRAINT UQ_ServiceOrder_OrderNo UNIQUE,
    CustomerId      INT NOT NULL CONSTRAINT FK_ServiceOrder_Customer REFERENCES Customer(CustomerId),
    ServiceId       INT NOT NULL CONSTRAINT FK_ServiceOrder_Service  REFERENCES CareService(ServiceId),
    Quantity        INT           NOT NULL CONSTRAINT CK_ServiceOrder_Qty CHECK (Quantity > 0),
    Amount          DECIMAL(10,2) NOT NULL,
    AppointmentTime DATETIME      NOT NULL,
    Status          TINYINT       NOT NULL CONSTRAINT DF_ServiceOrder_Status DEFAULT (0), -- 0 待支付 1 已支付 2 已完成 3 已取消
    CreatedAt       DATETIME      NOT NULL CONSTRAINT DF_ServiceOrder_CreatedAt DEFAULT (GETDATE())
);

/* ---------- 6. 投诉反馈 ---------- */
CREATE TABLE Complaint (
    ComplaintId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Complaint PRIMARY KEY,
    OrderId     INT NOT NULL CONSTRAINT FK_Complaint_Order REFERENCES ServiceOrder(OrderId),
    Content     NVARCHAR(500) NOT NULL,
    Reply       NVARCHAR(500) NULL,
    Status      TINYINT  NOT NULL CONSTRAINT DF_Complaint_Status DEFAULT (0),   -- 0 待处理 1 已回复
    CreatedAt   DATETIME NOT NULL CONSTRAINT DF_Complaint_CreatedAt DEFAULT (GETDATE()),
    RepliedAt   DATETIME NULL
);

/* ---------- 7. 健康数据 ---------- */
CREATE TABLE HealthRecord (
    RecordId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_HealthRecord PRIMARY KEY,
    CustomerId  INT NOT NULL CONSTRAINT FK_HealthRecord_Customer REFERENCES Customer(CustomerId),
    RecordType  NVARCHAR(10) NOT NULL CONSTRAINT CK_HealthRecord_Type CHECK (RecordType IN (N'血压', N'心率', N'血糖')),
    Value1      DECIMAL(6,1) NOT NULL,     -- 血压：收缩压；心率：次/分；血糖：mmol/L
    Value2      DECIMAL(6,1) NULL,         -- 血压：舒张压；其他类型为空
    MeasuredAt  DATETIME     NOT NULL
);

/* ---------- 8. 紧急联系人 ---------- */
CREATE TABLE EmergencyContact (
    ContactId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EmergencyContact PRIMARY KEY,
    CustomerId  INT NOT NULL CONSTRAINT FK_EmergencyContact_Customer REFERENCES Customer(CustomerId),
    ContactName NVARCHAR(20) NOT NULL,
    Phone       CHAR(11)     NOT NULL,
    Relation    NVARCHAR(10) NULL
);
GO

/* ================= 初始数据 ================= */
INSERT INTO Manager (UserName, Password, Phone, CreatedAt) VALUES
(N'admin', N'admin123', '13900000001', '2026-06-01T09:00:00'),
(N'zhangwei', N'zw202601', '13900000002', '2026-06-15T10:30:00'),
(N'liuna', N'ln888888a', '13900000003', '2026-07-02T14:20:00');

INSERT INTO Customer (Phone, Password, RealName, Gender, BirthDate, Address, Status, CreatedAt) VALUES
('13800000001', N'abc12345', N'王秀英', N'女', '1948-03-12', N'和平区南京街 12 号', 1, '2026-06-03T08:10:00'),
('13800000002', N'abc12345', N'李建国', N'男', '1951-07-25', N'沈河区青年大街 88 号', 1, '2026-06-05T09:20:00'),
('13800000003', N'abc12345', N'张桂兰', N'女', '1945-11-02', N'皇姑区北陵大街 3 号', 1, '2026-06-10T15:00:00'),
('13800000004', N'abc12345', N'刘志强', N'男', '1956-01-30', N'铁西区兴华街 20 号', 1, '2026-06-18T11:45:00'),
('13800000005', N'abc12345', N'陈淑珍', N'女', '1950-05-16', N'大东区东北大马路 6 号', 0, '2026-06-21T16:30:00'),
('13800000006', N'abc12345', N'杨德胜', N'男', '1943-09-09', N'浑南区创新路 101 号', 1, '2026-07-01T10:00:00'),
('13800000007', N'abc12345', N'赵玉梅', N'女', '1953-12-24', N'和平区三好街 7 号', 1, '2026-07-08T13:15:00'),
('13800000008', N'abc12345', N'黄国华', N'男', '1949-04-04', N'沈河区北站路 15 号', 1, '2026-07-19T09:05:00'),
('13800000009', N'abc12345', N'周凤琴', N'女', '1958-08-18', N'于洪区沈辽路 66 号', 1, '2026-08-02T14:40:00'),
('13800000010', N'abc12345', N'吴长海', N'男', '1947-02-11', N'皇姑区黄河大街 50 号', 1, '2026-08-11T08:30:00'),
('13800000011', N'abc12345', N'郑丽华', N'女', '1955-06-06', N'铁西区北二路 9 号', 1, '2026-08-27T17:20:00'),
('13800000012', N'abc12345', NULL, NULL, NULL, NULL, 1, '2026-09-03T12:00:00');

INSERT INTO ServiceCategory (CategoryName) VALUES
(N'生活照料'),
(N'医疗护理'),
(N'康复理疗'),
(N'精神慰藉');

INSERT INTO CareService (CategoryId, ServiceName, Price, DurationMinutes, Description, ImageName, IsOnSale) VALUES
(1, N'上门助浴', 120.00, 90, N'上门助浴服务，由持证人员上门提供。', N'bath.jpg', 1),
(1, N'助餐配送', 25.00, 30, N'助餐配送服务，由持证人员上门提供。', N'meal.jpg', 1),
(1, N'居家保洁', 80.00, 120, N'居家保洁服务，由持证人员上门提供。', NULL, 1),
(2, N'上门测血压血糖', 30.00, 20, N'上门测血压血糖服务，由持证人员上门提供。', N'bp.jpg', 1),
(2, N'陪同就医', 200.00, 240, N'陪同就医服务，由持证人员上门提供。', N'clinic.jpg', 1),
(2, N'伤口护理', 150.00, 60, N'伤口护理服务，由持证人员上门提供。', NULL, 1),
(3, N'康复理疗', 260.00, 60, N'康复理疗服务，由持证人员上门提供。', N'rehab.jpg', 1),
(3, N'中医推拿', 180.00, 45, N'中医推拿服务，由持证人员上门提供。', N'massage.jpg', 0),
(4, N'聊天陪伴', 60.00, 60, N'聊天陪伴服务，由持证人员上门提供。', N'chat.jpg', 1),
(4, N'代读书报', 40.00, 60, N'代读书报服务，由持证人员上门提供。', NULL, 1);

INSERT INTO ServiceOrder (OrderNo, CustomerId, ServiceId, Quantity, Amount, AppointmentTime, Status, CreatedAt) VALUES
('SO202607010001', 1, 1, 1, 120.00, '2026-07-03T09:00:00', 2, '2026-07-01T10:12:00'),
('SO202607020002', 1, 2, 10, 250.00, '2026-07-05T11:30:00', 2, '2026-07-02T08:30:00'),
('SO202607040003', 2, 5, 1, 200.00, '2026-07-08T08:00:00', 2, '2026-07-04T19:00:00'),
('SO202607060004', 3, 4, 2, 60.00, '2026-07-10T15:00:00', 2, '2026-07-06T09:45:00'),
('SO202607090005', 4, 7, 1, 260.00, '2026-07-15T14:00:00', 3, '2026-07-09T20:10:00'),
('SO202607120006', 6, 9, 2, 120.00, '2026-07-20T10:00:00', 2, '2026-07-12T11:00:00'),
('SO202607180007', 7, 3, 1, 80.00, '2026-07-22T09:00:00', 2, '2026-07-18T16:20:00'),
('SO202607280008', 2, 4, 1, 30.00, '2026-08-01T15:30:00', 2, '2026-07-28T10:00:00'),
('SO202607300009', 8, 1, 1, 120.00, '2026-08-03T09:30:00', 2, '2026-07-30T09:10:00'),
('SO202608010010', 1, 7, 2, 520.00, '2026-08-06T14:00:00', 2, '2026-08-01T15:00:00'),
('SO202608030011', 9, 2, 20, 500.00, '2026-08-10T11:30:00', 2, '2026-08-03T07:50:00'),
('SO202608050012', 3, 5, 1, 200.00, '2026-08-12T08:00:00', 3, '2026-08-05T13:30:00'),
('SO202608110013', 10, 6, 1, 150.00, '2026-08-15T10:00:00', 2, '2026-08-11T09:00:00'),
('SO202608140014', 6, 1, 1, 120.00, '2026-08-20T09:00:00', 2, '2026-08-14T18:40:00'),
('SO202608190015', 7, 9, 3, 180.00, '2026-08-25T15:00:00', 2, '2026-08-19T10:30:00'),
('SO202608280016', 11, 10, 2, 80.00, '2026-09-02T10:00:00', 2, '2026-08-28T14:00:00'),
('SO202609010017', 4, 4, 1, 30.00, '2026-09-05T15:00:00', 2, '2026-09-01T09:00:00'),
('SO202609030018', 2, 7, 1, 260.00, '2026-09-08T14:00:00', 2, '2026-09-03T11:20:00'),
('SO202609060019', 8, 5, 1, 200.00, '2026-09-12T08:00:00', 2, '2026-09-06T08:15:00'),
('SO202609100020', 1, 2, 10, 250.00, '2026-09-15T11:30:00', 2, '2026-09-10T10:40:00'),
('SO202609120021', 9, 3, 2, 160.00, '2026-09-18T09:00:00', 3, '2026-09-12T19:30:00'),
('SO202609160022', 10, 1, 1, 120.00, '2026-09-22T09:30:00', 2, '2026-09-16T16:00:00'),
('SO202609200023', 3, 9, 2, 120.00, '2026-09-28T10:00:00', 2, '2026-09-20T09:30:00'),
('SO202609270024', 6, 7, 2, 520.00, '2026-10-03T14:00:00', 2, '2026-09-27T15:10:00'),
('SO202610020025', 11, 4, 1, 30.00, '2026-10-08T15:00:00', 2, '2026-10-02T08:50:00'),
('SO202610060026', 7, 1, 1, 120.00, '2026-10-12T09:00:00', 1, '2026-10-06T12:00:00'),
('SO202610090027', 2, 2, 15, 375.00, '2026-10-15T11:30:00', 1, '2026-10-09T10:20:00'),
('SO202610140028', 12, 9, 1, 60.00, '2026-10-20T10:00:00', 0, '2026-10-14T21:00:00'),
('SO202610180029', 4, 5, 1, 200.00, '2026-10-25T08:00:00', 1, '2026-10-18T09:40:00'),
('SO202610210030', 1, 6, 1, 150.00, '2026-10-30T10:00:00', 0, '2026-10-21T17:30:00');

INSERT INTO Complaint (OrderId, Content, Reply, Status, CreatedAt, RepliedAt) VALUES
(3, N'陪诊人员迟到二十分钟。', N'已核实并向您致歉，已对服务人员进行培训。', 1, '2026-07-08T18:00:00', '2026-07-09T10:00:00'),
(9, N'助浴时水温偏低。', N'感谢反馈，已提醒服务人员提前调试水温。', 1, '2026-08-03T12:00:00', '2026-08-03T16:30:00'),
(11, N'有两天送餐时间晚于 12 点。', NULL, 0, '2026-08-12T13:00:00', NULL),
(15, N'陪伴人员很耐心，希望固定同一位。', N'已为您备注固定服务人员。', 1, '2026-08-25T18:20:00', '2026-08-26T09:00:00'),
(19, N'就医时排队较久，希望能提前挂号。', NULL, 0, '2026-09-12T17:00:00', NULL),
(24, N'理疗后有些酸痛，是否正常？', NULL, 0, '2026-10-03T19:00:00', NULL);

INSERT INTO HealthRecord (CustomerId, RecordType, Value1, Value2, MeasuredAt) VALUES
(1, N'血压', 138, 86, '2026-10-01T08:00:00'),
(1, N'血压', 142, 90, '2026-10-02T08:00:00'),
(1, N'血压', 135, 85, '2026-10-03T08:00:00'),
(1, N'血压', 145, 92, '2026-10-04T08:00:00'),
(1, N'血压', 130, 82, '2026-10-05T08:00:00'),
(1, N'血压', 128, 80, '2026-10-06T08:00:00'),
(1, N'血压', 133, 84, '2026-10-07T08:00:00'),
(1, N'心率', 72, NULL, '2026-10-01T08:05:00'),
(1, N'心率', 78, NULL, '2026-10-04T08:05:00'),
(1, N'心率', 70, NULL, '2026-10-07T08:05:00'),
(1, N'血糖', 6.1, NULL, '2026-10-01T07:30:00'),
(1, N'血糖', 7.4, NULL, '2026-10-04T07:30:00'),
(1, N'血糖', 6.6, NULL, '2026-10-07T07:30:00'),
(2, N'血压', 150, 95, '2026-10-02T09:00:00'),
(2, N'血压', 146, 92, '2026-10-05T09:00:00'),
(2, N'心率', 85, NULL, '2026-10-02T09:05:00'),
(3, N'血糖', 8.2, NULL, '2026-10-03T07:00:00'),
(3, N'血糖', 7.9, NULL, '2026-10-06T07:00:00'),
(6, N'血压', 122, 78, '2026-10-04T10:00:00'),
(6, N'心率', 66, NULL, '2026-10-04T10:05:00');

INSERT INTO EmergencyContact (CustomerId, ContactName, Phone, Relation) VALUES
(1, N'王小明', '13700000001', N'儿子'),
(1, N'王小红', '13700000002', N'女儿'),
(2, N'李娜', '13700000003', N'女儿'),
(3, N'张伟', '13700000004', N'儿子'),
(6, N'杨帆', '13700000005', N'孙子');
GO

/* 检查：各表行数 */
SELECT 'Manager' AS TableName, COUNT(*) AS Cnt FROM Manager
UNION ALL SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL SELECT 'ServiceCategory', COUNT(*) FROM ServiceCategory
UNION ALL SELECT 'CareService', COUNT(*) FROM CareService
UNION ALL SELECT 'ServiceOrder', COUNT(*) FROM ServiceOrder
UNION ALL SELECT 'Complaint', COUNT(*) FROM Complaint
UNION ALL SELECT 'HealthRecord', COUNT(*) FROM HealthRecord
UNION ALL SELECT 'EmergencyContact', COUNT(*) FROM EmergencyContact;
GO
