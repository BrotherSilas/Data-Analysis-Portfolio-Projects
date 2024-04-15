-- DATA CLEANING QUERIES

-- CHECKING THE DATA SET
select *
from [Silas Edet portfolio project]..Nashvillehousing


-- MAKING THE DATE FORMAT STANDARD
select SaleDate, CONVERT(date, SaleDate)
from [Silas Edet portfolio project]..Nashvillehousing

-- this method may work, may not work
update [Silas Edet portfolio project]..Nashvillehousing
set SaleDate=CONVERT(date, SaleDate)

-- this method works
alter TABLE [Silas Edet portfolio project]..Nashvillehousing
add newSaleDate Date

update [Silas Edet portfolio project]..Nashvillehousing
set newSaleDate=CONVERT(date, SaleDate)

select newSaleDate
from [Silas Edet portfolio project]..Nashvillehousing



-- UPDATING NULL PROPERTY ADDRESS DATA

-- select all columns having null property addresses
select *
from [Silas Edet portfolio project]..Nashvillehousing
-- where property address is null
order by parcelid

--where propertyaddress is null in a, copy and paste property address from b
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from [Silas Edet portfolio project]..Nashvillehousing a
join [Silas Edet portfolio project]..Nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

-- Update a
set propertyaddress=ISNULL(a.propertyaddress, b.propertyaddress)
from [Silas Edet portfolio project]..Nashvillehousing a
join [Silas Edet portfolio project]..Nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null
-- you can also replace with a string, example in comment below
-- set propertyaddress=ISNULL(a.propertyaddress, "no address")

-- if you run this again, all the null rows have been updated
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from [Silas Edet portfolio project]..Nashvillehousing a
join [Silas Edet portfolio project]..Nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null


-- BREAKING ADRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)
select propertyaddress
from [Silas Edet portfolio project]..Nashvillehousing
-- where property address is null
-- order by parcelid

-- USING SUBSTRING OR CHARACTER INDEX
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1 ) as Address
-- From [Silas Edet portfolio project]..Nashvillehousing
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as city

From [Silas Edet portfolio project]..Nashvillehousing

-- you have to add new columns to contain the new seperations
ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update [Silas Edet portfolio project]..Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update [Silas Edet portfolio project]..Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- checking to see if the new columns are added
select *
from [Silas Edet portfolio project]..Nashvillehousing


-- using parse
Select OwnerAddress
From [Silas Edet portfolio project]..Nashvillehousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Silas Edet portfolio project]..Nashvillehousing


ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update [Silas Edet portfolio project]..Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update [Silas Edet portfolio project]..Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update [Silas Edet portfolio project]..Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From [Silas Edet portfolio project]..Nashvillehousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Silas Edet portfolio project]..Nashvillehousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Silas Edet portfolio project]..Nashvillehousing


Update [Silas Edet portfolio project]..Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Silas Edet portfolio project]..Nashvillehousing
-- order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress

-- to check if duplicate rows still remain
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Silas Edet portfolio project]..Nashvillehousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
-- confirmed, no duplicate rows remain

Select *
From [Silas Edet portfolio project]..Nashvillehousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Silas Edet portfolio project]..Nashvillehousing


ALTER TABLE [Silas Edet portfolio project]..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
















