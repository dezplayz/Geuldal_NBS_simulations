#! --matrixtable --lddin --clone mask.map 
############################################
# Model: Adjust DEM for flooding areas     #
# Date: 28-10-2026                         #
# Author: Tijs de Pagter                   #
############################################

binding

# load maps
dem = dem.map;
landuse = landuse.map;

# output maps
updated = updated_dem.map;

initial
area = dem * 0 + 1;

# Identify cells with NBS_ID for flood area dams (NBS_ID = 29).
Dams = landuse == 29;

# Assign separate IDs to each line of cells to separate the different dams.
LineID = clump(Dams); 

# Count for each cell the amount of neighbour cells with NBS_ID = 29. 
Neighbour_Count = window4total(if(Dams, scalar(1), scalar(0)));

# Identify the end cells of each line of cells by the amount of neighbours,
# end cells will only have one neighbouring cell with NBS_ID = 29.
Endpoints = Dams and (Neighbour_Count eq 1);

# Find the lower and higher endpoint elevations for each line.
# find the lowest end point on the line, replace all other values with very large value (=NA)
Min_Height = areaminimum(if(Endpoints, dem, scalar(1e30)),LineID);

# find the highest end point on the line, replace all other values with a very large value (=NA)
#Max_Height = areamaximum(if(Endpoints, dem, scalar(1e30)),LineID); # unneccessary, remove

# find the lowest height among the cells of the dam.
Lowest_elevation = areaminimum(dem, LineID);

# Set a threshold for the two different options for dam height. This is calculated as the lowest
# elevation along the dam line plus the maximum dam height variable.
Threshold = Lowest_elevation + 1.5;

# The correct height option for each dam line is chosen.
# Option 1: If Threshold is lower than Min_Height, Dam_Height becomes Threshold. 
# Dam cells below the threshold are raised to it.
# Option 2: If Threshold is higher than Min_Height, Dam_Height becomes Min_Height. 
# Dam cells below the lowest endpoint elevation are raised to it.
Dam_Height = if(Threshold < Min_Height, Threshold, Min_Height);

# The cells will be raised to the correct dam height, dependent on which option is chosen.
# note: cells will only be raised, never lowered.
report updated = if(Dams, max(dem, Dam_Height), dem);

# for testing if the procedure works: calculate the difference between the original
# dem and updated dem.

#Difference = updated - dem;
#report test_difference.map = Difference;