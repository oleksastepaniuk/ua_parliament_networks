# U-LeNet. Visualising migration patterns of Ukrainian MPs

Ukrainian Parliament BI tool is a shiny application that allows to explore the migration of Ukrainian Members of Parliament (MPs) between Parliaments (Ukr. Rada) and Factions. Currently, the tool includes information regarding the last seven convocations (1998-2019) including the current one. Due to the limited access to high quality data, information regarding the first two convocations (1990-1998) is not included. Data collection and harmonization for all other years is in progress.

Tool allows to create and save a Sankey diagram relevant to a specific research question. 

BI is published [
online](https://ostepaniuk.shinyapps.io/rada_networks/).

To recreate the application:

1. Download the subdirectory **BI_Sankey_code**

2. Create a folder **www** inside the **BI_Sankey_code**

3. Download the archive **mps_data_for_shiny_Sankey_BI.zip** from the [
Kaggle page](https://www.kaggle.com/dataset/9b5e80df136eddb01b7e860c448436cfc569a8a92409f9b74fad560bbe41d1e6) of the project. Unpack all the data files to **./BI_Sankey_code/www**

4. Open either **ui.R** or **server.R** with RStudio and run the application
