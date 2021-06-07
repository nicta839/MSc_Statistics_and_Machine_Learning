#########
### 5 ###
#########

from pyspark import SparkContext
from pyspark.sql import SQLContext, Row
from pyspark.sql import functions as F

sc = SparkContext()
sqlContext = SQLContext(sc)

# Precipitation
rdd_precip = sc.textFile("BDA/input/precipitation-readings.csv")
parts_precip = rdd_precip.map(lambda line: line.split(";"))

precip_readings = parts_precip.map(lambda p: Row(
    station=p[0],
    month=p[1].split("-")[1],
    year=p[1].split("-")[0],
    precipitation=float(p[3])))

df_precip = sqlContext.createDataFrame(precip_readings)
df_precip.registerTempTable("precip_readings")

# Stations
rdd_stations = sc.textFile("BDA/input/stations-Ostergotland.csv")
parts_stations = rdd_stations.map(lambda line: line.split(";"))

# Filter data by year requirements (1993-2016)
df_precip = df_precip.filter((df_precip["year"] >= 1993) & (df_precip["year"] <= 2016))

# Collecting RDD and broadcasting the local python object to all nodes
station_ids_oster = parts_stations.map(lambda x: x[0])
stations_ids = sc.broadcast(station_ids_oster.collect()).value

# Keep only those stations inside Ostergotland
df_precip = df_precip[df_precip["station"].isin(stations_ids)] \
    .sort(["year", "month"]) \
    .select(["station", "year", "month", "precipitation"])

# Sum up precipitation per station per month and year
df_sum = df_precip.groupBy(["station", "year", "month"]).agg(F.sum("precipitation").alias("totalPrecipitation"))

# Avg over all stations 
df_avg = df_sum.groupBy("year", "month").agg(F.avg("totalPrecipitation").alias("avgPrecipitation")).sort(["year", "month"])

df_avg.rdd.saveAsTextFile("BDA/output/LAB2_5")