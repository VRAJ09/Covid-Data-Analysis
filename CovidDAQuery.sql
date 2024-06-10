--During Covid Data Analysis

--Covid Deaths Data
SELECT *
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Covid Vaccinations Data
SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4

-- DATA EXPLORATION

--Select Data that we will be working on
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Displays the probability of dying if you contract covid in your respective country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percent_deaths_for_cases
FROM CovidProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/Population) * 100 AS percent_cases_for_population
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

--Looking at Cardiovascular Death Rate vs. Total Cases
SELECT Location, date, total_cases, cardiovasc_death_rate
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Average of New Cases vs GDP Per Capita
SELECT Location, AVG(new_cases) AS average_new_cases, AVG(gdp_per_capita) AS average_gdp_per_capita
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY average_new_cases DESC


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/Population)) * 100 AS highest_cases_per_population
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY highest_cases_per_population DESC

-- Showing Countries with Highest Death rate per Population 
SELECT Location, Population, MAX(CAST(total_deaths AS int)) AS highest_death_count, MAX((total_deaths/Population)) * 100 AS highest_deaths_per_population
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY highest_deaths_per_population DESC

-- Showing Countries with highest total vaccinations
SELECT Location, Population, MAX(CAST(total_vaccinations AS int)) AS highest_vaccinations_count
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY highest_vaccinations_count DESC

-- BREAK DATA UP BY CONTINENT

-- Showing Total Death Count Per Continent
SELECT Location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS
-- World total cases, total deaths, and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS 
(
--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Rolling_Vaccinated_Percentage
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
	Continent nvarchar(255), 
	Location nvarchar(225),
	Date datetime,
	Population int,
	New_Vaccinatios numeric,
	Rolling_People_Vaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as rolling_people_vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Rolling_Vaccinated_Percentage
FROM #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualization
CREATE VIEW PercentPopualtionVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3

SELECT *
FROM PercentPopualtionVaccinated