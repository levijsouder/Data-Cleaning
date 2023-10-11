
use HousingDatadb

--Cleaning Data in SQL Queries

select*
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select 
	SaleDate,
	convert(date,Saledate) as saledate
from NashvilleHousing

--update of SaleDate direct not working so created a new SaleDate column to convert and update

alter table NashvilleHousing
add saledate2 date
update NashvilleHousing
set SaleDate2=convert(date,Saledate)

select 
	saledate2,
	*
from nashvillehousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from NashvilleHousing
--where PropertyAddress is null(checking for nulls to remove)
order by ParcelID

-- ParcelID coresponds to property address

select 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID,
	b.PropertyAddress,
	isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null

-- now if we run the query before the update there will be no null's in property thus 0 lines will be queried

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select 
	PropertyAddress
from NashvilleHousing

select
	substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
	substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from NashvilleHousing

ALTER TABLE NashvilleHousing
add StreetAddress Nvarchar(255)

update NashvilleHousing
set StreetAddress=substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
add City Nvarchar(255)

update NashvilleHousing
set City=substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

-- now that I've broken up the address' I can add new columns and update them with the substring query (we'll get rid of all the transformed rows last)

-- Here is a similar tranformation for Owner Address' which include a state

select*
from NashvilleHousing

select
	parsename(replace(OwnerAddress, ',','.'),3),
	parsename(replace(OwnerAddress, ',','.'),2),
	parsename(replace(OwnerAddress, ',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerStAddress nvarchar(255)

update NashvilleHousing
set OwnerStAddress=parsename(replace(OwnerAddress, ',','.'),3)

alter table NashvilleHousing
add OwnerCity nvarchar(255)

update NashvilleHousing
set OwnerCity=parsename(replace(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerState nvarchar(255)

update NashvilleHousing
set OwnerState=parsename(replace(OwnerAddress, ',','.'),1)

select*
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select 
	Distinct(SoldAsVacant), 
	count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select
	SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
					  when SoldAsVacant = 'N' then 'No'
					  else SoldAsVacant
					  end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- writing a cte and using windows functions to find the duplicates
with RowNumCTE as(
select *,
	ROW_NUMBER()over(
	partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num>1

with RowNumCTE as(
select *,
	ROW_NUMBER()over(
	partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from NashvilleHousing
)
Select*
from RowNumCTE
where row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from NashvilleHousing

-- want to delete
	-- owner address
	-- tax district
	-- property address
	-- sale date

alter table NashvilleHousing
drop column OwnerAddress,
			TaxDistrict,
			PropertyAddress			
			
alter table NashvilleHousing
drop column SaleDate