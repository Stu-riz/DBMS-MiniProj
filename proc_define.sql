CREATE OR REPLACE PROCEDURE AddPatient (
    p_AadharID VARCHAR2,
    p_Name VARCHAR2,
    p_Address VARCHAR2,
    p_Age NUMBER,
    p_PrimaryPhysician VARCHAR2
) AS
BEGIN
    INSERT INTO Patient VALUES (p_AadharID, p_Name, p_Age, p_Address, p_PrimaryPhysician);
END;
/

-- Add a new doctor
CREATE OR REPLACE PROCEDURE AddDoctor (
    p_DoctorID VARCHAR2,
    p_Name VARCHAR2,
    p_Specialization VARCHAR2,
    p_YearsOfExp NUMBER
) AS
BEGIN
    INSERT INTO Doctor VALUES (p_DoctorID, p_Name, p_Specialization, p_YearsOfExp);
END;
/

-- Add a new pharmacy
CREATE OR REPLACE PROCEDURE AddPharmacy (
    p_Name VARCHAR2,
    p_Address VARCHAR2,
    p_Phone VARCHAR2
) AS
BEGIN
    INSERT INTO Pharmacy VALUES (p_Name, p_Address, p_Phone);
END;
/

-- Add a new pharma company
CREATE OR REPLACE PROCEDURE AddCompany (
    p_Name VARCHAR2,
    p_Phone VARCHAR2
) AS
BEGIN
    INSERT INTO Pharma_Company VALUES (p_Name, p_Phone);
END;
/

-- Add a new drug
CREATE OR REPLACE PROCEDURE AddDrug (
    p_TradeName VARCHAR2,
    p_CompanyName VARCHAR2,
    p_Formula VARCHAR2
) AS
BEGIN
    INSERT INTO Drug VALUES (p_TradeName, p_CompanyName, p_Formula);
END;
/

-- Add a new prescription
CREATE OR REPLACE PROCEDURE AddPrescription (
    p_PrescriptionID VARCHAR2,
    p_PatientID VARCHAR2,
    p_DoctorID VARCHAR2,
    p_Date DATE
) AS
BEGIN
    DELETE FROM Prescription
    WHERE Patient_ID = p_PatientID AND Doctor_ID = p_DoctorID;

    INSERT INTO Prescription VALUES (p_PrescriptionID, p_PatientID, p_DoctorID, p_Date);
END;
/

-- Add a drug to a prescription
CREATE OR REPLACE PROCEDURE AddPrescriptionDrug (
    p_PrescriptionID VARCHAR2,
    p_TradeName VARCHAR2,
    p_CompanyName VARCHAR2,
    p_Qty NUMBER
) AS
BEGIN
    INSERT INTO Prescription_Drug VALUES (p_PrescriptionID, p_TradeName, p_CompanyName, p_Qty);
END;
/

-- Add a contract
CREATE OR REPLACE PROCEDURE AddContract (
    p_ContractID VARCHAR2,
    p_PharmacyName VARCHAR2,
    p_CompanyName VARCHAR2,
    p_Supervisor VARCHAR2,
    p_Content VARCHAR2,
    p_StartDate DATE,
    p_EndDate DATE
) AS
BEGIN
    INSERT INTO Contract VALUES (
        p_ContractID, p_StartDate, p_EndDate, p_Content,
        p_Supervisor, p_PharmacyName, p_CompanyName
    );
END;
/

-- 2. DELETE PROCEDURES

CREATE OR REPLACE PROCEDURE DeletePatient(p_AadharID VARCHAR2) AS
BEGIN
    DELETE FROM Patient WHERE Aadhar_ID = p_AadharID;
END;
/

CREATE OR REPLACE PROCEDURE DeleteDoctor(p_DoctorID VARCHAR2) AS
BEGIN
    DELETE FROM Doctor WHERE Doctor_ID = p_DoctorID;
END;
/

CREATE OR REPLACE PROCEDURE DeletePharmacy(p_PharmacyName VARCHAR2, p_Address VARCHAR2) AS
BEGIN
    DELETE FROM Pharmacy WHERE Pharmacy_Name = p_PharmacyName AND Address = p_Address;
END;
/

CREATE OR REPLACE PROCEDURE DeletePharmaCompany(p_CompanyName VARCHAR2) AS
BEGIN
    DELETE FROM Pharma_Company WHERE Company_Name = p_CompanyName;
END;
/

CREATE OR REPLACE PROCEDURE DeleteDrug(
    p_TradeName VARCHAR2,
    p_CompanyName VARCHAR2
) AS
BEGIN
    DELETE FROM Drug WHERE Trade_Name = p_TradeName AND Company_Name = p_CompanyName;
END;
/

