/*
Cleaning Data in SQL Queries

Used Skills: Self Join, Alter Data, Case, Window Function, CTE, Delete, Substring
*/

SELECT *
FROM NashvilleHousing


--Standardize Date Format
--remove the 00:00 timestamp

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT *
FROM NashvilleHousing


--Populate Property Address Data
--Use Join to populate the NULL Addresses based on same ParcelID

UPDATE a
SET PropertyAddress = 
	CASE
		WHEN a.PropertyAddress IS NULL THEN b.PropertyAddress
		ELSE a.PropertyAddress
		END
	FROM NashvilleHousing AS a
	JOIN NashvilleHousing AS b
		ON a.ParcelID = b.ParcelID
		AND NOT a.UniqueID = b.uniqueID


--Breaking Out Address into Individual Columns (Address, City, State)
--Use Substring to split the text based on the comma separator

SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS StreetAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
Add StreetAddress NVARCHAR(255);

Update NashvilleHousing
Set StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add City NVARCHAR(255);

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))


--Change Y and N to Yes and No in Sold as Vacant Field
--Inconsistency in original data, sometimes Y/N sometimes Yes/No

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
		WHEN SoldAsVacant LIKE 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
	FROM NashvilleHousing


--Remove Duplicates
--use Rank to find all duplicate rows
--only keep rows with rank 1

WITH rankTable AS (
SELECT *,
	RANK() OVER(
	PARTITION BY ParcelID,
				StreetAddress,
				City,
				LegalReference,
				SalePrice,
				SaleDate
	ORDER BY UniqueID
	) as rank
FROM NashvilleHousing
)

DELETE
FROM rankTable
WHERE rank > 1

--Delete/Drop Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress