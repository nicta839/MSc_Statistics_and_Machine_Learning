######## Exercise 1 ########
from pyspark import SparkContext

sc = SparkContext(appName = "BDA1_1")

temperature_file = sc.textFile("BDA/input/temperature-readings.csv")

# Map the data, split by lines
lines = temperature_file.map(lambda line: line.split(";"))

# Year and temp (think about adding stations here as well?)
year_temperature = lines.map(lambda x: (x[1][0:4], float(x[3])))

# Filter year
year_temperature = year_temperature.filter(lambda x: int(x[0])>=1950 and int(x[0])<=2014)

# Max temp
max_temperature = year_temperature.reduceByKey(lambda a, b: a if a >= b else b)
max_temperature_sorted = max_temperature.sortBy(ascending=False, keyfunc=lambda k: k[1])
# Min temp
min_temperature = year_temperature.reduceByKey(lambda a, b: a if a < b else b)
min_temperature_sorted = min_temperature.sortBy(ascending=False, keyfunc=lambda k: k[1])

# save the data
max_temperature_sorted.saveAsTextFile("BDA/output/LAB1_MAX")
min_temperature_sorted.saveAsTextFile("BDA/output/LAB1_MIN")