CREATE OR REPLACE PROCEDURE DeletePrescription(p_PrescriptionID VARCHAR2) AS
BEGIN
    DELETE FROM Prescription WHERE Prescription_ID = p_PrescriptionID;
END;
/

CREATE OR REPLACE PROCEDURE DeleteContract(p_ContractID VARCHAR2) AS
BEGIN
    DELETE FROM Contract WHERE Contract_ID = p_ContractID;
END;
/

CREATE OR REPLACE PROCEDURE DeleteSales(
    p_TradeName     VARCHAR2,
    p_CompanyName   VARCHAR2,
    p_PharmacyName  VARCHAR2
) AS
BEGIN
    DELETE FROM Sales
    WHERE Trade_Name = p_TradeName
      AND Company_Name = p_CompanyName
      AND Pharmacy_Name = p_PharmacyName;
END;
/

-- 3. UPDATE PROCEDURE

CREATE OR REPLACE PROCEDURE UpdateDrugPrice (
    p_TradeName VARCHAR2,
    p_CompanyName VARCHAR2,
    p_PharmacyName VARCHAR2,
    p_NewPrice NUMBER
) AS
BEGIN
    UPDATE Sales
    SET Price = p_NewPrice
    WHERE Trade_Name = p_TradeName AND Company_Name = p_CompanyName AND Pharmacy_Name = p_PharmacyName;
END;
/

-- 4. REPORTING PROCEDURES

-- Patient Prescriptions in a date range
CREATE OR REPLACE PROCEDURE ReportPatientPrescriptions (
    p_PatientID VARCHAR2,
    p_StartDate DATE,
    p_EndDate DATE
) AS
BEGIN
    FOR rec IN (
        SELECT * FROM Prescription
        WHERE Patient_ID = p_PatientID AND Date BETWEEN p_StartDate AND p_EndDate
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Prescription ID: ' || rec.Prescription_ID || ' Date: ' || rec.Date);
    END LOOP;
END;
/

-- Prescription details for given patient and date
CREATE OR REPLACE PROCEDURE GetPrescriptionDetails (
    p_PatientID VARCHAR2,
    p_Date DATE
) AS
BEGIN
    FOR rec IN (
        SELECT d.Trade_Name, d.Company_Name, pd.Qty
        FROM Prescription p
        JOIN Prescription_Drug pd ON p.Prescription_ID = pd.Prescription_ID
        JOIN Drug d ON pd.Trade_Name = d.Trade_Name AND pd.Company_Name = d.Company_Name
        WHERE p.Patient_ID = p_PatientID AND p.Date = p_Date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.Trade_Name || ' Company: ' || rec.Company_Name || ' Qty: ' || rec.Qty);
    END LOOP;
END;
/

-- Drugs by company
CREATE OR REPLACE PROCEDURE DrugsByCompany(p_CompanyName VARCHAR2) AS
BEGIN
    FOR rec IN (SELECT Trade_Name, Formula FROM Drug WHERE Company_Name = p_CompanyName) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.Trade_Name || ', Formula: ' || rec.Formula);
    END LOOP;
END;
/

-- Stock position of a pharmacy
CREATE OR REPLACE PROCEDURE StockPosition(p_PharmacyName VARCHAR2) AS
BEGIN
    FOR rec IN (
        SELECT Trade_Name, Company_Name, Price
        FROM Sales
        WHERE Pharmacy_Name = p_PharmacyName
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.Trade_Name || ' | Company: ' || rec.Company_Name || ' | Price: ' || rec.Price);
    END LOOP;
END;
/

-- Contact details between pharmacy and pharma company
CREATE OR REPLACE PROCEDURE PharmacyCompanyContacts AS
BEGIN
    FOR rec IN (
        SELECT DISTINCT c.Pharmacy_Name, c.Company_Name, p.Phone AS PharmacyPhone, ph.Phone AS CompanyPhone
        FROM Contract c
        JOIN Pharmacy p ON c.Pharmacy_Name = p.Pharmacy_Name
        JOIN Pharma_Company ph ON c.Company_Name = ph.Company_Name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Pharmacy: ' || rec.Pharmacy_Name || ' (' || rec.PharmacyPhone || ') | Company: ' || rec.Company_Name || ' (' || rec.CompanyPhone || ')');
    END LOOP;
END;
/

-- Patients of a doctor using Primary_Physician
CREATE OR REPLACE PROCEDURE PatientsOfDoctor(p_DoctorID VARCHAR2) AS
BEGIN
    FOR rec IN (
        SELECT Name, Aadhar_ID
        FROM Patient
        WHERE Primary_Physician = p_DoctorID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Patient: ' || rec.Name || ' | Aadhar_ID: ' || rec.Aadhar_ID);
    END LOOP;
END;
/