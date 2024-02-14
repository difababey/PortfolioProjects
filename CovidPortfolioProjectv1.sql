--SELECT * 
--FROM [Portfolio Project]..CovidDeaths
--ORDER BY 3,4

--SELECT * 
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select Data we are using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2

--Looking at total cases / total death
-- ROugh estimate of the likelihood of dying in a particular country if you caught covid
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Total Cases v. Population
SELECT Location, date, total_cases, population,(total_cases/population)*100 as InfectedPopuPercentage
FROM [Portfolio Project]..CovidDeaths$
--WHERE Location like '%states%'
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to population
SELECT Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPopuPercentage
FROM [Portfolio Project]..CovidDeaths$
Group By location, population
ORDER BY InfectedPopuPercentage desc

--Showing countries with Highest Death Count per population
Select location, Max(cast(total_deaths as int)) as totalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group By Location
Order By totalDeathCount desc

--Let's break things down by continent


--Showing the continents with highest death count
Select continent, Max(cast(total_deaths as int)) as totalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group By continent
Order By totalDeathCount desc

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage --SUM(cast(new_deaths as int))/ SUM(new_cases)*100  DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

-- Looking at total population v. vaccinations
-- partition ny aka break it apart by
-- we are breaking apart by location not continent because the end result is to have rolling sum in the next column
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
				Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
				Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP Table (Just another way to solve rather than the CTE, Same result)

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
				Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location 
				Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

