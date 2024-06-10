--Post Covid Data Analysis

--Post Covid Data
SELECT *
FROM CovidProject..PostCovid
ORDER BY Value

-- DATA EXPLORATION

-- Looking at Indicator vs Average Percentage Value
SELECT Indicator, AVG(cast(Value as float)) as avg_percent_value
FROM CovidProject..PostCovid
GROUP BY Indicator
ORDER BY avg_percent_value desc

-- Looking at Indicator with Subgroup vs Average Percentage Value (proportion of all all US adults)
SELECT Indicator, Subgroup, AVG(cast(Value as float)) as avg_percent_value
FROM CovidProject..PostCovid
GROUP BY Indicator, Subgroup
ORDER BY avg_percent_value desc

-- Looking at Indicator with State vs Average Percentage Value
SELECT Indicator, State, AVG(cast(Value as float)) as avg_percent_value
FROM CovidProject..PostCovid
GROUP BY Indicator, State
ORDER BY Indicator

-- Looking at Average Percentage Value for each Group
SELECT Indicator, [Group], AVG(cast(Value as float)) as avg_percent_value
FROM CovidProject..PostCovid
GROUP BY Indicator, [Group]
ORDER BY avg_percent_value desc

-- Average Margin of Error for all Indicators
SELECT Indicator, AVG((HighCI - LowCI) / 2) AS average_margin_of_error
FROM CovidProject..PostCovid
GROUP BY Indicator

 -- Looking at all States with higher Average Percentage Value than the National Average (Subquery Use)
SELECT State, AVG(cast(Value as float)) as avg_percent_value
FROM CovidProject..PostCovid
WHERE State != 'United States'
GROUP BY State
HAVING AVG(Value) > (
    SELECT AVG(Value)
    FROM CovidProject..PostCovid
    WHERE State = 'United States'
);

-- Looking at Trend Over Time for Each Indicator
SELECT Indicator, "Time Period Start Date" AS time_period_start_date, AVG(Value) AS average_value
FROM CovidProject..PostCovid
GROUP BY Indicator, "Time Period Start Date"
ORDER BY Indicator, "Time Period Start Date"

-- Looking at Indicator With Most Variability
SELECT top 1 Indicator, STDEV(Value) AS sd_value
FROM CovidProject..PostCovid
GROUP BY Indicator
ORDER BY sd_value DESC

-- Looking at Top 5 States by Average Percentage Value for Each Indicator
WITH state_avgs AS(
	SELECT State, Indicator, AVG(Value) as average_value
	FROM CovidProject..PostCovid
	WHERE State != 'United States'
	GROUP BY State, Indicator
)
SELECT Indicator, State, average_value
FROM (
	SELECT Indicator, State, average_value, ROW_NUMBER() OVER (PARTITION BY Indicator ORDER BY average_value DESC) AS rank
	From state_avgs
) Ranked
WHERE rank <= 5

--Looking at State-Wise Comparison Across Different Phases
SELECT State, Phase, AVG(Value) AS average_value
FROM CovidProject..PostCovid
WHERE State != 'United States'
GROUP BY State, Phase
ORDER BY State, Phase

--Looking at Distribution of Values by Quantiles
WITH Quartiles AS (
    SELECT Indicator, 
           NTILE(4) OVER (PARTITION BY Indicator ORDER BY Value) AS Quartile
    FROM CovidProject..PostCovid
)
SELECT Indicator, Quartile, COUNT(*) AS Count
FROM Quartiles
GROUP BY Indicator, Quartile