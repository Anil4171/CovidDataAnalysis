/*
Exploring Covid 19 Data  
Data taken from https://ourworldindata.org/covid-deaths
Data is divided into 2 tables, one containing cases and infection data and other table containing vaccination numbers
Table 1 : CovidDeaths 
Table 2: CovidVac
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Getting all data from the data base
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Selecting Data that is going to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows percentage of deaths caused in India due to Covid per day

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- As of 2021-08-12 2.32% population in India is infected by Covid 

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
-- Data shows Population in Andorra has highest infecction rate with 19.29%

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'India'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
-- Data shows as of 2021-08-12 United States has highest death count with count 619093
-- India stands at thrid place with a count of 430254

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'India'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Global Numbers
-- Globally,
-- Total Cases : 204937769
-- Total Deaths : 4325953
-- Death Percentage : 2.11
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Data is divided into 2 tables, one containing cases and infection data and other table containing vaccination numbers
-- Joining both tables on location and date and using a window funtion gave sum of all people vaccinated per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as SumOfPeopleVaccinatedPerDay
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on SumOfPeopleVaccinatedPerDay column to get percentage of people vaccinated
-- As of 2021-08-12, 473579392 are vaccinated in India, with a 34.31 vaccination percentage 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SumOfPeopleVaccinatedPerDay)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as SumOfPeopleVaccinatedPerDay
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'India'
--order by 2,3
)
Select *, (SumOfPeopleVaccinatedPerDay/Population)*100 as PercentageVaccinated
From PopvsVac



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as SumOfPeopleVaccinatedPerDay
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
