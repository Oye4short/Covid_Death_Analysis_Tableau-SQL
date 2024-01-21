Select *
From NewPortfolioProject..Covid_Deaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From NewPortfolioProject..Covid_Deaths
Where continent is not null 
order by 1,2

--/*percentage death per covid cases
--Shows likelyhood of death once infected*/

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From NewPortfolioProject..Covid_Deaths

order by 1,2

 --Total Cases vs Population
 --Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectedPopulationPercentage
From NewPortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPopulationPercentage
From NewPortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by InfectedPopulationPercentage desc

-- Countries with Highest Death Count 
-- Not taking into consideration the population of the country.

Select Location, MAX((total_deaths)) as TotalDeathCount
From NewPortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--This is another way to do the above if the column type was in an (nvarchar type)
-- it will view the column as an integer (int) for easy analysis.
/*Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From NewPortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc*/

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select Location, MAX(Total_deaths) as TotalDeathCount
From NewPortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is null 
Group by Location
order by TotalDeathCount desc

--Select continent, MAX(Total_deaths) as TotalDeathCount
--From NewPortfolioProject..Covid_Deaths
----Where location like '%states%'
--Where continent is not null 
--Group by continent
--order by TotalDeathCount desc

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From NewPortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

/*Covid Vaccinations analysis*/

Select *
From NewPortfolioProject..Covid_deaths dea
join NewPortfolioProject..Covid_Vaccinations vac
on dea.location =vac.location
and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
--, (Rolling_People_Vaccinated/population)*100
From NewPortfolioProject..Covid_deaths dea
join NewPortfolioProject..Covid_Vaccinations vac
on dea.location =vac.location
and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVac
--, (dea.RollingVac/population)*100
From NewPortfolioProject..Covid_deaths dea
join NewPortfolioProject..Covid_Vaccinations vac
on dea.location =vac.location
and dea.date = vac.date

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVac
--, (RollingVac/population)*100
From NewPortfolioProject..Covid_Deaths dea
Join NewPortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingVac/Population)*100 as PercentageRollingVac
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

From NewPortfolioProject..Covid_Deaths dea
Join NewPortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *

From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVac
--, (RollingPeopleVaccinated/population)*100
From NewPortfolioProject..CovidDeaths dea
Join NewPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated
