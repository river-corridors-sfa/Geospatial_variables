# Geospatial_variables

The scripts in this repository have been adapted from the original scripts written by Katie Willi. The original scripts can be found [here](https://github.com/rossyndicate/geospatial_for_conus_waters).   
If you use this data for your manuscript, please cite Katie's package as follows:   
Kathryn Willi, & Matthew R. V. Ross. (2023). Geospatial Data Puller for Waters in the Contiguous United States (Version v1). Zenodo. https://doi.org/10.5281/zenodo.8140272 

In addition to providing the data exported by Katie's script, here you will also find Net Primary Production (NPP) and Evapotranspiration data (ER) for the RC-SFA sites. The data was extracted using a script developed by Kristian Nelson. Net Primary Production is a mosaic of data from [here](https://e4ftl01.cr.usgs.gov/MOLT/MOD17A3HGF.061/2015.01.01/).
Evapotranspiration came is a mosaic of data from [here](https://e4ftl01.cr.usgs.gov/MOLT/MOD16A3GF.061/2021.01.01/).    


# Notes on the Data
## Please Read!
The Geospatial data generated for the RC-SFA (see v2_RCSFA_Extracted_Geospatial_Data_2023-06-21.csv), has been generated using v2 of the RC-SFA Geospatial Data Package on ESS-DIVE located [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251). The data package was downloaded on 06-20-2023 and data was generated on 06-21-2023. This file contains Geospatial information for all the RC-SFA sites in the United States and needs to be filtered by the user based on study of interest. If your site of interest is not present in the output it could be because:        

1- It is not in the United States.      
2- It is a small stream and does not have COMID associated with it. See ESS-DIVE data package [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251).    
3- The COMID for the site was flagged as a NHDPlusV2 non-network dataset. See ESS-DIVE data package [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251) for details.     


**Note**: COMIDs have been removed from the Geospatial outputs, if you need COMIDs, download the ESS-DIVE data package here [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251).         

**Note**: **A readme defining the NHD exported variables can be found [here](http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NationalData/0Release_Notes_NationalData_Seamless_GeoDatabase.pdf). A readme defining the StreamCat exported variables can be found [here](https://www.epa.gov/national-aquatic-resource-surveys/streamcat-metrics-and-definitions).**


# Instructions
At this point in time, the approach to using data extracted from the Katie Willi code for Geospatial Variables for the SFA is as follows :       

1- The base data (coordinates, site names, COMIDs) have been published on ESS-DIVE. This data package should be used as needed and cited when used.          

2- The GitHub is designed to make it easier for people to access extracted geospatial data. **There is a steward (VGC) who runs the code to extract data** when the geospatial DP is updated or when another need arises. The output is put in the github with a version number corresponding to the geospatial data package version. The date in the file name corresponds to the date the code was run.         

3- If you use the extracted data, make sure to note the version number. In your analysis products, you will cite the DP and the github, including the output file with its version number and date.       

4- **There is no need for you to run this code. You should just download the output file and subset as needed.**          

5- It is critical to maintain traceable provenance in your data, which is why we are directing you to go to the data package directly for COMIDs and have a steward for this specific code output.            

6- If you have requests, questions, or ideas for improvement, contact VGC, Brie, and Amy
