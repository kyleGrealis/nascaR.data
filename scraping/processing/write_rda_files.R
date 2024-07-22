library(tidyverse)
library(glue)

# where to save new rda files
to_path <- '../../data'

# list of race series
series <- list('cup', 'xfinity', 'truck')

# loop through each series' CSV files and write new rda files
for (i in series) {
    print(i)
    # List of CSV files
    csv_files <- list.files(
        glue::glue(
            'scraping/data/{i}-series/cleaned', pattern = "*.csv", full.names = TRUE
        )
    )
    for (j in csv_files) {
        print(j)
        base_name <- tools::file_path_sans_ext(basename(j))
        print(base_name)

        data <- read_csv(
            glue::glue(
                'scraping/data/{i}-series/cleaned/{j}'
            )
        )

        assign(base_name, data)

        save(
            list = base_name, 
            file = glue::glue('{to_path}/{base_name}.rda'),
            compress = 'xz'
        )

        rm(data)
    }
}
