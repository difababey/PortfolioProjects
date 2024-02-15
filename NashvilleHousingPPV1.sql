--Cleaning the data
Select * 
From [Portfolio Project]..NashvilleHousing

--Change Sale date

Select *, SaleDateConverted, Convert(Date, SaleDate)
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

-- Because Table did not UPDATE 
Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)
-----------------------------------------


--Populate Property address data

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

--Doing a self join to look at if parcelid is equal to Property address 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress IsNull(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a 
Join [Portfolio Project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set propertyaddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a 
Join [Portfolio Project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
---------------------------------------

--Breaking Out Address into Individual columns

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

Select 
Substring(Propertyaddress, 1, Charindex(',',propertyaddress)-1)  UpdatedAddress,
Substring(Propertyaddress, Charindex(',',propertyaddress)+ 1, len(propertyaddress)  City
From [Portfolio Project]..NashvilleHousing

Alter Table NashvilleHousing
Add propertysplitaddress Nvarchar(255);

Update NashvilleHousing
Set propertysplitaddress = Substring(Propertyaddress, 1, Charindex(',',propertyaddress)-1)  

Alter Table NashvilleHousing
Add propertysplitcity Nvarchar(255);

Update NashvilleHousing
Set propertysplitcity = Substring(Propertyaddress, Charindex(',',propertyaddress)+ 1, len(propertyaddress)


--Using Parsename instead of substring. Works well for delimitted items

Select Owneraddress
From [Portfolio Project]..NashvilleHousing

Select 
Parsename(Replace(Owneraddress,',','.'),3)
Parsename(Replace(Owneraddress,',','.'),2)
Parsename(Replace(Owneraddress,',','.'),1)
From [Portfolio Project]..NashvilleHousing
--
Alter Table NashvilleHousing
Add ownersplitaddress Nvarchar(255);

Update NashvilleHousing
Set ownersplitaddress = Parsename(Replace(Owneraddress,',','.'),3)
--

Alter Table NashvilleHousing
Add ownersplitcity Nvarchar(255);

Update NashvilleHousing
Set ownersplitcity = Parsename(Replace(Owneraddress,',','.'),2)  
--

Alter Table NashvilleHousing
Add ownersplitstate Nvarchar(255);

Update NashvilleHousing
Set propertysplitstate = Parsename(Replace(Owneraddress,',','.'),1)
-----------------------------------------------------------------------------

--Change Y & N to Yesand No in Sold as Vacant field

Select Distinct (SoldasVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group By SoldasVacant
Order by 2

Select soldasvacant,
CASE When soldasvacant = 'Y' Then 'Yes'
	When soldasvacant = 'N' Then 'No'
	else soldasvacant
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
Set soldasvacant = CASE When soldasvacant = 'Y' Then 'Yes'
						When soldasvacant = 'N' Then 'No'
					Else soldasvacant
From [Portfolio Project]..NashvilleHousing
---------------------------------------------------------------

--Remove duplicates
With RowNumCTE as (
Select Row Number () Over (
	Partition by ParcelID,
				Propertyaddress,
				SalePrice,
				SaleDate,
				LegalRefrence
				Order By Unique ID
				) row_num

From [Portfolio Project]..NashvilleHousing
Order by Parcel ID
)

Delete
From RowNumCTE
Where row_num > 1
Order By PropertyAddress
-----------------------------------------------------------------

--Delete Unused Columns

Select * 
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate