/*Audible for Amazon Dataset Clean-up */

Select Top 100 * from PortfolioProject..Audible


--Standardizing the date format and create a new column to store the data.

UPDATE Audible
SET releasedate = CONVERT(Date, releasedate)

ALTER TABLE Audible
ADD ReleaseDateConverted Date

UPDATE Audible
SET ReleaseDateConverted = CONVERT(Date, releasedate)


--Cleaning the Author column by trimming the 'WrittenBy' statement and generate a new column to store the new result


Select author, SUBSTRING(author, 11, LEN(author))
from PortfolioProject..Audible

--Option 2:- Extract 20 chracters from the author column starting at position 11
Select author, SUBSTRING(author, 11, 20)
from PortfolioProject..Audible

ALTER TABLE Audible
ADD AuthorUpdated varchar(255)

UPDATE Audible
SET AuthorUpdated = SUBSTRING(author, 11, LEN(author) -5)



--Cleaning the narrator column by trimming the 'Narratedby' statement and generate a new column to store the new result

Select narrator, SUBSTRING(narrator, 12, LEN(narrator))
from PortfolioProject..Audible

--Option 2:- Extract 20 chracters from the author column starting at position 11
Select author, SUBSTRING(author, 11, 30)
from PortfolioProject..Audible

ALTER TABLE Audible
ADD NarratorUpdated varchar(255)

UPDATE Audible
SET NarratorUpdated = SUBSTRING(narrator, 12, 50)

--Returning only the rating value for each item. Rtae is from 1 to 5

SELECT stars, SUBSTRING(stars,1,1)
FROM PortfolioProject..Audible

ALTER TABLE Audible
ADD StarsUpdated NVARCHAR(255)

UPDATE Audible
SET StarsUpdated = SUBSTRING(stars,1,1)



--Change Y and N to Yes and No on "Sold as Vacant" field
--Count the number of instances for each values
SELECT Distinct(Rewatch), Count(Rewatch)
FROM PortfolioProject.dbo.Audible
Group By Rewatch
Order by 2

--Change the instances

SELECT Rewatch , 
Case 
     When Rewatch = 'Y' THEN 'Yes'
     When Rewatch = 'N' THEN 'No'
	 ELSE Rewatch
	 END 
FROM PortfolioProject.dbo.Audible

Update Audible
Set Rewatch = Case
When Rewatch = 'Y' THEN 'Yes'
     When Rewatch = 'N' THEN 'No'
	 ELSE Rewatch
	 END

Update Audible	 
SET Rewatch = COALESCE(Rewatch, 'Not Yet Rated')

--Delete Unused columns, NOTE:- this isn't advisavle

--Delete Unused Columns


ALTER TABLE PortfolioProject..Audible
Drop Column author, narrator, releasedate, stars

