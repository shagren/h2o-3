setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../../scripts/h2o-r-test-setup.R")

test.pojo <- function() {
    #Set up path as dir.create() just sets up the directory and returns a logical based on if if failed or not
    path <- file.path(sandbox(),"pojos")

    #Set up tmp directory to write POJO
    dir <- dir.create(path)

    #Build AutoML
    iris.hex <- h2o.uploadFile(locate("smalldata/iris/iris.csv"), "iris.hex")
    hh <- h2o.automl(x=c(1,2,3,4),y=5,training_frame=iris.hex, max_models=3)

    #Download POJO
    if (hh@leader@algorithm != "stackedensemble") {
        print(sprintf("Dowloading POJO..."))
        start_time <- proc.time()[[3]]
        pojo_file <- h2o.download_pojo(hh,path=path) #check pojo
        end_time <- proc.time()[[3]]
        cat(sprintf("POJO file is %.2f bytes", object.size(pojo_file)),"\n")
        cat(sprintf("Time taken to dowloand POJO: %.2f",end_time - start_time))

        #Download genmodel
        h2o.download_pojo(hh,path=path,get_jar=TRUE) #Check genmodel.jar
    }

    #Delete tmp directory
    on.exit(unlink(path,recursive=TRUE))
}
doTest("Test AutoML POJO", test.pojo)