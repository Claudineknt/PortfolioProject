Select * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--Select * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--looking at total cases vs total deaths
-- Shows the likelihood of dieing if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Looking at the total cases vs the population
--shows what %age of population got covid.
Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Uganda%'
ORDER BY 1,2 

--return the countries with the highest infection rate compared to the population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Uganda%'
Group By location, population
ORDER BY PercentPopulationInfected DESC

--Countries with the highest death count per population

Select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group By location
ORDER BY TotalDeathCount DESC

--LETS BREAT THINGS DOWN BY CONTINENT

Select continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
Group By continent
ORDER BY TotalDeathCount DESC

--showing continents with the highest death count per population
Select continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS Not NULL
Group By continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
Select date SUM (new_cases) as totalNewCases, SUM(CAST(new_deaths as int)) as totalNewDeaths,  SUM(CAST(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
Group BY date
ORDER BY 1,2 

--showing the death percentage of the total population of the world
Select SUM (new_cases) as totalNewCases, SUM(CAST(new_deaths as int)) as totalNewDeaths,  SUM(CAST(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--Group BY date
ORDER BY 1,2 

--COVID VACCINATIONS

Select * 
FROM PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vac
  ON Death.location=Vac.location
  and Death.date= Vac.date


--Looking at total population VS vaccination

Select Death.continent, Death.location, Death.date, Death.population, CAST(Vac.new_vaccinations as bigint),
SUM(CAST(Vac.new_vaccinations as bigint)) OVER (Partition by Death.location ORDER BY Death.location, 
Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vac
  ON Death.location=Vac.location
  and Death.date= Vac.date
  WHERE Death.continent is not null
order by 2,3

--CTE
With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select Death.continent, Death.location, Death.date, Death.population, CAST(Vac.new_vaccinations as bigint),
SUM(CAST(Vac.new_vaccinations as bigint)) OVER (Partition by Death.location ORDER BY Death.location, 
Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vac
  ON Death.location=Vac.location
  and Death.date= Vac.date
  WHERE Death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopsvsVac


--TEMP TABLE

USE PortfolioProject
DROP Table if exists #PercentPopulationVaccinated  --(use this statment if you are planning on making alterations to the temp table
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
Insert into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as bigint)) OVER (Partition by Death.location ORDER BY Death.location, 
Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vac
  ON Death.location=Vac.location
  and Death.date= Vac.date
--WHERE Death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



