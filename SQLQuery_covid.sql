-- Covid Death Database
SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Data from CovidDeaths table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Total cases vs Total Deaths
SELECT
	location,
	date,
	CAST(total_cases AS int) AS TotalCases,
	CAST(total_deaths AS int) AS TotalDeaths,
	CAST((CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)) * 100 AS decimal (10,4)) DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--AND location = 'Iran'
ORDER BY 1,2

--Create View of Total cases vs Total Deaths
CREATE VIEW TotalCasesVsTotalDeaths as
SELECT
	location,
	date,
	CAST(total_cases as int) as TotalCases,
	CAST(total_deaths AS int) AS TotalDeaths,
	CAST((CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)) * 100 AS decimal (10,4)) DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL

-- Total cases vs Popuation
SELECT
	location,
	date,
	CAST(population AS int) AS Population,
	CAST(total_cases AS int) AS TotalCases,
	CAST((CAST(total_cases AS decimal)/CAST(population AS decimal)) * 100 AS decimal (10,8)) InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--AND location = 'Iran'
ORDER BY 1,2

-- Craete View of Total cases vs Popuation

CREATE VIEW TotalCasesVsTotalPopulation as
SELECT
	location,
	date,
	CAST(population AS int) AS Population,
	CAST(total_cases AS int) AS TotalCases,
	CAST((CAST(total_cases AS decimal)/CAST(population AS decimal)) * 100 AS decimal (10,8)) InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL

--Countries with Highest Infection Rate
SELECT
	Location,
	Population,
	MAX(CAST(total_cases as int)) as HighestInfectionCount,
	MAX((CAST(total_cases as int)/CAST(population as decimal))) * 100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY InfectedPercentage  DESC

--Create View of Countrie's Infection Rates
CREATE VIEW	CountriesInfectionRates as
SELECT
	Location,
	Population,
	MAX(CAST(total_cases as int)) as HighestInfectionCount,
	MAX((CAST(total_cases as int)/CAST(population as decimal))) * 100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population

--Countries with Highest Deaths per population
SELECT 
	location,
	population,
	Max(CAST(total_deaths as int)) as TotalDeathCount,
	Max(CAST(total_deaths as int)) / population * 100 as DeathPercentagePerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Creating View of Total Death Per Country
CREATE VIEW TotalDeathPerCountry as
SELECT 
	location,
	population,
	Max(CAST(total_deaths as int)) as TotalDeathCount,
	Max(CAST(total_deaths as int)) / population * 100 as DeathPercentagePerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population


--Continent with Highest Death Count
SELECT 
	continent,
	MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Creating View of Total Death per Continent 
CREATE VIEW TotalDeathPerContinent as 
SELECT 
	continent,
	MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent

--Global
SELECT 
--	date,
	SUM(CAST(new_cases as int)) as NewInfectionCount,
	SUM(CAST(new_deaths as int)) as NewDeathCount,
	CASE WHEN SUM(CAST(new_cases as int)) = 0 THEN NULL
	     ELSE 1.0 * SUM(CAST(new_deaths as int))/SUM(CAST(new_cases as int)) * 100
	END as DeathToInfectionRatio
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2;

--Covid Vaccination Database

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY location

--Total Population vs Total Vaccination
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as TotalVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--AND dea.location = 'India'
ORDER BY 2,3



--ETC
WITH PopVsVac (continent, location, date, population, new_vaccination, TotalVaccination)
as (
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as TotalVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (TotalVaccination/population) * 100 as VaccinationPercentage
FROM PopVsVac

--Creating View of Population Vs Vaccination
Create View PercentPopulationVaccinated as
WITH PopVsVac (continent, location, date, population, new_vaccination, TotalVaccination)
as (
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as TotalVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (TotalVaccination/population) * 100 as VaccinationPercentage
FROM PopVsVac


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
TotalVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as TotalVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (TotalVaccination/population) * 100 as VaccinationPercentage
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3 

