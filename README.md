# Ukrainian legislative networks dataset (U-LeNet)

## Context

The U-LeNet dataset was created by the Kyiv School of Economics (KSE) research team with the support of the Office of Naval Research (ONR) N00014-17-1-2675 funding.

Current repository includes scripts used for preparing the data and code for some of the projects made using the U-LeNet data:

- Directory **Cleaning data** - code for wrangling and merging raw files with data

- Directory **BI_Sankey** - code for creating a shiny application for vizualizing the migration patterns of MPs between Palriaments of different years

## Content

### The data include the following sets:

1.	Roll call voting 2002-2019

2.	Legislative co-authorship 2002-2019

3.	Attributes of bills and legislative acts

4.	Attributes of Members of parliament (MPs) 1998-2019

Data can be downloaded from the [
Kaggle page](https://www.kaggle.com/dataset/9b5e80df136eddb01b7e860c448436cfc569a8a92409f9b74fad560bbe41d1e6) of the project. Currently the the database of MPs attributes is available.

### Additional materials

1.	Ukrainian Parliament BI tool- migration of MPs between Parliaments and Factions ([link to shiny application](https://ostepaniuk.shinyapps.io/rada_networks/))

2.	Selected models and analyses (R scripts) - see our [Github repository](https://github.com/oleksastepaniuk/ua_parliament_networks)

### Work in progress (soon to be added):

1.	Declarations of MPs – wealth and ties to industries

2.	Voting in committees 

3.	Discussions in committees – transcripts of speeches and conversations

## Inspiration

The U-LeNet data allow:

- Detecting groups of interests in Parliament (cluster analysis, SNA)

- Detecting collaboration (co-authorship and co-voting)

- Predicting the success of a bill

- Testing SNA effects in legislation: QAP correlations, ERGM models, longitudinal network models

Broadly, it allows testing scientific and policy research questions related to the process of legislation.


## List of contributors:

- Tymofii Brik ([link](https://www.linkedin.com/in/tymofii-brik-5b320615/))

- Ostap Kuchma ([link](https://www.linkedin.com/in/ostap-kuchma-209bb951/))

- Oleksandr Nadelniuk ([link](https://www.liga.net/author/aleksandr-nadelnyuk))

- Dmytro Ostapchuk ([link](https://www.linkedin.com/in/dima-ostapchuk/?locale=en_US))

- Oleksa Stepaniuk ([link](https://www.linkedin.com/in/oleksa-stepaniuk/))


## Please cite as
Brik, T., Kuchma, O.,  Nadelniuk, O., Ostapchuk, D., Stepaniuk, O. Ukrainian legislative networks dataset (U-LeNet), 1998-2019. Version 1.0. Kyiv School of Economics, 2019.
