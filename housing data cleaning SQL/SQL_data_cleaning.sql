select * 
from NashvilleHousing


-- standarize Date Format

SELECT Saledate, CONVERT(date, saledate)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD saledateconverted date;

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------
-- Popluate Property Address data where null
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT A.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM NashvilleHousing as A
JOIN NashvilleHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a 
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM NashvilleHousing as A
JOIN NashvilleHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columsn( Address, city, state)

select propertyaddress
from NashvilleHousing

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as StreetAddress,
SUBSTRING(propertyaddress,CHARINDEX(',', propertyaddress)+1,LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',', propertyaddress)+1,LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

SELECT *
FROM NashvilleHousing

-----------------------------------------------------------------------------------
 --Change Y and N to Yes and No in 'Sold as Vacant" field

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
 FROM NashvilleHousing

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


 -------------------------------------------------
 -- Remove Duplicates
 WITH RowNumCTE AS(
 SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelId, 
				 propertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY
					UniqueID) row_num
 FROM NashvilleHousing
 )
 DELETE
 from RowNumCTE
 where row_num > 1
 --order by PropertyAddress



 --------------------------------------------------------------------------------------
-- Delete Unsued Columns
 SELECT *
 FROM NashvilleHousing

 ALTER TABLE NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate