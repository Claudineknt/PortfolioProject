/*Olympic Games from 1896 t0 2016 Data Exploration


*/

--Exploring the dataset
Select * from PortfolioProject.dbo.athlete_events

--Select the No. of Olympics games that have been held per the dataset from Athens 1896 to Rio 2016

SELECT Count(Distinct(Games)) NoOfEvent
FROM PortfolioProject.dbo.athlete_events

--Return the list of all Olympic games played so far
SELECT Year, Season, City
FROM PortfolioProject.dbo.athlete_events
Group by Year, Season, City
Order by 1 


--Shows the total number of countries/regions that participated in each olympic games. 
--Using CTE join the NOC table (has the countries) - National Olympic Committee

With AllRegions As (
SELECT  OH.Games, NR.region
FROM PortfolioProject.dbo.athlete_events OH
JOIN PortfolioProject.dbo.noc_regions NR
ON  OH.NOC = NR.NOC 
Group By Games, Nr.region)

SELECT Games, COUNT(1) TotalCountries
FROM AllRegions
Group by Games
Order By Games


--Option 2 to show the number of countries that participated in each olympic games
--The above result can be got by using a temp table

USE PortfolioProject
DROP Table if exists #MinMaxParticipatingCountries
Create Table #MinMaxParticipatingCountries (
Games nvarchar(255),
Region nvarchar (255))

INSERT INTO #MinMaxParticipatingCountries
SELECT  OH.Games, NR.region
FROM PortfolioProject.dbo.athlete_events OH
JOIN PortfolioProject.dbo.noc_regions NR
ON  OH.NOC = NR.NOC 
Group By Games, NR.Region

SELECT  Games, COUNT(1)  as MinCount
FROM #MinMaxParticipatingCountries
Group By Games
Order By 1



--Show the Olympic Games that had the highest participating countries and the lowest participating countries, 

With AllRegions As (
SELECT  OH.Games, NR.region
FROM PortfolioProject.dbo.athlete_events OH
JOIN PortfolioProject.dbo.noc_regions NR
ON  OH.NOC = NR.NOC 
Group By Games, Nr.region),

TotCountries as (
SELECT Games, COUNT(1) AS TotalCountries
FROM AllRegions
Group by Games
)

Select DISTINCT (FIRST_VALUE(Games) OVER (order by TotalCountries)) AS GameTime, FIRST_VALUE(TotalCountries) OVER (order BY TotalCountries) As LowestCountries 
,(FIRST_VALUE(Games) OVER (order by TotalCountries Desc)),FIRST_VALUE(TotalCountries) OVER (order BY TotalCountries desc) As HighestCountries 
from TotCountries

--Return countries that have participated in all the Olympic games since 1896. there are a total of 51 games
With AllRegions As (
SELECT  OH.Games, NR.region
FROM PortfolioProject.dbo.athlete_events OH
JOIN PortfolioProject.dbo.noc_regions NR
ON  OH.NOC = NR.NOC 
Group By Games, Nr.region),

totalgames AS(
SELECT region, COUNT(1) TotalCountries
FROM AllRegions
Group by region
--Order By region 
) 

SELECT region, TotalCountries
FROM totalgames
WHERE TotalCountries >50


--Show the sport that was played in all summer games

 With table1 as
          	(select count(distinct Games) as total_games
          	from PortfolioProject..athlete_events where Season = 'Summer'),
          table2 as
          	(select distinct Games, Sport
          	from PortfolioProject..athlete_events where Season = 'Summer'),
          table3 as
          	(select Sport, count(1) as no_of_games
          	from table2
          	group by sport)
      select *
      from table3
      join table1 on table1.total_games = table3.no_of_games;



--Identify the sport that was just played once in all of olympics.
SELECT Sport,  Count(Distinct(Games)) GamesPlayedOnce
from PortfolioProject..athlete_events
Group By Sport
Having Count(Distinct Games) = 1
Order By Sport, Count(1)



--Total number of games played in each olympic games
SELECT Games, Count(Distinct Sport) OlympicGames
from PortfolioProject..athlete_events
Group By Games
Order By Count(Distinct Sport) Desc



--Oldest athlete to win the gold medals
Select *
from PortfolioProject..athlete_events
Where Age >63 and Medal = 'Gold'
Order by Age Desc



--Show the 5 Top Altheletes that have won the most gold medals

Select Top 5 AE.Name, NR.region, Count (1) as totalgold
FROM PortfolioProject..athlete_events AE
JOIN PortfolioProject..noc_regions NR
ON AE.NOC = NR.NOC
Where AE.Medal = 'Gold'
Group by AE.Name, NR.region
Order By Count(1) Desc

--Show the top athletes who have won the most medals (Medals include gold, silver and bronze)
With CTE_Table1 as
            (select Name, Team, count(1) as total_medals
            FROM PortfolioProject..athlete_events 
            where Medal in ('Gold', 'Silver', 'Bronze')
            group by Name, Team
            --order by total_medals desc
			),
        CTE_Table2 as
            (select *, dense_rank() over (order by total_medals desc) as Grp
            from CTE_Table1)
    Select Name, Team, total_medals
    from  CTE_Table2
    where Grp <= 5

--Return the top 5 most successful countries in olympics. (Success is defined by no of medals won)

select NR.region, Count(1) as Total_Medals,
ROW_NUMBER() OVER(Order BY Count(1) DESC) 
            FROM PortfolioProject..athlete_events AE
			JOIN PortfolioProject..noc_regions NR
			ON AE.NOC = NR.NOC
        where Medal in ('Gold', 'Silver', 'Bronze')
        group by NR.region
        order by Count(1) desc



--List total gold, bronze and silver won by each country
--Solution 1
Select  NR.region, AE.Medal, Count(1) as Total_Medals 
            FROM PortfolioProject..athlete_events AE
			JOIN PortfolioProject..noc_regions NR
			ON AE.NOC = NR.NOC
        where Medal in ('Gold', 'Silver', 'Bronze')
        group by NR.region, AE.Medal
        order by Count(1) desc

--Different View. Solution 2
Select NR.Region,
Count(Case When AE.Medal='Gold' Then 1 End) AS Gold,
Count(Case When AE.Medal='Silver' Then 1 End) AS Silver,
Count(Case When AE.Medal='Bronze' Then 1 End) AS Bronze
from PortfolioProject..athlete_events AE 
Join  PortfolioProject..noc_regions NR
On AE.NOC = NR.NOC
Group by NR.Region
Order By Gold Desc,Silver Desc,Bronze Desc



--Return for each Olympic Games, which country won the highest gold, silver and bronze medals

With T1
As
(select O.Games, oh.region,
sum(case when Medal='Gold' then 1 else 0 end) as Gold,
sum(case when Medal= 'Silver' then 1 else 0 end) as Silver,
sum(case when Medal= 'Bronze' then 1 else 0 end) as Bronze
from PortfolioProject..athlete_events o
join  PortfolioProject..noc_regions oh on
o.NOC=oh.NOC
group by Games,region)
Select Distinct games,
Concat(
(FIRST_VALUE(region) Over(partition by games order by Gold desc)),
'-',
(FIRST_VALUE(Gold) Over(partition by games order by Gold desc))) As MaxGold,
Concat(
(FIRST_VALUE(region) Over(partition by games order by Silver desc)),
'-',
(FIRST_VALUE(Silver) Over(partition by games order by Silver desc))) As MaxSilver,
Concat(
(FIRST_VALUE(region) Over(partition by games order by Bronze desc)),
'-',
(FIRST_VALUE(Bronze) Over(partition by games order by Bronze desc))) As MaxBronze
From T1
Order By Games

--Show the sport where Any Country won the highest no of medals (In this case we go with USA)

Select Top 1 AE.Sport, Count(1) as totalmedals
            FROM PortfolioProject..athlete_events AE
			JOIN PortfolioProject..noc_regions NR
			ON AE.NOC = NR.NOC
        where Medal <>'NA' AND NR.NOC = 'USA'
        group by AE.Sport
        order by totalmedals desc 



--Return details of all Olympic Games where USA won medal(s) in hockey. 

SELECT AE.Team, AE.Sport, AE.Games, Count(1) as totalmedals
            FROM PortfolioProject..athlete_events AE
			JOIN PortfolioProject..noc_regions NR
			ON AE.NOC = NR.NOC
        where Medal <>'NA' AND NR.NOC = 'USA' AND Sport = 'Hockey'
        group by AE.Sport, AE.Games,AE.Team
        order by totalmedals desc 