select *
from covidproject.dbo.coviddeath
order by 3,4

--select *
--from covidproject.dbo.covidvacine
--order by 3,4

--Select the data that gonna be using

select location, date, total_cases, new_cases, total_deaths, population
from covidproject.dbo.coviddeath
order by 1,2

--Calculating total death percentage compared to total case
--and showing probability of death case if you contract covid in Indonesia
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from covidproject.dbo.coviddeath
where location='Indonesia'
order by 1,2

--Calculating percentage total case compared to population 
--showing probability of people got infected by covid in Indonesia
select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from covidproject.dbo.coviddeath
where location='Indonesia'
order by 1,2

-- Finding Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Count_of_Highest_Infection,  Max((total_cases/population))*100 as Infected_Percentage
From covidproject.dbo.coviddeath
Group by Location, Population
order by infected_percentage desc

-- Finding Countries with Highest Death per Population

Select Location, MAX(cast(Total_deaths as int)) as Count_of_Total_Death
From covidproject.dbo.coviddeath
Where continent is not null 
Group by Location
order by Count_of_Total_Death desc

-- finding contintents with the highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as Count_of_Total_Death
From covidproject.dbo.coviddeath
Where continent is not null 
Group by continent
order by Count_of_Total_Death desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From covidproject.dbo.coviddeath
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From covidproject.dbo.coviddeath dea
Join covidproject.dbo.covidvacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With Pop_vs_Vacs (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From covidproject.dbo.coviddeath dea
Join covidproject.dbo.covidvacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Vaccinated_percentage
From Pop_vs_Vacs



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From covidproject.dbo.coviddeath dea
Join covidproject.dbo.covidvacine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100  Vaccinated_percentage
From #Percent_Population_Vaccinated


-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From covidproject.dbo.coviddeath dea
Join covidproject.dbo.covidvacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

