######## Exercise 5 ########
from pyspark import SparkContext

sc = SparkContext(appName = "BDA1_5")

# Precipitation and otsergotland
precipitation_file = sc.textFile("BDA/input/precipitation-readings.csv")
oster_station = sc.textFile("BDA/input/stations-Ostergotland.csv")

# Map the data, split by lines
lines_precip = precipitation_file.map(lambda line: line.split(";"))
lines_oster = oster_station.map(lambda line: line.split(";"))

# Create tuple ((year, month, station_num), precipitation)
yearmonthstation_precip = lines_precip.map(lambda x: ((x[1][0:4], x[1][5:7], x[0]), float(x[3])))
yearmonthstation_precip_filtered = yearmonthstation_precip.filter(lambda x: int(x[0][0]) >= 1993 and int(x[0][0]) <= 2016)

# Collecting RDD and broadcasting the local python object to all nodes
station_ids_oster = lines_oster.map(lambda x: x[0])
stations_ids = sc.broadcast(station_ids_oster.collect()).value

# Keep only stations within Ostergotland 
filtered_rdd = yearmonthstation_precip_filtered.filter(lambda x: x[0][2] in stations_ids)

# Map to ((year, month), (precipation_value, 1))
filtered_rdd = filtered_rdd.reduceByKey(lambda a, b: a+b)
count_values_rdd = filtered_rdd.map(lambda x: ((x[0][0], x[0][1]), (x[1], 1)))

# Reduce to ((year, month), (precipitation_value_sum, count))
reduced_rdd = count_values_rdd.reduceByKey(lambda a, b: (a[0]+b[0], a[1]+b[1]))

# Map to ((year, month), average_precipitation)
avg_by_key_rdd = reduced_rdd.mapValues(lambda v: v[0]/v[1]).sortByKey()

avg_by_key_rdd.saveAsTextFile("BDA/output/LAB1_5")
