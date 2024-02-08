Select * 
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

Select * 
From PortfolioProject..CovidVaccinations$
where continent is not null
order by 3, 4

-- Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--total_deaths vs total_cases
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--location like '%Egypt%' and
where continent is not null
order by 1,2


--total_cases vs population
Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as CasesPercentage
From PortfolioProject..CovidDeaths$
where location like '%Egypt%' and continent is not null
order by 1,2

-- Countries with Highest Infection Rate per Population
Select location, population, max(total_cases) as HeighestInfectionCount, max((cast(total_cases as float)/cast(population as float))*100) as CasesPercentage
From PortfolioProject..CovidDeaths$
where continent is not null and location like '%Canada%'
Group by location, population
order by CasesPercentage desc

-- showing continents with heighest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
--where location like '%Egypt%'
order by TotalDeathCount desc

-- GLOBAL NUMBERS grouped by date
select date, sum(new_deaths) as SumOfNewDeaths, sum(new_cases)as SumOfNewCases , sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- GLOBAL NUMBERS

select sum(new_cases)as SumOfNewCases, sum(new_deaths) as SumOfNewDeaths,  (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2, 3

--using cte to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.Date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)

select *, (rollingPeopleVaccinated/population) * 100 as percentage
from PopvsVac

-- temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, (rollingPeopleVaccinated/population) * 100 
from #PercentPopulationVaccinated

--create view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated
