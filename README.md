# Physiognomica
Fisiognomica is a novel data Analytics Profiler of metrics comming from promentheus monitoring engine.   
It is an R package that supports a set of functions as presented at the wiki page. The supported funtions are available for execution via an opencpue server. Physiognomica functions can be execute both by R or via opencpu API. Physiognomica functions can be both triggered as separate analysis services or as a analisis fucntion chain. Physiognomica analisis functions can be registered at cloud-apps-profiler project platform or can be used separately.

#### Supported Analysis chain:
<img src="/images/functionchaingeneric.png">

#### Prerequisites:
1. R Project for Statistical Computing mininum version (R version 3.4.4 (2018-03-15))
https://www.r-project.org/
1. Opencpu API for Embedded Scientific Computing
https://www.opencpu.org/
```
# Requires Ubuntu 18.04 (Bionic) or 16.04 (Xenial)
sudo add-apt-repository -y ppa:opencpu/opencpu-2.1
sudo apt-get update 
sudo apt-get upgrade

# Installs OpenCPU server
sudo apt-get install -y opencpu-server
# Done! Open http://yourhost/ocpu in your browser

# Optional: installs rstudio in http://yourhost/rstudio
sudo apt-get install -y rstudio-server 
```

#### Supported Analysis results
Following are presented some analysis results. For more details see the wiki page:

| Analysis Service  | Result |
| ------------- | ------------- |
| correlogram  | <img src="/images/correlogram.png"> |
| chord diagram  | <img src="/images/mychordExample.png"> |
| linear regression  | <img src="/images/resourceefficiency.png"> |

#### License
This component is published under Apache 2.0 license. Please see the LICENSE file for more details.

#### Lead Developers
The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

- Eleni Fotopoulou ([@elfo](https://github.com/efotopoulou))
- Anastasios Zafeiropoulos ([@tzafeir ](https://github.com/azafeiropoulos)) 

#### Rererences
1.https://stackoverflow.com/questions/34525173/how-to-create-correlogram-using-d3-as-in-the-example-picture/34539194#34539194
2.http://jokergoo.github.io/blog/html/large_matrix_circular.html  
3.https://datascience-enthusiast.com/R/Interactive_chord_diagrams_R.html  
4.https://rpsychologist.com/d3/correlation/  
5.https://github.com/mattflor/chorddiag  
6.https://github.com/mattflor/chorddiag/blob/master/man/chorddiag.Rd  
7.https://rdrr.io/github/software-analytics/Rnalytica/man/stepwise.vif.html  
8.https://www.rdocumentation.org/packages/usdm/versions/1.1-18/topics/vif  
9.https://rdrr.io/cran/circlize/man/chordDiagram.html  
10.https://psycnotes.wordpress.com/selecting-and-visualizing-only-significant-correlation-coefficients-in-matrix/   
11.https://datascience-enthusiast.com/R/Interactive_chord_diagrams_R.html  
12.https://www.quora.com/Why-do-R-programmers-use-complicated-OpenCPU-for-web-apps-if-they-have-great-Shiny-platform  
13.https://stackoverflow.com/questions/22255465/assign-colors-to-a-range-of-values  
14.https://www.weave.works/blog/distributed-tracing-loki-zipkin-prometheus-mashup/  
