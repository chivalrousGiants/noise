FROM opencpu/rstudio

EXPOSE 80
EXPOSE 8004

CMD service opencpu restart && /usr/bin/R -e 'install.packages("limSolve", repos="https://cran.cnr.berkeley.edu/");install.packages("glmnet", repos="https://cran.cnr.berkeley.edu/");install.packages("RJSONIO", repos="https://cran.cnr.berkeley.edu/");library(devtools);install_github("rhanzawa/noise/analysis-server/rapporDecode", ref = "feat/DPAnalysis");' && /bin/bash
