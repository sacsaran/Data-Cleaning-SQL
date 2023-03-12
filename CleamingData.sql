/*
Data Cleaning project
*/

select * from PortfolioProject.dbo.NashvillHousing
----------------------------------------------------------------------------------------------------------
--standarise Date format
--we convert the SaleDate to date only and remove the time

select convertedSaleDate, convert(date,saleDate) as NewSAleDate
from PortfolioProject.dbo.NashvillHousing

update NashvillHousing 
set SaleDate= convert(date,saleDate)

alter table NashvillHousing
add convertedSaleDate date;

update NashvillHousing
set convertedSaleDate= convert(date,saleDate);

select * from 

-----------------------------------------------------------------------------------------------------------------------------------------
--populate Property Address Data

select *
from NashvillHousing
where PropertyAddress is null
order by ParcelID

--Identical parcelID with corresponding identical propertyb Adress
--let's do autojoin

select A.ParcelID,A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
from NashvillHousing as A join NashvillHousing as B
on A.ParcelID= B.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update A
set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from NashvillHousing as A join NashvillHousing as B
on A.ParcelID= B.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------
-- Break Address into individual coloum (Address, City, State) using substring and LEN

select propertyaddress from 
NashvillHousing

select SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Adress,
substring(propertyaddress,CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) as City 
from NashvillHousing


alter table NashvillHousing /* Add an extra column to the table */
add NashvillSplitAdress nvarchar(255)

update NashvillHousing
set NashvillSplitAdress=SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)


alter table NashvillHousing /* Add an extra column to the table */
add NashvillSplitCity nvarchar(255)

update NashvillHousing
set NashvillSplitCity=substring(propertyaddress,CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) /* taking the City only*/


select NashvillSplitCity 
from NashvillHousing



/*  splitting the OwnerAdress using ParsName*/

select OwnerAddress
from NashvillHousing


select 
PARSENAME(replace(OwnerAddress,',','.'), 3) as Adress, /* we reaplcing the coma(,) to the dot (.) as this is wat parsname understand*/
PARSENAME(replace(OwnerAddress,',','.'), 2)as City,
PARSENAME(replace(OwnerAddress,',','.'), 1) as State
from NashvillHousing

alter table NashvillHousing
Add AddressOWner nvarchar(255)

update NashvillHousing
set AddressOWner = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvillHousing
Add CitysOWner nvarchar(255)


update NashvillHousing
set CitysOWner = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvillHousing
Add StateOWner nvarchar(255)

update NashvillHousing
set StateOWner = PARSENAME(replace(OwnerAddress,',','.'),1)


--------
--changing Y and N to Yes and NO in 'Sold as Vacant' field


select distinct(SoldAsVacant), count(SoldAsVacant) 

from NashvillHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case 
    when SoldAsVacant ='Y' Then 'YES'
    When SoldAsVacant='N' then 'NO'
    else SoldAsVacant
end
from NashvillHousing

update NashvillHousing
set SoldAsVacant= case 
    when SoldAsVacant ='Y' Then 'YES'
    When SoldAsVacant='N' then 'NO'
    else SoldAsVacant
end
from NashvillHousing

------------------------------------------
-- Remove Duplicate using ROW number

WITH RownumnbCTE as(
select*,
ROW_NUMBER() OVER (PARTITION BY 
                      parcelID,
                      PropertyAddress, 
					  SaleDate, 
					  saleprice,
					  LegalReference
                      order by uniqueID 
)duplicate
from PortfolioProject.dbo.NashvillHousing
) 
/* delete
from RownumnbCTE
where duplicate>1
 */
select *
from RownumnbCTE
where duplicate>1



-----------------------------------------------------------
-- Delete unused colums

select *
from NashvillHousing

alter table NashvillHousing
drop Column OwnerAddress, taxDistrict, propertyAddress, saledate


