CREATE DATABASE hospital_revenue_db;
USE hospital_revenue_db;

CREATE TABLE billing (
    bill_id INT PRIMARY KEY,
    bill_date DATE,
    total_amount DECIMAL(10,2),
    insurance_covered_amount DECIMAL(10,2),
    patient_payable_amount DECIMAL(10,2),
    payment_status VARCHAR(50),
    payment_mode VARCHAR(50),
    admission_id INT
);

CREATE TABLE billing_detail (
    billing_detail_id INT PRIMARY KEY,
    charge_type VARCHAR(50),
    reference_id INT,
    amount DECIMAL(10,2),
    bill_id INT,
    CONSTRAINT fk_bill
        FOREIGN KEY (bill_id) REFERENCES billing(bill_id)
);

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_type VARCHAR(50),
    floor_number INT,
    status VARCHAR(20)
);
ALTER TABLE department
ADD CONSTRAINT chk_department_status
CHECK (status IN ('ACTIVE', 'INACTIVE'));

CREATE TABLE patient_insurance (
    patient_insurance_id INT PRIMARY KEY,
    policy_number VARCHAR(100) NOT NULL,
    coverage_percentage DECIMAL(5,2),
    policy_start_date DATE,
    policy_end_date DATE,
    patient_id INT,
    insurance_provider_id INT
);
ALTER TABLE patient_insurance
ADD CONSTRAINT chk_coverage_percentage
CHECK (coverage_percentage BETWEEN 0 AND 100);
ALTER TABLE patient_insurance
ADD CONSTRAINT chk_policy_dates
CHECK (policy_end_date >= policy_start_date);



CREATE TABLE admission (
    admission_id INT PRIMARY KEY,
    admission_date DATE,
    discharge_date DATE,
    admission_type VARCHAR(50),
    admission_status VARCHAR(50),
    patient_id INT,
    department_id INT,
    ward_id INT,
    bed_id INT,
    disease_id INT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/billing.csv'
INTO TABLE billing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(bill_id, bill_date, total_amount, insurance_covered_amount, patient_payable_amount, payment_status, payment_mode, admission_id);

SELECT * FROM billing LIMIT 100;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/billing_detail.csv'
INTO TABLE billing_detail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(billing_detail_id, charge_type, @reference_id, amount, bill_id)
SET reference_id = IF(@reference_id = '', 0, @reference_id);

SELECT * FROM billing_detail LIMIT 100;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/department.csv'
INTO TABLE department
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(department_id, department_name, department_type, floor_number, status);

SELECT * FROM department LIMIT 100;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patient_insurance.csv'
INTO TABLE patient_insurance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(patient_insurance_id, policy_number, coverage_percentage, policy_start_date, policy_end_date, patient_id, insurance_provider_id);

SELECT * FROM patient_insurance LIMIT 100;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/admission.csv'
INTO TABLE admission
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(admission_id, admission_date, discharge_date, admission_type, admission_status, patient_id, department_id, ward_id, bed_id, disease_id);

SELECT * FROM admission LIMIT 100;



ALTER TABLE billing_detail
ADD FOREIGN KEY (bill_id) REFERENCES billing(bill_id);

ALTER TABLE admissions
ADD FOREIGN KEY (patient_id) REFERENCES billing(patient_id);

ALTER TABLE admissions
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);



SELECT 
    b.bill_id,
    b.bill_date,
    d.department_name,
    SUM(bd.amount) AS total_revenue,
    b.payment_status,
    b.payment_mode,

    CASE 
        WHEN b.insurance_covered_amount > 0 THEN 'Insurance'
        ELSE 'Self Pay'
    END AS payment_type

FROM billing b

JOIN billing_detail bd 
    ON b.bill_id = bd.bill_id

JOIN admission a 
    ON b.admission_id = a.admission_id

JOIN department d 
    ON a.department_id = d.department_id

GROUP BY 
    b.bill_id,
    b.bill_date,
    d.department_name,
    b.payment_status,
    b.payment_mode,
    b.insurance_covered_amount;
    
    
    
    CREATE VIEW revenue_analysis AS
SELECT 
    b.bill_id,
    b.bill_date,
    d.department_name,
    SUM(bd.amount) AS total_revenue,
    b.payment_status,
    b.payment_mode,

    CASE 
        WHEN b.insurance_covered_amount > 0 THEN 'Insurance'
        ELSE 'Self Pay'
    END AS payment_type

FROM billing b
JOIN billing_detail bd ON b.bill_id = bd.bill_id
JOIN admission a ON b.admission_id = a.admission_id
JOIN department d ON a.department_id = d.department_id
GROUP BY 
    b.bill_id,
    b.bill_date,
    d.department_name,
    b.payment_status,
    b.payment_mode,
    b.insurance_covered_amount;
   