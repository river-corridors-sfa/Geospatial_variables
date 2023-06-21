# Geospatial_variables

The scripts in this repository have been adapted from the original scripts written by Katie Willi. The original scripts can be found [here](https://github.com/rossyndicate/geospatial_for_conus_waters). 

# Notes on the Data. Please Read!
The Geospatial data generated for the RC-SFA (see Geospatial_data_RCSFA_06-21-2023.csv), has been generated using v2 of the RC-SFA Geospatial Data Package on ESS-DIVE located [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251). The data package was downloaded on 06-20-2023 and data was generated on 06-21-2023. This file contains Geospatial information for all the RC-SFA sites in the Unitied States and needs to be filterd by the user based on study of interest. If your site of interest is not present in the output it could be because:        

1- It is not in the United States.      
2- It is a small stream and does not have COMID associated with it. See ESS-DIVE data package [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251).    
3- The COMID for the site was flagged as a NHDPlusV2 non-network dataset. See ESS-DIVE data package [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251) for details.     


**Note**: COMIDs have been removed from the Geospatial outputs, if you need COMIDs, download the ESS-DIVE data package here [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251).


# Notes for running the script. 
## Read before you start
1- Clone/Fork (TBD) this repository.       

2- Before running the scripts, make you copy the data folder located [here](https://pnnl.sharepoint.com/teams/SubsurfaceBiogeochemicalResearchSFA/Shared%20Documents/Forms/AllItems.aspx?csf=1&web=1&e=VFZ6Wh&xsdata=MDV8MDF8fGQ3ZDJmMzFlZTIwMDQyMDQ1ZjY3MDhkYjYyMDFiODYwfGQ2ZmFhNWY5MGFlMjQwMzM4YzAxMzAwNDhhMzhkZWVifDB8MHw2MzgyMTE1MzE3MzA4NzAxMTl8VW5rbm93bnxWR1ZoYlhOVFpXTjFjbWwwZVZObGNuWnBZMlY4ZXlKV0lqb2lNQzR3TGpBd01EQWlMQ0pRSWpvaVYybHVNeklpTENKQlRpSTZJazkwYUdWeUlpd2lWMVFpT2pFeGZRPT18MXxMMk5vWVhSekx6RTVPalV6T1RKaU1EQmhMVEpoWVRNdE5EWTJaQzA0TldWaUxXUTRORGxsTWpBd056SXdZVjlsTVRJNVl6RXlaaTAzTkRsaExUUXpNVEF0T0RCaU5pMHdOREprTW1NM05XWTNOREZBZFc1eExtZGliQzV6Y0dGalpYTXZiV1Z6YzJGblpYTXZNVFk0TlRVMU5qTTNNVGd5TXc9PXw1ZGM2M2MxMmI5Nzg0MTgxOWMyYjA4ZGI2MjAxYjg1ZnwzMzQwNzI0MDNiOTA0ZWEyOGFmZWQ0NmY0NmRlZDkwOQ%3D%3D&sdata=eFdDWlBuV0g1T3hXNVFKVjRkYnRVZm1iWUcyeXpjTWNvVTZMaGpmWVVGST0%3D&ovuser=d6faa5f9%2D0ae2%2D4033%2D8c01%2D30048a38deeb%2Cvanessa%2Egarayburu%2Dcaruso%40pnnl%2Egov&OR=Teams%2DHL&CT=1685575654861&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yMzA0MDIwMjcwNSIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D&cid=67c2abdc%2Ddc11%2D4451%2Dab1e%2Dcb620733d301&FolderCTID=0x012000474D2176820892418DD7D564CC1671FA&id=%2Fteams%2FSubsurfaceBiogeochemicalResearchSFA%2FShared%20Documents%2FGeneral%2FSFA%20Data%20and%20Software%20Management%2FKatie%5FR%5FCode%2Fgeospatial%5Ffor%5Fconus%5Fwaters%2Fdata&viewid=51be1786%2D6571%2D4313%2D804e%2D90711f81140d) into your GitHub local folder for this repository. This folder is too large and should not ne included in future commits. Git Ignore settings should take care of that but be aware in case something doesn't work.      

3- Make sure you have all the packages called at the beginning of the code installed  

4- A readme of the NHD exported variables can be found [here](https://edap-ow-data-commons.s3.amazonaws.com/NHDPlusV21/Data/NationalData/0Release_Notes_NationalData_Seamless_GeoDatabase.pdf). A readme for the StreamCat exported variables can be found [here](https://www.epa.gov/national-aquatic-resource-surveys/streamcat-metrics-and-definitions).

## General Note
Markdowns have as a default the working directories of the place where the markdown is saved.  Make sure you keep and follow the folder structure to avoid issues with working directories.    

##  Notes on the scripts   
- geospatial_extraction_with_comids_VGC: Pulls data from NHD, StreamCat, PRISM and other sources. **Note you MUST have correct and QAQC COMIDs for this step** 

For RC-SFA QAQC COMIDs, download the Data Package from ESS-DIVE located [here](https://data.ess-dive.lbl.gov/view/doi:10.15485/1971251).
- geospatial_workflow_check_comids: Provides a workflow that allows you to plot,check and rectify COMIDs based on the site coordinates.    

Both scripts currently run using the placeholder.csv file to exemplify the workflow. Markdowns as well as example output files are included in teh GitHub for reference. 

