--Cleaning Data in SQL

Select *
From Portfolio_Project1..Nashville

---Standardizing Data's Format----------------------- 
Select DateOfSale
From Portfolio_Project1..Nashville
Order by SaleDate ASC

Alter Table Nashville
Add DateOfSale Date;

Update Nashville
Set DateOfSale = CONVERT(Date, SaleDate)

---------Populate Property Address Date--------

Select *
From Portfolio_Project1..Nashville
Order by ParcelID

Select Ns.ParcelID, Ns.PropertyAddress, Nh.ParcelID, Nh.PropertyAddress,
ISNULL(Ns.PropertyAddress, Nh.PropertyAddress)
From Portfolio_Project1..Nashville Ns
Join Portfolio_Project1..Nashville Nh
	ON Ns.ParcelID = Nh.ParcelID 
	and Ns.[UniqueID ] <> Nh.[UniqueID ] 
	--joined same table but not the same row
Where Ns.PropertyAddress is not null

--Update housing Ns
Update Ns
Set Ns.PropertyAddress = ISNULL(Ns.PropertyAddress, Nh.PropertyAddress)
From Portfolio_Project1..Nashville Ns
Join Portfolio_Project1..Nashville Nh
	ON Ns.ParcelID = Nh.ParcelID 
	and Ns.[UniqueID ] <> Nh.[UniqueID ]
Where Ns.PropertyAddress is null

------------------------------------------------
--Breaking out address into individual columns = Address, City
Select a.PropertyAddress
From Portfolio_Project1..Nashville a

Select *
From Portfolio_Project1..Nashville a

Select 
	SUBSTRING(a.PropertyAddress, 1, CHARINDEX(',', a.PropertyAddress) -1) as Address,
	SUBSTRING(a.PropertyAddress, CHARINDEX(',', a.PropertyAddress) +1, LEN(a.PropertyAddress)) as City
From Portfolio_Project1..Nashville a

--Create two new columns
ALTER TABLE Nashville
Add PropertySplitAddress nvarchar(255);

ALTER TABLE Nashville
Add PropertySplitCity nvarchar(255);

Update Nashville 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update Nashville 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Owner Address
Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From Portfolio_Project1..Nashville 

ALTER TABLE Nashville
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE Nashville
Add OwnerSplitCity nvarchar(255);

ALTER TABLE Nashville
Add OwnerSplitState nvarchar(255);

Update Nashville 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Update Nashville 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Update Nashville 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

------------------------------------------------------------------
--Change Y and N to yes or no in "Sold as Vacant" Field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project1..Nashville
Group by SoldAsVacant

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
	WHEN SoldAsVacant LIKE 'N' THEN 'No'
	ELSE SoldAsVacant
END
From Portfolio_Project1..Nashville

Update Portfolio_Project1..Nashville
Set SoldAsVacant = CASE
	WHEN SoldAsVacant LIKE 'Y' THEN 'Yes'
	WHEN SoldAsVacant LIKE 'N' THEN 'No'
	ELSE SoldAsVacant
END
---------------------------------------------------------
--Remove Duplicates
WITH rowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER BY UniqueID
	) row_num
From Portfolio_Project1..Nashville
)

DELETE  
From rowNumCTE
Where row_num > 1

-----------------------------------------------------------
--Delete Unused Columns
Alter Table Portfolio_Project1..Nashville
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_Project1..Nashville
DROP Column SaleDate



