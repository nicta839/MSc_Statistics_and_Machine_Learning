######## Exercise 3 ########
from pyspark import SparkContext

sc = SparkContext(appName = "BDA1_3")

temperature_file = sc.textFile("BDA/input/temperature-readings.csv")

# Map the data, split by lines
lines = temperature_file.map(lambda line: line.split(";"))

# (Year, month, station) key, (temp) value
daily_station_temp = lines.map(lambda x: ((x[1][0:4], x[1][5:7], x[1][8:10], x[0]), (float(x[3]))))

# Filter time period 1960-2014
daily_station_temp = daily_station_temp.filter(lambda x: int(x[0][0]) >= 1960 and int(x[0][0]) <= 2014)

# Get Max and Min temperature for each day
max_temperature = daily_station_temp.reduceByKey(lambda a, b: a if a >= b else b)
min_temperature = daily_station_temp.reduceByKey(lambda a, b: a if a < b else b)

# Join Max and Min temperatures 
joined_rdd = max_temperature.join(min_temperature)

# Map to ((year, month, station_nb), daily_avg_temperature)
yearmonthstation_avgtemp = joined_rdd.map(lambda x: ((x[0][0], x[0][1], x[0][3]), (x[1][0] + x[1][1]) / 2))

# Get the average monthly temperature
count_values_rdd = yearmonthstation_avgtemp.mapValues(lambda v: (v, 1))
reduced_rdd = count_values_rdd.reduceByKey(lambda a,b: (a[0]+b[0], a[1]+b[1]))
avg_by_key_rdd = reduced_rdd.mapValues(lambda v: v[0]/v[1])

avg_by_key_rdd.saveAsTextFile("BDA/output/LAB1_3")

