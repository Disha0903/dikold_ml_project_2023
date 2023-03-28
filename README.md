# dikold_ml_project_2023
This is my project "Using spatial cross validation strategies to mitigate optimistic bias due to Spatial Autocorrelation (SAC)".



This research addresses blocking cross-validation methods to avoid inaccurate results due to the dependence of environmental predictors. Different methods of blocking cross-validation were considered to optimize their parameters in the prediction of a species' habitat suitability. In experiment six models with spatial, B-LOO and random CV were used.

In experiment I used spatial CV with different sizes of block,
B-LOO and random:
  
	"spBlock20" -  the size of block is 20 km
	"spBlock200" - the size of block is 200 km
	"spBlock400" - the size of block is 400 km
	"spBlock700" - the size of block is 700 km
	"B-LOO" - the size of block is 400 km
	"random CV"





*Data* folder contains 3 types of files:
1) Shapefiles with extension '.shp' (for Norway and Sweden countries).  

Do not delete all other files with other extension in folders, they are needed to load 'shp' file.

2) Environmental raster layers with extension 'asc'.

We have ```env_curr```, ```env_past``` and ```env_future``` folders for current, past and future predictions respectively. It is important to save it separately in different folders and change directory (setwd()) with full path to folder when you use ```env_data``` function. Do not delete setwd()

3) CSV files about locations of species.

Suffixes```_abs``` and ```_occ``` mean occurrence points and absence points. Also we have prefixes ```curr```, ```past```, ```fut``` for three time periods as with environmental data. In total there are 6 csv files.

*Scripts* folder contains R scripts and ipynb for plotting (only metrics):

1) Firstly run ```spatial.R```, it contains all preprocessing steps
2) Only after that you could run ```buffered.R``` and ```random.R```
3) To install packages use ```install.packages(' ')```

