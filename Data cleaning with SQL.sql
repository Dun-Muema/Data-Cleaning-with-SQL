--Cleaniing Data with SQL

Select * 
from [Project ].[dbo].[Nashville Housing]

--Standardize the Date format
Select SaleDateConverted, CONVERT(Date, SaleDate)
from[Project ].[dbo].[Nashville Housing]

Alter table [Project ].[dbo].[Nashville Housing]
add SaleDateConverted Date;

Update [Project ].[dbo].[Nashville Housing]
set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate the property Address (where the property Adress is Null)

Select *
from[Project ].[dbo].[Nashville Housing]
--where PropertyAddress is Null
order by ParcelID

Select X.ParcelID,X.PropertyAddress,Y.ParcelID,Y.PropertyAddress, ISNULL(X.PropertyAddress,Y.PropertyAddress)
from[Project ].[dbo].[Nashville Housing] X
join[Project ].[dbo].[Nashville Housing]Y
	on X.ParcelID = Y.ParcelID
	and X.[UniqueID ]<>Y.[UniqueID ]
where X.PropertyAddress is Null

Update X
set PropertyAddress = ISNULL(X.PropertyAddress,Y.PropertyAddress)
from[Project ].[dbo].[Nashville Housing] X
join[Project ].[dbo].[Nashville Housing]Y
	on X.ParcelID = Y.ParcelID
	and X.[UniqueID ]<>Y.[UniqueID ]

--Breakdown of Address into indvidual columns Address, City & State
Select PropertyAddress
from[Project ].[dbo].[Nashville Housing]
--where PropertyAddress is Null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from[Project ].[dbo].[Nashville Housing]

Alter table [Nashville Housing]
add PropertyAddress_split Nvarchar(255);

Update [Project ].[dbo].[Nashville Housing]
set PropertyAddress_split = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) 

Alter table [Nashville Housing]
add PropertyAddress_city Nvarchar(255);

Update [Project ].[dbo].[Nashville Housing]
set PropertyAddress_city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 


-- breakdown of owners adress to (Address, City & State)

Select OwnerAddress
from[Project ].[dbo].[Nashville Housing]

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from[Project ].[dbo].[Nashville Housing]

Alter table [Project ].[dbo].[Nashville Housing]
add OwnerAddress_split Nvarchar(255);

Update [Project ].[dbo].[Nashville Housing]
set OwnerAddress_split = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table [Project ].[dbo].[Nashville Housing]
add OwnerAddress_city Nvarchar(255);

Update [Project ].[dbo].[Nashville Housing]
set OwnerAddress_city = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter table [Project ].[dbo].[Nashville Housing]
add OwnerAddress_state Nvarchar(255);

Update [Project ].[dbo].[Nashville Housing]
set OwnerAddress_state = PARSENAME(Replace(OwnerAddress,',','.'),1) 

--Changing the Y and N to Yes and No in the SoldAsVacant Field
Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from[Project ].[dbo].[Nashville Housing] 
group by SoldAsVacant
order by 2

Select SoldAsVacant
,	case
		when SoldAsVacant ='Y' then 'Yes'
		when SoldAsVacant ='N' then 'No'
		else SoldAsVacant
		end
from[Project ].[dbo].[Nashville Housing] 

update [Project ].[dbo].[Nashville Housing]
set SoldAsVacant = case
		when SoldAsVacant ='Y' then 'Yes'
		when SoldAsVacant ='N' then 'No'
		else SoldAsVacant
		end
---------------------------------------------------------------------
--Removing Duplicates
With ROWNumCTE as 
(
select *,
	ROW_NUMBER()over(
	Partition by ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference 
				 ORDER By 
				 UniqueID
				 ) row_num
from[Project ].[dbo].[Nashville Housing]
--order by ParcelID
)
DELETE
From ROWNumCTE
where row_num > 1
--order by PropertyAddress

--Delete Unused Columns

Select*
from[Project ].[dbo].[Nashville Housing]

Alter table[Project ].[dbo].[Nashville Housing]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table[Project ].[dbo].[Nashville Housing]
Drop Column SaleDate