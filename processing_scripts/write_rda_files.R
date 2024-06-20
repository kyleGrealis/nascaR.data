library(tidyverse)
library(glue)

# from_path <- 'data/{i}-series/cleaned'
to_path <- 'nascaR.data/data'

series <- list('cup', 'xfinity', 'truck')

for (i in series) {
    print(i)
    # List of your CSV files
    csv_files <- list.files(
        glue::glue(
            'data/{i}-series/cleaned', pattern = "*.csv", full.names = TRUE
        )
    )
    for (j in csv_files) {
        print(j)
        base_name <- tools::file_path_sans_ext(basename(j))
        print(base_name)

        data <- read_csv(
            glue::glue(
                'data/{i}-series/cleaned/{j}'
            )
        )

        assign(base_name, data)

        save(list = base_name, file = glue::glue('{to_path}/{base_name}.rda'))

        rm(data)
    }
}


# cup_driver_career <- read_csv('data/cup-series/cleaned/cup_driver_career.csv')
# save(cup_driver_career, file = 'nascaR.data/data/cup_driver_career.rda')
