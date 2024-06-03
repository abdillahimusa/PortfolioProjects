-- The likelihood of dying if infected with covid in Canada
SELECT [location],[date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM TutorialDB..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2

-- Amount of people infected with Covid in percentage
SELECT [location],[date], population, total_cases, (total_cases/population)*100 AS CovidInfected
FROM TutorialDB..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2

-- Highest cases 
SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CovidInfected
FROM TutorialDB..CovidDeaths
GROUP BY [location], population
ORDER BY CovidInfected DESC

-- Highest deaths per country
SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM TutorialDB..CovidDeaths
WHERE continent is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM TutorialDB..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM TutorialDB..CovidDeaths
WHERE continent is not NULL
GROUP BY [date]
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM TutorialDB..CovidDeaths
WHERE continent is not NULL
order by 1,2

-- Join both of our tables toghether by location and date
SELECT *
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

-- Total population vs vaccinations

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3

-- CTE
With PopsvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS(SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)Select *, (RollingPeopleVaccinated/Population)*100
FROM PopsvsVac
ORDER BY 2,3

-- Temp Table
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
    Continent nvarchar(50),
    Location nvarchar(50),
    Date date,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric,
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM TutorialDB..CovidDeaths dea 
JOIN TutorialDB..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL


SELECT * 
FROM PercentPopulationVaccinated