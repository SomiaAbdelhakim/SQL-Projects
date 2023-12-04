SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs total deaths
/**
so we want to know the precentage of people who are dying, who actually get infected	
**/

SELECT location, date,total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Egypt%'
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows precentage of population get Covid

SELECT location, date,  population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS precentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Egypt%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate Compared to population

SELECT location, population, MAX(total_cases), MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS precentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group By location,population
ORDER BY precentPopulationInfected DESC

-- Showing Countries with Highest Death Count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group By location,population
ORDER BY TotalDeathsCount DESC

-- Break Things down by continent
-- Showing continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group By continent
ORDER BY TotalDeathsCount DESC

-- Global Numbers per day

Select date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(New_Cases),0) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group By date
order by 1,2

-- Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(New_Cases),0) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations 
/* what is the total of the people in the world that have been vaccinated*/

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingCount_Vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date
	and dea.location = vac.location 
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Looking at percentage of rollingcount vaccinated
/*We can know the max one but w need to rid of date and keep the location*/

WITH vacPerc (continent, location, date, population, new_vaccinations, RollingCount_Vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingCount_Vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date
	and dea.location = vac.location 
WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingCount_Vaccinated/population)*100 AS vaccinationPercentage
FROM vacPerc

--/* LOOKING at total vaccination for each Country */

--SELECT location, SUM(population) As Total_population, SUM(CONVERT(bigint,new_vaccinations)) AS TotalVaccination,
--			(SUM(CONVERT(bigint,new_vaccinations))/MAX(population))*100 AS vaccinationPercentage
--FROM vacPerc
--GROUP BY location
--ORDER BY location



-- Temp Table 

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingCount_Vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date
	and dea.location = vac.location 

SELECT *, (RollingPeopleVaccinated/population)*100 AS vaccinationPercentage
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingCount_Vaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated