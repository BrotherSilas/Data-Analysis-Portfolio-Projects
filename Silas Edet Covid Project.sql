select *
from [Silas Edet portfolio project]..CovidDeaths
where continent IS NOT NULL
order by 3,4;

select *
from [Silas Edet portfolio project]..CovidDeaths
where location = 'Nigeria'
order by 3,4;


select *
from [Silas Edet portfolio project]..CovidVaccinations
where location = 'Nigeria'
order by 3,4

-- Select data i will be using

select location, date, total_cases, total_deaths, population
From [Silas Edet portfolio project]..CovidDeaths
where location = 'Nigeria'
order by 1,2


DELETE
From [Silas Edet portfolio project]..CovidDeaths
WHERE total_cases IS NULL AND total_deaths IS NULL

select location, date, total_cases, total_deaths, population
From [Silas Edet portfolio project]..CovidDeaths
where location = 'Nigeria'
order by 1,2

-- Looking at Total cases vs Total Deaths
-- shows the likelihood of dying if you contract covid

SELECT location, date, total_cases, total_deaths (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercent 
From [Silas Edet portfolio project]..CovidDeaths
WHERE location = 'Nigeria'
order by 1, 2

-- looking at total cases vs population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS PopulationPercentIfected 
From [Silas Edet portfolio project]..CovidDeaths
WHERE location = 'Nigeria'
order by 1, 2


-- looking at countries with highes infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS HighestPopulationPercent 
From [Silas Edet portfolio project]..CovidDeaths
GROUP BY location, population
order by HighestPopulationPercent desc


--countries with highest death counts per population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS MaxTotalDeathCount 
From [Silas Edet portfolio project]..CovidDeaths
where continent IS NOT NULL
GROUP BY location, population
order by MaxTotalDeathCount desc

-- LET'S BREAK THINGS DOWN INTO CONTINENTS

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxTotalDeathCount 
From [Silas Edet portfolio project]..CovidDeaths
where continent IS NULL
GROUP BY location
order by MaxTotalDeathCount desc

SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxTotalDeathCount 
From [Silas Edet portfolio project]..CovidDeaths
where continent IS NOT NULL
GROUP BY continent
order by MaxTotalDeathCount desc


-- showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxTotalDeathCount 
From [Silas Edet portfolio project]..CovidDeaths
where continent IS NOT NULL
GROUP BY continent
order by MaxTotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage 
From [Silas Edet portfolio project]..CovidDeaths
WHERE continent IS NOT NULL
order by 1, 2



SELECT * 
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE
WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location) AS RollingPeopleVaccinated
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopVsVac


-- USING TEMP TABLE

DROP Table if exists RollingPeopleVaccinatedPercentage
CREATE Table RollingPeopleVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into RollingPeopleVaccinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location) AS RollingPeopleVaccinated
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM RollingPeopleVaccinatedPercentage



-- PERCENTAGE OF PEOPLE VACCINATED PER POPULATION IN NIGERIA
-- USING TEMP TABLE

DROP Table if exists RollingPeopleVaccinatedPercentage
CREATE Table RollingPeopleVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into RollingPeopleVaccinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location) AS RollingPeopleVaccinated
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.location = 'Nigeria'
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM RollingPeopleVaccinatedPercentage



SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, vac.new_vaccinations_smoothed
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Nigeria'
ORDER BY 1, 2, 3


-- Creating view to store data for later

Create View RollingPeopleVaccinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location) AS RollingPeopleVaccinated
From [Silas Edet portfolio project]..CovidDeaths as dea
JOIN [Silas Edet portfolio project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2, 3