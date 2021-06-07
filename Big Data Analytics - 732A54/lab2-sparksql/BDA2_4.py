#########
### 4 ###
#########

from pyspark import SparkContext
from pyspark.sql import SQLContext, Row
from pyspark.sql import functions as F

sc = SparkContext()
sqlContext = SQLContext(sc)

# Temperature data setup
rdd_temp = sc.textFile("BDA/input/temperature-readings.csv")
parts_temp = rdd_temp.map(lambda line: line.split(";"))

temp_readings = parts_temp.map(lambda p: Row( \
    station=p[0], \
    temperature=float(p[3])))

df_temps = sqlContext.createDataFrame(temp_readings)
df_temps.registerTempTable("temp_readings")

# Precipitation data setup 
rdd_precip = sc.textFile("BDA/input/precipitation-readings.csv")
# rdd_precip = sc.textFile("BDA_demo/input_data/precipitation-readings.csv")
parts_precip = rdd_precip.map(lambda line: line.split(";"))

precip_readings = parts_precip.map(lambda p: Row(
    day=p[1].split("-")[2],
    month=p[1].split("-")[1],
    year=p[1].split("-")[0],
    station=p[0], 
    precipitation=float(p[3])))

df_precip = sqlContext.createDataFrame(precip_readings)
df_precip.registerTempTable("precip_readings")

# Summing up hourly precipitation values
df_precip = df_precip.groupBy(["station", "day", "month", "year"]).agg(F.sum("precipitation").alias("precipitation"))

# Get maximum temperature and precipitation by station
max_temps = df_temps.groupBy("station").agg(F.max("temperature").alias("maxTemperature"))
max_precips = df_precip.groupBy("station").agg(F.max("precipitation").alias("maxPrecipitation"))

# Filter entries with temperature between 25 and 30 degrees
max_temps = max_temps.filter((max_temps["maxTemperature"] > 25) & (max_temps["maxTemperature"] < 30))

# Filter entries with precipitation between 100mm and 200mm
max_precips = max_precips.filter((max_precips["maxPrecipitation"] > 100) & (max_precips["maxPrecipitation"] < 200))

# Join dataframes keep only those entries that have data for both maxTemperature and maxPrecipitation
df_output = max_temps.join(max_precips, "station", 'inner') \
    .sort("station") \
    .select(["station", "maxTemperature", "maxPrecipitation"])

df_output.rdd.saveAsTextFile("BDA/output/LAB2_4")