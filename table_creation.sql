CREATE DATABASE NOVA;
USE NOVA;
-- PATIENT
CREATE TABLE Patient (
    Aadhar_ID VARCHAR2(12) PRIMARY KEY,
    Name VARCHAR2(100),
    Age NUMBER(3),
    Address VARCHAR2(255),
    Primary_Physician VARCHAR2(10)  -- FK to Doctor
);

-- DOCTOR
CREATE TABLE Doctor (
    Doctor_ID VARCHAR2(10) PRIMARY KEY,
    Name VARCHAR2(100),
    Specialization VARCHAR2(100),
    Years_Of_Exp NUMBER(3)
);

-- Update Foreign Key after Doctor table is created
ALTER TABLE Patient
ADD CONSTRAINT fk_patient_physician
FOREIGN KEY (Primary_Physician) REFERENCES Doctor(Doctor_ID);

-- PRESCRIPTION
CREATE TABLE Prescription (
    Prescription_ID VARCHAR2(10) PRIMARY KEY,
    Patient_ID VARCHAR2(12),
    Doctor_ID VARCHAR2(10),
    Date DATE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Aadhar_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);

-- DRUG
CREATE TABLE Drug (
    Trade_Name VARCHAR2(100),
    Company_Name VARCHAR2(100),
    Formula VARCHAR2(255),
    PRIMARY KEY (Trade_Name, Company_Name)
);

-- PRESCRIPTION_DRUG (Mapping Table)
CREATE TABLE Prescription_Drug (
    Prescription_ID VARCHAR2(10),
    Trade_Name VARCHAR2(100),
    Company_Name VARCHAR2(100),
    Qty NUMBER(5),
    PRIMARY KEY (Prescription_ID, Trade_Name, Company_Name),
    FOREIGN KEY (Prescription_ID) REFERENCES Prescription(Prescription_ID),
    FOREIGN KEY (Trade_Name, Company_Name) REFERENCES Drug(Trade_Name, Company_Name)
);

-- PHARMACY
CREATE TABLE Pharmacy (
    Pharmacy_Name VARCHAR2(100),
    Address VARCHAR2(255),
    Phone VARCHAR2(15),
    PRIMARY KEY (Pharmacy_Name, Address)
);

-- PHARMACY_DETAILS (Drug availability at pharmacy)
CREATE TABLE Pharmacy_Details (
    Trade_Name VARCHAR2(100),
    Company_Name VARCHAR2(100),
    Pharmacy_Name VARCHAR2(100),
    Address VARCHAR2(255),
    Price NUMBER(10,2),
    PRIMARY KEY (Trade_Name, Company_Name, Pharmacy_Name, Address),
    FOREIGN KEY (Trade_Name, Company_Name) REFERENCES Drug(Trade_Name, Company_Name),
    FOREIGN KEY (Pharmacy_Name, Address) REFERENCES Pharmacy(Pharmacy_Name, Address)
);

-- PHARMA_COMPANY
CREATE TABLE Pharma_Company (
    Company_Name VARCHAR2(100) PRIMARY KEY,
    Phone VARCHAR2(15)
);

-- CONTRACT
CREATE TABLE Contract (
    Contract_ID VARCHAR2(10) PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE,
    Content VARCHAR2(255),
    Supervisor VARCHAR2(100),
    Pharmacy_Name VARCHAR2(100),
    Company_Name VARCHAR2(100),
    FOREIGN KEY (Pharmacy_Name) REFERENCES Pharmacy(Pharmacy_Name),
    FOREIGN KEY (Company_Name) REFERENCES Pharma_Company(Company_Name)
);

-- SALES
CREATE TABLE Sales (
    Trade_Name VARCHAR2(100),
    Company_Name VARCHAR2(100),
    Pharmacy_Name VARCHAR2(100),
    Price NUMBER(10,2),
    PRIMARY KEY (Trade_Name, Company_Name, Pharmacy_Name),
    FOREIGN KEY (Trade_Name, Company_Name) REFERENCES Drug(Trade_Name, Company_Name),
    FOREIGN KEY (Pharmacy_Name) REFERENCES Pharmacy(Pharmacy_Name)
);