######## Exercise 4 ########
from pyspark import SparkContext

sc = SparkContext(appName = "BDA1_4")

# Temperature and precipitation
temperature_file = sc.textFile("BDA/input/temperature-readings.csv")
precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")

# Map the data, split by lines
lines_temp = temperature_file.map(lambda line: line.split(";"))
lines_precip = precipitation_file.map(lambda line: line.split(";"))

# Map to (station_nb, temperature_value)
station_temp = lines_temp.map(lambda x: (x[0], float(x[3])))

# Get maximum temperature per station
max_temperature = station_temp.reduceByKey(lambda a, b: a if a >= b else b)

# Filter all entries outside of 25-30 degrees
max_temperature = max_temperature.filter(lambda x: x[1] > 25 and x[1] < 30)

station_precip = lines_precip.map(lambda x: ((x[0], x[1][0:4], x[1][5:7], x[1][8:10]), float(x[3])))

# Calculate the sum of precipitation per day
station_precip = station_precip.reduceByKey(lambda a, b: a + b)

# Map to (station_nb, precipitation_value)
station_precip = station_precip.map(lambda x: (x[0][0], x[1]))

# Get maximum precipitation per station
max_precipitation = station_precip.reduceByKey(lambda a, b: a if a >= b else b)

# Filter all entries outside of 100-200mm
max_precipitation = max_precipitation.filter(lambda x: x[1] > 100 and x[1] < 200)

# Join
joined_rdd = max_temperature.join(max_precipitation)
joined_rdd.saveAsTextFile("BDA/output/LAB1_4")

