
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From SQLDataExploration..CovidDeaths
Where continent is not null 
order by 3,4


--------------
Select Location, date, total_cases, new_cases, total_deaths, population
From SQLDataExploration..CovidDeaths
Where continent is not null 
order by 1,2



-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in Kenya

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLDataExploration..CovidDeaths
Where location = 'Kenya'
and continent is not null 
order by 1,2



-- Total Cases vs Population
-- Kenyan percentage of population infected with Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectecPercentage
From SQLDataExploration..CovidDeaths
Where location = 'Kenya'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From SQLDataExploration..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCountPerCountry
From SQLDataExploration..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCountPerCountry desc



-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsPerContinet
From SQLDataExploration..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsPerContinet desc



-- Global Data

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLDataExploration..CovidDeaths
where continent is not null 
order by 1,2



-- Percentage of Population that has recieved at least one Covid Vaccine

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths deaths
Join SQLDataExploration..CovidVaccinations vaccine
	On deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null 
--order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths deaths
Join SQLDataExploration..CovidVaccinations vaccine
	On deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLDataExploration..CovidDeaths deaths
Join SQLDataExploration..CovidVaccinations vaccine
	On deaths.location = vaccine.location
	and deaths.date = vaccine.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths deaths
Join SQLDataExploration..CovidVaccinations vaccine
	On deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null 