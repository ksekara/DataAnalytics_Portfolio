--select *
--FROM CovidDeaths
--order by 3,4 

--select *
--FROM CovidVaccinations
--order by 3,4 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER by Location, date

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like '%lanka%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- show what percentage of populations had contracted covid
SELECT Location, date, total_cases, population,(total_cases/population)*100 AS InfectionPercentage
FROM CovidDeaths
WHERE Location like '%lanka%'
ORDER BY 1,2

-- Looking at Countries with Highest Infections Rate Compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases)/population*100 AS PercPopulationInfected
FROM CovidDeaths
GROUP BY Location, population
ORDER BY  PercPopulationInfected DESC



-- Showing countries with Highest Death Count per Population
SELECT Location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY TotalDeathCount  DESC

-- DETAILS BY CONTINENT
SELECT location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccination

WITH PopvsVac (Continet, location, date, population,new_vaccinations, CumulativeVaccination)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition BY dea.location  ORDER BY dea.location,dea.Date) AS CumulativeVaccination

FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CumulativeVaccination/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition BY dea.location  ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated

FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 