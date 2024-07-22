library(tidyverse)
library(glue)

# list of race series
series <- list('cup', 'xfinity', 'truck')

# loop through each series' CSV files and write new rda files
for (i in series) {
    print(i)
    
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

        # write the new rda files and save them in the package data directory
        save(
            list = base_name, 
            file = glue::glue('data/{base_name}.rda'),
            compress = 'xz'
        )

        rm(data)
    }
}
